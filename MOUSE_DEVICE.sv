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

logic [7:0] mouse_data[15:0];
logic [7:0] current_value;

logic [1:0] counter;

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
	if (mouse_data[7] > 0) begin
		send_cmd <= 1;
		cmd <= mouse_data[6];
		mouse_data[7] <= 0;
		counter <= 2'b11;
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
	
		case (counter)
			2'b00: begin
				mouse_data[0] <= data_recv;
				counter <= 2'b01;
			end
			
			2'b01: begin
				mouse_data[1] <= data_recv;
				counter <= 2'b10;
			end
			
			2'b10: begin
				mouse_data[2] <= data_recv;
				counter <= 2'b00;
				
				mouse_data[5] <= mouse_data[5] + 1;
			end
			
			2'b11: begin
				mouse_data[4] <= data_recv;
				counter <= 2'b00;
			end
		endcase
	end
end

assign data_out = (enable && mode) ? current_value : 'z;

endmodule