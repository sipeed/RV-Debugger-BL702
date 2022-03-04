#pragma once

#include "hal_uart.h"
#include "ring_buffer.h"


void uart_init(uint8_t index, void (*callback)(struct device *dev, void *args,
                                               uint32_t size, uint32_t event));
void uart_config(uint8_t index, uint32_t baudrate, uart_databits_t databits,
                 uart_parity_t parity, uart_stopbits_t stopbits);
void uart_set_dtr_rts(uint8_t index, uint8_t dtr, uint8_t rts);
void uart_dtr_init(uint8_t index);
void uart_rts_init(uint8_t index);
void uart_dtr_deinit(uint8_t index);
void uart_rts_deinit(uint8_t index);
void dtr_pin_set(uint8_t index, uint8_t status);
void rts_pin_set(uint8_t index, uint8_t status);
void uart_send_from_ringbuffer(uint8_t index, Ring_Buffer_Type *rb);