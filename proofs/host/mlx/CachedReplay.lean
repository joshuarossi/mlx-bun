import host.mlx.ReplayResult
import host.mlx.TraceRoles

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem call_closureApply (s : St) (out cls inputs : Arg) :
    call s chars!"mlx_closure_apply" [out,cls,inputs] = closureApply s out cls inputs := by
  have hs : symOf chars!"mlx_closure_apply" = some .closureApply := by decide +kernel
  unfold call
  rw [hs]

/-- A complete cached apply to an existing result vector, from the source
replay plan through the original output write. The stronger indexed graph
annotation survives every rebuilt node and the final vector assignment. -/
theorem ReplayPlan.applyDone_existing {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {cls : Nat} {N K : Nat → Prop}
    {s final : St} {result : List (Nat × Nat)} {t t' : Trace} {xs : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s (t.ins.zip xs) t.order K final result)
    (base : ∀ i n n', NodeRel i n n' → NodeR NR R (PrimR NR R) boundary i n n')
    {H : Nat → Prop} {tail : List NumV} {s' : St}
    (h : Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s') (trace : TraceR R t t')
    (keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) result)
    (outputs : listSupport (· < final.nnext) t.outs)
    (b off slot : Nat) (old : List Nat) (hslot : H slot) (hv : final.obj? slot = some (.vec old))
    (ns : s.nnext + t.order.length < 2^64) (nt : s'.nnext + t.order.length < 2^64)
    (bs : slot < 2^64) (bt : R.handle slot < 2^64) :
    ∃ final' : St,
      applyDone s cls b off slot t xs =
        okW (final.setObj slot (.vec (t.outs.map (substOf result)))) status0 [u64Write b off slot] ∧
      applyDone s' (R.handle cls) (R.a b) off (R.handle slot) t' (xs.map R.node) =
        okW (final'.setObj (R.handle slot) (.vec ((t.outs.map (substOf result)).map R.node)))
          status0 [u64Write (R.a b) off (R.handle slot)] ∧
      Live NR R NodeRel (fun _ => ObjectR NR R) H K tail
        (final.setObj slot (.vec (t.outs.map (substOf result))))
        (final'.setObj (R.handle slot) (.vec ((t.outs.map (substOf result)).map R.node))) ∧
      ListR (Parametric.ByteR NR R) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
        (cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0) := by
  obtain ⟨final',hs,ht,hl,_,_⟩ := plan.replay base h trace keys outputs ns nt
  refine ⟨final',NativeRoles.applyDone_existing s final cls b off slot t xs old _ hs hv,
    NativeRoles.applyDone_existing s' final' (R.handle cls) (R.a b) off (R.handle slot)
      t' (xs.map R.node) (old.map R.node) _ ht (hl.vec_view slot hslot old hv),
    hl.setObj slot hslot _ _ (.vec _) bs bt,
    Parametric.cellParts_roles (.handle slot) .u64 8 0⟩

/-- Fresh output slots use a new related vector handle. The absence checks
are made in the input states and transported through replay's object frame. -/
theorem ReplayPlan.applyDone_fresh {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {cls : Nat} {N K : Nat → Prop}
    {s final : St} {result : List (Nat × Nat)} {t t' : Trace} {xs : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s (t.ins.zip xs) t.order K final result)
    (base : ∀ i n n', NodeRel i n n' → NodeR NR R (PrimR NR R) boundary i n n')
    {H : Nat → Prop} {tail : List NumV} {s' : St}
    (h : Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s') (trace : TraceR R t t')
    (keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) result)
    (outputs : listSupport (· < final.nnext) t.outs)
    (b off slot slot' : Nat) (hv : s.obj? slot = none) (hv' : s'.obj? slot' = none)
    (ns : s.nnext + t.order.length < 2^64) (nt : s'.nnext + t.order.length < 2^64)
    (bs : s.next < 2^64) (bt : s'.next < 2^64) :
    ∃ final' : St,
      applyDone s cls b off slot t xs =
        okW (final.newObj (.vec (t.outs.map (substOf result)))).2 status0 [u64Write b off final.next] ∧
      applyDone s' (R.handle cls) (R.a b) off slot' t' (xs.map R.node) =
        okW (final'.newObj (.vec ((t.outs.map (substOf result)).map R.node))).2
          status0 [u64Write (R.a b) off final'.next] ∧
      Live NR R NodeRel (fun _ => ObjectR NR R) (fun a => a = final.next ∨ H a) K tail
        (final.newObj (.vec (t.outs.map (substOf result)))).2
        (final'.newObj (.vec ((t.outs.map (substOf result)).map R.node))).2 ∧
      ListR (Parametric.ByteR NR R) (cellParts .u64 (.big (Int.ofNat final.next)) 8 0)
        (cellParts .u64 (.big (Int.ofNat final'.next)) 8 0) := by
  obtain ⟨final',hs,ht,hl,ho,hn⟩ := plan.replay base h trace keys outputs ns nt
  have sourceFrame := plan.frames
  have hvfinal : final.obj? slot = none := by
    change final.objs.get slot = none
    rw [sourceFrame.1]
    exact hv
  have hvfinal' : final'.obj? slot' = none := by
    change final'.objs.get slot' = none
    rw [ho]
    exact hv'
  have bs' : final.next < 2^64 := by rw [sourceFrame.2]; exact bs
  have bt' : final'.next < 2^64 := by rw [hn]; exact bt
  refine ⟨final',NativeRoles.applyDone_fresh s final cls b off slot t xs _ hs hvfinal,
    NativeRoles.applyDone_fresh s' final' (R.handle cls) (R.a b) off slot' t' (xs.map R.node) _ ht hvfinal',
    hl.newObj _ _ (.vec _) bs' bt',?_⟩
  rw [← hl.handleMap.head]
  exact Parametric.cellParts_roles (.handle final.next) .u64 8 0

end Host.Mlx.Ffi.NativeRoles
