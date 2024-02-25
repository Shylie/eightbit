module REGISTER_BLOCK #(
	parameter WIDTH = 8,
	parameter DEPTH
)(
	input  logic                        clk,
	input  logic    [$clog2(DEPTH)-1:0] addr,
	input  logic                        save,
	input  logic                        restore,
	input  reg_op_t                     op,
	input  logic    [WIDTH-1:0]         bus_in,
	output logic    [WIDTH-1:0]         bus_out,
	output logic    [WIDTH-1:0]         always_bus_out
);

logic [WIDTH-1:0] always_buses_out[DEPTH];

generate
	genvar i;
	for (i = 0; i < DEPTH; i++) begin : loop
		REGISTER #(.WIDTH(WIDTH)) inst(
			.clk(clk),
			.save(save),
			.restore(restore),
			.op(addr == i ? op : REG_OP_NONE),
			.bus_in(bus_in),
			.bus_out(bus_out),
			.always_bus_out(always_buses_out[i])
		);
	end
endgenerate

assign always_bus_out = always_buses_out[addr];

endmodule