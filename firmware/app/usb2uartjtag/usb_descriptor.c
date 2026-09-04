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
 
#include "hal_usb.h"
#include "usbd_core.h"
#include "usbd_ftdi.h"
#include "usbd_winusb.h"
#include "usb_descriptor.h"
#include "bl702_usb.h"

#define USB_MS_OS_20_VENDOR_CODE 0x20
#define USB_SERIAL_PREFIX_LENGTH 11
#define USB_SERIAL_CHIP_ID_LENGTH 6
#define USB_SERIAL_DESCRIPTOR_OFFSET (0x12 + 0x37 + 0x04 + 0x0e + 0x1c)
#define USB_SERIAL_DATA_OFFSET (USB_SERIAL_DESCRIPTOR_OFFSET + 2)

const uint16_t ftdi_eeprom_info[] = 
{
	0x0800, 0x0403, 0x6010, 0x0501, 0x3280, 0x0000, 0x0200, 0x1096,
	0x1aa6, 0x0000, 0x0046, 0x0310, 0x004f, 0x0070, 0x0065, 0x006e,
	0x002d, 0x0045, 0x0043, 0x031a, 0x0055, 0x0053, 0x0042, 0x0020,
	0x0044, 0x0065, 0x0062, 0x0075, 0x0067, 0x0067, 0x0065, 0x0072,
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x1027 
};

// const uint16_t ftdi_eeprom_info[] = 
// {
//     0x0108, 0x0403, 0x6010, 0x0700, 0x3280, 0x0008, 0x0000, 0x0A9A, 
//     0x2CA4, 0x16D0, 0x0000, 0x0000, 0x0046, 0x030A, 0x0046, 0x0054 ,   
//     0x0044, 0x0049, 0x032C, 0x0042, 0x006F, 0x0075, 0x0066, 0x0066 ,   
//     0x0061, 0x006C, 0x006F, 0x0020, 0x004C, 0x0061, 0x0062, 0x0020 ,  
//     0x0044, 0x0065, 0x0062, 0x0075, 0x0067, 0x0067, 0x0065, 0x0072,
//     0x0316, 0x0042, 0x0046, 0x004C, 0x0042, 0x0031, 0x0032, 0x0033 ,  
//     0x0034, 0x0035, 0x0036, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 ,
//     0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x53FC ,       
// };
uint8_t cdc_descriptor[] =
{
    ///////////////////////////////////////
    /// device descriptor
    ///////////////////////////////////////
    0x12,                       /* bLength */
    USB_DESCRIPTOR_TYPE_DEVICE, /* bDescriptorType */
    0x10, 0x02,                 /* bcdUSB: USB 2.1, required for BOS */
    0x00,                       /* bDeviceClass */
    0x00,                       /* bDeviceSubClass */
    0x00,                       /* bDeviceProtocol */
    0x40,                       /* bMaxPacketSize */
    0x03, 0x04,                 /* idVendor */
    0x10, 0x60,                 /* idProduct */
    0x01, 0x05,                 /* bcdDevice: distinct from a real FT2232H */
    0x01,                       /* iManufacturer */
    0x02,                       /* iProduct */
    0x03,                       /* iSerial */
    0x01,                       /* bNumConfigurations */

    ///////////////////////////////////////
    /// config descriptor
    ///////////////////////////////////////
    0x09,                              /* bLength */
    USB_DESCRIPTOR_TYPE_CONFIGURATION, /* bDescriptorType */
    0x37, 0x00,                        /* wTotalLength */
    0x02,                              /* bNumInterfaces */
    0x01,                              /* bConfigurationValue */
    0x00,                              /* iConfiguration */
    0xa0,                              /* bmAttributes */
    0x2d,                              /* bMaxPower */

    ///////////////////////////////////////
    /// interface descriptor
    ///////////////////////////////////////
    0x09,                          /* bLength */
    USB_DESCRIPTOR_TYPE_INTERFACE, /* bDescriptorType */
    0x00,                          /* bInterfaceNumber */
    0x00,                          /* bAlternateSetting */
    0x02,                          /* bNumEndpoints */
    0xff,                          /* bInterfaceClass */
    0xff,                          /* bInterfaceSubClass */
    0xff,                          /* bInterfaceProtocol */
    0x02,                          /* iInterface */

    ///////////////////////////////////////
    /// endpoint descriptor
    ///////////////////////////////////////
    0x07,                         /* bLength */
    USB_DESCRIPTOR_TYPE_ENDPOINT, /* bDescriptorType */
    0x81,                         /* bEndpointAddress */
    0x02,                         /* bmAttributes */
    0x40, 0x00,                   /* wMaxPacketSize */
    0x01,                         /* bInterval */

    ///////////////////////////////////////
    /// endpoint descriptor
    ///////////////////////////////////////
    0x07,                         /* bLength */
    USB_DESCRIPTOR_TYPE_ENDPOINT, /* bDescriptorType */
    0x02,                         /* bEndpointAddress */
    0x02,                         /* bmAttributes */
    0x40, 0x00,                   /* wMaxPacketSize */
    0x01,                         /* bInterval */

    ///////////////////////////////////////
    /// interface descriptor
    ///////////////////////////////////////
    0x09,                          /* bLength */
    USB_DESCRIPTOR_TYPE_INTERFACE, /* bDescriptorType */
    0x01,                          /* bInterfaceNumber */
    0x00,                          /* bAlternateSetting */
    0x02,                          /* bNumEndpoints */
    0xff,                          /* bInterfaceClass */
    0xff,                          /* bInterfaceSubClass */
    0xff,                          /* bInterfaceProtocol */
    0x00,                          /* iInterface */

    ///////////////////////////////////////
    /// endpoint descriptor
    ///////////////////////////////////////
    0x07,                         /* bLength */
    USB_DESCRIPTOR_TYPE_ENDPOINT, /* bDescriptorType */
    CDC_IN_EP,                    /* bEndpointAddress */
    0x02,                         /* bmAttributes */
    0x40, 0x00,                   /* wMaxPacketSize */
    0x01,                         /* bInterval */

    ///////////////////////////////////////
    /// endpoint descriptor
    ///////////////////////////////////////
    0x07,                         /* bLength */
    USB_DESCRIPTOR_TYPE_ENDPOINT, /* bDescriptorType */
    CDC_OUT_EP,                   /* bEndpointAddress */
    0x02,                         /* bmAttributes */
    0x40, 0x00,                   /* wMaxPacketSize */
    0x01,                         /* bInterval */

    ///////////////////////////////////////
    /// string0 descriptor
    ///////////////////////////////////////
    0x04,                       /* bLength */
    USB_DESCRIPTOR_TYPE_STRING, /* bDescriptorType */
    0x09, 0x04,                 /* wLangID0 */
    ///////////////////////////////////////
    /// string1 descriptor
    ///////////////////////////////////////
    0x0E,                       /* bLength */
    USB_DESCRIPTOR_TYPE_STRING, /* bDescriptorType */
    'S', 0x00,                  /* wcChar0 */
    'I', 0x00,                  /* wcChar1 */
    'P', 0x00,                  /* wcChar2 */
    'E', 0x00,                  /* wcChar3 */
	'E', 0x00,                  /* wcChar4 */
	'D', 0x00,                  /* wcChar5 */
    ///////////////////////////////////////
    /// string2 descriptor
    ///////////////////////////////////////
    0x1c,                       /* bLength */
    USB_DESCRIPTOR_TYPE_STRING, /* bDescriptorType */
    'J', 0x00,                  /* wcChar0 */
    'T', 0x00,                  /* wcChar1 */
    'A', 0x00,                  /* wcChar2 */
    'G', 0x00,                  /* wcChar3 */
    ' ', 0x00,                  /* wcChar4 */
    'D', 0x00,                  /* wcChar5 */
    'e', 0x00,                  /* wcChar6 */
    'b', 0x00,                  /* wcChar7 */
    'u', 0x00,                  /* wcChar8 */
    'g', 0x00,                  /* wcChar9 */
    'g', 0x00,                  /* wcChar10 */
    'e', 0x00,                  /* wcChar11 */
    'r', 0x00,                  /* wcChar12 */
    ///////////////////////////////////////
    /// string3 descriptor
    ///////////////////////////////////////
    0x30,                       /* bLength */
    USB_DESCRIPTOR_TYPE_STRING, /* bDescriptorType */
    'B', 0x00,                  /* wcChar0 */
    'L', 0x00,                  /* wcChar1 */
    '7', 0x00,                  /* wcChar2 */
    '0', 0x00,                  /* wcChar3 */
    '2', 0x00,                  /* wcChar4 */
    '_', 0x00,                  /* wcChar5 */
    'F', 0x00,                  /* wcChar6 */
    'T', 0x00,                  /* wcChar7 */
    'D', 0x00,                  /* wcChar8 */
    'I', 0x00,                  /* wcChar9 */
    '_', 0x00,                  /* wcChar10 */
    '0', 0x00,                  /* wcChar11 */
    '0', 0x00,                  /* wcChar12 */
    '0', 0x00,                  /* wcChar13 */
    '0', 0x00,                  /* wcChar14 */
    '0', 0x00,                  /* wcChar15 */
    '0', 0x00,                  /* wcChar16 */
    '0', 0x00,                  /* wcChar17 */
    '0', 0x00,                  /* wcChar18 */
    '0', 0x00,                  /* wcChar19 */
    '0', 0x00,                  /* wcChar20 */
    '0', 0x00,                  /* wcChar21 */
    '0', 0x00,                  /* wcChar22 */
    ///////////////////////////////////////
    /// device qualifier descriptor
    ///////////////////////////////////////
    0x0a,
    USB_DESCRIPTOR_TYPE_DEVICE_QUALIFIER,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x40,
    0x01,
    0x00,

    0x00
};

/*
 * Microsoft OS 2.0 descriptors bind interface A to WinUSB automatically.
 * Interface B is intentionally omitted, so Windows can keep using FTDIBUS
 * for the UART channel.
 */
static uint8_t bos_descriptor[] = {
    0x05, USB_DESCRIPTOR_TYPE_BINARY_OBJECT_STORE, 0x21, 0x00, 0x01,
    0x1c, USB_DESCRIPTOR_TYPE_DEVICE_CAPABILITY, USB_BOS_CAPABILITY_PLATFORM, 0x00,
    0xd8, 0xdd, 0x60, 0xdf, 0x45, 0x89, 0x4c, 0xc7,
    0x9c, 0xd2, 0x65, 0x9d, 0x9e, 0x64, 0x8a, 0x9f,
    0x00, 0x00, 0x03, 0x06,
    0x2e, 0x00,
    USB_MS_OS_20_VENDOR_CODE,
    0x00
};

static uint8_t ms_os_20_descriptor[] = {
    /* Microsoft OS 2.0 descriptor set header */
    0x0a, 0x00, WINUSB_SET_HEADER_DESCRIPTOR_TYPE, 0x00,
    0x00, 0x00, 0x03, 0x06,
    0x2e, 0x00,

    /* Configuration subset header */
    0x08, 0x00, WINUSB_SUBSET_HEADER_CONFIGURATION_TYPE, 0x00,
    0x00, 0x00, 0x24, 0x00,

    /* Function subset header: interface A (MI_00) only */
    0x08, 0x00, WINUSB_SUBSET_HEADER_FUNCTION_TYPE, 0x00,
    0x00, 0x00, 0x1c, 0x00,

    /* Compatible ID descriptor */
    0x14, 0x00, WINUSB_FEATURE_COMPATIBLE_ID_TYPE, 0x00,
    'W', 'I', 'N', 'U', 'S', 'B', 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

static struct usb_bos_descriptor bos_desc = {
    .string = bos_descriptor,
    .string_len = sizeof(bos_descriptor),
};

static struct usb_msosv2_descriptor msosv2_desc = {
    .compat_id = ms_os_20_descriptor,
    .compat_id_len = sizeof(ms_os_20_descriptor),
    .vendor_code = USB_MS_OS_20_VENDOR_CODE,
};

void usb_descriptor_register(const uint8_t chip_id[8])
{
    static const char hex[] = "0123456789ABCDEF";
    uint32_t i;

    for (i = 0; i < USB_SERIAL_CHIP_ID_LENGTH; i++) {
        uint8_t value = chip_id[i + 2];
        uint32_t char_index = USB_SERIAL_PREFIX_LENGTH + (i * 2);

        cdc_descriptor[USB_SERIAL_DATA_OFFSET + (char_index * 2)] = hex[value >> 4];
        cdc_descriptor[USB_SERIAL_DATA_OFFSET + ((char_index + 1) * 2)] = hex[value & 0x0f];
    }

    usbd_desc_register(cdc_descriptor);
    usbd_bos_desc_register(&bos_desc);
    usbd_msosv2_desc_register(&msosv2_desc);
}
