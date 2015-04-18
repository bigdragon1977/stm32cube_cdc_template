PREFIX=arm-none-eabi-
CC=${PREFIX}gcc
AS=${PREFIX}as
OBJCOPY=${PREFIX}objcopy
MKDIR=mkdir

BUILD_DIR=build

CFLAGS=-fno-common -Os -g -mcpu=cortex-m3 -mthumb -mthumb-interwork

SOURCES=main.c stm32f1xx_hal_msp.c stm32f1xx_it.c system_stm32f1xx.c usbd_cdc_interface.c usbd_conf.c usbd_desc.c

OBJS=$(addprefix $(BUILD_DIR)/,$(SOURCES:.c=.o))
OBJS+=$(BUILD_DIR)/startup_stm32f103xb.o

INCLUDES=-IInc

LDFLAGS=-TSTM32F103XB_FLASH.ld

all: bin

include makefile.hal
include makefile.usb

CFLAGS+= $(INCLUDES) $(HAL_INCLUDES) $(USB_INCLUDES)
OBJS+=$(HAL_OBJECTS) $(USB_OBJECTS)

bin: main.elf
	$(OBJCOPY) -Obinary main.elf main.bin

main.elf: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c  -o $@ -g $^ 

$(BUILD_DIR)/%.o: Src/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $^


$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c  -o $@ -g $^ 
$(BUILD_DIR):
	$(MKDIR) $@

print-%: ; @echo $*=$($*)

clean:
	rm main.elf main.bin $(OBJS)

program: main.elf
	st-flash --reset write main.bin 0x08000000
