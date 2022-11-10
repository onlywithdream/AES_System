#include "picorv32.h"
#include "uart.h"
#include "aes.h"
#include "sw_aes.h"

#define BAUD_RATE 115200

#define WINV_INSTR 0x00
#define WNK_INSTR  0x10
#define EX_INSTR   0x20
#define WPCT_INSTR 0x30
#define RPCT_INSTR 0x40
#define TEST_INSTR 0x50

#define RECV_INSTR 0
#define RECV_N     1
#define RECV_DATA  2
#define SEND_DATA  3

uart_t* uart = (uart_t*)UART_BASE;
aes_t*   aes = (aes_t*) AES_BASE;

uint8_t instr;

uint8_t bytes_n;

uint8_t state;

uint8_t checksum;
uint8_t buf[128];

const nk_t AES_NK[] = {NK_4, NK_6, NK_8};

const uint32_t key[] = {0x03020100, 0x07060504, 0x0b0a0908, 0x0f0e0d0c, 
                        0x13121110, 0x17161514, 0x1b1a1918, 0x1f1e1d1c};

const uint32_t ptext[] = {0x33221100, 0x77665544, 0xbbaa9988, 0xffeeddcc};

uint32_t result[32];

void test(uint8_t type, const uint32_t times);

int main()
{
    uart_init(uart, BAUD_RATE);

    uart_putchar(uart, 'a');

    state = RECV_INSTR;
    
    for (; ; )
    {
        switch (state)
        {
        case RECV_INSTR:
            checksum = 0;
            buf[0] = uart_getchar(uart);
            instr = buf[0];
            switch (instr)
            {
            case WINV_INSTR:
                bytes_n = 1;
                state = RECV_DATA;
                break;
            case WNK_INSTR:
                bytes_n = 1;
                state = RECV_DATA;
                break;
            case EX_INSTR:
                state = RECV_N;
                break;
            case WPCT_INSTR:
                bytes_n = 128;
                state = RECV_DATA;
                break;
            case RPCT_INSTR:
                bytes_n = 128;
                state = SEND_DATA;
                break;
            case TEST_INSTR:
                bytes_n = 5;
                state = RECV_DATA;
                break;
            default:
                break;
            }
            uart_putchar(uart, instr);
            break;
        case RECV_N:
            bytes_n = uart_getchar(uart);
            state = RECV_DATA;
            break;
        case RECV_DATA:
            for (uint8_t i = 0; i < bytes_n; i++)
            {
                buf[i] = uart_getchar(uart);
                checksum += buf[i];
            }
            switch (instr)
            {
            case WINV_INSTR:
                aes_setinv(aes, buf[0]);
                break;
            case WNK_INSTR:
                aes_setnk(aes, buf[0]);
                break;
            case EX_INSTR:
                aes_setkey(aes, (uint32_t*)buf, AES_NK[bytes_n/8-2]);
                aes_expand(aes);
                break;
            case WPCT_INSTR:
                aes_setpcts(aes, (uint32_t*)buf, 8);
                aes_cipher(aes);
                break;
            case TEST_INSTR:
                test(buf[4], *((uint32_t*)buf));
                break;
            default:
                break;
            }
            state = RECV_INSTR;
            uart_putchar(uart, checksum);
            break;
        case SEND_DATA:
            while(aes_getstate(aes) != 0);
            aes_getpcts(aes, (uint32_t*)buf, 8);
            for (int i = 0; i < bytes_n; i++)
            {
                uart_putchar(uart, buf[i]);
                checksum += buf[i];
            }
            state = RECV_INSTR;
            uart_putchar(uart, checksum);
            break;
        default:
            break;
        }
    }
}

void test(uint8_t type, const uint32_t times)
{
    if(type == 0)
    {
        for (uint8_t nk = 4; nk <= 8; nk+=2)
        {
            key_expansion(key, (uint32_t*)buf, nk);
            for (uint32_t t = 0; t < times; t++)
            {
                cipher(ptext, result, (uint32_t*)buf, nk);
                inv_cipher(result, result, (uint32_t*)buf, nk);
            }
        }
    }
    else//When type > 0, it means number of blocks that aes module processes at one time
    {
        if (type > 8) type = 8;
        for (uint8_t i = 0; i < 3; i++)
        {
            aes_setnk(aes, AES_NK[i]);
            aes_setkey(aes, key, AES_NK[i]);
            aes_expand(aes);
            while (aes_getstate(aes) != 0);
            for (uint32_t t = 0; t < times; t+=type)
            {
                aes_setinv(aes, 0);
                aes_setpcts(aes, ptext, 8);
                aes_cipher(aes);
                while (aes_getstate(aes) != 0);
                aes_getpcts(aes, result, type);
                aes_setinv(aes, 1);
                aes_setpcts(aes, result, 8);
                aes_cipher(aes);
                while (aes_getstate(aes) != 0);
                aes_getpcts(aes, result, type);
            }
        }
    }
}