#include <cstdlib>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VSPLIT_REGISTER.h"

#define MAX_SIM_TIME 200
vluint64_t sim_time = 0;

int main(int argc, char** argv)
{
	srand(time(nullptr));

	VSPLIT_REGISTER v;
	VSPLIT_REGISTER* dut = &v;

	dut->op_low = 0;
	dut->op_high = 0;

	Verilated::traceEverOn(true);
	VerilatedVcdC* m_trace = new VerilatedVcdC;
	dut->trace(m_trace, 5);
	m_trace->open("waveform.vcd");

	while (sim_time < MAX_SIM_TIME)
	{
		switch(sim_time % 6)
		{
		case 0:
			dut->op_low = 0;
			dut->op_high = 0;
			dut->bus_in = rand() % (1 << 8);
			break;

		case 1:
			dut->op_low = 1;
			dut->op_high = 0;
			break;

		case 2:
			dut->op_low = 0;
			dut->op_high = 1;
			break;

		case 3:
			dut->op_low = 2;
			dut->op_high = 0;
			break;

		case 4:
			dut->op_low = 0;
			dut->op_high = 2;
			break;

		case 5:
			dut->op_low = 2;
			dut->op_high = 2;
			break;
		}

		dut->eval();

		m_trace->dump(sim_time);
		sim_time++;
	}

	m_trace->close();

	delete m_trace;

	exit(EXIT_SUCCESS);
}
