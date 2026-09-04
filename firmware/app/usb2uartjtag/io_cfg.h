/**
 * @file io_cfg.h
 * @brief Tang Nano 9K 3674 production-board wiring
 *
 * Copyright (c) 2021 Sipeed team
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to you under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */
#ifndef _IO_CFG_H
#define _IO_CFG_H

/*
 * Tang_nano_9K_3674_schematics.pdf, sheet BL702:
 *
 *   BL702 GPIO26 (BL_UART1_TX) -- R45 -- FPGA_RX  -- GW1NR pin 18
 *   GW1NR pin 17 (FPGA_TX)     -- R46 -- BL_UART1_RX -- GPIO27
 *
 * The production board has no UART modem-control wiring.  GPIO28 is the
 * Boot_Strap net, GPIO24 is LED_STATE, and GPIO25 is not connected.  Keep
 * all FTDI DTR/RTS/CTS requests logical-only so a host open/close cannot
 * change boot strapping or the JTAG clock.
 */
#define TANG_NANO_9K_3674_PRODUCTION 1
#define UART_TXD_PIN                 GPIO_PIN_26
#define UART_RXD_PIN                 GPIO_PIN_27
#define UART1_HAS_MODEM_CONTROL     0

/* D25/LED_STATE, active low; the production board has one BL702 LED. */
#define LED0_PIN                    GPIO_PIN_24
#define LED_COUNT                   1

/* BL702 -> GW1NR JTAG nets (R39/R36/R38/R37 on the production sheet). */
#define TMS_PIN                     GPIO_PIN_14
#define TCK_PIN                     GPIO_PIN_23
#define TDI_PIN                     GPIO_PIN_17
#define TDO_PIN                     GPIO_PIN_15

/*
 * UART0 is only a development log channel.  GPIO2 is NC on the production
 * board and is used as an optional TX probe by the BSP; it is deliberately
 * not one of the JTAG pins.  UART0 RX has no production-board connection.
 */
#define UART0_TXD_PIN               GPIO_PIN_2

#endif
