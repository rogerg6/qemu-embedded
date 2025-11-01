#include <linux/init.h>
#include <linux/module.h>
#include <linux/input.h>
#include <linux/platform_device.h>
// #include <mach/platform.h>

void my_device_release(struct device *dev) {
    printk(KERN_INFO "%s called.\n", __FUNCTION__);
}

static struct platform_device my_device = {.name = "my-driver-demo",
                                           .dev =
                                               {
                                                   .release = my_device_release,
                                               },
                                           .id            = -1,
                                           .resource      = NULL,
                                           .num_resources = 0};

int __init my_dev_init(void) {
    platform_device_register(&my_device);
    return 0;
}

void __exit my_dev_exit(void) {
    platform_device_unregister(&my_device);
}

module_init(my_dev_init);
module_exit(my_dev_exit);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("glq");
MODULE_DESCRIPTION("Virtual Platform Driver Module");