/**
 * @file board_resource.c
 * @brief 记录板载资源
 */

#include "board_resource.h"

static struct led_resource led_res = {
    .nr_led = 3,
    .pin =
        {
            GROUP_PIN(3, 4),
            GROUP_PIN(3, 5),
            GROUP_PIN(3, 6),
        },
};

struct led_resource *get_led_resource(void) {
    return &led_res;
}
