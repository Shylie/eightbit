module VGA_DEVICE(
	input  logic       clk,
	input  logic [3:0] address,
	input  logic       enable,
	input  logic       mode,
	input  logic [7:0] data_in,
	output logic [7:0] data_out,
	input  logic       clk_pixel,
	output logic [7:0] red,
	output logic [7:0] green,
	output logic [7:0] blue,
	output logic       hsync,
	output logic       vsync,
	output logic       blank,
	output logic       sync
);

wire logic [7:0] reg_data[15:0];

wire logic [9:0] screen_x;
wire logic [9:0] screen_y;

logic square;

logic [7:0] paint_red;
logic [7:0] paint_green;
logic [7:0] paint_blue;

DEVICE_INTERFACE device_interface(
	.clk(clk),
	.address(address),
	.enable(enable),
	.mode(mode),
	.data_in(data_in),
	.data_out(data_out),
	.device_data(reg_data)
);

VGA_480P vga_timings(
	.clk_pixel(clk_pixel),
	.screen_x(screen_x),
	.screen_y(screen_y),
	.hsync(hsync),
	.vsync(vsync),
	.blank(blank)
);

always_comb begin
	square = (screen_x > 220 && screen_x < 420) && (screen_y > 140 && screen_y < 340);
	
	paint_red   = (square) ? 8'hFF : 4'h1F;
	paint_green = (square) ? 8'hFF : 4'h3F;
	paint_blue  = (square) ? 8'hFF : 4'h7F;
	
	red   = (blank) ? paint_red   : 8'h0;
	green = (blank) ? paint_green : 8'h0;
	blue  = (blank) ? paint_blue  : 8'h0;
end

//always_ff @ (posedge clk) begin
//end

assign sync = 0;

endmodule