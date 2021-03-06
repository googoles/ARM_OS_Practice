ARCH = armv7-a
MCPU = cortex-a8

TARGET = rvpb

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-gcc
OC = arm-none-eabi-objcopy

LINKER_SCRIPT = ./yunsoo.ld
MAP_FILE = build/yunsoo.map

ASM_SRCS = $(wildcard boot/*.S)
ASM_OBJS = $(patsubst boot/%.S, build/%.os, $(ASM_SRCS))

VPATH = boot		\
	hal/$(TARGET)	\
	lib

C_SRCS  = $(notdir $(wildcard boot/*.c))
C_SRCS += $(notdir $(wildcard hal/$(TARGET)/*.c))
C_SRCS += $(notdir $(wildcard lib/*.c))
C_OBJS = $(patsubst %.c, build/%.o, $(C_SRCS))


INC_DIRS  = -I include 			\
            -I hal	   			\
            -I hal/$(TARGET)	\
            -I lib				\

CFLAGS = -c -g -std=c11 -mthumb-interwork

LDFLAGS = -nostartfiles -nostdlib -nodefaultlibs -static -lgcc

yunsoo = build/yunsoo.axf
yunsoo_bin = build/yunsoo.bin

.PHONY: all clean run debug gdb

all: $(yunsoo)

clean:
	@rm -rf build

run: $(yunsoo)
	qemu-system-arm -M realview-pb-a8 -kernel $(yunsoo) -nographic

debug: $(yunsoo)
	qemu-system-arm -M realview-pb-a8 -kernel $(yunsoo) -S -gdb tcp::1234,ipv4

gdb:
	arm-none-eabi-gdb

kill:
	kill -9 'ps aux | grep 'qemu' | awk 'NR==1{print $$2}''

$(yunsoo): $(ASM_OBJS) $(C_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(yunsoo) $(ASM_OBJS) $(C_OBJS) -Wl,-Map=$(MAP_FILE) $(LDFLAGS)
	$(OC) -O binary $(yunsoo) $(yunsoo_bin)

build/%.os: %.S
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) -marm $(INC_DIRS) $(CFLAGS) -o $@ $<

build/%.o: %.c
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) -marm $(INC_DIRS) $(CFLAGS) -o $@ $<
