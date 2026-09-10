/**
 * @file    rl_usb.h
 * @brief   RL-USB API Stub Header for DAPLink → BL702 Port
 *
 * Provides the function declarations needed by DAPLink core source files.
 * Actual implementation maps to BL702 USB stack in usbd_BL702.c.
 */

#ifndef RL_USB_H
#define RL_USB_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* USB initialization */
void usbd_init(void);
void usbd_connect(bool con);
bool usbd_configured(void);

/* RL-USB Core API (implemented as stubs/usbd_BL702.c) */
int32_t  USBD_Initialize(uint32_t index);
int32_t  USBD_Connect(uint32_t index);
bool     USBD_Configured(uint32_t index);

/* Endpoint operations */
int32_t  USBD_EndpointRead(uint32_t index, uint8_t ep, uint8_t *buf, uint32_t size);
int32_t  USBD_EndpointWrite(uint32_t index, uint8_t ep, const uint8_t *buf, uint32_t size);
uint32_t USBD_EndpointReadGetResult(uint32_t index, uint8_t ep);
int32_t  USBD_EndpointAbort(uint32_t index, uint8_t ep);

/* USB event types (from RL-USB) */
#define ARM_USBD_EVENT_OUT          (1U << 0)
#define ARM_USBD_EVENT_IN           (1U << 1)
#define ARM_USBD_EVENT_SETUP        (1U << 2)

/* Endpoint address helpers (avoid redefinition with usb_def.h) */
#ifndef USB_ENDPOINT_OUT
#define USB_ENDPOINT_OUT(n)         (n)
#endif
#ifndef USB_ENDPOINT_IN
#define USB_ENDPOINT_IN(n)          (0x80U | (n))
#endif

#ifdef __cplusplus
}
#endif

#endif /* RL_USB_H */
