target remote | openocd -f interface/stlink-v2-1.cfg -f target/stm32f4x_stlink.cfg -f scripts/gdb-pipe.cfg
monitor halt
monitor gdb_sync
stepi
