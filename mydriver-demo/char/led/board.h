#ifndef _BOARD_H
#define _BOARD_H

/***
 * 抽象出所有board上面led的操作, 做成接口
 * 针对具体的board的具体操作, 写在board.c里面
 * 可以通过编译选项选择.
 * 做到驱动和设备信息分离
 */
struct led_operations {
    int (*init)(int minor);
    int (*ctl)(int minor, char op);
};

struct led_operations *get_led_ops(void);

#endif
