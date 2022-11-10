TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 0

COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

SOURCES_DIR = ../../hw

VERILOG_SOURCES += $(wildcard $(SOURCES_DIR)/*.v $(SOURCES_DIR)/*/*.v $(SOURCES_DIR)/*/*/*.v)

DUT      = picorv32SOC
TOPLEVEL = $(DUT)
MODULE   = tb_$(DUT)

DUMP= $(TOPLEVEL)_dump

COMPILE_ARGS += -I$(SOURCES_DIR)

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
	echo '    $$dumpvars(3, $(TOPLEVEL));' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

wave:
	gtkwave $(TOPLEVEL).fst &

clean::
	rm -rf *.fst *.vcd *_dump.v results.xml flash_mem.hex