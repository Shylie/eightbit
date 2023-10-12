#include <cstdlib>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VMEMALU.h"

#define MAX_SIM_TIME 100
vluint64_t sim_time = 0;

int main(int argc, char** argv)
{
	srand(time(nullptr));

	VMEMALU* dut = new VMEMALU;
	dut->a = 0;
	dut->b = 0;
	dut->mode = 0;
	dut->control = true;

	Verilated::traceEverOn(true);
	VerilatedVcdC* m_trace = new VerilatedVcdC;
	dut->trace(m_trace, 5);
	m_trace->open("waveform.vcd");

	while (sim_time < MAX_SIM_TIME)
	{
		dut->control = !dut->control;

		switch (sim_time % 6)
		{
		case 1:
			dut->a = rand() % (1 << 16);
			break;

		case 3:
			dut->b = rand() % (1 << 16);		
			break;

		case 5:
			dut->mode = (dut->mode + 1) % 3;
			break;	
		}

		dut->eval();

		m_trace->dump(sim_time);
		sim_time++;
	}

	m_trace->close();

	delete m_trace;
	delete dut;

	exit(EXIT_SUCCESS);
}
