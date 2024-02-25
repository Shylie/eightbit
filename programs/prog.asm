#include "defs.asm"

JMPA start
JMPA new_frame

#bank PROGRAM

start:
AST 69
SWAP 0
AST 96
SWAP 1
AST 45
SWAP 2

loop:
SWAP 0
COPY 0
SWAP 1
SWAP 2
SWAP 0

JUMP loop

new_frame:
RTIR
