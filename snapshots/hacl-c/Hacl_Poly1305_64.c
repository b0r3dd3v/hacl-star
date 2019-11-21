/* MIT License
 *
 * Copyright (c) 2016-2018 INRIA and Microsoft Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


#include "Hacl_Poly1305_64.h"

extern uint64_t FStar_UInt64_eq_mask(uint64_t x0, uint64_t x1);

extern uint64_t FStar_UInt64_gte_mask(uint64_t x0, uint64_t x1);

extern FStar_UInt128_uint128
FStar_UInt128_add(FStar_UInt128_uint128 x0, FStar_UInt128_uint128 x1);

extern FStar_UInt128_uint128
FStar_UInt128_add_mod(FStar_UInt128_uint128 x0, FStar_UInt128_uint128 x1);

extern FStar_UInt128_uint128
FStar_UInt128_logand(FStar_UInt128_uint128 x0, FStar_UInt128_uint128 x1);

extern FStar_UInt128_uint128
FStar_UInt128_logor(FStar_UInt128_uint128 x0, FStar_UInt128_uint128 x1);

extern FStar_UInt128_uint128 FStar_UInt128_shift_left(FStar_UInt128_uint128 x0, uint32_t x1);

extern FStar_UInt128_uint128 FStar_UInt128_shift_right(FStar_UInt128_uint128 x0, uint32_t x1);

extern FStar_UInt128_uint128 FStar_UInt128_uint64_to_uint128(uint64_t x0);

extern uint64_t FStar_UInt128_uint128_to_uint64(FStar_UInt128_uint128 x0);

extern FStar_UInt128_uint128 FStar_UInt128_mul_wide(uint64_t x0, uint64_t x1);

inline static void Hacl_Bignum_Modulo_reduce(uint64_t *b)
{
  uint64_t b0 = b[0U];
  b[0U] = (b0 << (uint32_t)4U) + (b0 << (uint32_t)2U);
}

inline static void Hacl_Bignum_Modulo_carry_top(uint64_t *b)
{
  uint64_t b2 = b[2U];
  uint64_t b0 = b[0U];
  uint64_t b2_42 = b2 >> (uint32_t)42U;
  b[2U] = b2 & (uint64_t)0x3ffffffffffU;
  b[0U] = (b2_42 << (uint32_t)2U) + b2_42 + b0;
}

inline static void Hacl_Bignum_Modulo_carry_top_wide(FStar_UInt128_uint128 *b)
{
  FStar_UInt128_uint128 b2 = b[2U];
  FStar_UInt128_uint128 b0 = b[0U];
  FStar_UInt128_uint128
  b2_ = FStar_UInt128_logand(b2, FStar_UInt128_uint64_to_uint128((uint64_t)0x3ffffffffffU));
  uint64_t b2_42 = FStar_UInt128_uint128_to_uint64(FStar_UInt128_shift_right(b2, (uint32_t)42U));
  FStar_UInt128_uint128
  b0_ = FStar_UInt128_add(b0, FStar_UInt128_uint64_to_uint128((b2_42 << (uint32_t)2U) + b2_42));
  b[2U] = b2_;
  b[0U] = b0_;
}

inline static void
Hacl_Bignum_Fproduct_copy_from_wide_(uint64_t *output, FStar_UInt128_uint128 *input)
{
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)3U; i = i + (uint32_t)1U)
  {
    FStar_UInt128_uint128 xi = input[i];
    output[i] = FStar_UInt128_uint128_to_uint64(xi);
  }
}

inline static void
Hacl_Bignum_Fproduct_sum_scalar_multiplication_(
  FStar_UInt128_uint128 *output,
  uint64_t *input,
  uint64_t s
)
{
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)3U; i = i + (uint32_t)1U)
  {
    FStar_UInt128_uint128 xi = output[i];
    uint64_t yi = input[i];
    output[i] = FStar_UInt128_add_mod(xi, FStar_UInt128_mul_wide(yi, s));
  }
}

inline static void Hacl_Bignum_Fproduct_carry_wide_(FStar_UInt128_uint128 *tmp)
{
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)2U; i = i + (uint32_t)1U)
  {
    uint32_t ctr = i;
    FStar_UInt128_uint128 tctr = tmp[ctr];
    FStar_UInt128_uint128 tctrp1 = tmp[ctr + (uint32_t)1U];
    uint64_t r0 = FStar_UInt128_uint128_to_uint64(tctr) & (uint64_t)0xfffffffffffU;
    FStar_UInt128_uint128 c = FStar_UInt128_shift_right(tctr, (uint32_t)44U);
    tmp[ctr] = FStar_UInt128_uint64_to_uint128(r0);
    tmp[ctr + (uint32_t)1U] = FStar_UInt128_add(tctrp1, c);
  }
}

inline static void Hacl_Bignum_Fproduct_carry_limb_(uint64_t *tmp)
{
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)2U; i = i + (uint32_t)1U)
  {
    uint32_t ctr = i;
    uint64_t tctr = tmp[ctr];
    uint64_t tctrp1 = tmp[ctr + (uint32_t)1U];
    uint64_t r0 = tctr & (uint64_t)0xfffffffffffU;
    uint64_t c = tctr >> (uint32_t)44U;
    tmp[ctr] = r0;
    tmp[ctr + (uint32_t)1U] = tctrp1 + c;
  }
}

inline static void Hacl_Bignum_Fmul_shift_reduce(uint64_t *output)
{
  uint64_t tmp = output[2U];
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)2U; i = i + (uint32_t)1U)
  {
    uint32_t ctr = (uint32_t)3U - i - (uint32_t)1U;
    uint64_t z = output[ctr - (uint32_t)1U];
    output[ctr] = z;
  }
  output[0U] = tmp;
  Hacl_Bignum_Modulo_reduce(output);
}

static void
Hacl_Bignum_Fmul_mul_shift_reduce_(
  FStar_UInt128_uint128 *output,
  uint64_t *input,
  uint64_t *input2
)
{
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)2U; i = i + (uint32_t)1U)
  {
    uint64_t input2i = input2[i];
    Hacl_Bignum_Fproduct_sum_scalar_multiplication_(output, input, input2i);
    Hacl_Bignum_Fmul_shift_reduce(input);
  }
  uint32_t i = (uint32_t)2U;
  uint64_t input2i = input2[i];
  Hacl_Bignum_Fproduct_sum_scalar_multiplication_(output, input, input2i);
}

inline static void Hacl_Bignum_Fmul_fmul(uint64_t *output, uint64_t *input, uint64_t *input2)
{
  uint64_t tmp[3U] = { 0U };
  memcpy(tmp, input, (uint32_t)3U * sizeof input[0U]);
  KRML_CHECK_SIZE(sizeof(FStar_UInt128_uint64_to_uint128((uint64_t)0U)), (uint32_t)3U);
  FStar_UInt128_uint128 t[3U];
  for (uint32_t _i = 0U; _i < (uint32_t)3U; ++_i)
    t[_i] = FStar_UInt128_uint64_to_uint128((uint64_t)0U);
  Hacl_Bignum_Fmul_mul_shift_reduce_(t, tmp, input2);
  Hacl_Bignum_Fproduct_carry_wide_(t);
  Hacl_Bignum_Modulo_carry_top_wide(t);
  Hacl_Bignum_Fproduct_copy_from_wide_(output, t);
  uint64_t i0 = output[0U];
  uint64_t i1 = output[1U];
  uint64_t i0_ = i0 & (uint64_t)0xfffffffffffU;
  uint64_t i1_ = i1 + (i0 >> (uint32_t)44U);
  output[0U] = i0_;
  output[1U] = i1_;
}

inline static void
Hacl_Bignum_AddAndMultiply_add_and_multiply(uint64_t *acc, uint64_t *block, uint64_t *r)
{
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)3U; i = i + (uint32_t)1U)
  {
    uint64_t xi = acc[i];
    uint64_t yi = block[i];
    acc[i] = xi + yi;
  }
  Hacl_Bignum_Fmul_fmul(acc, acc, r);
}

typedef struct Hacl_Impl_Poly1305_64_State_poly1305_state_s
{
  uint64_t *r;
  uint64_t *h;
}
Hacl_Impl_Poly1305_64_State_poly1305_state;

extern FStar_UInt128_uint128 load128_le(uint8_t *x0);

extern void store128_le(uint8_t *x0, FStar_UInt128_uint128 x1);

inline static void
Hacl_Impl_Poly1305_64_poly1305_update(
  Hacl_Impl_Poly1305_64_State_poly1305_state st,
  uint8_t *m
)
{
  uint64_t *h = st.h;
  uint64_t *acc = h;
  uint64_t *r = st.r;
  uint64_t *r3 = r;
  uint64_t tmp[3U] = { 0U };
  FStar_UInt128_uint128 m0 = load128_le(m);
  uint64_t r0 = FStar_UInt128_uint128_to_uint64(m0) & (uint64_t)0xfffffffffffU;
  uint64_t
  r1 =
    FStar_UInt128_uint128_to_uint64(FStar_UInt128_shift_right(m0, (uint32_t)44U))
    & (uint64_t)0xfffffffffffU;
  uint64_t r2 = FStar_UInt128_uint128_to_uint64(FStar_UInt128_shift_right(m0, (uint32_t)88U));
  tmp[0U] = r0;
  tmp[1U] = r1;
  tmp[2U] = r2;
  uint64_t b2 = tmp[2U];
  uint64_t b2_ = (uint64_t)0x10000000000U | b2;
  tmp[2U] = b2_;
  Hacl_Bignum_AddAndMultiply_add_and_multiply(acc, tmp, r3);
}

inline static void
Hacl_Impl_Poly1305_64_poly1305_process_last_block_(
  uint8_t *block,
  Hacl_Impl_Poly1305_64_State_poly1305_state st,
  uint8_t *m,
  uint64_t rem_
)
{
  uint64_t tmp[3U] = { 0U };
  FStar_UInt128_uint128 m0 = load128_le(block);
  uint64_t r0 = FStar_UInt128_uint128_to_uint64(m0) & (uint64_t)0xfffffffffffU;
  uint64_t
  r1 =
    FStar_UInt128_uint128_to_uint64(FStar_UInt128_shift_right(m0, (uint32_t)44U))
    & (uint64_t)0xfffffffffffU;
  uint64_t r2 = FStar_UInt128_uint128_to_uint64(FStar_UInt128_shift_right(m0, (uint32_t)88U));
  tmp[0U] = r0;
  tmp[1U] = r1;
  tmp[2U] = r2;
  uint64_t *h = st.h;
  uint64_t *r = st.r;
  Hacl_Bignum_AddAndMultiply_add_and_multiply(h, tmp, r);
}

inline static void
Hacl_Impl_Poly1305_64_poly1305_process_last_block(
  Hacl_Impl_Poly1305_64_State_poly1305_state st,
  uint8_t *m,
  uint64_t rem_
)
{
  uint8_t zero1 = (uint8_t)0U;
  KRML_CHECK_SIZE(sizeof(zero1), (uint32_t)16U);
  uint8_t block[16U];
  for (uint32_t _i = 0U; _i < (uint32_t)16U; ++_i)
    block[_i] = zero1;
  uint32_t i0 = (uint32_t)rem_;
  uint32_t i = (uint32_t)rem_;
  memcpy(block, m, i * sizeof m[0U]);
  block[i0] = (uint8_t)1U;
  Hacl_Impl_Poly1305_64_poly1305_process_last_block_(block, st, m, rem_);
}

static void Hacl_Impl_Poly1305_64_poly1305_last_pass(uint64_t *acc)
{
  Hacl_Bignum_Fproduct_carry_limb_(acc);
  Hacl_Bignum_Modulo_carry_top(acc);
  uint64_t a0 = acc[0U];
  uint64_t a10 = acc[1U];
  uint64_t a20 = acc[2U];
  uint64_t a0_ = a0 & (uint64_t)0xfffffffffffU;
  uint64_t r0 = a0 >> (uint32_t)44U;
  uint64_t a1_ = (a10 + r0) & (uint64_t)0xfffffffffffU;
  uint64_t r1 = (a10 + r0) >> (uint32_t)44U;
  uint64_t a2_ = a20 + r1;
  acc[0U] = a0_;
  acc[1U] = a1_;
  acc[2U] = a2_;
  Hacl_Bignum_Modulo_carry_top(acc);
  uint64_t i0 = acc[0U];
  uint64_t i1 = acc[1U];
  uint64_t i0_ = i0 & (uint64_t)0xfffffffffffU;
  uint64_t i1_ = i1 + (i0 >> (uint32_t)44U);
  acc[0U] = i0_;
  acc[1U] = i1_;
  uint64_t a00 = acc[0U];
  uint64_t a1 = acc[1U];
  uint64_t a2 = acc[2U];
  uint64_t mask0 = FStar_UInt64_gte_mask(a00, (uint64_t)0xffffffffffbU);
  uint64_t mask1 = FStar_UInt64_eq_mask(a1, (uint64_t)0xfffffffffffU);
  uint64_t mask2 = FStar_UInt64_eq_mask(a2, (uint64_t)0x3ffffffffffU);
  uint64_t mask = (mask0 & mask1) & mask2;
  uint64_t a0_0 = a00 - ((uint64_t)0xffffffffffbU & mask);
  uint64_t a1_0 = a1 - ((uint64_t)0xfffffffffffU & mask);
  uint64_t a2_0 = a2 - ((uint64_t)0x3ffffffffffU & mask);
  acc[0U] = a0_0;
  acc[1U] = a1_0;
  acc[2U] = a2_0;
}

static Hacl_Impl_Poly1305_64_State_poly1305_state
Hacl_Impl_Poly1305_64_mk_state(uint64_t *r, uint64_t *h)
{
  return ((Hacl_Impl_Poly1305_64_State_poly1305_state){ .r = r, .h = h });
}

static void
Hacl_Standalone_Poly1305_64_poly1305_blocks(
  Hacl_Impl_Poly1305_64_State_poly1305_state st,
  uint8_t *m,
  uint64_t len1
)
{
  if (!(len1 == (uint64_t)0U))
  {
    uint8_t *block = m;
    uint8_t *tail1 = m + (uint32_t)16U;
    Hacl_Impl_Poly1305_64_poly1305_update(st, block);
    uint64_t len2 = len1 - (uint64_t)1U;
    Hacl_Standalone_Poly1305_64_poly1305_blocks(st, tail1, len2);
  }
}

static void
Hacl_Standalone_Poly1305_64_poly1305_partial(
  Hacl_Impl_Poly1305_64_State_poly1305_state st,
  uint8_t *input,
  uint64_t len1,
  uint8_t *kr
)
{
  uint64_t *r = st.r;
  uint64_t *x0 = r;
  FStar_UInt128_uint128 k1 = load128_le(kr);
  FStar_UInt128_uint128
  hs =
    FStar_UInt128_shift_left(FStar_UInt128_uint64_to_uint128((uint64_t)0x0ffffffc0ffffffcU),
      (uint32_t)64U);
  FStar_UInt128_uint128 ls = FStar_UInt128_uint64_to_uint128((uint64_t)0x0ffffffc0fffffffU);
  FStar_UInt128_uint128 k_clamped = FStar_UInt128_logand(k1, FStar_UInt128_logor(hs, ls));
  uint64_t r0 = FStar_UInt128_uint128_to_uint64(k_clamped) & (uint64_t)0xfffffffffffU;
  uint64_t
  r1 =
    FStar_UInt128_uint128_to_uint64(FStar_UInt128_shift_right(k_clamped, (uint32_t)44U))
    & (uint64_t)0xfffffffffffU;
  uint64_t
  r2 = FStar_UInt128_uint128_to_uint64(FStar_UInt128_shift_right(k_clamped, (uint32_t)88U));
  x0[0U] = r0;
  x0[1U] = r1;
  x0[2U] = r2;
  uint64_t *h = st.h;
  uint64_t *x00 = h;
  x00[0U] = (uint64_t)0U;
  x00[1U] = (uint64_t)0U;
  x00[2U] = (uint64_t)0U;
  Hacl_Standalone_Poly1305_64_poly1305_blocks(st, input, len1);
}

static void
Hacl_Standalone_Poly1305_64_poly1305_complete(
  Hacl_Impl_Poly1305_64_State_poly1305_state st,
  uint8_t *m,
  uint64_t len1,
  uint8_t *k1
)
{
  uint8_t *kr = k1;
  uint64_t len16 = len1 >> (uint32_t)4U;
  uint64_t rem16 = len1 & (uint64_t)0xfU;
  uint8_t *part_input = m;
  uint8_t *last_block = m + (uint32_t)((uint64_t)16U * len16);
  Hacl_Standalone_Poly1305_64_poly1305_partial(st, part_input, len16, kr);
  if (!(rem16 == (uint64_t)0U))
    Hacl_Impl_Poly1305_64_poly1305_process_last_block(st, last_block, rem16);
  uint64_t *h = st.h;
  uint64_t *acc = h;
  Hacl_Impl_Poly1305_64_poly1305_last_pass(acc);
}

static void
Hacl_Standalone_Poly1305_64_crypto_onetimeauth_(
  uint8_t *output,
  uint8_t *input,
  uint64_t len1,
  uint8_t *k1
)
{
  uint64_t buf[6U] = { 0U };
  uint64_t *r = buf;
  uint64_t *h3 = buf + (uint32_t)3U;
  Hacl_Impl_Poly1305_64_State_poly1305_state st = Hacl_Impl_Poly1305_64_mk_state(r, h3);
  uint8_t *key_s = k1 + (uint32_t)16U;
  Hacl_Standalone_Poly1305_64_poly1305_complete(st, input, len1, k1);
  uint64_t *h = st.h;
  uint64_t *acc = h;
  FStar_UInt128_uint128 k_ = load128_le(key_s);
  uint64_t h0 = acc[0U];
  uint64_t h1 = acc[1U];
  uint64_t h2 = acc[2U];
  uint64_t accl = h1 << (uint32_t)44U | h0;
  uint64_t acch = h2 << (uint32_t)24U | h1 >> (uint32_t)20U;
  FStar_UInt128_uint128
  acc_ =
    FStar_UInt128_logor(FStar_UInt128_shift_left(FStar_UInt128_uint64_to_uint128(acch),
        (uint32_t)64U),
      FStar_UInt128_uint64_to_uint128(accl));
  FStar_UInt128_uint128 acc_0 = acc_;
  FStar_UInt128_uint128 mac_ = FStar_UInt128_add_mod(acc_0, k_);
  store128_le(output, mac_);
}

static void
Hacl_Standalone_Poly1305_64_crypto_onetimeauth(
  uint8_t *output,
  uint8_t *input,
  uint64_t len1,
  uint8_t *k1
)
{
  Hacl_Standalone_Poly1305_64_crypto_onetimeauth_(output, input, len1, k1);
}

void
Hacl_Poly1305_64_crypto_onetimeauth(
  uint8_t *output,
  uint8_t *input,
  uint64_t len1,
  uint8_t *k1
)
{
  Hacl_Standalone_Poly1305_64_crypto_onetimeauth(output, input, len1, k1);
}
