#include <cstdlib>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VREGISTER.h"

#define MAX_SIM_TIME 100
vluint64_t sim_time = 0;

int main(int argc, char** argv)
{
	srand(time(nullptr));

	VREGISTER* dut = new VREGISTER;
	dut->read_enable = 0;
	dut->write_enable = 0;

	Verilated::traceEverOn(true);
	VerilatedVcdC* m_trace = new VerilatedVcdC;
	dut->trace(m_trace, 5);
	m_trace->open("waveform.vcd");

	while (sim_time < MAX_SIM_TIME)
	{
		switch (sim_time % 14)
		{
		case 2:
		case 3:
			dut->read_enable = 1;
			dut->write_enable = 0;
			break;

		case 6:
		case 7:
		case 10:
		case 11:
			dut->read_enable = 0;
			dut->write_enable = 1;
			break;
	
		case 8:
			dut->bus_in = rand() % 256;
		case 9:
			dut->read_enable = 0;
			dut->write_enable = 0;
			break;
		
		case 12:
		case 13:
			dut->read_enable = 1;
			dut->write_enable = 1;
			break;

		default:
			dut->read_enable = 0;
			dut->write_enable = 0;
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
