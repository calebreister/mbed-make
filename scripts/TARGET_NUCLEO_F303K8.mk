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

FLOAT_ABI = softfp

CPU = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=$(FLOAT_ABI)

LINKER_SCRIPT = lib/mbed/$(TARGET)/TOOLCHAIN_GCC_ARM/STM32F303X8.ld

CC_SYMBOLS = -DTARGET_M4 -DTARGET_FF_ARDUINO -DTOOLCHAIN_GCC_ARM -DTOOLCHAIN_GCC -DTARGET_RTOS_M4_M7 -DTARGET_LIKE_MBED -DTARGET_CORTEX_M -D__FPU_PRESENT=1 -DTARGET_LIKE_CORTEX_M4 -DTARGET_NUCLEO_F303K8 -D__MBED__=1 -DTARGET_STM -DTARGET_STM32F303K8 -DTARGET_STM32F3 -D__CORTEX_M4 -DARM_MATH_CM4 

INCLUDE_PATHS = -I lib/ -I lib/mbed/ \
-I lib/mbed/$(TARGET)/ \
-I lib/mbed/$(TARGET)/TARGET_STM/ \
-I lib/mbed/$(TARGET)/TARGET_STM/TARGET_STM32F3/ \
-I lib/mbed/$(TARGET)/TOOLCHAIN_GCC_ARM/ \
-I lib/mbed/$(TARGET)/TARGET_STM/TARGET_STM32F3/$(TARGET)

SYS_OBJECTS = $(wildcard lib/mbed/$(TARGET)/TOOLCHAIN_GCC_ARM/*.o)

#OpenOCD arguments
OCD_ARGS = -f interface/stlink-v2-1.cfg -f target/stm32f3x.cfg
FLASH_SCRIPT = -f scripts/stm32-flash.cfg
