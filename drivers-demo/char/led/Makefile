
KERNELDIR := ../../../linux-3.10.14
CURRENT_PATH := $(shell pwd)

obj-m += led_drv.o chip_gpio_ops.o

build: kernel_modules

kernel_modules:
	$(MAKE) -C $(KERNELDIR) M=$(CURRENT_PATH) modules
	${CROSS_COMPILE}gcc led_drv_test.c -g -o led_drv_test

clean:
	$(MAKE) -C $(KERNELDIR) M=$(CURRENT_PATH) clean
