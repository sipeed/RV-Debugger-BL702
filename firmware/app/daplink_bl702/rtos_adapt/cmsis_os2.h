/**
 * @file    cmsis_os2.h
 * @brief   CMSIS-RTOS2 API Header (minimal subset for DAPLink)
 *
 * DAPLink Interface Firmware - BL702 Port
 *
 * Provides the type and function declarations needed by DAPLink core.
 * Actual implementation is in cmsis_os2_port.c (bare-metal polling).
 */

#ifndef CMSIS_OS2_H_
#define CMSIS_OS2_H_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Status codes */
typedef int32_t osStatus_t;
#define osOK                 0
#define osError             -1
#define osErrorParameter    -2
#define osErrorResource     -3
#define osErrorTimeout      -4

/* Thread */
typedef void *osThreadId_t;
typedef void (*osThreadFunc_t)(void *argument);

typedef struct {
    const char *name;
    uint32_t    attr_bits;
    void       *cb_mem;
    uint32_t    cb_size;
    void       *stack_mem;
    uint32_t    stack_size;
    uint32_t    priority;
} osThreadAttr_t;

/* Timer */
typedef void *osTimerId_t;
typedef void (*osTimerFunc_t)(void *argument);

typedef enum {
    osTimerOnce     = 0,
    osTimerPeriodic = 1
} osTimerType_t;

typedef struct {
    const char *name;
    uint32_t    attr_bits;
    void       *cb_mem;
    uint32_t    cb_size;
} osTimerAttr_t;

/* Flags */
#define osFlagsWaitAny     0x00000000U
#define osWaitForever      0xFFFFFFFFU

/* Kernel */
osStatus_t    osKernelInitialize(void);
osStatus_t    osKernelStart(void);
uint32_t      osKernelGetTickCount(void);

/* Thread */
osThreadId_t  osThreadNew(osThreadFunc_t func, void *argument, const osThreadAttr_t *attr);
osThreadId_t  osThreadGetId(void);

/* Flags */
uint32_t      osThreadFlagsSet(osThreadId_t thread_id, uint32_t flags);
uint32_t      osThreadFlagsWait(uint32_t flags, uint32_t options, uint32_t timeout);

/* Timer */
osTimerId_t   osTimerNew(osTimerFunc_t func, osTimerType_t type, void *argument, const osTimerAttr_t *attr);
osStatus_t    osTimerStart(osTimerId_t timer_id, uint32_t ticks);

/* Delay */
osStatus_t    osDelay(uint32_t ticks);

/* Global flags variable (set by ISRs, polled by main loop) */
extern volatile uint32_t g_main_flags;

/* SysTick handler (called from mtime interrupt) */
void SysTick_Handler(void);

#ifdef __cplusplus
}
#endif

#endif /* CMSIS_OS2_H_ */
