import host.mlx.ReplayFrame
import host.mlx.ActualCachedCall
import host.mlx.ActualShapelessCall
import host.mlx.ActualSamplerCall

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.CachedKernel
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The complete cached call retains additional native graph roots and every
initially live handle, including arrays owned by other cache stages. -/
theorem cached_call_framed {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (frame : Nat → Prop) (roles : Nat → GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (replayRoles (coupledRoles roles)) ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H (fun i => liveNodes i ∨ frame i) tail source target)
    (closureLive : H 1352) (vectorLive : H 18221) (nullLive : H 0)
    (nodesBound : target.nnext + trace.order.length < 2^64) (handlesBound : target.next < 2^64)
    (b off : Nat) :
    ∃ replayedTarget : Host.Mlx.Ffi.St,
      Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [output b off,.big 1352,.big 18221] =
        okW (final.newObj (.vec [source.nnext])).2 status0 [u64Write b off source.next] ∧
      Host.Mlx.Ffi.call target chars!"mlx_closure_apply"
          [output (R.a b) off,.big (Int.ofNat (R.handle 1352)),.big (Int.ofNat (R.handle 18221))] =
        okW (replayedTarget.newObj (.vec ([source.nnext].map R.node))).2 status0
          [u64Write (R.a b) off replayedTarget.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (Host.Mlx.Ffi.Annotated.NodeRel (replayRoles (coupledRoles roles)) ν₀ ν C₀ C R boundary)
        (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R)
        (fun a => a = final.next ∨ H a) (fun i => resultNodes i ∨ frame i) tail
        (final.newObj (.vec [source.nnext])).2
        (replayedTarget.newObj (.vec ([source.nnext].map R.node))).2 ∧
      ListR (Host.Ts.Owned.Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R)
        (cellParts .u64 (.big (Int.ofNat final.next)) 8 0)
        (cellParts .u64 (.big (Int.ofNat replayedTarget.next)) 8 0) := by
  obtain ⟨payload',t',hc,ht⟩ := target_closure h closureLive
  have hz : target.obj? 0 = none := by
    have ho := h.objs 0 nullLive
    change OptionR (Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) (source.obj? 0) (target.obj? (R.handle 0)) at ho
    rw [source_null_object,h.handleZero] at ho
    cases ht : target.obj? 0 with
    | none => rfl
    | some obj => rw [ht] at ho; cases ho
  have keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) finalMap := by
    change listSupport (fun p : Nat × Nat => p.1 < 17778) [(15287,17777),(15284,15282),(15285,15243),(15286,1320)]
    dsimp [listSupport]; decide +kernel
  have outs : listSupport (· < final.nnext) trace.outs := by
    change 15287 < 17778 ∧ True
    decide +kernel
  obtain ⟨replayedTarget,_,hr,hl,hbytes⟩ :=
    ((source_plan (coupledRoles roles) (h.onlyNodes (fun _ hi => .inl hi))).frame frame).applyDone_fresh (fun _ _ _ h => h.base) h ht keys outs b off 0 0
      source_null_object hz (by rw [source_counter]; change 17777+1 < 2^64; decide +kernel) nodesBound
      (by rw [source_handle_counter]; decide +kernel) handlesBound
  have outputNodes : trace.outs.map (substOf finalMap) = [source.nnext] := by rfl
  rw [outputNodes] at hr hl
  refine ⟨replayedTarget,source_cached_call b off,?_,hl,hbytes⟩
  rw [call_closureApply,closureApply_cached target (output (R.a b) off) (R.a b) off 0
    (R.handle 1352) (R.handle 18221) (R.region 281474976715599) payload' false [t'] (inputs.map R.node) t'
    (output_slot (R.a b) off) hc (h.vec_view 18221 vectorLive inputs source_vector)
    (selected_target roles (h.onlyNodes (fun _ hi => .inl hi)) t' ht)]
  exact hr

end Host.Load.Run.Full.CachedKernel

namespace Host.Load.Run.Full.Shapeless
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The complete cached call retains additional native graph roots and every
+initially live handle, including arrays owned by other cache stages. -/
theorem cached_call_framed {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (frame : Nat → Prop) (base : Nat → GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H (fun i => N0 i ∨ frame i) tail source target)
    (closureLive : H 18194) (vectorLive : H 18195) (nullLive : H 0)
    (nodesBound : target.nnext + trace.order.length < 2^64) (handlesBound : target.next < 2^64)
    (b off : Nat) :
    ∃ replayedTarget : Host.Mlx.Ffi.St,
      Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [output b off,.big 18194,.big 18195] =
        okW (s8.newObj (.vec [17783])).2 status0 [u64Write b off source.next] ∧
      Host.Mlx.Ffi.call target chars!"mlx_closure_apply"
          [output (R.a b) off,.big (Int.ofNat (R.handle 18194)),.big (Int.ofNat (R.handle 18195))] =
        okW (replayedTarget.newObj (.vec ([17783].map R.node))).2 status0
          [u64Write (R.a b) off replayedTarget.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
        (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R)
        (fun a => a = s8.next ∨ H a) (fun i => N8 i ∨ frame i) tail
        (s8.newObj (.vec [17783])).2
        (replayedTarget.newObj (.vec ([17783].map R.node))).2 ∧
      ListR (Host.Ts.Owned.Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R)
        (cellParts .u64 (.big (Int.ofNat s8.next)) 8 0)
        (cellParts .u64 (.big (Int.ofNat replayedTarget.next)) 8 0) := by
  obtain ⟨payload',t',hc,ht⟩ := target_closure h closureLive
  have hz : target.obj? 0 = none := by
    have ho := h.objs 0 nullLive
    change OptionR (Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) (source.obj? 0) (target.obj? (R.handle 0)) at ho
    rw [source_null_object,h.handleZero] at ho
    cases ht : target.obj? 0 with
    | none => rfl
    | some obj => rw [ht] at ho; cases ho
  have keys : listSupport (fun p : Nat × Nat => p.1 < s8.nnext) m8 := by
    change listSupport (fun p : Nat × Nat => p.1 < 17784)
      [(15272,17783),(15271,17782),(15270,17781),(15268,17780),(15267,17779),(15266,17778),(15265,17777),(15262,1318),(15263,15245),(15264,1319)]
    dsimp [listSupport]; decide +kernel
  have outs : listSupport (· < s8.nnext) trace.outs := by
    change 15272 < 17784 ∧ True
    decide +kernel
  obtain ⟨replayedTarget,_,hr,hl,hbytes⟩ :=
    ((plan0 base).frame frame).applyDone_fresh (fun _ _ _ h => h.base) h ht keys outs b off 0 0
      source_null_object hz (by change 17777+8 < 2^64; decide +kernel) nodesBound
      (by change 22018 < 2^64; decide +kernel) handlesBound
  have outputNodes : trace.outs.map (substOf m8) = [17783] := by rfl
  rw [outputNodes] at hr hl
  refine ⟨replayedTarget,source_cached_call b off,?_,hl,hbytes⟩
  rw [call_closureApply,closureApply_cached target (output (R.a b) off) (R.a b) off 0
    (R.handle 18194) (R.handle 18195) (R.region 281474976715599) payload' true [t'] (inputs.map R.node) t'
    (CachedKernel.output_slot (R.a b) off) hc (h.vec_view 18195 vectorLive inputs source_vector)
    (selected_target base (h.onlyNodes (fun _ hi => .inl hi)) t' ht)]
  exact hr

end Host.Load.Run.Full.Shapeless

namespace Host.Load.Run.Full.Sampler
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The complete cached call retains additional native graph roots and every
+initially live handle, including arrays owned by other cache stages. -/
theorem cached_call_framed {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (frame : Nat → Prop) (base : Nat → GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H (fun i => N0 i ∨ frame i) tail source target)
    (closureLive : H 21993) (vectorLive : H 21994) (nullLive : H 0)
    (nodesBound : target.nnext + trace.order.length < 2^64) (handlesBound : target.next < 2^64)
    (b off : Nat) :
    ∃ replayedTarget : Host.Mlx.Ffi.St,
      Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [output b off,.big 21993,.big 21994] =
        okW (s5.newObj (.vec [17781])).2 status0 [u64Write b off source.next] ∧
      Host.Mlx.Ffi.call target chars!"mlx_closure_apply"
          [output (R.a b) off,.big (Int.ofNat (R.handle 21993)),.big (Int.ofNat (R.handle 21994))] =
        okW (replayedTarget.newObj (.vec ([17781].map R.node))).2 status0
          [u64Write (R.a b) off replayedTarget.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
        (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R)
        (fun a => a = s5.next ∨ H a) (fun i => N5 i ∨ frame i) tail
        (s5.newObj (.vec [17781])).2
        (replayedTarget.newObj (.vec ([17781].map R.node))).2 ∧
      ListR (Host.Ts.Owned.Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R)
        (cellParts .u64 (.big (Int.ofNat s5.next)) 8 0)
        (cellParts .u64 (.big (Int.ofNat replayedTarget.next)) 8 0) := by
  obtain ⟨payload',t',hc,ht⟩ := target_closure h closureLive
  have hz : target.obj? 0 = none := by
    have ho := h.objs 0 nullLive
    change OptionR (Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) (source.obj? 0) (target.obj? (R.handle 0)) at ho
    rw [source_null_object,h.handleZero] at ho
    cases ht : target.obj? 0 with
    | none => rfl
    | some obj => rw [ht] at ho; cases ho
  have keys : listSupport (fun p : Nat × Nat => p.1 < s5.nnext) m5 := by
    change listSupport (fun p : Nat × Nat => p.1 < 17782)
      [(17771,17781),(17770,17780),(17769,17779),(17768,17778),(17767,17777),(17766,17765)]
    dsimp [listSupport]; decide +kernel
  have outs : listSupport (· < s5.nnext) trace.outs := by
    change 17771 < 17782 ∧ True
    decide +kernel
  obtain ⟨replayedTarget,_,hr,hl,hbytes⟩ :=
    ((plan0 base h.nodeMap.injective).frame frame).applyDone_fresh (fun _ _ _ h => h.base) h ht keys outs b off 0 0
      source_null_object hz (by change 17777+5 < 2^64; decide +kernel) nodesBound
      (by change 22018 < 2^64; decide +kernel) handlesBound
  have outputNodes : trace.outs.map (substOf m5) = [17781] := by rfl
  rw [outputNodes] at hr hl
  refine ⟨replayedTarget,source_cached_call b off,?_,hl,hbytes⟩
  rw [call_closureApply,closureApply_cached target (output (R.a b) off) (R.a b) off 0
    (R.handle 21993) (R.handle 21994) (R.region 281474976715599) payload' false [t'] (inputs.map R.node) t'
    (CachedKernel.output_slot (R.a b) off) hc (h.vec_view 21994 vectorLive inputs source_vector)
    (selected_target base (h.onlyNodes (fun _ hi => .inl hi)) t' ht)]
  exact hr

end Host.Load.Run.Full.Sampler

