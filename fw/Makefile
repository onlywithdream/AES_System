RISCV_GNU_TOOLCHAIN_HOME ?= /opt/xpack-riscv-none-elf-gcc-12.2.0-1
RISCV_GNU_TOOLCHAIN_PREFIX ?= riscv-none-elf-

RISCV_GNU_GCC = $(RISCV_GNU_TOOLCHAIN_HOME)/bin/$(RISCV_GNU_TOOLCHAIN_PREFIX)gcc
RISCV_GNU_OBJDUMP = $(RISCV_GNU_TOOLCHAIN_HOME)/bin/$(RISCV_GNU_TOOLCHAIN_PREFIX)objdump
RISCV_GNU_OBJCOPY = $(RISCV_GNU_TOOLCHAIN_HOME)/bin/$(RISCV_GNU_TOOLCHAIN_PREFIX)objcopy

PYTHON ?= python3
MAKEHEX = $(PYTHON) makehex.py

MAIN_FILE ?= aes_comm.c

BOOT_TYPE ?= RAM

FLASH_SIZE ?= 2097152
RAM_SIZE ?= 2048

MABI ?= ilp32
MARCH ?= rv32imc

TARGET = fw

LDSCRIPT = ldscript_ram.lds
MEM_FILE = $(TARGET).mi

INC=-I./bsp -I./lib

CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -mabi=$(MABI) -march=$(MARCH) $(INC)

LDFLAGS += -Wl,--gc-sections
LDFLAGS += -mabi=$(MABI) -march=$(MARCH) $(INC)
LDFLAGS += -nostdlib -lgcc -ffreestanding -Wl,-Bstatic,-T,$(LDSCRIPT),-Map,$(TARGET).map,--print-memory-usage -o3

SRCS = $(MAIN_FILE) $(wildcard bsp/*.c bsp/*.S lib/*.c)

OBJS := $(SRCS)
OBJS := $(OBJS:.S=.o)
OBJS := $(OBJS:.c=.o)

all: $(OBJS) $(TARGET).elf $(TARGET).bin $(MEM_FILE)

$(TARGET).elf:$(OBJS)
	$(RISCV_GNU_GCC) $(LDFLAGS) $^ -o $@

%.o:%.c
	$(RISCV_GNU_GCC) -c $(CFLAGS) $< -o $@

%.o:%.S
	$(RISCV_GNU_GCC) -c $(CFLAGS) $< -o $@ -D__ASSEMBLY__=1

%.bin:%.elf
	$(RISCV_GNU_OBJCOPY) -O binary $< $@ 

%.hex:%.bin
	$(MAKEHEX) $(FLASH_SIZE) FLASH $< $*

%.mi:%.bin
	$(MAKEHEX) $(RAM_SIZE) RAM $< $*

clean:
	rm -f *.o */*.o