#ifndef TEA_H_INCLUDED
#define  TEA_H_INCLUDED
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void tea_encrypt (uint32_t* v, uint32_t* k);
void tea_decrypt (uint32_t* v, uint32_t* k) ;

#ifdef __cplusplus
}
#endif

#endif