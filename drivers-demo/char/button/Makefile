
KERNELDIR := ../../../linux-3.10.14
CURRENT_PATH := $(shell pwd)

obj-m += button_drv.o 
obj-m += board_xxx.o

build: kernel_modules

kernel_modules:
	$(MAKE) -C $(KERNELDIR) M=$(CURRENT_PATH) modules
	${CROSS_COMPILE}gcc button_drv_test.c -g -o button_drv_test

clean:
	$(MAKE) -C $(KERNELDIR) M=$(CURRENT_PATH) clean
