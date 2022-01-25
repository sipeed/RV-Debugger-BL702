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

#ifndef __UART_IF_H__
#define __UART_IF_H__

#include "hal_uart.h"

struct device *uart_init(enum uart_index_type uart_index);
void uart_config(struct device *uart, uint32_t baudrate, uint8_t databits,
     uart_parity_t parity, uart_stopbits_t stopbits);
void uart1_set_dtr_rts(uint8_t dtr, uint8_t rts);
void uart1_dtr_init(void);
void uart1_rts_init(void);
void uart1_dtr_deinit(void);
void uart1_rts_deinit(void);
void dtr_pin_set(uint8_t status);
void rts_pin_set(uint8_t status);
void uart_ringbuffer_init(enum uart_index_type uart_index);
void uart_send_from_ringbuffer(enum uart_index_type uart_index);
#endif