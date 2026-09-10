/**
 * @file    device.h
 * @brief   Device Header for BL702 (DAPLink-style)
 *
 * DAPLink Interface Firmware - BL702 Port
 *
 * Maps the INTERFACE_BL702 define to the BL702 CMSIS/device headers.
 */

#ifndef DEVICE_H
#define DEVICE_H

#if defined (INTERFACE_BL702)
/* BL702 RISC-V MCU - No CMSIS device header needed */
/* DAPLink CMSIS-DAP core only needs this file to exist */
#else
#error "Unknown INTERFACE_xxx define"
#endif

#endif /* DEVICE_H */
