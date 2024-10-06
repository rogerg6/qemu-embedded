#ifndef _LED_DRV_H
#define _LED_DRV_H

#include "chip_gpio_ops.h"


void led_device_create(int minor);
void led_device_destroy(int minor);
void register_led_operations(struct gpio_operations *ops);

#endif