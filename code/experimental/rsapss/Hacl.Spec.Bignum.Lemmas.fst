module Hacl.Spec.Bignum.Lemmas

open FStar.Mul

module S = Spec.RSAPSS
module M = Hacl.Spec.Bignum.Montgomery.Lemmas
module Loops = Lib.LoopCombinators


#reset-options "--z3rlimit 50 --max_fuel 0 --max_ifuel 0"

val lemma_mul_ass3: a:nat -> b:nat -> c:nat -> Lemma
  (a * b * c == a * c * b)
let lemma_mul_ass3 a b c = ()

val pow: x:nat -> n:nat -> Tot nat
let rec pow x n =
  if n = 0 then 1
  else x * pow x (n - 1)

#set-options "--max_fuel 2"

val lemma_pow_unfold: a:nat -> b:pos -> Lemma (a * pow a (b - 1) == pow a b)
let lemma_pow_unfold a b = ()

val lemma_pow_greater: a:pos -> b:nat ->
  Lemma (pow a b > 0)
  [SMTPat (pow a b)]
let rec lemma_pow_greater a b =
  if b = 0 then ()
  else lemma_pow_greater a (b - 1)

val lemma_pow1: a:nat -> Lemma (pow a 1 = a)
let lemma_pow1 a = ()

val lemma_pow_add: x:nat -> n:nat -> m:nat -> Lemma
  (pow x n * pow x m = pow x (n + m))
let rec lemma_pow_add x n m =
  if n = 0 then ()
  else begin
    lemma_pow_add x (n-1) m;
    Math.Lemmas.paren_mul_right x (pow x (n-1)) (pow x m) end

val lemma_pow_double: a:nat -> b:nat -> Lemma
  (pow (a * a) b == pow a (b + b))
let rec lemma_pow_double a b =
  if b = 0 then ()
  else begin
    calc (==) {
      pow (a * a) b;
      (==) { lemma_pow_unfold (a * a) b }
      a * a * pow (a * a) (b - 1);
      (==) { lemma_pow_double a (b - 1) }
      a * a * pow a (b + b - 2);
      (==) { lemma_pow1 a }
      pow a 1 * pow a 1 * pow a (b + b - 2);
      (==) { lemma_pow_add a 1 1 }
      pow a 2 * pow a (b + b - 2);
      (==) { lemma_pow_add a 2 (b + b - 2) }
      pow a (b + b);
    };
    assert (pow (a * a) b == pow a (b + b))
  end


val lemma_pow_mul_base: a:nat -> b:nat -> n:nat -> Lemma
  (pow a n * pow b n == pow (a * b) n)
let rec lemma_pow_mul_base a b n =
  if n = 0 then ()
  else begin
    calc (==) {
      pow a n * pow b n;
      (==) { lemma_pow_unfold a n; lemma_pow_unfold b n }
      a * pow a (n - 1) * (b * pow b (n - 1));
      (==) { Math.Lemmas.paren_mul_right (a * pow a (n - 1)) b (pow b (n - 1)) }
      a * pow a (n - 1) * b * pow b (n - 1);
      (==) { lemma_mul_ass3 a (pow a (n - 1)) b }
      a * b * pow a (n - 1) * pow b (n - 1);
      (==) { Math.Lemmas.paren_mul_right (a * b) (pow a (n - 1)) (pow b (n - 1)) }
      a * b * (pow a (n - 1) * pow b (n - 1));
      (==) { lemma_pow_mul_base a b (n - 1) }
      a * b * pow (a * b) (n - 1);
      (==) { lemma_pow_unfold (a * b) n }
      pow (a * b) n;
    };
    assert (pow a n * pow b n == pow (a * b) n)
  end


val lemma_pow_mod_base: a:nat -> b:nat -> n:pos -> Lemma
  (pow a b % n == pow (a % n) b % n)
let rec lemma_pow_mod_base a b n =
  if b = 0 then ()
  else begin
    calc (==) {
      pow a b % n;
      (==) { lemma_pow_unfold a b }
      a * pow a (b - 1) % n;
      (==) { Math.Lemmas.lemma_mod_mul_distr_r a (pow a (b - 1)) n }
      a * (pow a (b - 1) % n) % n;
      (==) { lemma_pow_mod_base a (b - 1) n }
      a * (pow (a % n) (b - 1) % n) % n;
      (==) { Math.Lemmas.lemma_mod_mul_distr_r a (pow (a % n) (b - 1)) n }
      a * pow (a % n) (b - 1) % n;
      (==) { Math.Lemmas.lemma_mod_mul_distr_l a (pow (a % n) (b - 1)) n }
      a % n * pow (a % n) (b - 1) % n;
      (==) { lemma_pow_unfold (a % n) b }
      pow (a % n) b % n;
    };
    assert (pow a b % n == pow (a % n) b % n)
  end


val lemma_fpow_unfold0: n:pos -> a:nat{a < n} -> b:pos{1 < b /\ b % 2 = 0} -> Lemma
  (S.fpow #n a b == S.fpow (S.fmul a a) (b / 2))
let lemma_fpow_unfold0 n a b = ()

val lemma_fpow_unfold1: n:pos -> a:nat{a < n} -> b:pos{1 < b /\ b % 2 = 1} -> Lemma
  (S.fpow #n a b == S.fmul a (S.fpow (S.fmul a a) (b / 2)))
let lemma_fpow_unfold1 n a b = ()


val lemma_pow_mod_n_is_fpow: n:pos -> a:nat{a < n} -> b:pos -> Lemma
  (ensures (S.fpow #n a b == pow a b % n)) (decreases b)
let rec lemma_pow_mod_n_is_fpow n a b =
  if b = 1 then ()
  else begin
    if b % 2 = 0 then begin
      calc (==) {
	S.fpow #n a b;
	(==) { lemma_fpow_unfold0 n a b }
	S.fpow #n (S.fmul #n a a) (b / 2);
	(==) { lemma_pow_mod_n_is_fpow n (S.fmul #n a a) (b / 2) }
	pow (S.fmul #n a a) (b / 2) % n;
	(==) { lemma_pow_mod_base (a * a) (b / 2) n }
	pow (a * a) (b / 2) % n;
	(==) { lemma_pow_double a (b / 2) }
	pow a b % n;
      };
      assert (S.fpow #n a b == pow a b % n) end
    else begin
      calc (==) {
	S.fpow #n a b;
	(==) { lemma_fpow_unfold1 n a b }
	S.fmul a (S.fpow (S.fmul #n a a) (b / 2));
	(==) { lemma_pow_mod_n_is_fpow n (S.fmul #n a a) (b / 2) }
	S.fmul a (pow (S.fmul #n a a) (b / 2) % n);
	(==) { lemma_pow_mod_base (a * a) (b / 2) n }
	S.fmul a (pow (a * a) (b / 2) % n);
	(==) { lemma_pow_double a (b / 2) }
	S.fmul a (pow a (b / 2 * 2) % n);
	(==) { Math.Lemmas.lemma_mod_mul_distr_r a (pow a (b / 2 * 2)) n }
	a * pow a (b / 2 * 2) % n;
	(==) { lemma_pow1 a }
	pow a 1 * pow a (b / 2 * 2) % n;
	(==) { lemma_pow_add a 1 (b / 2 * 2) }
	pow a (b / 2 * 2 + 1) % n;
	(==) { Math.Lemmas.euclidean_division_definition b 2 }
	pow a b % n;
      };
      assert (S.fpow #n a b == pow a b % n) end
  end


#set-options "--max_fuel 0"

val lemma_mul_ass5_aux: a:nat -> b:nat -> c:nat -> d:nat -> e:nat -> Lemma
  (a * b * c * d * e == a * b * (c * d * e))
let lemma_mul_ass5_aux a b c d e =
  calc (==) {
    a * b * c * d * e;
    (==) { Math.Lemmas.paren_mul_right (a * b) c d }
    a * b * (c * d) * e;
    (==) { Math.Lemmas.paren_mul_right (a * b) (c * d) e }
    a * b * (c * d * e);
  }


val lemma_mul_ass5: a:nat -> b:nat -> c:nat -> d:nat -> e:nat -> Lemma
  (a * b * (c * d) * e == a * c * (b * d * e))
let lemma_mul_ass5 a b c d e =
  calc (==) {
    a * b * (c * d) * e;
    (==) { Math.Lemmas.paren_mul_right (a * b) (c * d) e }
    a * b * ((c * d) * e);
    (==) { Math.Lemmas.paren_mul_right c d e }
    a * b * (c * d * e);
    (==) { lemma_mul_ass5_aux a b c d e }
    a * b * c * d * e;
    (==) { lemma_mul_ass3 a b c }
    a * c * b * d * e;
    (==) { lemma_mul_ass5_aux a c b d e }
    a * c * (b * d * e);
  }

val lemma_mod_mul_distr_aux: a:nat -> b:nat -> c:nat -> n:pos -> Lemma
  (a * b * c % n == a % n * (b % n) * c % n)
let lemma_mod_mul_distr_aux a b c n =
  calc (==) {
    a * b * c % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l (a * b) c n }
    a * b % n * c % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l a b n }
    a % n * b % n * c % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_r (a % n) b n }
    a % n * (b % n) % n * c % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l (a % n * (b % n)) c n }
    a % n * (b % n) * c % n;
  }


val mod_exp_f: n:pos -> d:pos -> bBits:nat -> b:nat{b < pow2 bBits} -> i:nat{i < bBits} -> tuple2 nat nat -> tuple2 nat nat
let mod_exp_f n d bBits b i (aM, accM) =
  let accM = if (b / pow2 i % 2 = 1) then accM * aM * d % n else accM in
  let aM = aM * aM * d % n in
  (aM, accM)


val mod_exp_mont: n:pos -> r:pos -> d:pos{r * d % n == 1} -> a:nat -> bBits:nat -> b:nat{b < pow2 bBits} -> res:nat
let mod_exp_mont n r d a bBits b =
  let aM = a * r % n in
  let accM = 1 * r % n in
  let (aM, accM) = Loops.repeati bBits (mod_exp_f n d bBits b) (aM, accM) in
  let acc = accM * d % n in
  acc

///
///  Lemma (mod_exp_mont n r d a bBits b == S.fpow #n a b)
///

val mod_exp_mont_lemma_step_a:
    n:pos -> d:pos
  -> bBits:nat -> b:nat{b < pow2 bBits}
  -> i:pos{i <= bBits}
  -> aM0:nat -> accM0:nat
  -> aM1:nat -> accM1:nat ->
  Lemma
  (requires
    aM1 % n == pow aM0 (pow2 (i - 1)) * pow d (pow2 (i - 1) - 1) % n /\
    accM1 % n == pow aM0 (b % pow2 (i - 1)) * accM0 * pow d (b % pow2 (i - 1)) % n)
  (ensures
   (let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM1, accM1) in
    aM2 % n == pow aM0 (pow2 i) * pow d (pow2 i - 1) % n))

let mod_exp_mont_lemma_step_a n d bBits b i aM0 accM0 aM1 accM1 =
  let pow2i1 = pow2 (i - 1) in
  let pow2i_loc () : Lemma (pow2i1 + pow2i1 == pow2 i) =
    Math.Lemmas.pow2_double_sum (i - 1) in
  let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM1, accM1) in
  Math.Lemmas.lemma_mod_mod aM2 (aM1 * aM1 * d) n;
  assert (aM2 % n == aM1 * aM1 * d % n);
  calc (==) {
    aM1 * aM1 * d % n;
    (==) { lemma_mod_mul_distr_aux aM1 aM1 d n }
    aM1 % n * (aM1 % n) * d % n;
    (==) { }
    (pow aM0 pow2i1 * pow d (pow2i1 - 1) % n) * (pow aM0 pow2i1 * pow d (pow2i1 - 1) % n) * d % n;
    (==) { lemma_mod_mul_distr_aux (pow aM0 pow2i1 * pow d (pow2i1 - 1)) (pow aM0 pow2i1 * pow d (pow2i1 - 1)) d n }
    pow aM0 pow2i1 * pow d (pow2i1 - 1) * (pow aM0 pow2i1 * pow d (pow2i1 - 1)) * d % n;
    (==) { lemma_mul_ass5 (pow aM0 pow2i1) (pow d (pow2i1 - 1)) (pow aM0 pow2i1) (pow d (pow2i1 - 1)) d }
    pow aM0 pow2i1 * pow aM0 pow2i1 * (pow d (pow2i1 - 1) * pow d (pow2i1 - 1) * d) % n;
    (==) { lemma_pow_add aM0 pow2i1 pow2i1 }
    pow aM0 (pow2i1 + pow2i1) * (pow d (pow2i1 - 1) * pow d (pow2i1 - 1) * d) % n;
    (==) { lemma_pow_add d (pow2i1 - 1) (pow2i1 - 1) }
    pow aM0 (pow2i1 + pow2i1) * (pow d (pow2i1 - 1 + pow2i1 - 1) * d) % n;
    (==) { lemma_pow1 d; lemma_pow_add d (pow2i1 - 1 + pow2i1 - 1) 1 }
    pow aM0 (pow2i1 + pow2i1) * pow d (pow2i1 + pow2i1 - 1) % n;
    (==) { pow2i_loc () }
    pow aM0 (pow2 i) * pow d (pow2 i - 1) % n;
  };
  assert (aM1 * aM1 * d % n == pow aM0 (pow2 i) * pow d (pow2 i - 1) % n)


val lemma_b_mod_pow2i: bBits:nat -> b:nat{b < pow2 bBits} -> i:pos{i <= bBits} -> Lemma
  (b % pow2 i == b / pow2 (i - 1) % 2 * pow2 (i - 1) + b % pow2 (i - 1))
let lemma_b_mod_pow2i bBits b i =
  calc (==) {
    b % pow2 i;
    (==) { Math.Lemmas.euclidean_division_definition (b % pow2 i) (pow2 (i - 1)) }
    b % pow2 i / pow2 (i - 1) * pow2 (i - 1) + b % pow2 i % pow2 (i - 1);
    (==) { Math.Lemmas.pow2_modulo_modulo_lemma_1 b (i - 1) i }
    b % pow2 i / pow2 (i - 1) * pow2 (i - 1) + b % pow2 (i - 1);
    (==) { Math.Lemmas.pow2_modulo_division_lemma_1 b (i - 1) i; assert_norm (pow2 1 = 2) }
    b / pow2 (i - 1) % 2 * pow2 (i - 1) + b % pow2 (i - 1);
  }


val mod_exp_mont_lemma_step_acc0:
    n:pos -> d:pos
  -> bBits:nat -> b:nat{b < pow2 bBits}
  -> i:pos{i <= bBits}
  -> aM0:nat -> accM0:nat
  -> aM1:nat -> accM1:nat ->
  Lemma
  (requires
    b / pow2 (i - 1) % 2 == 0 /\
    aM1 % n == pow aM0 (pow2 (i - 1)) * pow d (pow2 (i - 1) - 1) % n /\
    accM1 % n == pow aM0 (b % pow2 (i - 1)) * accM0 * pow d (b % pow2 (i - 1)) % n)
  (ensures
   (let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM1, accM1) in
    accM2 % n == pow aM0 (b % pow2 i) * accM0 * pow d (b % pow2 i) % n))

let mod_exp_mont_lemma_step_acc0 n d bBits b i aM0 accM0 aM1 accM1 =
  let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM1, accM1) in
  assert (accM2 = accM1);
  lemma_b_mod_pow2i bBits b i;
  assert (b % pow2 i == b % pow2 (i - 1))


val mod_exp_mont_lemma_step_acc1:
    n:pos -> d:pos
  -> bBits:nat -> b:nat{b < pow2 bBits}
  -> i:pos{i <= bBits}
  -> aM0:nat -> accM0:nat
  -> aM1:nat -> accM1:nat ->
  Lemma
  (requires
    b / pow2 (i - 1) % 2 == 1 /\
    aM1 % n == pow aM0 (pow2 (i - 1)) * pow d (pow2 (i - 1) - 1) % n /\
    accM1 % n == pow aM0 (b % pow2 (i - 1)) * accM0 * pow d (b % pow2 (i - 1)) % n)
  (ensures
   (let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM1, accM1) in
    accM2 % n == pow aM0 (b % pow2 i) * accM0 * pow d (b % pow2 i) % n))

let mod_exp_mont_lemma_step_acc1 n d bBits b i aM0 accM0 aM1 accM1 =
  let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM1, accM1) in
  Math.Lemmas.lemma_mod_mod accM2 (accM1 * aM1 * d) n;
  assert (accM2 % n = accM1 * aM1 * d % n);
  let lemma_b_mod_pow2i_loc () : Lemma (b % pow2 i == pow2 (i - 1) + b % pow2 (i - 1)) =
    lemma_b_mod_pow2i bBits b i in
  calc (==) {
    accM1 * aM1 * d % n;
    (==) { lemma_mod_mul_distr_aux accM1 aM1 d n }
    accM1 % n * (aM1 % n) * d % n;
    (==) { }
    (pow aM0 (b % pow2 (i - 1)) * accM0 * pow d (b % pow2 (i - 1)) % n) * (pow aM0 (pow2 (i - 1)) * pow d (pow2 (i - 1) - 1) % n) * d % n;
    (==) { lemma_mod_mul_distr_aux (pow aM0 (b % pow2 (i - 1)) * accM0 * pow d (b % pow2 (i - 1))) (pow aM0 (pow2 (i - 1)) * pow d (pow2 (i - 1) - 1)) d n }
    pow aM0 (b % pow2 (i - 1)) * accM0 * pow d (b % pow2 (i - 1)) * (pow aM0 (pow2 (i - 1)) * pow d (pow2 (i - 1) - 1)) * d % n;
    (==) { lemma_mul_ass5 (pow aM0 (b % pow2 (i - 1)) * accM0) (pow d (b % pow2 (i - 1))) (pow aM0 (pow2 (i - 1))) (pow d (pow2 (i - 1) - 1)) d }
    pow aM0 (b % pow2 (i - 1)) * accM0 * pow aM0 (pow2 (i - 1)) * (pow d (b % pow2 (i - 1)) * pow d (pow2 (i - 1) - 1) * d) % n;
    (==) { lemma_mul_ass3 (pow aM0 (b % pow2 (i - 1))) accM0 (pow aM0 (pow2 (i - 1))) }
    pow aM0 (b % pow2 (i - 1)) * pow aM0 (pow2 (i - 1)) * accM0 * (pow d (b % pow2 (i - 1)) * pow d (pow2 (i - 1) - 1) * d) % n;
    (==) { lemma_pow_add aM0 (b % pow2 (i - 1)) (pow2 (i - 1)) }
    pow aM0 (b % pow2 (i - 1) + pow2 (i - 1)) * accM0 * (pow d (b % pow2 (i - 1)) * pow d (pow2 (i - 1) - 1) * d) % n;
    (==) { lemma_pow_add d (b % pow2 (i - 1)) (pow2 (i - 1) - 1) }
    pow aM0 (b % pow2 (i - 1) + pow2 (i - 1)) * accM0 * (pow d (b % pow2 (i - 1) + pow2 (i - 1) - 1) * d) % n;
    (==) { lemma_pow1 d; lemma_pow_add d (b % pow2 (i - 1) + pow2 (i - 1) - 1) 1 }
    pow aM0 (b % pow2 (i - 1) + pow2 (i - 1)) * accM0 * pow d (b % pow2 (i - 1) + pow2 (i - 1)) % n;
    (==) { lemma_b_mod_pow2i_loc () }
    pow aM0 (b % pow2 i) * accM0 * pow d (b % pow2 i) % n;
    };
  assert (accM1 * aM1 * d % n == pow aM0 (b % pow2 i) * accM0 * pow d (b % pow2 i) % n)


val mod_exp_mont_lemma_step_acc:
    n:pos -> d:pos
  -> bBits:nat -> b:nat{b < pow2 bBits}
  -> i:pos{i <= bBits}
  -> aM0:nat -> accM0:nat
  -> aM1:nat -> accM1:nat ->
  Lemma
  (requires
    aM1 % n == pow aM0 (pow2 (i - 1)) * pow d (pow2 (i - 1) - 1) % n /\
    accM1 % n == pow aM0 (b % pow2 (i - 1)) * accM0 * pow d (b % pow2 (i - 1)) % n)
  (ensures
   (let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM1, accM1) in
    accM2 % n == pow aM0 (b % pow2 i) * accM0 * pow d (b % pow2 i) % n))

let mod_exp_mont_lemma_step_acc n d bBits b i aM0 accM0 aM1 accM1 =
  let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM1, accM1) in
  if (b / pow2 (i - 1) % 2 = 1) then
    mod_exp_mont_lemma_step_acc1 n d bBits b i aM0 accM0 aM1 accM1
  else
    mod_exp_mont_lemma_step_acc0 n d bBits b i aM0 accM0 aM1 accM1


val mod_exp_mont_lemma:
    n:pos -> d:pos
  -> bBits:nat -> b:nat{b < pow2 bBits}
  -> i:nat{i <= bBits}
  -> aM0:nat -> accM0:nat ->
  Lemma
  (let aM1, accM1 = Loops.repeati i (mod_exp_f n d bBits b) (aM0, accM0) in
   accM1 % n == pow aM0 (b % pow2 i) * accM0 * pow d (b % pow2 i) % n /\
   aM1 % n == pow aM0 (pow2 i) * pow d (pow2 i - 1) % n)

let rec mod_exp_mont_lemma n d bBits b i aM0 accM0 =
  if i = 0 then begin
    Loops.eq_repeati0 i (mod_exp_f n d bBits b) (aM0, accM0);
    assert_norm (b % pow2 0 = 0);
    assert_norm (pow aM0 (b % pow2 0) = 1);
    assert_norm (pow d (b % pow2 0) = 1);
    assert_norm (pow d (pow2 0 - 1) = 1);
    assert_norm (pow aM0 (pow2 0) = aM0);
    () end
  else begin
    Loops.unfold_repeati i (mod_exp_f n d bBits b) (aM0, accM0) (i - 1);
    let aM1, accM1 = Loops.repeati (i - 1) (mod_exp_f n d bBits b) (aM0, accM0) in
    mod_exp_mont_lemma n d bBits b (i - 1) aM0 accM0;
    mod_exp_mont_lemma_step_a n d bBits b i aM0 accM0 aM1 accM1;
    mod_exp_mont_lemma_step_acc n d bBits b i aM0 accM0 aM1 accM1
  end

val lemma_mont_aux: n:pos -> r:pos -> d:pos{r * d % n == 1} -> a:nat -> Lemma
  (a * r % n * d % n == a % n)
let lemma_mont_aux n r d a =
  calc (==) {
    a * r % n * d % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l (a * r) d n }
    a * r * d % n;
    (==) { Math.Lemmas.paren_mul_right a r d; Math.Lemmas.lemma_mod_mul_distr_r a (r * d) n }
    a * (r * d % n) % n;
    (==) { assert (r * d % n == 1) }
    a % n;
  }


val mont_mod_exp_lemma_before_to_mont:
  n:pos -> r:pos -> d:pos{r * d % n == 1} -> bBits:nat -> b:pos{b < pow2 bBits} -> a:nat -> accM0:nat -> Lemma
  (pow (a * r % n) b * accM0 * pow d b % n == pow a b * accM0 % n)

let mont_mod_exp_lemma_before_to_mont n r d bBits b a accM0 =
  let aM0 = a * r % n in
  let (aM1, accM1) : tuple2 nat nat = Loops.repeati bBits (mod_exp_f n d bBits b) (aM0, accM0) in
  mod_exp_mont_lemma n d bBits b bBits aM0 accM0;
  Math.Lemmas.small_mod b (pow2 bBits);
  assert (accM1 % n == pow aM0 b * accM0 * pow d b % n);
  calc (==) {
    pow aM0 b * accM0 * pow d b % n;
    (==) { lemma_mul_ass3 (pow aM0 b) accM0 (pow d b) }
    pow aM0 b * pow d b * accM0 % n;
    (==) { lemma_pow_mul_base aM0 d b }
    pow (aM0 * d) b * accM0 % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l (pow (aM0 * d) b) accM0 n }
    pow (aM0 * d) b % n * accM0 % n;
    (==) { lemma_pow_mod_base (aM0 * d) b n }
    pow (aM0 * d % n) b % n * accM0 % n;
    (==) { lemma_mont_aux n r d a }
    pow (a % n) b % n * accM0 % n;
    (==) { lemma_pow_mod_base a b n }
    pow a b % n * accM0 % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l (pow a b) accM0 n }
    pow a b * accM0 % n;
  };
  assert (accM1 % n == pow a b * accM0 % n)


val mont_mod_exp_lemma_after_to_mont:
  n:pos -> r:pos -> d:pos{r * d % n == 1} -> bBits:nat -> b:pos{b < pow2 bBits} -> a:nat -> Lemma
  (pow a b * (1 * r % n) % n * d % n == pow a b % n)

let mont_mod_exp_lemma_after_to_mont n r d bBits b a =
  let accM0 = 1 * r % n in
  calc (==) {
    pow a b * accM0 % n * d % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l (pow a b * accM0) d n }
    pow a b * accM0 * d % n;
    (==) { Math.Lemmas.paren_mul_right (pow a b) accM0 d; Math.Lemmas.lemma_mod_mul_distr_r (pow a b) (accM0 * d) n }
    pow a b * (accM0 * d % n) % n;
    (==) { lemma_mont_aux n r d 1 }
    pow a b % n;
  }


val mod_exp_lemma: n:pos -> r:pos -> d:pos{r * d % n == 1} -> a:nat -> bBits:nat -> b:pos{b < pow2 bBits} -> Lemma
  (mod_exp_mont n r d a bBits b == pow a b % n)

let mod_exp_lemma n r d a bBits b =
  let open Lib.LoopCombinators in
  let aM0 = a * r % n in
  let accM0 = 1 * r % n in
  let (aM1, accM1) : tuple2 nat nat = repeati bBits (mod_exp_f n d bBits b) (aM0, accM0) in
  mod_exp_mont_lemma n d bBits b bBits aM0 accM0;
  Math.Lemmas.small_mod b (pow2 bBits);
  assert (accM1 % n == pow aM0 b * accM0 * pow d b % n);
  mont_mod_exp_lemma_before_to_mont n r d bBits b a accM0;
  assert (accM1 % n == pow a b * accM0 % n);
  let res = accM1 * d % n in
  calc (==) {
    accM1 * d % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l accM1 d n }
    accM1 % n * d % n;
    (==) { mont_mod_exp_lemma_after_to_mont n r d bBits b a }
    pow a b % n;
  };
  assert (accM1 * d % n == pow a b % n)


// val mod_exp_lemma_s: n:pos -> r:pos -> d:pos{r * d % n == 1} -> a:nat{a < n} -> bBits:nat -> b:pos{b < pow2 bBits} -> Lemma
//   (mod_exp_mont n r d a bBits b == S.fpow #n a b)

// let mod_exp_lemma_s n r d a bBits b =
//   mod_exp_lemma n r d a bBits b;
//   lemma_pow_mod_n_is_fpow n a b


val mod_exp_f_ll: rLen:nat -> n:pos -> mu:nat -> bBits:nat -> b:nat{b < pow2 bBits} -> i:nat{i < bBits} -> tuple2 nat nat -> tuple2 nat nat
let mod_exp_f_ll rLen n mu bBits b i (aM, accM) =
  let accM = if (b / pow2 i % 2 = 1) then M.mont_mul rLen n mu accM aM else accM in
  let aM = M.mont_mul rLen n mu aM aM in
  (aM, accM)

val mod_exp_mont_ll: rLen:nat -> n:pos -> mu:nat -> a:nat -> bBits:nat -> b:pos{b < pow2 bBits} -> res:nat
let mod_exp_mont_ll rLen n mu a bBits b =
  let aM = M.to_mont rLen n mu a in
  let accM = M.to_mont rLen n mu 1 in
  let (aM, accM) = Loops.repeati bBits (mod_exp_f_ll rLen n mu bBits b) (aM, accM) in
  let acc = M.from_mont rLen n mu accM in
  acc


val mod_exp_mont_ll_lemma_loop_step_a:
    rLen:nat -> n:pos -> d:nat -> mu:nat -> bBits:nat -> b:pos{b < pow2 bBits}
  -> i:pos{i <= bBits}
  -> aM3:nat -> accM3:nat
  -> aM4:nat -> accM4:nat -> Lemma
  (requires
    (1 + n * mu) % pow2 64 == 0 /\ pow2 (64 * rLen) * d % n == 1 /\
    aM3 % n == aM4 % n)
  (ensures
    (let (aM1, accM1) = mod_exp_f_ll rLen n mu bBits b (i - 1) (aM3, accM3) in
     let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM4, accM4) in
     aM1 % n == aM2 % n))

let mod_exp_mont_ll_lemma_loop_step_a rLen n d mu bBits b i aM3 accM3 aM4 accM4 =
  let (aM1, accM1) = mod_exp_f_ll rLen n mu bBits b (i - 1) (aM3, accM3) in
  let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM4, accM4) in
  calc (==) {
    aM1 % n;
    (==) { }
    M.mont_mul rLen n mu aM3 aM3 % n;
    (==) { M.mont_reduction_lemma rLen n d mu (aM3 * aM3) }
    aM3 * aM3 * d % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l (aM3 * aM3) d n }
    aM3 * aM3 % n * d % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l aM3 aM3 n }
    aM4 % n * aM3 % n * d % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l aM4 aM3 n }
    aM4 * aM3 % n * d % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_r aM4 aM3 n }
    aM4 * (aM4 % n) % n * d % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_r aM4 aM4 n }
    aM4 * aM4 % n * d % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l (aM4 * aM4) d n }
    aM4 * aM4 * d % n;
    (==) { Math.Lemmas.lemma_mod_mod aM2 (aM4 * aM4 * d) n }
    aM2 % n;
  };
  assert (aM1 % n == aM2 % n)


val mod_exp_mont_ll_lemma_loop_step_acc:
    rLen:nat -> n:pos -> d:nat -> mu:nat -> bBits:nat -> b:pos{b < pow2 bBits}
  -> i:pos{i <= bBits}
  -> aM3:nat -> accM3:nat
  -> aM4:nat -> accM4:nat -> Lemma
  (requires
    (1 + n * mu) % pow2 64 == 0 /\ pow2 (64 * rLen) * d % n == 1 /\
    aM3 % n == aM4 % n /\ accM3 % n == accM4 % n)
  (ensures
    (let (aM1, accM1) = mod_exp_f_ll rLen n mu bBits b (i - 1) (aM3, accM3) in
     let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM4, accM4) in
     accM1 % n == accM2 % n))

let mod_exp_mont_ll_lemma_loop_step_acc rLen n d mu bBits b i aM3 accM3 aM4 accM4 =
  let (aM1, accM1) = mod_exp_f_ll rLen n mu bBits b (i - 1) (aM3, accM3) in
  let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM4, accM4) in
  if (b / pow2 (i - 1) % 2 = 1) then begin
    calc (==) {
      accM1 % n;
      (==) { }
      M.mont_mul rLen n mu accM3 aM3 % n;
      (==) { M.mont_reduction_lemma rLen n d mu (accM3 * aM3) }
      accM3 * aM3 * d % n;
      (==) { Math.Lemmas.lemma_mod_mul_distr_l (accM3 * aM3) d n }
      accM3 * aM3 % n * d % n;
      (==) { Math.Lemmas.lemma_mod_mul_distr_l accM3 aM3 n }
      accM4 % n * aM3 % n * d % n;
      (==) { Math.Lemmas.lemma_mod_mul_distr_l accM4 aM3 n }
      accM4 * aM3 % n * d % n;
      (==) { Math.Lemmas.lemma_mod_mul_distr_r accM4 aM3 n }
      accM4 * (aM4 % n) % n * d % n;
      (==) { Math.Lemmas.lemma_mod_mul_distr_r accM4 aM4 n }
      accM4 * aM4 % n * d % n;
      (==) { Math.Lemmas.lemma_mod_mul_distr_l (accM4 * aM4) d n }
      accM4 * aM4 * d % n;
      (==) { Math.Lemmas.lemma_mod_mod accM2 (accM4 * aM4 * d) n }
      accM2 % n;
    };
    assert (accM1 % n == accM2 % n) end
  else ()


val mod_exp_mont_ll_lemma_loop_step:
    rLen:nat -> n:pos -> d:nat -> mu:nat -> bBits:nat -> b:pos{b < pow2 bBits}
  -> i:pos{i <= bBits}
  -> aM3:nat -> accM3:nat
  -> aM4:nat -> accM4:nat -> Lemma
  (requires
    (1 + n * mu) % pow2 64 == 0 /\ pow2 (64 * rLen) * d % n == 1 /\
    aM3 % n == aM4 % n /\ accM3 % n == accM4 % n)
  (ensures
    (let (aM1, accM1) = mod_exp_f_ll rLen n mu bBits b (i - 1) (aM3, accM3) in
     let (aM2, accM2) = mod_exp_f n d bBits b (i - 1) (aM4, accM4) in
     aM1 % n == aM2 % n /\ accM1 % n == accM2 % n))

let mod_exp_mont_ll_lemma_loop_step rLen n d mu bBits b i aM3 accM3 aM4 accM4 =
  mod_exp_mont_ll_lemma_loop_step_acc rLen n d mu bBits b i aM3 accM3 aM4 accM4;
  mod_exp_mont_ll_lemma_loop_step_a rLen n d mu bBits b i aM3 accM3 aM4 accM4


val mod_exp_mont_ll_lemma_loop:
  rLen:nat -> n:pos -> d:nat -> mu:nat -> bBits:nat -> b:pos{b < pow2 bBits} -> i:nat{i <= bBits} -> aM0:nat -> accM0:nat -> Lemma
  (requires (1 + n * mu) % pow2 64 == 0 /\ pow2 (64 * rLen) * d % n == 1)
  (ensures
    (let aM1, accM1 = Loops.repeati i (mod_exp_f_ll rLen n mu bBits b) (aM0, accM0) in
     let aM2, accM2 = Loops.repeati i (mod_exp_f n d bBits b) (aM0, accM0) in
     aM1 % n == aM2 % n /\ accM1 % n == accM2 % n))

let rec mod_exp_mont_ll_lemma_loop rLen n d mu bBits b i aM0 accM0 =
  let aM1, accM1 = Loops.repeati i (mod_exp_f_ll rLen n mu bBits b) (aM0, accM0) in
  let aM2, accM2 = Loops.repeati i (mod_exp_f n d bBits b) (aM0, accM0) in
  if i = 0 then begin
    Loops.eq_repeati0 i (mod_exp_f n d bBits b) (aM0, accM0);
    Loops.eq_repeati0 i (mod_exp_f_ll rLen n mu bBits b) (aM0, accM0);
    () end
  else begin
    let aM3, accM3 = Loops.repeati (i - 1) (mod_exp_f_ll rLen n mu bBits b) (aM0, accM0) in
    let aM4, accM4 = Loops.repeati (i - 1) (mod_exp_f n d bBits b) (aM0, accM0) in
    Loops.unfold_repeati i (mod_exp_f n d bBits b) (aM0, accM0) (i - 1);
    Loops.unfold_repeati i (mod_exp_f_ll rLen n mu bBits b) (aM0, accM0) (i - 1);
    assert ((aM1, accM1) == mod_exp_f_ll rLen n mu bBits b (i - 1) (aM3, accM3));
    assert ((aM2, accM2) == mod_exp_f n d bBits b (i - 1) (aM4, accM4));
    mod_exp_mont_ll_lemma_loop rLen n d mu bBits b (i - 1) aM0 accM0;
    assert (aM3 % n == aM4 % n /\ accM3 % n == accM4 % n);
    mod_exp_mont_ll_lemma_loop_step rLen n d mu bBits b i aM3 accM3 aM4 accM4;
    assert (aM1 % n == aM2 % n /\ accM1 % n == accM2 % n);
    () end


val mod_exp_mont_ll_lemma: rLen:nat -> n:pos -> d:nat -> mu:nat -> a:nat -> bBits:nat -> b:pos{b < pow2 bBits} -> Lemma
  (requires (1 + n * mu) % pow2 64 == 0 /\ pow2 (64 * rLen) * d % n == 1)
  (ensures  mod_exp_mont_ll rLen n mu a bBits b % n == pow a b % n)

let mod_exp_mont_ll_lemma rLen n d mu a bBits b =
  let r = pow2 (64 * rLen) in
  let aM0 = M.to_mont rLen n mu a in
  let accM0 = M.to_mont rLen n mu 1 in
  let (aM1, accM1) : tuple2 nat nat = Loops.repeati bBits (mod_exp_f_ll rLen n mu bBits b) (aM0, accM0) in
  mod_exp_mont_ll_lemma_loop rLen n d mu bBits b bBits aM0 accM0;

  mod_exp_mont_lemma n d bBits b bBits aM0 accM0;
  Math.Lemmas.small_mod b (pow2 bBits);
  assert (accM1 % n == pow aM0 b * accM0 * pow d b % n);
  calc (==) {
    pow aM0 b * accM0 * pow d b % n;
    (==) { Math.Lemmas.paren_mul_right (pow aM0 b) accM0 (pow d b) }
    pow aM0 b * (accM0 * pow d b) % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l (pow aM0 b) (accM0 * pow d b) n }
    pow aM0 b % n * (accM0 * pow d b) % n;
    (==) { lemma_pow_mod_base aM0 b n }
    pow (aM0 % n) b % n * (accM0 * pow d b) % n;
    (==) { M.to_mont_lemma rLen n d mu a }
    pow (a * r % n) b % n * (accM0 * pow d b) % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l (pow (a * r % n) b) (accM0 * pow d b) n }
    pow (a * r % n) b * (accM0 * pow d b) % n;
    (==) { Math.Lemmas.paren_mul_right (pow (a * r % n) b) accM0 (pow d b) }
    pow (a * r % n) b * accM0 * pow d b % n;
    (==) { mont_mod_exp_lemma_before_to_mont n r d bBits b a accM0 }
    pow a b * accM0 % n;
  };
  assert (accM1 % n == pow a b * accM0 % n);
  let res = M.from_mont rLen n mu accM1 in
  M.from_mont_lemma rLen n d mu accM1;
  assert (res % n == accM1 * d % n);
  calc (==) {
    accM1 * d % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l accM1 d n }
    accM1 % n * d % n;
    (==) { assert (accM1 % n == pow a b * accM0 % n) }
    pow a b * accM0 % n * d % n;
    (==) { Math.Lemmas.lemma_mod_mul_distr_r (pow a b) accM0 n }
    pow a b * (accM0 % n) % n * d % n;
    (==) { M.to_mont_lemma rLen n d mu 1 }
    pow a b * (1 * r % n) % n * d % n;
    (==) { mont_mod_exp_lemma_after_to_mont n r d bBits b a }
    pow a b % n;
  };
  assert (accM1 * d % n == pow a b % n)


val mod_exp_mont_ll_lemma_fits_loop:
  rLen:nat -> n:pos -> d:nat -> mu:nat -> bBits:nat -> b:pos{b < pow2 bBits} -> i:nat{i <= bBits} -> aM0:nat -> accM0:nat -> Lemma
  (requires
    (1 + n * mu) % pow2 64 == 0 /\ pow2 (64 * rLen) * d % n == 1 /\
    4 * n < pow2 (64 * rLen) /\ aM0 < 2 * n /\ accM0 < 2 * n)
  (ensures
    (let (aM1, accM1) = Loops.repeati i (mod_exp_f_ll rLen n mu bBits b) (aM0, accM0) in
    aM1 < 2 * n /\ accM1 < 2 * n))

let rec mod_exp_mont_ll_lemma_fits_loop rLen n d mu bBits b i aM0 accM0 =
  let (aM1, accM1) = Loops.repeati i (mod_exp_f_ll rLen n mu bBits b) (aM0, accM0) in
  if i = 0 then begin
    Loops.eq_repeati0 i (mod_exp_f_ll rLen n mu bBits b) (aM0, accM0);
    () end
  else begin
    Loops.unfold_repeati i (mod_exp_f_ll rLen n mu bBits b) (aM0, accM0) (i - 1);
    let (aM2, accM2) = Loops.repeati (i - 1) (mod_exp_f_ll rLen n mu bBits b) (aM0, accM0) in
    //assert ((aM1, accM1) == mod_exp_f_ll rLen n mu bBits b (i - 1) (aM2, accM2));
    mod_exp_mont_ll_lemma_fits_loop rLen n d mu bBits b (i - 1) aM0 accM0;
    //assert (aM2 < 2 * n /\ accM2 < 2 * n);
    //assert (aM1 == M.mont_mul rLen n mu aM2 aM2);
    M.mont_mul_lemma_fits rLen n d mu aM2 aM2;
    assert (aM1 < 2 * n);

    if (b / pow2 (i - 1) % 2 = 1) then begin
      M.mont_mul_lemma_fits rLen n d mu accM2 aM2;
      assert (accM1 < 2 * n) end
    else assert (accM1 < 2 * n);
    () end


val mod_exp_mont_ll_lemma_fits:
  rLen:nat -> n:pos -> d:nat -> mu:nat -> a:nat -> bBits:nat -> b:pos{b < pow2 bBits} -> Lemma
  (requires
    (1 + n * mu) % pow2 64 == 0 /\ pow2 (64 * rLen) * d % n == 1 /\
    4 * n < pow2 (64 * rLen) /\ a < n)
  (ensures  mod_exp_mont_ll rLen n mu a bBits b <= n)

let mod_exp_mont_ll_lemma_fits rLen n d mu a bBits b =
  let r = pow2 (64 * rLen) in
  let aM0 = M.to_mont rLen n mu a in
  let accM0 = M.to_mont rLen n mu 1 in
  M.to_mont_lemma_fits rLen n d mu a;
  M.to_mont_lemma_fits rLen n d mu 1;
  assert (aM0 < 2 * n);
  assert (accM0 < 2 * n);
  let (aM1, accM1) : tuple2 nat nat = Loops.repeati bBits (mod_exp_f_ll rLen n mu bBits b) (aM0, accM0) in
  mod_exp_mont_ll_lemma_fits_loop rLen n d mu bBits b bBits aM0 accM0;
  assert (aM1 < 2 * n /\ accM1 < 2 * n);
  let res = M.from_mont rLen n mu accM1 in
  M.from_mont_lemma_fits rLen n d mu accM1;
  assert (res <= n)

///
///  Lemma (mod_exp_mont_ll_final_sub rLen n mu a bBits b == S.fpow #n a b)
///

val mod_exp_mont_ll_final_sub: rLen:nat -> n:pos -> mu:nat -> a:nat -> bBits:nat -> b:pos{b < pow2 bBits} -> res:nat
let mod_exp_mont_ll_final_sub rLen n mu a bBits b =
  let res = mod_exp_mont_ll rLen n mu a bBits b in
  if res = n then 0 else res


val mod_exp_mont_ll_lemma_eq:
  rLen:nat -> n:pos -> d:nat -> mu:nat -> a:nat -> bBits:nat -> b:pos{b < pow2 bBits} -> Lemma
  (requires
    (1 + n * mu) % pow2 64 == 0 /\ pow2 (64 * rLen) * d % n == 1 /\
    4 * n < pow2 (64 * rLen) /\ a < n)
  (ensures  mod_exp_mont_ll_final_sub rLen n mu a bBits b == S.fpow #n a b)

let mod_exp_mont_ll_lemma_eq rLen n d mu a bBits b =
  let res1 = mod_exp_mont_ll_final_sub rLen n mu a bBits b in
  let res = mod_exp_mont_ll rLen n mu a bBits b in
  calc (==) {
    res % n;
    (==) { mod_exp_mont_ll_lemma rLen n d mu a bBits b }
    pow a b % n;
    (==) { lemma_pow_mod_n_is_fpow n a b }
    S.fpow #n a b;
  };
  assert (res % n == S.fpow #n a b);
  if res = n then begin
    assert (res1 = 0);
    Math.Lemmas.cancel_mul_mod 1 n end
  else begin
    assert (res1 == res);
    mod_exp_mont_ll_lemma_fits rLen n d mu a bBits b;
    assert (res < n);
    Math.Lemmas.small_mod res n;
    () end


val eea_pow2_odd: a:nat -> n:pos ->
  Pure (tuple2 nat nat)
  (requires n % 2 = 1)
  (ensures  fun (d, k) -> pow2 a * d == 1 + k * n)
let eea_pow2_odd a n = admit()


val mod_exp_mont_preconditions:
  rLen:nat -> n:pos{n > 1} -> mu:nat -> Lemma
  (requires (1 + (n % pow2 64) * mu) % pow2 64 == 0 /\ n % 2 = 1)
  (ensures  (let d, k = eea_pow2_odd (64 * rLen) n in (1 + n * mu) % pow2 64 == 0 /\ pow2 (64 * rLen) * d % n == 1))

let mod_exp_mont_preconditions rLen n mu =
  calc (==) {
    (1 + n * mu) % pow2 64;
    (==) { Math.Lemmas.lemma_mod_plus_distr_r 1 (n * mu) (pow2 64) }
    (1 + n * mu % pow2 64) % pow2 64;
    (==) { Math.Lemmas.lemma_mod_mul_distr_l n mu (pow2 64) }
    (1 + n % pow2 64 * mu % pow2 64) % pow2 64;
    (==) { Math.Lemmas.lemma_mod_plus_distr_r 1 (n % pow2 64 * mu) (pow2 64) }
    (1 + n % pow2 64 * mu) % pow2 64;
    (==) { assert ((1 + (n % pow2 64) * mu) % pow2 64 == 0) }
    0;
  };
  assert ((1 + n * mu) % pow2 64 == 0);

  let d, k = eea_pow2_odd (64 * rLen) n in
  calc (==) {
    pow2 (64 * rLen) * d % n;
    (==) { }
    (1 + k * n) % n;
    (==) { Math.Lemmas.modulo_addition_lemma 1 n k }
    1 % n;
    (==) { Math.Lemmas.small_mod 1 n }
    1;
  };
  assert (pow2 (64 * rLen) * d % n == 1)


val mod_exp_mont_ll_lemma_eq_simplify:
  rLen:nat -> n:pos{n > 1} -> mu:nat -> a:nat -> bBits:nat -> b:pos{b < pow2 bBits} -> Lemma
  (requires (1 + (n % pow2 64) * mu) % pow2 64 == 0 /\ 4 * n < pow2 (64 * rLen) /\ a < n /\ n % 2 = 1)
  (ensures  mod_exp_mont_ll_final_sub rLen n mu a bBits b == S.fpow #n a b)

let mod_exp_mont_ll_lemma_eq_simplify rLen n mu a bBits b =
  let d, k = eea_pow2_odd (64 * rLen) n in
  mod_exp_mont_preconditions rLen n mu;
  mod_exp_mont_ll_lemma_eq rLen n d mu a bBits b


val mod_exp_mont_preconditions_rLen: nLen:nat -> n:pos{n < pow2 (64 * nLen)} -> Lemma (4 * n < pow2 (64 * (nLen + 1)))
let mod_exp_mont_preconditions_rLen nLen n =
  calc (<) {
    4 * n;
    (<) { Math.Lemmas.lemma_mult_lt_left 4 n (pow2 (64 * nLen)) }
    4 * pow2 (64 * nLen);
    (==) { assert_norm (pow2 2 = 4) }
    pow2 2 * pow2 (64 * nLen);
    (==) { Math.Lemmas.pow2_plus 2 (64 * nLen) }
    pow2 (2 + 64 * nLen);
    (<) { Math.Lemmas.pow2_lt_compat (64 + 64 * nLen) (2 + 64 * nLen) }
    pow2 (64 + 64 * nLen);
    (==) { Math.Lemmas.distributivity_add_right 64 1 nLen }
    pow2 (64 * (nLen + 1));
  };
  assert (4 * n < pow2 (64 * (nLen + 1)))
