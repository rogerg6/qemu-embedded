#ifndef _CHIP_GPIO_H
#define _CHIP_GPIO_H

struct gpio_operations {
    int (*init)(int minor);
    int (*ctl)(int minor, char op);
};

struct gpio_operations *get_gpio_ops(void);

#endif
