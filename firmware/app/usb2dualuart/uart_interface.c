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

#include "uart_interface.h"

#include "bflb_platform.h"
#include "hal_dma.h"
#include "hal_gpio.h"
#include "hal_usb.h"

#define UART_TX_DMA_SIZE (4095)
static uint8_t src_buffer[2][UART_TX_DMA_SIZE]
    __attribute__((section(".system_ram")));

static struct device *uart[2] = {NULL, NULL};
static struct device *dma_ch[2] = {NULL, NULL};

void uart_init(uint8_t index, void (*callback)(struct device *dev, void *args,
                                               uint32_t size, uint32_t event)) {
  if (index == 0) {
    uart_register(UART0_INDEX, "uart0");
    dma_register(DMA0_CH1_INDEX, "ch1");
    uart[0] = device_find("uart0");
    dma_ch[0] = device_find("ch1");

  } else if (index == 1) {
    uart_register(UART1_INDEX, "uart1");
    dma_register(DMA0_CH2_INDEX, "ch2");
    uart[1] = device_find("uart1");
    dma_ch[1] = device_find("ch2");
  }

  if (uart[index] && dma_ch[index]) {
    device_open(uart[index],
                DEVICE_OFLAG_DMA_TX | DEVICE_OFLAG_INT_RX);  // uart tx dma mode
    // device_control(uart[index], DEVICE_CTRL_SUSPEND, NULL);
    device_set_callback(uart[index], callback);
    device_control(uart[index], DEVICE_CTRL_SET_INT,
                   (void *)(UART_RX_FIFO_IT | UART_RTO_IT));

    device_open(dma_ch[index], 0);
    device_control(uart[index], DEVICE_CTRL_ATTACH_TX_DMA, dma_ch[index]);
  }
}

void uart_config(uint8_t index, uint32_t baudrate, uart_databits_t databits,
                 uart_parity_t parity, uart_stopbits_t stopbits) {
  uart_param_cfg_t cfg;
  cfg.baudrate = baudrate;
  cfg.stopbits = stopbits;
  cfg.parity = parity;
  cfg.databits = (databits - 5);
  if (uart[index]) {
    device_control(uart[index], DEVICE_CTRL_CONFIG, &cfg);
    device_control(uart[index], DEVICE_CTRL_RESUME, NULL);
  }
}

static uint8_t uart_dtr[2];
static uint8_t uart_rts[2];

void uart_set_dtr_rts(uint8_t index, uint8_t dtr, uint8_t rts) {
  uart_dtr[index] = dtr;
  uart_rts[index] = rts;
}
void uart_dtr_init(uint8_t index) {
  gpio_set_mode(uart_dtr[index], GPIO_OUTPUT_MODE);
}
void uart_rts_init(uint8_t index) {
  gpio_set_mode(uart_rts[index], GPIO_OUTPUT_MODE);
}
void uart_dtr_deinit(uint8_t index) {
  gpio_set_mode(uart_dtr[index], GPIO_INPUT_MODE);
}
void uart_rts_deinit(uint8_t index) {
  gpio_set_mode(uart_rts[index], GPIO_INPUT_MODE);
}
void dtr_pin_set(uint8_t index, uint8_t status) {
  gpio_write(uart_dtr[index], status);
}
void rts_pin_set(uint8_t index, uint8_t status) {
  gpio_write(uart_rts[index], status);
}

static dma_control_data_t uart_dma_ctrl_cfg = {
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
    .bits.TransferSize = UART_TX_DMA_SIZE};
static dma_lli_ctrl_t uart_lli_list[2] = {{.src_addr = (uint32_t)src_buffer[0],
                                           .dst_addr = DMA_ADDR_UART0_TDR,
                                           .nextlli = 0},
                                          {.src_addr = (uint32_t)src_buffer[1],
                                           .dst_addr = DMA_ADDR_UART1_TDR,
                                           .nextlli = 0}};

void uart_send_from_ringbuffer(uint8_t index, Ring_Buffer_Type *rb) {
  if (Ring_Buffer_Get_Length(rb)) {
    if (!dma_channel_check_busy(dma_ch[index])) {
      uint32_t avalibleCnt =
          Ring_Buffer_Read(rb, src_buffer[index], UART_TX_DMA_SIZE);
      if (avalibleCnt) {
        uart_dma_ctrl_cfg.bits.TransferSize = avalibleCnt;
        memcpy(&uart_lli_list[index].cfg, &uart_dma_ctrl_cfg,
               sizeof(dma_control_data_t));
        dma_channel_stop(dma_ch[index]);
        dma_channel_update(dma_ch[index], (void *)(&uart_lli_list[index]));
        dma_channel_start(dma_ch[index]);
        // TX indication
      }
    }
  }
}
