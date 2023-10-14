#include <cstdlib>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VMEM.h"

#define MAX_SIM_TIME 100
vluint64_t sim_time = 0;

int main(int argc, char** argv)
{
	srand(time(nullptr));

	VMEM* dut = new VMEM;
	dut->address_read_enable = 0;
	dut->enable = 0;
	dut->mode = 0;
	dut->data_in = 0;

	Verilated::traceEverOn(true);
	VerilatedVcdC* m_trace = new VerilatedVcdC;
	dut->trace(m_trace, 5);
	m_trace->open("waveform.vcd");

	
	while (sim_time < MAX_SIM_TIME)
	{
		switch (sim_time % 12)
		{
		case 1:
			dut->address_read_enable = 0;
			dut->data_in = rand() % (1 << 8);
			break;

		case 3:
			dut->enable = 1;
			dut->mode = 1;
			break;

		case 5:
			dut->enable = 1;
			dut->mode = 0;
			break;

		case 7:
			dut->enable = 1;
			dut->mode = 1;
			break;

		case 8:
			dut->enable = 0;
			break;

		case 9:
			dut->address = (dut->address + 1) % 4; // test first four addresses
			break;

		case 11:
			dut->address_read_enable = 1;
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
