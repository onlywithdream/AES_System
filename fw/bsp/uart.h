#ifndef __UART__
#define __UART__

#include "picorv32.h"

typedef struct
{
    __IO uint32_t CLKDIV;
    __IO uint32_t DATA;
}uart_t;

void uart_init(uart_t* uart, const uint32_t baud_rate);
uint8_t uart_putchar(uart_t* uart, const uint8_t c);
uint8_t uart_getchar(uart_t* uart);

#endif