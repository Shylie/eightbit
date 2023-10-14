#include <cstdlib>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VFSM.h"

#define MAX_SIM_TIME 2500
vluint64_t sim_time = 0;

int main(int argc, char** argv)
{
	srand(time(nullptr));

	VFSM v;
	VFSM* dut = &v;
	dut->clk = 1;
	dut->instruction = 0;
	dut->overflow = 0;
	dut->zero = 0;

	Verilated::traceEverOn(true);
	VerilatedVcdC* m_trace = new VerilatedVcdC;
	dut->trace(m_trace, 5);
	m_trace->open("waveform.vcd");

	while (sim_time < MAX_SIM_TIME)
	{
		dut->clk = !dut->clk;

		switch (sim_time % 288)
		{
		case 287:
			dut->instruction = (dut->instruction + 1) % 16;
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
