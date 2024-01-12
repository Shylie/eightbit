module LINEBUFFER #(
	parameter DATA_WIDTH = 8,
	parameter LENGTH = 640,
	parameter SCALE_WIDTH = 6
)(
	input wire logic                   clk_pixel,
	input wire logic                   line,
	input wire logic                   enable_input,
	input wire logic                   enable_output,
	input wire logic [SCALE_WIDTH-1:0] scale,
	input wire logic [DATA_WIDTH-1:0]  data_in,
	output     logic [DATA_WIDTH-1:0]  data_out
);

logic [DATA_WIDTH-1:0]  data[LENGTH-1:0];
logic [$clog2(LENGTH)-1:0] address_in;
logic [$clog2(LENGTH)-1:0] address_out;
logic [SCALE_WIDTH-1:0] count_horizontal;

always_ff @ (posedge clk_pixel) begin
	if (enable_output) begin
		if (count_horizontal == scale - 1) begin
			count_horizontal <= 0;
			if (address_out != LENGTH - 1) begin
				address_out <= address_out + 1;
			end
		end else begin
			count_horizontal <= count_horizontal + 1;
		end
	end
	
	if (line) begin
		address_out <= 0;
		count_horizontal <= 0;
	end
end

always_ff @ (posedge clk_pixel) begin
	if (enable_input) begin
		data[address_in] <= data_in;
	end

	if (enable_input && address_in != LENGTH - 1 && !line) begin
		address_in <= address_in + 1;
	end
	
	if (line) begin
		address_in <= 0;
	end
end

assign data_out = data[address_out];

endmodule