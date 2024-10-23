#include <linux/delay.h>
#include <linux/errno.h>
#include <linux/init.h>
#include <linux/io.h>
#include <linux/ioport.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/platform_device.h>
#include <linux/slab.h>
#include <linux/spinlock.h>

#include "button_drv.h"

void board_xxx_btn_init_gpio(int which) {
  printk("%s @ %s %d, button No.%d init.\n", __FILE__, __FUNCTION__, __LINE__,
         which);
}

int board_xxx_btn_read_gpio(int which) {
  printk("%s @ %s %d, button No.%d read.\n", __FILE__, __FUNCTION__, __LINE__,
         which);
  return 1;
}

struct button_operations board_xxx_btn_ops = {
    .count = 3,
    .init = board_xxx_btn_init_gpio,
    .read = board_xxx_btn_read_gpio,
};

static int __init board_xxx_btn_init(void) {
  register_button_operations(&board_xxx_btn_ops);
  return 0;
}

static void __init board_xxx_btn_exit(void) { unregister_button_operations(); }

module_init(board_xxx_btn_init);
module_exit(board_xxx_btn_exit);
MODULE_LICENSE("GPL");
