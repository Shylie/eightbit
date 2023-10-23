#include <cstdlib>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VEIGHTBIT.h"

#define MAX_SIM_TIME 100000
vluint64_t sim_time = 0;

int main(int argc, char** argv)
{
	srand(time(nullptr));

	VEIGHTBIT eb;
	VEIGHTBIT* dut = &eb;

	dut->buttons = 1;
	
	Verilated::traceEverOn(true);
	VerilatedVcdC* m_trace = new VerilatedVcdC;
	dut->trace(m_trace, 5);
	m_trace->open("waveform.vcd");

	while (sim_time < MAX_SIM_TIME)
	{
		dut->clk = !dut->clk;

		if (sim_time % 25 == 0)
		{
			dut->buttons = !dut->buttons;
		}

		dut->eval();

		m_trace->dump(sim_time);
		sim_time++;
	}

	m_trace->close();

	delete m_trace;

	exit(EXIT_SUCCESS);
}
