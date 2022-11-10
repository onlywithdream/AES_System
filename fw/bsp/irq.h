#ifndef __IRQ__
#define __IRQ__

#include "stdint.h"

#include "picorv32_custom_insn.h"

uint32_t *irq(uint32_t *regs, uint32_t irq_mask);

#endif