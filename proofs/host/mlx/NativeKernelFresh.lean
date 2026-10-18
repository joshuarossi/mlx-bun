import host.mlx.NativeKernelApply

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem kernelApply_fresh (s result : St) (out : Arg) (b off slot kh inv cfg : Nat)
    (name source header : List Char) (nIn nOut : Nat) (xs nodes : List Nat) (c : Cfg)
    (ho : slotOf out = some (b,off,slot))
    (hk : s.obj? kh = some (.kernel name source header nIn nOut))
    (hi : s.obj? inv = some (.vec xs)) (hc : s.obj? cfg = some (.cfg c))
    (hr : kernelApply.outs kh xs c s 0 c.outs = (result,nodes))
    (hv : result.obj? slot = none) :
    kernelApply s out (.big (Int.ofNat kh)) (.big (Int.ofNat inv)) (.big (Int.ofNat cfg)) =
      okW (result.newObj (.vec nodes)).2 status0 [u64Write b off result.next] := by
  unfold kernelApply
  simp only [ho,argNat_big_nat,Option.bind_some,hk,hi,hc,Option.map_some]
  rw [hr]
  dsimp only
  rw [NativeRoles.setVec_fresh result slot nodes hv] <;> rfl

/-- The fresh-vector alternative of the original Metal application, including
its new output handle. Existing kernel/config/vector objects retain their roles. -/
theorem Live.kernelApply_fresh {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R) H N tail s s')
    (out out' : Arg) (b off slot slot' kh inv cfg : Nat) (name source header : List Char)
    (nIn nOut : Nat) (xs : List Nat) (c c' : Cfg) (hkernel : H kh) (hinputs : H inv)
    (ho : slotOf out = some (b,off,slot)) (ho' : slotOf out' = some (R.a b,off,slot'))
    (hk : s.obj? kh = some (.kernel name source header nIn nOut))
    (hi : s.obj? inv = some (.vec xs)) (hv : s.obj? slot = none) (hv' : s'.obj? slot' = none)
    (hc : s.obj? cfg = some (.cfg c)) (hc' : s'.obj? (R.handle cfg) = some (.cfg c'))
    (config : CfgR NR c c')
    (ns : s.nnext + c.outs.length < 2^64) (nt : s'.nnext + c'.outs.length < 2^64)
    (bs : s.next < 2^64) (bt : s'.next < 2^64) :
    let result := kernelApply.outs kh xs c s 0 c.outs
    let result' := kernelApply.outs (R.handle kh) (xs.map R.node) c' s' 0 c'.outs
    ∃ K,
      kernelApply s out (.big (Int.ofNat kh)) (.big (Int.ofNat inv)) (.big (Int.ofNat cfg)) =
        okW (result.1.newObj (.vec result.2)).2 status0 [u64Write b off s.next] ∧
      kernelApply s' out' (.big (Int.ofNat (R.handle kh))) (.big (Int.ofNat (R.handle inv)))
        (.big (Int.ofNat (R.handle cfg))) =
        okW (result'.1.newObj (.vec result'.2)).2 status0 [u64Write (R.a b) off s'.next] ∧
      Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R)
        (fun a => a = s.next ∨ H a) K tail
        (result.1.newObj (.vec result.2)).2 (result'.1.newObj (.vec result'.2)).2 ∧
      result'.2 = result.2.map R.node ∧ (∀ i, N i → K i) ∧ listSupport K result.2 ∧
      ListR (Host.Ts.Owned.Parametric.ByteR NR R)
        (cellParts .u64 (.big (Int.ofNat s.next)) 8 0)
        (cellParts .u64 (.big (Int.ofNat s'.next)) 8 0) := by
  dsimp only
  let result := kernelApply.outs kh xs c s 0 c.outs
  let result' := kernelApply.outs (R.handle kh) (xs.map R.node) c' s' 0 c'.outs
  obtain ⟨K,hl,hm,hinc,hsup⟩ := kernel_outputs kh xs c c' config config.outs N s s' 0 h ns nt
  have hsobj : result.1.objs = s.objs := kernel_outputs_objs kh xs c c.outs s 0
  have htobj : result'.1.objs = s'.objs := kernel_outputs_objs (R.handle kh) (xs.map R.node) c' c'.outs s' 0
  have hsnext : result.1.next = s.next := kernel_outputs_next kh xs c c.outs s 0
  have htnext : result'.1.next = s'.next := kernel_outputs_next (R.handle kh) (xs.map R.node) c' c'.outs s' 0
  have hvresult : result.1.obj? slot = none := by
    change result.1.objs.get slot = none
    rw [hsobj]; exact hv
  have hvresult' : result'.1.obj? slot' = none := by
    change result'.1.objs.get slot' = none
    rw [htobj]; exact hv'
  have bs' : result.1.next < 2^64 := by rw [hsnext]; exact bs
  have bt' : result'.1.next < 2^64 := by rw [htnext]; exact bt
  have created := hl.newObj (.vec result.2) (.vec (result.2.map R.node)) (.vec result.2) bs' bt'
  change Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R)
    (fun a => a = result.1.next ∨ H a) K tail
    (result.1.newObj (.vec result.2)).2 (result'.1.newObj (.vec (result.2.map R.node))).2 at created
  rw [← hm,hsnext] at created
  refine ⟨K, ?_, ?_, created, hm, hinc, hsup, ?_⟩
  · rw [NativeRoles.kernelApply_fresh s result.1 out b off slot kh inv cfg name source header nIn nOut
      xs result.2 c ho hk hi hc rfl hvresult,hsnext]
  · rw [NativeRoles.kernelApply_fresh s' result'.1 out' (R.a b) off slot'
      (R.handle kh) (R.handle inv) (R.handle cfg) name source header nIn nOut
      (xs.map R.node) result'.2 c' ho' (h.kernel_view kh hkernel name source header nIn nOut hk)
      (h.vec_view inv hinputs xs hi) hc' rfl hvresult',htnext]
  · rw [← h.handleMap.head]
    exact Parametric.cellParts_roles (.handle s.next) .u64 8 0

end Host.Mlx.Ffi.NativeRoles
