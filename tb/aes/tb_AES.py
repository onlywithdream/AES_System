from multiprocessing.connection import wait
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, Timer, Combine
from cocotb.queue import Queue

from random import randint

from AES import KeyExpansion, Cipher, InvCipher

async def input_pct(dut, times, q, rk, nk, inv):
    for i in range(times):
        #input pct
        for j in range(8):
            pct = [randint(0, 255) for j in range(16)]
            await q.put(InvCipher(pct, rk, nk) if inv else Cipher(pct, rk, nk))
            in_pct = 0
            dut.in_pct_first_flag.value = j == 0
            for k in range(16):
                in_pct |= pct[k] << (8*k)
            dut.in_pct.value = in_pct
            await RisingEdge(dut.clk)
            await Timer(1, units='ns')
        while dut.out_state != 0:
            await RisingEdge(dut.clk)
            await Timer(1, units='ns')

async def compare_pct(dut, times, q):
    for i in range(times):
        await RisingEdge(dut.out_pct_first_flag)
        for j in range(8):
            await Timer(1, units='ns')
            hw_pct = [0]*16
            for k in range(16):
                hw_pct[k] = (dut.out_pct.value>>(8*k))&0xFF
            assert hw_pct == await q.get()
            if j == 7:
                assert dut.out_pct_last_flag.value == 1
            await RisingEdge(dut.clk)
    

@cocotb.test()
async def tb_AES(dut):
    q = Queue()

    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())

    dut.in_inv_valid.value = 0
    dut.in_inv.value = 0

    dut.in_nk_valid.value = 0
    dut.in_nk.value = 0

    dut.in_key_expand.value = 0
    dut.in_key_valid.value = 0
    dut.in_key_w.value = 0

    dut.in_pct_first_flag.value = 0
    dut.in_pct.value = 0

    #rst
    dut.rst.value = 1
    await ClockCycles(dut.clk, 2)
    await Timer(1, units='ns')
    dut.rst.value = 0

    for nk in [4, 6, 8]:
        nr = 10 if nk == 4 else (12 if nk == 6 else 14)
        for inv in [0, 1]:
            #init inv and nk
            dut.in_inv_valid.value = 1
            dut.in_inv.value = inv
            dut.in_nk_valid.value = 1
            dut.in_nk.value = 0 if nk == 4 else (1 if nk == 6 else 3)
            await RisingEdge(dut.clk)
            await Timer(1, units='ns')
            dut.in_inv_valid.value = 0
            dut.in_nk_valid.value = 0
            while dut.out_state.value != 0:
                await RisingEdge(dut.clk)
                await Timer(1, units='ns')

            #expand key
            k = [randint(0, 255) for i in range(nk*4)]
            rk = KeyExpansion(k, nk)
            dut.in_key_valid.value = 1
            for i in range(nk):
                dut.in_key_expand.value = i == nk - 1
                in_key_w = 0
                for j in range(4):
                    in_key_w |= k[i*4+j] << (j*8)
                dut.in_key_w.value = in_key_w
                await RisingEdge(dut.clk)
                await Timer(1, units='ns')
            dut.in_key_valid.value = 0
            dut.in_key_expand.value = 0
            while dut.out_state.value != 0:
                await RisingEdge(dut.clk)
                await Timer(1, units='ns')

            #input pct and compare
            input = cocotb.start_soon(input_pct(dut, 20, q, rk, nk, inv))
            compare = cocotb.start_soon(compare_pct(dut, 20, q))

            await Combine(input, compare)