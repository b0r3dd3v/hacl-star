module Vale.Arch.Heap
open FStar.Mul
open Vale.Interop
open Vale.Arch.HeapImpl
module Map16 = Vale.Lib.Map16
friend Vale.Arch.HeapImpl

let heap_impl = vale_full_heap

let heap_get hi = hi.vf_heap.mh

let heap_taint hi = hi.vf_taint

let heap_upd hi mh' mt' =
  let h' = mi_heap_upd hi.vf_heap mh' in
  {
    vf_layout = hi.vf_layout;
    vf_heap = h';
    vf_heaplets = Map16.upd hi.vf_heaplets 0 h';
    vf_taint = mt';
  }

let heap_create_machine ih =
  down_mem ih

let heap_create_impl ih mt =
  let vh = ValeHeap (down_mem ih) (Ghost.hide ih) in
  let vh4 = ((vh, vh), (vh, vh)) in
  let vh16 = ((vh4, vh4), (vh4, vh4)) in
  {
    vf_layout = {vl_old_heap = vh};
    vf_heap = vh;
    vf_heaplets = Map16.upd vh16 0 vh;
    vf_taint = mt;
  }
