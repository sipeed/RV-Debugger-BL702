/**
 * @file uart_interface.c
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

#include "hal_gpio.h"
#include "uart_interface.h"
#include "hal_usb.h"
#include "hal_dma.h"
#include "io_cfg.h"

#if !defined(BSP_USING_UART0) || !defined(BSP_USING_UART1)
#pragma GCC error "both BSP_USING_UART0 and BSP_USING_UART1 should be defined"
#endif

#define USB_OUT_RINGBUFFER_SIZE (8 * 1024)
#define UART_RX_RINGBUFFER_SIZE (8 * 1024)
#define UART_TX_DMA_SIZE (4095)

/* max 2 uarts supported */
uint8_t usb_rx_mem[USB_OUT_RINGBUFFER_SIZE * 2] __attribute__((section(".system_ram")));
uint8_t uart_rx_mem[UART_RX_RINGBUFFER_SIZE * 2] __attribute__((section(".system_ram")));

uint8_t src_buffer[UART_TX_DMA_SIZE * 2] __attribute__((section(".tcm_code")));

void uart_irq_callback(struct device *dev, void *args, uint32_t size, uint32_t state)
{
    uart_device_t *uart_device = (uart_device_t*)dev;
    Ring_Buffer_Type *uart_rx_rb = &uart_device->uart_rx_rb;

    if (state == UART_EVENT_RX_FIFO)
    {
        if (size && size < Ring_Buffer_Get_Empty_Length(uart_rx_rb))
        {
            Ring_Buffer_Write(uart_rx_rb, (uint8_t *)args, size);
        }
        else
        {
            MSG("RF\r\n");
        }
    }
    else if (state == UART_EVENT_RTO)
    {
        if (size && size < Ring_Buffer_Get_Empty_Length(uart_rx_rb))
        {
            Ring_Buffer_Write(uart_rx_rb, (uint8_t *)args, size);
        }
        else
        {
            MSG("RTO\r\n");
        }
    }
    else if (state == UART_RX_FER_IT)
    {
        MSG("ov\r\n");
    }
}

struct device *uart_init(enum uart_index_type uart_index)
{
    const char *name;
    struct device *uart;
    struct device *tx_dma;

    switch (uart_index)
    {
    case UART0_INDEX: name = "uart0"; break;
    case UART1_INDEX: name = "uart1"; break;
    default: return NULL;
    }
    uart_register(uart_index, name, DEVICE_OFLAG_RDWR);
    uart = device_find(name);
    if (!uart)
        return NULL;

    device_open(uart, DEVICE_OFLAG_DMA_TX | DEVICE_OFLAG_INT_RX); //uart0 tx dma mode
    device_control(uart, DEVICE_CTRL_SUSPEND, NULL);
    device_set_callback(uart, uart_irq_callback);
    device_control(uart, DEVICE_CTRL_SET_INT, (void *)(UART_RX_FIFO_IT | UART_RTO_IT));

    if (uart_index == UART1_INDEX)
    {
        dma_register(DMA0_CH2_INDEX, "ch2", DEVICE_OFLAG_RDWR);
        tx_dma = device_find("ch2");
    }
    else
    {
        /* FIXME: not assigned in peripheral_config.h */
        dma_register(DMA0_CH1_INDEX, "ch1", DEVICE_OFLAG_RDWR);
        tx_dma = device_find("ch1");
    }
    if (tx_dma)
    {
        device_open(tx_dma, 0);
        //device_set_callback(tx_dma, NULL);
        //device_control(tx_dma, DEVICE_CTRL_SET_INT, NULL);
    }
    device_control(uart, DEVICE_CTRL_ATTACH_TX_DMA, tx_dma);

    if (uart_index == UART1_INDEX)
    {
        uart1_set_dtr_rts(UART_DTR_PIN,UART_RTS_PIN);
        uart1_dtr_init();
        uart1_rts_init();
    }
    return uart;
}

void uart_config(struct device *uart, uint32_t baudrate, uint8_t databits,
    uart_parity_t parity, uart_stopbits_t stopbits)
{
    uart_param_cfg_t cfg;
    cfg.baudrate = baudrate;
    cfg.stopbits = stopbits;
    cfg.parity = parity;

    switch (databits)
    {
    case 5: cfg.databits = UART_DATA_LEN_5; break;
    case 6: cfg.databits = UART_DATA_LEN_6; break;
    case 7: cfg.databits = UART_DATA_LEN_7; break;
    case 8: cfg.databits = UART_DATA_LEN_8; break;
    default: cfg.databits = UART_DATA_LEN_IGNORE;
    }

    device_control(uart, DEVICE_CTRL_CONFIG, &cfg);
}

static uint8_t uart1_dtr;
static uint8_t uart1_rts;

void uart1_set_dtr_rts(uint8_t dtr, uint8_t rts)
{
    uart1_dtr = dtr;
    uart1_rts = rts;
}

void uart1_dtr_init(void)
{
    gpio_set_mode(uart1_dtr, GPIO_OUTPUT_MODE);
}
void uart1_rts_init(void)
{
    gpio_set_mode(uart1_rts, GPIO_OUTPUT_MODE);
}
void uart1_dtr_deinit(void)
{
    gpio_set_mode(uart1_dtr, GPIO_INPUT_MODE);
}
void uart1_rts_deinit(void)
{
    gpio_set_mode(uart1_rts, GPIO_INPUT_MODE);
}
void dtr_pin_set(uint8_t status)
{
    gpio_write(uart1_dtr, status);
}
void rts_pin_set(uint8_t status)
{
    gpio_write(uart1_rts, status);
}
void ringbuffer_lock()
{
    disable_irq();
}
void ringbuffer_unlock()
{
    enable_irq();
}

void uart_ringbuffer_init(enum uart_index_type uart_index)
{
    /* uart not registered yet, use raw copy */
    uart_device_t *uart_device = uart_get_device(uart_index);

    Ring_Buffer_Type *usb_rx_rb = &uart_device->usb_rx_rb;
    Ring_Buffer_Type *uart_rx_rb = &uart_device->uart_rx_rb;

    uint8_t *usb_mem = usb_rx_mem + (uart_index * USB_OUT_RINGBUFFER_SIZE);
    uint8_t *uart_mem = uart_rx_mem + (uart_index * UART_RX_RINGBUFFER_SIZE);

    /* init mem for ring_buffer */
    memset(usb_mem, 0, USB_OUT_RINGBUFFER_SIZE);
    memset(uart_mem, 0, UART_RX_RINGBUFFER_SIZE);

    /* init ring_buffer, lock is unrelated to uart_index currently */
    Ring_Buffer_Init(usb_rx_rb, usb_mem, USB_OUT_RINGBUFFER_SIZE, ringbuffer_lock, ringbuffer_unlock);
    Ring_Buffer_Init(uart_rx_rb, uart_mem, UART_RX_RINGBUFFER_SIZE, ringbuffer_lock, ringbuffer_unlock);
}

static dma_control_data_t uart_dma_ctrl_cfg =
{
    .bits.fix_cnt = 0,
    .bits.dst_min_mode = 0,
    .bits.dst_add_mode = 0,
    .bits.SI = 1,
    .bits.DI = 0,
    .bits.SWidth = DMA_TRANSFER_WIDTH_8BIT,
    .bits.DWidth = DMA_TRANSFER_WIDTH_8BIT,
    .bits.SBSize = 0,
    .bits.DBSize = 0,
    .bits.I = 0,
    .bits.TransferSize = 4095
};
static dma_lli_ctrl_t uart_lli_list[2] = 
{
    {
    .src_addr = (uint32_t)src_buffer,
    .dst_addr = DMA_ADDR_UART0_TDR,
    .nextlli = 0
    },
    {
    .src_addr = (uint32_t)(src_buffer + UART_TX_DMA_SIZE),
    .dst_addr = DMA_ADDR_UART1_TDR,
    .nextlli = 0
    }
};

extern void led_toggle(uint8_t idx);
void uart_send_from_ringbuffer(enum uart_index_type uart_index)
{
    uart_device_t *uart_device = uart_get_device(uart_index);
    Ring_Buffer_Type *usb_rx_rb = &uart_device->usb_rx_rb;

    if(Ring_Buffer_Get_Length(usb_rx_rb))
    {
        struct device *tx_dma = uart_device->tx_dma;
        if (!device_control(tx_dma, DMA_CHANNEL_GET_STATUS, NULL))
        {
            dma_lli_ctrl_t *lli_list = &uart_lli_list[uart_index];
            uint8_t *buffer = (uint8_t*)lli_list->src_addr;
            uint32_t avalibleCnt = Ring_Buffer_Read(usb_rx_rb, buffer, UART_TX_DMA_SIZE);
            
            if (avalibleCnt)
            {
                dma_channel_stop(tx_dma);
                uart_dma_ctrl_cfg.bits.TransferSize = avalibleCnt;
                memcpy(&lli_list->cfg, &uart_dma_ctrl_cfg, sizeof(dma_control_data_t));
                device_control(tx_dma,DMA_CHANNEL_UPDATE,(void*)((uint32_t)lli_list));
                dma_channel_start(tx_dma);
				led_toggle(0);	//TX indication
            }
        }
    }
}

