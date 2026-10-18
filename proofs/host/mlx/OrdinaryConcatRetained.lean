import host.mlx.NativeConcatRetained
import host.mlx.OrdinaryConcatHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ConcatCall
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

private theorem history_geometry (ν : Nat → F64) :
    ConcatGeometry ν (ConcatNative.shapeRoles 3) (ConcatNative.shapeRoles 1) (ConcatNative.shapeRoles 4) 1 := by
  refine ⟨[1,3,10240],[1,1,10240],rfl,rfl,rfl,rfl,?_⟩
  exact .cons _ 1 rfl (by change F64.toInt? (F64.ofInt 1) = some 1; decide +kernel)
    (.cons _ 4 rfl (by change F64.toInt? (F64.ofInt 4) = some 4; decide +kernel)
    (.cons _ 10240 rfl (by change F64.toInt? (F64.ofInt 10240) = some 10240; decide +kernel) .nil))

/-- The actual SSM history concatenation consumes the initialized null slot
and current vector/call notes. Both original calls, the updated result slot,
all retained families and the fresh producer policy are derived here. -/
theorem retained_transport {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s)
    (signatureFrame : ¬ framed 4409) (vectorLive : H 29371)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N (ConcatNative.preRoles base) objects)
    (fnRole thisRole : Value)
    (note : notes.runtime.control = callNote fnRole thisRole
      ((ConcatFamilyHost.arguments 3126700 29371 2 (F64.fin false 1 0)).map FixedArgument.role))
    (selected : notes.buffers.owners 3126700 = some (handleSlotNotes 0)) :
    ∃ t, interpC (step Host.Load.ffi input).run C₀ = some (output,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C
          (nodeWrite (ConcatNative.preRoles base) 22587
            (concatRole (ConcatNative.preRoles base) 20208 22582 1 (ConcatNative.shapeRoles 4)))
          boundary (objectWrite objects 29372 .stream) (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R live framed before after old old' output t ∧
      RetainedInventory (notes.nativeHandleResult 3126700 29372) ν₀ ν C₀ C R live output t ∧
      ProducerAnnotations roots (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i)
        (nodeWrite (ConcatNative.preRoles base) 22587
          (concatRole (ConcatNative.preRoles base) 20208 22582 1 (ConcatNative.shapeRoles 4))) (objectWrite objects 29372 .stream) ∧
      ProducerSupport roots (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) output.ffi.mlx := by
  have kind := source_callee_kind
  rw [source_caps] at kind
  have geometry : ∀ valuation, ConcatGeometry valuation ((ConcatNative.preRoles base) 20208).shape
      ((ConcatNative.preRoles base) 22582).shape (ConcatNative.shapeRoles 4) 1 := by
    intro valuation
    simpa only [ConcatNative.preRoles,ite_true,ite_eq_right (by decide : 22582 ≠ 20208)] using history_geometry valuation
  obtain ⟨sourcePost,t,left,right,post,retained,newPolicy,producers⟩ := ConcatFamilyHost.retained_from_source
    ν₀ ν C₀ C R (ConcatNative.preRoles base) boundary objects H N tail host live framed before after old old' input s h inventory
    4708 4409 3126700 29371 20208 22582 1 2 (F64.fin false 1 0) 1 chars!"i32" calleeObject signatureObject (.obj 4817)
    firstNode secondNode (ConcatNative.shapeRoles 4) source_control source_callee kind source_signature source_signature_kind
    signatureFrame vectorLive source_vector source_first source_second (by decide +kernel) (by decide +kernel) rfl
    (geometry ν₀) (geometry ν) roots policy (by decide +kernel) nodeBound (by decide +kernel) handleBound
    (by decide +kernel) heapBound fnRole thisRole note selected
  have actual : interpC (step Host.Load.ffi input).run C₀ = some (output,C₀) := by
    change interpC (step ConcatHost.F input).run C₀ = _
    rw [ConcatHost.source_step]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (left.symm.trans actual))
  dsimp only at same
  rw [same] at post retained producers
  have handleCounter : input.ffi.mlx.next = 29372 := source_counter
  have nodeCounter : input.ffi.mlx.nnext = 22587 := source_node_counter
  rw [handleCounter,nodeCounter] at post newPolicy producers
  rw [handleCounter] at retained
  exact ⟨t,actual,right,post,retained,newPolicy,producers⟩

end Host.Load.Run.Full.Ordinary.ConcatCall
