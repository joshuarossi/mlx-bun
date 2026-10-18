import host.mlx.ActualCachedKernel
import host.mlx.AnnotatedGeometry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.CachedKernel
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The fixed trace and corresponding actual input carry the same literal
dimension occurrences. Their meanings may differ between interpretations. -/
def coupledRoles (roles : Nat → GraphNode) (i : Nat) : GraphNode :=
  if i = 15284 then { roles 15282 with graph := none }
  else if i = 15285 then { roles 15243 with graph := none }
  else if i = 15286 then { roles 1320 with graph := none }
  else roles i

theorem coupled_input_roles (roles : Nat → GraphNode) :
    inputRoles (replayRoles (coupledRoles roles)) trace.ins =
      inputRoles (replayRoles (coupledRoles roles)) inputs := by
  simp [inputRoles,trace,inputs,replayRoles,withReplayRole,coupledRoles,source_counter]

theorem selected_target {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (roles : Nat → GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (replayRoles (coupledRoles roles)) ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H liveNodes tail source target)
    (t' : Trace) (ht : TraceR R trace t') :
    findTrace target false (inputs.map R.node) [t'] = M.pure (some t') := by
  have traceLive : listSupport liveNodes trace.ins := by dsimp [trace,listSupport,liveNodes]; decide +kernel
  have inputLive : listSupport liveNodes inputs := by dsimp [inputs,listSupport,liveNodes]; decide +kernel
  obtain ⟨a,ha,_,hra⟩ := shapesOf_roles h trace.ins metadata traceLive source_trace_inputs
  obtain ⟨b,hb,hsource,hrb⟩ := shapesOf_roles h inputs metadata inputLive source_real_inputs
  have literal : Metadata.Literal (inputRoles (replayRoles (coupledRoles roles)) inputs) :=
    Metadata.literal_of_holds hsource
      ⟨⟨[1,1,48,128],rfl⟩,⟨[1,1,48,128],rfl⟩,⟨[128],rfl⟩,True.intro⟩
  rw [coupled_input_roles roles] at hra
  have equal := Metadata.literal_unique literal hra hrb
  rw [← equal] at hb
  apply findTrace_fixed_head_self target t' [] _ a
  · rw [ht.ins]; exact ha
  · exact hb

theorem source_closure : source.obj? 1352 = some (.clo (.compiled 281474976715599 payload false [trace])) := by rfl
theorem source_null_object : source.obj? 0 = none := by rfl
theorem source_handle_counter : source.next = 22018 := by rfl

theorem target_closure {NR : NumV → NumV → Prop} {R : Ren} {NodeRel : Nat → Node → Node → Prop}
    {H N : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live NR R NodeRel (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR NR R) H N tail source target) (hc : H 1352) :
    ∃ payload' t', target.obj? (R.handle 1352) =
      some (.clo (.compiled (R.region 281474976715599) payload' false [t'])) ∧ TraceR R trace t' := by
  have hr := h.objs 1352 hc
  change OptionR (Host.Mlx.Ffi.NativeRoles.ObjectR NR R) (source.obj? 1352) (target.obj? (R.handle 1352)) at hr
  rw [source_closure] at hr
  cases ho : target.obj? (R.handle 1352) with
  | none => rw [ho] at hr; cases hr
  | some obj =>
    rw [ho] at hr
    cases hr with
    | some hr => cases hr with
      | clo hr => cases hr with
        | compiled cb sl hp traces => cases traces with
          | cons ht rest => cases rest; exact ⟨_,_,rfl,ht⟩

/-- The complete target cached dispatcher is derived from fixed annotations,
the actual source plan and initial live resources. There is no target trace
selection, inference, recursive replay or whole-call premise. -/
theorem cached_call_paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (roles : Nat → GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (replayRoles (coupledRoles roles)) ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H liveNodes tail source target)
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
        (fun a => a = final.next ∨ H a) resultNodes tail
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
    (source_plan (coupledRoles roles) h).applyDone_fresh (fun _ _ _ h => h.base) h ht keys outs b off 0 0
      source_null_object hz (by rw [source_counter]; change 17777+1 < 2^64; decide +kernel) nodesBound
      (by rw [source_handle_counter]; decide +kernel) handlesBound
  have outputNodes : trace.outs.map (substOf finalMap) = [source.nnext] := by rfl
  rw [outputNodes] at hr hl
  refine ⟨replayedTarget,source_cached_call b off,?_,hl,hbytes⟩
  rw [call_closureApply,closureApply_cached target (output (R.a b) off) (R.a b) off 0
    (R.handle 1352) (R.handle 18221) (R.region 281474976715599) payload' false [t'] (inputs.map R.node) t'
    (output_slot (R.a b) off) hc (h.vec_view 18221 vectorLive inputs source_vector)
    (selected_target roles h t' ht)]
  exact hr

end Host.Load.Run.Full.CachedKernel
