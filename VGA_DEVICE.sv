module VGA_DEVICE(
	input  logic       clk,
	input  logic [4:0] address,
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
	output logic       data_enable
);

localparam COORD_WIDTH = 16;

localparam CHANNEL_WIDTH     = 8;
localparam COLOR_WIDTH       = 3 * CHANNEL_WIDTH;
localparam COLOR_INDEX_WIDTH = 8;

localparam FB_WIDTH         = 160;
localparam FB_HEIGHT        = 120;
localparam FB_PIXELS        = FB_WIDTH * FB_HEIGHT;
localparam FB_ADDRESS_WIDTH = $clog2(FB_PIXELS);
localparam FB_DATA_WIDTH    = COLOR_INDEX_WIDTH;
localparam FB_SCALE         = 4;

localparam PL_ADDRESS_WIDTH = FB_DATA_WIDTH;
localparam PL_DATA_WIDTH    = COLOR_WIDTH;

localparam LATENCY = 3;

logic [7:0] current_value;

logic [7:0] reg_data[31:0];

logic signed [COORD_WIDTH-1:0] screen_x;
logic signed [COORD_WIDTH-1:0] screen_y;

logic frame;
logic line;
logic data_enable_internal;

logic frame_sys;
logic line_sys;
logic line0_sys;

logic current_frame;
logic write_fb;
logic [FB_ADDRESS_WIDTH-1:0] fb_address_write;
logic [FB_ADDRESS_WIDTH-1:0] fb_address_read;
logic [FB_DATA_WIDTH-1:0] fb_data_in;
logic [FB_DATA_WIDTH-1:0] fb_data_out_0;
logic [FB_DATA_WIDTH-1:0] fb_data_out_1;
logic [FB_DATA_WIDTH-1:0] fb_data_out;

logic [7:0] paint_red;
logic [7:0] paint_green;
logic [7:0] paint_blue;
logic [7:0] display_red;
logic [7:0] display_green;
logic [7:0] display_blue;

logic write_pl;
logic [PL_ADDRESS_WIDTH-1:0] pl_address_write;
logic [PL_ADDRESS_WIDTH-1:0] pl_address_read;
logic [PL_DATA_WIDTH-1:0] pl_data_in;
logic [PL_DATA_WIDTH-1:0] pl_data_out;

logic hsync_internal;
logic vsync_internal;

logic linebuffer_write;
logic linebuffer_read;

logic [$clog2(FB_SCALE):0] count_linebuffer_line;
logic linebuffer_line;
logic [$clog2(FB_WIDTH)-1:0] count_linebuffer_x;

VGA_TIMINGS #(.COORD_WIDTH(COORD_WIDTH)) vga_timings(
	.clk_pixel(clk_pixel),
	.hsync(hsync_internal),
	.vsync(vsync_internal),
	.data_enable(data_enable_internal),
	.frame(frame),
	.line(line),
	.screen_x(screen_x),
	.screen_y(screen_y)
);

BRAM #(.DATA_WIDTH(FB_DATA_WIDTH), .DEPTH(FB_PIXELS),
`ifdef verilator
	.INIT_FILE("fb.mem")
`else
	.INIT_FILE("framebuffer.mif")
`endif
) fb0(
	.data(fb_data_in),
	.wraddress(fb_address_write),
	.wren(!current_frame && write_fb),
	.rdaddress(fb_address_read),
	.wrclock(clk),
	.rdclock(clk),
	.q(fb_data_out_0)
);

BRAM #(.DATA_WIDTH(FB_DATA_WIDTH), .DEPTH(FB_PIXELS),
`ifdef verilator
	.INIT_FILE("fb.mem")
`else
	.INIT_FILE("framebuffer.mif")
`endif
) fb1(
	.data(fb_data_in),
	.wraddress(fb_address_write),
	.wren(current_frame && write_fb),
	.rdaddress(fb_address_read),
	.wrclock(clk),
	.rdclock(clk),
	.q(fb_data_out_1)
);

BRAM #(.DATA_WIDTH(PL_DATA_WIDTH), .DEPTH(256),
`ifdef verilator
	.INIT_FILE("pal.mem")
`else
	.INIT_FILE("palette.mif")
`endif
) palette(
	.data(pl_data_in),
	.wraddress(pl_address_write),
	.wren(write_pl),
	.rdaddress(pl_address_read),
	.wrclock(clk),
	.rdclock(clk_pixel),
	.q(pl_data_out)
);

LINEBUFFER #(.DATA_WIDTH(PL_ADDRESS_WIDTH), .LENGTH(FB_WIDTH)) linebuffer(
	.clk_pixel(clk_pixel),
	.clk_sys(clk),
	.line(line),
	.line_sys(line_sys),
	.enable_input(linebuffer_write),
	.enable_output(linebuffer_read),
	.scale(FB_SCALE),
	.data_in(fb_data_out),
	.data_out(pl_address_read)
);

XD xd_frame(
	.clk_src(clk_pixel),
	.clk_dst(clk),
	.flag_src(frame),
	.flag_dst(frame_sys)
);

XD xd_line(
	.clk_src(clk_pixel),
	.clk_dst(clk),
	.flag_src(line),
	.flag_dst(line_sys)
);

XD xd_line0(
	.clk_src(clk_pixel),
	.clk_dst(clk),
	.flag_src(line && screen_y == 0),
	.flag_dst(line0_sys)
);

initial begin
	current_frame = 0;
end

always_ff @ (posedge clk) begin
	fb_data_out <= current_frame ? fb_data_out_0 : fb_data_out_1;
end

always_ff @ (posedge clk) begin
	if (line0_sys) begin
		count_linebuffer_line <= 0;
	end else if (line_sys) begin
		count_linebuffer_line <= (count_linebuffer_line == FB_SCALE - 1) ? 0 : count_linebuffer_line + 1;
	end
end

always_ff @ (posedge clk) begin
	if (line0_sys) begin
		linebuffer_line <= 1;
	end
	if (frame_sys) begin
		linebuffer_line <= 0;
	end
end

always_comb linebuffer_write = (linebuffer_line && count_linebuffer_line == 0 && count_linebuffer_x < FB_WIDTH);

always_ff @ (posedge clk) begin
	if (line_sys) begin
		count_linebuffer_x <= 0;
	end else if (linebuffer_write) begin
		fb_address_read <= fb_address_read + 1;
		count_linebuffer_x <= count_linebuffer_x + 1;
	end
	
	if (frame_sys) begin
		fb_address_read <= 0;
	end
end

always_ff @ (posedge clk_pixel) begin
	linebuffer_read <= (screen_y >= 0 && screen_y < (FB_HEIGHT * FB_SCALE) && screen_x >= -LATENCY && screen_x < (FB_WIDTH * FB_SCALE) - LATENCY);
end

always_comb {display_blue, display_green, display_red} = data_enable_internal ?  pl_data_out: 0;

always_ff @ (negedge clk_pixel) begin
	hsync <= hsync_internal;
	vsync <= vsync_internal;
	red <= display_red;
	green <= display_green;
	blue <= display_blue;
	data_enable <= data_enable_internal;
end

always_ff @ (negedge clk) begin
	if (enable && mode) begin
		current_value <= reg_data[address];
	end
	
	if (enable && !mode) begin
		reg_data[address] <= data_in;
	end
	
	if (reg_data[1] > 0) begin
		reg_data[1] <= 0;
		
		// process commands
		
		// swap buffers
		if (reg_data[0] == 0) begin
			current_frame <= !current_frame;
		end
	end
end

assign data_out = (enable && mode) ? current_value : 'z;

endmodule