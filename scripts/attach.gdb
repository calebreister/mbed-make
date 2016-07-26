target remote | openocd -f interface/stlink-v2-1.cfg -f target/stm32f3x.cfg -f ../scripts/gdb-pipe.cfg
dir src
monitor halt
monitor gdb_sync
stepi
