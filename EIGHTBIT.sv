typedef enum logic [1:0] {
	MEMALU_OP_ADD    = 2'h0,
	MEMALU_OP_INCR   = 2'h1,
	MEMALU_OP_OFFSET = 2'h2
} memalu_op_t;

typedef enum logic [1:0] {
	REG_OP_NONE = 2'b00,
	REG_OP_READ = 2'b01,
	REG_OP_WRITE = 2'b10
} reg_op_t;


module EIGHTBIT(
	input  logic clk,
	input  logic [3:0] buttons,
	/* verilator lint_off UNUSED */
	input  logic [9:0] switches,
	/* verilator lint_on UNUSED */
	output logic [9:0] LED
);

/* verilator lint_off UNUSED */
logic [3:0] inverse_buttons;
/* verilator lint_on UNUSED */

wire [7:0]  data_bus;
wire [15:0] address_bus;
wire [7:0]  temp_always_bus_out;
wire [7:0]  ir_always_bus_out;
wire        overflow_flag;
wire        zero_flag;

wire        overflow_flag_out;
wire        zero_flag_out;

reg_op_t    ir_low;
reg_op_t    ir_high;
reg_op_t    acc_low;
reg_op_t    acc_high;
reg_op_t    temp_register_op;
reg_op_t    pc_op;
wire        overflow_read;
wire        zero_read;
wire        mp8_low;
wire        mp8_high;
reg_op_t    mp16_op;
reg_op_t    swap_register_op;
wire        address_read_enable;
wire        data_in;
/* verilator lint_off UNUSED */
wire        data_out;
/* verilator lint_on UNUSED */
wire        mem_enable;
reg_op_t    alu_data;
reg_op_t    alu_mem;
memalu_op_t alu_mem_mode;

reg_op_t    sr_op;

/* verilator lint_off PINMISSING */
FSM fsm(
	.clk(clk),
	//.instruction(switches[7:4]),
	.instruction(ir_always_bus_out[7:4]),
	.overflow(overflow_flag),
	.zero(zero_flag),
	.ir_low(ir_low),
	.ir_high(ir_high),
	.acc_low(acc_low),
	.acc_high(acc_high),
	.temp_register(temp_register_op),
	.pc(pc_op),
	.overflow_read(overflow_read),
	.zero_read(zero_read),
	.mp8_low(mp8_low),
	.mp8_high(mp8_high),
	.mp16(mp16_op),
	.swap_register(swap_register_op),
	.address_read(address_read_enable),
	.data_in(data_in),
	.data_out(data_out),
	.mem_enable(mem_enable),
	.alu_data(alu_data),
	.alu_mem(alu_mem),
	.alu_mem_mode(alu_mem_mode)
);

SPLIT_REGISTER #(.HALF_WIDTH(4)) ir(
	.clk(clk),
	.op_low(ir_low),
	.op_high(ir_high),
	.bus_in(data_bus),
	.bus_out(data_bus),
	.always_bus_out(ir_always_bus_out)
);

SPLIT_REGISTER #(.HALF_WIDTH(4)) acc(
	.clk(clk),
	.op_low(acc_low),
	.op_high(acc_high),
	.bus_in(data_bus),
	.bus_out(data_bus)
);

REGISTER #(.WIDTH(8)) temp(
	.clk(clk),
	.op(temp_register_op),
	.bus_in(data_bus),
	.bus_out(data_bus),
	.always_bus_out(temp_always_bus_out)
);

REGISTER #(.WIDTH(8)) swap(
	.clk(clk),
	.op(swap_register_op),
	.bus_in(data_bus),
	.bus_out(data_bus)
);

REGISTER #(.WIDTH(16)) pc(
	.clk(clk),
	.op(pc_op),
	.bus_in(address_bus),
	.bus_out(address_bus)
);

SPLIT_REGISTER #(.HALF_WIDTH(8)) mp(
	.clk(clk),
	.op_low(mp16_op),
	.op_high(mp16_op),
	.bus_b_low(mp8_low),
	.bus_b_high(mp8_high),
	.bus_in(address_bus),
	.bus_b_in(data_bus),
	.bus_out(address_bus)
);

REGISTER #(.WIDTH(2)) sr(
	.clk(clk),
	.op(sr_op),
	.bus_in({overflow_flag_out, zero_flag_out}),
	.always_bus_out({overflow_flag, zero_flag})
);

MEM #(.DATA_WIDTH(8), .ADDR_WIDTH(16)) mem(
	.clk(clk),
	.address(address_bus),
	.address_read_enable(address_read_enable),
	.enable(mem_enable),
	.mode(data_in),
	.data_in(data_bus),
	.data_out(data_bus)
);

ALU #(.WIDTH(8)) alu(
	.clk(clk),
	.a(data_bus),
	.b(temp_always_bus_out),
	.mode(alu_op_t'(ir_always_bus_out[3:0])),
	//.mode(alu_op_t'(switches[3:0])),
	.control(alu_data),
	.out(data_bus),
	.overflow(overflow_flag_out),
	.zero(zero_flag_out)
);

MEMALU #(.HALF_WIDTH(8)) memalu(
	.clk(clk),
	.a(address_bus),
	.b(data_bus),
	.mode(alu_mem_mode),
	.control(alu_mem),
	.out(address_bus)
);
/* verilator lint_on PINMISSING */

assign sr_op = (overflow_read && zero_read) ? REG_OP_READ : REG_OP_NONE;

assign inverse_buttons = ~buttons;
assign LED = {2'b00, temp_always_bus_out};

endmodule