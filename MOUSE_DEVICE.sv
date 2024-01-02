module MOUSE_DEVICE(
	input  logic       clk,
	input  logic [3:0] address,
	input  logic       enable,
	input  logic       mode,
	input  logic [7:0] data_in,
	output logic [7:0] data_out,
	inout  tri         PS2_CLK,
	inout  tri         PS2_DAT
);

// mouse_data[0] - data reporting size in range [0, 4]
// mouse_data[1] - command to send
// mouse_data[2] - command send enable
// mouse_data[3] - command response
// mouse_data[4] - last data report id
// rest of data  - data reporting sequence
logic [7:0] mouse_data[15:0];
logic [7:0] current_value;

logic [3:0] counter;

logic [7:0] cmd;
logic       send_cmd;
logic       cmd_was_sent;
logic       communication_timed_out;
logic [7:0] data_recv;
logic       data_recv_en;

PS2_Controller PS2(
	.CLOCK_50(clk),
	.the_command(cmd),
	.send_command(send_cmd),
	.PS2_CLK(PS2_CLK),
	.PS2_DAT(PS2_DAT),
	.received_data(data_recv),
	.received_data_en(data_recv_en),
	.command_was_sent(cmd_was_sent),
	.error_communication_timed_out(communication_timed_out)
);

initial begin
	counter = '0;
end

always_ff @ (negedge clk) begin
	if (mouse_data[2] > 0) begin
		send_cmd <= 1;
		cmd <= mouse_data[1];
		mouse_data[2] <= 0;
		counter <= 4'hF;
	end
	
	if (enable && mode) begin
		current_value <= mouse_data[address];
	end
	
	if (enable && !mode) begin
		mouse_data[address] <= data_in;
	end
	
	if (cmd_was_sent > 0 || communication_timed_out > 0) begin
		send_cmd <= 0;
	end

	if (data_recv_en) begin
		if (counter < 3'(mouse_data[0])) begin
			mouse_data[counter + 5] <= data_recv;
			
			counter <= counter + 1;
		end
		
		if (counter + 1 >= 3'(mouse_data[0])) begin
			counter <= 0;
			mouse_data[4] <= mouse_data[4] + 1;
		end
	end
end

assign data_out = (enable && mode) ? current_value : 'z;

endmodule