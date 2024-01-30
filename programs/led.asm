#include "defs.asm"

JMPA loop
JMPA new_frame

#bank PROGRAM

loop:
; load LED 0 value
MST 0xFF80
LOAD 0
; add one
SWAP
AST 1
ADD
; store back
STOR 0
; if zero, increment LED 1 as well
JMPZ next
JUMP loop

next:
; load LED 1 value
MST 0xFF80
LOAD 1
; add one
SWAP
AST 1
ADD
; store back
STOR 1
JMPZ nextnext
JUMP loop

nextnext:
; load LED 2 value
MST 0xFF80
LOAD 2
; add one
SWAP
AST 1
ADD
; store back
STOR 2
; go back to main loop
JUMP loop

new_frame:
MST 0xFF80
LOAD 9
SWAP
AST 1
ADD
STOR 9
RTIR
