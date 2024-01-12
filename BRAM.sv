module BRAM #(
	parameter DATA_WIDTH,
	parameter DEPTH,
	parameter INIT_FILE = "",
	localparam ADDRESS_WIDTH = $clog2(DEPTH)
)(
	input  logic [DATA_WIDTH-1:0]    data,
	input  logic [ADDRESS_WIDTH-1:0] wraddress,
	input  logic                     wren,
	input  logic [ADDRESS_WIDTH-1:0] rdaddress,
	input  logic                     wrclock,
	input  logic                     rdclock,
	output logic [DATA_WIDTH-1:0]    q
);

logic [DATA_WIDTH-1:0] memory[DEPTH];

initial begin
	if (INIT_FILE != 0) begin
		$readmemh(INIT_FILE, memory);
	end
end

always_ff @ (posedge wrclock) begin
	if (wren) begin
		memory[wraddress] = data;
	end
end

always_ff @ (posedge rdclock) begin
	q <= memory[rdaddress];
end

endmodule