/**
 * @file    flash.c
 * @brief   Flash HAL stub for BL702
 *
 * DAPLink Interface Firmware - BL702 Port
 *
 * Stub implementation: BL702 as a debug probe does not self-program its flash.
 * CMSIS-DAP core does not use these functions directly; they are for MSC
 * drag-n-drop and bootloader features (Phase 5+).
 */

#include <stdint.h>
#include <stdbool.h>
#include "flash_hal.h"

uint32_t flash_program_page(uint32_t adr, uint32_t sz, uint8_t *buf)
{
    (void)adr;
    (void)sz;
    (void)buf;
    return 1;   /* Error: not implemented */
}

uint32_t flash_erase_sector(uint32_t addr)
{
    (void)addr;
    return 1;   /* Error: not implemented */
}

bool flash_is_readable(uint32_t addr, uint32_t length)
{
    (void)addr;
    (void)length;
    return false;  /* Stub */
}
