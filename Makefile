# include config/make-locations
# include config/make-os
# include config/make-cc
# include config/make-debug-tool

CC := i686-elf-gcc
AS := i686-elf-as

DEPS := $(CC) $(LD) xorriso grub-mkrescue

BUILD_DIR := build
OBJECT_DIR := $(BUILD_DIR)/obj
BIN_DIR := $(BUILD_DIR)/bin
ISO_DIR := $(BUILD_DIR)/iso
ISO_BOOT_DIR := $(ISO_DIR)/boot
ISO_GRUB_DIR := $(ISO_DIR)/boot/grub

INCLUDES_DIR := includes
INCLUDES := $(patsubst %, -I%, $(INCLUDES_DIR))
SOURCE_FILES := $(shell find -name "*.[cS]")
SRC := $(patsubst ./%, $(OBJECT_DIR)/%.o, $(SOURCE_FILES))

OS_NAME := LunaixOS
OS_BIN := $(OS_NAME).bin
OS_ISO := $(OS_NAME).iso

QEMU_OPTIONS := -cdrom $(BUILD_DIR)/$(OS_ISO)

O := -O3
W := -Wall -Wextra
CFLAGS := -std=gnu99 -ffreestanding $(O) $(W)
LDFLAGS := -ffreestanding $(O) -nostdlib -lgcc

$(DEPS):
	@echo -n "checking $@ .... "
	@if which $@ > /dev/null; then \
		echo "ok";\
	else\
		echo "failed" && exit 1;\
	fi

check-cc:
	@echo -n "checking target i686-elf.... "
	@test "`i686-elf-gcc -dumpmachine`" = "i686-elf" && echo ok || (echo "failed" && exit 1)

check: $(DEPS) check-cc

$(OBJECT_DIR):
	@mkdir -p $(OBJECT_DIR)

$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

$(ISO_DIR):
	@mkdir -p $(ISO_DIR)
	@mkdir -p $(ISO_BOOT_DIR)
	@mkdir -p $(ISO_GRUB_DIR)

$(OBJECT_DIR)/%.S.o: %.S
	@mkdir -p $(@D)
	@echo "  CC    $<"
	@$(CC) $(INCLUDES) -c $< -o $@

$(OBJECT_DIR)/%.c.o: %.c
	@mkdir -p $(@D)
	@echo "  CC    $<"
	@$(CC) $(INCLUDES) -c $< -o $@ $(CFLAGS)

$(BIN_DIR)/$(OS_BIN): $(OBJECT_DIR) $(BIN_DIR) $(SRC)
	@echo "  LD    $(BIN_DIR)/$(OS_BIN)"
	@$(CC) -T link/linker.ld -o $(BIN_DIR)/$(OS_BIN) $(SRC) $(LDFLAGS)

$(BUILD_DIR)/$(OS_ISO): check $(ISO_DIR) $(BIN_DIR)/$(OS_BIN) GRUB_TEMPLATE
	@./config-grub.sh ${OS_NAME} $(ISO_GRUB_DIR)/grub.cfg
	cp $(BIN_DIR)/$(OS_BIN) $(ISO_BOOT_DIR)
	grub-mkrescue -o $(BUILD_DIR)/$(OS_ISO) $(ISO_DIR)

all: $(BUILD_DIR)/$(OS_ISO)

instable: CFLAGS := -g -std=gnu99 -ffreestanding $(O) $(W) $(ARCH_OPT) -D__LUNAIXOS_DEBUG__
instable: all

all-debug: O := -Og
all-debug: CFLAGS := -g -std=gnu99 -ffreestanding $(O) $(W) $(ARCH_OPT) -D__LUNAIXOS_DEBUG__
all-debug: LDFLAGS := -g -ffreestanding $(O) -nostdlib -lgcc
all-debug: clean $(BUILD_DIR)/$(OS_ISO)
	@echo "Dumping the disassembled kernel code to $(BUILD_DIR)/kdump.txt"
	@i686-elf-objdump -S $(BIN_DIR)/$(OS_BIN) > $(BUILD_DIR)/kdump.txt

clean:
	@rm -rf $(BUILD_DIR) || exit 1

run: $(BUILD_DIR)/$(OS_ISO)
	qemu-system-i386 $(QEMU_OPTIONS)
	# @sleep 1
	# @telnet 127.0.0.1 $(QEMU_MON_PORT)

debug-qemu: all-debug
	@i686-elf-objcopy --only-keep-debug $(BIN_DIR)/$(OS_BIN) $(BUILD_DIR)/kernel.dbg
	@qemu-system-i386 $(QEMU_OPTIONS)
	@sleep 1
	@$(QEMU_MON_TERM) -- telnet 127.0.0.1 $(QEMU_MON_PORT)
	@gdb -s $(BUILD_DIR)/kernel.dbg -ex "target remote localhost:1234"

debug-qemu-vscode: all-debug
	@i686-elf-objcopy --only-keep-debug $(BIN_DIR)/$(OS_BIN) $(BUILD_DIR)/kernel.dbg
	@qemu-system-i386 $(QEMU_OPTIONS)
	@sleep 0.5
	@telnet 127.0.0.1 $(QEMU_MON_PORT)

debug-bochs: all-debug
	@bochs -q -f bochs.cfg

debug-metal:
	@printf "@cmc" > $(PORT)
	@gdb -s $(BUILD_DIR)/kernel.dbg -ex "target remote $(PORT)"