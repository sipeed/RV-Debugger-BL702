/**
 * @file    gpio.h
 * @brief   GPIO Interface for DAPLink HIC HAL
 *
 * DAPLink Interface Firmware
 * Copyright (c) 2009-2019, ARM Limited, All Rights Reserved
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef GPIO_H
#define GPIO_H

#include <stdbool.h>
#include "IO_Config.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef enum led_state {
    GPIO_LED_OFF = 0,
    GPIO_LED_ON
} gpio_led_state_t;

void gpio_init(void);
void gpio_set_board_power(bool powerEnabled);
void gpio_set_hid_led(gpio_led_state_t state);
void gpio_set_cdc_led(gpio_led_state_t state);
void gpio_set_msc_led(gpio_led_state_t state);
uint8_t gpio_get_reset_btn_no_fwrd(void);
uint8_t gpio_get_reset_btn_fwrd(void);
#ifdef PBON_BUTTON
uint8_t gpio_get_pbon_btn(void);
#endif

static inline uint8_t gpio_get_reset_btn(void)
{
    return gpio_get_reset_btn_no_fwrd() || gpio_get_reset_btn_fwrd();
}

#ifdef __cplusplus
}
#endif

#endif
