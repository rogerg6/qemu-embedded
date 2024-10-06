/***
 * 抽象出某款芯片上面gpio的操作, 做成接口
 * 而相应的GPIO引脚等资源, 写在board_resource.c里面
 * 做到驱动和设备分离, 设备操作和设备资源信息分离
 */
#include <linux/printk.h>

#include "chip_gpio_ops.h"
#include "board_resource.h"

static struct led_resource *led_res = NULL;

// board A
static int chip_gpio_init(int minor) {
    if (!led_res)
        led_res = get_led_resource();
    if (minor >= led_res->nr_led)
        return -1;

    int x = led_res->pin[minor];
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
    if (minor >= led_res->nr_led)
        return -1;

    int x = led_res->pin[minor];
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

// board B
// board C
// board D

struct gpio_operations *get_gpio_ops(void) {
    return &gpio_ops;
}