#include "hal_usb.h"
#include "usbd_core.h"
#include "usbd_ftdi.h"
#include "ring_buffer.h"
#include "hal_gpio.h"
#include "hal_spi.h"
#include "hal_pwm.h"
#include "bl702_glb.h"
#include "bl702_gpio.h"
#include "bl702_pwm.h"
#include "io_cfg.h"

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
#define MPSSE_RUN_TEST          12

#define JTAG_TX_BUFFER_SIZE (1 * 1024)
#define JTAG_RX_BUFFER_SIZE (64)

uint8_t jtag_tx_buffer[JTAG_TX_BUFFER_SIZE] __attribute__((section(".tcm_data")));
Ring_Buffer_Type jtag_tx_rb;

uint8_t jtag_rx_buffer[JTAG_RX_BUFFER_SIZE] __attribute__((section(".tcm_data")));
static uint32_t jtag_rx_len = 0;
static volatile uint32_t jtag_rx_pos __attribute__((section(".tcm_data")));

static uint32_t mpsse_longlen __attribute__((section(".tcm_data"))) = 0;
static uint32_t mpsse_shortlen __attribute__((section(".tcm_data"))) = 0;
static uint32_t mpsse_status __attribute__((section(".tcm_data"))) = MPSSE_IDLE;
static uint32_t jtag_cmd __attribute__((section(".tcm_data"))) = 0;

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
#if GOWIN_INT_FLASH_QUIRK
static void pwm_start(void)
{
    GLB_GPIO_Cfg_Type gpio_cfg;

    gpio_cfg.drive = 0;
    gpio_cfg.smtCtrl = 1;
    gpio_cfg.gpioMode = GPIO_MODE_AF;
    gpio_cfg.pullType = GPIO_PULL_DOWN;
    gpio_cfg.gpioFun = GPIO_FUN_PWM;
    gpio_cfg.gpioPin = GPIO_PIN_3;
    GLB_GPIO_Init(&gpio_cfg);
    PWM_Channel_Enable(3);
}
static void pwm_stop(void)
{
    PWM_Channel_Disable(3);

    GLB_GPIO_Cfg_Type gpio_cfg;
    gpio_cfg.drive = 0;
    gpio_cfg.smtCtrl = 1;
    gpio_cfg.gpioMode = GPIO_MODE_OUTPUT;
    gpio_cfg.pullType = GPIO_PULL_NONE;
    gpio_cfg.gpioFun = GPIO_FUN_GPIO;
    gpio_cfg.gpioPin = GPIO_PIN_3;
    GLB_GPIO_Init(&gpio_cfg);
}

void pwm_init(void)
{
    static PWM_CH_CFG_Type pwmCfg = {
        .ch = 3,
        .clk = PWM_CLK_BCLK,
        .stopMode = PWM_STOP_GRACEFUL,
        .pol = PWM_POL_NORMAL,
        .clkDiv = 1,
        .period = 28,
        .threshold1 = 0,
        .threshold2 = 14,
        .intPulseCnt = 0,
    };
    PWM_Channel_Init(&pwmCfg);
}
#endif
void jtag_gpio_init(void)
{
    gpio_set_mode(TMS_PIN, GPIO_OUTPUT_MODE);
    gpio_set_mode(TDI_PIN, GPIO_OUTPUT_MODE);
    gpio_set_mode(TCK_PIN, GPIO_OUTPUT_MODE);
    gpio_set_mode(TDO_PIN, GPIO_INPUT_MODE);

    TMS_LOW;
    TDI_LOW;
    TCK_LOW;
#if GOWIN_INT_FLASH_QUIRK
    pwm_init();
#endif
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

    if (!jtag_received_flag) {
        usbd_ep_read(ep, jtag_rx_buffer, 64, &chunk);

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
    register volatile uint32_t *pio __asm("tp") = (volatile uint32_t *)0x40000180;

    if (!jtag_received_flag) {
        return;
    }

    disable_irq();
    //if (jtag_received_flag)
    {
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

                jtag_rx_pos++;
#if GOWIN_INT_FLASH_QUIRK

                if ((mpsse_longlen >= 8000) && (jtag_cmd & (1 << 5)) == 0) {
                    //SPI_OFF();
                    //Run_Test_Start();
                    pwm_start();
                    MSG("len:%d\r\n", mpsse_longlen);
                    MSG("run test start\r\n");
                    mpsse_status = MPSSE_RUN_TEST;
                } else if (jtag_cmd == 0x11 || jtag_cmd == 0x31)
#else
                if (jtag_cmd == 0x11 || jtag_cmd == 0x31 || jtag_cmd == 0x15 || jtag_cmd == 0x35)
#endif
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
#if MPSSE_SPI_HW
                usb_tx_data = spi_write_read(data);
#else
                usb_tx_data = 0;

                for (uint32_t i = 8; i; i--) {
                    //SCK_LOW;
                    pio[2] &= ~(1 << TCK_PIN);

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

#if MPSSE_SPI_HW
                usb_tx_data = spi_write_read(data);
#else
                usb_tx_data = 0;

                for (uint32_t i = 8; i; i--) {
                    //SCK_LOW;
                    pio[2] &= ~(1 << TCK_PIN);

                    if (data & 0x80) {
                        //MOSI_HIGH;
                        pio[2] |= (1 << TDI_PIN);
                    } else {
                        //MOSI_LOW;
                        pio[2] &= ~(1 << TDI_PIN);
                    }

                    data <<= 1;
                    usb_tx_data <<= 1;
                    //SCK_HIGH;
                    pio[2] |= (1 << TCK_PIN);
                    //if (TDO)
                    if (pio[0] & (1 << TDO_PIN)) {
                        usb_tx_data |= 0x01;
                    }
                }

                //SCK_LOW;
                pio[2] &= ~(1 << TCK_PIN);
#endif

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

                usb_tx_data = 0;

                do {
                    //SCK_LOW;
                    pio[2] &= ~(1 << TCK_PIN);

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

                do {
                    //SCK_LOW;
                    pio[2] &= ~(1 << TCK_PIN);

                    if (data & 0x80) {
                        //MOSI_HIGH;
                        pio[2] |= (1 << TDI_PIN);
                    } else {
                        //MOSI_LOW;
                        pio[2] &= ~(1 << TDI_PIN);
                    }

                    data <<= 1;
                    //SCK_HIGH;
                    pio[2] |= (1 << TCK_PIN);
                } while ((mpsse_shortlen--) > 0);

                //SCK_LOW;
                pio[2] &= ~(1 << TCK_PIN);

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
#if GOWIN_INT_FLASH_QUIRK

            case MPSSE_RUN_TEST:
                if (mpsse_longlen == 0) {
                    mpsse_status = MPSSE_IDLE;
                    MSG("run test stop\r\n");

                    pwm_stop();
                }

                for (uint32_t i = 0; i < 50; i++) {
                    __asm volatile("nop");
                }

                jtag_rx_pos++;
                mpsse_longlen--;
                break;
#endif

            default:
                mpsse_status = MPSSE_IDLE;
                break;
        }

        if (jtag_rx_pos >= jtag_rx_len) {
            jtag_received_flag = false;
            usbd_ep_read(0x02, NULL, 0, NULL);
        }
    }
    enable_irq();
}
