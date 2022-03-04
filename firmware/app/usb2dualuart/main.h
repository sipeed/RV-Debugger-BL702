#pragma once

#include "dev_cfg.h"
#include "ftdi/usbd_ftdi.h"
#include "hal_usb.h"
#include "uart_interface.h"

#define FTDI_IN_0_EP USB_SET_EP_IN(1)
#define FTDI_OUT_0_EP USB_SET_EP_OUT(2)
#define FTDI_IN_1_EP USB_SET_EP_IN(3)
#define FTDI_OUT_1_EP USB_SET_EP_OUT(4)

#define USBD_VID (0x0403)
#define USBD_PID (0x6010)
#define USBD_BCD (0x0500)
#define USBD_MAX_POWER (90) /* 90/2 = 45 */
#define USBD_LANGID_STRING (0x0409)

void led_set(uint8_t idx, uint8_t status);
void led_toggle(uint8_t idx);