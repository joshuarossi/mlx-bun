import host.load.run.full.FirstChoice
import host.mlx.AnnotatedReplay
import host.mlx.CachedReplay
import host.mlx.TraceSelection

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.CachedKernel
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles
open Host.Ts.Owned.Parametric

def source : Host.Mlx.Ffi.St := firstChoice.graph
def trace : Trace := ⟨[15284,15285,15286],[15287],[15287]⟩
def inputs : List Nat := [15282,15243,1320]
def substitutions : List (Nat × Nat) := trace.ins.zip inputs
def captured : Node := (source.nodes.get 15287).getD ⟨.zeros,[],[],0⟩
def rebuilt : Node := ⟨.replayed 1352 captured.prim,captured.ins.map (substOf substitutions),captured.shape,captured.dtype⟩
def final : Host.Mlx.Ffi.St := (source.addNode rebuilt).2
def finalMap : List (Nat × Nat) := (15287,source.nnext)::substitutions
def liveNodes (i : Nat) : Prop := i = 15287 ∨ i = 15284 ∨ i = 15285 ∨ i = 15286 ∨
  i = 15282 ∨ i = 15243 ∨ i = 1320
def boundary (i : Nat) : Prop := i ≠ 15287
def resultNodes (i : Nat) : Prop := i = source.nnext ∨ liveNodes i
def output (b off : Nat) : Arg := .jsPtr b off (List.replicate 8 (.lit 0))
def payload : Arg := match source.obj? 1352 with
  | some (.clo (.compiled _ p _ _)) => p
  | _ => .null

theorem captured_lookup : source.nodes.get 15287 = some captured := by rfl
theorem captured_kernel : isKernel captured.prim = true := by rfl
theorem captured_inputs : captured.ins = trace.ins := by rfl
theorem substituted_inputs : captured.ins.map (substOf substitutions) = inputs := by rfl
theorem source_counter : source.nnext = 17777 := by rfl
theorem output_slot (b off : Nat) : slotOf (output b off) = some (b,off,0) := by rfl

def metadata : List (List Dim × Nat) :=
  [([.lit 1,.lit 1,.lit 48,.lit 128],12),([.lit 1,.lit 1,.lit 48,.lit 128],12),([.lit 128],12)]

theorem source_trace_inputs : shapesOf source trace.ins = some metadata := by rfl
theorem source_real_inputs : shapesOf source inputs = some metadata := by rfl
theorem source_vector : source.obj? 18221 = some (.vec inputs) := by rfl
theorem source_trace_selected : findTrace source false inputs [trace] = M.pure (some trace) :=
  findTrace_fixed_head_self source trace [] inputs metadata source_trace_inputs source_real_inputs

theorem source_replay : replay source 1352 trace inputs = M.pure (some (final,[source.nnext])) := by
  have order : replayOrder source 1352 substitutions trace.order = M.pure (some (final,finalMap)) := by
    change replayOrder source 1352 substitutions [15287] = _
    rw [replay_kernel_head source 1352 15287 substitutions [] captured captured_lookup captured_kernel]
    rfl
  unfold replay
  change ((replayOrder source 1352 substitutions trace.order).bind _) = _
  rw [order]
  rfl

/-- An invocation using a matching vector present in the exact first-yield
native graph takes its existing fixed-signature cache and writes a fresh vector.
This theorem does not assert that the invocation is the next TypeScript call. -/
theorem source_cached_call (b off : Nat) :
    Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [output b off,.big 1352,.big 18221] =
      okW (final.newObj (.vec [source.nnext])).2 status0 [u64Write b off source.next] := by
  rw [call_closureApply]
  change closureApply source (output b off) (.big (Int.ofNat 1352)) (.big (Int.ofNat 18221)) = _
  have closure : source.obj? 1352 = some (.clo (.compiled 281474976715599
      payload false [trace])) := by rfl
  rw [closureApply_cached source (output b off) b off 0 1352 18221 281474976715599
    payload false [trace] inputs trace (output_slot b off) closure source_vector source_trace_selected]
  rw [applyDone_fresh source final 1352 b off 0 trace inputs [source.nnext] source_replay (by rfl)]
  rfl

def replayRoles (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode) : Nat → Host.Mlx.Ffi.Annotated.GraphNode :=
  Host.Mlx.Ffi.Annotated.withReplayRole roles 15287 source.nnext 1352 (captured.ins.map (substOf substitutions))

/-- The concrete source trace instantiates the recursive replay schema. Its
only local allocation witness is derived from the fixed captured annotation. -/
theorem source_plan {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (replayRoles roles) ν₀ ν C₀ C R boundary)
      (fun _ => ObjectR (NumberRoles ν₀ ν C₀ C) R) H liveNodes tail source target) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 1352
      (Host.Mlx.Ffi.Annotated.NodeRel (replayRoles roles) ν₀ ν C₀ C R boundary)
      liveNodes source substitutions trace.order resultNodes final finalMap := by
  have full : ¬ boundary 15287 := by intro hn; exact hn rfl
  have insLive : listSupport liveNodes captured.ins := by
    rw [captured_inputs]
    dsimp [trace,listSupport,liveNodes]
    decide +kernel
  have insBound : listSupport (· < source.nnext) captured.ins := by
    rw [captured_inputs,source_counter]
    dsimp [trace,listSupport]
    decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < source.nnext) substitutions := by
    rw [source_counter]
    dsimp [substitutions,trace,inputs,listSupport]
    decide +kernel
  apply ReplayPlan.kernel captured (.inl rfl) full captured_lookup captured_kernel insLive keys
  · intro nd' hr
    have graph := hr.base.graph.resolve_left full
    have mapped : nd'.ins.map (substOf (mapSubst R.node substitutions)) =
        (captured.ins.map (substOf substitutions)).map R.node := by
      rw [graph.2]
      exact subst_inputs_map R.node source.nnext h.nodeMap.injective substitutions keys captured.ins insBound
    exact hr.fresh_replayed (by rw [source_counter]; decide +kernel) full mapped
  · exact .done _ _ _

theorem replay_paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode) {H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel (replayRoles roles) ν₀ ν C₀ C R boundary)
      (fun _ => ObjectR (NumberRoles ν₀ ν C₀ C) R) H liveNodes tail source target)
    (bound : target.nnext + trace.order.length < 2^64) :
    ∃ final',
      replayOrder source 1352 substitutions trace.order = M.pure (some (final,finalMap)) ∧
      replayOrder target (R.handle 1352) (mapSubst R.node substitutions) (trace.order.map R.node) =
        M.pure (some (final',mapSubst R.node finalMap)) ∧
      Live (NumberRoles ν₀ ν C₀ C) R (Host.Mlx.Ffi.Annotated.NodeRel (replayRoles roles) ν₀ ν C₀ C R boundary)
        (fun _ => ObjectR (NumberRoles ν₀ ν C₀ C) R) H resultNodes tail final final' ∧
      final'.objs = target.objs ∧ final'.next = target.next :=
  (source_plan roles h).paired (fun _ _ _ hr => hr.base) h
    (by rw [source_counter]; change 17777 + 1 < 2^64; decide +kernel) bound

end Host.Load.Run.Full.CachedKernel
