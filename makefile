#Project parameters
PROJECT = Nucleo_blink
OBJECTS = obj/main.o
DEST    = debug
VPATH   = src lib $DEST
TARGET  = NUCLEO_F446RE
ELF     = $(DEST)/$(PROJECT).elf

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

include $(TARGET).mk

ifeq ($(DEBUG), 1)
	CC_FLAGS += -DDEBUG -O0
else
	CC_FLAGS += -DNDEBUG -Os
endif

CC_FLAGS = $(CPU) $(INCLUDE_PATHS) $(CC_SYMBOLS) -c -g -fno-common -fmessage-length=0 -Wall -Wextra -fno-exceptions -ffunction-sections -fdata-sections -fomit-frame-pointer -MMD -MP

LD_FLAGS = $(CPU) -Wl,--gc-sections --specs=nano.specs -u _printf_float -u _scanf_float -Wl,--wrap,main -Wl,-Map=$(DEST)/$(PROJECT).map,--cref
#`-u _printf_float -u _scanf_float` after --specs for floating point I/O

LD_SYS_LIBS = -lstdc++ -lsupc++ -lm -lc -lgcc -lnosys 
LIBRARIES = -lmbed 

.PHONY: all clean lst size

all: $(PROJECT).bin $(PROJECT).hex

clean:
	rm -f debug/* obj/* asm/* $(DEPS)

obj/%.o: %.c
	$(CC) $(CC_FLAGS) $(CC_SYMBOLS) -std=c99 $(INCLUDE_PATHS) -o $@ $<

obj/%.o: %.cc
	$(CXX) $(CC_FLAGS) $(CC_SYMBOLS) -std=c++98 -fno-rtti $(INCLUDE_PATHS) -o $@ $<

obj/%.o: %.cpp
	$(CXX) $(CC_FLAGS) $(CC_SYMBOLS) -std=c++98 -fno-rtti $(INCLUDE_PATHS) -o $@ $<

obj/%.o: %.asm
	$(CC) $(CPU) -c -x assembler-with-cpp -o asm/$@ $<

$(ELF): $(OBJECTS) $(SYS_OBJECTS)
	$(LD) $(LD_FLAGS) -T$(LINKER_SCRIPT) $(LIBRARY_PATHS) -o $@ $^ -Wl,--start-group $(LIBRARIES) $(LD_SYS_LIBS) -Wl,--end-group

$(PROJECT).bin: $(ELF)
	$(OBJCOPY) -O binary $< $(DEST)/$@

$(PROJECT).hex: $(ELF)
	@$(OBJCOPY) -O ihex $< $(DEST)/$@

$(PROJECT).lst: $(ELF)
	@$(OBJDUMP) -Sdh $< > $(DEST)/$@

lst: $(PROJECT).lst

size: $(ELF)
	$(SIZE) $(ELF)

DEPS = $(OBJECTS:.o=.d) $(SYS_OBJECTS:.o=.d)
-include $(DEPS)

