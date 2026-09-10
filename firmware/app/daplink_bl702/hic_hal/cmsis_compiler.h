/*
 * Copyright (c) 2024 CMSIS-DAP BL702 Port
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * RISC-V CMSIS Compiler Adapter
 *
 * Maps ARM CMSIS compiler-specific macros to RISC-V (GCC) equivalents.
 */

#ifndef __CMSIS_COMPILER_H__
#define __CMSIS_COMPILER_H__

#include <stdint.h>
#include <stddef.h>

/* === Inline macros === */
#ifndef __STATIC_INLINE
#define __STATIC_INLINE      static inline
#endif

#ifndef __STATIC_FORCEINLINE
#define __STATIC_FORCEINLINE static inline __attribute__((always_inline))
#endif

#ifndef __WEAK
#define __WEAK               __attribute__((weak))
#endif

/* === No Operation (NOP) === */
#ifndef __NOP
#define __NOP()              __asm__ volatile ("nop")
#endif

/* === Inline Assembly === */
#ifndef __ASM
#define __ASM                __asm__
#endif
#ifndef __ASM_VOLATILE
#define __ASM_VOLATILE       __asm__ volatile
#endif

/* === Packed attribute === */
#ifndef __PACKED
#define __PACKED             __attribute__((packed))
#endif

#ifndef __PACKED_STRUCT
#define __PACKED_STRUCT      struct __attribute__((packed))
#endif

/* === Unused parameter === */
#ifndef __UNUSED
#define __UNUSED(x)          (void)(x)
#endif

/* === No return === */
#ifndef __NO_RETURN
#define __NO_RETURN          __attribute__((noreturn))
#endif

/* === Section attribute === */
#ifndef __SECTION
#define __SECTION(x)         __attribute__((section(x)))
#endif

/* === Aligned attribute === */
#ifndef __ALIGNED
#define __ALIGNED(x)         __attribute__((aligned(x)))
#endif

/* === CLZ (Count Leading Zeros) === */
__STATIC_FORCEINLINE uint32_t __CLZ(uint32_t value) {
  if (value == 0U) return 32U;
  return (uint32_t)__builtin_clz(value);
}

#endif /* __CMSIS_COMPILER_H__ */
