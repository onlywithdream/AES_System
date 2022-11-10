#ifndef __SW_AES__
#define __SW_AES__

#include <stdint.h>

void key_expansion(const uint32_t* key, uint32_t* rkey, const uint8_t nk);

void cipher(const uint32_t* ptext, uint32_t* ctext, const uint32_t* rkey, const uint8_t nk);

void inv_cipher(const uint32_t* ctext, uint32_t* ptext, const uint32_t* rkey, const uint8_t nk);

#endif