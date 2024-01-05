// https://projectf.io/posts/fpga-graphics/

module VGA_480P(
	input  wire logic       clk_pixel,
	output logic      [9:0] screen_x,
	output logic      [9:0] screen_y,
	output logic            hsync,
	output logic            vsync,
	output logic            blank
);

localparam HA_END = 639;         // end of active pixels
localparam HS_STA = HA_END + 16; // sync starts after front porch
localparam HS_END = HS_STA + 96; // sync ends
localparam LINE   = 799;         // last pixel on line (after back porch)

localparam VA_END = 479;         // end of active pixels
localparam VS_STA = VA_END + 10; // sync starts after front porch
localparam VS_END = VS_STA + 2;  // sync ends
localparam SCREEN = 524;         // last line on screen (after back porch)

always_comb begin
	hsync = ~(screen_x >= HS_STA && screen_x <= HS_END); // invert due to negative polarity
	vsync = ~(screen_y >= VS_STA && screen_y <= VS_END); // invert due to negative polarity
	blank =  (screen_x <= HA_END && screen_y <= VA_END);
end

always_ff @ (posedge clk_pixel) begin
	if (screen_x == LINE) begin
		screen_x <= 0;
		screen_y <= (screen_y == SCREEN) ? 0 : screen_y + 1;
	end else begin	
		screen_x <= screen_x + 1;
	end
end

endmodule