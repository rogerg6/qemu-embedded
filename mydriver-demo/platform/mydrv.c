#include <linux/init.h>
#include <linux/module.h>
#include <linux/platform_device.h>

static int mod_param = -1;
module_param(mod_param, int, 0644);
MODULE_PARM_DESC(mod_param, "just test for module parameters.");

int my_driver_probe(struct platform_device *pdev) {
    printk(KERN_INFO "%s called.\n", __FUNCTION__);
    printk(KERN_INFO "mod_param = %d\n", mod_param);
    return 0;
}

int my_driver_remove(struct platform_device *pdev) {
    printk(KERN_INFO "%s called.\n", __FUNCTION__);
    return 0;
}

static struct platform_driver my_driver = {
    .driver = {.name = "my-driver-demo", .owner = THIS_MODULE},
    .probe  = my_driver_probe,
    .remove = my_driver_remove};

int __init my_drv_init(void) {
    platform_driver_register(&my_driver);
    return 0;
}

void __exit my_drv_exit(void) {
    printk(KERN_ERR "%s called.\n", __FUNCTION__);
    platform_driver_unregister(&my_driver);
}

module_init(my_drv_init);
module_exit(my_drv_exit);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("glq");
MODULE_DESCRIPTION("Virtual Platform Driver Module");