/**
 * @file    cmsis_os2_port.c
 * @brief   CMSIS-RTOS2 Bare-metal Adapter for BL702
 *
 * DAPLink Interface Firmware - BL702 Port
 *
 * Implements a minimal subset of CMSIS-RTOS2 API using polling and
 * a hardware timer (BL702 mtime) for periodic callbacks.
 *
 * Key mappings:
 *   osKernelInitialize / Start → init timer, call main function
 *   osThreadNew              → save function pointer
 *   osThreadFlagsWait        → poll global flag variable
 *   osThreadFlagsSet         → set global flag variable
 *   osTimerNew / Start       → register mtime callback
 *   osDelay                  → mtimer busy-wait
 */

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include "cmsis_os2.h"
#include "hal_mtimer.h"

/* ========================================================================
 * Global state
 * ======================================================================== */

static osThreadFunc_t  g_main_thread_func = NULL;
static void           *g_main_thread_arg  = NULL;

volatile uint32_t g_main_flags = 0;

/* Timer callback storage */
#define MAX_TIMERS 4
static osTimerFunc_t g_timer_funcs[MAX_TIMERS] = { NULL };
static uint32_t      g_timer_periods[MAX_TIMERS] = { 0 };
static uint32_t      g_timer_ticks[MAX_TIMERS] = { 0 };
static uint8_t       g_timer_count = 0;

/* ========================================================================
 * Timer ISR (called from mtime interrupt)
 * ======================================================================== */

void SysTick_Handler(void)
{
    uint8_t i;
    for (i = 0; i < g_timer_count; i++) {
        if (g_timer_funcs[i] != NULL) {
            g_timer_ticks[i]++;
            if (g_timer_ticks[i] >= g_timer_periods[i]) {
                g_timer_ticks[i] = 0;
                g_timer_funcs[i](NULL);
            }
        }
    }
}

/* ========================================================================
 * Kernel API
 * ======================================================================== */

osStatus_t osKernelInitialize(void)
{
    return osOK;
}

osStatus_t osKernelStart(void)
{
    if (g_main_thread_func) {
        g_main_thread_func(g_main_thread_arg);
    }
    /* Should never return */
    while (1) {}
    return osOK;
}

uint32_t osKernelGetTickCount(void)
{
    return (uint32_t)mtimer_get_time_ms();
}

/* ========================================================================
 * Thread API
 * ======================================================================== */

osThreadId_t osThreadNew(osThreadFunc_t func, void *argument, const osThreadAttr_t *attr)
{
    (void)attr;
    g_main_thread_func = func;
    g_main_thread_arg  = argument;
    return (osThreadId_t)1;
}

osThreadId_t osThreadGetId(void)
{
    return (osThreadId_t)1;
}

/* ========================================================================
 * Flags API
 * ======================================================================== */

uint32_t osThreadFlagsSet(osThreadId_t thread_id, uint32_t flags)
{
    (void)thread_id;
    g_main_flags |= flags;
    return flags;
}

uint32_t osThreadFlagsWait(uint32_t flags, uint32_t options, uint32_t timeout)
{
    (void)options;
    (void)timeout;

    /* Simple polling - wait until any requested flag is set */
    while (!(g_main_flags & flags)) {
        /* Yield / wait */
    }

    uint32_t ret = g_main_flags & flags;
    g_main_flags &= ~flags;
    return ret;
}

/* ========================================================================
 * Timer API
 * ======================================================================== */

osTimerId_t osTimerNew(osTimerFunc_t func, osTimerType_t type, void *argument, const osTimerAttr_t *attr)
{
    (void)type;
    (void)argument;
    (void)attr;

    if (g_timer_count >= MAX_TIMERS) {
        return NULL;
    }

    uint8_t idx = g_timer_count++;
    g_timer_funcs[idx] = func;
    g_timer_periods[idx] = 0;
    g_timer_ticks[idx] = 0;

    return (osTimerId_t)(uintptr_t)(idx + 1);
}

osStatus_t osTimerStart(osTimerId_t timer_id, uint32_t ticks)
{
    uint8_t idx = (uint8_t)((uintptr_t)timer_id - 1);
    if (idx >= g_timer_count) {
        return osErrorParameter;
    }
    g_timer_periods[idx] = ticks;
    g_timer_ticks[idx] = 0;
    return osOK;
}

/* ========================================================================
 * Delay API
 * ======================================================================== */

osStatus_t osDelay(uint32_t ticks)
{
    /* ticks in ms for our implementation */
    mtimer_delay_ms(ticks);
    return osOK;
}
