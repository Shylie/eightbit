module BUTTON_DEVICE(
	input  logic       clk,
	input  logic [3:0] address,
	input  logic       enable,
	input  logic       mode,
	output logic [7:0] data_out,
	input  logic [3:0] button_state
);

logic [7:0] button_data[15:0];
logic [7:0] current_value;

initial begin
	current_value = '0;
end

always_ff @ (posedge clk) begin
	button_data[0] <= {7'b0000000, button_state[0]};
	button_data[1] <= {7'b0000000, button_state[1]};
	button_data[2] <= {7'b0000000, button_state[2]};
	button_data[3] <= {7'b0000000, button_state[3]};
end

always_ff @ (negedge clk) begin
	if (enable && mode) begin
		current_value <= button_data[address];
	end
end

assign data_out = (enable && mode) ? current_value : 'z;

endmodule