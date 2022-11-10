TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 0

COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

SOURCES_DIR = ../../hw

VERILOG_SOURCES += $(SOURCES_DIR)/peripheral/interconnect/AddrMux1_4.v
VERILOG_SOURCES += $(SOURCES_DIR)/peripheral/interconnect/Interconnect.v

DUT      = Interconnect
TOPLEVEL = $(DUT)
MODULE   = tb_$(DUT)

DUMP= $(TOPLEVEL)_dump

ifeq ($(WAVES), 1)
	ifeq ($(SIM), icarus)
		PLUSARGS += -fst
		VERILOG_SOURCES += $(DUMP).v
		COMPILE_ARGS += -s $(DUMP)
	else ifeq ($(SIM), verilator)
		EXTRA_ARGS += --trace-fst --trace-structs
	endif
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

$(DUMP).v: Makefile
	echo 'module $(DUMP)();' > $@
	echo 'initial begin' >> $@
	echo '    $$dumpfile("$(TOPLEVEL).fst");' >> $@
	echo '    $$dumpvars(1, $(TOPLEVEL));' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

wave:
	gtkwave $(TOPLEVEL).fst &

clean::
	rm -rf *.fst
	rm -rf *.vcd
	rm -rf *_dump.v
	rm -rf results.xml