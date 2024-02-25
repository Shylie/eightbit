#once

#const(noemit) WORD_SIZE = 8
#const(noemit) INTERRUPT_SIZE = 7
#const(noemit) INTERRUPT_COUNT = 16
#const(noemit) INTERRUPT_SPACE = INTERRUPT_SIZE * (INTERRUPT_COUNT + 1)

#bankdef INTERRUPT_HANDLERS
{
	#bits WORD_SIZE
	#addr 0
	#size INTERRUPT_SPACE
	#outp 0
}

#bankdef PROGRAM
{
	#bits WORD_SIZE
	#addr INTERRUPT_SPACE
	#addr_end 0xFF80
	#outp INTERRUPT_SPACE * WORD_SIZE
}

#bank INTERRUPT_HANDLERS

#ruledef
{
	ASTL {value: u4} => 0x0 @ value
	ASTH {value: u4} => 0x1 @ value
	MSTL             => 0x20
	MSTH             => 0x30
	NOT              => 0x40
	OR               => 0x41
	AND              => 0x42
	XOR              => 0x43
	ADD              => 0x44
	SUB              => 0x45
	SHL              => 0x46
	SHRL             => 0x47
	SHRA             => 0x48
	MUL              => 0x49
	DIV              => 0x4A
	CMP              => 0x4B
	MINC {value: u2} => 0x5 @ 0b01 @ value
	MDEC {value: u2} => 0x5 @ 0b10 @ value
	JUMP             => 0x60
	JMPZ             => 0x70
	JMPO             => 0x80
	JUMP {dest: u16} =>
	{
		assert(dest - $ >= -124)
		offset = (dest - $ + 0x7D)
		assert(offset <= 0xFF)
		asm { ASTL {offset}`4 } @ asm { ASTH ({offset} >> 4)`4 } @ 0x60
	}
	JMPZ {dest: u16} =>
	{
		assert(dest - $ >= -124)
		offset = (dest - $ + 0x7D)
		assert(offset <= 0xFF)
		asm { ASTL {offset}`4 } @ asm { ASTH ({offset} >> 4)`4 } @ 0x70
	}
	JMPO {dest: u16} =>
	{
		assert(dest - $ >= -124)
		offset = (dest - $ + 0x7D)
		assert(offset <= 0xFF)
		asm { ASTL {offset}`4 } @ asm { ASTH ({offset} >> 4)`4 } @ 0x80
	}
	LOAD {offs:  u4} => 0x9 @ offs
	STOR {offs:  u4} => 0xA @ offs
	SWAP             => 0xB0
	SWAP {addr:  u4} => 0xB @ addr
	JMPA             => 0xC0
	JMPA {dest: u16} => asm
	{
		ASTL {dest}`4
		ASTH ({dest} >> 4)`4
		MSTL
		ASTL ({dest} >> 8)`4
		ASTH ({dest} >> 12)`4
		MSTH
	} @ 0xC0
	COPY {addr:  u4} => 0xD @ addr
	RTIR             => 0xF0

	AST {value: u8}  => asm
	{
		ASTL {value}`4
		ASTH ({value} >> 4)`4
	}

	MST {value: u16} => asm
	{
		ASTL {value}`4
		ASTH ({value} >> 4)`4
		MSTL
		ASTL ({value} >> 8)`4
		ASTH ({value} >> 12)`4
		MSTH
	}
}
