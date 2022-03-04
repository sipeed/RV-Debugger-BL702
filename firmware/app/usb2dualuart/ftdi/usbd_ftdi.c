/**
 * @file usbd_ftdi.c
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

#include "usbd_ftdi.h"

#include "usbd_core.h"

/* Requests */
#define SIO_RESET_REQUEST 0x00          /* Reset the port */
#define SIO_SET_MODEM_CTRL_REQUEST 0x01 /* Set the modem control register */
#define SIO_SET_FLOW_CTRL_REQUEST 0x02  /* Set flow control register */
#define SIO_SET_BAUDRATE_REQUEST 0x03   /* Set baud rate */
#define SIO_SET_DATA_REQUEST                       \
  0x04 /* Set the data characteristics of the port \
        */
#define SIO_POLL_MODEM_STATUS_REQUEST 0x05
#define SIO_SET_EVENT_CHAR_REQUEST 0x06
#define SIO_SET_ERROR_CHAR_REQUEST 0x07
#define SIO_SET_LATENCY_TIMER_REQUEST 0x09
#define SIO_GET_LATENCY_TIMER_REQUEST 0x0A
#define SIO_SET_BITMODE_REQUEST 0x0B
#define SIO_READ_PINS_REQUEST 0x0C
#define SIO_READ_EEPROM_REQUEST 0x90
#define SIO_WRITE_EEPROM_REQUEST 0x91
#define SIO_ERASE_EEPROM_REQUEST 0x92

#define SIO_DISABLE_FLOW_CTRL 0x0
#define SIO_RTS_CTS_HS (0x1 << 8)
#define SIO_DTR_DSR_HS (0x2 << 8)
#define SIO_XON_XOFF_HS (0x4 << 8)

#define SIO_SET_DTR_MASK 0x1
#define SIO_SET_DTR_HIGH (1 | (SIO_SET_DTR_MASK << 8))
#define SIO_SET_DTR_LOW (0 | (SIO_SET_DTR_MASK << 8))
#define SIO_SET_RTS_MASK 0x2
#define SIO_SET_RTS_HIGH (2 | (SIO_SET_RTS_MASK << 8))
#define SIO_SET_RTS_LOW (0 | (SIO_SET_RTS_MASK << 8))

#define SIO_RTS_CTS_HS (0x1 << 8)

static volatile uint32_t sof_tick = 0;
static uint8_t Latency_Timer[2] = {0x0004, 0x0004};
static const char *stop_name[] = {"1", "1.5", "2"};
static const char *parity_name[] = {"N", "O", "E", "M", "S"};

static void ftdi_notify_handler(uint8_t event, void *arg);
static int ftdi_vendor_request_handler(struct usb_setup_packet *pSetup,
                                       uint8_t **data, uint32_t *len);

static void usbd_ftdi_reset(void);
static void ftdi_set_baudrate(uint32_t itdf_divisor, uint32_t *actual_baudrate);

uint32_t usbd_ftdi_get_sof_tick(void) { return sof_tick; }
uint32_t usbd_ftdi_get_latency_timer(uint8_t index) {
  return Latency_Timer[index];
}

void usbd_ftdi_add_interface(usbd_class_t *class, usbd_interface_t *intf) {
  static usbd_class_t *last_class = NULL;

  if (last_class != class) {
    last_class = class;
    usbd_class_register(class);
  }

  intf->class_handler = NULL;
  intf->custom_handler = NULL;
  intf->vendor_handler = ftdi_vendor_request_handler;
  intf->notify_handler = ftdi_notify_handler;
  usbd_class_add_interface(class, intf);
}

__weak void usbd_ftdi_set_line_coding(uint8_t index, uint32_t baudrate,
                                      uint8_t databits, uint8_t parity,
                                      uint8_t stopbits) {}
__weak void usbd_ftdi_set_dtr(uint8_t index, bool dtr) {}
__weak void usbd_ftdi_set_rts(uint8_t index, bool rts) {}

static void ftdi_notify_handler(uint8_t event, void *arg) {
  switch (event) {
    case USB_EVENT_RESET:
      usbd_ftdi_reset();
      break;
    case USB_EVENT_SOF:
      sof_tick++;
      USBD_LOG_DBG("tick: %d\r\n", sof_tick);
      break;
    default:
      USBD_LOG_DBG("event 0x%x\r\n", event);
      break;
  }
}

static int ftdi_vendor_request_handler(struct usb_setup_packet *pSetup,
                                       uint8_t **data, uint32_t *len) {
  static uint32_t actual_baudrate[2] = {1200, 1200};
  uint8_t _epid = pSetup->wIndexL - 1;

  // LOG_D(
  //     "[ftdi] request 0x%02x(type: 0x%02x), i: 0x%04x, v: 0x%04x, l:
  //     0x%04x\r", pSetup->bRequest, pSetup->bmRequestType, pSetup->wIndex,
  //     pSetup->wValue, pSetup->wLength);

  switch (pSetup->bRequest) {
    case SIO_READ_EEPROM_REQUEST:
      *data = (uint8_t *)&ftdi_eeprom_info[pSetup->wIndexL];
      *len = 2;
      break;
    case SIO_RESET_REQUEST:

      break;
    case SIO_SET_MODEM_CTRL_REQUEST:
      switch (pSetup->wValue) {
        case SIO_SET_DTR_HIGH:
          // LOG_D("DTR 1\r\n");
          usbd_ftdi_set_dtr(_epid, true);
          break;
        case SIO_SET_DTR_LOW:
          // LOG_D("DTR 0\r\n");
          usbd_ftdi_set_dtr(_epid, false);
          break;
        case SIO_SET_RTS_HIGH:
          // LOG_D("RTS 1\r\n");
          usbd_ftdi_set_rts(_epid, true);
          break;
        case SIO_SET_RTS_LOW:
          // LOG_D("RTS 0\r\n");
          usbd_ftdi_set_rts(_epid, false);
          break;
        default:
          break;
      }
      break;
    case SIO_SET_FLOW_CTRL_REQUEST:

      break;
    case SIO_SET_BAUDRATE_REQUEST:  // wValue，2个字节波特率
    {
      ftdi_set_baudrate(pSetup->wValue | ((pSetup->wIndexH) << 16),
                        &actual_baudrate[_epid]);
      break;
    }
    case SIO_SET_DATA_REQUEST:
      /**
       * D0-D7 databits  BITS_7=7, BITS_8=8
       * D8-D10 parity  NONE=0, ODD=1, EVEN=2, MARK=3, SPACE=4
       * D11-D12 		STOP_BIT_1=0, STOP_BIT_15=1, STOP_BIT_2=2
       * D14  		BREAK_OFF=0, BREAK_ON=1
       **/
      if (actual_baudrate[_epid] != 1200) {
        // USBD_LOG("CDC_SET_LINE_CODING <%d %d %s
        // %s>\r\n",actual_baudrate,(uint8_t)pSetup->wValue,parity_name[(uint8_t)(pSetup->wValue>>8)],stop_name[(uint8_t)(pSetup->wValue>>11)]);
        usbd_ftdi_set_line_coding(
            _epid, actual_baudrate[_epid], (uint8_t)pSetup->wValue,
            (uint8_t)(pSetup->wValue >> 8), (uint8_t)(pSetup->wValue >> 11));
      }
      break;

    case SIO_POLL_MODEM_STATUS_REQUEST:
      // Poll modem status information

      //       This function allows the retrieve the two status bytes of the
      //  device. The device sends these bytes also as a header for each read
      //  access where they are discarded by ftdi_read_data(). The chip
      //  generates the two stripped status bytes in the absence of data every
      //  40 ms.

      //       Layout of the first byte:
      //       - B0..B3 - must be 0
      //       - B4       Clear to send (CTS)
      //                               0 = inactive
      //                               1 = active
      //       - B5       Data set ready (DTS)
      //                               0 = inactive
      //                               1 = active
      //       - B6       Ring indicator (RI)
      //                               0 = inactive
      //                               1 = active
      //       - B7       Receive line signal detect (RLSD)
      //                               0 = inactive
      //                               1 = active

      //       Layout of the second byte:
      //       - B0       Data ready (DR)
      //       - B1       Overrun error (OE)
      //       - B2       Parity error (PE)
      //       - B3       Framing error (FE)
      //       - B4       Break interrupt (BI)
      //       - B5       Transmitter holding register (THRE)
      //       - B6       Transmitter empty (TEMT)
      //       - B7       Error in RCVR FIFO
      *data = (uint8_t *)&ftdi_eeprom_info[2];
      *len = 2;
      break;
    case SIO_SET_EVENT_CHAR_REQUEST:

      break;
    case SIO_SET_ERROR_CHAR_REQUEST:

      break;
    case SIO_SET_LATENCY_TIMER_REQUEST:
      Latency_Timer[_epid] = pSetup->wValueL;
      break;
    case SIO_GET_LATENCY_TIMER_REQUEST:
      *data = &Latency_Timer[_epid];
      *len = 1;
      USBD_LOG_DBG("get latency%d:%d,len:%d\r\n", _epid, **data, *len);
      break;
    case SIO_SET_BITMODE_REQUEST:

      break;
    default:
      return -1;
  }
  return 0;
}

static void usbd_ftdi_reset(void) {
  sof_tick = 0;
  for (size_t i = 0; i < 2; i++) {
    Latency_Timer[i] = 0x0001;
  }
}

static void ftdi_set_baudrate(uint32_t itdf_divisor,
                              uint32_t *actual_baudrate) {
#define FTDI_USB_CLK 48000000
  int baudrate;
  uint8_t frac[] = {0, 8, 4, 2, 6, 10, 12, 14};
  int divisor = itdf_divisor & 0x3fff;
  divisor <<= 4;
  divisor |= frac[(itdf_divisor >> 14) & 0x07];

  if (itdf_divisor == 0x01) {
    baudrate = 2000000;
  } else if (itdf_divisor == 0x00) {
    baudrate = 3000000;
  } else {
    baudrate = FTDI_USB_CLK / divisor;
  }

  if (baudrate > 10000 && baudrate < 12000) {
    *actual_baudrate = (baudrate - 10000) * 10000;
  } else {
    *actual_baudrate = baudrate;
  }
}