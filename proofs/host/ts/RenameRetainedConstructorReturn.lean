import host.ts.RenameRuntimeClassNotes
import host.ts.RenameParametricRegistry
import host.ts.RenameRetainedHeapFrame

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

theorem constructorBoundaryNote_view {ν : Nat → F64} {C : CSrv} {R : Ren}
    (role : Value) (receiver : Val)
    (held : (constructorBoundaryNote role).Holds ν C R (Encode.frame (.k (.fn (.ctor receiver))))) :
    role.Holds ν C R receiver := by
  cases held with | node _ outer => cases outer with | cons inner _ =>
    cases inner with | node _ fields => cases fields with | cons boundary _ =>
      cases boundary with | node _ fields => cases fields with | cons value _ =>
        cases value with | value meaning => exact meaning

/-- Implicit constructor completion returns the receiver role saved at body
entry. The current return operand is ignored by the original constructor
boundary. All six inventory families survive the control/stack-only step. -/
theorem RetainedInventory.constructor_return_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (value receiver₀ : Val) (frames₀ : List Frame) (role : Value) (tailNotes : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .k (.fn (.ctor receiver₀))::frames₀)
    (stackNotes : notes.runtime.stack = constructorBoundaryNote role::tailNotes) :
    ∃ receiver frames,
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames₀}.ret receiver₀,C₀) ∧
      interpC (step F s).run C = some ({s with stack := frames}.ret receiver,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames₀}.ret receiver₀) ({s with stack := frames}.ret receiver) ∧
      RetainedInventory (notes.withRuntime ⟨returnNote role,tailNotes,notes.runtime.cells⟩) ν₀ ν C₀ C R live
        ({s₀ with stack := frames₀}.ret receiver₀) ({s with stack := frames}.ret receiver) := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,frames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨receiver,frameEq,_⟩ := frameRelation.constructorBoundary_view
  rw [frameEq] at targetStack
  have actualTarget : interpC (step F s).run C = some ({s with stack := frames}.ret receiver,C) := by
    rw [step_constructor_return_eq F s targetValue receiver frames targetControl targetStack]; rfl
  obtain ⟨selectedReceiver,selectedFrames,left,right,post⟩ := step_constructor_return_from_source F
    (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s₀ s h value receiver₀ frames₀ control stack
  have same := congrArg Prod.fst (Option.some.inj (right.symm.trans actualTarget))
  dsimp only at same
  rw [same] at post
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have cells := inventory.runtime.cellInventory.frame (fun _ alive => alive)
    (t₀:={s₀ with stack := frames₀}.ret receiver₀) (t:={s with stack := frames}.ret receiver)
    (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  have runtime : RuntimeInventory ⟨returnNote role,tailNotes,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      ({s₀ with stack := frames₀}.ret receiver₀) ({s with stack := frames}.ret receiver) :=
    ⟨cells.keyLive,
      ⟨returnNote_holds (constructorBoundaryNote_view role receiver₀ sourceNotes.head),sourceNotes.tail,cells.source⟩,
      ⟨returnNote_holds (constructorBoundaryNote_view role receiver targetNotes.head),targetNotes.tail,cells.target⟩⟩
  exact ⟨receiver,frames,left,actualTarget,post,
    inventory.heap_step runtime rfl rfl (TableExtends.refl C₀) (TableExtends.refl C)⟩

end Host.Ts.Owned.Annotated
