// https://projectf.io/posts/fpga-graphics/
// https://projectf.io/posts/display-signals/

module VGA_TIMINGS #(
	parameter COORD_WIDTH = 16,
	parameter H_RES  = 640,
	parameter H_FP   = 16,
	parameter H_SYNC = 96,
	parameter H_BP   = 48,
	parameter V_RES  = 480,
	parameter V_FP   = 10,
	parameter V_SYNC = 2,
	parameter V_BP   = 33,
	parameter H_POL  = 0,
	parameter V_POL  = 0
)(
	input  wire logic                     clk_pixel,
	output logic                          hsync,
	output logic                          vsync,
	output logic                          data_enable,
	output logic                          frame,
	output logic                          line,
	output logic signed [COORD_WIDTH-1:0] screen_x,
	output logic signed [COORD_WIDTH-1:0] screen_y
);

localparam signed H_START  = 0 - H_FP - H_SYNC - H_BP;
localparam signed HS_START = H_START + H_FP;
localparam signed HS_END   = HS_START + H_SYNC;
localparam signed HA_START = 0;
localparam signed HA_END   = H_RES - 1;

localparam signed V_START  = 0 - V_FP - V_SYNC - V_BP;
localparam signed VS_START = V_START + V_FP;
localparam signed VS_END   = VS_START + V_SYNC;
localparam signed VA_START = 0;
localparam signed VA_END   = V_RES - 1;

logic signed [COORD_WIDTH-1:0] x;
logic signed [COORD_WIDTH-1:0] y;

always_ff @ (posedge clk_pixel) begin
	hsync <= H_POL ? (x >= HS_START && x < HS_END) : ~(x >= HS_START && x < HS_END);
	vsync <= V_POL ? (y >= VS_START && y < VS_END) : ~(y >= VS_START && y < VS_END);
end

always_ff @ (posedge clk_pixel) begin
	data_enable <= (y >= VA_START && x >= HA_START);
	frame       <= (y == V_START && x == H_START);
	line        <= (y >= VA_START && x == H_START);
end

always_ff @ (posedge clk_pixel) begin
	if (x == HA_END) begin
		x <= H_START;
		y <= (y == VA_END) ? V_START : y + 1;
	end else begin
		x <= x + 1;
	end
end

always_ff @ (posedge clk_pixel) begin
	screen_x <= x;
	screen_y <= y;
end

endmodule