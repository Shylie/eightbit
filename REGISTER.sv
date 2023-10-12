module REGISTER #(
	parameter WIDTH = 8
)(
	input  logic             read_enable,
	input  logic             write_enable,
	input  logic [WIDTH-1:0] bus_in,
	output logic [WIDTH-1:0] bus_out,
	output logic [WIDTH-1:0] always_bus_out
);

/* verilator lint_off UNOPTFLAT */
logic [WIDTH-1:0] state;
/* verilator lint_on UNOPTFLAT */

always_latch begin
	if (read_enable && !write_enable) begin
		state <= bus_in;
	end
end

assign bus_out = (write_enable && !read_enable) ? state : 'z;
assign always_bus_out = state;

endmodule