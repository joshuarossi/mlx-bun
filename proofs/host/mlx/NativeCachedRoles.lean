import host.mlx.NativeTraceFits
import host.mlx.ReplayObjects
import host.mlx.ReplaySupport

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem compiled_single {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel : Nat → Node → Node → Prop} {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel (fun _ => ObjectR NR R) H N tail s s')
    (cls callback : Nat) (payload : Arg) (shapeless : Bool) (trace : Ffi.Trace) (held : H cls)
    (source : s.obj? cls = some (.clo (.compiled callback payload shapeless [trace]))) :
    ∃ payload' trace', s'.obj? (R.handle cls) =
      some (.clo (.compiled (R.region callback) payload' shapeless [trace'])) ∧ TraceR R trace trace' := by
  have hr := h.objs cls held
  change OptionR (ObjectR NR R) (s.obj? cls) (s'.obj? (R.handle cls)) at hr
  rw [source] at hr
  cases ho : s'.obj? (R.handle cls) with
  | none => rw [ho] at hr; cases hr
  | some obj =>
    rw [ho] at hr
    cases hr with
    | some hr => cases hr with
      | clo hr => cases hr with
        | compiled cb sl hp traces => cases traces with
          | cons ht rest => cases rest; exact ⟨_,_,rfl,ht⟩

/-- A checked source replay recipe and fixed input signature determine the
entire original cached call. All target closure/vector reads, trace selection,
replay steps and output writes are derived. The indexed object relation keeps
every captured callback/configuration field outside the result-vector slot. -/
theorem cached_existing_signature {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {H N K : Nat → Prop} {tail : List NumV} {s s' final : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (cls inv callback b off slot : Nat) (payload : Arg) (shapeless : Bool) (trace : Ffi.Trace)
    (xs old : List Nat) (substitutions : List (Nat × Nat)) (out out' : Arg)
    (closureLive : H cls) (inputsLive : H inv) (slotLive : H slot)
    (sourceClosure : s.obj? cls = some (.clo (.compiled callback payload shapeless [trace])))
    (sourceInputs : s.obj? inv = some (.vec xs)) (sourceOutput : s.obj? slot = some (.vec old))
    (sourceSlot : slotOf out = some (b,off,slot)) (targetSlot : slotOf out' = some (R.a b,off,R.handle slot))
    (traceSupport : listSupport N trace.ins) (inputsSupport : listSupport N xs)
    (signature : TraceSignature shapeless (inputRoles roles trace.ins) (inputRoles roles xs))
    (traceMeta inputsMeta : List (List Dim × Nat))
    (sourceTraceMeta : Ffi.shapesOf s trace.ins = some traceMeta) (sourceInputsMeta : Ffi.shapesOf s xs = some inputsMeta)
    (plan : ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary cls (NodeRel roles ν₀ ν C₀ C R boundary)
      N s (trace.ins.zip xs) trace.order K final substitutions)
    (keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) substitutions)
    (outputs : listSupport (· < final.nnext) trace.outs)
    (traceOutputsSupport : listSupport N trace.outs)
    (sourceNodes : s.nnext + trace.order.length < 2^64) (targetNodes : s'.nnext + trace.order.length < 2^64)
    (sourceSlotBound : slot < 2^64) (targetSlotBound : R.handle slot < 2^64) :
    ∃ final' : St,
      Ffi.call s chars!"mlx_closure_apply" [out,.big (Int.ofNat cls),.big (Int.ofNat inv)] =
        okW (final.setObj slot (.vec (trace.outs.map (substOf substitutions)))) status0 [u64Write b off slot] ∧
      Ffi.call s' chars!"mlx_closure_apply" [out',.big (Int.ofNat (R.handle cls)),.big (Int.ofNat (R.handle inv))] =
        okW (final'.setObj (R.handle slot) (.vec ((trace.outs.map (substOf substitutions)).map R.node)))
          status0 [u64Write (R.a b) off (R.handle slot)] ∧
      Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
        (ObjectRel (objectWrite objects slot (.vec (trace.outs.map (substOf substitutions)))) ν₀ ν C₀ C R) H K tail
        (final.setObj slot (.vec (trace.outs.map (substOf substitutions))))
        (final'.setObj (R.handle slot) (.vec ((trace.outs.map (substOf substitutions)).map R.node))) ∧
      ListR (ByteR (NumberRoles ν₀ ν C₀ C) R) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
        (cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0) ∧
      final'.objs = s'.objs ∧ final'.next = s'.next ∧
      (∀ i, N i → K i) ∧ listSupport K (trace.outs.map (substOf substitutions)) := by
  have weak := h.mono (fun _ _ p => p) (fun _ _ _ p => p) (fun _ _ _ p => p.base)
  obtain ⟨payload',trace',closure',traceRelated⟩ := weak.compiled_single cls callback payload shapeless trace closureLive sourceClosure
  obtain ⟨sourceSelected,targetSelected⟩ := h.findTrace_signature shapeless trace trace' xs traceRelated.ins
    traceSupport inputsSupport signature traceMeta inputsMeta sourceTraceMeta sourceInputsMeta
  have finalOutput : final.obj? slot = some (.vec old) := by
    change final.objs.get slot = _
    rw [plan.frames.1]
    exact sourceOutput
  obtain ⟨final',sourceApply,targetApply,post,bytes,objs,next⟩ := plan.applyDone_objects
    (fun _ _ _ p => p.base) (fun _ _ _ p => p.base) h traceRelated keys outputs b off slot old slotLive finalOutput
    (ObjectRel.write_vec objects ν₀ ν C₀ C R slot (trace.outs.map (substOf substitutions)))
    (fun _ ne _ _ p => ObjectRel.write_frame ne p) sourceNodes targetNodes sourceSlotBound targetSlotBound
  have support := plan.output_support (zip_support_right trace.ins xs inputsSupport) trace.outs traceOutputsSupport
  refine ⟨final',?_,?_,post,bytes,objs,next,support⟩
  · rw [call_closureApply,closureApply_cached s out b off slot cls inv callback payload shapeless [trace] xs trace
      sourceSlot sourceClosure sourceInputs sourceSelected]
    exact sourceApply
  · rw [call_closureApply,closureApply_cached s' out' (R.a b) off (R.handle slot) (R.handle cls) (R.handle inv)
      (R.region callback) payload' shapeless [trace'] (xs.map R.node) trace' targetSlot closure'
      (weak.vec_view inv inputsLive xs sourceInputs) targetSelected]
    exact targetApply

end Host.Mlx.Ffi.NativeRoles.Live
