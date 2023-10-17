#include <cstdlib>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VDEVICE_MAP.h"

vluint64_t sim_time = 0;

int main(int argc, char** argv)
{
	srand(time(nullptr));

	VDEVICE_MAP* dut = new VDEVICE_MAP;
	dut->address_read_enable = 1;
	dut->enable = 1;
	dut->address_in = 0;

	Verilated::traceEverOn(true);
	VerilatedVcdC* m_trace = new VerilatedVcdC;
	dut->trace(m_trace, 5);
	m_trace->open("waveform.vcd");

	while (true)
	{
		dut->clk = !dut->clk;
		dut->eval();

		m_trace->dump(sim_time);
		sim_time++;

		if (sim_time % 2 == 1)
		{
			dut->address_in = (dut->address_in + 1) % 0x10000;
		}

		if (dut->address_in == 0 && sim_time > 2)
		{
			break;
		}
	}

	m_trace->close();

	delete m_trace;
	delete dut;

	exit(EXIT_SUCCESS);
}
