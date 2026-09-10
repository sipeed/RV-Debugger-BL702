/**
 * @file    usbd_BL702.c
 * @brief   USB Device Adapter: RL-USB API → BL702 USB Stack
 *
 * DAPLink Interface Firmware - BL702 Port
 *
 * Maps DAPLink's RL-USB function calls to BL702's native USB API.
 * This allows DAPLink core code to compile against BL702 hardware.
 */

#include <stdint.h>
#include <stdbool.h>
#include "usbd_core.h"
#include "usb_dc.h"
#include "hal_usb.h"
#include "bl702_usb.h"
#include "rl_usb.h"

/* ========================================================================
 * Internal state
 * ======================================================================== */

static struct device *g_usb_dev = NULL;
static bool g_usb_connected = false;

/* ========================================================================
 * RL-USB API → BL702 Implementation
 * ======================================================================== */

void usbd_init(void)
{
    /* BL702 USB initialization is done in main.c via:
     *   usbd_desc_register() + usbd_class_register() + usb_dc_init()
     * This stub exists for DAPLink source compatibility.
     */
}

void usbd_connect(bool con)
{
    /* BL702 hardware automatically connects via D+ pull-up.
     * No explicit connect/disconnect control.
     */
    (void)con;
    g_usb_connected = con;
}

bool usbd_configured(void)
{
    return usb_device_is_configured();
}

int32_t USBD_Initialize(uint32_t index)
{
    (void)index;
    return 0;  /* ARM_DRIVER_OK */
}

int32_t USBD_Connect(uint32_t index)
{
    (void)index;
    return 0;
}

bool USBD_Configured(uint32_t index)
{
    (void)index;
    return usb_device_is_configured();
}

/* Endpoint read/write mapped to BL702 API */
int32_t USBD_EndpointRead(uint32_t index, uint8_t ep, uint8_t *buf, uint32_t size)
{
    uint32_t chunk = 0;
    (void)index;
    return usbd_ep_read(ep, buf, size, &chunk);
}

int32_t USBD_EndpointWrite(uint32_t index, uint8_t ep, const uint8_t *buf, uint32_t size)
{
    (void)index;
    return usbd_ep_write(ep, buf, size, NULL);
}

uint32_t USBD_EndpointReadGetResult(uint32_t index, uint8_t ep)
{
    (void)index;
    (void)ep;
    return 0;
}

int32_t USBD_EndpointAbort(uint32_t index, uint8_t ep)
{
    (void)index;
    (void)ep;
    return 0;
}
