import host.mlx.NativeReplayPolicy
import host.mlx.ReplayObjects

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

/-- The original null-slot result allocation keeps every current fixed native
object annotation. The new vector receives its predetermined producer list;
its handle and write bytes follow from the current allocation counters. -/
theorem ReplayPlan.applyDone_fresh_objects {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {ObjRel ObjRel' : Nat → Obj → Obj → Prop}
    {cls : Nat} {N K : Nat → Prop} {source final : St} {substitutions : List (Nat × Nat)}
    {trace targetTrace : Trace} {inputs : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N source (trace.ins.zip inputs) trace.order K final substitutions)
    (base : ∀ i n n', NodeRel i n n' → NodeR NR R (PrimR NR R) boundary i n n')
    (objects : ∀ i x y, ObjRel i x y → ObjectR NR R x y)
    {H : Nat → Prop} {tail : List NumV} {target : St}
    (h : Live NR R NodeRel ObjRel H N tail source target) (traceRelated : TraceR R trace targetTrace)
    (keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) substitutions)
    (outputs : listSupport (· < final.nnext) trace.outs)
    (buffer offset slot : Nat) (slotLive : H slot) (slotAbsent : source.obj? slot = none)
    (created : ObjRel' final.next (.vec (trace.outs.map (substOf substitutions)))
      (.vec ((trace.outs.map (substOf substitutions)).map R.node)))
    (frame : ∀ i, i ≠ final.next → ∀ x y, ObjRel i x y → ObjRel' i x y)
    (sourceNodes : source.nnext + trace.order.length < 2^64) (targetNodes : target.nnext + trace.order.length < 2^64)
    (sourceHandles : source.next < 2^64) (targetHandles : target.next < 2^64) :
    ∃ final' : St,
      applyDone source cls buffer offset slot trace inputs =
        okW (final.newObj (.vec (trace.outs.map (substOf substitutions)))).2 status0 [u64Write buffer offset final.next] ∧
      applyDone target (R.handle cls) (R.a buffer) offset (R.handle slot) targetTrace (inputs.map R.node) =
        okW (final'.newObj (.vec ((trace.outs.map (substOf substitutions)).map R.node))).2
          status0 [u64Write (R.a buffer) offset final'.next] ∧
      Live NR R NodeRel ObjRel' (fun i => i = final.next ∨ H i) K tail
        (final.newObj (.vec (trace.outs.map (substOf substitutions)))).2
        (final'.newObj (.vec ((trace.outs.map (substOf substitutions)).map R.node))).2 ∧
      ListR (Parametric.ByteR NR R) (cellParts .u64 (.big (Int.ofNat final.next)) 8 0)
        (cellParts .u64 (.big (Int.ofNat final'.next)) 8 0) ∧
      final'.objs = target.objs ∧ final'.next = target.next := by
  obtain ⟨final',left,right,post,objectFrame,counterFrame⟩ := plan.replay_objects base objects h traceRelated
    keys outputs sourceNodes targetNodes
  have absent : final.obj? slot = none := by
    change final.objs.get slot = none
    rw [plan.frames.1]
    exact slotAbsent
  have targetAbsent : final'.obj? (R.handle slot) = none := by
    have related := post.objs slot slotLive
    change OptionR (ObjRel slot) (final.obj? slot) (final'.obj? (R.handle slot)) at related
    rw [absent] at related
    cases targetRead : final'.obj? (R.handle slot) with
    | none => rfl
    | some value => rw [targetRead] at related; cases related
  have sourceBound : final.next < 2^64 := by rw [plan.frames.2]; exact sourceHandles
  have targetBound : final'.next < 2^64 := by rw [counterFrame]; exact targetHandles
  have allocated := post.newObjectRoles _ _ created frame sourceBound targetBound
  have bytes := Parametric.cellParts_roles (NR := NR) (.handle final.next) .u64 8 0 (R := R)
  rw [post.handleMap.head] at bytes
  exact ⟨final',NativeRoles.applyDone_fresh source final cls buffer offset slot trace inputs _ left absent,
    NativeRoles.applyDone_fresh target final' (R.handle cls) (R.a buffer) offset (R.handle slot) targetTrace (inputs.map R.node) _ right targetAbsent,
    allocated,bytes,objectFrame,counterFrame⟩

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- Strong replay and the pure reached policy determine the fresh vector's
annotation and producer closure. Final policy and target output roles are
conclusions, including all framed callback/configuration objects. -/
theorem ReplayPlan.applyDone_fresh_policy {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {objects : Nat → Object} {boundary roots H N K : Nat → Prop}
    {cls : Nat} {source target final : St} {substitutions : List (Nat × Nat)}
    {trace targetTrace : Ffi.Trace} {inputs : List Nat} {tail : List NumV}
    (plan : ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary cls (NodeRel roles ν₀ ν C₀ C R boundary)
      N source (trace.ins.zip inputs) trace.order K final substitutions)
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail source target)
    (policy : ProducerAnnotations roots H N roles objects) (traceRelated : TraceR R trace targetTrace)
    (inputSupport : listSupport N inputs) (outputSupport : listSupport N trace.outs)
    (keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) substitutions)
    (outputs : listSupport (· < final.nnext) trace.outs)
    (buffer offset slot : Nat) (slotLive : H slot) (slotAbsent : source.obj? slot = none)
    (sourceNodes : source.nnext + trace.order.length < 2^64) (targetNodes : target.nnext + trace.order.length < 2^64)
    (sourceHandles : source.next < 2^64) (targetHandles : target.next < 2^64) :
    let nodes := trace.outs.map (substOf substitutions)
    let newObjects := objectWrite objects final.next (.vec nodes)
    ∃ final' : St,
      applyDone source cls buffer offset slot trace inputs =
        okW (final.newObj (.vec nodes)).2 status0 [u64Write buffer offset final.next] ∧
      applyDone target (R.handle cls) (R.a buffer) offset (R.handle slot) targetTrace (inputs.map R.node) =
        okW (final'.newObj (.vec (nodes.map R.node))).2 status0 [u64Write (R.a buffer) offset final'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
        (ObjectRel newObjects ν₀ ν C₀ C R) (fun i => i = final.next ∨ H i) K tail
        (final.newObj (.vec nodes)).2 (final'.newObj (.vec (nodes.map R.node))).2 ∧
      ProducerAnnotations roots (fun i => i = final.next ∨ H i) K roles newObjects ∧
      ProducerSupport roots (fun i => i = final.next ∨ H i) K (final.newObj (.vec nodes)).2 ∧
      ListR (Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R) (cellParts .u64 (.big (Int.ofNat final.next)) 8 0)
        (cellParts .u64 (.big (Int.ofNat final'.next)) 8 0) := by
  dsimp only
  obtain ⟨final',left,right,post,bytes,_,_⟩ := plan.applyDone_fresh_objects
    (fun _ _ _ held => held.base) (fun _ _ _ held => held.base) h traceRelated keys outputs buffer offset slot slotLive slotAbsent
    (ObjectRel.write_vec objects ν₀ ν C₀ C R final.next (trace.outs.map (substOf substitutions)))
    (fun _ different _ _ held => ObjectRel.write_frame different held) sourceNodes targetNodes sourceHandles targetHandles
  have sourceRoles : ∀ i node, K i → final.nodes.get i = some node → (roles i).Holds ν₀ C₀ Owned.Annotated.identity node := by
    intro i node held read
    have finalRead : (final.newObj (.vec (trace.outs.map (substOf substitutions)))).2.nodes.get i = some node := read
    obtain ⟨_,_,related⟩ := post.node_view held finalRead
    exact related.source
  have replayPolicy := policy.replay plan (zip_support_right trace.ins inputs inputSupport) sourceNodes sourceRoles
  have supported := plan.output_support (zip_support_right trace.ins inputs inputSupport) trace.outs outputSupport
  have updated := replayPolicy.new_object final.next (.vec (trace.outs.map (substOf substitutions))) supported.2
  exact ⟨final',left,right,post,updated,updated.source post,bytes⟩

end Host.Mlx.Ffi.NativeRoles
