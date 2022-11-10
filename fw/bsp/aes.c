#include "aes.h"

inline uint8_t aes_getstate(aes_t* aes)
{
    return aes->state;
}

inline void aes_setinv(aes_t* aes, const int inv)
{
    aes->inv = inv;
}

inline uint8_t aes_getinv(aes_t* aes)
{
    return aes->inv;
}

inline void aes_setnk(aes_t* aes, const nk_t nk)
{
    aes->nk = nk;
}

inline nk_t aes_getnk(aes_t* aes)
{
    return aes->nk;
}

inline void aes_cipher(aes_t* aes)
{
    aes->cipher = 1;
}

inline void aes_expand(aes_t* aes)
{
    aes->expand = 1;
}

inline void aes_setkeyw(aes_t* aes, const uint32_t w)
{
    aes->key_w = w;
}

inline void aes_setkey(aes_t* aes, const uint32_t* buf, const nk_t nk)
{
    const uint32_t* buf_end = buf + (nk == NK_4 ? 4 : (nk == NK_6 ? 6 : 8));
    for (; buf < buf_end; buf++) aes->key_w = *buf;
}

inline void aes_setpctw(aes_t* aes, const uint32_t w, const int index)
{
    *((uint32_t*)aes+3+index) = w;
}

inline void aes_setpcts(aes_t* aes, const uint32_t* buf, const int pcts_n)
{
    for (int w_i = 0; w_i < pcts_n*4; w_i+=4)
    {
        aes->pct_w0 = buf[w_i+0];
        aes->pct_w1 = buf[w_i+1];
        aes->pct_w2 = buf[w_i+2];
        aes->pct_w3 = buf[w_i+3];
    }
}

inline uint32_t aes_getpctw(aes_t* aes, const int index)
{
    return *((uint32_t*)aes+3+index);
}

inline void aes_getpcts(aes_t* aes, uint32_t* buf, const int pcts_n)
{
    for (int w_i = 0; w_i < pcts_n*4; w_i+=4)
    {
        buf[w_i+0] = aes->pct_w0;
        buf[w_i+1] = aes->pct_w1;
        buf[w_i+2] = aes->pct_w2;
        buf[w_i+3] = aes->pct_w3;
    }
}
