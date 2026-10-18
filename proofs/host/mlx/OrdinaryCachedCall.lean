import host.mlx.OrdinaryCachedPlan
import host.ts.RenameKernelRfl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

noncomputable section

namespace Host.Load.Run.Full.Ordinary.CachedCall
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated



noncomputable def metadata : List (List Dim × Nat) := literalMetadata [([1,1,10240],12),([128],12),([128],12)]
noncomputable def payload : Arg := match source.obj? 1354 with
  | some (.clo (.compiled _ p _ _)) => p
  | _ => .null

theorem source_closure : source.obj? 1354 = some (.clo (.compiled 281474976715599 payload false [trace])) := by rfl
theorem source_vector : source.obj? 29376 = some (.vec inputs) := by rfl
theorem source_null_object : source.obj? 0 = none := by rfl
theorem source_counter : source.nnext = 22591 := by rfl
theorem source_handle_counter : source.next = 29378 := by rfl
theorem final_counter : s3.nnext = 22594 := by rfl
theorem source_trace_inputs : shapesOf source trace.ins = some metadata := by rfl
theorem source_real_inputs : shapesOf source inputs = some metadata := by rfl

theorem source_trace_selected : findTrace source false inputs [trace] = M.pure (some trace) :=
  findTrace_fixed_head_self source trace [] inputs metadata source_trace_inputs source_real_inputs

theorem source_replay : replay source 1354 trace inputs = M.pure (some (s3,[22591,22592,22593])) := by
  have order := (plan0 (ν₀ := fun _ => F64.zero false) (ν := fun _ => F64.zero false)
    (C₀ := ⟨[]⟩) (C := ⟨[]⟩) (R := Host.Ts.Owned.Annotated.identity) (fun _ => ⟨[],0,none⟩) (by intro a b ha hb h; exact h)).source
  change replayOrder s0 1354 m0 trace.order = M.pure (some (s3,m3)) at order
  unfold replay
  change ((replayOrder s0 1354 m0 trace.order).bind _) = _
  rw [order]
  rfl

noncomputable def actualBytes : List Byte := match (P.RestStream.micro0.micro23.s82.obj? 3126924).map Host.Ts.Obj.kind with
  | some (.buf bytes) => bytes
  | _ => []

noncomputable def outArg : Arg := .jsPtr 3126924 0 actualBytes

theorem actual_bytes : actualBytes = cellParts .u64 (.big (Int.ofNat 29377)) 8 0 := by host_kernel_rfl

theorem slot_parts (b off handle : Nat) :
    slotOf (.jsPtr b off (cellParts .u64 (.big (Int.ofNat handle)) 8 0)) = some (b,off,handle) := by rfl

theorem source_slot : slotOf outArg = some (3126924,0,29377) := by
  unfold outArg
  rw [actual_bytes]
  exact slot_parts _ _ _

theorem source_output_vector : source.obj? 29377 = some (.vec []) := by rfl

/-- The exact ordinary-body call overwrites its existing output vector. The
three nodes are replayed from the original stored compiled trace. -/
theorem source_cached_call :
    Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [outArg,.big 1354,.big 29376] =
      okW (s3.setObj 29377 (.vec [22591,22592,22593])) status0 [u64Write 3126924 0 29377] := by
  rw [call_closureApply]
  change closureApply source outArg (.big (Int.ofNat 1354)) (.big (Int.ofNat 29376)) = _
  rw [closureApply_cached source outArg 3126924 0 29377 1354 29376 281474976715599
    payload false [trace] inputs trace source_slot source_closure source_vector source_trace_selected]
  exact applyDone_existing source s3 1354 3126924 0 29377 trace inputs [] [22591,22592,22593]
    source_replay (by rfl)

noncomputable def coupledRoles (base : Nat → GraphNode) (i : Nat) : GraphNode :=
  if i = 15252 then { base 22590 with graph := none }
  else if i = 15253 then { base 10 with graph := none }
  else if i = 15254 then { base 11 with graph := none }
  else base i

theorem selected_target {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (base : Nat → GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (roles (coupledRoles base)) ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H N0 tail source target)
    (t' : Trace) (ht : TraceR R trace t') :
    findTrace target false (inputs.map R.node) [t'] = M.pure (some t') := by
  have traceLive : listSupport N0 trace.ins := by dsimp [trace,listSupport,N0]; decide +kernel
  have inputLive : listSupport N0 inputs := by dsimp [inputs,listSupport,N0]; decide +kernel
  obtain ⟨a,ha,_,hra⟩ := shapesOf_roles h trace.ins metadata traceLive source_trace_inputs
  obtain ⟨b,hb,hsource,hrb⟩ := shapesOf_roles h inputs metadata inputLive source_real_inputs
  have sameRoles : inputRoles (roles (coupledRoles base)) trace.ins = inputRoles (roles (coupledRoles base)) inputs := by
    simp [inputRoles,trace,inputs,roles,coupledRoles]
  rw [sameRoles] at hra
  have literal : Metadata.Literal (inputRoles (roles (coupledRoles base)) inputs) :=
    Metadata.literal_of_holds hsource ⟨⟨[1,1,10240],rfl⟩,⟨[128],rfl⟩,⟨[128],rfl⟩,True.intro⟩
  have equal := Metadata.literal_unique literal hra hrb
  rw [← equal] at hb
  apply findTrace_fixed_head_self target t' [] _ a
  · rw [ht.ins]; exact ha
  · exact hb

theorem target_closure {NR : NumV → NumV → Prop} {R : Ren} {NodeRel : Nat → Node → Node → Prop}
    {H N : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live NR R NodeRel (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR NR R) H N tail source target) (hc : H 1354) :
    ∃ payload' t', target.obj? (R.handle 1354) =
      some (.clo (.compiled (R.region 281474976715599) payload' false [t'])) ∧ TraceR R trace t' := by
  have hr := h.objs 1354 hc
  change OptionR (Host.Mlx.Ffi.NativeRoles.ObjectR NR R) (source.obj? 1354) (target.obj? (R.handle 1354)) at hr
  rw [source_closure] at hr
  cases ho : target.obj? (R.handle 1354) with
  | none => rw [ho] at hr; cases hr
  | some obj =>
    rw [ho] at hr
    cases hr with
    | some hr => cases hr with
      | clo hr => cases hr with
        | compiled cb sl hp traces => cases traces with
          | cons ht rest => cases rest; exact ⟨_,_,rfl,ht⟩

noncomputable def targetOutArg (R : Ren) : Arg :=
  .jsPtr (R.a 3126924) 0 (cellParts .u64 (.big (Int.ofNat (R.handle 29377))) 8 0)

/-- The actual ordinary invocation, related to any compatible native state.
All other live cache roots and handles survive, and the existing result slot
keeps its handle identity. -/
theorem cached_call_paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (frame : Nat → Prop) (base : Nat → GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (roles (coupledRoles base)) ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H (fun i => N0 i ∨ frame i) tail source target)
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
        (Host.Mlx.Ffi.Annotated.NodeRel (roles (coupledRoles base)) ν₀ ν C₀ C R boundary)
        (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R)
        H (fun i => N3 i ∨ frame i) tail
        (s3.setObj 29377 (.vec [22591,22592,22593]))
        (replayedTarget.setObj (R.handle 29377) (.vec ([22591,22592,22593].map R.node))) ∧
      ListR (Host.Ts.Owned.Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R)
        actualBytes (cellParts .u64 (.big (Int.ofNat (R.handle 29377))) 8 0) := by
  obtain ⟨payload',t',hc,ht⟩ := target_closure h closureLive
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
  obtain ⟨replayedTarget,_,hr,hl,hbytes⟩ :=
    ((plan0 (coupledRoles base) h.nodeMap.injective).frame frame).applyDone_existing
      (fun _ _ _ h => h.base) h ht keys outs 3126924 0 29377 [] outputLive (by rfl)
      (by change 22591+3 < 2^64; decide +kernel) nodesBound (by decide +kernel) targetSlotBound
  have outputNodes : trace.outs.map (substOf m3) = [22591,22592,22593] := by rfl
  rw [outputNodes] at hr hl
  refine ⟨replayedTarget,source_cached_call,?_,hl,?_⟩
  · rw [call_closureApply,closureApply_cached target (targetOutArg R) (R.a 3126924) 0
      (R.handle 29377) (R.handle 1354) (R.handle 29376) (R.region 281474976715599)
      payload' false [t'] (inputs.map R.node) t' (slot_parts _ _ _) hc
      (h.vec_view 29376 vectorLive inputs source_vector)
      (selected_target base (h.onlyNodes (fun _ hi => .inl hi)) t' ht)]
    exact hr
  · rw [actual_bytes]
    exact hbytes

end Host.Load.Run.Full.Ordinary.CachedCall
