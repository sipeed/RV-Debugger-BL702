#include "main.h"

#define FTDI_DESCRIPITOR_LEN (9 + 7 + 7 + 9 + 7 + 7)
#define USB_CONFIG_SIZE (9 + FTDI_DESCRIPITOR_LEN)

USB_DESC_SECTION uint8_t usb_descriptor[] = {
    ///////////////////////////////////////
    /// device descriptor
    ///////////////////////////////////////
    USB_DEVICE_DESCRIPTOR_INIT(USB_2_0, 0x00, 0x00, 0x00, USBD_VID, USBD_PID,
                               USBD_BCD, 0x01),

    ///////////////////////////////////////
    /// config descriptor
    ///////////////////////////////////////
    USB_CONFIG_DESCRIPTOR_INIT(
        USB_CONFIG_SIZE, 0x02, 0x01,
        (USB_CONFIG_BUS_POWERED | USB_CONFIG_REMOTE_WAKEUP), USBD_MAX_POWER),

    ///////////////////////////////////////
    /// interface0 descriptor
    ///////////////////////////////////////
    USB_INTERFACE_DESCRIPTOR_INIT(0x00, 0x00, 0x02,
                                  USB_DEVICE_CLASS_VEND_SPECIFIC, 0xff, 0xff,
                                  USB_STRING_LANGID_INDEX),
    USB_ENDPOINT_DESCRIPTOR_INIT(FTDI_IN_0_EP, USB_ENDPOINT_TYPE_BULK, 0x0040,
                                 0x01),
    USB_ENDPOINT_DESCRIPTOR_INIT(FTDI_OUT_0_EP, USB_ENDPOINT_TYPE_BULK, 0x0040,
                                 0x01),

    ///////////////////////////////////////
    /// interface1 descriptor
    ///////////////////////////////////////
    USB_INTERFACE_DESCRIPTOR_INIT(0x01, 0x00, 0x02,
                                  USB_DEVICE_CLASS_VEND_SPECIFIC, 0xff, 0xff,
                                  USB_STRING_LANGID_INDEX),
    USB_ENDPOINT_DESCRIPTOR_INIT(FTDI_IN_1_EP, USB_ENDPOINT_TYPE_BULK, 0x0040,
                                 0x01),
    USB_ENDPOINT_DESCRIPTOR_INIT(FTDI_OUT_1_EP, USB_ENDPOINT_TYPE_BULK, 0x0040,
                                 0x01),

    ///////////////////////////////////////
    /// string0 descriptor (LANGID)
    ///////////////////////////////////////
    USB_LANGID_INIT(USBD_LANGID_STRING),
    ///////////////////////////////////////
    /// string1 descriptor (MFC)
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
    /// string2 descriptor (PRODUCT)
    ///////////////////////////////////////
    0x20,                       /* bLength */
    USB_DESCRIPTOR_TYPE_STRING, /* bDescriptorType */
    'U', 0x00,                  /* wcChar0 */
    'S', 0x00,                  /* wcChar1 */
    'B', 0x00,                  /* wcChar2 */
    ' ', 0x00,                  /* wcChar3 */
    'T', 0x00,                  /* wcChar4 */
    'O', 0x00,                  /* wcChar5 */
    ' ', 0x00,                  /* wcChar6 */
    'D', 0x00,                  /* wcChar7 */
    'U', 0x00,                  /* wcChar8 */
    'A', 0x00,                  /* wcChar9 */
    'L', 0x00,                  /* wcChar10 */
    'U', 0x00,                  /* wcChar11 */
    'A', 0x00,                  /* wcChar12 */
    'R', 0x00,                  /* wcChar13 */
    'T', 0x00,                  /* wcChar14 */
    ///////////////////////////////////////
    /// string3 descriptor (SERIAL)
    ///////////////////////////////////////
    0x0E,                       /* bLength */
    USB_DESCRIPTOR_TYPE_STRING, /* bDescriptorType */
    'S', 0x00,                  /* wcChar0 */
    'I', 0x00,                  /* wcChar1 */
    '8', 0x00,                  /* wcChar2 */
    '8', 0x00,                  /* wcChar3 */
    '4', 0x00,                  /* wcChar4 */
    '8', 0x00,                  /* wcChar5 */

    ///////////////////////////////////////
    /// device qualifier descriptor
    ///////////////////////////////////////
    0x0a, USB_DESCRIPTOR_TYPE_DEVICE_QUALIFIER, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x40, 0x01, 0x00,

    0x00};