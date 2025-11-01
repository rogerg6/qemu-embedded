
KERNELDIR := ../../linux-3.10.14
CURRENT_PATH := $(shell pwd)

obj-m	+= mydev.o
obj-m	+= mydrv.o

build: kernel_modules

kernel_modules:
	$(MAKE) -C $(KERNELDIR) M=$(CURRENT_PATH) modules
clean:
	$(MAKE) -C $(KERNELDIR) M=$(CURRENT_PATH) clean
