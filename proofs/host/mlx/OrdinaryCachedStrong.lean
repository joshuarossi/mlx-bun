import host.mlx.ReplayObjects
import host.mlx.OrdinaryCachedCall

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedCall
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

noncomputable def outputObjectRoles (objects : Nat → Object) : Nat → Object :=
  objectWrite objects 29377 (.vec [22591,22592,22593])

/-- The exact ordinary cached call preserves all selected fixed object
annotations. Only the existing result vector receives its new fixed contents. -/
theorem cached_call_objects {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (frame : Nat → Prop) (base : Nat → GraphNode) (objects : Nat → Object)
    {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (NodeRel (roles (coupledRoles base)) ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H (fun i => N0 i ∨ frame i) tail source target)
    (closureLive : H 1354) (vectorLive : H 29376) (outputLive : H 29377)
    (nodesBound : target.nnext + trace.order.length < 2^64) (handlesBound : target.next < 2^64) :
    ∃ replayedTarget : Host.Mlx.Ffi.St,
      Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [outArg,.big 1354,.big 29376] =
        okW (s3.setObj 29377 (.vec [22591,22592,22593])) status0 [u64Write 3126924 0 29377] ∧
      Host.Mlx.Ffi.call target chars!"mlx_closure_apply"
          [targetOutArg R,.big (Int.ofNat (R.handle 1354)),.big (Int.ofNat (R.handle 29376))] =
        okW (replayedTarget.setObj (R.handle 29377) (.vec ([22591,22592,22593].map R.node))) status0
          [u64Write (R.a 3126924) 0 (R.handle 29377)] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (roles (coupledRoles base)) ν₀ ν C₀ C R boundary)
        (ObjectRel (outputObjectRoles objects) ν₀ ν C₀ C R) H (fun i => N3 i ∨ frame i) tail
        (s3.setObj 29377 (.vec [22591,22592,22593]))
        (replayedTarget.setObj (R.handle 29377) (.vec ([22591,22592,22593].map R.node))) ∧
      ListR (Host.Ts.Owned.Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R)
        actualBytes (cellParts .u64 (.big (Int.ofNat (R.handle 29377))) 8 0) ∧
      replayedTarget.objs = target.objs ∧ replayedTarget.next = target.next := by
  have weak := h.mono (fun _ _ p => p) (fun _ _ _ p => p) (fun _ _ _ p => p.base)
  obtain ⟨payload',t',hc,ht⟩ := target_closure weak closureLive
  have keys : listSupport (fun p : Nat × Nat => p.1 < s3.nnext) m3 := by
    change listSupport (fun p : Nat × Nat => p.1 < 22594)
      [(15257,22593),(15256,22592),(15255,22591),(15252,22590),(15253,10),(15254,11)]
    dsimp [listSupport]; decide +kernel
  have outs : listSupport (· < s3.nnext) trace.outs := by
    change listSupport (· < 22594) [15255,15256,15257]
    dsimp [listSupport]; decide +kernel
  have targetSlotBound : R.handle 29377 < 2^64 := by
    have := h.handleMap.bound 29377 (h.liveHandleBound 29377 outputLive)
    omega
  have outputNodes : trace.outs.map (substOf m3) = [22591,22592,22593] := by rfl
  have created : ObjectRel (outputObjectRoles objects) ν₀ ν C₀ C R 29377
      (.vec (trace.outs.map (substOf m3))) (.vec ((trace.outs.map (substOf m3)).map R.node)) := by
    rw [outputNodes]
    exact ObjectRel.write_vec objects ν₀ ν C₀ C R 29377 [22591,22592,22593]
  obtain ⟨replayedTarget,_,hr,hl,hbytes,hobjects,hnext⟩ :=
    ((plan0 (coupledRoles base) h.nodeMap.injective).frame frame).applyDone_objects
      (fun _ _ _ h => h.base) (fun _ _ _ h => h.base) h ht keys outs 3126924 0 29377 [] outputLive
      (by rfl) created (fun _ ne _ _ p => ObjectRel.write_frame ne p)
      (by change 22591+3 < 2^64; decide +kernel) nodesBound (by decide +kernel) targetSlotBound
  rw [outputNodes] at hr hl
  refine ⟨replayedTarget,source_cached_call,?_,hl,?_,hobjects,hnext⟩
  · rw [call_closureApply,closureApply_cached target (targetOutArg R) (R.a 3126924) 0
      (R.handle 29377) (R.handle 1354) (R.handle 29376) (R.region 281474976715599)
      payload' false [t'] (inputs.map R.node) t' (slot_parts _ _ _) hc
      (weak.vec_view 29376 vectorLive inputs source_vector)
      (selected_target base (weak.onlyNodes (fun _ hi => .inl hi)) t' ht)]
    exact hr
  · rw [actual_bytes]
    exact hbytes

/-- The original call's only native object-store change is its existing
output-vector slot; the captured closure and every other object are framed. -/
theorem source_object_frame (i : Nat) (ne : i ≠ 29377) :
    (s3.setObj 29377 (.vec [22591,22592,22593])).obj? i = source.obj? i := by
  change (s3.objs.set 29377 (.vec [22591,22592,22593])).get i = source.objs.get i
  rw [PTrie.get_set_u64 _ _ _ (by decide +kernel : 29377 < 2^64),ite_eq_right ne]
  rfl

theorem target_object_frame (R : Ren) (target replayed : Host.Mlx.Ffi.St)
    (frame : replayed.objs = target.objs) (bound : R.handle 29377 < 2^64)
    (i : Nat) (ne : i ≠ R.handle 29377) :
    (replayed.setObj (R.handle 29377) (.vec ([22591,22592,22593].map R.node))).obj? i = target.obj? i := by
  change (replayed.objs.set (R.handle 29377) (.vec ([22591,22592,22593].map R.node))).get i = target.objs.get i
  rw [PTrie.get_set_u64 _ _ _ bound,ite_eq_right ne,frame]

end Host.Load.Run.Full.Ordinary.CachedCall
