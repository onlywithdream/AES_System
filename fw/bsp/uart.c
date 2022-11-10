#include "uart.h"

void uart_init(uart_t* uart, const uint32_t baud_rate)
{
    uart->CLKDIV = SYSCLKFREQ / baud_rate;
}

uint8_t uart_putchar(uart_t* uart, const uint8_t c)
{
	uart->DATA = c;
    return c;
}

uint8_t uart_getchar(uart_t* uart)
{
    int c;
    do{
        c = uart->DATA;
    }while(c < 0);
    return c;
}
