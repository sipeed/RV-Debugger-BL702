/**
 * @file    read_uid.c
 * @brief   Unique ID Reader for BL702
 *
 * DAPLink Interface Firmware - BL702 Port
 * Reads the BL702 chip unique ID via EF_Ctrl.
 */

#include <stdint.h>
#include <string.h>
#include "read_uid.h"
#include "bl702_ef_ctrl.h"

static uint32_t g_unique_id[2] = { 0, 0 };
static char g_unique_id_str[17] = "";   /* 8 hex bytes + null */

void read_unique_id(uint32_t *id)
{
    uint8_t chip_id[8];
    EF_Ctrl_Read_Chip_ID(chip_id);

    /* Pack 8 bytes into 2 x 32-bit words */
    id[0] = ((uint32_t)chip_id[0] <<  0) |
            ((uint32_t)chip_id[1] <<  8) |
            ((uint32_t)chip_id[2] << 16) |
            ((uint32_t)chip_id[3] << 24);
    id[1] = ((uint32_t)chip_id[4] <<  0) |
            ((uint32_t)chip_id[5] <<  8) |
            ((uint32_t)chip_id[6] << 16) |
            ((uint32_t)chip_id[7] << 24);
}

void create_unique_id(void)
{
    static const char hex[] = "0123456789ABCDEF";
    uint8_t chip_id[8];
    int i;

    EF_Ctrl_Read_Chip_ID(chip_id);

    for (i = 0; i < 8; i++) {
        g_unique_id_str[i * 2 + 0] = hex[(chip_id[i] >> 4) & 0x0F];
        g_unique_id_str[i * 2 + 1] = hex[ chip_id[i]       & 0x0F];
    }
    g_unique_id_str[16] = '\0';
}

const char *read_unique_id_str(void)
{
    return g_unique_id_str;
}
