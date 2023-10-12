typedef enum logic [1:0] {
	MEMALU_OP_ADD    = 2'h0,
	MEMALU_OP_INCR   = 2'h1,
	MEMALU_OP_OFFSET = 2'h2
} memalu_op_t;

module MEMALU #(
	parameter WIDTH = 16
)(
	input  logic       [WIDTH-1:0] a,
	input  logic       [WIDTH-1:0] b,
	input  memalu_op_t             mode,
	input  logic                   control,
	output logic       [WIDTH-1:0] out
);

logic [WIDTH-1:0] result;

always_comb begin
	case (mode)
		MEMALU_OP_ADD:    result = a + b;
		MEMALU_OP_INCR:   result = a + 1;
		MEMALU_OP_OFFSET: result = a + b - 'h7F;
		default: result = 'x;
	endcase
end

assign out = control ? result : 'z;

endmodule