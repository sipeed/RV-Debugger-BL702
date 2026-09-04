#include "hal_usb.h"
#include "usbd_core.h"
#include "usbd_ftdi.h"
#include "ring_buffer.h"
#include "hal_gpio.h"
#include "hal_spi.h"
#include "bl702_glb.h"
#include "bl702_gpio.h"
#include "io_cfg.h"

#ifndef MPSSE_SPI_HW
#define MPSSE_SPI_HW 0
#endif

/* Gowin's embedded-flash erase is encoded as 18,750 zero bytes at 1 MHz.
 * Emit the requested 150,000 TCK pulses as one uninterrupted transaction;
 * processing the bytes separately inserts USB scheduling gaps and the FPGA
 * does not accept the erase sequence. */
#define MPSSE_LONG_CLOCK_MIN_BYTES 8000
#define MPSSE_GOWIN_ERASE_CLOCKS 150000
#define MPSSE_GOWIN_ERASE_HALF_NOPS 2

/* Gowin splits every embedded-flash DR32 into 0x11 (24 bits),
 * 0x13 (7 bits), and 0x4b (the final TDI bit while leaving Shift-DR).
 * Buffer that exact sequence and emit the 32 clocks as one uninterrupted
 * GPIO transaction.  This preserves negative-edge MPSSE semantics across
 * command boundaries without changing openFPGALoader's LSB path. */
#ifndef MPSSE_GOWIN_PROGRAM_DR32_COALESCE
#define MPSSE_GOWIN_PROGRAM_DR32_COALESCE 1
#endif

/* Execute every complete USB OUT payload in one critical section.  This is
 * required for FTDI-compatible negative-edge streams: a USB packet boundary
 * must not become an extra JTAG idle interval. */
#ifndef MPSSE_PROCESS_PACKET_CONTIGUOUS
#define MPSSE_PROCESS_PACKET_CONTIGUOUS 1
#endif

/* Gowin's WINUSB backend submits one complete 1754-byte embedded-flash page
 * as a single bulk transfer.  Accumulate only transfers carrying the known
 * page header, then execute the whole transfer without 64-byte USB packet
 * gaps.  Other MPSSE traffic keeps the ordinary low-latency path. */
#ifndef MPSSE_GOWIN_PROGRAM_TRANSFER_BATCH
#define MPSSE_GOWIN_PROGRAM_TRANSFER_BATCH 1
#endif

#ifndef MPSSE_GOWIN_PROGRAM_HALF_NOPS
#define MPSSE_GOWIN_PROGRAM_HALF_NOPS 2
#endif

#define MPSSE_GOWIN_PROGRAM_EDGE_DELAY() do { \
    for (volatile uint32_t edge_delay = 0; \
         edge_delay < MPSSE_GOWIN_PROGRAM_HALF_NOPS; edge_delay++) { \
        __asm volatile("nop" ::: "memory"); \
    } \
} while (0)

/* GPIO access itself provides the ordinary shift pacing. */
#define MPSSE_DELAY_LOW()  do { } while (0)
#define MPSSE_DELAY_HIGH() do { } while (0)
#define MPSSE_MSB_DATA_SETUP_DELAY() do { } while (0)

#define TMS_HIGH ((*(volatile uint32_t *)0x40000188) |= (1 << TMS_PIN))
#define TMS_LOW  ((*(volatile uint32_t *)0x40000188) &= (~(1 << TMS_PIN)))
#define TDI_HIGH ((*(volatile uint32_t *)0x40000188) |= (1 << TDI_PIN))
#define TDI_LOW  ((*(volatile uint32_t *)0x40000188) &= (~(1 << TDI_PIN)))
#define TCK_HIGH ((*(volatile uint32_t *)0x40000188) |= (1 << TCK_PIN))
#define TCK_LOW  ((*(volatile uint32_t *)0x40000188) &= (~(1 << TCK_PIN)))
#define TDO      ((*(volatile uint32_t *)0x40000180) & (1 << TDO_PIN))

#define SCK_HIGH  TCK_HIGH
#define SCK_LOW   TCK_LOW
#define MOSI_HIGH TDI_HIGH
#define MOSI_LOW  TDI_LOW
#define MISO      TDO

#define MPSSE_IDLE              0
#define MPSSE_RCV_LENGTH_L      1
#define MPSSE_RCV_LENGTH_H      2
#define MPSSE_TRANSMIT_BYTE     3
#define MPSSE_RCV_LENGTH        4
#define MPSSE_TRANSMIT_BIT      5
#define MPSSE_ERROR             6
#define MPSSE_TRANSMIT_BIT_MSB  7
#define MPSSE_TMS_OUT           8
#define MPSSE_NO_OP_1           9
#define MPSSE_NO_OP_2           10
#define MPSSE_TRANSMIT_BYTE_MSB 11

#define JTAG_TX_BUFFER_SIZE (1 * 1024)
#define JTAG_RX_BUFFER_SIZE (4 * 1024)
#define JTAG_USB_MAX_PACKET_SIZE (64)

uint8_t jtag_tx_buffer[JTAG_TX_BUFFER_SIZE] __attribute__((section(".tcm_data")));
Ring_Buffer_Type jtag_tx_rb;

uint8_t jtag_rx_buffer[JTAG_RX_BUFFER_SIZE] __attribute__((section(".tcm_data")));
static volatile uint32_t jtag_rx_len = 0;
static volatile uint32_t jtag_rx_pos __attribute__((section(".tcm_data")));

#if MPSSE_GOWIN_PROGRAM_TRANSFER_BATCH
static volatile bool mpsse_gowin_rx_collecting __attribute__((section(".tcm_data"))) = false;
static volatile bool mpsse_gowin_rx_ready __attribute__((section(".tcm_data"))) = false;
static volatile bool mpsse_gowin_rx_processing __attribute__((section(".tcm_data"))) = false;
#endif

static uint32_t mpsse_longlen __attribute__((section(".tcm_data"))) = 0;
static uint32_t mpsse_longlen_initial __attribute__((section(".tcm_data"))) = 0;
static bool mpsse_long_clock_candidate __attribute__((section(".tcm_data"))) = false;
static bool mpsse_long_clock_suppress __attribute__((section(".tcm_data"))) = false;
static uint32_t mpsse_shortlen __attribute__((section(".tcm_data"))) = 0;
static uint32_t mpsse_shortlen_initial __attribute__((section(".tcm_data"))) = 0;
static uint32_t mpsse_status __attribute__((section(".tcm_data"))) = MPSSE_IDLE;
static uint32_t jtag_cmd __attribute__((section(".tcm_data"))) = 0;
#if MPSSE_GOWIN_PROGRAM_DR32_COALESCE
static bool mpsse_gowin_ir_pending __attribute__((section(".tcm_data"))) = false;
static uint8_t mpsse_gowin_ir_low7 __attribute__((section(".tcm_data"))) = 0;
static bool mpsse_gowin_program_active __attribute__((section(".tcm_data"))) = false;
static uint8_t mpsse_gowin_program_word[4] __attribute__((section(".tcm_data")));
static uint8_t mpsse_gowin_program_word_stage __attribute__((section(".tcm_data"))) = 0;
#endif

static volatile uint32_t jtag_received_flag __attribute__((section(".tcm_data"))) = false;

extern struct device *usb_fs;

static void rb_lock(void)
{
    //disable_irq(); //no need disable irq as it is already disable in big loop
}

static void rb_unlock(void)
{
    //enable_irq();
}

static void jtag_write(uint8_t data)
{
    Ring_Buffer_Write_Byte(&jtag_tx_rb, data);
}

void jtag_ringbuffer_init(void)
{
    memset(jtag_tx_buffer, 0, JTAG_TX_BUFFER_SIZE);
    /* init ring_buffer */
    Ring_Buffer_Init(&jtag_tx_rb, jtag_tx_buffer, JTAG_TX_BUFFER_SIZE, rb_lock, rb_unlock);
}

void jtag_mpsse_reset(void)
{
    Ring_Buffer_Reset(&jtag_tx_rb);
    jtag_rx_len = 0;
    jtag_rx_pos = 0;
    jtag_received_flag = false;
#if MPSSE_GOWIN_PROGRAM_TRANSFER_BATCH
    mpsse_gowin_rx_collecting = false;
    mpsse_gowin_rx_ready = false;
    mpsse_gowin_rx_processing = false;
#endif
    mpsse_longlen = 0;
    mpsse_longlen_initial = 0;
    mpsse_long_clock_candidate = false;
    mpsse_long_clock_suppress = false;
    mpsse_shortlen = 0;
    mpsse_shortlen_initial = 0;
    mpsse_status = MPSSE_IDLE;
    jtag_cmd = 0;
#if MPSSE_GOWIN_PROGRAM_DR32_COALESCE
    mpsse_gowin_ir_pending = false;
    mpsse_gowin_ir_low7 = 0;
    mpsse_gowin_program_active = false;
    memset(mpsse_gowin_program_word, 0, sizeof(mpsse_gowin_program_word));
    mpsse_gowin_program_word_stage = 0;
#endif
}

#if MPSSE_GOWIN_PROGRAM_DR32_COALESCE
static inline __attribute__((always_inline)) void
mpsse_gowin_clock_program_dr32(volatile uint32_t *pio, uint8_t tail)
{
    const uint32_t jtag_mask =
        (1U << TCK_PIN) | (1U << TMS_PIN) | (1U << TDI_PIN);
    uint32_t output_base = pio[2] & ~jtag_mask;
    uint32_t output_low = output_base;

    /* The first bit is established while TCK is already low.  For every
     * later bit, the output_low write is simultaneously the falling edge and
     * the next data update, matching FTDI's negative-edge output semantics. */
    for (uint32_t bit_index = 0; bit_index < 32; bit_index++) {
        uint8_t tdi;
        if (bit_index < 24) {
            uint32_t byte_index = bit_index >> 3;
            uint32_t bit_in_byte = 7U - (bit_index & 7U);
            tdi = (mpsse_gowin_program_word[byte_index] >> bit_in_byte) & 1U;
        } else if (bit_index < 31) {
            tdi = (mpsse_gowin_program_word[3] >> (31U - bit_index)) & 1U;
        } else {
            tdi = (tail >> 7) & 1U;
        }

        output_low = output_base;
        if (tdi) {
            output_low |= 1U << TDI_PIN;
        }
        if (bit_index == 31 && (tail & 1U)) {
            output_low |= 1U << TMS_PIN;
        }

        pio[2] = output_low;
        MPSSE_GOWIN_PROGRAM_EDGE_DELAY();
        pio[2] = output_low | (1U << TCK_PIN);
        MPSSE_GOWIN_PROGRAM_EDGE_DELAY();
    }
    pio[2] = output_low;
}

#endif

static bool mpsse_long_clock_byte(uint8_t data)
{
    if (mpsse_long_clock_suppress) {
        /* The full stream was clocked contiguously when its first byte arrived. */
        return true;
    }
    if (!mpsse_long_clock_candidate) {
        return false;
    }
    /* Do not classify normal configuration data as a dummy clock stream. */
    if (data != 0) {
        mpsse_long_clock_candidate = false;
        return false;
    }

    mpsse_long_clock_candidate = false;
    mpsse_long_clock_suppress = true;
    TMS_LOW;
    /* Gowin's 0x19 stream carries zero data, so keep TDI low while idling. */
    TDI_LOW;
    for (uint32_t bit = 0; bit < MPSSE_GOWIN_ERASE_CLOCKS; bit++) {
        TCK_LOW;
        for (volatile uint32_t delay = 0;
             delay < MPSSE_GOWIN_ERASE_HALF_NOPS; delay++) {
            __asm volatile("nop" ::: "memory");
        }
        TCK_HIGH;
        for (volatile uint32_t delay = 0;
             delay < MPSSE_GOWIN_ERASE_HALF_NOPS; delay++) {
            __asm volatile("nop" ::: "memory");
        }
    }
    TCK_LOW;
    return true;
}

void jtag_gpio_init(void)
{
    gpio_set_mode(TMS_PIN, GPIO_OUTPUT_MODE);
    gpio_set_mode(TDI_PIN, GPIO_OUTPUT_MODE);
    gpio_set_mode(TCK_PIN, GPIO_OUTPUT_MODE);
    gpio_set_mode(TDO_PIN, GPIO_INPUT_MODE);

    TMS_LOW;
    TDI_LOW;
    TCK_LOW;
}

#if MPSSE_SPI_HW
static struct device *jtag_spi;

#define SPI_BASE_ADDR   ((uint32_t)0x4000A200)
#define SPI_MSB_FIRST() ((*(volatile uint32_t *)SPI_BASE_ADDR) &= (~(1 << 6)))
#define SPI_LSB_FIRST() ((*(volatile uint32_t *)SPI_BASE_ADDR) |= (1 << 6))

static inline void spi_on(void)
{
    /**gpio spi func*/
    uint32_t temp_val = BL_RD_WORD(0x40000100);
    temp_val = (temp_val & (~(31 << 8))) | (4 << 8);
    BL_WR_WORD(0x40000100, temp_val);
    /**spi enable*/
    (*(volatile uint32_t *)SPI_BASE_ADDR) |= (1 << 0);
}
static inline void spi_on(void)
{
    /**gpio spi func*/
    uint32_t temp_val = BL_RD_WORD(0x40000100 + TCK_PIN / 2 * 4);
    temp_val = (temp_val & (~(31 << 8))) | (4 << 8);
    BL_WR_WORD(0x40000100, temp_val);
    uint32_t temp_val = BL_RD_WORD(0x40000100 + TDO_PIN / 2 * 4);
    temp_val = (temp_val & (~(31 << 8))) | (4 << 8);
    BL_WR_WORD(0x40000100, temp_val);
    uint32_t temp_val = BL_RD_WORD(0x40000100 + TDI_PIN / 2 * 4);
    temp_val = (temp_val & (~(31 << 8))) | (4 << 8);
    BL_WR_WORD(0x40000100, temp_val);
    /**spi enable*/
    (*(volatile uint32_t *)SPI_BASE_ADDR) |= (1 << 0);
}
static inline void spi_off(void)
{
    /**spi disable*/
    (*(volatile uint32_t *)SPI_BASE_ADDR) &= (~(1 << 0));
    /**gpio func*/
    uint32_t temp_val = BL_RD_WORD(0x40000100 + TCK_PIN / 2 * 4);
    temp_val = (temp_val & (~(31 << 8))) | (11 << 8);
    BL_WR_WORD(0x40000100, temp_val);
    uint32_t temp_val = BL_RD_WORD(0x40000100 + TDO_PIN / 2 * 4);
    temp_val = (temp_val & (~(31 << 8))) | (11 << 8);
    BL_WR_WORD(0x40000100, temp_val);
    uint32_t temp_val = BL_RD_WORD(0x40000100 + TDI_PIN / 2 * 4);
    temp_val = (temp_val & (~(31 << 8))) | (11 << 8);
    BL_WR_WORD(0x40000100, temp_val);
}
void jtag_spi_init(void)
{
    spi_register(SPI0_INDEX, "jtag_spi", DEVICE_OFLAG_RDWR);
    jtag_spi = device_find("jtag_spi");

    if (jtag_spi) {
        device_open(jtag_spi, DEVICE_OFLAG_STREAM_TX | DEVICE_OFLAG_STREAM_RX);
    }

    /*rx ignore disable*/
    (*(volatile uint32_t *)0x4000A200) &= (~(1 << 8));
}

#endif

void usbd_cdc_jtag_out(uint8_t ep)
{
    uint32_t chunk;

#if MPSSE_GOWIN_PROGRAM_TRANSFER_BATCH
    if (!mpsse_gowin_rx_processing && !mpsse_gowin_rx_ready &&
        (!jtag_received_flag || mpsse_gowin_rx_collecting)) {
        uint32_t offset = mpsse_gowin_rx_collecting ? jtag_rx_len : 0;

        if (offset > JTAG_RX_BUFFER_SIZE - JTAG_USB_MAX_PACKET_SIZE) {
            mpsse_gowin_rx_collecting = false;
            mpsse_gowin_rx_ready = true;
            return;
        }

        usbd_ep_read(ep, jtag_rx_buffer + offset,
                     JTAG_USB_MAX_PACKET_SIZE, &chunk);
        if (chunk == 0) {
            return;
        }

        jtag_rx_len = offset + chunk;
        jtag_rx_pos = 0;
        jtag_received_flag = true;

        if (!mpsse_gowin_rx_collecting) {
            static const uint8_t page_header[] = {
                0x4b, 0x03, 0x03, 0x1b, 0x06, 0x71
            };
            uint32_t search_limit = jtag_rx_len;
            if (search_limit > 32) {
                search_limit = 32;
            }
            for (uint32_t pos = 0;
                 pos + sizeof(page_header) <= search_limit; pos++) {
                if (memcmp(jtag_rx_buffer + pos, page_header,
                           sizeof(page_header)) == 0) {
                    mpsse_gowin_rx_collecting = true;
                    break;
                }
            }
        }

        if (mpsse_gowin_rx_collecting) {
            if (chunk < JTAG_USB_MAX_PACKET_SIZE) {
                mpsse_gowin_rx_collecting = false;
                mpsse_gowin_rx_ready = true;
            } else {
                usbd_ep_read(ep, NULL, 0, NULL);
            }
        }
        return;
    }
#else
    if (!jtag_received_flag) {
        usbd_ep_read(ep, jtag_rx_buffer, JTAG_USB_MAX_PACKET_SIZE, &chunk);

        if (chunk == 0) {
            //MSG("111\r\n");
            return;
        }

        jtag_rx_len = chunk;
        // MSG("r:%d\r\n", jtag_rx_len);

        // bflb_platform_dump(jtag_rx_buffer, jtag_rx_len);
        jtag_rx_pos = 0;
        jtag_received_flag = true;
    }
#endif
}

extern uint16_t usb_dc_ftdi_send_from_ringbuffer(struct device *dev, Ring_Buffer_Type *rb, uint8_t ep);
void usbd_cdc_jtag_in(uint8_t ep)
{
    if (!jtag_received_flag) {
        usb_dc_ftdi_send_from_ringbuffer(usb_fs, &jtag_tx_rb, ep);
    }
}

ATTR_CLOCK_SECTION void jtag_process(void)
{
    uint32_t usb_tx_data = 0;
    uint32_t data = 0;
    bool suppress_gpio = false;
    volatile uint32_t *pio = (volatile uint32_t *)0x40000180;

    if (!jtag_received_flag) {
        return;
    }
#if MPSSE_GOWIN_PROGRAM_TRANSFER_BATCH
    if (mpsse_gowin_rx_collecting) {
        return;
    }
    mpsse_gowin_rx_processing = true;
#endif

    cpu_global_irq_disable();
    //if (jtag_received_flag)
    {
process_next_mpsse_byte:
        switch (mpsse_status) {
            case MPSSE_IDLE:
                jtag_cmd = jtag_rx_buffer[jtag_rx_pos];

                //MSG("cmd:0x%02x\r\n",jtag_cmd);

                switch (jtag_cmd) {
                    case 0x80:
                    case 0x82: /* 假Bit bang模式 */
                        mpsse_status = MPSSE_NO_OP_1;
                        jtag_rx_pos++;
                        break;

                    case 0x81:
                    case 0x83: /* 假状态 */
                        usb_tx_data = jtag_rx_buffer[jtag_rx_pos] - 0x80;
                        jtag_write(usb_tx_data);
                        jtag_rx_pos++;
                        break;

                    case 0x84:
                    case 0x85: /* Loopback */
                        jtag_rx_pos++;
                        break;

                    case 0x8a: /* Disable clock divide by 5 */
                    case 0x8b: /* Enable clock divide by 5 */
                    case 0x8c: /* Enable 3-phase clocking */
                    case 0x8d: /* Disable 3-phase clocking */
                    case 0x96: /* Enable adaptive clocking */
                    case 0x97: /* Disable adaptive clocking */
                        /*
                         * These FT2232H setup commands do not return data.
                         * Treating them as invalid leaves FA+opcode bytes in
                         * the IN FIFO and shifts the following JTAG response.
                         */
                        jtag_rx_pos++;
                        break;

                    case 0x86: /* 调速，暂时不支持 */
                        mpsse_status = MPSSE_NO_OP_1;
                        jtag_rx_pos++;
                        break;

                    case 0x87: /* 立刻刷新缓冲 */
                        jtag_rx_pos++;
                        break;

                    case 0x19:
                    case 0x1d:
                    case 0x39:
                    case 0x3d:
                    case 0x11:
                    case 0x15:
                    case 0x31:
                    case 0x35:
#if MPSSE_SPI_HW
                        spi_on();
#endif
                        mpsse_status = MPSSE_RCV_LENGTH_L;
                        jtag_rx_pos++;
                        break;

                    case 0x6b:
                    case 0x6f:
                    case 0x4b:
                    case 0x4f:
                    case 0x3b:
                    case 0x3f:
                    case 0x1b:
                    case 0x1f:
                    case 0x13:
                    case 0x17:
#if MPSSE_SPI_HW
                        spi_off();
#endif
                        mpsse_status = MPSSE_RCV_LENGTH;
                        jtag_rx_pos++;
                        break;

                    default:
                        usb_tx_data = 0xFA;
                        jtag_write(usb_tx_data);
                        mpsse_status = MPSSE_ERROR;
                        break;
                }

                break;

            case MPSSE_RCV_LENGTH_L: /* 接收长度 */
                mpsse_longlen = jtag_rx_buffer[jtag_rx_pos];

                mpsse_status = MPSSE_RCV_LENGTH_H;
                jtag_rx_pos++;
                break;

            case MPSSE_RCV_LENGTH_H:
                mpsse_longlen |= (jtag_rx_buffer[jtag_rx_pos] << 8) & 0xff00;
                mpsse_longlen_initial = mpsse_longlen + 1;
                mpsse_long_clock_candidate =
                    ((jtag_cmd & 0x20) == 0) &&
                    (mpsse_longlen_initial >= MPSSE_LONG_CLOCK_MIN_BYTES);
                mpsse_long_clock_suppress = false;

                jtag_rx_pos++;
                if (jtag_cmd == 0x11 || jtag_cmd == 0x31 || jtag_cmd == 0x15 || jtag_cmd == 0x35)
                {
                    mpsse_status = MPSSE_TRANSMIT_BYTE_MSB;
#if MPSSE_SPI_HW
                    SPI_MSB_FIRST();
#endif
                } else {
                    mpsse_status = MPSSE_TRANSMIT_BYTE;
#if MPSSE_SPI_HW
                    SPI_LSB_FIRST();
#endif
                }

                break;

            case MPSSE_TRANSMIT_BYTE:
                // __asm volatile("nop" ::: "memory");
                data = jtag_rx_buffer[jtag_rx_pos];
                if (mpsse_long_clock_byte(data)) {
                    usb_tx_data = 0;
                    if (mpsse_longlen == 0) {
                        mpsse_long_clock_suppress = false;
                    }
                    mpsse_status = (mpsse_longlen == 0) ? MPSSE_IDLE : MPSSE_TRANSMIT_BYTE;
                    mpsse_longlen--;
                    jtag_rx_pos++;
                    break;
                }
#if MPSSE_SPI_HW
                usb_tx_data = spi_write_read(data);
#else
                usb_tx_data = 0;

                for (uint32_t i = 8; i; i--) {
                    //SCK_LOW;
                    pio[2] &= ~(1 << TCK_PIN);

                    MPSSE_DELAY_LOW();

                    if (data & 0x01) {
                        //MOSI_HIGH;
                        pio[2] |= (1 << TDI_PIN);
                    } else {
                        //MOSI_LOW;
                        pio[2] &= ~(1 << TDI_PIN);
                    }

                    data >>= 1;
                    usb_tx_data >>= 1;

                    pio[2] |= (1 << TCK_PIN);
                    MPSSE_DELAY_HIGH();
                    //SCK_HIGH;
                    //if (MISO)
                    if (pio[0] & (1 << TDO_PIN)) {
                        usb_tx_data |= 0x80;
                    }
                }

                //SCK_LOW;
                pio[2] &= ~(1 << TCK_PIN);
#endif

                if (jtag_cmd == 0x39 || jtag_cmd == 0x3d) {
                    jtag_write(usb_tx_data);
                }

                if (mpsse_longlen == 0) {
                    mpsse_status = MPSSE_IDLE;
                }

                mpsse_longlen--;
                jtag_rx_pos++;
                // __asm volatile("nop" ::: "memory");
                break;

            case MPSSE_TRANSMIT_BYTE_MSB:
                data = jtag_rx_buffer[jtag_rx_pos];
#if MPSSE_GOWIN_PROGRAM_DR32_COALESCE
                if (mpsse_gowin_program_active && jtag_cmd == 0x11 &&
                    mpsse_longlen_initial == 3) {
                    uint32_t byte_index =
                        mpsse_longlen_initial - (mpsse_longlen + 1U);
                    if (byte_index < 3 &&
                        mpsse_gowin_program_word_stage == byte_index) {
                        mpsse_gowin_program_word[byte_index] = data;
                        mpsse_gowin_program_word_stage++;
                        suppress_gpio = true;
                    } else {
                        mpsse_gowin_program_active = false;
                        mpsse_gowin_program_word_stage = 0;
                    }
                }
#endif
                if (mpsse_long_clock_byte(data)) {
                    usb_tx_data = 0;
                    if (mpsse_longlen == 0) {
                        mpsse_long_clock_suppress = false;
                    }
                    mpsse_status = (mpsse_longlen == 0) ? MPSSE_IDLE : MPSSE_TRANSMIT_BYTE_MSB;
                    jtag_rx_pos++;
                    mpsse_longlen--;
                    break;
                }

                usb_tx_data = 0;
                if (!suppress_gpio) {
#if MPSSE_SPI_HW
                    usb_tx_data = spi_write_read(data);
#else
                    for (uint32_t i = 8; i; i--) {
                    //SCK_LOW;
                        pio[2] &= ~(1 << TCK_PIN);

                        MPSSE_DELAY_LOW();

                        if (data & 0x80) {
                        //MOSI_HIGH;
                            pio[2] |= (1 << TDI_PIN);
                        } else {
                        //MOSI_LOW;
                            pio[2] &= ~(1 << TDI_PIN);
                        }

                        MPSSE_MSB_DATA_SETUP_DELAY();

                        data <<= 1;
                        usb_tx_data <<= 1;
                    //SCK_HIGH;
                        pio[2] |= (1 << TCK_PIN);
                        MPSSE_DELAY_HIGH();
                    //if (TDO)
                        if (pio[0] & (1 << TDO_PIN)) {
                            usb_tx_data |= 0x01;
                        }
                    }

                    //SCK_LOW;
                    pio[2] &= ~(1 << TCK_PIN);
#endif
                }

                if (jtag_cmd == 0x31 || jtag_cmd == 0x35) {
                    jtag_write(usb_tx_data);
                }

                if (mpsse_longlen == 0) {
                    mpsse_status = MPSSE_IDLE;
                }

                jtag_rx_pos++;
                mpsse_longlen--;
                break;

            case MPSSE_RCV_LENGTH:
                mpsse_shortlen = jtag_rx_buffer[jtag_rx_pos];
                mpsse_shortlen_initial = mpsse_shortlen + 1;

                if (jtag_cmd == 0x6b || jtag_cmd == 0x4b || jtag_cmd == 0x6f || jtag_cmd == 0x4f) {
                    mpsse_status = MPSSE_TMS_OUT;
                } else if (jtag_cmd == 0x13 || jtag_cmd == 0x17) {
                    mpsse_status = MPSSE_TRANSMIT_BIT_MSB;
                } else {
                    mpsse_status = MPSSE_TRANSMIT_BIT;
                }

                jtag_rx_pos++;
                break;

            case MPSSE_TRANSMIT_BIT:
                data = jtag_rx_buffer[jtag_rx_pos];
#if MPSSE_GOWIN_PROGRAM_DR32_COALESCE
                /* Gowin shifts the low seven IR bits with 0x1b, then supplies
                 * the eighth bit through the following TMS command's bit 7. */
                if (jtag_cmd == 0x1b && mpsse_shortlen_initial == 7) {
                    mpsse_gowin_ir_low7 = data & 0x7fU;
                    mpsse_gowin_ir_pending = true;
                }
#endif

                usb_tx_data = 0;

                do {
                    //SCK_LOW;
                    pio[2] &= ~(1 << TCK_PIN);

                    MPSSE_DELAY_LOW();

                    if (data & 0x01) {
                        //MOSI_HIGH;
                        pio[2] |= (1 << TDI_PIN);
                    } else {
                        //MOSI_LOW;
                        pio[2] &= ~(1 << TDI_PIN);
                    }

                    data >>= 1;
                    usb_tx_data >>= 1;

                    //SCK_HIGH;
                    pio[2] |= (1 << TCK_PIN);

                    MPSSE_DELAY_HIGH();

                    // if (TDO) {
                    if (pio[0] & (1 << TDO_PIN)) {
                        usb_tx_data |= 0x80;
                    }
                } while ((mpsse_shortlen--) > 0);

                //SCK_LOW;
                pio[2] &= ~(1 << TCK_PIN);

                if (jtag_cmd == 0x3b || jtag_cmd == 0x3f) {
                    jtag_write(usb_tx_data);
                }

                mpsse_status = MPSSE_IDLE;
                jtag_rx_pos++;
                break;

            case MPSSE_TRANSMIT_BIT_MSB:
                data = jtag_rx_buffer[jtag_rx_pos];
#if MPSSE_GOWIN_PROGRAM_DR32_COALESCE
                if (mpsse_gowin_program_active && jtag_cmd == 0x13 &&
                    mpsse_shortlen_initial == 7) {
                    if (mpsse_gowin_program_word_stage == 3) {
                        mpsse_gowin_program_word[3] = data;
                        mpsse_gowin_program_word_stage = 4;
                        suppress_gpio = true;
                    } else {
                        mpsse_gowin_program_active = false;
                        mpsse_gowin_program_word_stage = 0;
                    }
                }
#endif

                if (!suppress_gpio) {
                    do {
                    //SCK_LOW;
                        pio[2] &= ~(1 << TCK_PIN);

                        MPSSE_DELAY_LOW();

                        if (data & 0x80) {
                        //MOSI_HIGH;
                            pio[2] |= (1 << TDI_PIN);
                        } else {
                        //MOSI_LOW;
                            pio[2] &= ~(1 << TDI_PIN);
                        }

                        MPSSE_MSB_DATA_SETUP_DELAY();

                        data <<= 1;
                    //SCK_HIGH;
                        pio[2] |= (1 << TCK_PIN);
                        MPSSE_DELAY_HIGH();
                    } while ((mpsse_shortlen--) > 0);

                    //SCK_LOW;
                    pio[2] &= ~(1 << TCK_PIN);
                }

                mpsse_status = MPSSE_IDLE;
                jtag_rx_pos++;
                break;

            case MPSSE_ERROR:
                usb_tx_data = jtag_rx_buffer[jtag_rx_pos];
                jtag_write(usb_tx_data);
                mpsse_status = MPSSE_IDLE;
                jtag_rx_pos++;

                break;

            case MPSSE_TMS_OUT:
                //__asm volatile ("nop":::"memory");
                data = jtag_rx_buffer[jtag_rx_pos];
#if MPSSE_GOWIN_PROGRAM_DR32_COALESCE
                if (mpsse_gowin_ir_pending) {
                    if (mpsse_shortlen_initial == 1) {
                        uint8_t instruction =
                            mpsse_gowin_ir_low7 | (data & 0x80U);
                        /* A new programming session starts at a clean word. */
                        mpsse_gowin_program_active = (instruction == 0x71U);
                        mpsse_gowin_program_word_stage = 0;
                    }
                    mpsse_gowin_ir_pending = false;
                }

                if (mpsse_gowin_program_active && jtag_cmd == 0x4b &&
                    mpsse_shortlen_initial == 1 &&
                    mpsse_gowin_program_word_stage == 4) {
                    mpsse_gowin_clock_program_dr32(pio, data);
                    mpsse_gowin_program_word_stage = 0;
                    mpsse_status = MPSSE_IDLE;
                    jtag_rx_pos++;
                    break;
                }
#endif
                if (data & 0x80) {
                    //TDI_HIGH;
                    pio[2] |= 1 << TDI_PIN;
                } else {
                    //TDI_LOW;
                    pio[2] &= ~(1 << TDI_PIN);
                }

                usb_tx_data = 0;

                do {
                    TCK_LOW;
                    pio[2] &= ~(1 << TCK_PIN);

                    MPSSE_DELAY_LOW();

                    if (data & 0x01) {
                        //TMS_HIGH;
                        pio[2] |= (1 << TMS_PIN);
                    } else {
                        //TMS_LOW;
                        pio[2] &= ~(1 << TMS_PIN);
                    }

                    data >>= 1;
                    usb_tx_data >>= 1;

                    //TCK_HIGH;
                    pio[2] |= (1 << TCK_PIN);

                    MPSSE_DELAY_HIGH();

                    // if (TDO) {
                    if (pio[0] & (1 << TDO_PIN)) {
                        usb_tx_data |= 0x80;
                    }
                } while ((mpsse_shortlen--) > 0);

                //TCK_LOW;
                pio[2] &= ~(1 << TCK_PIN);

                if (jtag_cmd == 0x6b || jtag_cmd == 0x6f) {
                    jtag_write(usb_tx_data);
                }

                mpsse_status = MPSSE_IDLE;
                jtag_rx_pos++;
                //__asm volatile ("nop":::"memory");
                break;

            case MPSSE_NO_OP_1:
                jtag_rx_pos++;
                mpsse_status = MPSSE_NO_OP_2;
                break;

            case MPSSE_NO_OP_2:
                mpsse_status = MPSSE_IDLE;
                jtag_rx_pos++;
                break;
            default:
                mpsse_status = MPSSE_IDLE;
                break;
        }

 #if MPSSE_PROCESS_PACKET_CONTIGUOUS
        if (jtag_rx_pos < jtag_rx_len) {
            goto process_next_mpsse_byte;
        }
 #endif
        if (jtag_rx_pos >= jtag_rx_len) {
            jtag_received_flag = false;
#if MPSSE_GOWIN_PROGRAM_TRANSFER_BATCH
            jtag_rx_len = 0;
            mpsse_gowin_rx_ready = false;
#endif
            usbd_ep_read(0x02, NULL, 0, NULL);
        }
    }
#if MPSSE_GOWIN_PROGRAM_TRANSFER_BATCH
    mpsse_gowin_rx_processing = false;
#endif
    cpu_global_irq_enable();
}
