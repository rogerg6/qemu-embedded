
KERNELDIR := ../../../linux-3.10.14
CURRENT_PATH := $(shell pwd)

led-y := led_drv.o board.o
obj-m	+= led.o

build: kernel_modules

kernel_modules:
	$(MAKE) -C $(KERNELDIR) M=$(CURRENT_PATH) modules
	${CROSS_COMPILE}gcc led_drv_test.c -g -o led_drv_test
	cp led.ko ../../../rootfs/home
	cp led_drv_test ../../../rootfs/home

clean:
	$(MAKE) -C $(KERNELDIR) M=$(CURRENT_PATH) clean
	rm -f led_drv_test
