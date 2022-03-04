/**
 * @file main.c
 * @brief
 *
 * Copyright (c) 2021 Bouffalolab team
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

#include "main.h"

#include "bflb_platform.h"
#include "hal_uart.h"
#include "hal_usb.h"
#include "usbd_core.h"

/* ring buffer */
#define USB_OUT_RINGBUFFER_SIZE (8 * 1024)
#define UART_RX_RINGBUFFER_SIZE (8 * 1024)
static uint8_t usb_rx_mem[2][USB_OUT_RINGBUFFER_SIZE]
    __attribute__((section(".system_ram")));
static uint8_t uart_rx_mem[2][UART_RX_RINGBUFFER_SIZE]
    __attribute__((section(".system_ram")));
static Ring_Buffer_Type usb_rx_rb[2];
static Ring_Buffer_Type uart_rx_rb[2];

/* private function */
static void led_gpio_init(void);
static void usb_ringbuffer_init(void);
static void uart_ringbuffer_init(void);
static void uart_irq_callback(struct device *dev, void *args, uint32_t size,
                              uint32_t state);
static int usb_dc_ftdi_send_from_ringbuffer(struct device *dev,
                                            Ring_Buffer_Type *rb, uint8_t ep);
static int usb_dc_ftdi_receive_to_ringbuffer(struct device *dev,
                                             Ring_Buffer_Type *rb, uint8_t ep);
static void usbd_cdc_acm_bulk_out(uint8_t ep);
static void usbd_cdc_acm_bulk_in(uint8_t ep);

static struct device *usb_fs;
static usbd_class_t ftdi_class[2];
static usbd_interface_t ftdi_data_intf[2];
static usbd_endpoint_t ftdi_in_ep[2] = {
    {.ep_addr = FTDI_IN_0_EP, .ep_cb = usbd_cdc_acm_bulk_in},
    {.ep_addr = FTDI_IN_1_EP, .ep_cb = usbd_cdc_acm_bulk_in}};
static usbd_endpoint_t ftdi_out_ep[2] = {
    {.ep_addr = FTDI_OUT_0_EP, .ep_cb = usbd_cdc_acm_bulk_out},
    {.ep_addr = FTDI_OUT_1_EP, .ep_cb = usbd_cdc_acm_bulk_out}};

/* external funtion and data */
extern struct device *usb_dc_init(void);
extern USB_DESC_SECTION uint8_t usb_descriptor[];

// enum uart_index_type board_get_debug_uart_index(void) { return 1; }

int main(void) {
  /* disable debug for uart0 */
  bflb_platform_print_set(1);
  led_gpio_init();
  led_set(0, 1); /* led0 on */
  led_set(1, 0); /* led1 off */
  bflb_platform_init(0);
  usb_ringbuffer_init();
  uart_ringbuffer_init();
  uart_set_dtr_rts(0, UART0_DTR_PIN, UART0_RTS_PIN);
  uart_set_dtr_rts(1, UART1_DTR_PIN, UART1_RTS_PIN);
  uart_dtr_init(0);
  uart_dtr_init(1);
  uart_init(0, uart_irq_callback);
  uart_init(1, uart_irq_callback);

  /* update USB_VID,PID,BCD */
  memcpy((void *)&usb_descriptor[8], (void *)&ftdi_eeprom_info[1],
         3 * sizeof(uint16_t));

  usbd_desc_register(usb_descriptor);
  for (size_t i = 0; i < 2; i++) {
    usbd_ftdi_add_interface(&ftdi_class[i], &ftdi_data_intf[i]);
    usbd_interface_add_endpoint(&ftdi_data_intf[i], &ftdi_in_ep[i]);
    usbd_interface_add_endpoint(&ftdi_data_intf[i], &ftdi_out_ep[i]);
  }

  usb_fs = usb_dc_init();
  if (usb_fs) {
    device_control(
        usb_fs, DEVICE_CTRL_SET_INT,
        (void *)(USB_SOF_IT | USB_EP1_DATA_IN_IT | USB_EP2_DATA_OUT_IT |
                 USB_EP3_DATA_IN_IT | USB_EP4_DATA_OUT_IT));
  }
  while (!usb_device_is_configured()) {
  }

  led_set(1, 1); /* led1 on */

  while (1) {
    uart_send_from_ringbuffer(0, &usb_rx_rb[0]);
    uart_send_from_ringbuffer(1, &usb_rx_rb[1]);
  }

  return 0;
}

/************************  led ctrl functions  ************************/
static uint32_t led_pins[2] = {LED0_PIN, LED1_PIN};
static volatile uint8_t led_stat[2] = {0, 0};
static void led_gpio_init(void) {
  gpio_set_mode(led_pins[0], GPIO_OUTPUT_MODE);
  gpio_set_mode(led_pins[1], GPIO_OUTPUT_MODE);
  led_set(0, led_stat[0]);
  led_set(1, led_stat[1]);
  return;
}

void led_set(uint8_t idx, uint8_t status) {
  gpio_write(led_pins[idx], !status);
  led_stat[idx] = status;
  return;
}

void led_toggle(uint8_t idx) {
  led_stat[idx] = !led_stat[idx];
  gpio_write(led_pins[idx], !led_stat[idx]);
  return;
}

/************************  API for usbd_ftdi  ************************/
void usbd_ftdi_set_line_coding(uint8_t index, uint32_t baudrate,
                               uint8_t databits, uint8_t parity,
                               uint8_t stopbits) {
  uart_config(index, baudrate, databits, parity, stopbits);
  Ring_Buffer_Reset(&uart_rx_rb[index]);
  Ring_Buffer_Reset(&usb_rx_rb[index]);
}
void usbd_ftdi_set_dtr(uint8_t index, bool dtr) { dtr_pin_set(index, !dtr); }
void usbd_ftdi_set_rts(uint8_t index, bool rts) { rts_pin_set(index, !rts); }

/* init ring_buffer for usb */
static void usb_ringbuffer_init(void) {
  for (size_t i = 0; i < 2; i++) {
    /* init mem for ring_buffer */
    memset(usb_rx_mem[i], 0, USB_OUT_RINGBUFFER_SIZE);

    /* init ring_buffer */
    Ring_Buffer_Init(&usb_rx_rb[i], usb_rx_mem[i], USB_OUT_RINGBUFFER_SIZE,
                     cpu_global_irq_disable, cpu_global_irq_enable);
  }
}

static void uart_ringbuffer_init(void) {
  for (size_t i = 0; i < 2; i++) {
    /* init mem for ring_buffer */
    memset(uart_rx_mem[i], 0, UART_RX_RINGBUFFER_SIZE);

    /* init ring_buffer */
    Ring_Buffer_Init(&uart_rx_rb[i], uart_rx_mem[i], UART_RX_RINGBUFFER_SIZE,
                     cpu_global_irq_disable, cpu_global_irq_enable);
  }
}

/* USB out -> UART tx */
static void usbd_cdc_acm_bulk_out(uint8_t ep) {
  size_t _epid = (USB_EP_GET_IDX(ep) - 1) / 2;
  usb_dc_ftdi_receive_to_ringbuffer(usb_fs, &usb_rx_rb[_epid], ep);
}
/* UART rx -> USB in */
static void usbd_cdc_acm_bulk_in(uint8_t ep) {
  size_t _epid = (USB_EP_GET_IDX(ep) - 1) / 2;
  usb_dc_ftdi_send_from_ringbuffer(usb_fs, &uart_rx_rb[_epid], ep);
  // usb_dc_ftdi_send_from_ringbuffer(usb_fs, &usb_rx_rb[_epid], ep);
}

#include "bl702_usb.h"
static int usb_dc_ftdi_receive_to_ringbuffer(struct device *dev,
                                             Ring_Buffer_Type *rb, uint8_t ep) {
  size_t _epid;
  uint8_t ep_idx;
  uint8_t recv_len;
  uint32_t timeout = 0x0000FFFF;
  static bool overflow_flag[2] = {false, false};

  /* Check if OUT ep */
  if (USB_EP_GET_DIR(ep) != USB_EP_DIR_OUT) {
    return -USB_DC_EP_DIR_ERR;
  }

  ep_idx = USB_EP_GET_IDX(ep);
  _epid = (ep_idx - 1) / 2;

  while (!USB_Is_EPx_RDY_Free(ep_idx)) {
    timeout--;
    if (!timeout) {
      LOG_E("ep%d wait free timeout\r\n", ep);
      return -USB_DC_EP_TIMEOUT_ERR;
    }
  }

  recv_len = USB_Get_EPx_RX_FIFO_CNT(ep_idx);

  /*if rx fifo count equal 0,it means last is send nack and ringbuffer is
   * smaller than 64, so,if ringbuffer is larger than 64,set ack to recv next
   * data.
   */
  if (overflow_flag[_epid] && (Ring_Buffer_Get_Empty_Length(rb) > 64) &&
      (!recv_len)) {
    overflow_flag[_epid] = false;
    USB_Set_EPx_Rdy(ep_idx);
    return 0;
  } else {
    uint32_t addr = USB_BASE + 0x11C + (ep_idx - 1) * 0x10;
    Ring_Buffer_Write_Callback(rb, recv_len, fifocopy_to_mem, (void *)addr);

    if (Ring_Buffer_Get_Empty_Length(rb) < 64) {
      overflow_flag[_epid] = true;
      return -USB_DC_RB_SIZE_SMALL_ERR;
    }

    USB_Set_EPx_Rdy(ep_idx);
    return 0;
  }
}

static int usb_dc_ftdi_send_from_ringbuffer(struct device *dev,
                                            Ring_Buffer_Type *rb, uint8_t ep) {
  size_t _epid;
  uint8_t ep_idx;
  uint32_t timeout = 0x0000FFFF;
  static uint8_t ftdi_header[2] = {0x01, 0x60};
  static uint64_t last_send[2] = {0, 0};

  ep_idx = USB_EP_GET_IDX(ep);
  _epid = (ep_idx - 1) / 2;

  /* Check if IN ep */
  if (USB_EP_GET_DIR(ep) != USB_EP_DIR_IN) {
    return -USB_DC_EP_DIR_ERR;
  }

  while (!USB_Is_EPx_RDY_Free(ep_idx)) {
    timeout--;
    if (!timeout) {
      LOG_E("ep%d wait free timeout\r\n", ep);
      return -USB_DC_EP_TIMEOUT_ERR;
    }
  }

  uint32_t addr = USB_BASE + 0x118 + (ep_idx - 1) * 0x10;

  if ((USB_Get_EPx_TX_FIFO_CNT(ep_idx) == USB_FS_MAX_PACKET_SIZE) &&
      Ring_Buffer_Get_Length(rb) >= USB_FS_MAX_PACKET_SIZE - 2) {
    memcopy_to_fifo((void *)addr, (uint8_t *)ftdi_header, 2);
    Ring_Buffer_Read_Callback(rb, USB_FS_MAX_PACKET_SIZE - 2, memcopy_to_fifo,
                              (void *)addr);

    USB_Set_EPx_Rdy(ep_idx);
    last_send[_epid] = bflb_platform_get_time_us();
    return 0;
  } else {
    uint64_t Latency_Timer = usbd_ftdi_get_latency_timer(_epid);
    if (bflb_platform_get_time_us() - last_send[_epid] >=
        Latency_Timer * 1000) {
      memcopy_to_fifo((void *)addr, (uint8_t *)ftdi_header, 2);
      Ring_Buffer_Read_Callback(rb, Ring_Buffer_Get_Length(rb), memcopy_to_fifo,
                                (void *)addr);

      USB_Set_EPx_Rdy(ep_idx);
      last_send[_epid] = bflb_platform_get_time_us();
    }
    return -USB_DC_RB_SIZE_SMALL_ERR;
  }
}

static void uart_irq_callback(struct device *dev, void *args, uint32_t size,
                              uint32_t state) {
  uint8_t _idx = UART_DEV(dev)->id;
  switch (state) {
    case UART_EVENT_RX_FIFO:
    case UART_EVENT_RTO:
      if (size && size < Ring_Buffer_Get_Empty_Length(&uart_rx_rb[_idx])) {
        Ring_Buffer_Write(&uart_rx_rb[_idx], (uint8_t *)args, size);
        led_toggle(_idx);
      } else {
        LOG_E(state == UART_EVENT_RX_FIFO ? "RF\r\n" : "RTO\r\n");
      }
      break;
    case UART_RX_FER_IT:
      LOG_E("OV\r\n");
      break;

    default:
      break;
  }
}