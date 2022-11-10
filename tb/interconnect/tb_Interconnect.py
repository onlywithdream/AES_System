import cocotb
from cocotb.triggers import Timer

from random import randint

@cocotb.test()
async def tb_Interconnect(dut):
    m_start = [0x00000000, 0x10000000, 0x20000000, 0x28000000, 
               0x30000000, 0x38000000, 0x40000000]
    m_end   = [0x10000000, 0x20000000, 0x28000000, 0x30000000, 
               0x38000000, 0x40000000, 0x80000000]
    
    #get reference
    s_valid = dut.s_mem_valid
    s_ready = dut.s_mem_ready
    s_addr  = dut.s_mem_addr
    s_wdata = dut.s_mem_wdata
    s_wstrb = dut.s_mem_wstrb
    s_rdata = dut.s_mem_rdata

    m_valid = [dut.m_mem_valid0, dut.m_mem_valid1, dut.m_mem_valid2, dut.m_mem_valid3, 
               dut.m_mem_valid4, dut.m_mem_valid5, dut.m_mem_valid6]

    m_ready = [dut.m_mem_ready0, dut.m_mem_ready1, dut.m_mem_ready2, dut.m_mem_ready3, 
               dut.m_mem_ready4, dut.m_mem_ready5, dut.m_mem_ready6]

    m_addr = [dut.m_mem_addr0, dut.m_mem_addr1, dut.m_mem_addr2, dut.m_mem_addr3, 
              dut.m_mem_addr4, dut.m_mem_addr5, dut.m_mem_addr6]

    m_wdata = [dut.m_mem_wdata0, dut.m_mem_wdata1, dut.m_mem_wdata2, dut.m_mem_wdata3, 
               dut.m_mem_wdata4, dut.m_mem_wdata5, dut.m_mem_wdata6]

    m_wstrb = [dut.m_mem_wstrb0, dut.m_mem_wstrb1, dut.m_mem_wstrb2, dut.m_mem_wstrb3, 
               dut.m_mem_wstrb4, dut.m_mem_wstrb5, dut.m_mem_wstrb6]

    m_rdata = [dut.m_mem_rdata0, dut.m_mem_rdata1, dut.m_mem_rdata2, dut.m_mem_rdata3, 
               dut.m_mem_rdata4, dut.m_mem_rdata5, dut.m_mem_rdata6]

    #init
    s_valid.value = 0
    s_wdata.value = 0
    s_wstrb.value = 0

    for i in range(7):
        m_ready[i].value = 0
        m_rdata[i].value = randint(0, 2**32-1)

    for i in range(7):
        for j in range(100):
            s_addr.value = randint(m_start[i], m_end[i])
            s_wdata.value = randint(0, 2**32-1)
            s_wstrb.value = randint(0, 2**4-1)

            for s_valid_val in range(2):
                for m_ready_val in range(2):
                    s_valid.value = s_valid_val
                    m_ready[i].value = m_ready_val
                    await Timer(1, units='ns')

                    assert(m_ready[i].value == s_ready.value)
                    assert(m_valid[i].value == s_valid.value)
                    assert(m_rdata[i].value == s_rdata.value)

                    for k in range(7):
                        assert(m_addr[k].value == s_addr.value)
                        assert(m_wdata[k].value == s_wdata.value)
                        assert(m_wstrb[k].value == s_wstrb.value)