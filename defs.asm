#once

#bankdef PROGRAM
{
	#bits 8
	#addr 0
	#size 0x10000
	#outp 0
}

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
	INPUT            => 0x4F
	JUMP             => 0x60
	JMPZ             => 0x70
	JMPO             => 0x80
	JUMP {dest: u16} =>
	{
		assert(dest - $ >= -124)
		offset = (dest - $ + 0x7C)
		assert(offset <= 0xFF)
		asm { ASTL {offset}`4 } @ asm { ASTH ({offset} >> 4)`4 } @ 0x60
	}
	JMPZ {dest: u16} =>
	{
		assert(dest - $ >= -124)
		offset = (dest - $ + 0x7C)
		assert(offset <= 0xFF)
		asm { ASTL {offset}`4 } @ asm { ASTH ({offset} >> 4)`4 } @ 0x70
	}
	JMPO {dest: u16} =>
	{
		assert(dest - $ >= -124)
		offset = (dest - $ + 0x7C)
		assert(offset <= 0xFF)
		asm { ASTL {offset}`4 } @ asm { ASTH ({offset} >> 4)`4 } @ 0x80
	}
	LOAD {offs:  u4} => 0x9 @ offs
	STOR {offs:  u4} => 0xA @ offs
	SWAP             => 0xB0
	MADD             => 0xC0

	AST {value: u8}  =>
	{
		assert(value <= 0xFF)
		asm
		{
			ASTL {value}`4
			ASTH ({value} >> 4)`4
		}
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

	MEMSWAP {offs1: u4}, {offs2: u4} => asm
	{
		LOAD {offs1}
		SWAP
		LOAD {offs2}
		STOR {offs1}
		SWAP
		STOR {offs2}
	}

	MEMSWAP {addr: u16}, {offs1: u4}, {offs2: u4} => asm
	{
		MST {addr}
		LOAD {offs1}
		SWAP
		LOAD {offs2}
		STOR {offs1}
		SWAP
		STOR {offs2}
	}
}
