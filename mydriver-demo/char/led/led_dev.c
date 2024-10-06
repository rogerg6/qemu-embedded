/**
 * @file led_dev.c
 * @brief led设备的platform device, 主要描述设备资源信息
 */
#include <linux/types.h>
#include <linux/init.h>
#include <linux/device.h>
#include <linux/platform_device.h>
#include <linux/io.h>
#include <linux/console.h>
#include <linux/of_platform.h>
#include <asm/setup.h>
#include <linux/gfp.h>
#include <linux/module.h>

#include "led_dev.h"

static void led_dev_release(struct device *dev) {}

static struct resource led_res[] = {
    {.start = GROUP_PIN(3, 1),
     .flags = IORESOURCE_IRQ,
     .name  = "led0"},   // IORESOURCE_IRQ是随便写的
    {.start = GROUP_PIN(3, 2), .flags = IORESOURCE_IRQ, .name = "led1"},
    {.start = GROUP_PIN(3, 3), .flags = IORESOURCE_IRQ, .name = "led2"},
};

static struct platform_device led_dev = {
    .name          = "myled",
    .num_resources = ARRAY_SIZE(led_res),
    .resource      = led_res,
    .dev =
        {
            .release = led_dev_release,
        },
};

static int __init led_dev_init(void) {
    int err = platform_device_register(&led_dev);
    return err;
}

static void __exit led_dev_exit(void) {
    platform_device_unregister(&led_dev);
}

module_init(led_dev_init);
module_exit(led_dev_exit);
MODULE_LICENSE("GPL");
