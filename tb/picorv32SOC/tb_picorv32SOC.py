import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer

@cocotb.test()
async def tb_picorv32SOC(dut):
    cocotb.start_soon(Clock(dut.eclk, 37, units='ns').start())
    dut.erstn.value = 1

    await Timer(1000, units='us')