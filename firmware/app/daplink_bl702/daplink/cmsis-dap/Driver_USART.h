/**
 * @file    Driver_USART.h
 * @brief   Minimal CMSIS-Driver USART stub for BL702 SWO
 *
 * The CMSIS-DAP SWO.c expects an ARM CMSIS-Driver USART interface.
 * Since BL702 uses its own UART HAL, this stub provides the type
 * definitions expected by SWO.c for compilation only — the actual
 * SWO UART functions are implemented in swo_uart_bl702.c and
 * override the __WEAK implementations in SWO.c at link time.
 */

#ifndef __DRIVER_USART_H__
#define __DRIVER_USART_H__

#include <stdint.h>

/* ARM_USART status bits */
#define ARM_USART_EVENT_RECEIVE_COMPLETE   (1U << 0)
#define ARM_USART_EVENT_TX_COMPLETE        (1U << 1)
#define ARM_USART_EVENT_RX_OVERFLOW        (1U << 2)
#define ARM_USART_EVENT_RX_BREAK           (1U << 3)
#define ARM_USART_EVENT_RX_FRAMING_ERROR   (1U << 4)
#define ARM_USART_EVENT_RX_PARITY_ERROR    (1U << 5)

/* ARM_USART control codes */
#define ARM_USART_MODE_ASYNCHRONOUS        (0x01U)
#define ARM_USART_DATA_BITS_8              (0x03U << 4)
#define ARM_USART_PARITY_NONE              (0x00U << 6)
#define ARM_USART_STOP_BITS_1              (0x00U << 8)
#define ARM_USART_CONTROL_RX               (0x02U)
#define ARM_USART_ABORT_RECEIVE            (0x1002U)

/* ARM Driver status codes */
#define ARM_DRIVER_OK      0

/* ARM Power states */
#define ARM_POWER_OFF      0
#define ARM_POWER_FULL     (1U << 0)

/* USART Status */
typedef struct {
  uint8_t rx_busy;
  uint8_t tx_busy;
} ARM_USART_STATUS;

/* USART Driver — function pointer table (never called, for compilation only) */
typedef struct _ARM_DRIVER_USART {
  int32_t (*Initialize)   (void *cb);
  int32_t (*Uninitialize) (void);
  int32_t (*PowerControl) (uint32_t state);
  int32_t (*Control)      (uint32_t control, uint32_t arg);
  int32_t (*Receive)      (void *buf, uint32_t num);
  ARM_USART_STATUS (*GetStatus) (void);
  uint32_t (*GetRxCount)  (void);
} ARM_DRIVER_USART;

#endif /* __DRIVER_USART_H__ */
