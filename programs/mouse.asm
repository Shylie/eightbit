#include "defs.asm"

; enable data reporting
MST 0xFFA0
AST 0xF4
STOR 6
AST 1
STOR 7

; check if new data has been reported
loop:
MST 0xFFA0
LOAD 5
SWAP
MST last_recv_id
LOAD 0
CMP
; no new data if id and last id are equal (CMP = 0)
JMPZ loop
; store new id as last seen id
SWAP
STOR 0

; update LEDs
MST 0xFFA0
LOAD 1
SWAP
AST 16
MUL
SWAP
MST 0xFF80
SWAP
STOR 0
STOR 1
STOR 2
STOR 3
STOR 4
STOR 5
STOR 6
STOR 7
STOR 8
STOR 9
JUMP loop

last_recv_id: #res 1
