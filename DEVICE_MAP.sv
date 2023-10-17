module DEVICE_MAP #(
	parameter DATA_WIDTH = 8,
	parameter ADDRESS_WIDTH = 16,
	parameter DEVICE_SELECT_WIDTH = 3,
	parameter DEVICE_ADDRESS_WIDTH = 4,
	parameter DEVICE_SELECT_WIDTH_OUT = 1 << DEVICE_SELECT_WIDTH,
	parameter FULL_DEVICE_BITS = DEVICE_SELECT_WIDTH + DEVICE_ADDRESS_WIDTH,
	parameter MEM_MASK = ADDRESS_WIDTH'({ADDRESS_WIDTH - FULL_DEVICE_BITS{1'b1}}) << FULL_DEVICE_BITS
)(
	input  logic                               clk,
	input  logic [ADDRESS_WIDTH-1:0]           address_in,
	input  logic                               address_read_enable,
	input  logic                               enable,
	output logic [ADDRESS_WIDTH-1:0]           address_out,
	output logic                               mem_enable,
	output logic [DEVICE_SELECT_WIDTH_OUT-1:0] dev_enable
);

logic [ADDRESS_WIDTH-1:0] current_address;

initial begin
	current_address = '0;
end

always_ff @ (negedge clk) begin
	if (address_read_enable) begin	
		current_address <= address_in;
	end
end

always_comb begin
	if (current_address < MEM_MASK) begin
		mem_enable = enable;
		dev_enable = '0;
	end else begin
		mem_enable = '0;
		for (int i = 0; i < DEVICE_SELECT_WIDTH_OUT; i++) begin
			dev_enable[i] = (enable && current_address[FULL_DEVICE_BITS-1:DEVICE_ADDRESS_WIDTH] == DEVICE_SELECT_WIDTH'(i));
		end
	end
end

assign address_out = current_address;

endmodule