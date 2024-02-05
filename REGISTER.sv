module REGISTER #(
	parameter WIDTH = 8
)(
	input  logic                clk,
	input  logic                save,
	input  logic                restore,
	input  reg_op_t             op,
	input  logic    [WIDTH-1:0] bus_in,
	output logic    [WIDTH-1:0] bus_out,
	output logic    [WIDTH-1:0] always_bus_out
);

/* verilator lint_off UNOPTFLAT */
logic [WIDTH-1:0] state;
logic [WIDTH-1:0] saved_state;
/* verilator lint_on UNOPTFLAT */

initial begin
	state = '0;
	saved_state = '0;
end

always_ff @ (negedge clk) begin
	if (op == REG_OP_READ) begin
		state <= bus_in;
	end
	
	if (save) begin
		saved_state <= state;
	end else if (restore) begin
		state <= saved_state;
	end
end

assign bus_out = (op == REG_OP_WRITE) ? state : 'z;
assign always_bus_out = state;

endmodule