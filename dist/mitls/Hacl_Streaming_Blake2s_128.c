/* MIT License
 *
 * Copyright (c) 2016-2020 INRIA, CMU and Microsoft Corporation
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


#include "Hacl_Streaming_Blake2s_128.h"

/*
  State allocation function when there is no key
*/
Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
*Hacl_Streaming_Blake2s_128_blake2s_128_no_key_create_in()
{
  KRML_CHECK_SIZE(sizeof (uint8_t),
    Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128));
  uint8_t
  *buf =
    KRML_HOST_CALLOC(Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128),
      sizeof (uint8_t));
  Lib_IntVector_Intrinsics_vec128
  *wv = KRML_HOST_MALLOC(sizeof (Lib_IntVector_Intrinsics_vec128) * (uint32_t)4U);
  for (uint32_t _i = 0U; _i < (uint32_t)4U; ++_i)
    wv[_i] = Lib_IntVector_Intrinsics_vec128_zero;
  Lib_IntVector_Intrinsics_vec128
  *b = KRML_HOST_MALLOC(sizeof (Lib_IntVector_Intrinsics_vec128) * (uint32_t)4U);
  for (uint32_t _i = 0U; _i < (uint32_t)4U; ++_i)
    b[_i] = Lib_IntVector_Intrinsics_vec128_zero;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  block_state = { .fst = wv, .snd = b };
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  s = { .block_state = block_state, .buf = buf, .total_len = (uint64_t)0U };
  KRML_CHECK_SIZE(sizeof (
      Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
    ),
    (uint32_t)1U);
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  *p =
    KRML_HOST_MALLOC(sizeof (
        Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
      ));
  p[0U] = s;
  Hacl_Blake2s_128_blake2s_init(block_state.fst,
    block_state.snd,
    (uint32_t)0U,
    NULL,
    (uint32_t)32U);
  return p;
}

/*
  (Re-)initialization function when there is no key
*/
void
Hacl_Streaming_Blake2s_128_blake2s_128_no_key_init(
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  *s
)
{
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  scrut = *s;
  uint8_t *buf = scrut.buf;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  block_state = scrut.block_state;
  Hacl_Blake2s_128_blake2s_init(block_state.fst,
    block_state.snd,
    (uint32_t)0U,
    NULL,
    (uint32_t)32U);
  s[0U] =
    (
      (Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____){
        .block_state = block_state,
        .buf = buf,
        .total_len = (uint64_t)0U
      }
    );
}

/*
  Update function when there is no key
*/
void
Hacl_Streaming_Blake2s_128_blake2s_128_no_key_update(
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  *p,
  uint8_t *data,
  uint32_t len
)
{
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  s = *p;
  uint64_t total_len = s.total_len;
  uint32_t sz;
  if
  (
    total_len
    %
      (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128)
    == (uint64_t)0U
    && total_len > (uint64_t)0U
  )
  {
    sz = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  }
  else
  {
    sz =
      (uint32_t)(total_len
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128));
  }
  if
  (
    len
    <= Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128) - sz
  )
  {
    Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
    s1 = *p;
    K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
    block_state1 = s1.block_state;
    uint8_t *buf = s1.buf;
    uint64_t total_len1 = s1.total_len;
    uint32_t sz1;
    if
    (
      total_len1
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128)
      == (uint64_t)0U
      && total_len1 > (uint64_t)0U
    )
    {
      sz1 = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
    }
    else
    {
      sz1 =
        (uint32_t)(total_len1
        %
          (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
            Hacl_Impl_Blake2_Core_M128));
    }
    uint8_t *buf2 = buf + sz1;
    memcpy(buf2, data, len * sizeof (uint8_t));
    uint64_t total_len2 = total_len1 + (uint64_t)len;
    *p
    =
      (
        (Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____){
          .block_state = block_state1,
          .buf = buf,
          .total_len = total_len2
        }
      );
    return;
  }
  if (sz == (uint32_t)0U)
  {
    Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
    s1 = *p;
    K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
    block_state1 = s1.block_state;
    uint8_t *buf = s1.buf;
    uint64_t total_len1 = s1.total_len;
    uint32_t sz1;
    if
    (
      total_len1
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128)
      == (uint64_t)0U
      && total_len1 > (uint64_t)0U
    )
    {
      sz1 = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
    }
    else
    {
      sz1 =
        (uint32_t)(total_len1
        %
          (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
            Hacl_Impl_Blake2_Core_M128));
    }
    if (!(sz1 == (uint32_t)0U))
    {
      uint64_t prevlen = total_len1 - (uint64_t)sz1;
      uint32_t
      nb =
        Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128)
        / (uint32_t)64U;
      uint64_t ite;
      if ((uint32_t)0U == (uint32_t)0U)
      {
        ite = prevlen;
      }
      else
      {
        ite = prevlen + (uint64_t)(uint32_t)64U;
      }
      Hacl_Blake2s_128_blake2s_update_multi(Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128),
        block_state1.fst,
        block_state1.snd,
        ite,
        buf,
        nb);
    }
    uint32_t ite0;
    if
    (
      (uint64_t)len
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128)
      == (uint64_t)0U
      && (uint64_t)len > (uint64_t)0U
    )
    {
      ite0 = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
    }
    else
    {
      ite0 =
        (uint32_t)((uint64_t)len
        %
          (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
            Hacl_Impl_Blake2_Core_M128));
    }
    uint32_t
    n_blocks =
      (len - ite0)
      / Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
    uint32_t
    data1_len =
      n_blocks
      * Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
    uint32_t data2_len = len - data1_len;
    uint8_t *data1 = data;
    uint8_t *data2 = data + data1_len;
    uint32_t nb = data1_len / (uint32_t)64U;
    uint64_t ite;
    if ((uint32_t)0U == (uint32_t)0U)
    {
      ite = total_len1;
    }
    else
    {
      ite = total_len1 + (uint64_t)(uint32_t)64U;
    }
    Hacl_Blake2s_128_blake2s_update_multi(data1_len,
      block_state1.fst,
      block_state1.snd,
      ite,
      data1,
      nb);
    uint8_t *dst = buf;
    memcpy(dst, data2, data2_len * sizeof (uint8_t));
    *p
    =
      (
        (Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____){
          .block_state = block_state1,
          .buf = buf,
          .total_len = total_len1 + (uint64_t)len
        }
      );
    return;
  }
  uint32_t
  diff =
    Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
      Hacl_Impl_Blake2_Core_M128)
    - sz;
  uint8_t *data1 = data;
  uint8_t *data2 = data + diff;
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  s1 = *p;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  block_state10 = s1.block_state;
  uint8_t *buf0 = s1.buf;
  uint64_t total_len10 = s1.total_len;
  uint32_t sz10;
  if
  (
    total_len10
    %
      (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128)
    == (uint64_t)0U
    && total_len10 > (uint64_t)0U
  )
  {
    sz10 = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  }
  else
  {
    sz10 =
      (uint32_t)(total_len10
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128));
  }
  uint8_t *buf2 = buf0 + sz10;
  memcpy(buf2, data1, diff * sizeof (uint8_t));
  uint64_t total_len2 = total_len10 + (uint64_t)diff;
  *p
  =
    (
      (Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____){
        .block_state = block_state10,
        .buf = buf0,
        .total_len = total_len2
      }
    );
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  s10 = *p;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  block_state1 = s10.block_state;
  uint8_t *buf = s10.buf;
  uint64_t total_len1 = s10.total_len;
  uint32_t sz1;
  if
  (
    total_len1
    %
      (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128)
    == (uint64_t)0U
    && total_len1 > (uint64_t)0U
  )
  {
    sz1 = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  }
  else
  {
    sz1 =
      (uint32_t)(total_len1
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128));
  }
  if (!(sz1 == (uint32_t)0U))
  {
    uint64_t prevlen = total_len1 - (uint64_t)sz1;
    uint32_t
    nb =
      Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128)
      / (uint32_t)64U;
    uint64_t ite;
    if ((uint32_t)0U == (uint32_t)0U)
    {
      ite = prevlen;
    }
    else
    {
      ite = prevlen + (uint64_t)(uint32_t)64U;
    }
    Hacl_Blake2s_128_blake2s_update_multi(Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128),
      block_state1.fst,
      block_state1.snd,
      ite,
      buf,
      nb);
  }
  uint32_t ite0;
  if
  (
    (uint64_t)(len - diff)
    %
      (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128)
    == (uint64_t)0U
    && (uint64_t)(len - diff) > (uint64_t)0U
  )
  {
    ite0 = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  }
  else
  {
    ite0 =
      (uint32_t)((uint64_t)(len - diff)
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128));
  }
  uint32_t
  n_blocks =
    (len - diff - ite0)
    / Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  uint32_t
  data1_len =
    n_blocks
    * Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  uint32_t data2_len = len - diff - data1_len;
  uint8_t *data11 = data2;
  uint8_t *data21 = data2 + data1_len;
  uint32_t nb = data1_len / (uint32_t)64U;
  uint64_t ite;
  if ((uint32_t)0U == (uint32_t)0U)
  {
    ite = total_len1;
  }
  else
  {
    ite = total_len1 + (uint64_t)(uint32_t)64U;
  }
  Hacl_Blake2s_128_blake2s_update_multi(data1_len,
    block_state1.fst,
    block_state1.snd,
    ite,
    data11,
    nb);
  uint8_t *dst = buf;
  memcpy(dst, data21, data2_len * sizeof (uint8_t));
  *p
  =
    (
      (Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____){
        .block_state = block_state1,
        .buf = buf,
        .total_len = total_len1 + (uint64_t)(len - diff)
      }
    );
}

/*
  Finish function when there is no key
*/
void
Hacl_Streaming_Blake2s_128_blake2s_128_no_key_finish(
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  *p,
  uint8_t *dst
)
{
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  scrut = *p;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  block_state = scrut.block_state;
  uint8_t *buf_ = scrut.buf;
  uint64_t total_len = scrut.total_len;
  uint32_t r;
  if
  (
    total_len
    %
      (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128)
    == (uint64_t)0U
    && total_len > (uint64_t)0U
  )
  {
    r = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  }
  else
  {
    r =
      (uint32_t)(total_len
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128));
  }
  uint8_t *buf_1 = buf_;
  KRML_CHECK_SIZE(sizeof (Lib_IntVector_Intrinsics_vec128), (uint32_t)4U * (uint32_t)1U);
  Lib_IntVector_Intrinsics_vec128
  *wv = alloca((uint32_t)4U * (uint32_t)1U * sizeof (Lib_IntVector_Intrinsics_vec128));
  for (uint32_t _i = 0U; _i < (uint32_t)4U * (uint32_t)1U; ++_i)
    wv[_i] = Lib_IntVector_Intrinsics_vec128_zero;
  KRML_CHECK_SIZE(sizeof (Lib_IntVector_Intrinsics_vec128), (uint32_t)4U * (uint32_t)1U);
  Lib_IntVector_Intrinsics_vec128
  *b = alloca((uint32_t)4U * (uint32_t)1U * sizeof (Lib_IntVector_Intrinsics_vec128));
  for (uint32_t _i = 0U; _i < (uint32_t)4U * (uint32_t)1U; ++_i)
    b[_i] = Lib_IntVector_Intrinsics_vec128_zero;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  tmp_block_state = { .fst = wv, .snd = b };
  Lib_IntVector_Intrinsics_vec128 *src_b = block_state.snd;
  Lib_IntVector_Intrinsics_vec128 *dst_b = tmp_block_state.snd;
  memcpy(dst_b, src_b, (uint32_t)4U * sizeof (Lib_IntVector_Intrinsics_vec128));
  uint64_t prev_len = total_len - (uint64_t)r;
  uint32_t ite0;
  if (r % (uint32_t)64U == (uint32_t)0U && r > (uint32_t)0U)
  {
    ite0 = (uint32_t)64U;
  }
  else
  {
    ite0 = r % (uint32_t)64U;
  }
  uint8_t *buf_last = buf_1 + r - ite0;
  uint8_t *buf_multi = buf_1;
  uint32_t ite1;
  if
  (
    (uint32_t)64U
    == Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128)
  )
  {
    ite1 = (uint32_t)0U;
  }
  else
  {
    uint32_t ite;
    if (r % (uint32_t)64U == (uint32_t)0U && r > (uint32_t)0U)
    {
      ite = (uint32_t)64U;
    }
    else
    {
      ite = r % (uint32_t)64U;
    }
    ite1 = r - ite;
  }
  uint32_t nb = ite1 / (uint32_t)64U;
  uint32_t ite2;
  if
  (
    (uint32_t)64U
    == Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128)
  )
  {
    ite2 = (uint32_t)0U;
  }
  else
  {
    uint32_t ite;
    if (r % (uint32_t)64U == (uint32_t)0U && r > (uint32_t)0U)
    {
      ite = (uint32_t)64U;
    }
    else
    {
      ite = r % (uint32_t)64U;
    }
    ite2 = r - ite;
  }
  uint64_t ite3;
  if ((uint32_t)0U == (uint32_t)0U)
  {
    ite3 = prev_len;
  }
  else
  {
    ite3 = prev_len + (uint64_t)(uint32_t)64U;
  }
  Hacl_Blake2s_128_blake2s_update_multi(ite2,
    tmp_block_state.fst,
    tmp_block_state.snd,
    ite3,
    buf_multi,
    nb);
  uint32_t ite4;
  if
  (
    (uint32_t)64U
    == Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128)
  )
  {
    ite4 = r;
  }
  else if (r % (uint32_t)64U == (uint32_t)0U && r > (uint32_t)0U)
  {
    ite4 = (uint32_t)64U;
  }
  else
  {
    ite4 = r % (uint32_t)64U;
  }
  uint64_t prev_len_last = total_len - (uint64_t)ite4;
  uint32_t ite5;
  if
  (
    (uint32_t)64U
    == Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128)
  )
  {
    ite5 = r;
  }
  else if (r % (uint32_t)64U == (uint32_t)0U && r > (uint32_t)0U)
  {
    ite5 = (uint32_t)64U;
  }
  else
  {
    ite5 = r % (uint32_t)64U;
  }
  uint64_t ite6;
  if ((uint32_t)0U == (uint32_t)0U)
  {
    ite6 = prev_len_last;
  }
  else
  {
    ite6 = prev_len_last + (uint64_t)(uint32_t)64U;
  }
  uint32_t ite;
  if
  (
    (uint32_t)64U
    == Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128)
  )
  {
    ite = r;
  }
  else if (r % (uint32_t)64U == (uint32_t)0U && r > (uint32_t)0U)
  {
    ite = (uint32_t)64U;
  }
  else
  {
    ite = r % (uint32_t)64U;
  }
  Hacl_Blake2s_128_blake2s_update_last(ite5,
    tmp_block_state.fst,
    tmp_block_state.snd,
    ite6,
    ite,
    buf_last);
  Hacl_Blake2s_128_blake2s_finish((uint32_t)32U, dst, tmp_block_state.snd);
}

/*
  Free state function when there is no key
*/
void
Hacl_Streaming_Blake2s_128_blake2s_128_no_key_free(
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  *s
)
{
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  scrut = *s;
  uint8_t *buf = scrut.buf;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  block_state = scrut.block_state;
  Lib_IntVector_Intrinsics_vec128 *wv = block_state.fst;
  Lib_IntVector_Intrinsics_vec128 *b = block_state.snd;
  KRML_HOST_FREE(wv);
  KRML_HOST_FREE(b);
  KRML_HOST_FREE(buf);
  KRML_HOST_FREE(s);
}

/*
  State allocation function when using a (potentially null) key
*/
Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
*Hacl_Streaming_Blake2s_128_blake2s_128_with_key_create_in(uint32_t key_size, uint8_t *k)
{
  KRML_CHECK_SIZE(sizeof (uint8_t),
    Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128));
  uint8_t
  *buf =
    KRML_HOST_CALLOC(Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128),
      sizeof (uint8_t));
  Lib_IntVector_Intrinsics_vec128
  *wv = KRML_HOST_MALLOC(sizeof (Lib_IntVector_Intrinsics_vec128) * (uint32_t)4U);
  for (uint32_t _i = 0U; _i < (uint32_t)4U; ++_i)
    wv[_i] = Lib_IntVector_Intrinsics_vec128_zero;
  Lib_IntVector_Intrinsics_vec128
  *b = KRML_HOST_MALLOC(sizeof (Lib_IntVector_Intrinsics_vec128) * (uint32_t)4U);
  for (uint32_t _i = 0U; _i < (uint32_t)4U; ++_i)
    b[_i] = Lib_IntVector_Intrinsics_vec128_zero;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  block_state = { .fst = wv, .snd = b };
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  s = { .block_state = block_state, .buf = buf, .total_len = (uint64_t)0U };
  KRML_CHECK_SIZE(sizeof (
      Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
    ),
    (uint32_t)1U);
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  *p =
    KRML_HOST_MALLOC(sizeof (
        Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
      ));
  p[0U] = s;
  Hacl_Blake2s_128_blake2s_init(block_state.fst, block_state.snd, key_size, k, (uint32_t)32U);
  return p;
}

/*
  (Re-)initialization function when using a (potentially null) key
*/
void
Hacl_Streaming_Blake2s_128_blake2s_128_with_key_init(
  uint32_t key_size,
  uint8_t *k,
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  *s
)
{
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  scrut = *s;
  uint8_t *buf = scrut.buf;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  block_state = scrut.block_state;
  Hacl_Blake2s_128_blake2s_init(block_state.fst, block_state.snd, key_size, k, (uint32_t)32U);
  s[0U] =
    (
      (Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____){
        .block_state = block_state,
        .buf = buf,
        .total_len = (uint64_t)0U
      }
    );
}

/*
  Update function when using a (potentially null) key
*/
void
Hacl_Streaming_Blake2s_128_blake2s_128_with_key_update(
  uint32_t key_size,
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  *p,
  uint8_t *data,
  uint32_t len
)
{
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  s = *p;
  uint64_t total_len = s.total_len;
  uint32_t sz;
  if
  (
    total_len
    %
      (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128)
    == (uint64_t)0U
    && total_len > (uint64_t)0U
  )
  {
    sz = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  }
  else
  {
    sz =
      (uint32_t)(total_len
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128));
  }
  if
  (
    len
    <= Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128) - sz
  )
  {
    Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
    s1 = *p;
    K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
    block_state1 = s1.block_state;
    uint8_t *buf = s1.buf;
    uint64_t total_len1 = s1.total_len;
    uint32_t sz1;
    if
    (
      total_len1
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128)
      == (uint64_t)0U
      && total_len1 > (uint64_t)0U
    )
    {
      sz1 = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
    }
    else
    {
      sz1 =
        (uint32_t)(total_len1
        %
          (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
            Hacl_Impl_Blake2_Core_M128));
    }
    uint8_t *buf2 = buf + sz1;
    memcpy(buf2, data, len * sizeof (uint8_t));
    uint64_t total_len2 = total_len1 + (uint64_t)len;
    *p
    =
      (
        (Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____){
          .block_state = block_state1,
          .buf = buf,
          .total_len = total_len2
        }
      );
    return;
  }
  if (sz == (uint32_t)0U)
  {
    Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
    s1 = *p;
    K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
    block_state1 = s1.block_state;
    uint8_t *buf = s1.buf;
    uint64_t total_len1 = s1.total_len;
    uint32_t sz1;
    if
    (
      total_len1
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128)
      == (uint64_t)0U
      && total_len1 > (uint64_t)0U
    )
    {
      sz1 = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
    }
    else
    {
      sz1 =
        (uint32_t)(total_len1
        %
          (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
            Hacl_Impl_Blake2_Core_M128));
    }
    if (!(sz1 == (uint32_t)0U))
    {
      uint64_t prevlen = total_len1 - (uint64_t)sz1;
      uint32_t
      nb =
        Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128)
        / (uint32_t)64U;
      uint64_t ite;
      if (key_size == (uint32_t)0U)
      {
        ite = prevlen;
      }
      else
      {
        ite = prevlen + (uint64_t)(uint32_t)64U;
      }
      Hacl_Blake2s_128_blake2s_update_multi(Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128),
        block_state1.fst,
        block_state1.snd,
        ite,
        buf,
        nb);
    }
    uint32_t ite0;
    if
    (
      (uint64_t)len
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128)
      == (uint64_t)0U
      && (uint64_t)len > (uint64_t)0U
    )
    {
      ite0 = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
    }
    else
    {
      ite0 =
        (uint32_t)((uint64_t)len
        %
          (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
            Hacl_Impl_Blake2_Core_M128));
    }
    uint32_t
    n_blocks =
      (len - ite0)
      / Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
    uint32_t
    data1_len =
      n_blocks
      * Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
    uint32_t data2_len = len - data1_len;
    uint8_t *data1 = data;
    uint8_t *data2 = data + data1_len;
    uint32_t nb = data1_len / (uint32_t)64U;
    uint64_t ite;
    if (key_size == (uint32_t)0U)
    {
      ite = total_len1;
    }
    else
    {
      ite = total_len1 + (uint64_t)(uint32_t)64U;
    }
    Hacl_Blake2s_128_blake2s_update_multi(data1_len,
      block_state1.fst,
      block_state1.snd,
      ite,
      data1,
      nb);
    uint8_t *dst = buf;
    memcpy(dst, data2, data2_len * sizeof (uint8_t));
    *p
    =
      (
        (Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____){
          .block_state = block_state1,
          .buf = buf,
          .total_len = total_len1 + (uint64_t)len
        }
      );
    return;
  }
  uint32_t
  diff =
    Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
      Hacl_Impl_Blake2_Core_M128)
    - sz;
  uint8_t *data1 = data;
  uint8_t *data2 = data + diff;
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  s1 = *p;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  block_state10 = s1.block_state;
  uint8_t *buf0 = s1.buf;
  uint64_t total_len10 = s1.total_len;
  uint32_t sz10;
  if
  (
    total_len10
    %
      (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128)
    == (uint64_t)0U
    && total_len10 > (uint64_t)0U
  )
  {
    sz10 = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  }
  else
  {
    sz10 =
      (uint32_t)(total_len10
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128));
  }
  uint8_t *buf2 = buf0 + sz10;
  memcpy(buf2, data1, diff * sizeof (uint8_t));
  uint64_t total_len2 = total_len10 + (uint64_t)diff;
  *p
  =
    (
      (Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____){
        .block_state = block_state10,
        .buf = buf0,
        .total_len = total_len2
      }
    );
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  s10 = *p;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  block_state1 = s10.block_state;
  uint8_t *buf = s10.buf;
  uint64_t total_len1 = s10.total_len;
  uint32_t sz1;
  if
  (
    total_len1
    %
      (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128)
    == (uint64_t)0U
    && total_len1 > (uint64_t)0U
  )
  {
    sz1 = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  }
  else
  {
    sz1 =
      (uint32_t)(total_len1
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128));
  }
  if (!(sz1 == (uint32_t)0U))
  {
    uint64_t prevlen = total_len1 - (uint64_t)sz1;
    uint32_t
    nb =
      Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128)
      / (uint32_t)64U;
    uint64_t ite;
    if (key_size == (uint32_t)0U)
    {
      ite = prevlen;
    }
    else
    {
      ite = prevlen + (uint64_t)(uint32_t)64U;
    }
    Hacl_Blake2s_128_blake2s_update_multi(Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128),
      block_state1.fst,
      block_state1.snd,
      ite,
      buf,
      nb);
  }
  uint32_t ite0;
  if
  (
    (uint64_t)(len - diff)
    %
      (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128)
    == (uint64_t)0U
    && (uint64_t)(len - diff) > (uint64_t)0U
  )
  {
    ite0 = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  }
  else
  {
    ite0 =
      (uint32_t)((uint64_t)(len - diff)
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128));
  }
  uint32_t
  n_blocks =
    (len - diff - ite0)
    / Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  uint32_t
  data1_len =
    n_blocks
    * Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  uint32_t data2_len = len - diff - data1_len;
  uint8_t *data11 = data2;
  uint8_t *data21 = data2 + data1_len;
  uint32_t nb = data1_len / (uint32_t)64U;
  uint64_t ite;
  if (key_size == (uint32_t)0U)
  {
    ite = total_len1;
  }
  else
  {
    ite = total_len1 + (uint64_t)(uint32_t)64U;
  }
  Hacl_Blake2s_128_blake2s_update_multi(data1_len,
    block_state1.fst,
    block_state1.snd,
    ite,
    data11,
    nb);
  uint8_t *dst = buf;
  memcpy(dst, data21, data2_len * sizeof (uint8_t));
  *p
  =
    (
      (Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____){
        .block_state = block_state1,
        .buf = buf,
        .total_len = total_len1 + (uint64_t)(len - diff)
      }
    );
}

/*
  Finish function when using a (potentially null) key
*/
void
Hacl_Streaming_Blake2s_128_blake2s_128_with_key_finish(
  uint32_t key_size,
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  *p,
  uint8_t *dst
)
{
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  scrut = *p;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  block_state = scrut.block_state;
  uint8_t *buf_ = scrut.buf;
  uint64_t total_len = scrut.total_len;
  uint32_t r;
  if
  (
    total_len
    %
      (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
        Hacl_Impl_Blake2_Core_M128)
    == (uint64_t)0U
    && total_len > (uint64_t)0U
  )
  {
    r = Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128);
  }
  else
  {
    r =
      (uint32_t)(total_len
      %
        (uint64_t)Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S,
          Hacl_Impl_Blake2_Core_M128));
  }
  uint8_t *buf_1 = buf_;
  KRML_CHECK_SIZE(sizeof (Lib_IntVector_Intrinsics_vec128), (uint32_t)4U * (uint32_t)1U);
  Lib_IntVector_Intrinsics_vec128
  *wv = alloca((uint32_t)4U * (uint32_t)1U * sizeof (Lib_IntVector_Intrinsics_vec128));
  for (uint32_t _i = 0U; _i < (uint32_t)4U * (uint32_t)1U; ++_i)
    wv[_i] = Lib_IntVector_Intrinsics_vec128_zero;
  KRML_CHECK_SIZE(sizeof (Lib_IntVector_Intrinsics_vec128), (uint32_t)4U * (uint32_t)1U);
  Lib_IntVector_Intrinsics_vec128
  *b = alloca((uint32_t)4U * (uint32_t)1U * sizeof (Lib_IntVector_Intrinsics_vec128));
  for (uint32_t _i = 0U; _i < (uint32_t)4U * (uint32_t)1U; ++_i)
    b[_i] = Lib_IntVector_Intrinsics_vec128_zero;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  tmp_block_state = { .fst = wv, .snd = b };
  Lib_IntVector_Intrinsics_vec128 *src_b = block_state.snd;
  Lib_IntVector_Intrinsics_vec128 *dst_b = tmp_block_state.snd;
  memcpy(dst_b, src_b, (uint32_t)4U * sizeof (Lib_IntVector_Intrinsics_vec128));
  uint64_t prev_len = total_len - (uint64_t)r;
  uint32_t ite0;
  if (r % (uint32_t)64U == (uint32_t)0U && r > (uint32_t)0U)
  {
    ite0 = (uint32_t)64U;
  }
  else
  {
    ite0 = r % (uint32_t)64U;
  }
  uint8_t *buf_last = buf_1 + r - ite0;
  uint8_t *buf_multi = buf_1;
  uint32_t ite1;
  if
  (
    (uint32_t)64U
    == Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128)
  )
  {
    ite1 = (uint32_t)0U;
  }
  else
  {
    uint32_t ite;
    if (r % (uint32_t)64U == (uint32_t)0U && r > (uint32_t)0U)
    {
      ite = (uint32_t)64U;
    }
    else
    {
      ite = r % (uint32_t)64U;
    }
    ite1 = r - ite;
  }
  uint32_t nb = ite1 / (uint32_t)64U;
  uint32_t ite2;
  if
  (
    (uint32_t)64U
    == Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128)
  )
  {
    ite2 = (uint32_t)0U;
  }
  else
  {
    uint32_t ite;
    if (r % (uint32_t)64U == (uint32_t)0U && r > (uint32_t)0U)
    {
      ite = (uint32_t)64U;
    }
    else
    {
      ite = r % (uint32_t)64U;
    }
    ite2 = r - ite;
  }
  uint64_t ite3;
  if (key_size == (uint32_t)0U)
  {
    ite3 = prev_len;
  }
  else
  {
    ite3 = prev_len + (uint64_t)(uint32_t)64U;
  }
  Hacl_Blake2s_128_blake2s_update_multi(ite2,
    tmp_block_state.fst,
    tmp_block_state.snd,
    ite3,
    buf_multi,
    nb);
  uint32_t ite4;
  if
  (
    (uint32_t)64U
    == Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128)
  )
  {
    ite4 = r;
  }
  else if (r % (uint32_t)64U == (uint32_t)0U && r > (uint32_t)0U)
  {
    ite4 = (uint32_t)64U;
  }
  else
  {
    ite4 = r % (uint32_t)64U;
  }
  uint64_t prev_len_last = total_len - (uint64_t)ite4;
  uint32_t ite5;
  if
  (
    (uint32_t)64U
    == Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128)
  )
  {
    ite5 = r;
  }
  else if (r % (uint32_t)64U == (uint32_t)0U && r > (uint32_t)0U)
  {
    ite5 = (uint32_t)64U;
  }
  else
  {
    ite5 = r % (uint32_t)64U;
  }
  uint64_t ite6;
  if (key_size == (uint32_t)0U)
  {
    ite6 = prev_len_last;
  }
  else
  {
    ite6 = prev_len_last + (uint64_t)(uint32_t)64U;
  }
  uint32_t ite;
  if
  (
    (uint32_t)64U
    == Hacl_Streaming_Blake2_blocks_state_len(Spec_Blake2_Blake2S, Hacl_Impl_Blake2_Core_M128)
  )
  {
    ite = r;
  }
  else if (r % (uint32_t)64U == (uint32_t)0U && r > (uint32_t)0U)
  {
    ite = (uint32_t)64U;
  }
  else
  {
    ite = r % (uint32_t)64U;
  }
  Hacl_Blake2s_128_blake2s_update_last(ite5,
    tmp_block_state.fst,
    tmp_block_state.snd,
    ite6,
    ite,
    buf_last);
  Hacl_Blake2s_128_blake2s_finish((uint32_t)32U, dst, tmp_block_state.snd);
}

/*
  Free state function when using a (potentially null) key
*/
void
Hacl_Streaming_Blake2s_128_blake2s_128_with_key_free(
  uint32_t key_size,
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  *s
)
{
  Hacl_Streaming_Functor_state_s__K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128____
  scrut = *s;
  uint8_t *buf = scrut.buf;
  K____Lib_IntVector_Intrinsics_vec128___Lib_IntVector_Intrinsics_vec128_
  block_state = scrut.block_state;
  Lib_IntVector_Intrinsics_vec128 *wv = block_state.fst;
  Lib_IntVector_Intrinsics_vec128 *b = block_state.snd;
  KRML_HOST_FREE(wv);
  KRML_HOST_FREE(b);
  KRML_HOST_FREE(buf);
  KRML_HOST_FREE(s);
}

