/**
 * @file    daplink_addr.h
 * @brief   DAPLink Address Definitions Stub for BL702
 *
 * Single-image build: no separate bootloader/interface regions.
 */

#ifndef DAPLINK_ADDR_H
#define DAPLINK_ADDR_H

#define DAPLINK_ROM_START               0x00000000
#define DAPLINK_ROM_SIZE                0x00080000
#define DAPLINK_ROM_IF_START            0x00000000
#define DAPLINK_ROM_IF_SIZE             0x00080000
#define DAPLINK_ROM_BL_START            0x00000000
#define DAPLINK_ROM_BL_SIZE             0

#define DAPLINK_ROM_CONFIG_USER_START   0
#define DAPLINK_ROM_CONFIG_USER_SIZE    0
#define DAPLINK_RAM_START               0x42000000
#define DAPLINK_RAM_SIZE                0x00020000
#define DAPLINK_RAM_APP_START           0x42000000
#define DAPLINK_RAM_APP_SIZE            0x00020000
#define DAPLINK_RAM_SHARED_START        0
#define DAPLINK_RAM_SHARED_SIZE         0
#define DAPLINK_AUTOMATION_ALL          0

#endif
