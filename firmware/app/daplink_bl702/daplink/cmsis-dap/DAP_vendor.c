/**
 * @file    DAP_vendor.c
 * @brief   CMSIS-DAP Vendor Commands Stub for BL702
 *
 * Minimal stub: vendor commands are not needed for basic CMSIS-DAP operation.
 */

#include "DAP.h"

__WEAK uint32_t DAP_ProcessVendorCommand(const uint8_t *request, uint8_t *response) {
    (void)request;
    *response = ID_DAP_Invalid;
    return ((1U << 16) | 1U);
}
