module DEVICE_INTERFACE #(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 4,
	parameter WRITABLE   = 1
)(
	input  logic                  clk,
	input  logic [ADDR_WIDTH-1:0] address,
	input  logic                  enable,
	input  logic                  mode,
	input  logic [DATA_WIDTH-1:0] data_in,
	output logic [DATA_WIDTH-1:0] data_out,
	output logic [DATA_WIDTH-1:0] device_data[(1 << ADDR_WIDTH) - 1:0]
);

logic [DATA_WIDTH-1:0] memory[(1 << ADDR_WIDTH) - 1:0];

logic [DATA_WIDTH-1:0] current_value;

initial begin
	current_value = '0;
end

always_ff @ (negedge clk) begin
	if (enable && mode) begin
		current_value <= memory[address];
	end
	
	if (enable && !mode && WRITABLE) begin
		memory[address] <= data_in;
	end
end

assign data_out = (enable && mode) ? current_value : 'z;

generate
	genvar i;
	for (i = 0; i < 1 << ADDR_WIDTH; i++) begin : loop
		assign device_data[i] = memory[i];
	end
endgenerate

endmodule