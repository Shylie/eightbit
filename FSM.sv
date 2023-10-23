module FSM(
	input  logic             clk,
	input  logic       [3:0] instruction,
	input  logic             overflow,
	input  logic             zero,
	output reg_op_t          ir_low,
	output reg_op_t          ir_high,
	output reg_op_t          acc_low,
	output reg_op_t          acc_high,
	output reg_op_t          temp_register,
	output reg_op_t          pc,
	output logic             overflow_read,
	output logic             zero_read,
	output logic             mp8_low,
	output logic             mp8_high,
	output reg_op_t          mp16,
	output reg_op_t          swap_register,
	output logic             address_read,
	output logic             data_in,
	output logic             data_out,
	output logic             mem_enable,
	output reg_op_t          alu_data,
	output reg_op_t          alu_mem,
	output memalu_op_t       alu_mem_mode
);

/* verilator lint_off UNOPTFLAT */
logic [4:0] current_state;
logic [4:0] next_state;
/* verilator lint_on UNOPTFLAT */

always_ff @(posedge clk) begin
	current_state <= next_state;
end

always_comb begin
	casez ({instruction, overflow, zero, current_state})
		11'b??????00000: next_state = 5'b00001; // A -> B
		11'b??????00001: next_state = 5'b00010; // B -> C
		11'b??????00010: next_state = 5'b00011; // C -> INCPCA
		11'b??????00011: next_state = 5'b00100; // INCPCA -> INCPCB
		11'b0000??00100: next_state = 5'b00101; // INCPCB -> ASTLA
		11'b0001??00100: next_state = 5'b00111; // INCPCB -> ASTHA
		11'b0010??00100: next_state = 5'b01001; // INCPCB -> MSTLA
		11'b0011??00100: next_state = 5'b01011; // INCPCB -> MSTHA
		11'b0100??00100: next_state = 5'b01101; // INCPCB -> OPERA
		11'b0110??00100: next_state = 5'b11100; // INCPCB -> JMPA
		11'b0111?100100: next_state = 5'b11100; // INCPCB -> JMPA (JMZ)
		11'b10001?00100: next_state = 5'b11100; // INCPCB -> JMPA (JMO)
		11'b1001??00100: next_state = 5'b01111; // INCPCB -> LODA
		11'b1010??00100: next_state = 5'b10011; // INCPCB -> STOA
		11'b1011??00100: next_state = 5'b10111; // INCPCB -> SWPA
		11'b1100??00100: next_state = 5'b11010; // INCPCB -> MADDA
		11'b??????00101: next_state = 5'b00000; // ASTLA -> A
		11'b??????00111: next_state = 5'b00000; // ASTHA -> A
		11'b??????01001: next_state = 5'b00000; // MSTLA -> A
		11'b??????01011: next_state = 5'b00000; // MSTHA -> A
		11'b??????01101: next_state = 5'b01110; // OPERA -> OPERB
		11'b??????01110: next_state = 5'b00000; // OPERB -> A
		11'b??????01111: next_state = 5'b10000; // LODA -> LODB
		11'b??????10000: next_state = 5'b10001; // LODB -> LODC
		11'b??????10001: next_state = 5'b10010; // LODC -> LODD
		11'b??????10010: next_state = 5'b00000; // LODD -> A
		11'b??????10011: next_state = 5'b10100; // STOA -> STOB
		11'b??????10100: next_state = 5'b10101; // STOB -> STOC
		11'b??????10101: next_state = 5'b10110; // STOC -> STOD
		11'b??????10110: next_state = 5'b00000; // STOD -> A
		11'b??????10111: next_state = 5'b11000; // SWPA -> SWPB
		11'b??????11000: next_state = 5'b11001; // SWPB -> SWPC
		11'b??????11001: next_state = 5'b00000; // SWPC -> A
		11'b??????11010: next_state = 5'b11011; // MADDA -> MADDB
		11'b??????11011: next_state = 5'b00000; // MADDB -> A
		11'b??????11100: next_state = 5'b11101; // JMPA -> JMPB
		11'b??????11101: next_state = 5'b00000; // JMPB -> A
		default:         next_state = 5'b00000;
	endcase
end

always_comb begin
	ir_low = REG_OP_NONE;
	ir_high = REG_OP_NONE;
	acc_low = REG_OP_NONE;
	acc_high = REG_OP_NONE;
	temp_register = REG_OP_NONE;
	pc = REG_OP_NONE;
	overflow_read = 1'b0;
	zero_read = 1'b0;
	mp8_low = 1'b0;
	mp8_high = 1'b0;
	mp16 = REG_OP_NONE;
	swap_register = REG_OP_NONE;
	address_read = 1'b0;
	data_in = 1'b0;
	data_out = 1'b0;
	mem_enable = 1'b0;
	alu_data = REG_OP_NONE;
	alu_mem = REG_OP_NONE;
	alu_mem_mode = MEMALU_OP_ADD;
	
	case (current_state)
		// A
		5'h0: begin
			pc = REG_OP_WRITE;
			address_read = 1'b1;
		end
		
		// B
		5'h1: begin
			data_in = 1'b1;
			mem_enable = 1'b1;
		end
		
		// C
		5'h2: begin
			data_in = 1'b1;
			mem_enable = 1'b1;
			ir_low = REG_OP_READ;
			ir_high = REG_OP_READ;
		end
		
		// INCPCA
		5'h3: begin
			pc = REG_OP_WRITE;
			alu_mem_mode = MEMALU_OP_INCR;
			alu_mem = REG_OP_READ;
		end
		
		// INCPCB
		5'h4: begin
			alu_mem = REG_OP_WRITE;
			alu_mem_mode = MEMALU_OP_INCR;
			pc = REG_OP_READ;
		end
		
		// ASTLA
		5'h5: begin
			ir_low = REG_OP_WRITE;
			acc_low = REG_OP_READ;
		end
		
		// ASTHA
		5'h7: begin
			ir_low = REG_OP_WRITE;
			acc_high = REG_OP_READ;
		end
		
		// MSTLA
		5'h9: begin
			acc_low = REG_OP_WRITE;
			acc_high = REG_OP_WRITE;
			mp8_low = 1'b1;
		end
		
		// MSTHA
		5'hB: begin
			acc_low = REG_OP_WRITE;
			acc_high = REG_OP_WRITE;
			mp8_high = 1'b1;
		end
		
		// OPERA
		5'hD: begin
			acc_low = REG_OP_WRITE;
			acc_high = REG_OP_WRITE;
			alu_data = REG_OP_READ;
		end
		
		// OPER_B
		5'hE: begin
			alu_data = REG_OP_WRITE;
			acc_low = REG_OP_READ;
			acc_high = REG_OP_READ;
			overflow_read = 1'b1;
			zero_read = 1'b1;
		end
		
		// LODA
		5'hF: begin
			ir_low = REG_OP_SWRITENC;
			mp16 = REG_OP_WRITE;
			alu_mem = REG_OP_READ;
			alu_mem_mode = MEMALU_OP_OFFSET;
		end
		
		// LODB
		5'h10: begin
			alu_mem = REG_OP_WRITE;
			address_read = 1'b1;
		end
		
		// LODC
		5'h11: begin
			data_in = 1'b1;
			mem_enable = 1'b1;
		end
		
		// LODD
		5'h12: begin
			data_in = 1'b1;
			mem_enable = 1'b1;
			acc_low = REG_OP_READ;
			acc_high = REG_OP_READ;
		end
		
		// STOA
		5'h13: begin
			ir_low = REG_OP_SWRITENC;
			mp16 = REG_OP_WRITE;
			alu_mem = REG_OP_READ;
			alu_mem_mode = MEMALU_OP_OFFSET;
		end
		
		// STOB
		5'h14: begin
			alu_mem = REG_OP_WRITE;
			address_read = 1'b1;
		end
		
		// STOC
		5'h15: begin
			acc_low = REG_OP_WRITE;
			acc_high = REG_OP_WRITE;
		end
		
		// STOD
		5'h16: begin
			data_out = 1'b1;
			mem_enable = 1'b1;
			acc_low = REG_OP_WRITE;
			acc_high = REG_OP_WRITE;
		end
		
		// SWPA
		5'h17: begin
			temp_register = REG_OP_WRITE;
			swap_register = REG_OP_READ;
		end
		
		// SWPB
		5'h18: begin
			acc_low = REG_OP_WRITE;
			acc_high = REG_OP_WRITE;
			temp_register = REG_OP_READ;
		end
		
		// SWPC
		5'h19: begin
			swap_register = REG_OP_WRITE;
			acc_low = REG_OP_READ;
			acc_high = REG_OP_READ;
		end
		
		// MADDA
		5'h1A: begin
			acc_low = REG_OP_WRITE;
			acc_high = REG_OP_WRITE;
			mp16 = REG_OP_WRITE;
			alu_mem = REG_OP_READ;
		end
		
		// MADDB
		5'h1B: begin
			alu_mem = REG_OP_WRITE;
			mp16 = REG_OP_READ;
		end
		
		// JMPA
		5'h1C: begin
			acc_low = REG_OP_WRITE;
			acc_high = REG_OP_WRITE;
			pc = REG_OP_WRITE;
			alu_mem_mode = MEMALU_OP_OFFSET;
			alu_mem = REG_OP_READ;
		end
		
		// JMPB
		5'h1D: begin
			alu_mem = REG_OP_WRITE;
			alu_mem_mode = MEMALU_OP_OFFSET;
			pc = REG_OP_READ;
		end
		
		default: begin end
	endcase
end

endmodule