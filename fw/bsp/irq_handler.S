#include "picorv32_custom_insn.h"

.global irq

.section .text.irq_handler
irq_vec:
//restore registers
    picorv32_setq_insn(q2, x1)
	picorv32_setq_insn(q3, x2)

	addi x2, x2, -128

	picorv32_getq_insn(x1, q0)   //store q0
	sw x1,   0*4(x2)
	picorv32_getq_insn(x1, q2)   //store x1
	sw x1,   1*4(x2)
	picorv32_getq_insn(x1, q3)   //store x2
	sw x1,   2*4(x2)
	sw x3,   3*4(x2)
	sw x4,   4*4(x2)
	sw x5,   5*4(x2)
	sw x6,   6*4(x2)
	sw x7,   7*4(x2)
	sw x8,   8*4(x2)
	sw x9,   9*4(x2)
	sw x10, 10*4(x2)
	sw x11, 11*4(x2)
	sw x12, 12*4(x2)
	sw x13, 13*4(x2)
	sw x14, 14*4(x2)
	sw x15, 15*4(x2)
	sw x16, 16*4(x2)
	sw x17, 17*4(x2)
	sw x18, 18*4(x2)
	sw x19, 19*4(x2)
	sw x20, 20*4(x2)
	sw x21, 21*4(x2)
	sw x22, 22*4(x2)
	sw x23, 23*4(x2)
	sw x24, 24*4(x2)
	sw x25, 25*4(x2)
	sw x26, 26*4(x2)
	sw x27, 27*4(x2)
	sw x28, 28*4(x2)
	sw x29, 29*4(x2)
	sw x30, 30*4(x2)
	sw x31, 31*4(x2)

//call irq function
//args
	mv a0, x2 //regs
	picorv32_getq_insn(a1, q1) //irq_mask
	jal ra, irq

//recover registers
//new irq_regs address returned from C code in a0
	mv x2, a0

	lw x1,   0*4(x2)
	picorv32_setq_insn(q0, x1)
	lw x1,   1*4(x2)
	picorv32_setq_insn(q1, x1)
	lw x1,   2*4(x2)
	picorv32_setq_insn(q2, x1)
	lw x3,   3*4(x2)
	lw x4,   4*4(x2)
	lw x5,   5*4(x2)
	lw x6,   6*4(x2)
	lw x7,   7*4(x2)
	lw x8,   8*4(x2)
	lw x9,   9*4(x2)
	lw x10, 10*4(x2)
	lw x11, 11*4(x2)
	lw x12, 12*4(x2)
	lw x13, 13*4(x2)
	lw x14, 14*4(x2)
	lw x15, 15*4(x2)
	lw x16, 16*4(x2)
	lw x17, 17*4(x2)
	lw x18, 18*4(x2)
	lw x19, 19*4(x2)
	lw x20, 20*4(x2)
	lw x21, 21*4(x2)
	lw x22, 22*4(x2)
	lw x23, 23*4(x2)
	lw x24, 24*4(x2)
	lw x25, 25*4(x2)
	lw x26, 26*4(x2)
	lw x27, 27*4(x2)
	lw x28, 28*4(x2)
	lw x29, 29*4(x2)
	lw x30, 30*4(x2)
	lw x31, 31*4(x2)
	picorv32_getq_insn(x1, q1)
	picorv32_getq_insn(x2, q2)

    picorv32_retirq_insn()