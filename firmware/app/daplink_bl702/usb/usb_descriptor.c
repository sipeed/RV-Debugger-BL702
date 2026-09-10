/**
 * @file    usb_descriptor.c
 * @brief   CMSIS-DAP v2 USB Descriptor for BL702 (DAPLink-style)
 *
 * USB descriptor table for CMSIS-DAP v2 WinUSB BULK interface.
 * Phase 2: CMSIS-DAP only. Phase 5 will add MSC + CDC composite.
 */

#include "usbd_core.h"
#include "usb_def.h"

/* Keil CMSIS-DAP official VID/PID (recognized by Keil MDK out of the box) */
#define USBD_VID        0xC251U
#define USBD_PID        0xF00AU

/* Endpoint addresses (BL702: separate physical EP per direction) */
#define DAP_OUT_EP      0x02U   /* EP2 OUT - command */
#define DAP_IN_EP       0x81U   /* EP1 IN  - response */

uint8_t usbd_descriptor[] =
{
    /* Device Descriptor (18 bytes) */
    0x12,                       USB_DESCRIPTOR_TYPE_DEVICE,
    0x00, 0x02,                 0x00, 0x00, 0x00, 0x40,
    0x51, 0xC2,                 /* VID = 0xC251 */
    0x0A, 0xF0,                 /* PID = 0xF00A */
    0x00, 0x01,                 0x01, 0x02, 0x03, 0x01,

    /* Configuration Descriptor (32 bytes total) */
    0x09,                       USB_DESCRIPTOR_TYPE_CONFIGURATION,
    0x20, 0x00,                 0x01, 0x01, 0x00, 0x80, 0xFA,

    /* Interface Descriptor (CMSIS-DAP v2, Vendor-specific BULK) */
    0x09,                       USB_DESCRIPTOR_TYPE_INTERFACE,
    0x00, 0x00, 0x02,           /* bInterface=0, bAlternate=0, bNumEndpoints=2 */
    0xFF, 0x00, 0x00, 0x00,     /* Vendor Specific */

    /* Endpoint: BULK OUT (EP2, must come first for OpenOCD) */
    0x07,                       USB_DESCRIPTOR_TYPE_ENDPOINT,
    DAP_OUT_EP, 0x02,           /* EP2 OUT, BULK */
    0x40, 0x00, 0x01,           /* MaxPacket=64, Interval=1 */

    /* Endpoint: BULK IN (EP1) */
    0x07,                       USB_DESCRIPTOR_TYPE_ENDPOINT,
    DAP_IN_EP, 0x02,            /* EP1 IN, BULK */
    0x40, 0x00, 0x01,           /* MaxPacket=64, Interval=1 */

    /* String 0: Language ID */
    0x04,                       USB_DESCRIPTOR_TYPE_STRING,
    0x09, 0x04,

    /* String 1: Manufacturer "ARM Ltd" (16 bytes) */
    0x10,                       USB_DESCRIPTOR_TYPE_STRING,
    'A',0x00,'R',0x00,'M',0x00,' ',0x00,'L',0x00,'t',0x00,'d',0x00,

    /* String 2: Product "DAPLink CMSIS-DAP" (38 bytes) */
    0x24,                       USB_DESCRIPTOR_TYPE_STRING,
    'D',0x00,'A',0x00,'P',0x00,'L',0x00,'i',0x00,'n',0x00,'k',0x00,
    ' ',0x00,
    'C',0x00,'M',0x00,'S',0x00,'I',0x00,'S',0x00,'-',0x00,'D',0x00,'A',0x00,'P',0x00,

    /* String 3: Serial Number "202400000001" (26 bytes) */
    0x1A,                       USB_DESCRIPTOR_TYPE_STRING,
    '2',0x00,'0',0x00,'2',0x00,'4',0x00,'0',0x00,'0',0x00,'0',0x00,'0',0x00,'0',0x00,'0',0x00,'0',0x00,'1',0x00,

    /* Device Qualifier */
    0x0A,                       USB_DESCRIPTOR_TYPE_DEVICE_QUALIFIER,
    0x00,0x02, 0x00,0x00,0x00,0x40,0x01,0x00,

    0x00  /* Terminator */
};

/* ========================================================================
* Microsoft OS 1.0 Descriptors for automatic WinUSB driver binding
* ========================================================================
*
* MS OS 1.0 uses a special string descriptor at index 0xEE plus a
* vendor request to return the Compatible ID. This approach:
*   - Works on all Windows versions (XP through 11)
*   - Does NOT require bcdUSB 2.1 / BOS descriptor
*   - CherryUSB fully supports this path (unlike the untested BOS path)
*
* Without these, Windows sees a Vendor Specific interface (0xFF) and
* has no driver to load — Keil MDK cannot find the debug probe.
*/

/* Vendor request code embedded in the 0xEE string descriptor */
#define MSOSV1_VENDOR_CODE  0x07U

/* MS OS 1.0 String Descriptor at fixed index 0xEE (18 bytes).
* Windows reads this on first attach to detect MS OS descriptor support.
* Format: Unicode string "MSFT100" + vendor_code as last character. */
static uint8_t dap_msosv1_string[] = {
   0x12,                                /* bLength = 18 */
   USB_DESCRIPTOR_TYPE_STRING,          /* bDescriptorType = 0x03 */
   'M',0x00, 'S',0x00, 'F',0x00, 'T',0x00,
   '1',0x00, '0',0x00, '0',0x00,
   MSOSV1_VENDOR_CODE, 0x00,           /* vendor code = 0x07 as Unicode char */
};

/* MS OS 1.0 Compatible ID Descriptor (32 bytes).
* Returned in response to vendor request (bRequest = vendor_code, wIndex = 0x04).
* Tells Windows to load WinUSB.sys for interface 0. */
static uint8_t dap_msosv1_compat_id[] = {
   /* Header */
   0x20, 0x00, 0x00, 0x00,             /* dwLength = 32 */
   0x00, 0x01,                           /* bcdVersion = 0x0100 */
   0x04, 0x00,                           /* wIndex = 0x0004 (Compatible ID) */
   0x01,                                  /* bCount = 1 function section */
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* reserved[7] */
   /* Function section 1 */
   'W','I','N','U','S','B',0x00,0x00,    /* compatibleID[8] = "WINUSB" */
   0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, /* subCompatibleID[8] = "" */
};

/* MS OS 1.0 Extended Properties Descriptor (140 bytes).
* Sets DeviceInterfaceGUID = {CDB3B5AD-293B-4663-AA36-1AAE46463776}
* per CMSIS-DAP v2 spec. Debuggers (Keil, OpenOCD) use this GUID
* to identify CMSIS-DAP v2 devices among all WinUSB devices.
*
* Returned in response to vendor request (wIndex = 0x05).
* Property data uses Unicode (UTF-16LE) per MDK middleware convention.
* Property name "DeviceInterfaceGUID" (19 chars, singular) matches MDK example. */
static uint8_t dap_msosv1_property[] = {
   /* Extended Properties Header */
   0x8C, 0x00, 0x00, 0x00,             /* dwLength = 140 */
   0x00, 0x01,                           /* bcdVersion = 0x0100 */
   0x05, 0x00,                           /* wIndex = 0x0005 */
   0x01, 0x00,                           /* wCount = 1 */

   /* Custom Property Section 0 */
   0x82, 0x00, 0x00, 0x00,             /* dwSize = 130 */
   0x01, 0x00, 0x00, 0x00,             /* dwPropertyDataType = REG_SZ (1) */
   0x26, 0x00,                           /* wPropertyNameLength = 38 (19 Unicode chars, no null) */
   /* bPropertyName: "DeviceInterfaceGUID" (Unicode UTF-16LE, 19 chars) */
   'D',0x00,'e',0x00,'v',0x00,'i',0x00,'c',0x00,'e',0x00,
   'I',0x00,'n',0x00,'t',0x00,'e',0x00,'r',0x00,'f',0x00,
   'a',0x00,'c',0x00,'e',0x00,
   'G',0x00,'U',0x00,'I',0x00,'D',0x00,
   /* dwPropertyDataLength = 78 (39 Unicode chars incl. null, × 2 bytes) */
   0x4E, 0x00, 0x00, 0x00,
   /* bPropertyData: "{CDB3B5AD-293B-4663-AA36-1AAE46463776}" + null (Unicode UTF-16LE) */
   '{',0x00,'C',0x00,'D',0x00,'B',0x00,'3',0x00,'B',0x00,'5',0x00,'A',0x00,'D',0x00,
   '-',0x00,
   '2',0x00,'9',0x00,'3',0x00,'B',0x00,
   '-',0x00,
   '4',0x00,'6',0x00,'6',0x00,'3',0x00,
   '-',0x00,
   'A',0x00,'A',0x00,'3',0x00,'6',0x00,
   '-',0x00,
   '1',0x00,'A',0x00,'A',0x00,'E',0x00,'4',0x00,'6',0x00,'4',0x00,'6',0x00,'3',0x00,'7',0x00,'7',0x00,'6',0x00,
   '}',0x00,
   0x00,0x00,                           /* null terminator (U+0000) */
};

/* Wrapper struct for CherryUSB registration */
struct usb_msosv1_descriptor dap_msosv1_desc = {
   .string                = dap_msosv1_string,
   .string_len            = sizeof(dap_msosv1_string),
   .vendor_code           = MSOSV1_VENDOR_CODE,
   .compat_id             = dap_msosv1_compat_id,
   .compat_id_len         = sizeof(dap_msosv1_compat_id),
   .comp_id_property      = dap_msosv1_property,
   .comp_id_property_len  = sizeof(dap_msosv1_property),
};

/* ========================================================================
* Minimal BOS Descriptor (5 bytes, USB 2.1 compliance)
* ========================================================================
*
* bcdUSB 2.1 (0x0210) REQUIRES BOS support per USB spec.
* Without BOS, Windows 11 rejects the device as non-compliant.
* This minimal BOS (zero capabilities) satisfies the requirement
* without triggering any MS OS 2.0 / vendor request behavior.
*
* Phase 2: no MS OS 2.0 platform capability (to be added if basic BOS works).
*/
/* NOTE: non-static to ensure DMA-accessible memory placement on BL702 */
uint8_t dap_bos_descriptor[] = {
    0x05,                                        /* bLength = 5 */
    USB_DESCRIPTOR_TYPE_BINARY_OBJECT_STORE,     /* bDescriptorType = 0x0F */
    0x05, 0x00,                                  /* wTotalLength = 5 */
    0x00,                                        /* bNumDeviceCaps = 0 */
};

struct usb_bos_descriptor dap_bos_desc = {
   .string     = dap_bos_descriptor,
   .string_len = sizeof(dap_bos_descriptor),
};
