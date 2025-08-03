# Makefile for GooberOSx64 (native x86_64 system toolchain)

TARGET = bin/kernel.elf
ISO = bin/gooberos.iso

C_SOURCES = kernel.c
ASM_SOURCES = boot.s

BUILD_DIR = build
BIN_DIR = bin
OBJ = $(BUILD_DIR)/boot.o $(BUILD_DIR)/kernel.o

CC = gcc
AS = nasm
LD = ld.bfd

CFLAGS = -ffreestanding -O2 -Wall -Wextra -mno-red-zone -m64
LDFLAGS = -T linker.ld -nostdlib -z max-page-size=0x1000

GRUB_BIOS_DIR = /usr/lib/grub/i386-pc

.PHONY: all clean run iso

all: $(ISO)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(BUILD_DIR)/boot.o: boot.s | $(BUILD_DIR)
	$(AS) -f elf64 boot.s -o $@

$(BUILD_DIR)/kernel.o: kernel.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c kernel.c -o $@

$(TARGET): $(OBJ) | $(BIN_DIR)
	$(CC) $(CFLAGS) -nostdlib -no-pie -static -T linker.ld -fuse-ld=bfd -o $@ $^

iso: $(TARGET)
	mkdir -p isodir/boot/grub
	cp $(TARGET) isodir/boot/kernel.elf
	echo 'set timeout=0\nset default=0\nmenuentry "GooberOSx64" {\n  multiboot2 /boot/kernel.elf\n  boot\n}' > isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) isodir -d $(GRUB_BIOS_DIR)

run: iso
	qemu-system-x86_64 -cdrom $(ISO)

clean:
	rm -rf $(BUILD_DIR) isodir $(BIN_DIR)
