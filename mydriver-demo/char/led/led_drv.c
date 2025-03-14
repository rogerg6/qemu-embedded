/**
 * @brief led驱动, 其实就是字符设备驱动
 * 提供file_operations结构体, 创建设备节点, 供应用层调用
 */
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/errno.h>
#include <linux/miscdevice.h>
#include <linux/kernel.h>
#include <linux/major.h>
#include <linux/mutex.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/stat.h>
#include <linux/init.h>
#include <linux/device.h>
#include <linux/tty.h>
#include <linux/kmod.h>
#include <linux/gfp.h>
#include <linux/printk.h>

#include "chip_gpio_ops.h"

#define MIN(x, y) (x < y ? x : y)
#define LED_NUM 3   // the number of leds

static int  major = -1;
static char char_buf[1024];

static struct class           *led_class;
static struct gpio_operations *led_ops;

void led_device_create(int minor) {
    device_create(led_class, NULL, MKDEV(major, minor), NULL, "led%d", minor);
}
void led_device_destroy(int minor) {
    device_destroy(led_class, MKDEV(major, minor));
}
void register_led_operations(struct gpio_operations *ops) {
    led_ops = ops;
}
EXPORT_SYMBOL(led_device_create);
EXPORT_SYMBOL(led_device_destroy);
EXPORT_SYMBOL(register_led_operations);

static int led_open(struct inode *inode, struct file *file) {
    int minor = -1;
    printk(KERN_INFO "%s %s %d\n", __FILE__, __FUNCTION__, __LINE__);
    WARN_ON(1);
    minor = iminor(inode);
    led_ops->init(minor);
    return 0;
}

static int led_close(struct inode *inode, struct file *file) {
    printk(KERN_INFO "%s %s %d\n", __FILE__, __FUNCTION__, __LINE__);
    WARN_ON(1); 
    return 0;
}

static ssize_t led_read(struct file *file, char __user *buf, size_t size, loff_t *offset) {
    printk(KERN_INFO "%s %s %d\n", __FILE__, __FUNCTION__, __LINE__);
    WARN_ON(1); 
    unsigned long nr;
    nr = copy_to_user(buf, char_buf, MIN(1024, size));
    return nr;
}

static ssize_t led_write(struct file *file, const char __user *buf, size_t size, loff_t *offset) {
    ssize_t nw;
    int     minor = -1;
    printk(KERN_INFO "%s %s %d\n", __FILE__, __FUNCTION__, __LINE__);
    WARN_ON(1); 
    nw = copy_from_user((void *)char_buf, buf, MIN(1024, size));

    minor = iminor(file_inode(file));
    led_ops->ctl(minor, char_buf[0]);
    return nw;
}


static const struct file_operations led_fops = {
    .owner   = THIS_MODULE,
    .open    = led_open,
    .release = led_close,
    .read    = led_read,
    .write   = led_write,
};

static int __init led_init(void) {
    int err;
    // 注册字符设备
    major = register_chrdev(0, "led", &led_fops);

    // 创建类
    led_class = class_create(THIS_MODULE, "led");
    err       = PTR_ERR(led_class);
    if (IS_ERR(led_class))
        return -1;

    return 0;
}

static void __exit led_exit(void) {
    class_destroy(led_class);
    unregister_chrdev(major, "led");
}

module_init(led_init);
module_exit(led_exit);
MODULE_LICENSE("GPL");
