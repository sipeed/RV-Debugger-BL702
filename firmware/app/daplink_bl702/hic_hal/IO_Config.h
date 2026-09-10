/**
 * @file    IO_Config.h
 * @brief   I/O Pin Configuration for BL702 CMSIS-DAP Debug Probe
 *
 * DAPLink Interface Firmware - BL702 Port
 * Based on the BL702 USB2JTAG board pinout.
 *
 * BL702 uses flat GPIO numbering (GPIO_PIN_0..31), unlike STM32's PORT+PIN.
 * All pins are mapped directly to GPIO pin numbers.
 */

#ifndef __IO_CONFIG_H__
#define __IO_CONFIG_H__

#include "hal_gpio.h"
#include "compiler.h"

/* ========================================================================
 * Debug Interface Pins (SWD/JTAG)
 * ======================================================================== */

/* SWCLK / TCK */
#define SWCLK_TCK_PIN           GPIO_PIN_15

/* SWDIO / TMS (bidirectional: output + input on same pin) */
#define SWDIO_TMS_PIN           GPIO_PIN_2

/* TDI (JTAG only) */
#define TDI_PIN                 GPIO_PIN_0

/* TDO (JTAG only) */
#define TDO_PIN                 GPIO_PIN_1

/* nRESET - Target reset (open-drain, active low) */
#define NRESET_PIN              GPIO_PIN_3

/* ========================================================================
 * Status LEDs (active-low: 0 = ON, 1 = OFF)
 * ======================================================================== */

/* Connected / HID LED - indicates debugger is connected */
#define CONNECTED_LED_PIN       GPIO_PIN_9

/* Running / CDC LED - indicates target is running */
#define RUNNING_LED_PIN         GPIO_PIN_17

/* MSC LED - indicates MSC activity (shared with HID LED for now) */
#define MSC_LED_PIN             GPIO_PIN_9

/* ========================================================================
 * USB Control
 * ======================================================================== */

/* USB Connect (D+ pull-up enable) - BL702 handles this in hardware */
/* No GPIO control needed */

/* ========================================================================
 * Target Power Control (optional)
 * ======================================================================== */

/* If board has a power switch for the target, define the pin here */
/* #define POWER_EN_PIN         GPIO_PIN_xx */

/* ========================================================================
 * Reset Button (optional)
 * ======================================================================== */

/* If board has a reset button */
/* #define RESET_BTN_PIN        GPIO_PIN_xx */

#endif /* __IO_CONFIG_H__ */
