from re import S
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, Timer

from random import randint

from AES import MixColumns, InvMixColumns

@cocotb.test()
async def tb_MixCols(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())

    dut.in_bypass_flag.value = 0

    dut.in_s_1.value = 0
    dut.out_s_1.value = 0

    dut.in_s_2.value = 0
    dut.out_s_2.value = 0

    await RisingEdge(dut.clk)
    await Timer(1, units='ns')

    #test mixcols
    for i in range(100):
        cols = [randint(0, 255) for j in range(16)]
        ac_mixed_cols = MixColumns(cols)
        ac_inv_mixed_cols = InvMixColumns(cols)

        in_s = 0
        for j in range(16):
            in_s |= cols[j] << (j*8)
        dut.in_s_1.value = in_s

        await ClockCycles(dut.clk, 2)
        await Timer(1, units='ns')

        out_s = dut.out_s_1.value
        hw_mixed_cols = [0] * 16
        for j in range(16):
            hw_mixed_cols[j] = (out_s >> (j*8)) & 0xFF
        assert ac_mixed_cols == hw_mixed_cols

        dut.in_s_2.value = out_s
        await ClockCycles(dut.clk, 2)
        await Timer(1, units='ns')

        out_s = dut.out_s_2.value
        hw_inv_mixed_cols = [0] * 16
        for j in range(16):
            hw_inv_mixed_cols[j] = (out_s >> (j*8)) & 0xFF
        assert ac_inv_mixed_cols == hw_inv_mixed_cols

    dut.in_bypass_flag.value = 1
    for i in range(100):
        in_s = randint(0, 2**128-1)
        dut.in_s_1.value = in_s
        dut.in_s_2.value = in_s

        await ClockCycles(dut.clk, 2)
        await Timer(1, units='ns')

        assert in_s == dut.out_s_1.value
        assert in_s == dut.out_s_2.value
