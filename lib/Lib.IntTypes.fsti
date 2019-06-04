module Lib.IntTypes

open FStar.Mul
open FStar.Math.Lemmas

///
/// Definition of machine integer base types
///

type inttype =
  | U1 | U8 | U16 | U32 | U64 | U128 | S8 | S16 | S32 | S64
///
/// Operations on the underlying machine integer base types
///

inline_for_extraction
let bits (n:inttype) =
  match n with
  | U1 -> 1
  | U8 -> 8
  | S8 -> 8
  | U16 -> 16
  | S16 -> 16
  | U32 -> 32
  | S32 -> 32
  | U64 -> 64
  | S64 -> 64
  | U128 -> 128
  //| S128 -> 128

inline_for_extraction
let range (x:int) (n:inttype) : Type0 =
  match n with
  | U1 | U8 | U16 | U32 | U64 | U128 -> UInt.size x (bits n)
  | S8 | S16 | S32 | S64 -> Int.size x (bits n)

inline_for_extraction
type range_t (n:inttype) = x:int{range x n}

inline_for_extraction
let numbytes (n:inttype) =
  match n with
  | U1 -> 1
  | U8 -> 1
  | S8 -> 1
  | U16 -> 2
  | S16 -> 2
  | U32 -> 4
  | S32 -> 4
  | U64 -> 8
  | S64 -> 8
  | U128 -> 16
  //| S128 -> 16

val pow2_values: n:nat ->  Lemma (
    pow2 0 == 1 /\
    pow2 1 == 2 /\
    pow2 2 == 4 /\
    pow2 3 == 8 /\
    pow2 4 == 16 /\
    pow2 8 == 0x100 /\
    pow2 16 == 0x10000 /\
    pow2 32 == 0x100000000 /\
    pow2 64 == 0x10000000000000000 /\
    pow2 128 == 0x100000000000000000000000000000000
    )
    [SMTPat (pow2 n)]

inline_for_extraction
unfold let modulus (t:inttype) = pow2 (bits t)

inline_for_extraction
unfold let maxint (t:inttype) =
  match t with
  | U1 | U8 | U16 | U32 | U64 | U128 -> UInt.max_int (bits t)
  | S8 | S16 | S32 | S64 -> Int.max_int (bits t)
  
inline_for_extraction
unfold let minint (t:inttype) =
  match t with
  | U1 | U8 | U16 | U32 | U64 | U128 -> UInt.min_int (bits t)
  | S8 | S16 | S32 | S64 -> Int.min_int (bits t)
  
(* PUBLIC Machine Integers *)

inline_for_extraction
let pub_int_t (t:inttype) =
  match t with
  | U1 -> u:UInt8.t{UInt8.v u < 2}
  | U8 -> UInt8.t
  | U16 -> UInt16.t
  | U32 -> UInt32.t
  | U64 -> UInt64.t
  | U128 -> UInt128.t
  | S8 -> Int8.t
  | S16 -> Int16.t
  | S32 -> Int32.t
  | S64 -> Int64.t
  //| S128 -> Int128.t

inline_for_extraction
let pub_int_v #t (x:pub_int_t t) : (n:range_t t) =
  match t with
  | U1 -> UInt8.v x
  | U8 -> UInt8.v x
  | U16 -> UInt16.v x
  | U32 -> UInt32.v x
  | U64 -> UInt64.v x
  | U128 -> UInt128.v x
  | S8 -> Int8.v x
  | S16 -> Int16.v x
  | S32 -> Int32.v x
  | S64 -> Int64.v x
  //| S128 -> Int128.v x

(* SECRET Machine Integers *)

type secrecy_level =
  | SEC
  | PUB

inline_for_extraction
val sec_int_t: t:inttype -> Type0

inline_for_extraction
val sec_int_v: #t:inttype -> u:sec_int_t t -> n:range_t t

(* GENERIC (unsigned) Machine Integers *)

inline_for_extraction
let uint_t (t:inttype) (l:secrecy_level) =
  match l with
  | PUB -> pub_int_t t
  | SEC -> sec_int_t t

let uint_v #t #l (u:uint_t t l) : n:range_t t =
  match l with
  | PUB -> pub_int_v #t u
  | SEC -> sec_int_v #t u

val uintv_extensionality:
   #t:inttype
 -> #l:secrecy_level
 -> a:uint_t t l
 -> b:uint_t t l
 -> Lemma
  (requires uint_v #t #l a == uint_v #t #l b)
  (ensures  a == b)

///
/// Definition of machine integers
///

inline_for_extraction
type uint1 = uint_t U1 SEC

inline_for_extraction
type uint8 = uint_t U8 SEC

inline_for_extraction
type int8 = uint_t S8 SEC

inline_for_extraction
type uint16 = uint_t U16 SEC

inline_for_extraction
type int16 = uint_t S16 SEC

inline_for_extraction
type uint32 = uint_t U32 SEC

inline_for_extraction
type int32 = uint_t S32 SEC

inline_for_extraction
type uint64 = uint_t U64 SEC

inline_for_extraction
type int64 = uint_t S64 SEC

inline_for_extraction
type uint128 = uint_t U128 SEC

//inline_for_extraction
//type int128 = uint_t S128 SEC

inline_for_extraction
unfold type bit_t = uint_t U1 PUB

inline_for_extraction
unfold type byte_t = uint_t U8 PUB

inline_for_extraction
unfold type size_t = uint_t U32 PUB

inline_for_extraction
unfold type pub_int8 = uint_t S8 PUB

inline_for_extraction
unfold type pub_uint16 = uint_t U16 PUB

inline_for_extraction
unfold type pub_int16 = uint_t S16 PUB

inline_for_extraction
unfold type pub_uint32 = uint_t U32 PUB

inline_for_extraction
unfold type pub_int32 = uint_t S32 PUB

inline_for_extraction
unfold type pub_uint64 = uint_t U64 PUB

inline_for_extraction
unfold type pub_int64 = uint_t S64 PUB

inline_for_extraction
unfold type pub_uint128 = uint_t U128 PUB

//inline_for_extraction
//unfold type pub_int128 = uint_t S128 PUB
///
/// Casts between natural numbers and machine integers
///

inline_for_extraction
val secret: #t:inttype -> u:uint_t t PUB -> v:uint_t t SEC{uint_v v == uint_v u}

inline_for_extraction
val uint: #t:inttype -> #l:secrecy_level -> (n:range_t t) -> u:uint_t t l{uint_v u == n}

val uintv_injective:
   #t:inttype
 -> #l:secrecy_level
 -> a:uint_t t l
 -> Lemma (ensures uint (uint_v #t #l a) == a)
 [SMTPat (uint_v #t #l a)]

inline_for_extraction
let u1 (n:range_t U1) : u:uint1{uint_v #U1 u == n} = uint #U1 #SEC n

inline_for_extraction
let u8 (n:range_t U8) : u:uint8{uint_v #U8 u == n} = uint #U8 #SEC n

inline_for_extraction
let i8 (n:range_t S8) : u:int8{uint_v #S8 u == n} = uint #S8 #SEC n

inline_for_extraction
let u16 (n:range_t U16) : u:uint16{uint_v #U16 u == n} = uint #U16 #SEC n

inline_for_extraction
let i16 (n:range_t S16) : u:int16{uint_v #S16 u == n} = uint #S16 #SEC n

inline_for_extraction
let u32 (n:range_t U32) : u:uint32{uint_v #U32 u == n} = uint #U32 #SEC n

inline_for_extraction
let i32 (n:range_t S32) : u:int32{uint_v #S32 u == n} = uint #S32 #SEC n

inline_for_extraction
let u64 (n:range_t U64) : u:uint64{uint_v #U64 u == n} = uint #U64 #SEC n

inline_for_extraction
let i64 (n:range_t S64) : u:int64{uint_v #S64 u == n} = uint #S64 #SEC n

(* We only support 64-bit literals, hence the unexpected upper limit in the following function *)
inline_for_extraction
val u128: (n:range_t U64) -> u:uint128{uint_v #U128 u == n}

//inline_for_extraction
//let i128 (n:range_t S128) : u:int128{uint_v #S128 u == n} = uint #S128 #SEC n

unfold noextract
let max_size_t = maxint U32

unfold inline_for_extraction
type size_nat = n:nat{n <= max_size_t}

unfold inline_for_extraction
type size_pos = n:pos{n <= max_size_t}

inline_for_extraction
let size (n:size_nat) : size_t = uint #U32 #PUB n

unfold inline_for_extraction
let size_v (s:size_t) = uint_v #U32 #PUB s

unfold inline_for_extraction noextract
let v #t #l x = uint_v #t #l x

val size_v_size_lemma: s:size_nat ->
  Lemma
  (ensures (size_v (size s) == s))
  [SMTPat (size_v (size s))]

val uint_v_size_lemma: s:size_nat ->
  Lemma
  (ensures (uint_v (size s) == s))
  [SMTPat (uint_v (size s))]

inline_for_extraction
let byte (n:nat{n < 256}) : b:byte_t{uint_v b == n} = uint #U8 #PUB n

inline_for_extraction
let byte_v (s:byte_t) : n:size_nat{uint_v s == n} = pub_int_v (s <: pub_int_t U8)

inline_for_extraction
val size_to_uint32: s:size_t -> u:uint32{u == u32 (uint_v s)}

inline_for_extraction
val size_to_uint64: s:size_t -> u:uint64{u == u64 (uint_v s)}

inline_for_extraction
val byte_to_uint8: s:byte_t -> u:uint8{u == u8 (byte_v s)}

let op_At_Percent = Int.op_At_Percent

#reset-options
inline_for_extraction
val byte_to_int8: s:byte_t -> u:int8{u == i8 ((byte_v s) @% 256)}

inline_for_extraction
val nat_to_uint: #t:inttype -> #l:secrecy_level -> (n:range_t t) -> u:uint_t t l{uint_v u == n}

inline_for_extraction
let op_At_Percent_Dot x t =
  match t with
  | U1 | U8 | U16 | U32 | U64 | U128 -> x % modulus t
  | S8 | S16 | S32 | S64 -> x @% modulus t

inline_for_extraction
val cast: #t:inttype -> #l:secrecy_level
          -> t':inttype{(~(U128? t')) \/ (U1? t) \/ (U8? t) \/ (U16? t) \/ (U32? t) \/ (U64? t) \/ (U128? t)} -> l':secrecy_level {PUB? l \/ SEC? l'}
          -> u1:uint_t t l -> u2:uint_t t' l'{uint_v u2 == uint_v u1 @%. t'}

inline_for_extraction
let to_u1 #t #l u : uint1 = cast #t #l U1 SEC u

inline_for_extraction
let to_u8 #t #l u : uint8 = cast #t #l U8 SEC u

inline_for_extraction
let to_i8 #t #l u : int8 = cast #t #l S8 SEC u

inline_for_extraction
let to_u16 #t #l u : uint16 = cast #t #l U16 SEC u

inline_for_extraction
let to_i16 #t #l u : int16 = cast #t #l S16 SEC u

inline_for_extraction
let to_u32 #t #l u : uint32 = cast #t #l U32 SEC u

inline_for_extraction
let to_i32 #t #l u : int32 = cast #t #l S32 SEC u

inline_for_extraction
let to_u64 #t #l u : uint64 = cast #t #l U64 SEC u

inline_for_extraction
let to_i64 #t #l u : int64 = cast #t #l S64 SEC u

inline_for_extraction
let to_u128 (#t:inttype{(U1? t) \/ (U8? t) \/ (U16? t) \/ (U32? t) \/ (U64? t) \/ (U128? t)}) #l u : uint128 = cast #t #l U128 SEC u

//inline_for_extraction
//let to_i128 #t #l u : int128 = cast #t #l S128 SEC u

///
/// Bitwise operators for all machine integers
///

inline_for_extraction
val add_mod: #t:inttype -> #l:secrecy_level ->
             a:uint_t t l ->
             b:uint_t t l ->
             c:uint_t t l

inline_for_extraction
val add_mod_lemma: #t:inttype -> #l:secrecy_level ->
             a:uint_t t l ->
             b:uint_t t l ->
	     Lemma
	     (ensures (uint_v #t #l (add_mod #t #l a b) == (uint_v a + uint_v b) @%. t))
	     [SMTPat (uint_v #t #l (add_mod #t #l a b))]

inline_for_extraction
val add: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:uint_t t l{range (uint_v a + uint_v b) t}
  -> uint_t t l

inline_for_extraction
val add_lemma: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:uint_t t l{range (uint_v a + uint_v b) t}
  -> Lemma
    (ensures (uint_v #t #l (add #t #l a b) == uint_v a + uint_v b))
    [SMTPat (uint_v #t #l (add #t #l a b))]

inline_for_extraction
val incr: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l{uint_v a < maxint t}
  -> uint_t t l

inline_for_extraction
val incr_lemma: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l{uint_v a < maxint t}
  -> Lemma
  (ensures (uint_v #t #l (incr a) == uint_v a + 1))

inline_for_extraction
val mul_mod: #t:inttype{t <> U128} -> #l:secrecy_level
  -> a:uint_t t l
  -> b:uint_t t l
  -> uint_t t l

inline_for_extraction
val mul_mod_lemma: #t:inttype{t <> U128} -> #l:secrecy_level
  -> a:uint_t t l
  -> b:uint_t t l
  -> Lemma
  (ensures (uint_v #t #l (mul_mod #t #l a b) == (uint_v a `op_Multiply` uint_v b) @%. t))
  [SMTPat (uint_v #t #l (mul_mod #t #l a b))]

inline_for_extraction
val mul: #t:inttype{t <> U128} -> #l:secrecy_level
  -> a:uint_t t l
  -> b:uint_t t l{range (uint_v a `op_Multiply` uint_v b) t}
  -> uint_t t l


inline_for_extraction
val mul_lemma: #t:inttype{t <> U128} -> #l:secrecy_level
  -> a:uint_t t l
  -> b:uint_t t l{range (uint_v a `op_Multiply` uint_v b) t}
  -> Lemma
  (ensures (uint_v #t #l (mul #t #l a b) == uint_v a `op_Multiply` uint_v b))
  [SMTPat (uint_v #t #l (mul #t #l a b))]


inline_for_extraction
val mul64_wide: a:uint64 -> b:uint64 -> uint128

inline_for_extraction
val mul64_wide_lemma: a:uint64 -> b:uint64
  -> Lemma
  (ensures (uint_v (mul64_wide a b) == uint_v a `op_Multiply` uint_v b))
  [SMTPat (uint_v (mul64_wide a b))]

//inline_for_extraction
//val mulsigned64_wide: a:int64 -> b:int64 -> int128

//inline_for_extraction
//val mulsigned64_wide_lemma: a:int64 -> b:int64
  //-> Lemma
  //(ensures (uint_v (mulsigned64_wide a b) == uint_v a `op_Multiply` uint_v b))
  //[SMTPat (uint_v (mulsigned64_wide a b))]
(* KB: I would prefer the post-condition to say:
       uint_v c = (pow2 (bits t) + uint_v a - uint_v b) % pow2 (bits t)
*)
inline_for_extraction
val sub_mod: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:uint_t t l
  -> c:uint_t t l

inline_for_extraction
val sub_mod_lemma: #t:inttype -> #l:secrecy_level ->
             a:uint_t t l ->
             b:uint_t t l ->
	     Lemma
	     (ensures (uint_v #t #l (sub_mod #t #l a b) == (uint_v a - uint_v b) @%. t))
	     [SMTPat (uint_v #t #l (sub_mod #t #l a b))]

inline_for_extraction
val sub: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:uint_t t l{range (uint_v a - uint_v b) t}
  -> uint_t t l

inline_for_extraction
val sub_lemma: #t:inttype -> #l:secrecy_level ->
             a:uint_t t l ->
             b:uint_t t l{range (uint_v a - uint_v b) t} ->
	     Lemma
	     (ensures (uint_v #t #l (sub #t #l a b) == uint_v a - uint_v b))
	     [SMTPat (uint_v #t #l (sub #t #l a b))]

inline_for_extraction
val decr: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l{uint_v a > minint t}
  -> uint_t t l

inline_for_extraction
val decr_lemma: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l{uint_v a > minint t}
  -> Lemma
  (ensures (uint_v #t #l (decr a) == uint_v a - 1))

inline_for_extraction
let zero (t:inttype) = 0

inline_for_extraction
let one (t:inttype) = 1

#reset-options
inline_for_extraction
let ones_v (t:inttype) =
  match t with
  | U1 | U8 | U16 | U32 | U64 | U128 -> maxint t
  | S8 | S16 | S32 | S64 -> -1


inline_for_extraction
val logxor: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:uint_t t l
  -> uint_t t l

val logxor_lemma: #t:inttype -> a:uint_t t SEC -> b:uint_t t SEC -> Lemma
  (a `logxor` (a `logxor` b) == b /\
   a `logxor` (b `logxor` a) == b /\
   a `logxor` (uint #t #SEC 0) == a)

val logxor_lemma1: #t:inttype -> a:uint_t t SEC -> b:uint_t t SEC -> Lemma
  (requires range (v a) U1 /\ range (v b) U1)
  (ensures range (v (a `logxor` b)) U1)

inline_for_extraction
val logand: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:uint_t t l
  -> uint_t t l

val logand_lemma: #t:inttype{~(U1? t)} -> a:uint_t t SEC -> b:uint_t t SEC -> Lemma
  (requires v a = zero t \/ v a = ones_v t)
  (ensures (if v a = zero t then v (a `logand` b) == zero t else v (a `logand` b) == v b))

let logand_v (#t:inttype{~(U1? t)}) (a: range_t t) (b:range_t t) : range_t t=
match t with
  |S8 | S16 | S32 | S64 -> Int.logand #(8*numbytes t) a b
  |_ -> UInt.logand #(8*numbytes t) a b
  
val logand_spec: #t:inttype{~(U1? t)} -> #l:secrecy_level
  -> a:uint_t t l -> b:uint_t t l
  -> Lemma (ensures (v (a `logand` b) == (v a `logand_v` v b)))
  //[SMTPat (v (a `logand` b))]

inline_for_extraction
val logor: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:uint_t t l
  -> uint_t t l

val logor_disjoint: #t:inttype{(U1? t) \/ (U8? t) \/ (U16? t) \/ (U32? t) \/ (U64? t) \/ (U128? t)} -> a:uint_t t SEC -> b:uint_t t SEC -> m:nat{m < bits t} -> Lemma
  (requires 0 <= v a /\ v a < pow2 m /\ v b % pow2 m == 0)
  (ensures v (a `logor` b) == v a + v b)

inline_for_extraction
val lognot: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> uint_t t l

inline_for_extraction
type shiftval (t:inttype) = u:size_t{uint_v u < bits t}

inline_for_extraction
type rotval  (t:inttype) = u:size_t{uint_v u > 0 /\ uint_v u < bits t}

inline_for_extraction
val shift_right: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:shiftval t
  -> c:uint_t t l

val shift_right_lemma: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:shiftval t
  -> Lemma
    (ensures uint_v #t #l (shift_right #t #l a b) ==  uint_v #t #l a / pow2 (uint_v #U32 #PUB b))
    [SMTPat (uint_v #t #l (shift_right #t #l a b))]

inline_for_extraction
val shift_left: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:shiftval t
  -> c:uint_t t l

val shift_left_lemma: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:shiftval t
  -> Lemma
    (uint_v #t #l (shift_left #t #l a b) == (uint_v #t #l a `op_Multiply` pow2 (uint_v #U32 #PUB b)) @%. t)
    [SMTPat (uint_v #t #l (shift_left #t #l a b))]

inline_for_extraction
val rotate_right: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:rotval t
  -> uint_t t l

inline_for_extraction
val rotate_left: #t:inttype -> #l:secrecy_level
  -> a:uint_t t l
  -> b:rotval t
  -> uint_t t l

///
/// Masking operators for all machine integers
///

inline_for_extraction
val zeroes: t:inttype -> l:secrecy_level -> v:uint_t t l{uint_v v = zero t}

inline_for_extraction
val ones: t:inttype -> l:secrecy_level -> v:uint_t t l{uint_v v = ones_v t}

inline_for_extraction
val eq_mask: #t:inttype{~(S64? t)} -> uint_t t SEC -> uint_t t SEC -> uint_t t SEC

val eq_mask_lemma: #t:inttype{~(S64? t)} -> a:uint_t t SEC -> b:uint_t t SEC -> Lemma
  (requires True)
  (ensures  (v a = v b ==> v (eq_mask a b) == ones_v t) /\
            (v a <> v b ==> v (eq_mask a b) == 0))
  [SMTPat (eq_mask #t a b)]

val eq_mask_logand_lemma: #t:inttype{~(U1? t) /\ ~(S64? t)} -> a:uint_t t SEC -> b:uint_t t SEC -> c:uint_t t SEC -> Lemma
  (ensures (if v a = v b then v (c `logand` (eq_mask a b)) == v c else v (c `logand` (eq_mask a b)) == 0))
  [SMTPat (c `logand` (eq_mask a b))]

inline_for_extraction
val neq_mask: #t:inttype{~(S64? t)} -> a:uint_t t SEC -> b:uint_t t SEC -> uint_t t SEC

inline_for_extraction
val gte_mask: #t:inttype{~(S8? t) /\ ~(S16? t) /\ ~(S32? t) /\ ~(S64? t)} -> uint_t t SEC -> b:uint_t t SEC -> uint_t t SEC

val gte_mask_lemma: #t:inttype{~(S8? t) /\ ~(S16? t) /\ ~(S32? t) /\ ~(S64? t)} -> a:uint_t t SEC -> b:uint_t t SEC -> Lemma
  (requires True)
  (ensures  (v a >= v b ==> v (gte_mask a b) == maxint t) /\
            (v a < v b ==> v (gte_mask a b) == 0))
  [SMTPat (gte_mask #t a b)]

val gte_mask_logand_lemma: #t:inttype{~(U1? t) /\ ~(S8? t) /\ ~(S16? t) /\ ~(S32? t) /\ ~(S64? t)} -> a:uint_t t SEC -> b:uint_t t SEC -> c:uint_t t SEC -> Lemma
  (ensures (if v a >= v b then v (c `logand` (gte_mask a b)) == v c else v (c `logand` (gte_mask a b)) == 0))
  [SMTPat (c `logand` (gte_mask a b))]

inline_for_extraction
val lt_mask: #t:inttype{~(S8? t) /\ ~(S16? t) /\ ~(S32? t) /\ ~(S64? t)} -> uint_t t SEC -> uint_t t SEC -> uint_t t SEC

inline_for_extraction
val gt_mask: #t:inttype{~(S8? t) /\ ~(S16? t) /\ ~(S32? t) /\ ~(S64? t)} -> uint_t t SEC -> b:uint_t t SEC -> uint_t t SEC

inline_for_extraction
val lte_mask: #t:inttype{~(S8? t) /\ ~(S16? t) /\ ~(S32? t) /\ ~(S64? t)} -> uint_t t SEC -> uint_t t SEC -> uint_t t SEC

inline_for_extraction
let mod_mask (#t:inttype{~(S8? t) /\ ~(S16? t) /\ ~(S32? t) /\ ~(S64? t)}) (#l:secrecy_level) (m:shiftval t) : uint_t t l =
  (nat_to_uint 1 `shift_left` m) `sub_mod` nat_to_uint 1

val mod_mask_lemma: #t:inttype{~(S8? t) /\ ~(S16? t) /\ ~(S32? t) /\ ~(S64? t)} -> #l:secrecy_level -> a:uint_t t l -> m:shiftval t ->
  Lemma
    (requires True)
    (ensures  uint_v (a `logand` (mod_mask #t m)) == uint_v a % pow2 (uint_v m))
    [SMTPat (a `logand` (mod_mask #t m))]

///
/// Operators available for all machine integers
///

inline_for_extraction
let (+!) #t #l = add #t #l

inline_for_extraction
let (+.) #t #l = add_mod #t #l

inline_for_extraction
let ( *! ) #t #l = mul #t #l

inline_for_extraction
let ( *. ) #t #l = mul_mod #t #l

inline_for_extraction
let ( -! ) #t #l = sub #t #l

inline_for_extraction
let ( -. ) #t #l = sub_mod #t #l

inline_for_extraction
let ( >>. ) #t #l = shift_right #t #l

inline_for_extraction
let ( <<. ) #t #l = shift_left #t #l

inline_for_extraction
let ( >>>. ) #t #l = rotate_right #t #l

inline_for_extraction
let ( <<<. ) #t #l = rotate_left #t #l

inline_for_extraction
let ( ^. ) #t #l = logxor #t #l

inline_for_extraction
let ( |. ) #t #l = logor #t #l

inline_for_extraction
let ( &. ) #t #l = logand #t #l

inline_for_extraction
let ( ~. ) #t #l = lognot #t #l

///
/// Operations reserved to public integers
///

inline_for_extraction
val div: #t:inttype{t <> U128 /\ ~(S8? t) /\ ~(S16? t) /\ ~(S32? t) /\ ~(S64? t)}
  -> a:uint_t t PUB
  -> b:uint_t t PUB{uint_v b > 0}
  -> uint_t t PUB

inline_for_extraction
val div_lemma: #t:inttype{t <> U128 /\ ~(S8? t) /\ ~(S16? t) /\ ~(S32? t) /\ ~(S64? t)}
  -> a:uint_t t PUB
  -> b:uint_t t PUB{uint_v b > 0}
  -> Lemma
  (ensures (uint_v #t (div #t a b) == uint_v a / uint_v b))
  [SMTPat (uint_v #t (div #t a b))]


inline_for_extraction
val mod: #t:inttype{t <> U128 /\ ~(S8? t) /\ ~(S16? t) /\ ~(S32? t) /\ ~(S64? t)} -> a:uint_t t PUB -> b:uint_t t PUB{uint_v b > 0} -> uint_t t PUB

inline_for_extraction
val mod_lemma: #t:inttype{t <> U128 /\ ~(S8? t) /\ ~(S16? t) /\ ~(S32? t) /\ ~(S64? t)}
  -> a:uint_t t PUB
  -> b:uint_t t PUB{uint_v b > 0}
  -> Lemma
  (ensures (uint_v #t (mod #t a b) == uint_v a % uint_v b))
  [SMTPat (uint_v #t (mod #t a b))]


inline_for_extraction
val eq: #t:inttype -> uint_t t PUB -> uint_t t PUB -> bool

inline_for_extraction
val eq_lemma: #t:inttype
  -> a:uint_t t PUB
  -> b:uint_t t PUB
  -> Lemma
  (ensures (eq #t a b == (uint_v a = uint_v b)))
  [SMTPat (eq #t a b)]

inline_for_extraction
val ne: #t:inttype -> uint_t t PUB -> uint_t t PUB -> bool

inline_for_extraction
val ne_lemma: #t:inttype
  -> a:uint_t t PUB
  -> b:uint_t t PUB
  -> Lemma
  (ensures (ne #t a b == (uint_v a <> uint_v b)))
  [SMTPat (ne #t a b)]

inline_for_extraction
val lt: #t:inttype -> uint_t t PUB -> uint_t t PUB -> bool

inline_for_extraction
val lt_lemma: #t:inttype
  -> a:uint_t t PUB
  -> b:uint_t t PUB
  -> Lemma
  (ensures (lt #t a b == (uint_v a < uint_v b)))
  [SMTPat (lt #t a b)]

inline_for_extraction
val lte: #t:inttype -> uint_t t PUB -> uint_t t PUB -> bool

inline_for_extraction
val lte_lemma: #t:inttype
  -> a:uint_t t PUB
  -> b:uint_t t PUB
  -> Lemma
  (ensures (lte #t a b == (uint_v a <= uint_v b)))
  [SMTPat (lte #t a b)]


inline_for_extraction
val gt: #t:inttype -> uint_t t PUB -> uint_t t PUB -> bool

inline_for_extraction
val gt_lemma: #t:inttype
  -> a:uint_t t PUB
  -> b:uint_t t PUB
  -> Lemma
  (ensures (gt #t a b == (uint_v a > uint_v b)))
  [SMTPat (gt #t a b)]


inline_for_extraction
val gte: #t:inttype -> uint_t t PUB -> uint_t t PUB -> bool

inline_for_extraction
val gte_lemma: #t:inttype
  -> a:uint_t t PUB
  -> b:uint_t t PUB
  -> Lemma
  (ensures (gte #t a b == (uint_v a >= uint_v b)))
  [SMTPat (gte #t a b)]

inline_for_extraction
let (/.) #t = div #t

inline_for_extraction
let (%.) #t = mod #t

inline_for_extraction
let (=.) #t = eq #t

inline_for_extraction
let (<>.) #t = ne #t

inline_for_extraction
let (<.) #t = lt #t

inline_for_extraction
let (<=.) #t = lte #t

inline_for_extraction
let (>.) #t = gt #t

inline_for_extraction
let (>=.) #t = gte #t

inline_for_extraction
let p_t (t:inttype) =
  match t with
  | U32 -> UInt32.t
  | _ -> UInt64.t
