module REGISTER #(
	parameter WIDTH = 8
)(
	input  logic                clk,
	input  reg_op_t             op,
	input  logic    [WIDTH-1:0] bus_in,
	output logic    [WIDTH-1:0] bus_out,
	output logic    [WIDTH-1:0] always_bus_out
);

/* verilator lint_off UNOPTFLAT */
logic [WIDTH-1:0] state;
/* verilator lint_on UNOPTFLAT */

initial begin
	state = '0;
end

always_ff @ (negedge clk) begin
	if (op == REG_OP_READ) begin
		state <= bus_in;
	end
end

assign bus_out = (op == REG_OP_WRITE) ? state : 'z;
assign always_bus_out = state;

endmodule