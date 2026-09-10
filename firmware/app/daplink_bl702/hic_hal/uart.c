/**
 * @file    uart.c
 * @brief   UART Driver stub for BL702
 *
 * DAPLink Interface Firmware - BL702 Port
 *
 * Stub implementation: UART (CDC serial) not yet implemented.
 * CMSIS-DAP core does not require UART for basic debug functionality.
 * Full implementation needed for Phase 5 (CDC virtual COM port).
 */

#include <stdint.h>
#include <stdbool.h>
#include "uart.h"

int32_t uart_initialize(void)
{
    return 0;   /* Stub: success */
}

int32_t uart_uninitialize(void)
{
    return 0;
}

int32_t uart_reset(void)
{
    return 0;
}

int32_t uart_set_configuration(UART_Configuration *config)
{
    (void)config;
    return 0;
}

int32_t uart_get_configuration(UART_Configuration *config)
{
    (void)config;
    return 0;
}

int32_t uart_write_free(void)
{
    return 0;
}

int32_t uart_write_data(uint8_t *data, uint16_t size)
{
    (void)data;
    (void)size;
    return 0;
}

int32_t uart_read_data(uint8_t *data, uint16_t size)
{
    (void)data;
    (void)size;
    return 0;
}

void uart_set_control_line_state(uint16_t ctrl_bmp)
{
    (void)ctrl_bmp;
}

void uart_software_flow_control(void)
{
}

void uart_enable_flow_control(bool enabled)
{
    (void)enabled;
}
