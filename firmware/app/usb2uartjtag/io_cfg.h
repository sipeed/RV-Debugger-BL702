/**
 * @file usbd_ftdi.h
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
#ifndef _IO_CFG_H
#define _IO_CFG_H
 
#define UART_TXD_PIN	GPIO_PIN_26
#define UART_RXD_PIN	GPIO_PIN_27
#define UART_DTR_PIN	GPIO_PIN_28
#define UART_RTS_PIN	GPIO_PIN_24
#define UART_CTS_PIN	GPIO_PIN_25

#define LED0_PIN		GPIO_PIN_9
#define LED1_PIN		GPIO_PIN_17

#define TMS_PIN			GPIO_PIN_2
#define TCK_PIN			GPIO_PIN_15
#define TDI_PIN			GPIO_PIN_0
#define TDO_PIN			GPIO_PIN_1

//UART0 for debug
#define UART0_TXD_PIN	GPIO_PIN_14
#define UART0_RXD_PIN	GPIO_PIN_23


#endif

