/* This file was generated by KreMLin <https://github.com/FStarLang/kremlin>
 * KreMLin invocation: Kremlin.native -tmpdir ./ext -drop FStar,Prims,C,C.*,C.Loops.Spec.Loops,Spec.*,Lib.*,WasmSupport -drop Hacl.Cast,Hacl.UInt8,Hacl.UInt16,Hacl.UInt32,Hacl.UInt64,Hacl.UInt128 -drop Hacl.Spec.Endianness,Hacl.Endianness,Seq.Create -drop Hacl.Impl.SHA2_256.Lemmas,Hacl.Impl.SHA2_384.Lemmas,Hacl.Impl.SHA2_512.Lemmas -drop MerkleTree.Old.High -I ../ ../MerkleTree.Old.Low.fst lib/connect.c lib/Hacl_SHA2_256.c merkle_tree.c
 * F* version: e9fccfb3
 * KreMLin version: b561bc14
 */

#include "kremlib.h"
#ifndef __LowStar_H
#define __LowStar_H




uint32_t LowStar_Vector_new_capacity(uint32_t cap);

void LowStar_BufVector_new_region_();

extern void *LowStar_BufVector_root;

#define __LowStar_H_DEFINED
#endif
