#include "defs.asm"

JMPA loop
JMPA new_frame

#bank PROGRAM

loop:
MINC 0
MINC 0
MDEC 0
JUMP loop

new_frame:
RTIR
