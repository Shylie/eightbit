#include "defs.asm"

loop:
MST 0xFF90 ; BUTTON_DEVICE
LOAD 0 ; button 0
SWAP
MST last_button
AST 1
CMP
JMPZ button_pushed
; not pushed
SWAP
STOR 0
JUMP loop

button_pushed:
LOAD 0
CMP
JMPZ loop ; same, no need to store

; not the same, store new value
SWAP
STOR 0

; Increment LED values by 8. Reset on overflow. 
MST 0xFF80 ; LED_DEVICE
LOAD 0
SWAP
AST 8
ADD
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

last_button: #res 1
