#include "picorv32.h"
#include "uart.h"
#include "aes.h"

#define BAUD_RATE 115200

uart_t* uart = (uart_t*)UART_BASE;
aes_t*  aes  = (aes_t*)AES_BASE;

const uint8_t nks[] = {NK_4, NK_6, NK_8};

const uint32_t key[] = {0x03020100, 0x07060504, 0x0b0a0908, 0x0f0e0d0c, 
                        0x13121110, 0x17161514, 0x1b1a1918, 0x1f1e1d1c};

const uint32_t ptext[] = {0x33221100, 0x77665544, 0xbbaa9988, 0xffeeddcc};

uint32_t result[4];

void print_words(uint32_t* words, int n);

int main()
{
    uart_init(uart, BAUD_RATE);

    printf("Key is: \n");
    print_words(key, 8);

    printf("Ptext is: \n");
    print_words(ptext, 4);

    for (int i = 0; i < 3; i++)
    {
        printf("Nk is: %d\n", 4+i*2);

        aes_setnk(aes, nks[i]);
        if (aes_getnk(aes) != nks[i])
        {
            printf("Nk set fail!\n");
            goto infinite_loop;
        }

        aes_setkey(aes, key, nks[i]);
        aes_expand(aes);
        while (aes_getstate(aes) != 0);

        for (int inv = 0; inv < 2; inv++)
        {
            aes_setinv(aes, inv);
            if (aes_getinv(aes) != inv)
            {
                printf("Inv set fail!\n");
                goto infinite_loop;
            }

            aes_setpcts(aes, inv?result:ptext, 8);
            aes_cipher(aes);
            while (aes_getstate(aes) != 0);

            aes_getpcts(aes, result, 1);
            printf(inv?"P":"C");
            printf("text is: \n");
            print_words(result, 4);
        }
    }

    infinite_loop: for (; ; );
}

void print_words(uint32_t* words, int n)
{
    for (int i = 0; i < n; i++)
    {
        printf("%x\n", words[i]);
    }
}