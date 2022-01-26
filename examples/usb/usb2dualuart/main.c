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
#include "uart_interface.h"
#include "bl702_ef_ctrl.h"
#include "bl702_usb.h"
#include "bl702_glb.h"
#include "hal_gpio.h"
#include "io_cfg.h"

#if !defined(BSP_USING_UART0) || !defined(BSP_USING_UART1)
#pragma GCC error "both BSP_USING_UART0 and BSP_USING_UART1 should be defined"
#endif

/*
UART0/1:
	RXD	-> ringbuffer -> usbd_cdc_acm_bulk_in -> CDC_IN_EP
UART <---------------------------------------------------> USB
	TXD <- ringbuffer <- usbd_cdc_acm_bulk_out<- CDC_OUT_EP
*/
extern struct device* usb_dc_init(void);

usbd_class_t cdc_class0;
usbd_interface_t cdc_data_intf0;
usbd_class_t cdc_class1;
usbd_interface_t cdc_data_intf1;
extern uint8_t cdc_descriptor[];
struct device *usb_fs;


/************************  led ctrl functions  ************************/
static uint32_t led_pins[2] = {LED0_PIN, LED1_PIN};
static volatile uint8_t led_stat[2] = {0, 0};
static void led_gpio_init(void)
{
    gpio_set_mode(led_pins[0], GPIO_OUTPUT_MODE);
    gpio_set_mode(led_pins[1], GPIO_OUTPUT_MODE);
	return;
}

void led_set(uint8_t idx, uint8_t status)
{
    gpio_write(led_pins[idx], !status);
	led_stat[idx] = status;
	return;
}

void led_toggle(uint8_t idx)
{
	led_stat[idx] = !led_stat[idx];
    gpio_write(led_pins[idx], !led_stat[idx]);
	return;
}

/************************  API for usbd_ftdi  ************************/
void usbd_ftdi_set_baudrate(uint8_t setup_index, uint32_t baudrate)
{
    enum uart_index_type index = (setup_index == 2)? UART1_INDEX : UART0_INDEX;
    struct device *uart = (struct device *)uart_get_device(index);
    /* ignore the following parameters */
    uint8_t databits = 0;
    uart_parity_t parity = UART_PAR_IGNORE;
    uart_stopbits_t stopbits = UART_STOP_IGNORE;

    uart_config(uart, baudrate, databits, parity, stopbits);
}

void usbd_ftdi_set_data_framing(uint8_t setup_index, uint8_t databits, uint8_t parity, uint8_t stopbits)
{
    enum uart_index_type index = (setup_index == 2)? UART1_INDEX : UART0_INDEX;
    struct device *uart = (struct device *)uart_get_device(index);
    /* ignore baudrate */
    uint32_t baudrate = 0;

    uart_config(uart, baudrate, databits, parity, stopbits);
}

void usbd_ftdi_set_dtr(bool dtr)
{
    dtr_pin_set(!dtr);
}

void usbd_ftdi_set_rts(bool rts)
{
    rts_pin_set(!rts);
}


/************************  USB UART logic for latency timer  ************************/
static volatile uint32_t temp_tick2 = 0;	//tick for uart1 port
static volatile uint32_t temp_tick1 = 0;	//tick for uart0 port
uint64_t last_send = 0;

extern  uint32_t mpsse_status;
// UART RX -> USB IN
uint16_t usb_dc_ftdi_send_from_ringbuffer(struct device *dev, Ring_Buffer_Type *rb, uint8_t ep)
{
    uint8_t ep_idx;
    uint32_t timeout = 0x00FFFFFF;

    ep_idx = USB_EP_GET_IDX(ep);
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
        uint8_t ftdi_header[2] = {0x01,0x60};
		MSG("*");
        memcopy_to_fifo((void *)addr,ftdi_header,2);
        Ring_Buffer_Read_Callback(rb, USB_FS_MAX_PACKET_SIZE-2, memcopy_to_fifo, (void *)addr);
        USB_Set_EPx_Rdy(ep_idx);
		led_toggle(0);	//RX indication
		last_send = mtimer_get_time_us();
        return 0;
    }
    else
    {
		/*uint64_t Latency_Timer = (ep_idx - 1)==0?usbd_ftdi_get_latency_timer1():usbd_ftdi_get_latency_timer2();	//超时才发
		if(mtimer_get_time_us()-last_send>Latency_Timer*1000) {
			uint8_t ftdi_header[2] = {0x01,0x60};       
			memcopy_to_fifo((void *)addr,ftdi_header,2);
			USB_Set_EPx_Rdy(ep_idx);
			last_send = mtimer_get_time_us();
			//MSG("Port%d refresh\r\n", ep_idx);
			return -USB_DC_RB_SIZE_SMALL_ERR;
		}*/
		
        if(ep_idx == CDC_IN_EP) //UART1
        {
            if((uint32_t)(usbd_ftdi_get_sof_tick()-temp_tick2) >= usbd_ftdi_get_latency_timer2())
            {
                uint8_t ftdi_header[2] = {0x01,0x60};
                temp_tick2 = usbd_ftdi_get_sof_tick();
                memcopy_to_fifo((void *)addr,ftdi_header,2);
                USB_Set_EPx_Rdy(ep_idx);
            }
        }
        else	//0x81, UART0
        {
            if((uint32_t)(usbd_ftdi_get_sof_tick()-temp_tick1) >= usbd_ftdi_get_latency_timer1())
            {
                uint8_t ftdi_header[2] = {0x01,0x60};
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
    static bool overflow_flag = false;

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
    if(overflow_flag && (Ring_Buffer_Get_Empty_Length(rb)>64) && (!recv_len))
    {
        overflow_flag = false;
        USB_Set_EPx_Rdy(ep_idx);
        return 0;
    }
    else
    {
        uint32_t addr = USB_BASE + 0x11C + (ep_idx - 1) * 0x10;
        Ring_Buffer_Write_Callback(rb, recv_len, fifocopy_to_mem, (void *)addr);

        if(Ring_Buffer_Get_Empty_Length(rb) < 64)
        {
            overflow_flag = true;
            return -USB_DC_RB_SIZE_SMALL_ERR;
        }
        USB_Set_EPx_Rdy(ep_idx);
        return 0;
    }
}


// USB -> UART out
void usbd_cdc_acm_bulk_out(uint8_t ep)
{
    enum uart_index_type index = (ep == CDC_IN_EP)? UART1_INDEX : UART0_INDEX;
    uart_device_t *uart_device = uart_get_device(index);
    Ring_Buffer_Type *usb_rx_rb = &uart_device->usb_rx_rb;

    usb_dc_ftdi_receive_to_ringbuffer(usb_fs, usb_rx_rb, ep);
}
//UART -> USB in
void usbd_cdc_acm_bulk_in(uint8_t ep)
{
    enum uart_index_type index = (ep == CDC_IN_EP)? UART1_INDEX : UART0_INDEX;
    uart_device_t *uart_device = uart_get_device(index);
    Ring_Buffer_Type *uart_rx_rb = &uart_device->uart_rx_rb;

    usb_dc_ftdi_send_from_ringbuffer(usb_fs, uart_rx_rb, ep);
}


/************************  endpoint definition  ************************/
//For UART1
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

//For UART0
usbd_endpoint_t cdc_out_ep0 = 
{
    .ep_addr = JTAG_OUT_EP,
    .ep_cb = usbd_cdc_acm_bulk_out
};

usbd_endpoint_t cdc_in_ep0 = 
{
    .ep_addr = JTAG_IN_EP,
    .ep_cb = usbd_cdc_acm_bulk_in
};


//for dbg chip id
static void hexarr2string(uint8_t *hexarray,int length,uint8_t *string)
{
	unsigned char num2string_table[] = "0123456789ABCDEF";
    int i = 0;
	while(i < length)
	{
	    *(string++) = num2string_table[((hexarray[i] >> 4) & 0x0f)];
		*(string++) = num2string_table[(hexarray[i] & 0x0f)];
		i++;
	}
	return;
}

int main(void)
{
    uint8_t *serial;
    uint8_t chipid[8];
    uint8_t chipid2[6];
    GLB_Select_Internal_Flash();
    /* UART0 also attached as usb cdc, no more console port... */
    bflb_platform_print_set(1);
    bflb_platform_init(0);
    uart_ringbuffer_init(UART1_INDEX);
    uart_init(UART1_INDEX);
    uart_ringbuffer_init(UART0_INDEX);
    uart_init(UART0_INDEX);
    led_gpio_init();
	led_set(0, 1);	//led0 for RX/TX indication
	led_set(1, 1);	//led1 for Power indication
    EF_Ctrl_Read_Chip_ID(chipid);
    // hexarr2string(&chipid[2],3,chipid2);
    // bflb_platform_dump(chipid,8);
    // bflb_platform_dump(chipid2,6);
    serial = &cdc_descriptor[0x12+0x37+0x04+ 0x0e + 0x1c+0x24];
    serial[0] = 0x30; //chipid2[0];
    serial[2] = 0x31; //chipid2[1];
    serial[4] = 0x32; //chipid2[2];
    serial[6] = 0x33; //chipid2[3];
    serial[8] = 0x34; //chipid2[4];
    serial[10] = 0x35; //chipid2[5];
    usbd_desc_register(cdc_descriptor);

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
    
	led_toggle(0);
    while (1)
    {
        uart_send_from_ringbuffer(UART1_INDEX);
        uart_send_from_ringbuffer(UART0_INDEX);
    }
	
	return 0;
}
