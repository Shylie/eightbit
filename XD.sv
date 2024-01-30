// https://projectf.io/posts/lib-clock-xd/

module XD(
	input  wire logic clk_src,
	input  wire logic clk_dst,
	input  wire logic flag_src,
	output      logic flag_dst
);

logic toggle_src = 1'b0;
always_ff @ (posedge clk_src) toggle_src <= toggle_src ^ flag_src;

logic [3:0] shr_dst = 4'b0;
always_ff @ (posedge clk_dst) shr_dst <= {shr_dst[2:0], toggle_src};

always_comb flag_dst = shr_dst[3] ^ shr_dst[2];

endmodule