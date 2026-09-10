/**
 * @file    DAP_config.h
 * @brief   CMSIS-DAP Configuration for BL702 (DAPLink-style)
 *
 * DAPLink Interface Firmware - BL702 Port
 *
 * Uses DAPLink's IO_Config.h for pin definitions, separating pin mapping
 * from CMSIS-DAP protocol configuration.
 */

#ifndef __DAP_CONFIG_H__
#define __DAP_CONFIG_H__

#include "IO_Config.h"
#include "hal_gpio.h"
#include "hal_mtimer.h"
#include "gpio.h"
#include <string.h>

/* For __STATIC_INLINE, __STATIC_FORCEINLINE, __WEAK, __NOP */
#include "cmsis_compiler.h"


//**************************************************************************************************
/**
\defgroup DAP_Config_Debug_gr CMSIS-DAP Debug Unit Information
@{
*/

/// Processor Clock: BL702 max 144MHz
#define CPU_CLOCK               144000000U

/// I/O Port write cycles (RISC-V typical: 2)
#define IO_PORT_WRITE_CYCLES    2U

/// SWD support: enabled
#define DAP_SWD                 1

/// JTAG support: enabled
#define DAP_JTAG                1

/// Max JTAG devices on scan chain
#define DAP_JTAG_DEV_CNT        8U

/// Default port mode: 1=SWD, 2=JTAG
#define DAP_DEFAULT_PORT        1U

/// Default SWD/JTAG clock: 1MHz
#define DAP_DEFAULT_SWJ_CLOCK   1000000U

/// Packet size: 64 bytes (Full-speed USB BULK)
#define DAP_PACKET_SIZE         64U

/// Packet buffers: 4 (BL702 SRAM-constrained)
#define DAP_PACKET_COUNT        4U

/// SWO UART trace: not implemented (GPIO1/UART0 conflicts with JTAG TDO)
#define SWO_UART                0
#define SWO_UART_DRIVER         0
#define SWO_UART_MAX_BAUDRATE   10000000U

/// SWO Manchester: not implemented
#define SWO_MANCHESTER          0
#define SWO_BUFFER_SIZE         4096U
#define SWO_STREAM              0

/// Timestamp clock: 1MHz (BL702 mtime)
#define TIMESTAMP_CLOCK         1000000U

/// UART COM port: not implemented
#define DAP_UART                0
#define DAP_UART_DRIVER         0
#define DAP_UART_RX_BUFFER_SIZE 1024U
#define DAP_UART_TX_BUFFER_SIZE 1024U

/// USB COM Port: not implemented
#define DAP_UART_USB_COM_PORT   0

/// Fixed target: no
#define TARGET_FIXED            0

/* String functions */
__STATIC_INLINE uint8_t DAP_GetVendorString (char *str) {
  (void)str; return 0U;
}
__STATIC_INLINE uint8_t DAP_GetProductString (char *str) {
  const char *p = "DAPLink CMSIS-DAP";
  uint8_t len = (uint8_t)strlen(p) + 1U;
  memcpy(str, p, len); return len;
}
__STATIC_INLINE uint8_t DAP_GetSerNumString (char *str) {
  const char *p = "202400000001";
  uint8_t len = (uint8_t)strlen(p) + 1U;
  memcpy(str, p, len); return len;
}
__STATIC_INLINE uint8_t DAP_GetTargetDeviceVendorString (char *str) { (void)str; return 0U; }
__STATIC_INLINE uint8_t DAP_GetTargetDeviceNameString   (char *str) { (void)str; return 0U; }
__STATIC_INLINE uint8_t DAP_GetTargetBoardVendorString  (char *str) { (void)str; return 0U; }
__STATIC_INLINE uint8_t DAP_GetTargetBoardNameString    (char *str) { (void)str; return 0U; }
__STATIC_INLINE uint8_t DAP_GetProductFirmwareVersionString (char *str) { (void)str; return 0U; }

///@}


//**************************************************************************************************
/**
\defgroup DAP_Config_PortIO_gr CMSIS-DAP Hardware I/O Pin Access
@{

All GPIO operations use BL702 HAL: gpio_write(), gpio_read(), gpio_set_mode()
Pin numbers defined in IO_Config.h
*/

// JTAG/SWD Port Setup
__STATIC_INLINE void PORT_JTAG_SETUP (void) {
  gpio_set_mode(SWCLK_TCK_PIN, GPIO_OUTPUT_MODE); gpio_write(SWCLK_TCK_PIN, 1);
  gpio_set_mode(SWDIO_TMS_PIN, GPIO_OUTPUT_MODE); gpio_write(SWDIO_TMS_PIN, 1);
  gpio_set_mode(TDI_PIN,       GPIO_OUTPUT_MODE); gpio_write(TDI_PIN,       1);
  gpio_set_mode(TDO_PIN,       GPIO_INPUT_MODE);
  gpio_set_mode(NRESET_PIN,    GPIO_OUTPUT_MODE); gpio_write(NRESET_PIN,    1);
}
__STATIC_INLINE void PORT_SWD_SETUP (void) {
  gpio_set_mode(SWCLK_TCK_PIN, GPIO_OUTPUT_MODE); gpio_write(SWCLK_TCK_PIN, 1);
  gpio_set_mode(SWDIO_TMS_PIN, GPIO_OUTPUT_MODE); gpio_write(SWDIO_TMS_PIN, 1);
  gpio_set_mode(NRESET_PIN,    GPIO_OUTPUT_MODE); gpio_write(NRESET_PIN,    1);
  gpio_set_mode(TDI_PIN,       GPIO_HZ_MODE);
}
__STATIC_INLINE void PORT_OFF (void) {
  gpio_set_mode(SWCLK_TCK_PIN, GPIO_HZ_MODE);
  gpio_set_mode(SWDIO_TMS_PIN, GPIO_HZ_MODE);
  gpio_set_mode(TDI_PIN,       GPIO_HZ_MODE);
  gpio_set_mode(TDO_PIN,       GPIO_HZ_MODE);
  gpio_set_mode(NRESET_PIN,    GPIO_HZ_MODE);
}

// SWCLK/TCK
__STATIC_FORCEINLINE uint32_t PIN_SWCLK_TCK_IN  (void)       { return (uint32_t)gpio_read(SWCLK_TCK_PIN); }
__STATIC_FORCEINLINE void     PIN_SWCLK_TCK_SET (void)       { gpio_write(SWCLK_TCK_PIN, 1); }
__STATIC_FORCEINLINE void     PIN_SWCLK_TCK_CLR (void)       { gpio_write(SWCLK_TCK_PIN, 0); }

// SWDIO/TMS
__STATIC_FORCEINLINE uint32_t PIN_SWDIO_TMS_IN  (void)       { return (uint32_t)gpio_read(SWDIO_TMS_PIN); }
__STATIC_FORCEINLINE void     PIN_SWDIO_TMS_SET (void)       { gpio_write(SWDIO_TMS_PIN, 1); }
__STATIC_FORCEINLINE void     PIN_SWDIO_TMS_CLR (void)       { gpio_write(SWDIO_TMS_PIN, 0); }
__STATIC_FORCEINLINE uint32_t PIN_SWDIO_IN      (void)       { return (uint32_t)gpio_read(SWDIO_TMS_PIN); }
__STATIC_FORCEINLINE void     PIN_SWDIO_OUT     (uint32_t b) { gpio_write(SWDIO_TMS_PIN, (b & 1U) ? 1 : 0); }
__STATIC_FORCEINLINE void     PIN_SWDIO_OUT_ENABLE  (void)   { gpio_set_mode(SWDIO_TMS_PIN, GPIO_OUTPUT_MODE); }
__STATIC_FORCEINLINE void     PIN_SWDIO_OUT_DISABLE (void)   { gpio_set_mode(SWDIO_TMS_PIN, GPIO_INPUT_MODE); }

// TDI
__STATIC_FORCEINLINE uint32_t PIN_TDI_IN  (void)             { return (uint32_t)gpio_read(TDI_PIN); }
__STATIC_FORCEINLINE void     PIN_TDI_OUT (uint32_t b)       { gpio_write(TDI_PIN, (b & 1U) ? 1 : 0); }

// TDO
__STATIC_FORCEINLINE uint32_t PIN_TDO_IN  (void)             { return (uint32_t)gpio_read(TDO_PIN); }

// nTRST (not connected on BL702 board)
__STATIC_FORCEINLINE uint32_t PIN_nTRST_IN  (void)           { return 0U; }
__STATIC_FORCEINLINE void     PIN_nTRST_OUT (uint32_t b)     { (void)b; }

// nRESET
__STATIC_FORCEINLINE uint32_t PIN_nRESET_IN  (void)          { return (uint32_t)gpio_read(NRESET_PIN); }
__STATIC_FORCEINLINE void     PIN_nRESET_OUT (uint32_t b)    {
  if (b) {
    /* Release reset: MUST drive high BEFORE changing mode.
     * gpio_set_mode() preserves the previous output value, so if we
     * change mode first the pin stays low for the duration of the call,
     * generating a spurious reset pulse that disrupts SWD. */
    gpio_write(NRESET_PIN, 1);
    gpio_set_mode(NRESET_PIN, GPIO_OUTPUT_PP_MODE);
  } else {
    /* Assert reset: drive low */
    gpio_set_mode(NRESET_PIN, GPIO_OUTPUT_MODE);
    gpio_write(NRESET_PIN, 0);
  }
}

///@}


//**************************************************************************************************
/**
\defgroup DAP_Config_LEDs_gr CMSIS-DAP Hardware Status LEDs
@{
*/
__STATIC_INLINE void LED_CONNECTED_OUT (uint32_t bit) { gpio_write(CONNECTED_LED_PIN, (bit & 1U) ? 0 : 1); }
__STATIC_INLINE void LED_RUNNING_OUT   (uint32_t bit) { gpio_write(RUNNING_LED_PIN,   (bit & 1U) ? 0 : 1); }
///@}


//**************************************************************************************************
/**
\defgroup DAP_Config_Timestamp_gr CMSIS-DAP Timestamp
@{
*/
__STATIC_INLINE uint32_t TIMESTAMP_GET (void) { return (uint32_t)mtimer_get_time_us(); }
///@}


//**************************************************************************************************
/**
\defgroup DAP_Config_Initialization_gr CMSIS-DAP Initialization
@{
*/
__STATIC_INLINE void DAP_SETUP (void) {
  gpio_init();  /* Initialize all pins via HIC HAL */
}
__STATIC_INLINE uint8_t RESET_TARGET (void) {
  /* Hardware reset via nRESET pin (GPIO_PIN_3).
   * Sequence: assert low → wait 20ms → release high → wait 20ms.
   * Uses push-pull with internal pull-up when releasing to avoid
   * floating when the target board lacks an external pull-up. */
  uint32_t delay;

  /* Assert reset: drive low */
  gpio_set_mode(NRESET_PIN, GPIO_OUTPUT_MODE);
  gpio_write(NRESET_PIN, 0);

  /* Wait ~20ms (144MHz CPU, ~3 cycles/loop_iter) */
  for (delay = 960000U; delay; delay--) {
    __NOP();
  }

  /* Release reset: drive high with internal pull-up */
  gpio_write(NRESET_PIN, 1);
  gpio_set_mode(NRESET_PIN, GPIO_OUTPUT_PP_MODE);

  /* Wait ~20ms for target to stabilize */
  for (delay = 960000U; delay; delay--) {
    __NOP();
  }

  return 1U;  /* Reset performed */
}
///@}


//**************************************************************************************************
/**
\defgroup DAP_Config_Delay_gr CMSIS-DAP Delay calibration (RISC-V)
@{
*/
#ifndef DELAY_SLOW_CYCLES
#define DELAY_SLOW_CYCLES       3U
#endif
#ifndef DELAY_FAST_CYCLES
#define DELAY_FAST_CYCLES       0U
#endif
///@}


#endif /* __DAP_CONFIG_H__ */
