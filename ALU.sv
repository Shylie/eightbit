typedef enum logic [3:0] {
	ALU_OP_NOT  = 4'h0,
	ALU_OP_OR   = 4'h1,
	ALU_OP_AND  = 4'h2,
	ALU_OP_XOR  = 4'h3,
	ALU_OP_ADD  = 4'h4,
	ALU_OP_SUB  = 4'h5,
	ALU_OP_SHL  = 4'h6,
	ALU_OP_LSHR = 4'h7,
	ALU_OP_ASHR = 4'h8
} alu_op_t;

module ALU #(
	parameter WIDTH = 8
)(
	input  logic    [WIDTH-1:0] a,
	input  logic    [WIDTH-1:0] b,
	input  alu_op_t             mode,
	input  logic                control,
	output logic    [WIDTH-1:0] out,
	output logic                overflow,
	output logic                zero
);

logic    [WIDTH-1:0] result;
logic                overflow_r;

always_comb begin
	overflow_r = 'x;
	case (mode)
		ALU_OP_NOT:  result = ~a;
		ALU_OP_OR:   result = a | b;
		ALU_OP_AND:  result = a & b;
		ALU_OP_XOR:  result = a ^ b;
		ALU_OP_ADD: {overflow_r, result} = a + b;
		ALU_OP_SUB: {overflow_r, result} = a - b;
		ALU_OP_SHL:  result = a << 1;
		ALU_OP_LSHR: result = a >> 1;
		ALU_OP_ASHR: result = a >>> 1;
		default: result = 'x;
	endcase
end

assign out = control ? result : 'z;
assign overflow = control ? overflow_r : 'z;
assign zero = control ? !(|result) : 'z;

endmodule
