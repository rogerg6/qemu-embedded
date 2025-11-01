/***
 * platform_driver抽象gpio的操作
 * 主要做设备资源probe,操作设备
 */
#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/delay.h>
#include <linux/errno.h>
#include <linux/ioport.h>
#include <linux/platform_device.h>
#include <linux/slab.h>
#include <linux/spinlock.h>
#include <linux/io.h>
#include <linux/of.h>

#include "chip_gpio_ops.h"
#include "led_dev.h"
#include "led_drv.h"

static int g_led_pins[100];
static int g_led_cnt = 0;

// board A
static int chip_gpio_init(int minor) {
    if (minor >= g_led_cnt)
        return -1;

    int x = g_led_pins[minor];
    int g = GROUP(x);
    int p = PIN(x);
    printk(KERN_INFO "%s %s %d, board A led%d[group%d pin%d] init.\n",
           __FILE__,
           __FUNCTION__,
           __LINE__,
           minor,
           g,
           p);
    return 0;
}

static int chip_gpio_ctl(int minor, char op) {
    if (minor >= g_led_cnt)
        return -1;

    int x = g_led_pins[minor];
    int g = GROUP(x);
    int p = PIN(x);
    printk(KERN_INFO "%s %s %d, board A led%d[group%d pin%d] %s.\n",
           __FILE__,
           __FUNCTION__,
           __LINE__,
           minor,
           g,
           p,
           (op == '0' ? "off" : "on"));
    return 0;
}

static struct gpio_operations gpio_ops = {
    .init = chip_gpio_init,
    .ctl  = chip_gpio_ctl,
};

int led_drv_probe(struct platform_device *pdev) {
    struct device_node *np;
    int                 err;
    uint32_t            led_pin_val;

    np = pdev->dev.of_node;
    if (!np)
        return -1;

    err = of_property_read_u32(np, "pin", &led_pin_val);
    if (err < 0)
        return -1;

    g_led_pins[g_led_cnt] = led_pin_val;
    led_device_create(g_led_cnt++);

    return 0;
}

int led_drv_remove(struct platform_device *pdev) {
    struct device_node *np;
    int                 err;
    int                 i;
    uint32_t            led_pin_val;

    np = pdev->dev.of_node;
    if (!np)
        return -1;

    err = of_property_read_u32(np, "pin", &led_pin_val);
    if (err < 0)
        return -1;

    // set g_led_pins[i] = -1, and destroy led device
    for (i = 0; i < g_led_cnt; i++)
        if (g_led_pins[i] == led_pin_val) {
            led_device_destroy(i);
            g_led_pins[i] = -1;
            break;
        }
    for (i = 0; i < g_led_cnt; i++)
        if (g_led_pins[i] != -1)
            break;
    if (i == g_led_cnt)
        g_led_cnt = 0;

    return 0;
}

static const struct of_device_id myleds[] = {
    {.compatible = "myled-of"},
    {},
};


static struct platform_driver led_drv = {
    .probe  = led_drv_probe,
    .remove = led_drv_remove,
    .driver =
        {
            .name           = "myled",
            .of_match_table = myleds,
        },
};

static int __init led_drv_init(void) {
    int err = platform_driver_register(&led_drv);
    register_led_operations(&gpio_ops);
    return err;
}

static void __exit led_drv_exit(void) {
    platform_driver_unregister(&led_drv);
}

module_init(led_drv_init);
module_exit(led_drv_exit);
MODULE_LICENSE("GPL");
