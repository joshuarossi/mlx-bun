import host.ts.RenameParametricReads
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRuntimeDispatch
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- A checked absent ordinary prototype lookup returns undefined on both
sides. The absence follows the entire source path, rather than merely its
own properties. No target lookup or fresh numeric meaning is assumed. -/
theorem RetainedInventory.missing_member_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a : Nat) (name : Name) (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret (.obj a)) (stack : s₀.stack = .e (.member (.str name) false)::frames)
    (path : OrdinaryLookup s₀ name 16 a none) (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret .undef,C₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.ret .undef,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret .undef) ({s with stack := targetFrames}.ret .undef) ∧
      RetainedInventory (notes.withRuntime ⟨returnNote .undef,tail,notes.runtime.cells⟩) ν₀ ν C₀ C R live
        ({s₀ with stack := frames}.ret .undef) ({s with stack := targetFrames}.ret .undef) := by
  obtain ⟨receiver,targetControl,receiverRelation⟩ := (h.control_view control).ret_view
  cases receiverRelation
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.member_view] at targetStack
  have alive : live a := by have support := h.controlLive; rw [control] at support; exact support.1
  obtain ⟨property,left,right,post,descriptor⟩ := step_member_lookup_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h a name none frames targetFrames control targetControl stack targetStack alive path
  cases descriptor
  have sourceStack := inventory.runtime.source.stack
  have targetStackRole := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  have runtime : RuntimeInventory ⟨returnNote .undef,tail,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      ({s₀ with stack := frames}.ret .undef) ({s with stack := targetFrames}.ret .undef) :=
    ⟨inventory.runtime.keyLive,⟨returnNote_holds .undef,sourceStack.tail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds .undef,targetStackRole.tail,inventory.runtime.target.cells⟩⟩
  exact ⟨targetFrames,left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
end Host.Ts.Owned.Annotated
