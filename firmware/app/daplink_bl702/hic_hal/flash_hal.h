/**
 * @file    flash_hal.h
 * @brief   Flash HAL Interface for DAPLink HIC HAL
 *
 * DAPLink Interface Firmware
 * Copyright (c) 2009-2020, ARM Limited, All Rights Reserved
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef FLASH_HAL_H
#define FLASH_HAL_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

uint32_t  flash_program_page(uint32_t adr, uint32_t sz, uint8_t *buf);
uint32_t  flash_erase_sector(uint32_t addr);
bool flash_is_readable(uint32_t addr, uint32_t length);

#ifdef __cplusplus
}
#endif

#endif
