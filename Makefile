#Project parameters
PROJECT = Nucleo_blink
OBJECTS = main.o
DEST    = debug
VPATH   = source obj asm mbed $DEST

#Compilation options
DEBUG = 1

#Tools
AS      = $(GCC_BIN)arm-none-eabi-as
CC      = $(GCC_BIN)arm-none-eabi-gcc
CXX     = $(GCC_BIN)arm-none-eabi-g++
LD      = $(GCC_BIN)arm-none-eabi-gcc
OBJCOPY = $(GCC_BIN)arm-none-eabi-objcopy
OBJDUMP = $(GCC_BIN)arm-none-eabi-objdump
SIZE    = $(GCC_BIN)arm-none-eabi-size 

include stm32f446re_mbed.mk

CFLAGS = $(INCLUDE_PATHS) $(CC_SYMBOLS) $(CPU) -c -g -fno-common -fmessage-length=0 -Wall -Wextra -fno-exceptions -ffunction-sections -fdata-sections -fomit-frame-pointer -MMD -MP

ifeq ($(HARDFP),1)
	FLOAT_ABI = hard
else
	FLOAT_ABI = softfp
endif

ifeq ($(DEBUG), 1)
	CFLAGS += -DDEBUG -O0
else
	CFLAGS += -DNDEBUG -Os
endif

LD_FLAGS = $(CPU) -Wl,--gc-sections --specs=nano.specs -u _printf_float -u _scanf_float -Wl,--wrap,main -Wl,-Map=$(PROJECT).map,--cref
LD_SYS_LIBS = -lstdc++ -lsupc++ -lm -lc -lgcc -lnosys

LIBRARY_PATHS = -L./mbed/TARGET_NUCLEO_F446RE/TOOLCHAIN_GCC_ARM 
LIBRARIES = -lmbed 

.PHONY: all clean lst size

all: $(PROJECT).bin $(PROJECT).hex

clean:
	rm -f debug/* obj/* asm/* $(DEPS)

# %.o: %.asm #.asm.o:
# 	echo "MyRule"
# 	$(CC) $(CPU) -c -x assembler-with-cpp -o asm/$@ $<
# %.o: %.s #.s.o:
# 	echo "MyRule"
# 	$(CC) $(CPU) -c -x assembler-with-cpp -o asm/$@ $<
# %.o: %.S #.S.o:
# 	echo "MyRule"
# 	$(CC) $(CPU) -c -x assembler-with-cpp -o asm/$@ $<

# %.o: %.c #.c.o:
# 	echo "MyRule"
# 	$(CC)  $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu99 $(INCLUDE_PATHS) -o obj/$@ $<

# %.o: %.cc %.cpp #.cpp.o:
# 	echo "MyRule"
# 	$(CXX) $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu++98 -fno-rtti $(INCLUDE_PATHS) -o obj/$@ $<

# %.o: %.cc
# 	echo "MyRule"
# 	$(CXX) $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu++98 -fno-rtti $(INCLUDE_PATHS) -o obj/$@ $<

$(PROJECT).elf: $(OBJECTS) $(SYS_OBJECTS)
	$(LD) $(LD_FLAGS) -T$(LINKER_SCRIPT) $(LIBRARY_PATHS) -o $(DEST)/$@ $^ $(LIBRARIES) $(LD_SYS_LIBS) $(LIBRARIES) $(LD_SYS_LIBS)

$(PROJECT).bin: $(PROJECT).elf
	$(OBJCOPY) -O binary $< $@

$(PROJECT).hex: $(PROJECT).elf
	@$(OBJCOPY) -O ihex $< $@

$(PROJECT).lst: $(PROJECT).elf
	@$(OBJDUMP) -Sdh $< > $@

lst: $(PROJECT).lst

size: $(PROJECT).elf
	$(SIZE) $(PROJECT).elf

DEPS = $(OBJECTS:.o=.d) $(SYS_OBJECTS:.o=.d)
-include $(DEPS)

