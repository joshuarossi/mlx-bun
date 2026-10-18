import host.mlx.NativeReplayFreshObjects
import host.mlx.NativeCachedRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- The null-slot cached branch derives target closure/vector lookup, trace
selection, replay, and fresh result allocation from current strong indexed
annotations. Every captured object is retained and producer closure grows by
the checked replay and its actual returned vector. -/
theorem cached_fresh_signature {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {objects : Nat → Object} {boundary roots H N K : Nat → Prop}
    {tail : List NumV} {source target final : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail source target)
    (policy : ProducerAnnotations roots H N roles objects)
    (closure vector callback buffer offset slot : Nat) (payload : Arg) (shapeless : Bool) (trace : Ffi.Trace)
    (inputs : List Nat) (substitutions : List (Nat × Nat)) (out out' : Arg)
    (closureLive : H closure) (vectorLive : H vector) (slotLive : H slot)
    (sourceClosure : source.obj? closure = some (.clo (.compiled callback payload shapeless [trace])))
    (sourceVector : source.obj? vector = some (.vec inputs)) (sourceSlotAbsent : source.obj? slot = none)
    (sourceSlot : slotOf out = some (buffer,offset,slot)) (targetSlot : slotOf out' = some (R.a buffer,offset,R.handle slot))
    (signature : TraceSignature shapeless (inputRoles roles trace.ins) (inputRoles roles inputs))
    (capturedMeta inputMeta : List (List Dim × Nat))
    (capturedRead : Ffi.shapesOf source trace.ins = some capturedMeta) (inputsRead : Ffi.shapesOf source inputs = some inputMeta)
    (plan : ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary closure (NodeRel roles ν₀ ν C₀ C R boundary)
      N source (trace.ins.zip inputs) trace.order K final substitutions)
    (keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) substitutions)
    (outputs : listSupport (· < final.nnext) trace.outs)
    (sourceNodes : source.nnext + trace.order.length < 2^64) (targetNodes : target.nnext + trace.order.length < 2^64)
    (sourceHandles : source.next < 2^64) (targetHandles : target.next < 2^64) :
    let nodes := trace.outs.map (substOf substitutions)
    let newObjects := objectWrite objects final.next (.vec nodes)
    ∃ final' : St,
      Ffi.call source chars!"mlx_closure_apply" [out,.big (Int.ofNat closure),.big (Int.ofNat vector)] =
        okW (final.newObj (.vec nodes)).2 status0 [u64Write buffer offset final.next] ∧
      Ffi.call target chars!"mlx_closure_apply" [out',.big (Int.ofNat (R.handle closure)),.big (Int.ofNat (R.handle vector))] =
        okW (final'.newObj (.vec (nodes.map R.node))).2 status0 [u64Write (R.a buffer) offset final'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
        (ObjectRel newObjects ν₀ ν C₀ C R) (fun i => i = final.next ∨ H i) K tail
        (final.newObj (.vec nodes)).2 (final'.newObj (.vec (nodes.map R.node))).2 ∧
      ProducerAnnotations roots (fun i => i = final.next ∨ H i) K roles newObjects ∧
      ProducerSupport roots (fun i => i = final.next ∨ H i) K (final.newObj (.vec nodes)).2 ∧
      ListR (Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R) (cellParts .u64 (.big (Int.ofNat final.next)) 8 0)
        (cellParts .u64 (.big (Int.ofNat final'.next)) 8 0) := by
  dsimp only
  have held := policy.source h
  have support := held.single_trace closure callback payload shapeless trace closureLive sourceClosure
  have inputsHeld := held.vector vector inputs vectorLive sourceVector
  have weak := h.mono (fun _ _ held => held) (fun _ _ _ held => held) (fun _ _ _ held => held.base)
  obtain ⟨payload',trace',closureRead,traceRelated⟩ := weak.compiled_single closure callback payload shapeless trace closureLive sourceClosure
  obtain ⟨sourceSelected,targetSelected⟩ := h.findTrace_signature shapeless trace trace' inputs traceRelated.ins
    support.inputs inputsHeld signature capturedMeta inputMeta capturedRead inputsRead
  obtain ⟨final',left,right,post,policyPost,supportPost,bytes⟩ := plan.applyDone_fresh_policy h policy traceRelated
    inputsHeld support.outputs keys outputs buffer offset slot slotLive sourceSlotAbsent sourceNodes targetNodes sourceHandles targetHandles
  refine ⟨final',?_,?_,post,policyPost,supportPost,bytes⟩
  · rw [call_closureApply,closureApply_cached source out buffer offset slot closure vector callback payload shapeless [trace] inputs trace
      sourceSlot sourceClosure sourceVector sourceSelected]
    exact left
  · rw [call_closureApply,closureApply_cached target out' (R.a buffer) offset (R.handle slot)
      (R.handle closure) (R.handle vector) (R.region callback) payload' shapeless [trace'] (inputs.map R.node) trace'
      targetSlot closureRead (weak.vec_view vector vectorLive inputs sourceVector) targetSelected]
    exact right

end Host.Mlx.Ffi.NativeRoles.Live
