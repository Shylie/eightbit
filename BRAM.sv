module BRAM #(
	parameter DATA_WIDTH,
	parameter DEPTH,
	parameter INIT_FILE = ""
)(
	input  logic [DATA_WIDTH-1:0]    data,
	input  logic [ADDRESS_WIDTH-1:0] wraddress,
	input  logic                     wren,
	input  logic [ADDRESS_WIDTH-1:0] rdaddress,
	input  logic                     wrclock,
	input  logic                     rdclock,
	output logic [DATA_WIDTH-1:0]    q
);

localparam ADDRESS_WIDTH = $clog2(DEPTH);

(* ram_init_file = INIT_FILE *) logic [DATA_WIDTH-1:0] memory[DEPTH];

`ifdef verilator
initial begin
	if (INIT_FILE != 0) begin
		$readmemh(INIT_FILE, memory);
	end
end
`endif

always_ff @ (posedge wrclock) begin
	if (wren) begin
		memory[wraddress] <= data;
	end
end

always_ff @ (posedge rdclock) begin
	q <= memory[rdaddress];
end

endmodule