module Hacl.Impl.EC.LowLevel

open FStar.HyperStack.All
open FStar.HyperStack
module ST = FStar.HyperStack.ST

open Lib.IntTypes
open Lib.Buffer

open Hacl.Spec.EC.Definition
open Spec.ECC
open Spec.ECC.Curves
open FStar.Mul
open Hacl.Spec.MontgomeryMultiplication

open Hacl.Impl.EC.Setup


#set-options "--z3rlimit 100"


val uploadZeroImpl: #c: curve -> f: felem c -> Stack unit 
  (requires fun h -> live h f)
  (ensures fun h0 _ h1 -> as_nat c h1 f == 0 /\ modifies (loc f) h0 h1)



val uploadOneImpl: #c: curve -> f: felem c -> Stack unit
  (requires fun h -> live h f)
  (ensures fun h0 _ h1 -> as_nat c h1 f == 1 /\ modifies (loc f) h0 h1)


val uploadZeroPoint: #c: curve -> p: point c -> 
  Stack unit
  (requires fun h -> live h p)
  (ensures fun h0 _ h1 ->
    let len = getCoordinateLenU64 c in 
    modifies (loc p) h0 h1 /\
    as_nat c h1 (gsub p (size 0) len) == 0 /\ 
    as_nat c h1 (gsub p len len) == 0 /\
    as_nat c h1 (gsub p (size 2 *! len) len) == 0) 


val add_bn: #c: curve -> x: felem c -> y: felem c -> result: felem c -> 
  Stack uint64
    (requires fun h -> live h x /\ live h y /\ live h result /\ eq_or_disjoint x result /\ eq_or_disjoint y result)
    (ensures fun h0 r h1 -> modifies (loc result) h0 h1 /\ v r <= 1 /\ 
      as_nat c h1 result + v r * (pow2 (getPower c)) == as_nat c h0 x + as_nat c h0 y)   


val add_long_bn: #c: curve -> x: widefelem c -> y: widefelem c -> result: widefelem c -> 
  Stack uint64 
  (requires fun h -> live h x /\ live h y /\ live h result /\ eq_or_disjoint x result /\ eq_or_disjoint y result)
  (ensures fun h0 r h1 -> modifies (loc result) h0 h1 /\ v r <= 1 /\ 
    wide_as_nat c h1 result + v r * pow2 (getLongPower c) == wide_as_nat c h0 x + wide_as_nat c h0 y)


val add_dep_prime: #c: curve -> x: felem c -> t: uint64 {uint_v t == 0 \/ uint_v t == 1} -> result: felem c -> 
  Stack uint64
    (requires fun h -> live h x /\ live h result /\ eq_or_disjoint x result)
    (ensures fun h0 r h1 -> modifies (loc result) h0 h1 /\ (
      if uint_v t = 1 then 
	as_nat c h1 result + uint_v r * (pow2 (getPower c))  == as_nat c h0 x + getPrime c
      else
	as_nat c h1 result  == as_nat c h0 x))  
 

val sub_bn: #c: curve -> x: felem c -> y:felem c -> result: felem c -> 
  Stack uint64
    (requires fun h -> live h x /\ live h y /\ live h result /\ eq_or_disjoint x result /\ eq_or_disjoint y result)
    (ensures fun h0 r h1 -> modifies1 result h0 h1 /\ v r <= 1 /\ 
      as_nat c h1 result - v r * (pow2 (getPower c)) == as_nat c h0 x - as_nat c h0 y)


val sub_bn_gl: #c: curve -> x: felem c -> y: glbuffer uint64 (getCoordinateLenU64 c) -> 
  result: felem c -> Stack uint64
    (requires fun h -> live h x /\ live h y /\ live h result /\ disjoint x result /\ disjoint y result)
    (ensures fun h0 r h1 -> modifies (loc result) h0 h1 /\ v r <= 1 /\ 
      as_nat c h1 result - v r * (pow2 (getPower c)) == as_nat c h0 x  - as_nat_il c h0 y /\ (
      if uint_v r = 0 then 
	as_nat c h0 x >= as_nat_il c h0 y 
      else 
	as_nat c h0 x < as_nat_il c h0 y))


val short_mul_bn: #c: curve -> a: glbuffer uint64 (getCoordinateLenU64 c) -> b: uint64 -> result: widefelem c -> Stack unit
  (requires fun h -> live h a /\ live h result /\ wide_as_nat c h result = 0)
  (ensures fun h0 _ h1 -> modifies (loc result) h0 h1 /\ 
    as_nat_il c h0 a * uint_v b = wide_as_nat c h1 result /\ 
    wide_as_nat c h1 result < (pow2 (getPower c)) * pow2 64)

val short_mul_prime: #c: curve -> b: uint64 -> result: widefelem c -> Stack unit
  (requires fun h -> live h result /\ wide_as_nat c h result = 0)
  (ensures fun h0 _ h1 -> modifies (loc result) h0 h1 /\ 
    getPrime c * uint_v b = wide_as_nat c h1 result /\ 
    wide_as_nat c h1 result < (pow2 (getPower c))  * pow2 64)


val square_bn: #c: curve -> f: felem c -> out: widefelem c -> Stack unit
    (requires fun h -> live h out /\ live h f /\ eq_or_disjoint f out)
    (ensures  fun h0 _ h1 -> modifies (loc out) h0 h1 /\ 
      wide_as_nat c h1 out = as_nat c h0 f * as_nat c h0 f)
      



val reduction_prime_2prime_with_carry: #c: curve -> x: widefelem c -> result: felem c -> 
  Stack unit 
    (requires fun h -> 
      live h x /\ live h result /\ eq_or_disjoint x result /\ wide_as_nat c h x < 2 * getPrime c)
    (ensures fun h0 _ h1 -> 
      modifies (loc result) h0 h1 /\ as_nat c h1 result = wide_as_nat c h0 x % getPrime c)


val reduction_prime_2prime: #c: curve -> x: felem c -> result: felem c -> 
  Stack unit
    (requires fun h -> 
      live h x /\ live h result /\ eq_or_disjoint x result)
    (ensures fun h0 _ h1 -> 
      modifies (loc result) h0 h1 /\ as_nat c h1 result == as_nat c h0 x % getPrime c)


val felem_add: #c: curve -> a: felem c -> b: felem c -> out: felem c -> 
  Stack unit
    (requires (fun h0 -> 
      live h0 a /\ live h0 b /\ live h0 out /\ eq_or_disjoint a out /\  eq_or_disjoint b out /\
      as_nat c h0 a < getPrime c /\ as_nat c h0 b < getPrime c))
    (ensures (fun h0 _ h1 -> 
      modifies (loc out) h0 h1 /\ 
      as_nat c h1 out == (as_nat c h0 a + as_nat c h0 b) % getPrime c /\
      as_nat c h1 out == toDomain_ #c((fromDomain_ #c (as_nat c h0 a) + fromDomain_ #c (as_nat c h0 b)) % getPrime c)))


val felem_double: #c: curve -> a: felem c -> out: felem c -> 
  Stack unit 
    (requires (fun h0 -> 
      live h0 a /\ live h0 out /\ eq_or_disjoint a out /\ as_nat c h0 a < getPrime c))
    (ensures (fun h0 _ h1 -> 
      modifies (loc out) h0 h1 /\ 
      as_nat c h1 out == (2 * as_nat c h0 a) % getPrime c /\
      as_nat c h1 out == toDomain_ #c (2 * fromDomain_ #c (as_nat c h0 a) % getPrime c)))


val felem_sub: #c: curve -> a: felem c -> b: felem c -> out: felem c -> 
  Stack unit 
    (requires (fun h0 -> 
      live h0 out /\ live h0 a /\ live h0 b /\ 
      as_nat c h0 a < getPrime c /\ as_nat c h0 b < getPrime c))
    (ensures (fun h0 _ h1 -> 
      modifies (loc out) h0 h1 /\ 
      as_nat c h1 out == (as_nat c h0 a - as_nat c h0 b) % getPrime c /\
      as_nat c h1 out == toDomain_ #c ((fromDomain_ #c (as_nat c h0 a) - fromDomain_ #c (as_nat c h0 b)) % getPrime c)))    


val mul: #c: curve -> f: felem c -> r: felem c -> out: widefelem c -> 
  Stack unit
    (requires fun h -> live h out /\ live h f /\ live h r /\ disjoint r out)
    (ensures  fun h0 _ h1 -> modifies (loc out) h0 h1 /\ 
      wide_as_nat c h1 out = as_nat c h0 r * as_nat c h0 f)



val isZero_uint64_CT: #c: curve ->  f: felem c -> Stack uint64
  (requires fun h -> live h f)
  (ensures fun h0 r h1 -> modifies0 h0 h1 /\ 
    (if as_nat c h0 f = 0 then uint_v r == pow2 64 - 1 else uint_v r == 0))


val compare_felem: #c: curve -> a: felem c -> b: felem c -> Stack uint64
  (requires fun h -> live h a /\ live h b) 
  (ensures fun h0 r h1 -> modifies0 h0 h1 /\ 
    (if as_nat c h0 a = as_nat c h0 b then uint_v r == pow2 64 - 1 else uint_v r = 0))

(*
val copy_conditional: #c: curve -> out: felem c -> x: felem c 
  -> mask: uint64 {uint_v mask = 0 \/ uint_v mask = pow2 64 - 1} -> Stack unit 
  (requires fun h -> live h out /\ live h x)
  (ensures fun h0 _ h1 -> modifies (loc out) h0 h1 /\ 
    (if uint_v mask = 0 then as_seq h1 out == as_seq h0 out else as_seq h1 out == as_seq h0 x))  *)


val shiftLeftWord: #c: curve -> i: felem c -> o: lbuffer uint64 (getCoordinateLenU64 c *. 2ul)-> 
  Stack unit 
    (requires fun h -> live h i /\ live h o /\ disjoint i o)
    (ensures fun h0 _ h1 -> modifies1 o h0 h1 /\ wide_as_nat c h1 o == as_nat c h0 i * (pow2 (getPower c)))


inline_for_extraction noextract
val mod64: #c: curve -> a: widefelem c -> Stack uint64 
  (requires fun h -> live h a) 
  (ensures fun h0 r h1 -> modifies0 h0 h1 /\ wide_as_nat c h1 a % pow2 64 = uint_v r)


val shift1_with_carry: #c: curve -> t: widefelem c -> t1: widefelem c -> carry: uint64 -> Stack unit 
  (requires fun h -> live h t /\ live h t1 /\ disjoint t t1)
  (ensures fun h0 _ h1 -> modifies (loc t1) h0 h1 /\ 
    (wide_as_nat c h0 t + pow2 (getLongPower c) * v carry) / pow2 64 = wide_as_nat c h1 t1)


inline_for_extraction noextract 
val upload_one_montg_form: #c: curve -> b: felem c -> Stack unit
  (requires fun h -> live h b /\ as_nat c h b = 0)
  (ensures fun h0 _ h1 -> modifies (loc b) h0 h1 /\ as_nat c h1 b = toDomain_ #c 1)


inline_for_extraction noextract
val scalar_bit: #c: curve -> #buf_type: buftype
  -> s:lbuffer_t buf_type uint8 (getScalarLen c)
  -> n:size_t{v n < v (getScalarLenBytes c)}
  -> Stack uint64
    (requires fun h0 -> live h0 s)
    (ensures  fun h0 r h1 -> h0 == h1 /\ r == Spec.ECDSA.ith_bit_felem #c (as_seq h0 s) (v n) 
    /\ v r <= 1)


val mul_atomic: x: uint64 -> y: uint64 -> result: lbuffer uint64 (size 1) -> temp: lbuffer uint64 (size 1) ->
  Stack unit
    (requires fun h -> live h result /\ live h temp /\ disjoint result temp)
  (ensures fun h0 _ h1 -> modifies (loc result |+| loc temp) h0 h1 /\ 
    (
      let h0 = Seq.index (as_seq h1 temp) 0 in 
      let result = Seq.index (as_seq h1 result) 0 in 
      uint_v result + uint_v h0 * pow2 64 = uint_v x * uint_v y))
