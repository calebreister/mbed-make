# Copyright (c) 2016 Caleb Reister
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#Project parameters
PROJECT = Nucleo_blink
OBJECTS = $(call GETOBJ,src)
VPATH   = src $DEST lib obj
TARGET  = NUCLEO_F303K8
TARGET := TARGET_$(TARGET)
ELF     = $(DEST)/$(PROJECT).elf
DEBUG   = 1
export DEST PROJECT

#Tools
AS      = $(GCC_BIN)arm-none-eabi-as
CC      = $(GCC_BIN)arm-none-eabi-gcc
CXX     = $(GCC_BIN)arm-none-eabi-g++
LD      = $(GCC_BIN)arm-none-eabi-gcc
DBG     = $(GCC_BIN)arm-none-eabi-gdb
OBJCOPY = $(GCC_BIN)arm-none-eabi-objcopy
OBJDUMP = $(GCC_BIN)arm-none-eabi-objdump
SIZE    = $(GCC_BIN)arm-none-eabi-size 

#One liner to assign source file names to object files...
GETOBJ = $(shell ls $(1) | egrep "(\.[csS]|\.cc|\.cpp|\.asm)" | sed -e "s/^/obj\//;s/\(\.[csS]\|\.cc\|\.cpp\|\.asm\)/\.o/g")

#Compiler configuration
INCLUDE_PATHS = -I lib/mbed
CC_FLAGS = $(CPU) $(INCLUDE_PATHS) $(CC_SYMBOLS) -c -g -fno-common -fmessage-length=0 -Wall -Wextra -fno-exceptions -ffunction-sections -fdata-sections -fomit-frame-pointer -MMD -MP
ifeq ($(DEBUG), 1)
	CC_FLAGS += -DDEBUG -O0
	DEST = debug
else
	CC_FLAGS += -DNDEBUG -Os
	DEST = release
endif

#Linker configuration
LD_FLAGS = $(CPU) -Wl,--gc-sections --specs=nano.specs -u _printf_float -u _scanf_float -Wl,--wrap,main -Wl,-Map=$(DEST)/$(PROJECT).map,--cref
LD_SYS_LIBS = -lstdc++ -lsupc++ -lm -lc -lgcc -lnosys
LIBRARY_PATHS = -L./lib/mbed/$(TARGET)/TOOLCHAIN_GCC_ARM
LIBRARIES = -lmbed

DEPS = $(OBJECTS:.o=.d) $(SYS_OBJECTS:.o=.d)
-include $(DEPS)

#Target-specific configuration
include scripts/$(TARGET).mk
include scripts/mbed-rtos.mk

################################################################################
.PHONY: all flash gdb clean lst size update

all: $(PROJECT).bin $(PROJECT).hex
	printenv

clean:
	rm -f debug/* release/* obj/*
	cd lib/mbed && hg purge #clear changes in lib/mbed
	cd lib/mbed-rtos && hg purge #clear changes in lib/mbed-rtos
	find . -regextype posix-egrep -regex "\..*\/(\#[A-Za-z0-9_\-\.]+\#|[A-Za-z0-9_\-\.]+\~)" -print -exec rm {} \;

#NOTE: purge is a built-in hg extension. To enable it, add `purge =` under the
#`[extensions]` section in .hgrc

update:
	cd lib/mbed && hg pull && hg update -r tip -C #hg pull lib/mbed
	cd lib/mbed-rtos && hg pull && hg update -r tip -C #hg pull lib/mbed-rtos

lst: $(PROJECT).lst

size: $(ELF)
	$(SIZE) $(ELF)

################################################################################
obj/%.o: %.c
	$(CC) $(CC_FLAGS) $(CC_SYMBOLS) -std=c99 $(INCLUDE_PATHS) -o $@ $<

obj/%.o: %.cc
	$(CXX) $(CC_FLAGS) $(CC_SYMBOLS) -std=c++98 -fno-rtti $(INCLUDE_PATHS) -o $@ $<

obj/%.o: %.cpp
	$(CXX) $(CC_FLAGS) $(CC_SYMBOLS) -std=c++98 -fno-rtti $(INCLUDE_PATHS) -o $@ $<

obj/%.o: %.asm
	$(CC) $(CPU) -c -x assembler-with-cpp -o $@ $<

obj/%.o: %.S
	$(CC) $(CPU) -c -x assembler-with-cpp -o $@ $<

obj/%.o: %.s
	$(CC) $(CPU) -c -x assembler-with-cpp -o $@ $<

$(ELF): $(OBJECTS) $(SYS_OBJECTS)
	$(LD) $(LD_FLAGS) -T$(LINKER_SCRIPT) $(LIBRARY_PATHS) -o $@ $^ -Wl,--start-group $(LIBRARIES) $(LD_SYS_LIBS) -Wl,--end-group

$(PROJECT).bin: $(ELF)
	$(OBJCOPY) -O binary $< $(DEST)/$@

$(PROJECT).hex: $(ELF)
	@$(OBJCOPY) -O ihex $< $(DEST)/$@

$(PROJECT).lst: $(ELF)
	@$(OBJDUMP) -Sdh $< > $(DEST)/$@

#OpenOCD rules##################################################################
#To use OpenOCD without root access, run these commands...
# sudo ln -s /usr/share/openocd/contrib/99-openocd.rules /etc/udev/rules.d/
# sudo udevadm control --reload-rules

#Flash the project to 
flash: $(PROJECT).bin
	openocd $(OCD_ARGS) $(FLASH_SCRIPT)

#Launch gdb with the appropriate scripts
#If the $EMACS environment variable is defined, gdb will be launched within
#emacs.
gdb: $(ELF)
ifeq ($(EMACS),t)
	emacsclient -e "(gdb \"$(DBG) $(ELF) -i=mi -x $(CURDIR)/scripts/attach.gdb\")"
else
	$(DBG) $(ELF) -x $(CURDIR)/scripts/attach.gdb
endif
