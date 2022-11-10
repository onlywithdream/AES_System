#ifndef __PICORV32__
#define __PICORV32__

//Include std head files
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>

//Macros
#define __I                     volatile const	/* 'read only' permissions      */
#define __O                     volatile        /* 'write only' permissions     */
#define __IO                    volatile        /* 'read / write' permissions   */

#define KHz (1000)
#define MHz (1000000)

//MCU frequency
#define SYSCLKFREQ (50 * MHz)	/* Base on System Clock in Hardware IPCore */

//Peripheral address base
#define UART_BASE  (0x20000000)
#define AES_BASE   (0x28000000)

#endif