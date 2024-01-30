module DEVICE_INTERFACE #(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 5,
	parameter WRITABLE   = 1
)(
	input  logic                  clk,
	input  logic [ADDR_WIDTH-1:0] address,
	input  logic                  enable,
	input  logic                  mode,
	input  logic [DATA_WIDTH-1:0] data_in,
	output logic [DATA_WIDTH-1:0] data_out,
	inout  tri   [DATA_WIDTH-1:0] device_data[(1 << ADDR_WIDTH) - 1:0]
);

logic [DATA_WIDTH-1:0] current_value;

initial begin
	current_value = '0;
end

always_ff @ (negedge clk) begin
	if (enable && mode) begin
		current_value <= device_data[address];
	end
	
	if (enable && !mode && WRITABLE) begin
		device_data[address] <= data_in;
	end
end

assign data_out = (enable && mode) ? current_value : 'z;

endmodule