module SPLIT_REGISTER #(
	parameter HALF_WIDTH = 4
)(
	input  logic                       clk,
	input  reg_op_t                    op_low,
	input  reg_op_t                    op_high,
	input  logic                       bus_b_low,
	input  logic                       bus_b_high,
	input  logic    [HALF_WIDTH*2-1:0] bus_in,
	input  logic    [HALF_WIDTH-1:0]   bus_b_in,
	output logic    [HALF_WIDTH*2-1:0] bus_out,
	output logic    [HALF_WIDTH*2-1:0] always_bus_out
);

/* verilator lint_off UNOPTFLAT */
logic [HALF_WIDTH*2-1:0] state;
/* verilator lint_on UNOPTFLAT */

initial begin
	state = '0;
end

always_ff @ (negedge clk) begin
	if (bus_b_low) begin
		state[HALF_WIDTH-1:0] <= bus_b_in;
	end
	
	if (bus_b_high) begin
		state[2*HALF_WIDTH-1:HALF_WIDTH] <= bus_b_in;
	end

	if (op_low == REG_OP_READ) begin
		state[HALF_WIDTH-1:0] <= bus_in[HALF_WIDTH-1:0];
	end
	
	if (op_high == REG_OP_READ) begin
		state[2*HALF_WIDTH-1:HALF_WIDTH] <= bus_in[2*HALF_WIDTH-1:HALF_WIDTH];
	end
end

assign bus_out[HALF_WIDTH-1:0] = (op_low == REG_OP_WRITE) ? state[HALF_WIDTH-1:0] : ((op_low == REG_OP_NONE && op_high == REG_OP_WRITE) ? state[2*HALF_WIDTH-1:HALF_WIDTH] : 'z);
assign bus_out[2*HALF_WIDTH-1:HALF_WIDTH] = (op_high == REG_OP_WRITE) ? state[2*HALF_WIDTH-1:HALF_WIDTH] : ((op_high == REG_OP_NONE && op_low == REG_OP_WRITE) ? state[HALF_WIDTH-1:0] : 'z);
assign always_bus_out = state;

endmodule