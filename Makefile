ARCH = armv7-a
MCPU = cortex-a8

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OC = arm-none-eabi-objcopy

LINKER_SCRIPT = ./yunsoo.ld
MAP_FILE = build/yunsoo.map

ASM_SRCS = $(wildcard boot/*.S)
ASM_OBJS = $(patsubst boot/%.S, build/%.os, $(ASM_SRCS))

C_SRCS = $(wildcard boot/*.c)
C_OBJS = $(patsubst boot/%.c, build/%.o, $(C_SRCS))

INC_DIRS = -I include

yunsoo = build/yunsoo.axf
yunsoo_bin = build/yunsoo.bin

.PHONY: all clean run debug gdb

all: $(yunsoo)

clean:
	@rm -rf build

run: $(yunsoo)
	qemu-system-arm -M realview-pb-a8 -kernel $(yunsoo)

debug: $(yunsoo)
	qemu-system-arm -M realview-pb-a8 -kernel $(yunsoo) -S -gdb tcp::1234,ipv4

gdb:
	arm-none-eabi-gdb

$(yunsoo): $(ASM_OBJS) $(C_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(yunsoo) $(ASM_OBJS) $(C_OBJS) -Map=$(MAP_FILE)
	$(OC) -O binary $(yunsoo) $(yunsoo_bin)

build/%.os: $(ASM_SRCS)
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) $(INC_DIRS) -c -g -o $@ $<

build/%.o: $(C_SRCS)
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) $(INC_DIRS) -c -g -o $@ $<
