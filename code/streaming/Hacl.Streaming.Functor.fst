module Hacl.Streaming.Functor

/// Provided an instance of the type class, this creates a streaming API on top.
/// This means that every function in this module takes two extra arguments
/// compared to the previous streaming module specialized for hashes: the type
/// of the index, and a type class for that index. Then, as usual, a given value
/// for the index as a parameter.

#set-options "--max_fuel 0 --max_ifuel 0"

module ST = FStar.HyperStack.ST
module HS = FStar.HyperStack
module B = LowStar.Buffer
module G = FStar.Ghost
module S = FStar.Seq
module U32 = FStar.UInt32
module U64 = FStar.UInt64

open Hacl.Streaming.Interface
open FStar.HyperStack.ST
open LowStar.BufferOps
open FStar.Mul

inline_for_extraction noextract
let uint8 = Lib.IntTypes.uint8

inline_for_extraction noextract
let uint32 = Lib.IntTypes.uint32

/// State machinery
/// ===============

noeq
type state_s #index (c: block index) (i: index) =
| State:
    block_state: c.state i ->
    buf: B.buffer Lib.IntTypes.uint8 { B.len buf = c.block_len i } ->
    total_len: UInt64.t ->
    seen: G.erased (S.seq uint8) ->
    state_s #index c i

// TODO: move to fsti
let state #index (c: block index) (i: index) = B.pointer (state_s c i)

let freeable #index (c: block index) (i: index) (h: HS.mem) (p: state c i) =
  B.freeable p /\ (
  let s = B.deref h p in
  let State hash_state buf _ _ = s in
  B.freeable buf /\ c.freeable h hash_state)

let preserves_freeable #index (c: block index) (i: index) (s: state c i) (h0 h1: HS.mem): Type0 =
  freeable c i h0 s ==> freeable c i h1 s

let footprint_s #index (c: block index) (i: index) (h: HS.mem) (s: state_s c i) =
  let State block_state buf_ _ _ = s in
  B.(loc_union (loc_addr_of_buffer buf_) (c.footprint h block_state))

// TODO: move to fsti
let footprint #index (c: block index) (i: index) (m: HS.mem) (s: state c i) =
  B.(loc_union (loc_addr_of_buffer s) (footprint_s c i m (B.deref m s)))

/// Invariants
/// ==========

noextract
let bytes = S.seq uint8

noextract
let split_at_last #index (c: block index) (i: index) (b: bytes):
  Pure (bytes & bytes)
    (requires True)
    (ensures (fun (blocks, rest) ->
      S.length rest < U32.v (c.block_len i) /\
      S.length rest = S.length b % U32.v (c.block_len i) /\
      S.equal (S.append blocks rest) b /\
      S.length blocks % U32.v (c.block_len i) = 0))
=
  let n = S.length b / U32.v (c.block_len i) in
  let blocks, rest = S.split b (n * U32.v (c.block_len i)) in
  assert (S.length blocks = n * U32.v (c.block_len i));
  FStar.Math.Lemmas.multiple_modulo_lemma n (U32.v (c.block_len i));
  assert ((n * U32.v (c.block_len i)) % U32.v (c.block_len i) = 0);
  assert (S.length rest = S.length b - n * U32.v (c.block_len i));
  assert (S.length b - n * U32.v (c.block_len i) < U32.v (c.block_len i));
  blocks, rest

let loc_includes_union_l_footprint_s
  #index
  (c: block index)
  (i: index)
  (m: HS.mem)
  (l1 l2: B.loc) (s: state_s c i)
: Lemma
  (requires (
    B.loc_includes l1 (footprint_s c i m s) \/ B.loc_includes l2 (footprint_s c i m s)
  ))
  (ensures (B.loc_includes (B.loc_union l1 l2) (footprint_s c i m s)))
  [SMTPat (B.loc_includes (B.loc_union l1 l2) (footprint_s c i m s))]
= B.loc_includes_union_l l1 l2 (footprint_s c i m s)

let invariant_s #index (c: block index) (i: index) h (s: state_s c i) =
  let State hash_state buf_ total_len seen = s in
  let seen = G.reveal seen in
  let blocks, rest = split_at_last c i seen in

  // Liveness and disjointness (administrative)
  B.live h buf_ /\ c.invariant #i h hash_state /\
  B.(loc_disjoint (loc_buffer buf_) (c.footprint h hash_state)) /\

  // Formerly, the "hashes" predicate
  S.length blocks + S.length rest = U64.v total_len /\
  S.length seen = U64.v total_len /\
  U64.v total_len < c.max_input_length i /\
  // Note the double equals here, we now no longer know that this is a sequence.
  c.v h hash_state == c.update_multi_s i (c.init_s i) blocks /\
  S.equal (S.slice (B.as_seq h buf_) 0 (U64.v total_len % U32.v (c.block_len i))) rest

let invariant #index (c: block index) (i: index) (m: HS.mem) (s: state c i) =
  B.live m s /\
  B.(loc_disjoint (loc_addr_of_buffer s) (footprint_s c i m (B.deref m s))) /\
  invariant_s c i m (B.get m s 0)

val invariant_loc_in_footprint
  (#index: Type0)
  (c: block index)
  (i: index)
  (s: state c i)
  (m: HS.mem)
: Lemma
  (requires (invariant c i m s))
  (ensures (B.loc_in (footprint c i m s) m))
  [SMTPat (invariant c i m s)]


#push-options "--max_ifuel 1"
let invariant_loc_in_footprint #index c i s m =
  let aux (h:HS.mem) (s:c.state i): Lemma
    (requires (c.invariant h s))
    (ensures (B.loc_in (c.footprint #i h s) h))
    [SMTPat (c.invariant h s)]
  =
    c.invariant_loc_in_footprint #i h s
  in
  ()
#pop-options

// TODO: move to fsti
val seen: #index:Type0 -> c:block index -> i:index -> h:HS.mem -> s:state c i -> GTot bytes
let seen #index c i h s =
  G.reveal (State?.seen (B.deref h s))

val frame_invariant: #index:Type0 -> c:block index -> i:index -> l:B.loc -> s:state c i -> h0:HS.mem -> h1:HS.mem -> Lemma
  (requires (
    invariant c i h0 s /\
    B.loc_disjoint l (footprint c i h0 s) /\
    B.modifies l h0 h1))
  (ensures (
    invariant c i h1 s /\
    footprint c i h0 s == footprint c i h1 s))
  [ SMTPat (invariant c i h1 s); SMTPat (B.modifies l h0 h1) ]

let frame_invariant #index c i l s h0 h1 =
  let state_s = B.deref h0 s in
  let State block_state _ _ _ = state_s in
  c.frame_invariant #i l block_state h0 h1

val frame_seen: #index:Type0 -> c:block index -> i:index -> l:B.loc -> s:state c i -> h0:HS.mem -> h1:HS.mem -> Lemma
  (requires (
    invariant c i h0 s /\
    B.loc_disjoint l (footprint c i h0 s) /\
    B.modifies l h0 h1))
  (ensures (seen c i h0 s == seen c i h1 s))
  [ SMTPat (seen c i h1 s); SMTPat (B.modifies l h0 h1) ]

let frame_seen #_ _ _ _ _ _ _ =
  ()

val frame_freeable: #index:Type0 -> c:block index -> i:index -> l:B.loc -> s:state c i -> h0:HS.mem -> h1:HS.mem -> Lemma
  (requires (
    invariant c i h0 s /\
    freeable c i h0 s /\
    B.loc_disjoint l (footprint c i h0 s) /\
    B.modifies l h0 h1))
  (ensures (freeable c i h1 s))
  [ SMTPat (freeable c i h1 s); SMTPat (B.modifies l h0 h1) ]

let frame_freeable #index c i l s h0 h1 =
  let State block_state _ _ _ = B.deref h0 s in
  c.frame_freeable #i l block_state h0 h1

val create_in (#index: Type0) (c: block index) (i: index) (r: HS.rid): ST (state c i)
  (requires (fun _ ->
    HyperStack.ST.is_eternal_region r))
  (ensures (fun h0 s h1 ->
    invariant c i h1 s /\
    seen c i h1 s == S.empty /\
    B.(modifies loc_none h0 h1) /\
    B.fresh_loc (footprint c i h1 s) h0 h1 /\
    B.(loc_includes (loc_region_only true r) (footprint c i h1 s)) /\
    freeable c i h1 s))

let split_at_last_empty #index (c: block index) (i: index): Lemma
  (ensures (
    let blocks, rest = split_at_last c i S.empty in
    S.equal blocks S.empty /\ S.equal rest S.empty))
=
  ()

#push-options "--using_facts_from '*,-LowStar.Monotonic.Buffer.unused_in_not_unused_in_disjoint_2'"
let create_in #index c i r =
  let aux (h:HS.mem) (s:c.state i): Lemma
    (requires (c.invariant h s))
    (ensures (B.loc_in (c.footprint #i h s) h))
    [SMTPat (c.invariant h s)]
  =
    c.invariant_loc_in_footprint #i h s
  in

  (**) let h0 = ST.get () in

  (**) B.loc_unused_in_not_unused_in_disjoint h0;
  let buf = B.malloc r (Lib.IntTypes.u8 0) (c.block_len i) in
  (**) let h1 = ST.get () in
  (**) assert (B.fresh_loc (B.loc_buffer buf) h0 h1);
  (**) B.loc_unused_in_not_unused_in_disjoint h1;

  let hash_state = c.create_in i r in
  (**) let h2 = ST.get () in
  (**) assert (B.fresh_loc (c.footprint #i h2 hash_state) h0 h2);

  let s = State hash_state buf 0UL (G.hide S.empty) in
  (**) assert (B.fresh_loc (footprint_s c i h2 s) h0 h2);

  (**) B.loc_unused_in_not_unused_in_disjoint h2;
  let p = B.malloc r s 1ul in
  (**) let h3 = ST.get () in
  (**) c.frame_invariant B.loc_none hash_state h2 h3;
  (**) B.(modifies_only_not_unused_in loc_none h2 h3);
  (**) assert (B.fresh_loc (B.loc_addr_of_buffer p) h0 h3);
  (**) assert (B.fresh_loc (footprint_s c i h3 s) h0 h3);
  (**) c.frame_freeable B.loc_none hash_state h2 h3;
  (**) assert (freeable c i h3 p);

  c.init (G.hide i) hash_state;
  (**) let h4 = ST.get () in
  (**) assert (B.fresh_loc (c.footprint #i h4 hash_state) h0 h4);
  (**) assert (B.fresh_loc (B.loc_buffer buf) h0 h4);
  (**) c.update_multi_zero i (c.v h4 hash_state);
  (**) split_at_last_empty c i;
  (**) B.modifies_only_not_unused_in B.loc_none h0 h4;

  (**) let h5 = ST.get () in
  (**) assert (
    let h = h5 in
    let s = (B.get h5 p 0) in
    let State hash_state buf_ total_len seen = s in
    let seen = G.reveal seen in
    let blocks, rest = split_at_last c i seen in
    // JP: unclear why I need to assert this... but without it the proof doesn't
    // go through.
    U64.v total_len < c.max_input_length i /\
    True
  );
  (**) assert (invariant c i h5 p);
  (**) assert (seen c i h5 p == S.empty);
  (**) assert B.(modifies loc_none h0 h5);
  (**) assert (B.fresh_loc (footprint c i h5 p) h0 h5);
  (**) assert B.(loc_includes (loc_region_only true r) (footprint c i h5 p));
  (**) assert (freeable c i h5 p);

  (**) assert (ST.equal_stack_domains h1 h5);
  (**) assert (ST.equal_stack_domains h0 h1);

  p
#pop-options

val init: #index:Type0 -> c:block index -> i:G.erased index -> (
  let i = G.reveal i in
  s:state c i -> Stack unit
  (requires (fun h0 ->
    invariant c i h0 s))
  (ensures (fun h0 _ h1 ->
    preserves_freeable c i s h0 h1 /\
    invariant c i h1 s /\
    seen c i h1 s == S.empty /\
    footprint c i h0 s == footprint c i h1 s /\
    B.(modifies (footprint c i h0 s) h0 h1))))

let init #index c i s =
  let aux (h:HS.mem) (s:c.state i): Lemma
    (requires (c.invariant h s))
    (ensures (B.loc_in (c.footprint #i h s) h))
    [SMTPat (c.invariant h s)]
  =
    c.invariant_loc_in_footprint #i h s
  in
  let aux l s h0 h1: Lemma
    (requires
      c.invariant h0 s /\
      c.freeable h0 s /\
      B.loc_disjoint l (c.footprint #i h0 s) /\
      B.modifies l h0 h1)
    (ensures (
      c.freeable h1 s))
    [ SMTPat (c.freeable h1 s); SMTPat (B.modifies l h0 h1) ]
  =
    c.frame_freeable #i l s h0 h1
  in

  let open LowStar.BufferOps in
  let h1 = ST.get () in
  let State hash_state buf _ _ = !*s in
  // JP: figuring out the alg at run-time is useful, but entails a lot more
  // proof difficulty; note the let-binding below, as well as the fact that
  // implicit argument resolution basically no longer works after this...
  let i = c.index_of_state i hash_state in
  [@inline_let]
  let hash_state: c.state i = hash_state in

  c.init (G.hide i) hash_state;
  let h2 = ST.get () in
  c.update_multi_zero i (c.v h2 hash_state);
  split_at_last_empty c i;

  B.upd s 0ul (State hash_state buf 0UL (G.hide S.empty));
  let h3 = ST.get () in
  c.frame_invariant B.(loc_buffer s) hash_state h2 h3;

  // This seems to cause insurmountable difficulties. Puzzled.
  ST.lemma_equal_domains_trans h1 h2 h3;

  // AR: 07/22: same old `Seq.equal` and `==` story
  assert (Seq.equal (seen c i h3 s) Seq.empty);

  assert (preserves_freeable c i s h1 h3);
  //assert (hashed h3 s == S.empty);
  assert (footprint c i h1 s == footprint c i h3 s);
  assert (B.(modifies (footprint c i h1 s) h1 h3));
  //assert (B.live h3 s);
  //assert (B.(loc_disjoint (loc_addr_of_buffer s) (footprint_s h3 (B.deref h3 s))));
  assert (
    let h = h3 in
    let s = B.get h3 s 0 in
    let State hash_state buf_ total_len seen = s in
    let seen = G.reveal seen in
    let blocks, rest = split_at_last c i seen in

    // Liveness and disjointness (administrative)
    B.live h buf_ /\ c.invariant #i h hash_state /\
    B.(loc_disjoint (loc_buffer buf_) (c.footprint h hash_state)) /\

    // Formerly, the "hashes" predicate
    S.length blocks + S.length rest = U64.v total_len /\
    S.length seen = U64.v total_len /\
    U64.v total_len < c.max_input_length i /\
    // Note the double equals here, we now no longer know that this is a sequence.
    c.v h hash_state == c.update_multi_s i (c.init_s i) blocks /\
    S.equal (S.slice (B.as_seq h buf_) 0 (U64.v total_len % U32.v (c.block_len i))) rest
  );
  assert (invariant_s c i h3 (B.get h3 s 0))

unfold
let update_pre
  #index
  (c: block index)
  (i: index)
  (s: state c i)
  (data: B.buffer uint8)
  (len: UInt32.t)
  (h0: HS.mem)
=
  invariant c i h0 s /\
  B.live h0 data /\
  U32.v len = B.length data /\
  S.length (seen c i h0 s) + U32.v len < c.max_input_length i /\
  B.(loc_disjoint (loc_buffer data) (footprint c i h0 s))

unfold
let update_post
  #index
  (c: block index)
  (i: index)
  (s: state c i)
  (data: B.buffer uint8)
  (len: UInt32.t)
  (h0 h1: HS.mem)
=
  preserves_freeable c i s h0 h1 /\
  invariant c i h1 s /\
  B.(modifies (footprint c i h0 s) h0 h1) /\
  footprint c i h0 s == footprint c i h1 s /\
  seen c i h1 s == seen c i h0 s `S.append` B.as_seq h0 data

/// We keep the total length at run-time, on 64 bits, but require that it abides
/// by the size requirements for the smaller hashes -- we're not interested at
/// this stage in having an agile type for lengths that would be up to 2^125 for
/// SHA384/512.

#push-options "--z3cliopt smt.arith.nl=false"
let mod_block_len_bound #index (c: block index) (i: index)
  (total_len: U64.t): Lemma
  (requires True)
  (ensures U64.v (total_len `U64.rem` FStar.Int.Cast.uint32_to_uint64 (c.block_len i)) <= pow2 32 - 1)
=
  let open FStar.Int.Cast in
  let x = total_len `U64.rem` uint32_to_uint64 (c.block_len i) in
  calc (<=) {
    U64.v x;
  (<=) { FStar.Math.Lemmas.euclidean_division_definition (U64.v total_len) (U64.v (uint32_to_uint64 (c.block_len i))) }
    U64.v total_len % U64.v (uint32_to_uint64 (c.block_len i) );
  (<=) { FStar.Math.Lemmas.modulo_range_lemma (U64.v total_len) (U64.v (uint32_to_uint64 (c.block_len i))) }
    U64.v (uint32_to_uint64 (c.block_len i));
  (<=) { }
    pow2 32 - 1;
  }

inline_for_extraction noextract
let rest #index (c: block index) (i: index)
  (total_len: UInt64.t): (x:UInt32.t { U32.v x = U64.v total_len % U32.v (c.block_len i) })
=
  let open FStar.Int.Cast in
  let x = total_len `U64.rem` uint32_to_uint64 (c.block_len i) in
  let r = FStar.Int.Cast.uint64_to_uint32 x in
  mod_block_len_bound c i total_len;
  calc (==) {
    U32.v r;
  (==) { }
    U64.v x % pow2 32;
  (==) { FStar.Math.Lemmas.small_modulo_lemma_1 (U64.v x) (pow2 32) }
    U64.v x;
  (==) { FStar.Math.Lemmas.euclidean_division_definition (U64.v total_len) (U64.v (uint32_to_uint64 (c.block_len i))) }
    U64.v total_len % U64.v (uint32_to_uint64 (c.block_len i) );
  (==) { }
    U64.v total_len % U32.v (c.block_len i);
  };
  r
#pop-options

inline_for_extraction noextract
let add_len #index (c: block index) (i: index) (total_len: UInt64.t) (len: UInt32.t):
  Pure UInt64.t
    (requires U64.v total_len + U32.v len < c.max_input_length i)
    (ensures fun x -> U64.v x = U64.v total_len + U32.v len /\ U64.v x < c.max_input_length i)
=
  total_len `U64.add` Int.Cast.uint32_to_uint64 len

/// We split update into several versions, to all be simplified into a single
/// large one at extraction-time.

let total_len_h #index (c: block index) (i: index) h (p: state c i) =
  State?.total_len (B.deref h p)

/// Case 1: we just need to grow the buffer, no call to the hash function.

#push-options "--z3rlimit 50"
let split_at_last_small #index (c: block index) (i: index) (b: bytes) (d: bytes): Lemma
  (requires (
    let _, rest = split_at_last c i b in
    S.length rest + S.length d < U32.v (c.block_len i)))
  (ensures (
    let blocks, rest = split_at_last c i b in
    let blocks', rest' = split_at_last c i (S.append b d) in
    S.equal blocks blocks' /\ S.equal (S.append rest d) rest'))
=
  let blocks, rest = split_at_last c i b in
  let blocks', rest' = split_at_last c i (S.append b d) in
  let l = U32.v (c.block_len i) in

  (* Looking at the definition of split_at_last, blocks depends only on S.length b / l. *)
  calc (==) {
    S.length b / l;
  (==) { S.lemma_len_append blocks rest }
    (S.length blocks + S.length rest) / l;
  (==) { Math.Lemmas.lemma_div_exact (S.length blocks) l }
    (l * (S.length blocks / l) + S.length rest) / l;
  (==) { }
    (S.length rest + (S.length blocks / l) * l) / l;
  (==) { Math.Lemmas.lemma_div_plus (S.length rest) (S.length blocks / l) l }
    (S.length rest) / l + (S.length blocks / l);
  (==) { Math.Lemmas.small_div (S.length rest) l }
    S.length blocks / l;
  };

  calc (==) {
    S.length (S.append b d) / l;
  (==) { S.lemma_len_append b d; S.lemma_len_append blocks rest }
    (S.length blocks + S.length rest + S.length d) / l;
  (==) { Math.Lemmas.lemma_div_exact (S.length blocks) l }
    (l * (S.length blocks / l) + (S.length rest + S.length d)) / l;
  (==) { }
    ((S.length rest + S.length d) + (S.length blocks / l) * l) / l;
  (==) { Math.Lemmas.lemma_div_plus (S.length rest + S.length d) (S.length blocks / l) l }
    (S.length rest + S.length d) / l + (S.length blocks / l);
  (==) { Math.Lemmas.small_div (S.length rest + S.length d) l }
    S.length blocks / l;
  };

  assert (S.equal blocks blocks');

  calc (S.equal) {
    rest `S.append` d;
  (S.equal) { (* definition *) }
    S.slice b ((S.length b / l) * l) (S.length b) `S.append` d;
  (S.equal) { }
    S.slice (S.append b d) ((S.length b / l) * l) (S.length b) `S.append` d;
  (S.equal) { (* above *) }
    S.slice (S.append b d) ((S.length (S.append b d) / l) * l) (S.length b) `S.append` d;
  (S.equal) { (* ? *) }
    S.slice (S.append b d) ((S.length (S.append b d) / l) * l) (S.length b)
    `S.append`
    S.slice (S.append b d) (S.length b) (S.length (S.append b d));
  (S.equal) { S.lemma_split (S.append b d) ((S.length (S.append b d) / l) * l) }
    S.slice (S.append b d) ((S.length (S.append b d) / l) * l) (S.length b + S.length d);
  (S.equal) { S.lemma_len_append b d }
    S.slice (S.append b d) ((S.length (S.append b d) / l) * l) (S.length (S.append b d));
  (S.equal) { }
    rest';
  };

  ()
#pop-options

#push-options "--z3cliopt smt.arith.nl=false"
let add_len_small #index (c: block index) (i: index) (total_len: UInt64.t) (len: UInt32.t): Lemma
  (requires
    U32.v len < U32.v (c.block_len i) - U32.v (rest c i total_len) /\
    U64.v total_len + U32.v len < c.max_input_length i)
  (ensures (rest c i (add_len c i total_len len) = rest c i total_len `U32.add` len))
=
  calc (==) {
    U32.v (rest c i (add_len c i total_len len));
  (==) { }
    U64.v (add_len c i total_len len) % U32.v (c.block_len i);
  (==) { }
    (U64.v total_len + U32.v len) % U32.v (c.block_len i);
  (==) { Math.Lemmas.modulo_distributivity (U64.v total_len) (U32.v len) (U32.v (c.block_len i)) }
    (U64.v total_len % U32.v (c.block_len i) + U32.v len % U32.v (c.block_len i)) % U32.v (c.block_len i);
  (==) { Math.Lemmas.lemma_mod_add_distr (U64.v total_len % U32.v (c.block_len i)) (U32.v len) (U32.v (c.block_len i)) }
    (U64.v total_len % U32.v (c.block_len i) + U32.v len) % U32.v (c.block_len i);
  (==) { }
    (U32.v (rest c i total_len) + U32.v len) % U32.v (c.block_len i);
  (==) { Math.Lemmas.modulo_lemma (U32.v (rest c i total_len) + U32.v len) (U32.v (c.block_len i)) }
    U32.v (rest c i total_len) + U32.v len;
  }
#pop-options

val update_small:
  #index:Type0 ->
  (c: block index) ->
  i:G.erased index -> (
  let i = G.reveal i in
  s:state c i ->
  data: B.buffer uint8 ->
  len: UInt32.t ->
  Stack unit
    (requires fun h0 ->
      update_pre c i s data len h0 /\
      U32.v len < U32.v (c.block_len i) - U32.v (rest c i (total_len_h c i h0 s)))
    (ensures fun h0 s' h1 ->
      update_post c i s data len h0 h1))

#push-options "--z3rlimit 50"
let update_small #index c i p data len =
  let aux (h:HS.mem) (s:c.state i): Lemma
    (requires (c.invariant h s))
    (ensures (B.loc_in (c.footprint #i h s) h))
    [SMTPat (c.invariant h s)]
  =
    c.invariant_loc_in_footprint #i h s
  in
  let aux l s h0 h1: Lemma
    (requires
      c.invariant h0 s /\
      c.freeable h0 s /\
      B.loc_disjoint l (c.footprint #i h0 s) /\
      B.modifies l h0 h1)
    (ensures (
      c.freeable h1 s))
    [ SMTPat (c.freeable h1 s); SMTPat (B.modifies l h0 h1) ]
  =
    c.frame_freeable #i l s h0 h1
  in
  let open LowStar.BufferOps in
  let h00 = ST.get () in
  assert (invariant c i h00 p);
  let s = !*p in
  let State hash_state buf total_len seen_ = s in
  let i = c.index_of_state i hash_state in
  [@inline_let]
  let hash_state: c.state i = hash_state in

  let sz = rest c i total_len in
  add_len_small c i total_len len;
  let h0 = ST.get () in
  let buf1 = B.sub buf 0ul sz in
  let buf2 = B.sub buf sz len in

  B.blit data 0ul buf2 0ul len;
  let h1 = ST.get () in
  split_at_last_small c i (G.reveal seen_) (B.as_seq h0 data);
  c.frame_invariant (B.loc_buffer buf) hash_state h0 h1;
  assert (B.as_seq h1 data == B.as_seq h0 data);

  let total_len = add_len c i total_len len in
  p *= (State hash_state buf total_len (G.hide (G.reveal seen_ `S.append` (B.as_seq h0 data))));
  let h2 = ST.get () in
  assert (B.as_seq h2 data == B.as_seq h1 data);
  c.frame_invariant (B.loc_buffer p) hash_state h1 h2;
  assert (
    let b = S.append (G.reveal seen_) (B.as_seq h0 data) in
    let blocks, rest = split_at_last c i b in
    S.length blocks + S.length rest = U64.v total_len /\
    S.length b = U64.v total_len /\
    U64.v total_len < c.max_input_length i /\
    (==) (c.v h2 hash_state) (c.update_multi_s i (c.init_s i) blocks) /\
    S.equal (S.slice (B.as_seq h2 buf) 0 (U64.v total_len % U32.v (c.block_len i))) rest
    );
  assert (seen c i h2 p `S.equal` (S.append (G.reveal seen_) (B.as_seq h0 data)));
  assert (footprint c i h0 p == footprint c i h2 p);
  assert (preserves_freeable c i p h0 h2);
  assert (equal_domains h00 h2)

#pop-options

/// Case 2: we have no buffered data.

#set-options "--z3rlimit 60"
let split_at_last_blocks #index (c: block index) (i: index) (b: bytes) (d: bytes): Lemma
  (requires (
    let blocks, rest = split_at_last c i b in
    S.equal rest S.empty))
  (ensures (
    let blocks, rest = split_at_last c i b in
    let blocks', rest' = split_at_last c i d in
    let blocks'', rest'' = split_at_last c i (S.append b d) in
    S.equal blocks'' (S.append blocks blocks') /\
    S.equal rest' rest''))
=
  let blocks, rest = split_at_last c i b in
  let blocks', rest' = split_at_last c i d in
  let blocks'', rest'' = split_at_last c i (S.append b d) in
  let b' = S.append blocks rest in
  let d' = S.append blocks' rest' in
  let l = U32.v (c.block_len i) in
  calc (S.equal) {
    rest';
  (S.equal) { }
    snd (split_at_last c i d);
  (S.equal) { }
    S.slice d ((S.length d / l) * l) (S.length d);
  (S.equal) { }
    S.slice (S.append b d) (S.length b + (S.length d / l) * l) (S.length b + S.length d);
  (S.equal) { }
    S.slice (S.append b d) (S.length b + (S.length d / l) * l) (S.length (S.append b d));
  (S.equal) { Math.Lemmas.div_exact_r (S.length b) l }
    // For some reason this doesn't go through with the default rlimit, even
    // though this is a direct rewriting based on the application of the lemma
    // above.
    S.slice (S.append b d) ((S.length b / l) * l + (S.length d / l) * l) (S.length (S.append b d));
  (S.equal) { Math.Lemmas.distributivity_add_left (S.length b / l) (S.length d / l) l }
    S.slice (S.append b d) ((S.length b / l + S.length d / l) * l) (S.length (S.append b d));
  (S.equal) { Math.Lemmas.lemma_div_plus (S.length d) (S.length b / l) l }
    S.slice (S.append b d) (((S.length b + S.length d) / l) * l) (S.length (S.append b d));
  (S.equal) { }
    snd (S.split (S.append b d) (((S.length (S.append b d)) / l) * l));
  (S.equal) { }
    rest'';
  };

  calc (S.equal) {
    S.append blocks blocks';
  (S.equal) { (* rest = S.empty *) }
    S.append (S.append blocks rest) blocks';
  (S.equal) { }
    S.append b blocks';
  (S.equal) { }
    S.append b (fst (split_at_last c i d));
  (S.equal) { (* definition of split_at_last *) }
    S.append b (fst (S.split d ((S.length d / l) * l)));
  (S.equal) { (* definition of split *) }
    S.append b (S.slice d 0 ((S.length d / l) * l));
  (S.equal) { }
    S.slice (S.append b d) 0 (S.length b + (S.length d / l) * l);
  (S.equal) { Math.Lemmas.div_exact_r (S.length b) l }
    S.slice (S.append b d) 0 ((S.length b / l) * l + (S.length d / l) * l);
  (S.equal) { Math.Lemmas.distributivity_add_left (S.length b / l) (S.length d / l) l }
    S.slice (S.append b d) 0 ((S.length b / l + S.length d / l) * l);
  (S.equal) { Math.Lemmas.lemma_div_plus (S.length d) (S.length b / l) l }
    S.slice (S.append b d) 0 (((S.length b + S.length d) / l) * l);
  (S.equal) { }
    fst (S.split (S.append b d) (((S.length (S.append b d)) / l) * l));
  (S.equal) { }
    blocks'';
  }

#push-options "--z3rlimit 50"
val update_empty_buf:
  #index:Type0 ->
  c:block index ->
  i:G.erased index -> (
  let i = G.reveal i in
  s:state c i ->
  data: B.buffer Lib.IntTypes.uint8 ->
  len: UInt32.t ->
  Stack unit
    (requires fun h0 ->
      update_pre c i s data len h0 /\
      rest c i (total_len_h c i h0 s) = 0ul)
    (ensures fun h0 s' h1 ->
      update_post c i s data len h0 h1))

inline_for_extraction noextract
let seen_pred = seen

let update_empty_buf #index c i p data len =
  let aux (h:HS.mem) (s:c.state i): Lemma
    (requires (c.invariant h s))
    (ensures (B.loc_in (c.footprint #i h s) h))
    [SMTPat (c.invariant h s)]
  =
    c.invariant_loc_in_footprint #i h s
  in
  let aux l s h0 h1: Lemma
    (requires
      c.invariant h0 s /\
      c.freeable h0 s /\
      B.loc_disjoint l (c.footprint #i h0 s) /\
      B.modifies l h0 h1)
    (ensures (
      c.freeable h1 s))
    [ SMTPat (c.freeable h1 s); SMTPat (B.modifies l h0 h1) ]
  =
    c.frame_freeable #i l s h0 h1
  in
  let aux i h
    (input1:S.seq uint8 { S.length input1 % U32.v (c.block_len i) = 0 })
    (input2:S.seq uint8 { S.length input2 % U32.v (c.block_len i) = 0 }):
    Lemma (ensures (
      let input = S.append input1 input2 in
      concat_blocks_modulo (U32.v (c.block_len i)) input1 input2;
      (==) (c.update_multi_s i (c.update_multi_s i h input1) input2)
        (c.update_multi_s i h input)))
    [ SMTPat (c.update_multi_s i (c.update_multi_s i h input1) input2) ]
  =
    c.update_multi_associative i h input1 input2
  in

  let open LowStar.BufferOps in
  let s = !*p in
  let State hash_state buf total_len seen = s in
  let i = c.index_of_state i hash_state in
  [@inline_let]
  let hash_state: c.state i = hash_state in
  let sz = rest c i total_len in
  let h0 = ST.get () in
  assert (
    let blocks, rest = split_at_last c i (G.reveal seen) in
    S.equal blocks (G.reveal seen) /\
    S.equal rest S.empty);
  split_at_last_blocks c i (G.reveal seen) (B.as_seq h0 data);
  let n_blocks = len `U32.div` c.block_len i in
  let data1_len = n_blocks `U32.mul` c.block_len i in
  let data2_len = len `U32.sub` data1_len in
  let data1 = B.sub data 0ul data1_len in
  let data2 = B.sub data data1_len data2_len in
  c.update_multi (G.hide i) hash_state data1 data1_len;

  let dst = B.sub buf 0ul data2_len in
  let h1 = ST.get () in
  B.blit data2 0ul dst 0ul data2_len;
  let h2 = ST.get () in
  c.frame_invariant (B.loc_buffer buf) hash_state h1 h2;

  S.append_assoc (G.reveal seen) (B.as_seq h0 data1) (B.as_seq h0 data2);
  assert (S.equal
    (S.append (S.append (G.reveal seen) (B.as_seq h0 data1)) (B.as_seq h0 data2))
    (S.append (G.reveal seen) (S.append (B.as_seq h0 data1) (B.as_seq h0 data2))));

  p *= (State hash_state buf (add_len c i total_len len)
    (G.hide (G.reveal seen `S.append` B.as_seq h0 data)));
  let h3 = ST.get () in
  c.frame_invariant (B.loc_buffer p) hash_state h2 h3;

  // After careful diagnosis, this is the difficult proof obligation that sends
  // z3 off the rails.
  (
    let seen' = G.reveal seen `S.append` B.as_seq h0 data in
    let blocks, rest = split_at_last c i seen' in
    calc (==) {
      S.length blocks + S.length rest;
    (==) { }
      S.length seen';
    (==) { S.lemma_len_append (G.reveal seen) (B.as_seq h0 data) }
      S.length (G.reveal seen) + S.length (B.as_seq h0 data);
    (==) { }
      U64.v total_len + U32.v len;
    }
  )
#pop-options


/// Case 3: we are given just enough data to end up on the boundary
#push-options "--z3rlimit 200"
val update_round:
  #index:Type0 ->
  c:block index ->
  i:G.erased index -> (
  let i = G.reveal i in
  s:state c i ->
  data: B.buffer uint8 ->
  len: UInt32.t ->
  Stack unit
    (requires fun h0 ->
      update_pre c i s data len h0 /\ (
      let r = rest c i (total_len_h c i h0 s) in
      U32.v len + U32.v r = U32.v (c.block_len i) /\
      r <> 0ul))
    (ensures fun h0 _ h1 ->
      update_post c i s data len h0 h1 /\
      U64.v (total_len_h c i h1 s) % U32.v (c.block_len i) = 0))

(*let split_at_last_block #index (c: block index) (i: index) (b: bytes) (d: bytes): Lemma
  (requires (
    let _, rest = split_at_last c i b in
    S.length rest + S.length d = U32.v (c.block_len i)))
  (ensures (
    let blocks, rest = split_at_last c i b in
    let blocks', rest' = split_at_last c i (S.append b d) in
    S.equal (S.append b d) blocks' /\ S.equal S.empty rest'))
=
   admit ()

let update_round #index c i p data len =
  let aux (h:HS.mem) (s:c.state i): Lemma
    (requires (c.invariant h s))
    (ensures (B.loc_in (c.footprint #i h s) h))
    [SMTPat (c.invariant h s)]
  =
    c.invariant_loc_in_footprint #i h s
  in
  let aux l s h0 h1: Lemma
    (requires
      c.invariant h0 s /\
      c.freeable h0 s /\
      B.loc_disjoint l (c.footprint #i h0 s) /\
      B.modifies l h0 h1)
    (ensures (
      c.freeable h1 s))
    [ SMTPat (c.freeable h1 s); SMTPat (B.modifies l h0 h1) ]
  =
    c.frame_freeable #i l s h0 h1
  in
  let aux i h
    (input1:S.seq uint8 { S.length input1 % U32.v (c.block_len i) = 0 })
    (input2:S.seq uint8 { S.length input2 % U32.v (c.block_len i) = 0 }):
    Lemma (ensures (
      let input = S.append input1 input2 in
      concat_blocks_modulo (U32.v (c.block_len i)) input1 input2;
      (==) (c.update_multi_s i (c.update_multi_s i h input1) input2)
        (c.update_multi_s i h input)))
    [ SMTPat (c.update_multi_s i (c.update_multi_s i h input1) input2) ]
  =
    c.update_multi_associative i h input1 input2
  in

  let open LowStar.BufferOps in
  let s = !*p in
  let State hash_state buf_ total_len seen = s in
  let i = c.index_of_state i hash_state in
  [@inline_let]
  let hash_state: c.state i = hash_state in
  let h0 = ST.get () in
  let sz = rest c i total_len in
  let diff = c.block_len i `U32.sub` sz in
  let buf0 = B.sub buf_ 0ul (c.block_len i) in
  let buf1 = B.sub buf0 0ul sz in
  let buf2 = B.sub buf0 sz diff in
  assert (B.(loc_pairwise_disjoint
    [ loc_buffer buf1; loc_buffer buf2; loc_buffer data; ]));
  B.blit data 0ul buf2 0ul diff;
  let h1 = ST.get () in
  assert (S.equal (B.as_seq h1 buf0) (S.append (B.as_seq h1 buf1) (B.as_seq h1 data)));
  c.frame_invariant (B.loc_buffer buf_) hash_state h0 h1;
  c.update_multi (G.hide i) hash_state buf0 (c.block_len i);
  let h2 = ST.get () in
  // JP: no clue why I had to go through all these manual steps.
  (
    let blocks, rest = split_at_last c i (G.reveal seen) in
    assert ((==) (c.v h2 hash_state)
      (c.update_multi_s i (c.v h1 hash_state) (B.as_seq h1 buf0)));
    assert (S.equal (B.as_seq h0 buf1) (B.as_seq h1 buf1));
    assert (S.equal rest (B.as_seq h1 buf1));
    assert (S.equal (B.as_seq h0 data) (B.as_seq h1 data));
    assert (S.equal (B.as_seq h1 buf0) (S.append (B.as_seq h1 buf1) (B.as_seq h1 data)));
    assert ((==) (c.v h2 hash_state)
      (c.update_multi_s i (c.init_s i)
        (S.append blocks (B.as_seq h1 buf0))));
    assert ((==) (c.v h2 hash_state)
      (c.update_multi_s i (c.init_s i)
        (S.append blocks (S.append (B.as_seq h1 buf1) (B.as_seq h1 data)))));
    ()); admit ()
    S.append_assoc blocks (B.as_seq h1 buf1) (B.as_seq h1 data);
    assert (S.equal (c.v h2 hash_state)
      (update_multi i (Spec.Agile.Hash.init i)
        (S.append (S.append blocks (B.as_seq h1 buf1)) (B.as_seq h1 data))));
    assert (S.equal (S.append blocks rest) (G.reveal seen));
    assert (S.equal (c.v h2 hash_state)
      (update_multi i (Spec.Agile.Hash.init i)
        (S.append (G.reveal seen) (B.as_seq h1 data))));
    assert (S.equal (c.v h2 hash_state)
      (update_multi i (Spec.Agile.Hash.init i)
        (S.append (G.reveal seen) (B.as_seq h0 data))));
    split_at_last_block i (G.reveal seen) (B.as_seq h0 data);
    let blocks', rest' = split_at_last i (S.append (G.reveal seen) (B.as_seq h0 data)) in
    assert (S.equal rest' S.empty);
    assert (B.live h2 buf_ /\
      B.(loc_disjoint (loc_buffer buf_) (Hash.footprint hash_state h2)) /\
      Hash.invariant hash_state h2);
    ()
  );
  p *= (State hash_state buf_ (add_len total_len len)
    (G.hide (G.reveal seen `S.append` B.as_seq h0 data)));
  let h3 = ST.get () in
  Hash.frame_invariant (B.loc_buffer p) hash_state h2 h3;
  Hash.frame_invariant_implies_footprint_preservation (B.loc_buffer p) hash_state h2 h3;
  assert (hashed #i h3 p `S.equal` (S.append (G.reveal seen) (B.as_seq h0 data)))
#pop-options

#push-options "--z3rlimit 200"
let update a p data len =
  let open LowStar.BufferOps in
  let s = !*p in
  let State hash_state buf_ total_len seen = s in
  let a = Hash.alg_of_state a hash_state in
  let sz = rest a total_len in
  if len `U32.lt` (Hacl.Hash.Definitions.block_len a `U32.sub` sz) then
    update_small (G.hide a) p data len
  else if sz = 0ul then
    update_empty_buf (G.hide a) p data len
  else begin
    let h0 = ST.get () in
    let diff = Hacl.Hash.Definitions.block_len a `U32.sub` sz in
    let data1 = B.sub data 0ul diff in
    let data2 = B.sub data diff (len `U32.sub` diff) in
    update_round (G.hide a) p data1 diff;
    let h1 = ST.get () in
    update_empty_buf (G.hide a) p data2 (len `U32.sub` diff);
    let h2 = ST.get () in
    (
      let seen = G.reveal seen in
      assert (hashed #a h1 p `S.equal` (S.append seen (B.as_seq h0 data1)));
      assert (hashed #a h2 p `S.equal` (S.append (S.append seen (B.as_seq h0 data1)) (B.as_seq h0 data2)));
      S.append_assoc seen (B.as_seq h0 data1) (B.as_seq h0 data2);
      assert (S.equal (S.append (B.as_seq h0 data1) (B.as_seq h0 data2)) (B.as_seq h0 data));
      assert (S.equal
        (S.append (S.append seen (B.as_seq h0 data1)) (B.as_seq h0 data2))
        (S.append seen (B.as_seq h0 data)));
      assert (hashed #a h2 p `S.equal` (S.append seen (B.as_seq h0 data)));
      ()
    )
  end
#pop-options

*)