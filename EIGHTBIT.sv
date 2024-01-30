typedef enum logic [1:0] {
	MEMALU_OP_ADD    = 2'h0,
	MEMALU_OP_INCR   = 2'h1,
	MEMALU_OP_OFFSET = 2'h2
} memalu_op_t;

typedef enum logic [3:0] {
	ALU_OP_NOT  = 4'h0,
	ALU_OP_OR   = 4'h1,
	ALU_OP_AND  = 4'h2,
	ALU_OP_XOR  = 4'h3,
	ALU_OP_ADD  = 4'h4,
	ALU_OP_SUB  = 4'h5,
	ALU_OP_SHL  = 4'h6,
	ALU_OP_LSHR = 4'h7,
	ALU_OP_ASHR = 4'h8,
	ALU_OP_MUL  = 4'h9,
	ALU_OP_DIV  = 4'hA,
	ALU_OP_CMP  = 4'hB
} alu_op_t;

typedef enum logic [1:0] {
	REG_OP_NONE = 2'b00,
	REG_OP_READ = 2'b01,
	REG_OP_WRITE = 2'b10,
	REG_OP_SWRITENC = 2'b11 // split register no copy
} reg_op_t;

module EIGHTBIT(
	input  logic clk,
	input  logic [3:0] buttons,
	input  logic [9:0] switches,
	output logic [9:0] LED,
	output logic       VGA_CLK,
	output logic [7:0] VGA_RED,
	output logic [7:0] VGA_GREEN,
	output logic [7:0] VGA_BLUE,
	output logic       VGA_HSYNC,
	output logic       VGA_VSYNC,
	output logic       VGA_BLANK,
	inout  tri         PS2_CLK,
	inout  tri         PS2_DAT
);

localparam DEVICE_SELECT_WIDTH = 3;
localparam DEVICE_SELECT_WIDTH_OUT = 1 << DEVICE_SELECT_WIDTH;

logic [3:0] inverse_buttons;

wire [7:0]  data_bus;
wire [15:0] address_bus;
wire [15:0] register_address_bus;
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
wire        mem_enable;
reg_op_t    alu_data;
reg_op_t    alu_mem;
memalu_op_t alu_mem_mode;

reg_op_t    sr_op;

wire                               mem_mem_enable;
wire [DEVICE_SELECT_WIDTH_OUT-1:0] mem_dev_enable;

wire clk_25_2;
wire clk_100;

`ifndef verilator
PLL pll(
	.refclk(clk),
	.outclk_0(clk_100)
);

VGA_PLL vga_pll(
	.refclk(clk),
	.outclk_0(clk_25_2)
);
`endif

// verilator lint_off PINMISSING
FSM fsm(
	.clk(clk_100),
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
	.mem_enable(mem_enable),
	.alu_data(alu_data),
	.alu_mem(alu_mem),
	.alu_mem_mode(alu_mem_mode)
);

SPLIT_REGISTER #(.HALF_WIDTH(4)) ir(
	.clk(clk_100),
	.op_low(ir_low),
	.op_high(ir_high),
	.bus_in(data_bus),
	.bus_out(data_bus),
	.always_bus_out(ir_always_bus_out)
);

SPLIT_REGISTER #(.HALF_WIDTH(4)) acc(
	.clk(clk_100),
	.op_low(acc_low),
	.op_high(acc_high),
	.bus_in(data_bus),
	.bus_out(data_bus)
);

REGISTER #(.WIDTH(8)) temp(
	.clk(clk_100),
	.op(temp_register_op),
	.bus_in(data_bus),
	.bus_out(data_bus),
	.always_bus_out(temp_always_bus_out)
);

REGISTER #(.WIDTH(8)) swap(
	.clk(clk_100),
	.op(swap_register_op),
	.bus_in(data_bus),
	.bus_out(data_bus)
);

REGISTER #(.WIDTH(16)) pc(
	.clk(clk_100),
	.op(pc_op),
	.bus_in(address_bus),
	.bus_out(address_bus)
);

SPLIT_REGISTER #(.HALF_WIDTH(8)) mp(
	.clk(clk_100),
	.op_low(mp16_op),
	.op_high(mp16_op),
	.bus_b_low(mp8_low),
	.bus_b_high(mp8_high),
	.bus_in(address_bus),
	.bus_b_in(data_bus),
	.bus_out(address_bus)
);

REGISTER #(.WIDTH(2)) sr(
	.clk(clk_100),
	.op(sr_op),
	.bus_in({overflow_flag_out, zero_flag_out}),
	.always_bus_out({overflow_flag, zero_flag})
);

MEM #(.DATA_WIDTH(8), .ADDR_WIDTH(16)) mem(
	.clk(clk_100),
	.address(register_address_bus),
	.enable(mem_mem_enable),
	.mode(data_in),
	.data_in(data_bus),
	.data_out(data_bus)
);

ALU #(.WIDTH(8)) alu(
	.clk(clk_100),
	.a(data_bus),
	.b(temp_always_bus_out),
	.mode(alu_op_t'(ir_always_bus_out[3:0])),
	.control(alu_data),
	.out(data_bus),
	.overflow(overflow_flag_out),
	.zero(zero_flag_out)
);

MEMALU #(.HALF_WIDTH(8)) memalu(
	.clk(clk_100),
	.a(address_bus),
	.b(data_bus),
	.mode(alu_mem_mode),
	.control(alu_mem),
	.out(address_bus)
);

DEVICE_MAP #(.DATA_WIDTH(8), .ADDRESS_WIDTH(16), .DEVICE_SELECT_WIDTH(DEVICE_SELECT_WIDTH), .DEVICE_ADDRESS_WIDTH(4)) devmap(
	.clk(clk_100),
	.address_in(address_bus),
	.address_read_enable(address_read_enable),
	.enable(mem_enable),
	.address_out(register_address_bus),
	.mem_enable(mem_mem_enable),
	.dev_enable(mem_dev_enable)
);


LED_DEVICE led_device(
	.clk(clk_100),
	.address(register_address_bus[3:0]),
	.enable(mem_dev_enable[0]),
	.mode(data_in),
	.data_in(data_bus),
	.data_out(data_bus),
	.LED(LED)
);

BUTTON_DEVICE button_device(
	.clk(clk_100),
	.address(register_address_bus[3:0]),
	.enable(mem_dev_enable[1]),
	.mode(data_in),
	.data_out(data_bus),
	.button_state(inverse_buttons)
);

`ifndef verilator
MOUSE_DEVICE mouse_device(
	.clk(clk_100),
	.address(register_address_bus[3:0]),
	.enable(mem_dev_enable[2]),
	.mode(data_in),
	.data_in(data_bus),
	.data_out(data_bus),
	.PS2_CLK(PS2_CLK),
	.PS2_DAT(PS2_DAT)
);
`endif

VGA_DEVICE vga_device(
	.clk(clk_100),
	.address(register_address_bus[3:0]),
	.enable(mem_dev_enable[3]),
	.mode(data_in),
	.data_in(data_bus),
	.data_out(data_bus),
	.clk_pixel(clk_25_2),
	.red(VGA_RED),
	.green(VGA_GREEN),
	.blue(VGA_BLUE),
	.hsync(VGA_HSYNC),
	.vsync(VGA_VSYNC),
	.data_enable(VGA_BLANK)
);
// verilator lint_on PINMISSING

assign sr_op = (overflow_read && zero_read) ? REG_OP_READ : REG_OP_NONE;

assign inverse_buttons = ~buttons;

assign VGA_CLK = clk_25_2;

`ifdef verilator
assign clk_100 = clk;
assign clk_25_2 = clk;
`endif

endmodule