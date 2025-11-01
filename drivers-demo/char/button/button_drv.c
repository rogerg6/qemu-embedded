/**
 * @brief button驱动, 其实就是字符设备驱动
 * 提供file_operations结构体, 创建设备节点, 供应用层调用
 *
 * 主要功能, 提供应用层读取button的值
 */
#include <linux/device.h>
#include <linux/errno.h>
#include <linux/fs.h>
#include <linux/gfp.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/kmod.h>
#include <linux/major.h>
#include <linux/miscdevice.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/printk.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/stat.h>
#include <linux/tty.h>

#include "button_drv.h"

#define MIN(x, y) (x < y ? x : y)
#define BUTTON_NUM 3 // the number of buttons

static int major = -1;

static struct class *button_class;
static struct button_operations *button_ops;

void button_device_create(int minor) {}
void button_device_destroy(int minor) {
  device_destroy(button_class, MKDEV(major, minor));
}
void register_button_operations(struct button_operations *ops) {
  button_ops = ops;
  int i;

  for (i = 0; i < button_ops->count; i++) {
    device_create(button_class, NULL, MKDEV(major, i), NULL, "button%d", i);
  }
}
void unregister_button_operations(void) {
  int i;
  for (i = 0; i < button_ops->count; i++) {
    device_destroy(button_class, MKDEV(major, i));
  }
  button_ops = NULL;
}
EXPORT_SYMBOL(register_button_operations);
EXPORT_SYMBOL(unregister_button_operations);

static int button_open(struct inode *inode, struct file *file) {
  int minor = -1;
  printk(KERN_INFO "%s %s %d\n", __FILE__, __FUNCTION__, __LINE__);
  minor = iminor(inode);
  button_ops->init(minor);
  return 0;
}

static int button_close(struct inode *inode, struct file *file) {
  printk(KERN_INFO "%s %s %d\n", __FILE__, __FUNCTION__, __LINE__);
  return 0;
}

static ssize_t button_read(struct file *file, char __user *buf, size_t size,
                           loff_t *offset) {
  printk(KERN_INFO "%s %s %d\n", __FILE__, __FUNCTION__, __LINE__);
  char level;

  level = button_ops->read(iminor(file_inode(file)));
  return copy_to_user(buf, &level, 1);
}

static ssize_t button_write(struct file *file, const char __user *buf,
                            size_t size, loff_t *offset) {
  return 0;
}

static const struct file_operations button_fops = {
    .owner = THIS_MODULE,
    .open = button_open,
    .release = button_close,
    .read = button_read,
    .write = button_write,
};

static int __init button_init(void) {
  int err;
  // 注册字符设备
  major = register_chrdev(0, "button", &button_fops);

  // 创建类
  button_class = class_create(THIS_MODULE, "button");
  err = PTR_ERR(button_class);
  if (IS_ERR(button_class))
    return -1;

  return 0;
}

static void __exit button_exit(void) {
  class_destroy(button_class);
  unregister_chrdev(major, "button");
}

module_init(button_init);
module_exit(button_exit);
MODULE_LICENSE("GPL");
