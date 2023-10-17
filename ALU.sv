module ALU #(
	parameter WIDTH = 8
)(
	input  logic                clk,
	input  logic    [WIDTH-1:0] a,
	input  logic    [WIDTH-1:0] b,
	input  alu_op_t             mode,
	input  reg_op_t             control,
	output logic    [WIDTH-1:0] out,
	output logic                overflow,
	output logic                zero
);

logic [WIDTH-1:0] a_reg;
logic [WIDTH-1:0] b_reg;
alu_op_t          mode_reg;
logic [WIDTH-1:0] result;
logic             overflow_r;

always_ff @ (negedge clk) begin
	if (control == REG_OP_READ) begin
		a_reg <= a;
		b_reg <= b;
		mode_reg <= mode;
	end
end

always_comb begin
	overflow_r = 'x;
	case (mode_reg)
		ALU_OP_NOT:  result = ~a_reg;
		ALU_OP_OR:   result = a_reg | b_reg;
		ALU_OP_AND:  result = a_reg & b_reg;
		ALU_OP_XOR:  result = a_reg ^ b_reg;
		ALU_OP_ADD: {overflow_r, result} = a_reg + b_reg;
		ALU_OP_SUB: {overflow_r, result} = a_reg - b_reg;
		ALU_OP_SHL:  result = a_reg << 1;
		ALU_OP_LSHR: result = a_reg >> 1;
		ALU_OP_ASHR: result = signed'(a_reg) >>> 1;
		default: result = 'x;
	endcase
end

assign out = (control == REG_OP_WRITE) ? result : 'z;
assign overflow = (control == REG_OP_WRITE) ? overflow_r : 'z;
assign zero = (control == REG_OP_WRITE) ? !(|result) : 'z;

endmodule
