module MEM #(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 16
)(
	input  logic                  clk,
	input  logic [ADDR_WIDTH-1:0] address,
	/* verilator lint_off UNUSED */
	input  logic                  address_read_enable, // remove later??
	/* verilator lint_on UNUSED */
	input  logic                  enable,
	input  logic                  mode,
	input  logic [DATA_WIDTH-1:0] data_in,
	output logic [DATA_WIDTH-1:0] data_out
);

logic [DATA_WIDTH-1:0] memory[1 << ADDR_WIDTH - 1:0];

logic [DATA_WIDTH-1:0] current_value;
logic [ADDR_WIDTH-1:0] current_address;

initial begin
	current_value = '0;
	current_address = '0;
	$readmemh("prog.mem", memory);
end

always_ff @ (negedge clk) begin
	if (address_read_enable) begin
		current_address <= address;
	end

	if (enable && mode) begin
		current_value <= memory[current_address];
	end
	
	if (enable && !mode) begin
		memory[current_address] <= data_in;
	end
end

assign data_out = (enable && mode) ? current_value : 'z;

endmodule