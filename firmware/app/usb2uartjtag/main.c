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
void usbd_ftdi_set_line_coding(uint32_t baudrate, uint8_t databits, uint8_t parity, uint8_t stopbits)
{
    uart1_config(baudrate, databits, parity, stopbits);
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
static volatile uint32_t temp_tick2 = 0;	//tick for uart port
static volatile uint32_t temp_tick1 = 0;	//tick for uart port
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
		
        if(ep_idx == CDC_IN_EP) //UART
        {
            if((uint32_t)(usbd_ftdi_get_sof_tick()-temp_tick2) >= usbd_ftdi_get_latency_timer2())
            {
                uint8_t ftdi_header[2] = {0x01,0x60};     
                temp_tick2 = usbd_ftdi_get_sof_tick();                 
                memcopy_to_fifo((void *)addr,ftdi_header,2);
                USB_Set_EPx_Rdy(ep_idx);
            }
        }
        else	//0x81, JTAG
        {
            //if((uint32_t)(usbd_ftdi_get_sof_tick()-temp_tick1) >= usbd_ftdi_get_latency_timer1())
			//if(mpsse_status != 12)
			//MSG("#");
			if(mtimer_get_time_us()-last_send>1000)
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
    uint8_t chipid[8];
    uint8_t chipid2[6];
    GLB_Select_Internal_Flash();
    bflb_platform_init(0);
    uart_ringbuffer_init();
    uart1_init();
    uart1_set_dtr_rts(UART_DTR_PIN,UART_RTS_PIN);
    uart1_dtr_init();
    uart1_rts_init();
    led_gpio_init();
	led_set(0, 1);	//led0 for RX/TX indication
	led_set(1, 1);	//led1 for Power indication
    jtag_ringbuffer_init();
    jtag_gpio_init();
    EF_Ctrl_Read_Chip_ID(chipid);
    // hexarr2string(&chipid[2],3,chipid2);
    // bflb_platform_dump(chipid,8);
    // bflb_platform_dump(chipid2,6);
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24] = 	0x00; //chipid2[0];
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+2] = 	0x11; //chipid2[1];
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+4] = 	0x22; //chipid2[2];
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+6] = 	0x33; //chipid2[3];
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+8] = 	0x44; //chipid2[4];
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+10] = 	0x55; //chipid2[5];
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
        uart_send_from_ringbuffer();
        jtag_process();
    }
	
	return 0;
}
