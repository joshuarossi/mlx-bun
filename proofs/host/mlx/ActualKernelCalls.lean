import host.mlx.ActualKernelPlans
import host.mlx.ReplaySource
import host.mlx.ReplayFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Kernel1354
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev output := CachedKernel.output

def metadata : List (List Dim × Nat) := literalMetadata [([1,1,10240],12),([128],12),([128],12)]
def payload : Arg := match source.obj? 1354 with
  | some (.clo (.compiled _ p _ _)) => p
  | _ => .null

theorem source_closure : source.obj? 1354 = some (.clo (.compiled 281474976715599 payload false [trace])) := by rfl
theorem source_vector : source.obj? 18173 = some (.vec inputs) := by rfl
theorem source_null_object : source.obj? 0 = none := by rfl
theorem source_counter : source.nnext = 17777 := by rfl
theorem source_handle_counter : source.next = 22018 := by rfl
theorem final_counter : s3.nnext = 17780 := by rfl
theorem source_trace_inputs : shapesOf source trace.ins = some metadata := by rfl
theorem source_real_inputs : shapesOf source inputs = some metadata := by rfl

theorem source_trace_selected : findTrace source false inputs [trace] = M.pure (some trace) :=
  findTrace_fixed_head_self source trace [] inputs metadata source_trace_inputs source_real_inputs

theorem source_replay : replay source 1354 trace inputs = M.pure (some (s3,[17777,17778,17779])) := by
  have order := (plan0 (ν₀ := fun _ => F64.zero false) (ν := fun _ => F64.zero false)
    (C₀ := ⟨[]⟩) (C := ⟨[]⟩) (R := Host.Ts.Owned.Annotated.identity) (fun _ => ⟨[],0,none⟩) (by intro a b ha hb h; exact h)).source
  change replayOrder s0 1354 m0 trace.order = M.pure (some (s3,m3)) at order
  unfold replay
  change ((replayOrder s0 1354 m0 trace.order).bind _) = _
  rw [order]
  rfl

/-- The actual first-yield native state contains this shapeless trace and a
matching input vector. Its invocation uses the cached path with fresh nodes for each cached kernel output. -/
theorem source_cached_call (b off : Nat) :
    Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [output b off,.big 1354,.big 18173] =
      okW (s3.newObj (.vec [17777,17778,17779])).2 status0 [u64Write b off source.next] := by
  rw [call_closureApply]
  change closureApply source (output b off) (.big (Int.ofNat 1354)) (.big (Int.ofNat 18173)) = _
  rw [closureApply_cached source (output b off) b off 0 1354 18173 281474976715599
    payload false [trace] inputs trace (CachedKernel.output_slot b off) source_closure source_vector source_trace_selected]
  rw [applyDone_fresh source s3 1354 b off 0 trace inputs [17777,17778,17779] source_replay (by rfl)]
  rfl

def coupledRoles (base : Nat → GraphNode) (i : Nat) : GraphNode :=
  if i = 15252 then { base 15251 with graph := none }
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

/-- Original source and target cached calls follow from the fixed actual trace
plan and initial resource relation. Target selection, inference and recursive
execution are conclusions; the native readback suffix remains arbitrary. -/
theorem cached_call_framed {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (frame : Nat → Prop) (base : Nat → GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (roles (coupledRoles base)) ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H (fun i => N0 i ∨ frame i) tail source target)
    (closureLive : H 1354) (vectorLive : H 18173) (nullLive : H 0)
    (nodesBound : target.nnext + trace.order.length < 2^64) (handlesBound : target.next < 2^64)
    (b off : Nat) :
    ∃ replayedTarget : Host.Mlx.Ffi.St,
      Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [output b off,.big 1354,.big 18173] =
        okW (s3.newObj (.vec [17777,17778,17779])).2 status0 [u64Write b off source.next] ∧
      Host.Mlx.Ffi.call target chars!"mlx_closure_apply"
          [output (R.a b) off,.big (Int.ofNat (R.handle 1354)),.big (Int.ofNat (R.handle 18173))] =
        okW (replayedTarget.newObj (.vec ([17777,17778,17779].map R.node))).2 status0
          [u64Write (R.a b) off replayedTarget.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (Host.Mlx.Ffi.Annotated.NodeRel (roles (coupledRoles base)) ν₀ ν C₀ C R boundary)
        (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R)
        (fun a => a = s3.next ∨ H a) (fun i => N3 i ∨ frame i) tail
        (s3.newObj (.vec [17777,17778,17779])).2
        (replayedTarget.newObj (.vec ([17777,17778,17779].map R.node))).2 ∧
      ListR (Host.Ts.Owned.Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R)
        (cellParts .u64 (.big (Int.ofNat s3.next)) 8 0)
        (cellParts .u64 (.big (Int.ofNat replayedTarget.next)) 8 0) := by
  obtain ⟨payload',t',hc,ht⟩ := target_closure h closureLive
  have hz : target.obj? 0 = none := by
    have ho := h.objs 0 nullLive
    change OptionR (Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) (source.obj? 0) (target.obj? (R.handle 0)) at ho
    rw [source_null_object,h.handleZero] at ho
    cases ht : target.obj? 0 with
    | none => rfl
    | some obj => rw [ht] at ho; cases ho
  have keys : listSupport (fun p : Nat × Nat => p.1 < s3.nnext) m3 := by
    change listSupport (fun p : Nat × Nat => p.1 < 17780)
      [(15257,17779),(15256,17778),(15255,17777),(15252,15251),(15253,10),(15254,11)]
    dsimp [listSupport]; decide +kernel
  have outs : listSupport (· < s3.nnext) trace.outs := by
    change listSupport (· < 17780) [15255,15256,15257]
    dsimp [listSupport]
    decide +kernel
  obtain ⟨replayedTarget,_,hr,hl,hbytes⟩ :=
    ((plan0 (coupledRoles base) h.nodeMap.injective).frame frame).applyDone_fresh (fun _ _ _ h => h.base) h ht keys outs b off 0 0
      source_null_object hz (by change 17777+3 < 2^64; decide +kernel) nodesBound
      (by change 22018 < 2^64; decide +kernel) handlesBound
  have outputNodes : trace.outs.map (substOf m3) = [17777,17778,17779] := by rfl
  rw [outputNodes] at hr hl
  refine ⟨replayedTarget,source_cached_call b off,?_,hl,hbytes⟩
  rw [call_closureApply,closureApply_cached target (output (R.a b) off) (R.a b) off 0
    (R.handle 1354) (R.handle 18173) (R.region 281474976715599) payload' false [t'] (inputs.map R.node) t'
    (CachedKernel.output_slot (R.a b) off) hc (h.vec_view 18173 vectorLive inputs source_vector)
    (selected_target base (h.onlyNodes (fun _ hi => .inl hi)) t' ht)]
  exact hr

end Host.Load.Run.Full.Kernel1354

namespace Host.Load.Run.Full.Kernel1362
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev output := CachedKernel.output

def metadata : List (List Dim × Nat) := literalMetadata [([1,1,5120],12),([1,1,5120],12),([5120],12)]
def payload : Arg := match source.obj? 1362 with
  | some (.clo (.compiled _ p _ _)) => p
  | _ => .null

theorem source_closure : source.obj? 1362 = some (.clo (.compiled 281474976715599 payload false [trace])) := by rfl
theorem source_vector : source.obj? 18238 = some (.vec inputs) := by rfl
theorem source_null_object : source.obj? 0 = none := by rfl
theorem source_counter : source.nnext = 17777 := by rfl
theorem source_handle_counter : source.next = 22018 := by rfl
theorem final_counter : s2.nnext = 17779 := by rfl
theorem source_trace_inputs : shapesOf source trace.ins = some metadata := by rfl
theorem source_real_inputs : shapesOf source inputs = some metadata := by rfl

theorem source_trace_selected : findTrace source false inputs [trace] = M.pure (some trace) :=
  findTrace_fixed_head_self source trace [] inputs metadata source_trace_inputs source_real_inputs

theorem source_replay : replay source 1362 trace inputs = M.pure (some (s2,[17777,17778])) := by
  have order := (plan0 (ν₀ := fun _ => F64.zero false) (ν := fun _ => F64.zero false)
    (C₀ := ⟨[]⟩) (C := ⟨[]⟩) (R := Host.Ts.Owned.Annotated.identity) (fun _ => ⟨[],0,none⟩) (by intro a b ha hb h; exact h)).source
  change replayOrder s0 1362 m0 trace.order = M.pure (some (s2,m2)) at order
  unfold replay
  change ((replayOrder s0 1362 m0 trace.order).bind _) = _
  rw [order]
  rfl

/-- The actual first-yield native state contains this shapeless trace and a
matching input vector. Its invocation uses the cached path with fresh nodes for each cached kernel output. -/
theorem source_cached_call (b off : Nat) :
    Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [output b off,.big 1362,.big 18238] =
      okW (s2.newObj (.vec [17777,17778])).2 status0 [u64Write b off source.next] := by
  rw [call_closureApply]
  change closureApply source (output b off) (.big (Int.ofNat 1362)) (.big (Int.ofNat 18238)) = _
  rw [closureApply_cached source (output b off) b off 0 1362 18238 281474976715599
    payload false [trace] inputs trace (CachedKernel.output_slot b off) source_closure source_vector source_trace_selected]
  rw [applyDone_fresh source s2 1362 b off 0 trace inputs [17777,17778] source_replay (by rfl)]
  rfl

def coupledRoles (base : Nat → GraphNode) (i : Nat) : GraphNode :=
  if i = 15291 then { base 15239 with graph := none }
  else if i = 15292 then { base 15290 with graph := none }
  else if i = 15293 then { base 1326 with graph := none }
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
    Metadata.literal_of_holds hsource ⟨⟨[1,1,5120],rfl⟩,⟨[1,1,5120],rfl⟩,⟨[5120],rfl⟩,True.intro⟩
  have equal := Metadata.literal_unique literal hra hrb
  rw [← equal] at hb
  apply findTrace_fixed_head_self target t' [] _ a
  · rw [ht.ins]; exact ha
  · exact hb

theorem target_closure {NR : NumV → NumV → Prop} {R : Ren} {NodeRel : Nat → Node → Node → Prop}
    {H N : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live NR R NodeRel (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR NR R) H N tail source target) (hc : H 1362) :
    ∃ payload' t', target.obj? (R.handle 1362) =
      some (.clo (.compiled (R.region 281474976715599) payload' false [t'])) ∧ TraceR R trace t' := by
  have hr := h.objs 1362 hc
  change OptionR (Host.Mlx.Ffi.NativeRoles.ObjectR NR R) (source.obj? 1362) (target.obj? (R.handle 1362)) at hr
  rw [source_closure] at hr
  cases ho : target.obj? (R.handle 1362) with
  | none => rw [ho] at hr; cases hr
  | some obj =>
    rw [ho] at hr
    cases hr with
    | some hr => cases hr with
      | clo hr => cases hr with
        | compiled cb sl hp traces => cases traces with
          | cons ht rest => cases rest; exact ⟨_,_,rfl,ht⟩

/-- Original source and target cached calls follow from the fixed actual trace
plan and initial resource relation. Target selection, inference and recursive
execution are conclusions; the native readback suffix remains arbitrary. -/
theorem cached_call_framed {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (frame : Nat → Prop) (base : Nat → GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (roles (coupledRoles base)) ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H (fun i => N0 i ∨ frame i) tail source target)
    (closureLive : H 1362) (vectorLive : H 18238) (nullLive : H 0)
    (nodesBound : target.nnext + trace.order.length < 2^64) (handlesBound : target.next < 2^64)
    (b off : Nat) :
    ∃ replayedTarget : Host.Mlx.Ffi.St,
      Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [output b off,.big 1362,.big 18238] =
        okW (s2.newObj (.vec [17777,17778])).2 status0 [u64Write b off source.next] ∧
      Host.Mlx.Ffi.call target chars!"mlx_closure_apply"
          [output (R.a b) off,.big (Int.ofNat (R.handle 1362)),.big (Int.ofNat (R.handle 18238))] =
        okW (replayedTarget.newObj (.vec ([17777,17778].map R.node))).2 status0
          [u64Write (R.a b) off replayedTarget.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (Host.Mlx.Ffi.Annotated.NodeRel (roles (coupledRoles base)) ν₀ ν C₀ C R boundary)
        (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R)
        (fun a => a = s2.next ∨ H a) (fun i => N2 i ∨ frame i) tail
        (s2.newObj (.vec [17777,17778])).2
        (replayedTarget.newObj (.vec ([17777,17778].map R.node))).2 ∧
      ListR (Host.Ts.Owned.Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R)
        (cellParts .u64 (.big (Int.ofNat s2.next)) 8 0)
        (cellParts .u64 (.big (Int.ofNat replayedTarget.next)) 8 0) := by
  obtain ⟨payload',t',hc,ht⟩ := target_closure h closureLive
  have hz : target.obj? 0 = none := by
    have ho := h.objs 0 nullLive
    change OptionR (Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) (source.obj? 0) (target.obj? (R.handle 0)) at ho
    rw [source_null_object,h.handleZero] at ho
    cases ht : target.obj? 0 with
    | none => rfl
    | some obj => rw [ht] at ho; cases ho
  have keys : listSupport (fun p : Nat × Nat => p.1 < s2.nnext) m2 := by
    change listSupport (fun p : Nat × Nat => p.1 < 17779)
      [(15295,17778),(15294,17777),(15291,15239),(15292,15290),(15293,1326)]
    dsimp [listSupport]; decide +kernel
  have outs : listSupport (· < s2.nnext) trace.outs := by
    change listSupport (· < 17779) [15294,15295]
    dsimp [listSupport]
    decide +kernel
  obtain ⟨replayedTarget,_,hr,hl,hbytes⟩ :=
    ((plan0 (coupledRoles base) h.nodeMap.injective).frame frame).applyDone_fresh (fun _ _ _ h => h.base) h ht keys outs b off 0 0
      source_null_object hz (by change 17777+2 < 2^64; decide +kernel) nodesBound
      (by change 22018 < 2^64; decide +kernel) handlesBound
  have outputNodes : trace.outs.map (substOf m2) = [17777,17778] := by rfl
  rw [outputNodes] at hr hl
  refine ⟨replayedTarget,source_cached_call b off,?_,hl,hbytes⟩
  rw [call_closureApply,closureApply_cached target (output (R.a b) off) (R.a b) off 0
    (R.handle 1362) (R.handle 18238) (R.region 281474976715599) payload' false [t'] (inputs.map R.node) t'
    (CachedKernel.output_slot (R.a b) off) hc (h.vec_view 18238 vectorLive inputs source_vector)
    (selected_target base (h.onlyNodes (fun _ hi => .inl hi)) t' ht)]
  exact hr

end Host.Load.Run.Full.Kernel1362

