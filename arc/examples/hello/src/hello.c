/* IPM (Inter-Processor Mailbox) sample application for ARC processor
 * Copyright (C) 2017 Intel Corporation
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#include <zephyr.h>

#include <ipm.h>
#include <ipm/ipm_quark_se.h>
#include <device.h>
#include <init.h>
#include <misc/printk.h>
#include <string.h>

QUARK_SE_IPM_DEFINE(ipm_receive_channel, 0, QUARK_SE_IPM_INBOUND);
QUARK_SE_IPM_DEFINE(ipm_send_channel, 1, QUARK_SE_IPM_OUTBOUND);

#define PRIORITY      7
#define IPM_DATA_SIZE 16
#define DELAY         1000
#define STACKSIZE     2048

static volatile bool received;
static volatile char received_data[IPM_DATA_SIZE];
static const char *send_data = "Hey, it's ARC!!";

static void ipm_callback(void *context, uint32_t id, volatile void *data)
{
    volatile char *p = data;

    /* Copy data from mailbox to local buffer */
    for (unsigned i = 0; i < IPM_DATA_SIZE; ++i)
        received_data[i] = p[i];

    received = true;
}

void main(void)
{
    struct device *ipm_send_dev = device_get_binding("ipm_send_channel");
    struct device *ipm_receive_dev = device_get_binding("ipm_receive_channel");
    ipm_register_callback(ipm_receive_dev, ipm_callback, NULL);
    ipm_set_enabled(ipm_receive_dev, 1);

    while (1) {
        /* Send message to x86 core */
        ipm_send(ipm_send_dev, 1, 0, send_data, IPM_DATA_SIZE);

        /* Wait for response */
        while(!received);

        /* Print response */
        printk("Sent message \"%s\" to x86 core, received response \"%s\"",
                send_data, received_data);

        received = false;
        k_sleep(DELAY);
    }
}

K_THREAD_DEFINE(main_id, STACKSIZE, main, NULL, NULL, NULL,
		PRIORITY, 0, K_NO_WAIT);
