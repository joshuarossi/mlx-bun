import host.mlx.KernelOutputRoles
import host.mlx.NativeVector

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem kernelApply_existing (s result : St) (out : Arg) (b off slot kh inv cfg : Nat)
    (name source header : List Char) (nIn nOut : Nat) (xs nodes old : List Nat) (c : Cfg)
    (ho : slotOf out = some (b,off,slot))
    (hk : s.obj? kh = some (.kernel name source header nIn nOut))
    (hi : s.obj? inv = some (.vec xs)) (hc : s.obj? cfg = some (.cfg c))
    (hr : kernelApply.outs kh xs c s 0 c.outs = (result,nodes))
    (hv : result.obj? slot = some (.vec old)) :
    kernelApply s out (.big (Int.ofNat kh)) (.big (Int.ofNat inv)) (.big (Int.ofNat cfg)) =
      okW (result.setObj slot (.vec nodes)) status0 [u64Write b off slot] := by
  unfold kernelApply
  simp only [ho,argNat_big_nat,Option.bind_some,hk,hi,hc,Option.map_some]
  rw [hr]
  dsimp only
  rw [NativeRoles.setVec_existing result slot old nodes hv]

/-- Actual Metal kernel application to an existing output vector, including
all output nodes, fresh graph identities, the vector assignment and handle
write. Source/header identity is retained by the kernel object relation. -/
theorem Live.kernelApply_existing {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R) H N tail s s')
    (out out' : Arg) (b off slot kh inv cfg : Nat) (name source header : List Char)
    (nIn nOut : Nat) (xs old : List Nat) (c c' : Cfg)
    (hslot : H slot) (hkernel : H kh) (hinputs : H inv)
    (ho : slotOf out = some (b,off,slot)) (ho' : slotOf out' = some (R.a b,off,R.handle slot))
    (hk : s.obj? kh = some (.kernel name source header nIn nOut))
    (hi : s.obj? inv = some (.vec xs)) (hv : s.obj? slot = some (.vec old))
    (hc : s.obj? cfg = some (.cfg c)) (hc' : s'.obj? (R.handle cfg) = some (.cfg c'))
    (config : CfgR NR c c')
    (ns : s.nnext + c.outs.length < 2^64) (nt : s'.nnext + c'.outs.length < 2^64)
    (bs : slot < 2^64) (bt : R.handle slot < 2^64) :
    let result := kernelApply.outs kh xs c s 0 c.outs
    let result' := kernelApply.outs (R.handle kh) (xs.map R.node) c' s' 0 c'.outs
    ∃ K,
      kernelApply s out (.big (Int.ofNat kh)) (.big (Int.ofNat inv)) (.big (Int.ofNat cfg)) =
        okW (result.1.setObj slot (.vec result.2)) status0 [u64Write b off slot] ∧
      kernelApply s' out' (.big (Int.ofNat (R.handle kh))) (.big (Int.ofNat (R.handle inv)))
        (.big (Int.ofNat (R.handle cfg))) =
        okW (result'.1.setObj (R.handle slot) (.vec result'.2)) status0 [u64Write (R.a b) off (R.handle slot)] ∧
      Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R) H K tail
        (result.1.setObj slot (.vec result.2)) (result'.1.setObj (R.handle slot) (.vec result'.2)) ∧
      result'.2 = result.2.map R.node ∧ (∀ i, N i → K i) ∧ listSupport K result.2 ∧
      ListR (Host.Ts.Owned.Parametric.ByteR NR R)
        (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
        (cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0) := by
  dsimp only
  let result := kernelApply.outs kh xs c s 0 c.outs
  let result' := kernelApply.outs (R.handle kh) (xs.map R.node) c' s' 0 c'.outs
  obtain ⟨K,hl,hm,hinc,hsup⟩ := kernel_outputs kh xs c c' config config.outs N s s' 0 h ns nt
  have hsobj : result.1.objs = s.objs := kernel_outputs_objs kh xs c c.outs s 0
  have htobj : result'.1.objs = s'.objs := kernel_outputs_objs (R.handle kh) (xs.map R.node) c' c'.outs s' 0
  have hv' := h.vec_view slot hslot old hv
  have hvresult : result.1.obj? slot = some (.vec old) := by
    change result.1.objs.get slot = some (.vec old)
    rw [hsobj]; exact hv
  have hvresult' : result'.1.obj? (R.handle slot) = some (.vec (old.map R.node)) := by
    change result'.1.objs.get (R.handle slot) = some (.vec (old.map R.node))
    rw [htobj]; exact hv'
  have updated := hl.setObj slot hslot (.vec result.2) (.vec (result.2.map R.node)) (.vec result.2) bs bt
  change Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R) H K tail
    (result.1.setObj slot (.vec result.2)) (result'.1.setObj (R.handle slot) (.vec (result.2.map R.node))) at updated
  rw [← hm] at updated
  refine ⟨K, ?_, ?_, updated, hm, hinc, hsup, Parametric.cellParts_roles (.handle slot) .u64 8 0⟩
  · exact NativeRoles.kernelApply_existing s result.1 out b off slot kh inv cfg name source header nIn nOut
      xs result.2 old c ho hk hi hc rfl hvresult
  · exact NativeRoles.kernelApply_existing s' result'.1 out' (R.a b) off (R.handle slot)
      (R.handle kh) (R.handle inv) (R.handle cfg) name source header nIn nOut
      (xs.map R.node) result'.2 (old.map R.node) c' ho'
      (h.kernel_view kh hkernel name source header nIn nOut hk) (h.vec_view inv hinputs xs hi) hc' rfl hvresult'

end Host.Mlx.Ffi.NativeRoles
