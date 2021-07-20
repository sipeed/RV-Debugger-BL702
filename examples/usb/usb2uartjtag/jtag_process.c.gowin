/**
 * @file uart_interface.h
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
#include "ring_buffer.h"
#include "hal_gpio.h"
#include "hal_spi.h"
#include "hal_pwm.h"
#include "bl702_glb.h"
#include "bl702_gpio.h"
#include "bl702_pwm.h"
#include "io_cfg.h"
#define GOWIN_INT_FLASH_QUIRK 1
#define GW_DBG	1
#define MPSSE_SPI_HW 0

#define PWM_CH	0	//TCK pin num %5

#define TMS_HIGH    ((*(volatile uint32_t *)0x40000188) |= (1<<TMS_PIN))
#define TMS_LOW     ((*(volatile uint32_t *)0x40000188) &= (~(1<<TMS_PIN)))
#define TDI_HIGH    ((*(volatile uint32_t *)0x40000188) |= (1<<TDI_PIN))
#define TDI_LOW     ((*(volatile uint32_t *)0x40000188) &= (~(1<<TDI_PIN)))
#define TCK_HIGH    ((*(volatile uint32_t *)0x40000188) |= (1<<TCK_PIN))
#define TCK_LOW     ((*(volatile uint32_t *)0x40000188) &= (~(1<<TCK_PIN)))
#define TDO         ((*(volatile uint32_t *)0x40000180) & (1<<TDO_PIN))

#define SCK_HIGH    TCK_HIGH
#define SCK_LOW     TCK_LOW
#define MOSI_HIGH   TDI_HIGH
#define MOSI_LOW    TDI_LOW
#define MISO        TDO

#define MPSSE_IDLE          0
#define MPSSE_RCV_LENGTH_L  1
#define MPSSE_RCV_LENGTH_H  2
#define MPSSE_TRANSMIT_BYTE 3
#define MPSSE_RCV_LENGTH    4
#define MPSSE_TRANSMIT_BIT  5
#define MPSSE_ERROR         6
#define MPSSE_TRANSMIT_BIT_MSB 7
#define MPSSE_TMS_OUT       8
#define MPSSE_NO_OP_1       9
#define MPSSE_NO_OP_2       10
#define MPSSE_TRANSMIT_BYTE_MSB 11
#define MPSSE_RUN_TEST  12

#define JTAG_TX_BUFFER_SIZE (1 * 1024)
#define JTAG_RX_BUFFER_SIZE (4096)  //64  //1801

//6.94ns every "nop"  
#define DELAY() \
{\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
}

#define DELAY_LOW() \
{\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
}

#define DELAY_HIGH() \
{\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");\
}


/*
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\
	__asm volatile ("nop":::"memory");__asm volatile ("nop":::"memory");\

*/


uint8_t jtag_tx_buffer[JTAG_TX_BUFFER_SIZE] __attribute__((section(".tcm_data")));
Ring_Buffer_Type jtag_tx_rb;

uint8_t jtag_rx_buffer[JTAG_RX_BUFFER_SIZE] __attribute__((section(".tcm_data")));
static volatile uint32_t jtag_rx_len = 0;
static volatile uint32_t jtag_rx_pos __attribute__((section(".tcm_data")));

static uint32_t mpsse_longlen __attribute__((section(".tcm_data"))) = 0;
static uint32_t mpsse_shortlen __attribute__((section(".tcm_data"))) = 0;
static uint32_t mpsse_status __attribute__((section(".tcm_data"))) = MPSSE_IDLE;
static uint32_t jtag_cmd __attribute__((section(".tcm_data"))) = 0;

static volatile uint32_t jtag_received_flag __attribute__((section(".tcm_data"))) = false;


static uint32_t usb_tx_data = 0;
static uint32_t tmp = 0;


extern struct device *usb_fs;

static void rb_lock(void)
{
    //disable_irq();
}

static void rb_unlock(void)
{
    //enable_irq();
}

static void jtag_write(uint8_t data)
{
    Ring_Buffer_Write_Byte(&jtag_tx_rb, data);
}

void jtag_ringbuffer_init(void)
{
    memset(jtag_tx_buffer, 0, JTAG_TX_BUFFER_SIZE);
    /* init ring_buffer */
    Ring_Buffer_Init(&jtag_tx_rb, jtag_tx_buffer, JTAG_TX_BUFFER_SIZE, rb_lock, rb_unlock);
}
#if GOWIN_INT_FLASH_QUIRK 
static void pwm_start(void)
{
    GLB_GPIO_Cfg_Type gpio_cfg;

    gpio_cfg.drive = 0;
    gpio_cfg.smtCtrl = 1;
    gpio_cfg.gpioMode = GPIO_MODE_AF;
    gpio_cfg.pullType = GPIO_PULL_DOWN;
    gpio_cfg.gpioFun = GPIO_FUN_PWM;
    gpio_cfg.gpioPin = TCK_PIN;
    GLB_GPIO_Init(&gpio_cfg);
    PWM_Channel_Enable(PWM_CH);

}
static void pwm_stop(void)
{

    PWM_Channel_Disable(PWM_CH);

    GLB_GPIO_Cfg_Type gpio_cfg;
    gpio_cfg.drive = 0;
    gpio_cfg.smtCtrl = 1;
    gpio_cfg.gpioMode = GPIO_MODE_OUTPUT;
    gpio_cfg.pullType = GPIO_PULL_NONE;
    gpio_cfg.gpioFun = GPIO_FUN_GPIO;
    gpio_cfg.gpioPin = TCK_PIN;
    GLB_GPIO_Init(&gpio_cfg);
}

void pwm_init(void)
{
    static PWM_CH_CFG_Type pwmCfg =
    {
        .ch = PWM_CH,
        .clk = PWM_CLK_BCLK,
        .stopMode = PWM_STOP_GRACEFUL,
        .pol = PWM_POL_NORMAL,
        .clkDiv = 1,
        .period = 29,
        .threshold1 = 0,
        .threshold2 = 14,
        .intPulseCnt = 0,
    };
    PWM_Channel_Init(&pwmCfg);
}
#endif
void jtag_gpio_init(void)
{
    gpio_set_mode(TMS_PIN, GPIO_OUTPUT_MODE);
    gpio_set_mode(TDI_PIN, GPIO_OUTPUT_MODE);
    gpio_set_mode(TCK_PIN, GPIO_OUTPUT_MODE);
    gpio_set_mode(TDO_PIN, GPIO_INPUT_MODE);

    TMS_LOW;
    TDI_LOW;
    TCK_LOW;
#if GOWIN_INT_FLASH_QUIRK 
    pwm_init();
	//pwm_start();
#endif
}

#if MPSSE_SPI_HW
static struct device* jtag_spi;

#define SPI_BASE_ADDR ((uint32_t)0x4000A200)
#define SPI_MSB_FIRST()   ((*(volatile uint32_t *)SPI_BASE_ADDR) &= (~(1<<6)))
#define SPI_LSB_FIRST()   ((*(volatile uint32_t *)SPI_BASE_ADDR) |= (1<<6))

static inline void spi_on(void)
{
    /**gpio spi func*/
    uint32_t temp_val = BL_RD_WORD(0x40000100);
    temp_val = (temp_val & (~(31<<8)))|(4<<8);
    BL_WR_WORD(0x40000100,temp_val);
    /**spi enable*/
    (*(volatile uint32_t *)SPI_BASE_ADDR) |= (1<<0);
}
static inline void spi_on(void)
{
    /**gpio spi func*/
    uint32_t temp_val = BL_RD_WORD(0x40000100+TCK_PIN/2*4);
    temp_val = (temp_val & (~(31<<8)))|(4<<8);
    BL_WR_WORD(0x40000100,temp_val);
    uint32_t temp_val = BL_RD_WORD(0x40000100+TDO_PIN/2*4);
    temp_val = (temp_val & (~(31<<8)))|(4<<8);
    BL_WR_WORD(0x40000100,temp_val);
    uint32_t temp_val = BL_RD_WORD(0x40000100+TDI_PIN/2*4);
    temp_val = (temp_val & (~(31<<8)))|(4<<8);
    BL_WR_WORD(0x40000100,temp_val);
    /**spi enable*/
    (*(volatile uint32_t *)SPI_BASE_ADDR) |= (1<<0);
}
static inline void spi_off(void)
{
    /**spi disable*/
    (*(volatile uint32_t *)SPI_BASE_ADDR) &= (~(1<<0));    
    /**gpio func*/
    uint32_t temp_val = BL_RD_WORD(0x40000100+TCK_PIN/2*4);
    temp_val = (temp_val & (~(31<<8)))|(11<<8);
    BL_WR_WORD(0x40000100,temp_val);
    uint32_t temp_val = BL_RD_WORD(0x40000100+TDO_PIN/2*4);
    temp_val = (temp_val & (~(31<<8)))|(11<<8);
    BL_WR_WORD(0x40000100,temp_val);
    uint32_t temp_val = BL_RD_WORD(0x40000100+TDI_PIN/2*4);
    temp_val = (temp_val & (~(31<<8)))|(11<<8);
    BL_WR_WORD(0x40000100,temp_val);

}
void jtag_spi_init(void)
{
    spi_register(SPI0_INDEX,"jtag_spi",DEVICE_OFLAG_RDWR);
    jtag_spi = device_find("jtag_spi");
    if(jtag_spi)
    {
        device_open(jtag_spi,DEVICE_OFLAG_STREAM_TX|DEVICE_OFLAG_STREAM_RX);
    }
    /*rx ignore disable*/
    (*(volatile uint32_t *)0x4000A200) &= (~(1<<8));
}

#endif

volatile uint64_t last_rcv = 0;
uint8_t tmpbuf[64];
volatile int doing_flag = 0; 
volatile int ef_flag = 0; 
volatile int ef_cnt = 0; 


#if GW_DBG
//编程包头特点 
// 4b 03 03 1b 06 15 6b 00 01 4b 01 01 4b 05 00 4b 03 03 1b 06 71 6b 00 01
// 4b 03 03 1b 06 15 6b 00 01 4b 01 01 4b 05 00 4b 03 03 1b 06 71 6b 00 01  4b 01 01 4b  05 00 4b 02
// len>=21, idx=18: 1b 06 71
void usbd_cdc_jtag_out(uint8_t ep)
{//
    uint32_t chunk;
    //if (!jtag_received_flag)
	if(!doing_flag)
    {
        usbd_ep_read(ep, jtag_rx_buffer+jtag_rx_len, 64, &chunk);

        if (chunk == 0)
        {
            //MSG("111\r\n");
            return;
        }
		//if(jtag_rx_len == 0) MSG("\r\n");
        //查找ef program标志 1b 06 71 6b 00 01
        uint8_t* p0 = jtag_rx_buffer+jtag_rx_len;
        uint8_t* p = jtag_rx_buffer+jtag_rx_len+18;
        uint8_t* p1 = jtag_rx_buffer+jtag_rx_len+chunk-5;
        if(!ef_flag && chunk>=21 && p[0]==0x1b && p[1]==0x06 && p[2]==0x71){
            ef_flag = 1;
            MSG("$");
        }
        if(ef_flag == 1) {  
            if( (p1[0]==0x19 && p1[1]==0x01)){
                ef_flag = 0;    //结尾是 19 01 00 00 00 (只适用于新工艺的1NZ和4K系列) 
            }/* else if ((p0[4]==0x19 && p0[5]==0xee && p0[6]==0x02)){
                //01 4b 03 01  19 ee 02 00  //1N FPGA
                ef_flag = 2;
                ef_cnt = 0x2ee - 6-1;
            } else if ((p0[26]==0x19 && p0[27]==0xee && p0[28]==0x02)) {
                //1N FPGA
                //06 00 4b 00  01 4b 03 01  4b 02 01 19  02 00 00 00  00 1b 06 00  4b 00 01 4b  03 01 19 ee  02 00 00 00
                ef_flag = 2;
                ef_cnt = 0x2ee - 28-1;
            }*/
        } /*else if(ef_flag == 2) {
            ef_cnt -= chunk;
            if(ef_cnt<=0) {
                ef_flag = 0;
            }
        }*/
            
        //MSG("@%d@",chunk);
        
        jtag_rx_len += chunk;

        // bflb_platform_dump(jtag_rx_buffer, jtag_rx_len);
        jtag_rx_pos = 0;
        jtag_received_flag = true;
		last_rcv = mtimer_get_time_us();
		//MSG("%d", mtimer_get_time_us()%10000); //, 
		usbd_ep_read(JTAG_OUT_EP, NULL, 0, NULL);	//表示处理好一帧？
    }
}

#else 
void usbd_cdc_jtag_out(uint8_t ep)
{
    uint32_t chunk;
    if (!jtag_received_flag) {	//在处理完之前的包后才进行下一次接收
        usbd_ep_read(ep, jtag_rx_buffer, 64, &chunk);	
        if (chunk == 0){
            return;
        }
        jtag_rx_len = chunk;
        // bflb_platform_dump(jtag_rx_buffer, jtag_rx_len);
        jtag_rx_pos = 0;
        jtag_received_flag = true;
    }
}
#endif

extern uint16_t usb_dc_ftdi_send_from_ringbuffer(struct device *dev, Ring_Buffer_Type *rb, uint8_t ep);
static volatile uint32_t temp_tick1 = 0;
void usbd_cdc_jtag_in(uint8_t ep)
{	//MSG("#%ld#", mtimer_get_time_us()%1000);
    if (jtag_rx_len==0) //(!jtag_received_flag)) //没有需要处理的接收内容时返回数据
    {
		//temp_tick1 = usbd_get_sof_tick(); 
        usb_dc_ftdi_send_from_ringbuffer(usb_fs, &jtag_tx_rb, ep);
    }
}


ATTR_CLOCK_SECTION void jtag_process(void)
{
    uint32_t usb_tx_data = 0;
    uint32_t data = 0;
	register uint32_t tmpt = mtimer_get_time_us();
    register volatile uint32_t *pio __asm ("tp") = (volatile uint32_t *)0x40000180;
    register uint32_t bitbang = 0;

    if (!jtag_received_flag)
        return;
    
#if GW_DBG
    if(ef_flag == 0) {
        if((tmpt-last_rcv<5) || (jtag_rx_len == 0))	//200us之后再统一处理, 加速整包的处理  // 
        {	
            return;
        }
    } else {
        //if((jtag_rx_len < 1750))	//200us之后再统一处理, 加速整包的处理  //
        //if((tmpt-last_rcv<500) || (jtag_rx_len == 0))        
        //{	//MSG("#%d#", jtag_rx_len);
        //    return;
        //}
        //MSG("@%d,%d@", tmpt%10000, last_rcv%10000);
        return; //直接返回，等待接收完成
    }


	//MSG("#%d#", jtag_rx_len);
	//MSG("+%ldus, %d\r\n", mtimer_get_time_us(), jtag_rx_len);
	disable_irq();
    doing_flag = 1;
	while(jtag_rx_pos < jtag_rx_len)
#else
	disable_irq();
	while(jtag_rx_pos < jtag_rx_len)
#endif
    {
        switch (mpsse_status)
        {
            case MPSSE_IDLE:
                jtag_cmd = jtag_rx_buffer[jtag_rx_pos];
                //MSG("cmd:0x%02x\r\n",jtag_cmd);
				switch (jtag_cmd)
				{	/* Instructions*/
					case 0x80:
					case 0x82:/* set data bit as output, we just nop it */
						mpsse_status = MPSSE_NO_OP_1; //need read two byte next
						jtag_rx_pos++;
						break;
					case 0x81:
					case 0x83:/* dummy read back 8pins data, and send to usb */
						usb_tx_data = jtag_rx_buffer[jtag_rx_pos] - 0x80;
						jtag_write(usb_tx_data);
						jtag_rx_pos++;
						break;
					case 0x84:
					case 0x85:/* Loopback, nothing to do*/
						jtag_rx_pos++;
						break;
					case 0x86: /* Clock Divisor, 0xValueL, 0xValueH; CLK=30M/Val */
						//not support, we fixed 2.5MHz, 400ns period, 200ns each
						mpsse_status = MPSSE_NO_OP_1; //need read two byte next
						jtag_rx_pos++;
						break;
					case 0x87: /* send immediate*/
						//This will make the chip flush its buffer back to the PC.
						//no thing to do
						jtag_rx_pos++;
						break;
					case 0x8a:	// //Disables the clk divide by 5 to allow for a 60MHz master clock
					case 0x8b:	//Enables the clk divide by 5 to allow for backward compatibility with FT2232D
					case 0x8c:	//Enables 3 phase data clocking. Used by I2C interfaces to allow data on both clock edges.
					case 0x8d:	// //Disables 3 phase data clocking.
					case 0x8e:	//Allows for a clock to be output without transferring data. Commonly used in the JTAG state machine. Clocks counted in terms of numbers of bit
					case 0x8f:	//Allows for a clock to be output without transferring data. Commonly used in the JTAG state machine. Clocks countedin terms of numbers of bytes
					case 0x94:	//Allows for a clock to be output without transferring data until a logic 1 input on GPIOL1 stops the clock
					case 0x95:	//Allows for a clock to be output without transferring data until a logic 0 input on GPIOL1 stops the clock.
					case 0x96:	//Allows for a clock to be output without transferring data until a logic 0 input on GPIOL1 stops the clock.
					case 0x97:	// //Disable adaptive clocking
					case 0x9c:	//Allows for a clock to be output without transferring data until a logic 1 input on GPIOL1 stops the clock or a set number of clock pulses are sent. Clocks counted in terms of numbers of bytes
					case 0x9d:	//Allows for a clock to be output without transferring data until a logic 0 input on GPIOL1 stops the clock or a setnumber of clock pulses are sent. Clocks counted in terms of numbers of bytes
						jtag_rx_pos++;
						break;
						
					/* Data Shifting Command */
					case 0x19:
					case 0x1d:
					case 0x39:
					case 0x3d:
					case 0x11:
					case 0x15:
					case 0x31:
					case 0x35:
					#if MPSSE_SPI_HW
						spi_on();
					#endif
						mpsse_status = MPSSE_RCV_LENGTH_L;
						jtag_rx_pos++;
						break;
					case 0x6b:
					case 0x6f:
					case 0x4b:
					case 0x4f:
					case 0x3b:
					case 0x3f:
					case 0x1b:
					case 0x1f:
					case 0x13:
					case 0x17:
					#if MPSSE_SPI_HW
						spi_off();
					#endif
						mpsse_status = MPSSE_RCV_LENGTH;
						jtag_rx_pos++;
						break;
					default:
						usb_tx_data = 0xFA;
						jtag_write(usb_tx_data);
						mpsse_status = MPSSE_ERROR;
						break;
                }
                break;
            case MPSSE_RCV_LENGTH_L:/* 接收长度 */
                mpsse_longlen = jtag_rx_buffer[jtag_rx_pos];

                mpsse_status = MPSSE_RCV_LENGTH_H;
                jtag_rx_pos++;
                break;
            case MPSSE_RCV_LENGTH_H:
                mpsse_longlen |= (jtag_rx_buffer[jtag_rx_pos] << 8) & 0xff00;
                
                jtag_rx_pos++;
#if GOWIN_INT_FLASH_QUIRK
                if ((mpsse_longlen >=2000) && (jtag_cmd & (1 << 5)) == 0) //1N 型号：0xb98
                {
                    //SPI_OFF();
                    //Run_Test_Start();
                    pwm_start();
                    //MSG("len:%d\r\n",mpsse_longlen);
                    //MSG("run test start\r\n");
                    mpsse_status = MPSSE_RUN_TEST;
                }
                else if (jtag_cmd == 0x11 || jtag_cmd == 0x31)
#else
                if (jtag_cmd == 0x11 || jtag_cmd == 0x31)
#endif
                {
                    mpsse_status = MPSSE_TRANSMIT_BYTE_MSB;
#if MPSSE_SPI_HW
                        SPI_MSB_FIRST();
#endif
                }
                else
                {
                    mpsse_status = MPSSE_TRANSMIT_BYTE;
#if MPSSE_SPI_HW
                        SPI_LSB_FIRST();
#endif
                }
                break;
            case MPSSE_TRANSMIT_BYTE:
                //__asm volatile ("nop":::"memory");
                data = jtag_rx_buffer[jtag_rx_pos];
#if MPSSE_SPI_HW
                usb_tx_data = spi_write_read(data);
#else
                usb_tx_data = 0;
                
                bitbang = pio[2];
                for (uint32_t i = 8; i ; i--)
                {
                    //SCK_LOW;
                    bitbang &= ~((1 << TCK_PIN) | (1 << TDI_PIN));
                    pio[2] = bitbang;
					DELAY_LOW();
                    if (data & 0x01) {
                        //MOSI_HIGH;
                        bitbang |= ((1 << TCK_PIN) | (1 << TDI_PIN));
                    } else {
                        //MOSI_LOW;
                        bitbang |= (1<<TCK_PIN);
                    }
                    pio[2] = bitbang;

                    data >>= 1;
                    usb_tx_data >>= 1;
                    //SCK_HIGH;
                    //if (MISO)
					DELAY_HIGH();
                    if (pio[0] & (1 << TDO_PIN))
                        usb_tx_data |= 0x80;
                }
                //SCK_LOW;
                pio[2] &= ~(1<<TCK_PIN);
#endif
                if (jtag_cmd == 0x39)
                    jtag_write(usb_tx_data);

                if (mpsse_longlen == 0)
                    mpsse_status = MPSSE_IDLE;

                mpsse_longlen--;
                jtag_rx_pos++;
                //__asm volatile ("nop":::"memory");
                break;
            case MPSSE_TRANSMIT_BYTE_MSB:
                data = jtag_rx_buffer[jtag_rx_pos];

#if MPSSE_SPI_HW
                usb_tx_data = spi_write_read(data);
#else
                usb_tx_data = 0;   
                
                bitbang = pio[2];
                for (uint32_t i = 8; i ; i--)
                {
                    //SCK_LOW;
                    bitbang &= ~((1 << TCK_PIN) | (1 << TDI_PIN));
                    pio[2] = bitbang;
					DELAY_LOW();
                    if (data & 0x80) {
                        //MOSI_HIGH;
                        bitbang |= ((1 << TCK_PIN) | (1 << TDI_PIN));
                    } else {
                        //MOSI_LOW;
                        bitbang |= (1<<TCK_PIN);
                    }
                    pio[2] = bitbang;

                    data <<= 1;
                    usb_tx_data <<= 1;
                    //SCK_HIGH;
                    //if (MISO)
					DELAY_HIGH();
                    if (pio[0] & (1 << TDO_PIN))
                        usb_tx_data |= 0x01;
                }
                //SCK_LOW;
                pio[2] &= ~(1<<TCK_PIN);
#endif
                if (jtag_cmd == 0x31)
                    jtag_write(usb_tx_data);

                if (mpsse_longlen == 0)
                    mpsse_status = MPSSE_IDLE;

                jtag_rx_pos++;
                mpsse_longlen--;
                break;
            case MPSSE_RCV_LENGTH:
                mpsse_shortlen = jtag_rx_buffer[jtag_rx_pos];

                if (jtag_cmd == 0x6b || jtag_cmd == 0x4b)
                {
                    mpsse_status = MPSSE_TMS_OUT;
                }
                else if (jtag_cmd == 0x13)
                {
                    mpsse_status = MPSSE_TRANSMIT_BIT_MSB;
                }
                else
                    mpsse_status = MPSSE_TRANSMIT_BIT;

                jtag_rx_pos++;
                break;
            case MPSSE_TRANSMIT_BIT:
                data = jtag_rx_buffer[jtag_rx_pos];

                usb_tx_data = 0;

                bitbang = pio[2];
                do
                {
                    //SCK_LOW;
                    bitbang &= ~((1 << TCK_PIN) | (1 << TDI_PIN));
                    pio[2] = bitbang;
					DELAY_LOW();
                    if (data & 0x01) {
                        //MOSI_HIGH;
                        bitbang |= ((1 << TCK_PIN) | (1 << TDI_PIN));
                    } else {
                        //MOSI_LOW;
                        bitbang |= (1<<TCK_PIN);
                    }
                    pio[2] = bitbang;

                    data >>= 1;
                    usb_tx_data >>= 1;

                    //SCK_HIGH;
					DELAY_HIGH();
                    if (MISO)
                        usb_tx_data |= 0x80;
                }
                while ((mpsse_shortlen--) > 0);
                //SCK_LOW;
                pio[2] &= ~(1<<TCK_PIN);

                if (jtag_cmd == 0x3b)
                    jtag_write(usb_tx_data);

                mpsse_status = MPSSE_IDLE;
                jtag_rx_pos++;
                break;
            case MPSSE_TRANSMIT_BIT_MSB:
                data = jtag_rx_buffer[jtag_rx_pos];

                bitbang = pio[2];
                do
                {
                    //SCK_LOW;
                    bitbang &= ~((1 << TCK_PIN) | (1 << TDI_PIN));
                    pio[2] = bitbang;
					DELAY_LOW();
                    if (data & 0x80) {
                        //MOSI_HIGH;
                        bitbang |= ((1 << TCK_PIN) | (1 << TDI_PIN));
                    } else {
                        //MOSI_LOW;
                        bitbang |= (1<<TCK_PIN);
                    }
                    pio[2] = bitbang; 
					DELAY_HIGH();

                    data <<= 1;
                    //SCK_HIGH;
                }
                while ((mpsse_shortlen--) > 0);
                //SCK_LOW;
                pio[2] &= ~(1<<TCK_PIN);

                mpsse_status = MPSSE_IDLE;
                jtag_rx_pos++;
                break;
            case MPSSE_ERROR:
                usb_tx_data = jtag_rx_buffer[jtag_rx_pos];
                jtag_write(usb_tx_data);
                mpsse_status = MPSSE_IDLE;
                jtag_rx_pos++;

                break;
            case MPSSE_TMS_OUT:
            //__asm volatile ("nop":::"memory");
                data = jtag_rx_buffer[jtag_rx_pos];
 
                if (data & 0x80)
                    //TDI_HIGH;
                    pio[2] |= 1 << TDI_PIN;
                else
                    //TDI_LOW;
                    pio[2] &= ~(1 << TDI_PIN);

                usb_tx_data = 0;
                bitbang = pio[2];

                do
                {
                    //TCK_LOW;
                    bitbang &= ~((1 << TCK_PIN) | (1 << TMS_PIN));
                    pio[2] = bitbang;
					DELAY_LOW();
                    if (data & 0x01) {
                        //TMS_HIGH;
                        bitbang |= ((1 << TCK_PIN) | (1 << TMS_PIN));
                    } else {
                        //TMS_LOW;
                        bitbang |= (1<<TCK_PIN);
                    }
                    pio[2] = bitbang;
					
					DELAY_HIGH();

                    data >>= 1;
                    usb_tx_data >>= 1;

                    //TCK_HIGH;
                    //if (TDO)
                    if (pio[0] & (1 << TDO_PIN))
                        usb_tx_data |= 0x80;
                }
                while ((mpsse_shortlen--) > 0);
                //TCK_LOW;
                pio[2] &= ~(1<<TCK_PIN);

                if (jtag_cmd == 0x6b)
                    jtag_write(usb_tx_data);

                mpsse_status = MPSSE_IDLE;
                jtag_rx_pos++;
            //__asm volatile ("nop":::"memory");
                break;
            case MPSSE_NO_OP_1:
                jtag_rx_pos++;
                mpsse_status = MPSSE_NO_OP_2;
                break;
            case MPSSE_NO_OP_2:
                mpsse_status = MPSSE_IDLE;
                jtag_rx_pos++;
                break;
            case MPSSE_RUN_TEST:
                if (mpsse_longlen == 0)
                {
                    mpsse_status = MPSSE_IDLE;
                    //MSG("run test stop\r\n");

                    pwm_stop();
                }  
                
                jtag_rx_pos++;
                mpsse_longlen --;
				DELAY();DELAY();DELAY();DELAY();DELAY();DELAY();DELAY();DELAY();DELAY();
                break;
            default:
                mpsse_status = MPSSE_IDLE;
                break;
        }

        if (jtag_rx_pos >= jtag_rx_len)
        {
            jtag_received_flag = false;
#if !GW_DBG
            usbd_ep_read(JTAG_OUT_EP, NULL, 0, NULL);
#endif
			jtag_rx_len = 0;

        }
    }
	//MSG("-%ldus\r\n", mtimer_get_time_us());
    doing_flag = 0;
    ef_flag = 0;
    enable_irq();
    
	return;
}
	