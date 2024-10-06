#include "board.h"
#include <linux/printk.h>

// board A
static int board_A_led_init(int minor) {
    printk(KERN_INFO "%s %s %d, board A led%d init.\n", __FILE__, __FUNCTION__, __LINE__, minor);
    return 0;
}

static int board_A_led_ctl(int minor, char op) {
    printk(KERN_INFO "%s %s %d, board A led%d %s.\n",
           __FILE__,
           __FUNCTION__,
           __LINE__,
           minor,
           (op == '0' ? "off" : "on"));
    return 0;
}

static struct led_operations board_A_led_ops = {
    .init = board_A_led_init,
    .ctl  = board_A_led_ctl,
};

// board B
// board C
// board D

struct led_operations *get_led_ops(void) {
    return &board_A_led_ops;
}