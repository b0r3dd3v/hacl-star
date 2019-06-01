#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdbool.h>
#include <time.h>
#include <vec128.h>

typedef uint64_t cycles;

static __inline__ cycles cpucycles(void)
{
  uint64_t rax,rdx,aux;
  asm volatile ( "rdtscp\n" : "=a" (rax), "=d" (rdx), "=c" (aux) : : );
  return (rdx << 32) + rax;
}


//https://boringssl.googlesource.com/boringssl/+/2214/crypto/cipher/cipher_test.txt

extern void Hacl_AES_256_GCM_M32_aes256_gcm_init(uint64_t* ctx, uint8_t* k, uint8_t* n);
extern void Hacl_AES_256_GCM_M32_aes256_gcm_encrypt(uint64_t* ctx, int in_len, uint8_t* out, uint8_t* in, int aad_len, uint8_t* aad);
extern bool Hacl_AES_256_GCM_M32_aes256_gcm_decrypt(uint64_t* ctx, int out_len, uint8_t* out, uint8_t* in, int aad_len, uint8_t* aad);

#define ROUNDS 100000
#define SIZE   16384

int main() {
  uint8_t in[60] = {
    0xd9, 0x31, 0x32, 0x25, 0xf8, 0x84, 0x06, 0xe5,
    0xa5, 0x59, 0x09, 0xc5, 0xaf, 0xf5, 0x26, 0x9a,
    0x86, 0xa7, 0xa9, 0x53, 0x15, 0x34, 0xf7, 0xda,
    0x2e, 0x4c, 0x30, 0x3d, 0x8a, 0x31, 0x8a, 0x72,
    0x1c, 0x3c, 0x0c, 0x95, 0x95, 0x68, 0x09, 0x53,
    0x2f, 0xcf, 0x0e, 0x24, 0x49, 0xa6, 0xb5, 0x25,
    0xb1, 0x6a, 0xed, 0xf5, 0xaa, 0x0d, 0xe6, 0x57,
    0xba, 0x63, 0x7b, 0x39};
  uint8_t k[32] = {
    0xfe, 0xff, 0xe9, 0x92, 0x86, 0x65, 0x73, 0x1c,
    0x6d, 0x6a, 0x8f, 0x94, 0x67, 0x30, 0x83, 0x08,
    0xfe, 0xff, 0xe9, 0x92, 0x86, 0x65, 0x73, 0x1c,
    0x6d, 0x6a, 0x8f, 0x94, 0x67, 0x30, 0x83, 0x08
  };
  uint8_t n[12] = {
    0xca, 0xfe, 0xba, 0xbe, 0xfa, 0xce, 0xdb, 0xad,
    0xde, 0xca, 0xf8, 0x88
  };
  uint8_t aad[20] = {
    0xfe, 0xed, 0xfa, 0xce, 0xde, 0xad, 0xbe, 0xef,
    0xfe, 0xed, 0xfa, 0xce, 0xde, 0xad, 0xbe, 0xef,
    0xab, 0xad, 0xda, 0xd2
  };
  uint8_t exp[76] = {
    0x52, 0x2d, 0xc1, 0xf0, 0x99, 0x56, 0x7d, 0x07, 
    0xf4, 0x7f, 0x37, 0xa3, 0x2a, 0x84, 0x42, 0x7d,
    0x64, 0x3a, 0x8c, 0xdc, 0xbf, 0xe5, 0xc0, 0xc9,
    0x75, 0x98, 0xa2, 0xbd, 0x25, 0x55, 0xd1, 0xaa, 
    0x8c, 0xb0, 0x8e, 0x48, 0x59, 0x0d, 0xbb, 0x3d,
    0xa7, 0xb0, 0x8b, 0x10, 0x56, 0x82, 0x88, 0x38,
    0xc5, 0xf6, 0x1e, 0x63, 0x93, 0xba, 0x7a, 0x0a,
    0xbc, 0xc9, 0xf6, 0x62, 0x76, 0xfc, 0x6e, 0xce, 
    0x0f, 0x4e, 0x17, 0x68, 0xcd, 0xdf, 0x88, 0x53,
    0xbb, 0x2d, 0x55, 0x1b
  };




 /* uint8_t in2[652] = {
0x08,0x00,0x00,0x1e,0x00,0x1c,0x00,0x0a,0x00,0x14,0x00,0x12,0x00,0x1d,0x00,0x17,0x00,0x18,0x00,0x19,0x01,0x00,0x01,0x01,0x01,0x02,0x01,0x03,0x01,0x04,0x00,0x00,0x00,0x00,0x0b,0x00,0x01,0xb9,0x00,0x00,0x01,0xb5,0x00,0x01,0xb0,0x30,0x82,0x01,0xac,0x30,0x82,0x01,0x15,0xa0,0x03,0x02,0x01,0x02,0x02,0x01,0x02,0x30,0x0d,0x06,0x09,0x2a,0x86,0x48,0x86,0xf7,0x0d,0x01,0x01,0x0b,0x05,0x00,0x30,0x0e,0x31,0x0c,0x30,0x0a,0x06,0x03,0x55,0x04,0x03,0x13,0x03,0x72,0x73,0x61,0x30,0x1e,0x17,0x0d,0x31,0x36,0x30,0x37,0x33,0x30,0x30,0x31,0x32,0x33,0x35,0x39,0x5a,0x17,0x0d,0x32,0x36,0x30,0x37,0x33,0x30,0x30,0x31,0x32,0x33,0x35,0x39,0x5a,0x30,0x0e,0x31,0x0c,0x30,0x0a,0x06,0x03,0x55,0x04,0x03,0x13,0x03,0x72,0x73,0x61,0x30,0x81,0x9f,0x30,0x0d,0x06,0x09,0x2a,0x86,0x48,0x86,0xf7,0x0d,0x01,0x01,0x01,0x05,0x00,0x03,0x81,0x8d,0x00,0x30,0x81,0x89,0x02,0x81,0x81,0x00,0xb4,0xbb,0x49,0x8f,0x82,0x79,0x30,0x3d,0x98,0x08,0x36,0x39,0x9b,0x36,0xc6,0x98,0x8c,0x0c,0x68,0xde,0x55,0xe1,0xbd,0xb8,0x26,0xd3,0x90,0x1a,0x24,0x61,0xea,0xfd,0x2d,0xe4,0x9a,0x91,0xd0,0x15,0xab,0xbc,0x9a,0x95,0x13,0x7a,0xce,0x6c,0x1a,0xf1,0x9e,0xaa,0x6a,0xf9,0x8c,0x7c,0xed,0x43,0x12,0x09,0x98,0xe1,0x87,0xa8,0x0e,0xe0,0xcc,0xb0,0x52,0x4b,0x1b,0x01,0x8c,0x3e,0x0b,0x63,0x26,0x4d,0x44,0x9a,0x6d,0x38,0xe2,0x2a,0x5f,0xda,0x43,0x08,0x46,0x74,0x80,0x30,0x53,0x0e,0xf0,0x46,0x1c,0x8c,0xa9,0xd9,0xef,0xbf,0xae,0x8e,0xa6,0xd1,0xd0,0x3e,0x2b,0xd1,0x93,0xef,0xf0,0xab,0x9a,0x80,0x02,0xc4,0x74,0x28,0xa6,0xd3,0x5a,0x8d,0x88,0xd7,0x9f,0x7f,0x1e,0x3f,0x02,0x03,0x01,0x00,0x01,0xa3,0x1a,0x30,0x18,0x30,0x09,0x06,0x03,0x55,0x1d,0x13,0x04,0x02,0x30,0x00,0x30,0x0b,0x06,0x03,0x55,0x1d,0x0f,0x04,0x04,0x03,0x02,0x05,0xa0,0x30,0x0d,0x06,0x09,0x2a,0x86,0x48,0x86,0xf7,0x0d,0x01,0x01,0x0b,0x05,0x00,0x03,0x81,0x81,0x00,0x85,0xaa,0xd2,0xa0,0xe5,0xb9,0x27,0x6b,0x90,0x8c,0x65,0xf7,0x3a,0x72,0x67,0x17,0x06,0x18,0xa5,0x4c,0x5f,0x8a,0x7b,0x33,0x7d,0x2d,0xf7,0xa5,0x94,0x36,0x54,0x17,0xf2,0xea,0xe8,0xf8,0xa5,0x8c,0x8f,0x81,0x72,0xf9,0x31,0x9c,0xf3,0x6b,0x7f,0xd6,0xc5,0x5b,0x80,0xf2,0x1a,0x03,0x01,0x51,0x56,0x72,0x60,0x96,0xfd,0x33,0x5e,0x5e,0x67,0xf2,0xdb,0xf1,0x02,0x70,0x2e,0x60,0x8c,0xca,0xe6,0xbe,0xc1,0xfc,0x63,0xa4,0x2a,0x99,0xbe,0x5c,0x3e,0xb7,0x10,0x7c,0x3c,0x54,0xe9,0xb9,0xeb,0x2b,0xd5,0x20,0x3b,0x1c,0x3b,0x84,0xe0,0xa8,0xb2,0xf7,0x59,0x40,0x9b,0xa3,0xea,0xc9,0xd9,0x1d,0x40,0x2d,0xcc,0x0c,0xc8,0xf8,0x96,0x12,0x29,0xac,0x91,0x87,0xb4,0x2b,0x4d,0xe1,0x00,0x00,0x0f,0x00,0x00,0x84,0x08,0x04,0x00,0x80,0x45,0x47,0xd6,0x16,0x8f,0x25,0x10,0xc5,0x50,0xbd,0x94,0x9c,0xd2,0xbc,0x63,0x1f,0xf1,0x34,0xfa,0x10,0xa8,0x27,0xff,0x69,0xb1,0x66,0xa6,0xbd,0x95,0xe2,0x49,0xed,0x0d,0xaf,0x57,0x15,0x92,0xeb,0xbe,0x9f,0xf1,0x3d,0xe6,0xb0,0x3a,0xcc,0x21,0x81,0x46,0x78,0x1f,0x69,0x3b,0x5a,0x69,0x2b,0x73,0x19,0xd7,0x4f,0xd2,0xe5,0x3b,0x6a,0x2d,0xf0,0xf6,0x78,0x5d,0x62,0x4f,0x02,0x4a,0x44,0x03,0x0c,0xa0,0x0b,0x86,0x9a,0xe8,0x1a,0x53,0x2b,0x19,0xe4,0x7e,0x52,0x5f,0xf4,0xa6,0x2c,0x51,0xa5,0x88,0x9e,0xb5,0x65,0xfe,0xe2,0x68,0x59,0x0d,0x8a,0x3c,0xa3,0xc1,0xbc,0x3b,0xd5,0x40,0x4e,0x39,0x72,0x0c,0xa2,0xea,0xee,0x30,0x8f,0x4e,0x07,0x00,0x76,0x1e,0x98,0x63,0x89,0x14,0x00,0x00,0x20,0x9e,0xfe,0xe0,0x3e,0xbf,0xfb,0xc0,0xdc,0x23,0xd2,0x6d,0x95,0x87,0x44,0xc0,0x9e,0x30,0x00,0x47,0x7e,0xff,0x7a,0xe3,0x14,0x8a,0x50,0xe5,0x67,0x00,0x13,0xaa,0xaa,0x16       };
  uint8_t k2[16] = {
0xfd,0xa2,0xa4,0x40,0x46,0x70,0x80,0x8f,0x49,0x37,0x47,0x8b,0x8b,0x6e,0x3f,0xe1
	      };
  uint8_t n2[12] = {
0xb5,0xf3,0xa3,0xfa,0xe1,0xcb,0x25,0xc9,0xdc,0xd7,0x39,0x93
	      };
  uint8_t aad2[0] = {};
  uint8_t exp2[668] = {
0xc1,0xe6,0x31,0xf8,0x1d,0x2a,0xf2,0x21,0xeb,0xb6,0xa9,0x57,0xf5,0x8f,0x3e,0xe2,0x66,0x27,0x26,0x35,0xe6,0x7f,0x99,0xa7,0x52,0xf0,0xdf,0x08,0xad,0xeb,0x33,0xba,0xb8,0x61,0x1e,0x55,0xf3,0x3d,0x72,0xcf,0x84,0x38,0x24,0x61,0xa8,0xbf,0xe0,0xa6,0x59,0xba,0x2d,0xd1,0x87,0x3f,0x6f,0xcc,0x70,0x7a,0x98,0x41,0xce,0xfc,0x1f,0xb0,0x35,0x26,0xb9,0xca,0x4f,0xe3,0x43,0xe5,0x80,0x5e,0x95,0xa5,0xc0,0x1e,0x56,0x57,0x06,0x38,0xa7,0x6a,0x4b,0xc8,0xfe,0xb0,0x7b,0xe8,0x79,0xf9,0x05,0x68,0x61,0x7d,0x90,0x5f,0xec,0xd5,0xb1,0x61,0x9f,0xb8,0xec,0x4a,0x66,0x28,0xd1,0xbb,0x2b,0xb2,0x24,0xc4,0x90,0xff,0x97,0xa6,0xc0,0xe9,0xac,0xd0,0x36,0x04,0xbc,0x3a,0x59,0xd8,0x6b,0xda,0xb4,0xe0,0x84,0xc1,0xc1,0x45,0x0f,0x9c,0x9d,0x2a,0xfe,0xb1,0x72,0xc0,0x72,0x34,0xd7,0x39,0x86,0x8e,0xbd,0x62,0xde,0x20,0x60,0xa8,0xde,0x98,0x94,0x14,0xa8,0x29,0x20,0xda,0xcd,0x1c,0xac,0x0c,0x6e,0x72,0xec,0xd7,0xf4,0x01,0x85,0x74,0xce,0xac,0xa6,0xd2,0x9f,0x36,0x1b,0xc3,0x7e,0xe2,0x88,0x8b,0x8e,0x30,0x2c,0xa9,0x56,0x1a,0x9d,0xe9,0x16,0x3e,0xdf,0xa6,0x6b,0xad,0xd4,0x89,0x48,0x84,0xc7,0xb3,0x59,0xbc,0xac,0xae,0x59,0x08,0x05,0x1b,0x37,0x95,0x2e,0x10,0xa4,0x5f,0xe7,0x3f,0xda,0x12,0x6e,0xbd,0x67,0x57,0x5f,0x1b,0xed,0x8a,0x99,0x2a,0x89,0x47,0x4d,0x7d,0xec,0x1e,0xed,0x32,0x78,0x24,0x12,0x3a,0x41,0x4a,0xdb,0x66,0xd5,0xef,0x7d,0x08,0x36,0xff,0x98,0xc2,0xcd,0xd7,0xfb,0x07,0x81,0xe1,0x92,0xbf,0x0c,0x75,0x68,0xbf,0x7d,0x89,0x0a,0x51,0xc3,0x32,0x87,0x9b,0x50,0x37,0xb2,0x12,0xd6,0x22,0x41,0x2c,0xa4,0x8e,0x83,0x23,0x81,0x7b,0xd6,0xd7,0x46,0xee,0xf6,0x83,0x84,0x5c,0xec,0x4e,0x3e,0xf6,0x4b,0x3a,0x18,0xfc,0xce,0x51,0x3e,0xa9,0x51,0xf3,0x36,0x66,0x93,0xa7,0xff,0x49,0x0d,0x09,0xd0,0x8a,0xb1,0xf6,0x3e,0x13,0x62,0x5a,0x54,0x59,0x61,0x59,0x9c,0x0d,0x9c,0x7a,0x09,0x9d,0x11,0x63,0xca,0xd1,0xb9,0xbc,0xf8,0xe9,0x17,0xd7,0x66,0xb9,0x88,0x53,0xef,0x68,0x77,0x83,0x4f,0x89,0x1d,0xf1,0x6b,0xe1,0xfc,0xc9,0xc1,0x8e,0xa1,0x88,0x2e,0xa3,0xf1,0xf4,0xb6,0x43,0x58,0xe1,0xb1,0x46,0xce,0xbf,0xb3,0xe0,0x2e,0x15,0x3f,0xdb,0x73,0xaf,0x26,0x93,0xf2,0x2c,0x6f,0x59,0x3f,0xa4,0x75,0x38,0x0b,0xa6,0x61,0x17,0x40,0xad,0x20,0xe3,0x19,0xa6,0x54,0xac,0x56,0x84,0x77,0x52,0x36,0x16,0x2e,0x84,0x47,0xed,0x80,0x88,0x61,0xbf,0xbd,0xa6,0xe1,0x8e,0xc9,0x7a,0xe0,0x90,0xbf,0x70,0x34,0x75,0xcf,0xb9,0x0f,0xe2,0x0a,0x3c,0x55,0xbe,0xf6,0xf5,0xeb,0xa6,0xe6,0xa1,0xda,0x6a,0x19,0x96,0xb8,0xbd,0xe4,0x21,0x80,0x60,0x8c,0xa2,0x27,0x9d,0xef,0x8e,0x81,0x53,0x89,0x5c,0xc8,0x50,0xdb,0x64,0x20,0x56,0x1c,0x04,0xb5,0x72,0x9c,0xc6,0x88,0x34,0x36,0xea,0x02,0xee,0x07,0xeb,0x9b,0xae,0xe2,0xfb,0x3a,0x9e,0x1b,0xbd,0xa8,0x73,0x0d,0x6b,0x22,0x05,0x76,0xe2,0x4d,0xf7,0x0a,0xf6,0x92,0x8e,0xb8,0x65,0xfe,0xe8,0xa1,0xd1,0xc0,0xf1,0x81,0x8a,0xca,0x68,0xd5,0x00,0x2a,0xe4,0xc6,0x5b,0x2f,0x49,0xc9,0xe6,0xe2,0x1d,0xcf,0x76,0x78,0x4a,0xdb,0xd0,0xe8,0x87,0xa3,0x68,0x32,0xef,0x85,0xbe,0xb1,0x05,0x87,0xf1,0x6c,0x6f,0xfe,0x60,0xd7,0x45,0x10,0x59,0xec,0x7f,0x10,0x14,0xc3,0xef,0xe1,0x9e,0x56,0xae,0xdb,0x5a,0xd3,0x1a,0x9f,0x29,0xdc,0x44,0x58,0xcf,0xbf,0x0c,0x70,0x70,0xc1,0x75,0xdc,0xad,0x46,0xe1,0x67,0x52,0x26,0xb4,0x7c,0x07,0x1a,0xad,0x31,0x72,0xeb,0xd3,0x3e,0x45,0xd7,0x41,0xcb,0x91,0x25,0x3a,0x01,0xa6,0x9a,0xe3,0xcc,0x29,0x2b,0xce,0x9c,0x03,0x24,0x6a,0xc9,0x51,0xe4,0x5e,0x97,0xeb,0xf0,0x4a,0x9d,0x51,0xfa,0xb5,0xcf,0x06,0xd9,0x48,0x5c,0xce,0x74,0x6b,0x1c,0x07,0x7b,0xe6,0x9a,0xd1,0x53,0xf1,0x65,0x6e,0xf8,0x9f,0xc7,0xd1,0xed,0x8c,0x3e,0x2d,0xa7,0xa2
};
*/


  uint8_t comp[76] = {0};
  bool ok = true;

  uint64_t ctx[396] = {0};
  Hacl_AES_256_GCM_M32_aes256_gcm_init(ctx,k,n);
  Hacl_AES_256_GCM_M32_aes256_gcm_encrypt(ctx,60,comp,in,20,aad);
  printf("AESGCM-AES256-M32 computed:");
  for (int i = 0; i < 76; i++)
    printf("%02x",comp[i]);
  printf("\n");
  printf("AESGCM-AES256-M32 expected:");
  for (int i = 0; i < 76; i++)
    printf("%02x",exp[i]);
  printf("\n");
  ok = true;
  for (int i = 0; i < 76; i++) {
    ok = ok & (exp[i] == comp[i]);
    if (!ok) break;
  }
  if (ok) printf("Encrypt Success!\n");
  else printf("Encrypt FAILURE!\n");

  Hacl_AES_256_GCM_M32_aes256_gcm_init(ctx,k,n);
  bool res = Hacl_AES_256_GCM_M32_aes256_gcm_decrypt(ctx,60,comp,exp,20,aad);
  if (!res)
    printf("AESGCM-AES256-M32 Decrypt failed!\n");
  else {
    printf("AESGCM-AES256-M32 Decrypt computed:");
    for (int i = 0; i < 60; i++)
      printf("%02x",comp[i]);
    printf("\n");
    printf("AESGCM-AES256-M32 Decrypt expected:");
    for (int i = 0; i < 60; i++)
      printf("%02x",in[i]);
    printf("\n");
    ok = true;
    for (int i = 0; i < 60; i++)
      ok = ok & (in[i] == comp[i]);
    if (ok) printf("Decrypt Success!\n");
    else printf("Decrypt FAILURE!\n");
  }


  /*uint8_t comp2[668] = {0};
  Hacl_AES_256_GCM_M32_aes256_gcm_init(ctx,k2,n2);
  Hacl_AES_256_GCM_M32_aes256_gcm_encrypt(ctx,652,comp2,in2,0,aad2);
  printf("AESGCM-M32 computed:");
  for (int i = 0; i < 668; i++)
    printf("%02x",comp2[i]);
  printf("\n");
  printf("AESGCM_M32 expected:");
  for (int i = 0; i < 668; i++)
    printf("%02x",exp2[i]);
  printf("\n");
  ok = true;
  int i = 0;
  for (i = 0; i < 668; i++) {
    ok = ok & (exp2[i] == comp2[i]);
    if (!ok) break;
   }

  if (ok) printf("Encrypt Success!\n");
  else printf("Encrypt FAILURE at %d!\n",i);

  Hacl_AES_256_GCM_M32_aes256_gcm_init(ctx,k2,n2);
  res = Hacl_AES_256_GCM_M32_aes256_gcm_decrypt(ctx,652,comp2,exp2,0,aad2);
  if (!res)
    printf("AESGCM-M32 Decrypt failed!\n");
  else {
    printf("AESGCM-M32 Decrypt computed:");
    for (int i = 0; i < 652; i++)
      printf("%02x",comp2[i]);
    printf("\n");
    printf("AESGCM_M32 Decrypt expected:");
    for (int i = 0; i < 652; i++)
      printf("%02x",in2[i]);
    printf("\n");
    ok = true;
    int i = 0;
    for (i = 0; i < 652; i++)
      ok = ok & (in2[i] == comp2[i]);
    if (ok) printf("Decrypt Success!\n");
    else printf("Decrypt FAILURE at %d!\n",i);
  }
*/
  uint64_t len = SIZE;
  uint8_t plain[SIZE+16];
  uint8_t key[16];
  uint8_t nonce[12];
  cycles a,b;
  clock_t t1,t2;
  uint64_t count = ROUNDS * SIZE;
  memset(plain,'P',SIZE);
  memset(key,'K',16);
  memset(nonce,'N',12);

  Hacl_AES_256_GCM_M32_aes256_gcm_init(ctx,key,nonce);
  for (int j = 0; j < ROUNDS; j++) {
    Hacl_AES_256_GCM_M32_aes256_gcm_encrypt(ctx,SIZE,plain,plain,20,aad);
  }

  t1 = clock();
  a = cpucycles();
  for (int j = 0; j < ROUNDS; j++) {
    Hacl_AES_256_GCM_M32_aes256_gcm_encrypt(ctx,SIZE,plain,plain,20,aad);
  }
  b = cpucycles();
  t2 = clock();
  clock_t tdiff1 = t2 - t1;
  cycles cdiff1 = b - a;

  printf("AES-AES256-M32 PERF:\n");
  printf("cycles for %" PRIu64 " bytes: %" PRIu64 " (%.2fcycles/byte)\n",count,(uint64_t)cdiff1,(double)cdiff1/count);
  printf("time for %" PRIu64 " bytes: %" PRIu64 " (%.2fus/byte)\n",count,(uint64_t)tdiff1,(double)tdiff1/count);
  printf("bw %8.2f MB/s\n",(double)count/(((double)tdiff1 / CLOCKS_PER_SEC) * 1000000.0));
}
