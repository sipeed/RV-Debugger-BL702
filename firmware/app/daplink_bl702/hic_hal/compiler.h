/**
 * @file    compiler.h
 * @brief   Compiler Abstraction Macros (BL702 / RISC-V)
 *
 * DAPLink Interface Firmware - BL702 Port
 */

#ifndef COMPILER_H
#define COMPILER_H

/* Static assertion */
#define COMPILER_ASSERT(expr)   _Static_assert(expr, #expr)

#endif
