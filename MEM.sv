module MEM #(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 16
)(
	input  logic                  clk,
	input  logic [ADDR_WIDTH-1:0] address,
	input  logic                  enable,
	input  logic                  mode,
	input  logic [DATA_WIDTH-1:0] data_in,
	output logic [DATA_WIDTH-1:0] data_out
);

(* ram_init_file = "prog.mif" *) logic [DATA_WIDTH-1:0] memory[(1 << ADDR_WIDTH) - 1:0];

logic [DATA_WIDTH-1:0] current_value;

initial begin
	current_value = '0;
`ifdef verilator
	$readmemh("prog.mem", memory);
`endif
end

always_ff @ (negedge clk) begin
	if (enable && mode) begin
		current_value <= memory[address];
	end
	
	if (enable && !mode) begin
		memory[address] <= data_in;
	end
end

assign data_out = (enable && mode) ? current_value : 'z;

endmodule