module LED_DEVICE(
	input  logic       clk,
	input  logic [3:0] address,
	input  logic       enable,
	input  logic       mode,
	input  logic [7:0] data_in,
	output logic [7:0] data_out,
	output logic [9:0] LED
);

wire logic [7:0] pwm_data[15:0];
logic [7:0] counter;

DEVICE_INTERFACE device_interface(
	.clk(clk),
	.address(address),
	.enable(enable),
	.mode(mode),
	.data_in(data_in),
	.data_out(data_out),
	.device_data(pwm_data)
);

initial begin
	counter = '0;
end

always_ff @ (posedge clk) begin
	counter <= counter + 1;
end

generate
	genvar i;
	for (i = 0; i < 10; i++) begin : loop
		assign LED[i] = (counter < 8'((16'(pwm_data[i]) ** 2) / 16'd255));
	end
endgenerate

endmodule