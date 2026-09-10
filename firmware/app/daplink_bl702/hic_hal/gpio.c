/**
 * @file    gpio.c
 * @brief   GPIO Driver for BL702 CMSIS-DAP Debug Probe
 *
 * DAPLink Interface Firmware - BL702 Port
 *
 * Implements the DAPLink HIC HAL gpio.h interface using BL702 HAL GPIO API.
 *
 * LED convention (following DAPLink):
 *   - HID LED  = CONNECTED_LED  (GPIO_9)  - on when debugger connected
 *   - CDC LED  = running status  (GPIO_17) - on when target running
 *   - MSC LED  = activity         (GPIO_9)  - flashes during MSC activity
 */

#include <stdbool.h>
#include "hal_gpio.h"
#include "IO_Config.h"
#include "gpio.h"
#include "compiler.h"

void gpio_init(void)
{
    /* Initialize LED pins as outputs, LEDs OFF (active-low: 1=OFF) */
    gpio_set_mode(CONNECTED_LED_PIN, GPIO_OUTPUT_MODE);
    gpio_write(CONNECTED_LED_PIN, 1);

    gpio_set_mode(RUNNING_LED_PIN, GPIO_OUTPUT_MODE);
    gpio_write(RUNNING_LED_PIN, 1);

    gpio_set_mode(MSC_LED_PIN, GPIO_OUTPUT_MODE);
    gpio_write(MSC_LED_PIN, 1);

    /* Initialize debug interface pins to Hi-Z (will be configured by DAP_Setup) */
    gpio_set_mode(SWCLK_TCK_PIN, GPIO_HZ_MODE);
    gpio_set_mode(SWDIO_TMS_PIN, GPIO_HZ_MODE);
    gpio_set_mode(TDI_PIN,       GPIO_HZ_MODE);
    gpio_set_mode(TDO_PIN,       GPIO_HZ_MODE);
    gpio_set_mode(NRESET_PIN,    GPIO_HZ_MODE);

#ifdef RESET_BTN_PIN
    gpio_set_mode(RESET_BTN_PIN, GPIO_INPUT_MODE);
#endif

#ifdef POWER_EN_PIN
    gpio_set_mode(POWER_EN_PIN, GPIO_OUTPUT_MODE);
    gpio_write(POWER_EN_PIN, 0);  /* Power off initially */
#endif
}

void gpio_set_board_power(bool powerEnabled)
{
#ifdef POWER_EN_PIN
    gpio_write(POWER_EN_PIN, powerEnabled ? 1 : 0);
#else
    (void)powerEnabled;
#endif
}

void gpio_set_hid_led(gpio_led_state_t state)
{
    /* Active-low: GPIO_LED_ON (1) → write 0; GPIO_LED_OFF (0) → write 1 */
    gpio_write(CONNECTED_LED_PIN, (state == GPIO_LED_ON) ? 0 : 1);
}

void gpio_set_cdc_led(gpio_led_state_t state)
{
    gpio_write(RUNNING_LED_PIN, (state == GPIO_LED_ON) ? 0 : 1);
}

void gpio_set_msc_led(gpio_led_state_t state)
{
    gpio_write(MSC_LED_PIN, (state == GPIO_LED_ON) ? 0 : 1);
}

uint8_t gpio_get_reset_btn_no_fwrd(void)
{
#ifdef RESET_BTN_PIN
    /* Active-low button: pressed = 0 */
    return (gpio_read(RESET_BTN_PIN) == 0) ? 1 : 0;
#else
    return 0;
#endif
}

uint8_t gpio_get_reset_btn_fwrd(void)
{
    /* Same as no_fwrd for simple probe (no separate forward pin) */
    return gpio_get_reset_btn_no_fwrd();
}
