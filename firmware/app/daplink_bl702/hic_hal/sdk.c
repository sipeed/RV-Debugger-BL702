/**
 * @file    sdk.c
 * @brief   BL702 SDK Initialization
 *
 * DAPLink Interface Firmware - BL702 Port
 */

#include "sdk.h"
#include "bl702_glb.h"
#include "bflb_platform.h"

void sdk_init(void)
{
    /* Select internal flash (required for BL702 boot) */
    GLB_Select_Internal_Flash();

    /* Initialize platform (clocks, UART for debug output) */
    bflb_platform_init(0);
}
