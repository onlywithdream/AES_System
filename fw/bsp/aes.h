#ifndef __AES__
#define __AES__

#include "picorv32.h"

typedef struct
{
    __I  uint32_t state;

    __O  uint8_t  cipher;
    __O  uint8_t  expand;
    __IO uint8_t  nk;
    __IO uint8_t  inv;

    __O  uint32_t key_w;

    __IO  uint32_t pct_w0;
    __IO  uint32_t pct_w1;
    __IO  uint32_t pct_w2;
    __IO  uint32_t pct_w3;
}aes_t;

typedef enum
{
    NK_4 = 0,
    NK_6 = 1,
    NK_8 = 3
}nk_t;

uint8_t aes_getstate(aes_t* aes);

void aes_setinv(aes_t* aes, const int inv);
uint8_t aes_getinv(aes_t* aes);

void aes_setnk(aes_t* aes, const nk_t nk);
nk_t aes_getnk(aes_t* aes);

void aes_cipher(aes_t* aes);

void aes_expand(aes_t* aes);

void aes_setkeyw(aes_t* aes, const uint32_t w);
void aes_setkey(aes_t* aes, const uint32_t* buf, const nk_t nk);

void aes_setpctw(aes_t* aes, const uint32_t w, const int index);
void aes_setpcts(aes_t* aes, const uint32_t* buf, const int pcts_n);

uint32_t aes_getpctw(aes_t* aes, const int index);
void aes_getpcts(aes_t* aes, uint32_t* buf, const int pcts_n);

#endif