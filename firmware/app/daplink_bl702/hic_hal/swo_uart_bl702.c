/**
 * @file    swo_uart_bl702.c
 * @brief   SWO UART capture for BL702 using interrupt-driven RX
 *
 * Configures UART0 RX on GPIO_PIN_1 (reuses TDO pin) with RX FIFO
 * interrupt to capture SWO trace data into SWO.c's TraceBuf.
 *
 * Interrupt flow:
 *   UART RX byte arrives → RX FIFO threshold reached → ISR fires →
 *   read all FIFO bytes → write to TraceBuf → update TraceIndexI
 */

#include <stdint.h>
#include "DAP_config.h"
#include "DAP.h"
#include "Driver_USART.h"
#include "bl702_uart.h"
#include "bl702_glb.h"
#include "hal_gpio.h"
#include "bl702_common.h"  /* CPU_Interrupt_Enable/Disable */

#if (SWO_UART != 0)

/* Dummy USART driver instance (required by SWO.c extern declaration) */
ARM_DRIVER_USART Driver_USART0;

/* Extern from SWO.c — ISR writes directly to trace buffer */
extern uint8_t           TraceBuf[SWO_BUFFER_SIZE];
extern volatile uint32_t TraceIndexI;
extern volatile uint8_t  TraceUpdate;

/* ---- UART state ---- */
static uint8_t  swo_uart_ready = 0U;

/* ========================================================================
 * UART RX Interrupt Handler
 * ========================================================================
 *
 * Called by BL702 UART interrupt when RX FIFO threshold is reached.
 * Reads all available bytes from the FIFO and appends them to TraceBuf.
 */
static void swo_uart_rx_isr(uint32_t uart_id) {
  uint32_t idx_i, fifo_cnt, avail;
  uint8_t  byte;
  (void)uart_id;

  fifo_cnt = (uint32_t)UART_GetRxFifoCount(UART0_ID);
  if (fifo_cnt == 0U) return;

  idx_i = TraceIndexI;

  /* Don't overflow the trace buffer (wrap-safe) */
  avail = SWO_BUFFER_SIZE - (idx_i & (SWO_BUFFER_SIZE - 1U));
  if (fifo_cnt > avail) {
    fifo_cnt = avail;
  }

  while (fifo_cnt--) {
    UART_ReceiveData(UART0_ID, &byte, 1U);
    TraceBuf[idx_i & (SWO_BUFFER_SIZE - 1U)] = byte;
    idx_i++;
  }

  TraceIndexI = idx_i;
  TraceUpdate = 1U;

  UART_IntClear(UART0_ID, UART_INT_RX_FIFO_REQ);
}

/* ========================================================================
 * SWO UART functions called by SWO.c
 * ======================================================================== */

uint32_t SWO_Mode_UART (uint32_t enable) {
  if (enable) {
    UART_CFG_Type uartCfg;
    UART_FifoCfg_Type fifoCfg;

    /* Enable UART clock (96MHz) */
    GLB_Set_UART_CLK(ENABLE, HBN_UART_CLK_96M, 1);

    /* Route GPIO1 (TDO) to UART0_RXD */
    GLB_UART_Fun_Sel(GLB_UART_SIG_1, GLB_UART_SIG_FUN_UART0_RXD);
    GLB_UART_Sig_Swap_Set(0);

    /* Configure GPIO1 as input with pull-up */
    gpio_set_mode(TDO_PIN, GPIO_INPUT_PP_MODE);

    /* Configure UART: 8N1, default 2MHz */
    uartCfg.uartClk = 96000000U;
    uartCfg.baudRate = 2000000U;  /* Default 2MHz */
    uartCfg.dataBits = UART_DATABITS_8;
    uartCfg.stopBits = UART_STOPBITS_1;
    uartCfg.parity = UART_PARITY_NONE;
    uartCfg.ctsFlowControl = DISABLE;
    uartCfg.rxDeglitch = ENABLE;
    uartCfg.byteBitInverse = UART_LSB_FIRST;
    UART_Init(UART0_ID, &uartCfg);

    /* RX FIFO: threshold=1 (interrupt per byte), no DMA */
    fifoCfg.txFifoDmaThreshold = 0;
    fifoCfg.rxFifoDmaThreshold = 0;
    fifoCfg.txFifoDmaEnable = DISABLE;
    fifoCfg.rxFifoDmaEnable = DISABLE;
    UART_FifoConfig(UART0_ID, &fifoCfg);

    /* Install RX FIFO interrupt handler */
    UART_Int_Callback_Install(UART0_ID, UART_INT_RX_FIFO_REQ,
                              (intCallback_Type *)swo_uart_rx_isr);
    UART_IntMask(UART0_ID, UART_INT_RX_FIFO_REQ, UNMASK);
    CPU_Interrupt_Enable(UART0_IRQn);

    /* Enable UART RX */
    UART_Enable(UART0_ID, UART_RX);

    swo_uart_ready = 1U;
  } else {
    if (swo_uart_ready) {
      CPU_Interrupt_Disable(UART0_IRQn);
      UART_Disable(UART0_ID, UART_RX);
      UART_DeInit(UART0_ID);
      swo_uart_ready = 0U;
    }
  }
  return 1U;
}

uint32_t SWO_Baudrate_UART (uint32_t baudrate) {
  if (baudrate > SWO_UART_MAX_BAUDRATE) {
    baudrate = SWO_UART_MAX_BAUDRATE;
  }
  if (baudrate == 0U) return 0U;

  if (swo_uart_ready) {
    CPU_Interrupt_Disable(UART0_IRQn);
    UART_Disable(UART0_ID, UART_RX);

    UART_CFG_Type uartCfg;
    uartCfg.uartClk = 96000000U;
    uartCfg.baudRate = baudrate;
    uartCfg.dataBits = UART_DATABITS_8;
    uartCfg.stopBits = UART_STOPBITS_1;
    uartCfg.parity = UART_PARITY_NONE;
    uartCfg.ctsFlowControl = DISABLE;
    uartCfg.rxDeglitch = ENABLE;
    uartCfg.byteBitInverse = UART_LSB_FIRST;
    UART_Init(UART0_ID, &uartCfg);

    UART_Enable(UART0_ID, UART_RX);
    CPU_Interrupt_Enable(UART0_IRQn);
  }
  return baudrate;
}

uint32_t SWO_Control_UART (uint32_t active) {
  if (!swo_uart_ready) return 0U;
  if (active) {
    UART_RxFifoClear(UART0_ID);
  }
  return 1U;
}

void SWO_Capture_UART (uint8_t *buf, uint32_t num) {
  (void)buf;
  (void)num;
  /* Data is captured automatically by ISR */
}

uint32_t SWO_GetCount_UART (void) {
  if (!swo_uart_ready) return 0U;
  /* ISR writes directly to TraceBuf; return 0 as count is tracked
   * by SWO.c's internal TraceIndexI (updated by ISR) */
  return 0U;
}

#endif /* (SWO_UART != 0) */
