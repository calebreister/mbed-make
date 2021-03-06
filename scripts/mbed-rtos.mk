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

VPATH += lib/mbed-rtos/rtos lib/mbed-rtos/rtx/TARGET_CORTEX_M lib/mbed-rtos/rtx/TARGET_CORTEX_M/TARGET_RTOS_M4_M7/TOOLCHAIN_GCC

INCLUDE_PATHS += -I lib/mbed-rtos/rtos -I lib/mbed-rtos/rtx -I lib/mbed-rtos/rtx/TARGET_CORTEX_M

#Order matters here, since some of these come from assembly files
OBJECTS +=  $(call GETOBJ,lib/mbed-rtos/rtx/TARGET_CORTEX_M) \
$(call GETOBJ,lib/mbed-rtos/rtos) \
$(call GETOBJ,lib/mbed-rtos/rtx/TARGET_CORTEX_M/TARGET_RTOS_M4_M7/TOOLCHAIN_GCC)

#OBJECTS += obj/HAL_CM4.o obj/SVC_Table.o obj/rtos_idle.o obj/HAL_CM.o obj/RTX_Conf_CM.o obj/rt_CMSIS.o obj/rt_Event.o obj/rt_List.o obj/rt_Mailbox.o obj/rt_MemBox.o obj/rt_Memory.o obj/rt_Mutex.o obj/rt_Robin.o obj/rt_Semaphore.o obj/rt_System.o obj/rt_Task.o obj/rt_Time.o obj/rt_Timer.o obj/Mutex.o obj/RtosTimer.o obj/Semaphore.o obj/Thread.o
