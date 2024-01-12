MODULE ?= EIGHTBIT

.PHONY: sim
sim: build
	./obj_dir/V$(MODULE)

.PHONY: verilate
verilate: obj_dir/$(MODULE).stamp.verilate

.PHONY: build
build: obj_dir/V$(MODULE)

.PHONY: clean
clean:
	rm -rf ./obj_dir

./obj_dir/V$(MODULE): ./obj_dir/$(MODULE).stamp.verilate
	@echo
	@echo "### BUILDING SIM ###"
	make -C obj_dir -f V$(MODULE).mk V$(MODULE) CPPFLAGS="-I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -I."

./obj_dir/$(MODULE).stamp.verilate: *.sv tb_$(MODULE).cpp
	@echo
	@echo "### VERILATING ###"
	verilator -Wno-WIDTH -Wno-TIMESCALEMOD -I/mnt/c/intelFPGA/23.1std/quartus/eda/fv_lib/verilog/ --trace --cc $(MODULE).sv --exe tb_$(MODULE).cpp -CFLAGS -D_REENTRANT -LDFLAGS -lSDL2 -LDFLAGS -lSDL2main 
	@touch obj_dir/$(MODULE).stamp.verilate
