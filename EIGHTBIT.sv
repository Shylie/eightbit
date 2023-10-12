module EIGHTBIT(
	input  logic clk,
	input  logic [3:0] buttons,
	input  logic [9:0] switches,
	output logic [9:0] LED
);

logic [3:0] inverse_buttons;

REGISTER #(.WIDTH(10)) acc(
	.read_enable(inverse_buttons[0]),
	.write_enable(inverse_buttons[1]),
	.bus_in(switches),
	.bus_out(LED)
);

assign inverse_buttons = ~buttons;

endmodule