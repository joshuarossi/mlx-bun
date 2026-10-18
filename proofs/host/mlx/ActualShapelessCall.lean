import host.mlx.ActualShapelessPlan
import host.mlx.ReplaySource

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Shapeless
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev output := CachedKernel.output

def metadata : List (List Dim × Nat) := literalMetadata [([48],12),([1,1,48],12),([48],12)]
def payload : Arg := match source.obj? 18194 with
  | some (.clo (.compiled _ p _ _)) => p
  | _ => .null

theorem source_closure : source.obj? 18194 = some (.clo (.compiled 281474976715599 payload true [trace])) := by rfl
theorem source_vector : source.obj? 18195 = some (.vec inputs) := by rfl
theorem source_null_object : source.obj? 0 = none := by rfl
theorem source_counter : source.nnext = 17777 := by rfl
theorem source_handle_counter : source.next = 22018 := by rfl
theorem final_counter : s8.nnext = 17784 := by rfl
theorem source_trace_inputs : shapesOf source trace.ins = some metadata := by rfl
theorem source_real_inputs : shapesOf source inputs = some metadata := by rfl

theorem source_trace_selected : findTrace source true inputs [trace] = M.pure (some trace) := by
  rw [findTrace,traceFits_shapeless source trace inputs metadata metadata source_trace_inputs source_real_inputs]
  rfl

theorem source_replay : replay source 18194 trace inputs = M.pure (some (s8,[17783])) := by
  have order := (plan0 (ν₀ := fun _ => F64.zero false) (ν := fun _ => F64.zero false)
    (C₀ := ⟨[]⟩) (C := ⟨[]⟩) (R := Host.Ts.Owned.Annotated.identity) (fun _ => ⟨[],0,none⟩)).source
  change replayOrder s0 18194 m0 trace.order = M.pure (some (s8,m8)) at order
  unfold replay
  change ((replayOrder s0 18194 m0 trace.order).bind _) = _
  rw [order]
  rfl

/-- The actual first-yield native state contains this shapeless trace and a
matching input vector. Its invocation uses the cached path with seven fresh
inferred nodes and one shared data leaf. -/
theorem source_cached_call (b off : Nat) :
    Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [output b off,.big 18194,.big 18195] =
      okW (s8.newObj (.vec [17783])).2 status0 [u64Write b off source.next] := by
  rw [call_closureApply]
  change closureApply source (output b off) (.big (Int.ofNat 18194)) (.big (Int.ofNat 18195)) = _
  rw [closureApply_cached source (output b off) b off 0 18194 18195 281474976715599
    payload true [trace] inputs trace (CachedKernel.output_slot b off) source_closure source_vector source_trace_selected]
  rw [applyDone_fresh source s8 18194 b off 0 trace inputs [17783] source_replay (by rfl)]
  rfl

theorem selected_target {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (base : Nat → GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H N0 tail source target)
    (t' : Trace) (ht : TraceR R trace t') :
    findTrace target true (inputs.map R.node) [t'] = M.pure (some t') := by
  have traceLive : listSupport N0 trace.ins := by dsimp [trace,listSupport,N0]; decide +kernel
  have inputLive : listSupport N0 inputs := by dsimp [inputs,listSupport,N0]; decide +kernel
  have erased := h.mono (fun _ _ r => r) (fun _ _ _ r => r.base) (fun _ _ _ r => r)
  have fits := erased.traceFits_shapeless trace t' ht inputs metadata metadata source_trace_inputs source_real_inputs traceLive inputLive
  rw [findTrace,fits.2]
  rfl

theorem target_closure {NR : NumV → NumV → Prop} {R : Ren} {NodeRel : Nat → Node → Node → Prop}
    {H N : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live NR R NodeRel (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR NR R) H N tail source target) (hc : H 18194) :
    ∃ payload' t', target.obj? (R.handle 18194) =
      some (.clo (.compiled (R.region 281474976715599) payload' true [t'])) ∧ TraceR R trace t' := by
  have hr := h.objs 18194 hc
  change OptionR (Host.Mlx.Ffi.NativeRoles.ObjectR NR R) (source.obj? 18194) (target.obj? (R.handle 18194)) at hr
  rw [source_closure] at hr
  cases ho : target.obj? (R.handle 18194) with
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
theorem cached_call_paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (base : Nat → GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      (fun _ => Host.Mlx.Ffi.NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R) H N0 tail source target)
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
        (fun a => a = s8.next ∨ H a) N8 tail
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
    (plan0 base).applyDone_fresh (fun _ _ _ h => h.base) h ht keys outs b off 0 0
      source_null_object hz (by change 17777+8 < 2^64; decide +kernel) nodesBound
      (by change 22018 < 2^64; decide +kernel) handlesBound
  have outputNodes : trace.outs.map (substOf m8) = [17783] := by rfl
  rw [outputNodes] at hr hl
  refine ⟨replayedTarget,source_cached_call b off,?_,hl,hbytes⟩
  rw [call_closureApply,closureApply_cached target (output (R.a b) off) (R.a b) off 0
    (R.handle 18194) (R.handle 18195) (R.region 281474976715599) payload' true [t'] (inputs.map R.node) t'
    (CachedKernel.output_slot (R.a b) off) hc (h.vec_view 18195 vectorLive inputs source_vector)
    (selected_target base h t' ht)]
  exact hr

end Host.Load.Run.Full.Shapeless
