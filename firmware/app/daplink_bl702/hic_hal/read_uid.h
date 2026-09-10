/**
 * @file    read_uid.h
 * @brief   Unique ID Reader Interface
 *
 * DAPLink Interface Firmware
 * Copyright (c) 2009-2016, ARM Limited, All Rights Reserved
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef READ_UID_H
#define READ_UID_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void read_unique_id(uint32_t *id);
void create_unique_id(void);
const char *read_unique_id_str(void);

#ifdef __cplusplus
}
#endif

#endif
