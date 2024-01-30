module INTERRUPT_BUFFER #(
	parameter WIDTH = 4,
	parameter MAX_STORED_INTERRUPTS = 8
)(
	input  logic             clk,
	input  logic [WIDTH-1:0] interrupt_in,
	input  logic             processing,
	output logic [WIDTH-1:0] interrupt_out
);

localparam INTERRUPT_ADDRESS_WIDTH = $clog2(MAX_STORED_INTERRUPTS);

logic [WIDTH-1:0] interrupts[MAX_STORED_INTERRUPTS];
logic [INTERRUPT_ADDRESS_WIDTH-1:0] interrupt_queue_top = '0;
logic last_processing = '0;

always_ff @ (negedge clk) begin
	// interrupt is done processing, send out next
	if (last_processing && !processing) begin
		for (int i = 1; i < interrupt_queue_top; i++) begin
			interrupts[i - 1] = interrupts[i];
		end
		interrupts[interrupt_queue_top - 1] <= '0;
		
		if (interrupt_queue_top > 0) begin
			interrupt_queue_top = interrupt_queue_top - 1;
		end
	end

	last_processing <= processing;
	
	if (interrupt_in > 0 && interrupt_queue_top < MAX_STORED_INTERRUPTS - 1) begin
		interrupts[interrupt_queue_top] <= interrupt_in;
		interrupt_queue_top = interrupt_queue_top + 1;
	end
end

assign interrupt_out = interrupts[0];

endmodule