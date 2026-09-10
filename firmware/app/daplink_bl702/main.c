/**
 * @file    main.c
 * @brief   DAPLink Interface Firmware for BL702
 *
 * Phase 2-5 entry point. Uses DAPLink HIC HAL and CMSIS-DAP core,
 * with BL702 native USB stack and bare-metal main loop.
 *
 * Based on the proven synchronous CMSIS-DAP architecture verified with OpenOCD.
 */

#include <stdint.h>
#include <stdbool.h>
#include "hal_usb.h"
#include "bl702_usb.h"
#include "usbd_core.h"
#include "usb_dc.h"
#include "sdk.h"
#include "gpio.h"
#include "DAP_config.h"
#include "DAP.h"
#include "rl_usb.h"

/* ========================================================================
 * CMSIS-DAP USB Endpoint Constants
 * ======================================================================== */
#define CMSIS_DAP_OUT_EP    0x02U   /* EP2 OUT */
#define CMSIS_DAP_IN_EP     0x81U   /* EP1 IN  */
#define DAP_PACKET_SIZE     64U     /* From DAP_config.h */
/* Ring buffer needs N+1 slots for SPSC full-detection (1 slot always empty).
 * DAP_PACKET_COUNT=4 means Keil may send up to 4 packets without waiting,
 * so we need 5 slots (4 usable).  With only 4 slots (3 usable) the 4th
 * consecutive TransferBlock during flash download is silently dropped,
 * the response never arrives, and Keil times out → "RDDI-DAP Error". */
#define REQ_BUF_COUNT       (DAP_PACKET_COUNT + 1U)

/* ========================================================================
 * USB Communication Buffers (lock-free single-producer single-consumer ring)
 *
 * DAP_PACKET_COUNT=4 means Keil may pipeline up to 4 packets. The ring
 * buffer absorbs bursts so packets are never dropped while the main loop
 * processes a previous command.
 *
 * Design: classic SPSC ring buffer using head/tail indices only (no shared
 * counter).  ISR (producer) advances head; main loop (consumer) advances tail.
 * Empty: head == tail.  Full: (head + 1) % N == tail (one slot always empty).
 * ======================================================================== */
static uint8_t  g_req_bufs[REQ_BUF_COUNT][DAP_PACKET_SIZE]; /* Request ring */
static uint8_t  g_resp_buf[DAP_PACKET_SIZE];                /* Response (single, synchronous send) */
static uint16_t g_resp_len;
static volatile uint8_t g_req_head = 0U;  /* ISR writes, main loop reads */
static          uint8_t g_req_tail = 0U;  /* Main loop writes, ISR reads  */
static volatile uint8_t g_in_done  = 0U;

/* ========================================================================
 * USB Class & Endpoints
 * ======================================================================== */
extern uint8_t usbd_descriptor[];

static usbd_class_t     dap_class;
static usbd_interface_t dap_intf;

/* Forward declarations */
void usbd_dap_out_cb(uint8_t ep);
void usbd_dap_in_cb(uint8_t ep);

static usbd_endpoint_t dap_out_ep = { .ep_addr = CMSIS_DAP_OUT_EP, .ep_cb = usbd_dap_out_cb };
static usbd_endpoint_t dap_in_ep  = { .ep_addr = CMSIS_DAP_IN_EP,  .ep_cb = usbd_dap_in_cb };

/* ========================================================================
 * USB Endpoint Callbacks
 * ======================================================================== */

void usbd_dap_out_cb(uint8_t ep)
{
    uint32_t chunk = 0U;
    uint8_t next_head = (g_req_head + 1U) % REQ_BUF_COUNT;

    /* Enqueue into ring buffer if there is room (one slot always empty) */
    if (next_head != g_req_tail) {
        usbd_ep_read(ep, g_req_bufs[g_req_head], DAP_PACKET_SIZE, &chunk);
        if (chunk > 0U) {
            g_req_head = next_head;
        }
    }
    /* Always re-arm the endpoint so the USB host can send the next packet.
     * If the ring was full, data in the current packet is lost — but with
     * REQ_BUF_COUNT=4 and the main loop depleting faster than Keil sends,
     * this should never happen in practice. */
    usbd_ep_read(ep, NULL, 0, NULL);
}

void usbd_dap_in_cb(uint8_t ep)
{
    (void)ep;
    g_in_done = 1U;
}

/* ========================================================================
 * USB Notification Handler
 * ======================================================================== */
static void dap_notify_handler(uint8_t event, void *arg)
{
    (void)arg;
    switch (event) {
        case USB_EVENT_RESET:      break;
        case USB_EVENT_CONFIGURED: break;
        default:                   break;
    }
}

/* ========================================================================
 * Synchronous IN FIFO Write (byte-by-byte, matches memcopy_to_fifo)
 * ======================================================================== */
static int dap_fifo_write_sync(uint8_t ep, const uint8_t *data, uint32_t len)
{
    uint8_t  ep_idx = USB_EP_GET_IDX(ep);
    uint32_t timeout;
    uint32_t addr;
    uint32_t i;

    if (USB_EP_GET_DIR(ep) != USB_EP_DIR_IN) return -1;

    timeout = 0x00FFFFFFU;
    while (!USB_Is_EPx_RDY_Free(ep_idx)) {
        if (!--timeout) return -2;
    }

    addr = USB_BASE + 0x118U + (uint32_t)(ep_idx - 1U) * 0x10U;
    for (i = 0U; i < len; i++) {
        *(volatile uint8_t *)addr = data[i];
    }

    g_in_done = 0U;
    USB_Set_EPx_Rdy(ep_idx);

    timeout = 0x00FFFFFFU;
    while (!g_in_done) {
        if (!--timeout) return -3;
    }

    return 0;
}

/* ========================================================================
 * USB Initialization
 * ======================================================================== */
static void usb_init(void)
{
    /* Standard USB device descriptor */
    usbd_desc_register(usbd_descriptor);

    /* Microsoft OS 1.0 descriptors for automatic WinUSB driver binding on Windows.
    * MS OS 1.0 uses a string descriptor at index 0xEE (no BOS/bcdUSB 2.1 needed)
    * and is fully supported by the CherryUSB stack on BL702. */
   extern struct usb_msosv1_descriptor dap_msosv1_desc;
   usbd_msosv1_desc_register(&dap_msosv1_desc);

    memset(&dap_class, 0, sizeof(dap_class));
    memset(&dap_intf, 0, sizeof(dap_intf));
    dap_class.name = "daplink";
    usbd_class_register(&dap_class);

    dap_intf.class_handler  = NULL;
    dap_intf.custom_handler = NULL;
    dap_intf.vendor_handler = NULL;
    dap_intf.notify_handler = dap_notify_handler;
    usbd_class_add_interface(&dap_class, &dap_intf);
    usbd_interface_add_endpoint(&dap_intf, &dap_out_ep);
    usbd_interface_add_endpoint(&dap_intf, &dap_in_ep);

    struct device *usb_dev = usb_dc_init();
    if (usb_dev) {
        device_control(usb_dev, DEVICE_CTRL_SET_INT,
            (void *)(uintptr_t)(USB_SOF_IT | USB_EP2_DATA_OUT_IT | USB_EP1_DATA_IN_IT));
    }
}

/* ========================================================================
 * Main Entry Point
 * ======================================================================== */
int main(void)
{
    /* Platform init */
    sdk_init();
    gpio_init();
    DAP_Setup();

    /* USB init */
    usb_init();
    while (!usb_device_is_configured()) {}

    /* Main loop: dequeue requests from ring buffer, process, respond */
    while (1) {
        /* SPSC ring: non-empty when head != tail */
        if (g_req_head != g_req_tail) {
            uint8_t *req = g_req_bufs[g_req_tail];

            /* Process command: req = input, g_resp_buf = output (separate buffers) */
            g_resp_len = (uint16_t)DAP_ExecuteCommand(req, g_resp_buf);
            dap_fifo_write_sync(CMSIS_DAP_IN_EP, g_resp_buf, g_resp_len);

            /* Advance tail — slot is now free for the ISR to reuse.
             * No lock needed: ISR only reads g_req_tail (volatile g_req_head
             * is written by ISR and read here — both single-byte aligned
             * stores/loads are atomic on RISC-V). */
            g_req_tail = (g_req_tail + 1U) % REQ_BUF_COUNT;
        }
    }

    return 0;
}
