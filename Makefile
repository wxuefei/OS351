KERNELNAME = os351
TOP = $(shell pwd)

OBJECTS_BOOT = boot/loader.o
OBJECTS_KERN = kern/main.o kern/io.o kern/terminal.o kern/interrupts.o kern/interrupt_handlers.o kern/threads.o kern/context_switch.o
OBJECTS_LIBK = libk/stdio.o libk/string.o

OBJECTS_ALL = $(OBJECTS_BOOT) $(OBJECTS_KERN) $(OBJECTS_LIBK)

MAKE = make

CC_DEBUG = -g
AS_DEBUG = -g

export CC = gcc
export CFLAGS = -I$(TOP) -I$(TOP)/boot -I$(TOP)/kern -I$(TOP)/libk $(CC_DEBUG) -m64 -nostdinc -nostdlib -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs -Wall -Wextra

export LD = ld
export LDFLAGS = -T link.ld -z max-page-size=4096

export AS = nasm
export ASFLAGS = $(AS_DEBUG) -felf64

$(KERNELNAME).elf: $(OBJECTS_ALL)
	$(MAKE) -C boot
	$(MAKE) -C kern
	$(MAKE) -C libk
	$(LD) $(LDFLAGS) $(OBJECTS_ALL) -o $(KERNELNAME).elf
	cp $(KERNELNAME).elf ISO/boot
	grub-mkrescue -o $(KERNELNAME).iso ISO/

run: $(KERNELNAME).elf
	$(QEMU) $(QEMU_FLAGS) -kernel $(KERNELNAME).elf

clean:
	$(MAKE) -C boot clean
	$(MAKE) -C kern clean
	$(MAKE) -C libk clean
	rm -f ISO/boot/$(KERNELNAME).elf
	rm -f $(KERNELNAME).elf
	rm -f $(KERNELNAME).iso
	rm -f *.o
