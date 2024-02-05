module FSM #(
	parameter INTERRUPT_WIDTH = 4
)(
	input  logic                            clk,
	input  logic                      [3:0] instruction,
	input  logic                            overflow,
	input  logic                            zero,
	input  logic      [INTERRUPT_WIDTH-1:0] interrupt,
	output reg_op_t                         ir_low,
	output reg_op_t                         ir_high,
	output reg_op_t                         acc_low,
	output reg_op_t                         acc_high,
	output reg_op_t                         temp_register,
	output reg_op_t                         pc,
	output logic                            overflow_read,
	output logic                            zero_read,
	output logic                            mp8_low,
	output logic                            mp8_high,
	output reg_op_t                         mp16,
	output reg_op_t                         swap_register,
	output logic                            address_read,
	output logic                            data_in,
	output logic                            mem_enable,
	output reg_op_t                         alu_data,
	output reg_op_t                         alu_mem,
	output memalu_op_t                      alu_mem_mode,
	output logic                            processing_interrupt,
	output logic                     [15:0] address,
	output logic                            save_state,
	output logic                            restore_state
);

/* verilator lint_off UNOPTFLAT */
logic [5:0]  current_state;
logic [5:0]  next_state;
/* verilator lint_on UNOPTFLAT */

logic [15:0] address_out;
logic        output_address;

initial begin
	processing_interrupt = 0;
	output_address = 0;
end

always_ff @(posedge clk) begin
	current_state <= next_state;
end

always_comb begin
	casez ({processing_interrupt, |interrupt, instruction, overflow, zero, current_state})
		14'b?0??????011110: next_state = 6'b000000; // CHECK_INTERRUPT -> A (no interrupt)
		14'b01??????011110: next_state = 6'b011111; // CHECK_INTERRUPT -> HANDLE_INTERRUPT_A (found an interrupt)
		14'b11??????011110: next_state = 6'b000000; // CHECK_INTERRUPT -> A (found an interrupt, but already processing one)
		14'b????????000000: next_state = 6'b000001; // A -> B
		14'b????????000001: next_state = 6'b000010; // B -> C
		14'b????????000010: next_state = 6'b000011; // C -> INCPCA
		14'b????????000011: next_state = 6'b000100; // INCPCA -> INCPCB
		14'b??0000??000100: next_state = 6'b000101; // INCPCB -> ASTLA
		14'b??0001??000100: next_state = 6'b000111; // INCPCB -> ASTHA
		14'b??0010??000100: next_state = 6'b001001; // INCPCB -> MSTLA
		14'b??0011??000100: next_state = 6'b001011; // INCPCB -> MSTHA
		14'b??0100??000100: next_state = 6'b001101; // INCPCB -> OPERA
		14'b??0110??000100: next_state = 6'b011100; // INCPCB -> JMPA
		14'b??0111?1000100: next_state = 6'b011100; // INCPCB -> JMPA (JMZ)
		14'b??10001?000100: next_state = 6'b011100; // INCPCB -> JMPA (JMO)
		14'b??1001??000100: next_state = 6'b001111; // INCPCB -> LODA
		14'b??1010??000100: next_state = 6'b010011; // INCPCB -> STOA
		14'b??1011??000100: next_state = 6'b010111; // INCPCB -> SWPA
		14'b??1100??000100: next_state = 6'b011010; // INCPCB -> JMPAA
		14'b??1111??000100: next_state = 6'b100001; // INCPCB -> RTIRA
		14'b????????000101: next_state = 6'b011110; // ASTLA -> CHECK_INTERRUPT
		14'b????????000111: next_state = 6'b011110; // ASTHA -> CHECK_INTERRUPT
		14'b????????001001: next_state = 6'b011110; // MSTLA -> CHECK_INTERRUPT
		14'b????????001011: next_state = 6'b011110; // MSTHA -> CHECK_INTERRUPT
		14'b????????001101: next_state = 6'b001110; // OPERA -> OPERB
		14'b????????001110: next_state = 6'b011110; // OPERB -> CHECK_INTERRUPT
		14'b????????001111: next_state = 6'b010000; // LODA -> LODB
		14'b????????010000: next_state = 6'b010001; // LODB -> LODC
		14'b????????010001: next_state = 6'b010010; // LODC -> LODD
		14'b????????010010: next_state = 6'b011110; // LODD -> CHECK_INTERRUPT
		14'b????????010011: next_state = 6'b010100; // STOA -> STOB
		14'b????????010100: next_state = 6'b010101; // STOB -> STOC
		14'b????????010101: next_state = 6'b010110; // STOC -> STOD
		14'b????????010110: next_state = 6'b011110; // STOD -> CHECK_INTERRUPT
		14'b????????010111: next_state = 6'b011000; // SWPA -> SWPB
		14'b????????011000: next_state = 6'b011001; // SWPB -> SWPC
		14'b????????011001: next_state = 6'b011110; // SWPC -> CHECK_INTERRUPT
		14'b????????011010: next_state = 6'b011011; // JMPAA -> JMPAB
		14'b????????011011: next_state = 6'b011110; // JMPAB -> CHECK_INTERRUPT
		14'b????????011100: next_state = 6'b011101; // JMPA -> JMPB
		14'b????????011101: next_state = 6'b011110; // JMPB -> CHECK_INTERRUPT
		14'b????????100001: next_state = 6'b011110; // RTIRA -> CHECK_INTERRUPT
		14'b????????011111: next_state = 6'b100000; // HANDLE_INTERRUPT_A -> HANDLE_INTERRUPT_B
		14'b????????100000: next_state = 6'b000000; // HANDLE_INTERRUPT_B -> A
		default:            next_state = 6'b011110; // invalid state
	endcase
end

always_ff @ (posedge clk) begin
	ir_low <= REG_OP_NONE;
	ir_high <= REG_OP_NONE;
	acc_low <= REG_OP_NONE;
	acc_high <= REG_OP_NONE;
	temp_register <= REG_OP_NONE;
	pc <= REG_OP_NONE;
	overflow_read <= 1'b0;
	zero_read <= 1'b0;
	mp8_low <= 1'b0;
	mp8_high <= 1'b0;
	mp16 <= REG_OP_NONE;
	swap_register <= REG_OP_NONE;
	address_read <= 1'b0;
	data_in <= 1'b0;
	mem_enable <= 1'b0;
	alu_data <= REG_OP_NONE;
	alu_mem <= REG_OP_NONE;
	alu_mem_mode <= MEMALU_OP_ADD;
	output_address <= 1'b0;
	save_state <= 1'b0;
	restore_state <= 1'b0;
	
	case (current_state)
		// A
		6'h0: begin
			pc <= REG_OP_WRITE;
			address_read <= 1'b1;
		end
		
		// B
		6'h1: begin
			data_in <= 1'b1;
			mem_enable <= 1'b1;
		end
		
		// C
		6'h2: begin
			data_in <= 1'b1;
			mem_enable <= 1'b1;
			ir_low <= REG_OP_READ;
			ir_high <= REG_OP_READ;
		end
		
		// INCPCA
		6'h3: begin
			pc <= REG_OP_WRITE;
			alu_mem_mode <= MEMALU_OP_INCR;
			alu_mem <= REG_OP_READ;
		end
		
		// INCPCB
		6'h4: begin
			alu_mem <= REG_OP_WRITE;
			alu_mem_mode <= MEMALU_OP_INCR;
			pc <= REG_OP_READ;
		end
		
		// ASTLA
		6'h5: begin
			ir_low <= REG_OP_WRITE;
			acc_low <= REG_OP_READ;
		end
		
		// ASTHA
		6'h7: begin
			ir_low <= REG_OP_WRITE;
			acc_high <= REG_OP_READ;
		end
		
		// MSTLA
		6'h9: begin
			acc_low <= REG_OP_WRITE;
			acc_high <= REG_OP_WRITE;
			mp8_low <= 1'b1;
		end
		
		// MSTHA
		6'hB: begin
			acc_low <= REG_OP_WRITE;
			acc_high <= REG_OP_WRITE;
			mp8_high <= 1'b1;
		end
		
		// OPERA
		6'hD: begin
			acc_low <= REG_OP_WRITE;
			acc_high <= REG_OP_WRITE;
			alu_data <= REG_OP_READ;
		end
		
		// OPER_B
		6'hE: begin
			alu_data <= REG_OP_WRITE;
			acc_low <= REG_OP_READ;
			acc_high <= REG_OP_READ;
			overflow_read <= 1'b1;
			zero_read <= 1'b1;
		end
		
		// LODA
		6'hF: begin
			ir_low <= REG_OP_SWRITENC;
			mp16 <= REG_OP_WRITE;
			alu_mem <= REG_OP_READ;
			alu_mem_mode <= MEMALU_OP_OFFSET;
		end
		
		// LODB
		6'h10: begin
			alu_mem <= REG_OP_WRITE;
			address_read <= 1'b1;
		end
		
		// LODC
		6'h11: begin
			data_in <= 1'b1;
			mem_enable <= 1'b1;
		end
		
		// LODD
		6'h12: begin
			data_in <= 1'b1;
			mem_enable <= 1'b1;
			acc_low <= REG_OP_READ;
			acc_high <= REG_OP_READ;
		end
		
		// STOA
		6'h13: begin
			ir_low <= REG_OP_SWRITENC;
			mp16 <= REG_OP_WRITE;
			alu_mem <= REG_OP_READ;
			alu_mem_mode <= MEMALU_OP_OFFSET;
		end
		
		// STOB
		6'h14: begin
			alu_mem <= REG_OP_WRITE;
			address_read <= 1'b1;
		end
		
		// STOC
		6'h15: begin
			acc_low <= REG_OP_WRITE;
			acc_high <= REG_OP_WRITE;
		end
		
		// STOD
		6'h16: begin
			mem_enable <= 1'b1;
			acc_low <= REG_OP_WRITE;
			acc_high <= REG_OP_WRITE;
		end
		
		// SWPA
		6'h17: begin
			temp_register <= REG_OP_WRITE;
			swap_register <= REG_OP_READ;
		end
		
		// SWPB
		6'h18: begin
			acc_low <= REG_OP_WRITE;
			acc_high <= REG_OP_WRITE;
			temp_register <= REG_OP_READ;
		end
		
		// SWPC
		6'h19: begin
			swap_register <= REG_OP_WRITE;
			acc_low <= REG_OP_READ;
			acc_high <= REG_OP_READ;
		end
		
		// JMPAA
		6'h1A: begin
			mp16 <= REG_OP_WRITE;
			pc <= REG_OP_READ;
		end
		
		// JMPAB
		6'h1B: begin
			// nop
		end
		
		// JMPA
		6'h1C: begin
			acc_low <= REG_OP_WRITE;
			acc_high <= REG_OP_WRITE;
			pc <= REG_OP_WRITE;
			alu_mem_mode <= MEMALU_OP_OFFSET;
			alu_mem <= REG_OP_READ;
		end
		
		// JMPB
		6'h1D: begin
			alu_mem <= REG_OP_WRITE;
			alu_mem_mode <= MEMALU_OP_OFFSET;
			pc <= REG_OP_READ;
		end
		
		// CHECK_INTERRUPT
		6'h1E: begin
			// do nothing?
		end
		
		// HANDLE_INTERRUPT_A
		6'h1F: begin
			processing_interrupt <= 1'b1;
			save_state <= 1'b1;
		end
		
		// HANDLE_INTERRUPT_B
		6'h20: begin
			address_out <= 7 * interrupt;
			pc <= REG_OP_READ;
			output_address <= 1'b1;
		end
		
		// RTIRA
		6'h21: begin
			restore_state <= 1'b1;
			processing_interrupt <= 1'b0;
		end
		
		default: begin end
	endcase
end

assign address = (output_address) ? address_out : 'z;

endmodule