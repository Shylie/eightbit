#include <cstdlib>
#include <iostream>
#include <SDL2/SDL.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VEIGHTBIT.h"

//#define WAVE

vluint64_t sim_time = 0;

constexpr int H_RES = 640;
constexpr int V_RES = 480;

struct Pixel
{
	uint8_t a;
	uint8_t r;
	uint8_t g;
	uint8_t b;
} screenbuffer[H_RES * V_RES];

SDL_Window*   window   = nullptr;
SDL_Renderer* renderer = nullptr;
SDL_Texture*  texture  = nullptr;
const Uint8* keyboard_state = nullptr;

int main(int argc, char** argv)
{
	srand(time(nullptr));

	window   = SDL_CreateWindow("simulation", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, H_RES, V_RES, SDL_WINDOW_SHOWN);
	renderer = SDL_CreateRenderer(window, -1, 0);
	texture  = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, H_RES, V_RES);

	keyboard_state = SDL_GetKeyboardState(nullptr);

	VEIGHTBIT eb;
	VEIGHTBIT* dut = &eb;

#ifdef WAVE
	Verilated::traceEverOn(true);
	VerilatedVcdC* m_trace = new VerilatedVcdC;
	dut->trace(m_trace, 5);

	m_trace->open("waveform.vcd");
#endif

	unsigned int index;
	while (true)
	{
		dut->clk = 1;
		dut->eval();
#ifdef WAVE
		m_trace->dump(sim_time++);
#endif
		dut->clk = 0;
		dut->eval();
#ifdef WAVE
		m_trace->dump(sim_time++);
#endif

		if (dut->VGA_BLANK)
		{
			Pixel& p = screenbuffer[index];
			p.a = 0xFF;
			p.b = dut->VGA_BLUE;
			p.g = dut->VGA_GREEN;
			p.r = dut->VGA_RED;

			if (++index == H_RES * V_RES)
			{
				index = 0;

				SDL_Event e;
				if (SDL_PollEvent(&e))
				{
					if (e.type == SDL_QUIT)
					{
						break;
					}
				}

				if (keyboard_state[SDL_SCANCODE_Q]) { break; }

				SDL_UpdateTexture(texture, nullptr, screenbuffer, H_RES * sizeof(Pixel));
				SDL_RenderClear(renderer);
				SDL_RenderCopy(renderer, texture, nullptr, nullptr);
				SDL_RenderPresent(renderer);
			}
		}
	}

#ifdef WAVE
	m_trace->close();
#endif

	exit(EXIT_SUCCESS);
}
