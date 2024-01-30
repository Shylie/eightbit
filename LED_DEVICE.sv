module LED_DEVICE(
	input  logic       clk,
	input  logic [3:0] address,
	input  logic       enable,
	input  logic       mode,
	input  logic [7:0] data_in,
	output logic [7:0] data_out,
	output logic [9:0] LED
);

logic [7:0] pwm_data[15:0];
logic [7:0] counter;
logic [7:0] current_value;

initial begin
	counter = '0;
end

always_ff @ (posedge clk) begin
	counter <= counter + 1;
end

always_ff @ (negedge clk) begin
	if (enable && mode) begin
		current_value <= pwm_data[address];
	end
	
	if (enable && !mode) begin
		pwm_data[address] <= data_in;
	end
end

generate
	genvar i;
	for (i = 0; i < 10; i++) begin : loop
		assign LED[i] = (counter < 8'((16'(pwm_data[i]) ** 2) / 16'd255));
	end
endgenerate

assign data_out = (enable && mode) ? current_value : 'z;

endmodule