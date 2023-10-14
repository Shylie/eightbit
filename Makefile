ifndef MODULE
ifneq ($(MAKECMDGOALS),clean)
$(error MODULE is not set)
endif
endif

.PHONY: wave
wave: waveforms/$(MODULE)_waveform.vcd
	@echo
	@echo "### VIEWING WAVEFORM ###"
	gtkwave $(PWD)/waveforms/$(MODULE)_waveform.vcd &

.PHONY: sim
sim: waveforms/$(MODULE)_waveform.vcd

.PHONY: verilate
verilate: obj_dir/$(MODULE).stamp.verilate

.PHONY: build
build: obj_dir/V$(MODULE)

.PHONY: clean
clean:
	rm -rf ./obj_dir
	rm -rf waveforms

waveforms/$(MODULE)_waveform.vcd: ./obj_dir/V$(MODULE)
	@echo
	@echo "### SIMULATING ###"
	@./obj_dir/V$(MODULE)
	@mkdir -p waveforms
	@mv waveform.vcd waveforms/$(MODULE)_waveform.vcd

./obj_dir/V$(MODULE): ./obj_dir/$(MODULE).stamp.verilate
	@echo
	@echo "### BUILDING SIM ###"
	make -C obj_dir -f V$(MODULE).mk V$(MODULE) CPPFLAGS="-I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -I."

./obj_dir/$(MODULE).stamp.verilate: *.sv tb_$(MODULE).cpp
	@echo
	@echo "### VERILATING ###"
	verilator -Wall --trace --cc $(MODULE).sv --exe tb_$(MODULE).cpp
	@touch obj_dir/$(MODULE).stamp.verilate
