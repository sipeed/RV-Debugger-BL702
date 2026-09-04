/**
 * @file main.c
 * @brief 
 * 
 * Copyright (c) 2021 Sipeed team
 * 
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.  The
 * ASF licenses this file to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations
 * under the License.
 * 
 */
#include "hal_usb.h"
#include "usbd_core.h"
#include "usbd_ftdi.h"
#include "usb_descriptor.h"
#include "uart_interface.h"
#include "bl702_ef_ctrl.h"
#include "bl702_usb.h"
#include "bl702_glb.h"
#include "hal_gpio.h"
#include "hal_mtimer.h"
#include "io_cfg.h"

/*
UART:
	RXD	-> ringbuffer -> usbd_cdc_acm_bulk_in -> CDC_IN_EP
UART <---------------------------------------------------> USB
	TXD <- ringbuffer <- usbd_cdc_acm_bulk_out<- CDC_OUT_EP
	
JTAG:
	jtag_rx_buffer[jtag_rx_pos] -> jtag_cmd -> mpsse status machine
	MPSSE_TRANSMIT_BYTE/BIT MSB/LSB MPSSE_TMS_OUT
	bitbang simulate clk rate about 5MHz
*/

extern struct device* usb_dc_init(void);
extern void jtag_process(void);
extern void jtag_ringbuffer_init(void);
extern void jtag_gpio_init(void);
extern void usbd_cdc_jtag_out(uint8_t ep);
extern void usbd_cdc_jtag_in(uint8_t ep);

usbd_class_t cdc_class0;
usbd_interface_t cdc_data_intf0;
usbd_class_t cdc_class1;
usbd_interface_t cdc_data_intf1;
struct device *usb_fs;


/************************  led ctrl functions  ************************/
/* The production Tang Nano 9K has one BL702-controlled LED (LED_STATE).
 * Keep the indexed API used by the USB/UART paths so older diagnostics can
 * still call led_toggle(0), while out-of-range legacy LED1 calls are safe. */
#ifndef LED_COUNT
#define LED_COUNT 1
#endif
#if LED_COUNT > 1
static uint32_t led_pins[LED_COUNT] = {LED0_PIN, LED1_PIN};
#else
static uint32_t led_pins[LED_COUNT] = {LED0_PIN};
#endif
static volatile uint8_t led_stat[LED_COUNT] = {0};
static void led_gpio_init(void)
{
    for (uint8_t idx = 0; idx < LED_COUNT; idx++) {
        gpio_set_mode(led_pins[idx], GPIO_OUTPUT_MODE);
    }
	return;
}

void led_set(uint8_t idx, uint8_t status)
{
    if (idx >= LED_COUNT) {
        return;
    }
    gpio_write(led_pins[idx], !status);
	led_stat[idx] = status;
	return;
}

void led_toggle(uint8_t idx)
{
	if (idx >= LED_COUNT) {
		return;
	}
	led_stat[idx] = !led_stat[idx];
    gpio_write(led_pins[idx], !led_stat[idx]);
	return;
}

/************************  API for usbd_ftdi  ************************/
void usbd_ftdi_set_line_coding(uint32_t baudrate, uint8_t databits, uint8_t parity, uint8_t stopbits)
{
    uart_parity_t uart_parity;
    uart_stopbits_t uart_stopbits;

    /* FTDI encodes 1/1.5/2 stop bits as 0/1/2, while the BL702 HAL uses
     * 1/2/3 (0 means 0.5 stop bit).  Do not pass the FTDI value through. */
    switch (stopbits & 0x03) {
        case 1:
            uart_stopbits = UART_STOP_ONE_D_FIVE;
            break;
        case 2:
            uart_stopbits = UART_STOP_TWO;
            break;
        case 0:
        default:
            uart_stopbits = UART_STOP_ONE;
            break;
    }

    switch (parity & 0x07) {
        case 1:
            uart_parity = UART_PAR_ODD;
            break;
        case 2:
            uart_parity = UART_PAR_EVEN;
            break;
        case 0:
        default:
            uart_parity = UART_PAR_NONE;
            break;
    }

    Ring_Buffer_Reset(&uart1_rx_rb);
    Ring_Buffer_Reset(&usb_rx_rb);
    uart1_config(baudrate, databits, uart_parity, uart_stopbits);
    MSG("[uart1] line coding %lu,%u,%u,%u\r\n", baudrate, databits,
        parity & 0x07, stopbits & 0x03);
}

void usbd_ftdi_set_dtr(bool dtr)
{
#if UART1_HAS_MODEM_CONTROL
    dtr_pin_set(!dtr);
#else
    /* GPIO28 is Boot_Strap on Tang Nano 9K 3674; there is no DTR net. */
    (void)dtr;
#endif
}

void usbd_ftdi_set_rts(bool rts)
{
#if UART1_HAS_MODEM_CONTROL
    rts_pin_set(!rts);
#else
    /* GPIO24 is LED_STATE and GPIO25 is NC; neither is RTS. */
    (void)rts;
#endif
}


/************************  USB UART logic for latency timer  ************************/
static volatile uint32_t temp_tick2 = 0;	//tick for uart port
static volatile uint32_t temp_tick1 = 0;	//tick for jtag port
static uint64_t last_send[2] = {0, 0};

// UART RX -> USB IN
uint16_t usb_dc_ftdi_send_from_ringbuffer(struct device *dev, Ring_Buffer_Type *rb, uint8_t ep)
{
    uint8_t ep_idx;
    uint8_t channel;
    uint32_t timeout = 0x00FFFFFF;

    ep_idx = USB_EP_GET_IDX(ep);
    channel = (ep_idx - 1) / 2;
    /* Check if IN ep */
    if (USB_EP_GET_DIR(ep) != USB_EP_DIR_IN)
    {
        return -USB_DC_EP_DIR_ERR;
    }

    while (!USB_Is_EPx_RDY_Free(ep_idx))
    {
        timeout--;
        if (!timeout)
        {
            MSG("ep%d wait free timeout\r\n", ep);
            return -USB_DC_EP_TIMEOUT_ERR;
        }
    }

    uint32_t addr = USB_BASE + 0x118 + (ep_idx - 1) * 0x10;

    if ((USB_Get_EPx_TX_FIFO_CNT(ep_idx) == USB_FS_MAX_PACKET_SIZE) && Ring_Buffer_Get_Length(rb))
    {
        uint8_t ftdi_header[2] = {0x31,0x60};
        memcopy_to_fifo((void *)addr,ftdi_header,2);
        Ring_Buffer_Read_Callback(rb, USB_FS_MAX_PACKET_SIZE-2, memcopy_to_fifo, (void *)addr);
        USB_Set_EPx_Rdy(ep_idx);
		led_toggle(0);	//RX indication
		last_send[channel] = mtimer_get_time_us();
        return 0;
    }
    else
    {
		/*uint64_t Latency_Timer = (ep_idx - 1)==0?usbd_ftdi_get_latency_timer1():usbd_ftdi_get_latency_timer2();	//超时才发
		if(mtimer_get_time_us()-last_send>Latency_Timer*1000) {
			uint8_t ftdi_header[2] = {0x31,0x60};       
			memcopy_to_fifo((void *)addr,ftdi_header,2);
			USB_Set_EPx_Rdy(ep_idx);
			last_send[channel] = mtimer_get_time_us();
			//MSG("Port%d refresh\r\n", ep_idx);
			return -USB_DC_RB_SIZE_SMALL_ERR;
		}*/
		
        if(ep == CDC_IN_EP) //UART
        {
            if((uint32_t)(usbd_ftdi_get_sof_tick()-temp_tick2) >= usbd_ftdi_get_latency_timer2())
            {
                uint8_t ftdi_header[2] = {0x31,0x60};     
                temp_tick2 = usbd_ftdi_get_sof_tick();                 
                memcopy_to_fifo((void *)addr,ftdi_header,2);
                USB_Set_EPx_Rdy(ep_idx);
            }
        }
		else if (ep == JTAG_IN_EP)	//0x81, JTAG
        {
			if(mtimer_get_time_us()-last_send[channel]>1000)
            {
				uint8_t ftdi_header[2] = {0x31,0x60};     
				temp_tick1 = usbd_ftdi_get_sof_tick();  				
				memcopy_to_fifo((void *)addr,ftdi_header,2);
				USB_Set_EPx_Rdy(ep_idx);
			}
        }
        return -USB_DC_RB_SIZE_SMALL_ERR; 
    }

}

// USB OUT -> UART TX
int usb_dc_ftdi_receive_to_ringbuffer(struct device *dev, Ring_Buffer_Type *rb, uint8_t ep)
{
    uint8_t ep_idx;
    uint8_t recv_len;
    uint32_t timeout = 0x00FFFFFF;
    static bool overflow_flag[8] = {false};

    /* Check if OUT ep */
    if (USB_EP_GET_DIR(ep) != USB_EP_DIR_OUT)
    {
        //USB_DC_LOG_ERR("Wrong endpoint direction\r\n");
        return -USB_DC_EP_DIR_ERR;
    }

    ep_idx = USB_EP_GET_IDX(ep);

    while (!USB_Is_EPx_RDY_Free(ep_idx))
    {
        timeout--;
        if (!timeout)
        {
            //USB_DC_LOG_ERR("ep%d wait free timeout\r\n", ep);
            return -USB_DC_EP_TIMEOUT_ERR;
        }
    }
    recv_len = USB_Get_EPx_RX_FIFO_CNT(ep_idx);
    
    /*if rx fifo count equal 0,it means last is send nack and ringbuffer is smaller than 64,
    * so,if ringbuffer is larger than 64,set ack to recv next data.
    */
    if(overflow_flag[ep_idx] && (Ring_Buffer_Get_Empty_Length(rb)>64) && (!recv_len))
    {
        overflow_flag[ep_idx] = false;
        USB_Set_EPx_Rdy(ep_idx);
        return 0;
    }
    else
    {
        uint32_t addr = USB_BASE + 0x11C + (ep_idx - 1) * 0x10;
        Ring_Buffer_Write_Callback(rb, recv_len, fifocopy_to_mem, (void *)addr);

        if(Ring_Buffer_Get_Empty_Length(rb) < 64)
        {
            overflow_flag[ep_idx] = true;
            return -USB_DC_RB_SIZE_SMALL_ERR;
        }
        USB_Set_EPx_Rdy(ep_idx);
        return 0;
    }
}


// USB -> UART out
void usbd_cdc_acm_bulk_out(uint8_t ep)
{
    usb_dc_ftdi_receive_to_ringbuffer(usb_fs, &usb_rx_rb, ep);
}
//UART -> USB in
void usbd_cdc_acm_bulk_in(uint8_t ep)
{
    usb_dc_ftdi_send_from_ringbuffer(usb_fs, &uart1_rx_rb, ep);
}


/************************  endpoint definition  ************************/
//For UART
usbd_endpoint_t cdc_out_ep1 = 
{
    .ep_addr = CDC_OUT_EP,
    .ep_cb = usbd_cdc_acm_bulk_out
};

usbd_endpoint_t cdc_in_ep1 = 
{
    .ep_addr = CDC_IN_EP,
    .ep_cb = usbd_cdc_acm_bulk_in
};

//For JTAG
usbd_endpoint_t cdc_out_ep0 = 
{
    .ep_addr = JTAG_OUT_EP,
    .ep_cb = usbd_cdc_jtag_out
};

usbd_endpoint_t cdc_in_ep0 = 
{
    .ep_addr = JTAG_IN_EP,
    .ep_cb = usbd_cdc_jtag_in
};


//for dbg chip id
int main(void)
{
    uint8_t chipid[8];
    GLB_Select_Internal_Flash();
    bflb_platform_init(0);
    MSG("[usb2uartjtag] boot\r\n");
    uart_ringbuffer_init();
    uart1_init();
    uart1_config(115200, 8, UART_PAR_NONE, UART_STOP_ONE);
    MSG("[uart1] default 115200,8N1 GPIO26/TX GPIO27/RX\r\n");
#if UART1_HAS_MODEM_CONTROL
    uart1_set_dtr_rts(UART_DTR_PIN, UART_RTS_PIN);
    uart1_dtr_init();
    uart1_rts_init();
#endif
    led_gpio_init();
	led_set(0, 1);	//led0 for RX/TX indication
#if LED_COUNT > 1
	led_set(1, 1);	//led1 for Power indication
#endif
    jtag_ringbuffer_init();
    jtag_gpio_init();
    MSG("[usb2uartjtag] uart+jtag initialized\r\n");
    EF_Ctrl_Read_Chip_ID(chipid);
    // bflb_platform_dump(chipid,8);
    usb_descriptor_register(chipid);

    usbd_ftdi_add_interface(&cdc_class0,&cdc_data_intf0);
    usbd_interface_add_endpoint(&cdc_data_intf0,&cdc_out_ep0);
    usbd_interface_add_endpoint(&cdc_data_intf0,&cdc_in_ep0);

    usbd_ftdi_add_interface(&cdc_class1,&cdc_data_intf1);
    usbd_interface_add_endpoint(&cdc_data_intf1,&cdc_out_ep1);
    usbd_interface_add_endpoint(&cdc_data_intf1,&cdc_in_ep1);

    usb_fs = usb_dc_init();
    if (usb_fs)
    {
        device_control(usb_fs, DEVICE_CTRL_SET_INT, (void *)(USB_SOF_IT|USB_EP2_DATA_OUT_IT | USB_EP1_DATA_IN_IT|USB_EP4_DATA_OUT_IT|USB_EP3_DATA_IN_IT));
    }
    while(!usb_device_is_configured()){};
    MSG("[usb2uartjtag] usb configured\r\n");

	led_toggle(0);
    MSG("[usb2uartjtag] main loop\r\n");
    while (1)
    {
        uart_send_from_ringbuffer();
        jtag_process();
    }
	
	return 0;
}
