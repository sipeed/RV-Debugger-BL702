# DAPLink Interface Firmware for BL702 (Minimal CMSIS-DAP Build)
# Phase 1-2: HIC HAL + CMSIS-DAP protocol core only

set(BSP_COMMON_DIR ${CMAKE_SOURCE_DIR}/bsp/bsp_common)

set(TARGET_REQUIRED_LIBS usb_stack)

set(TARGET_REQUIRED_PRIVATE_INCLUDE
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_LIST_DIR}/hic_hal
    ${CMAKE_CURRENT_LIST_DIR}/daplink
    ${CMAKE_CURRENT_LIST_DIR}/daplink/cmsis-dap
    ${CMAKE_CURRENT_LIST_DIR}/rtos_adapt
    ${CMAKE_CURRENT_LIST_DIR}/usb)

set(TARGET_REQUIRED_SRCS
    # BL702 USB Device Controller driver
    ${BSP_COMMON_DIR}/usb/usb_dc.c

    # HIC HAL implementation
    ${CMAKE_CURRENT_LIST_DIR}/hic_hal/gpio.c
    ${CMAKE_CURRENT_LIST_DIR}/hic_hal/uart.c
    ${CMAKE_CURRENT_LIST_DIR}/hic_hal/sdk.c
    ${CMAKE_CURRENT_LIST_DIR}/hic_hal/flash.c
    ${CMAKE_CURRENT_LIST_DIR}/hic_hal/read_uid.c

    # USB descriptor
    ${CMAKE_CURRENT_LIST_DIR}/usb/usb_descriptor.c

    # DAPLink CMSIS-DAP protocol core (self-contained, minimal dependencies)
    ${CMAKE_CURRENT_LIST_DIR}/daplink/cmsis-dap/DAP.c
    ${CMAKE_CURRENT_LIST_DIR}/daplink/cmsis-dap/SW_DP.c
    ${CMAKE_CURRENT_LIST_DIR}/daplink/cmsis-dap/JTAG_DP.c
    ${CMAKE_CURRENT_LIST_DIR}/daplink/cmsis-dap/DAP_vendor.c)

set(TARGET_REQUIRED_PRIVATE_OPTIONS
    -DDAPLINK_IF=1)

set(mains main.c)

generate_bin()
