module MEMALU #(
	parameter HALF_WIDTH = 8
)(
	input  logic                          clk,
	input  logic       [2*HALF_WIDTH-1:0] a,
	input  logic       [HALF_WIDTH-1:0]   b,
	input  memalu_op_t                    mode,
	input  reg_op_t                       control,
	output logic       [2*HALF_WIDTH-1:0] out
);

logic [2*HALF_WIDTH-1:0] a_reg;
logic [HALF_WIDTH-1:0] b_reg;
logic [2*HALF_WIDTH-1:0] result;

always_ff @ (negedge clk) begin
	if (control == REG_OP_READ) begin
		a_reg <= a;
		b_reg <= b;
	end
end

always_comb begin
	case (mode)
		MEMALU_OP_ADD:    result = a_reg + 16'(b_reg);
		MEMALU_OP_INCR:   result = a_reg + 16'h0001;
		MEMALU_OP_OFFSET: result = a_reg + 16'(b_reg) - 'h80;
		default: result = 'x;
	endcase
end

assign out = (control == REG_OP_WRITE) ? result : 'z;

endmodule