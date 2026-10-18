import host.ts.RenameParametricReads
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRuntimeArguments
import host.ts.RenameRuntimeDispatch
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- A source ordinary-prototype path determines the accessor and its mapped
getter. The actual getter call retains the original receiver and caller tail;
no callee or lookup equation is required of the target. -/
theorem RetainedInventory.getter_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a getter : Nat) (name : Name) (setter : Val) (enumerable : Bool) (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret (.obj a)) (stack : s₀.stack = .e (.member (.str name) false)::frames)
    (path : OrdinaryLookup s₀ name 16 a (some (.acc (.obj getter) setter enumerable)))
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := {s₀ with stack := frames}.go (.call (.obj getter) (.obj a) [])
      let t := {s with stack := targetFrames}.go (.call (.obj (R.a getter)) (.obj (R.a a)) [])
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ⟨callNote (.obj getter) (.obj a) [],tail,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨receiver,targetControl,receiverRelation⟩ := (h.control_view control).ret_view
  cases receiverRelation
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.member_view] at targetStack
  have alive : live a := by have support := h.controlLive; rw [control] at support; exact support.1
  obtain ⟨property,left,right,post,descriptor⟩ := step_member_lookup_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h a name (some (.acc (.obj getter) setter enumerable)) frames targetFrames
    control targetControl stack targetStack alive path
  cases descriptor with
  | some descriptor =>
    obtain ⟨targetGetter,targetSetter,rfl,getterRelation,_⟩ := descriptor.accessor
    cases getterRelation
    have sourceStack := inventory.runtime.source.stack
    have targetStackNotes := inventory.runtime.target.stack
    rw [stackNotes,stack,List.map_cons] at sourceStack
    rw [stackNotes,targetStack,List.map_cons] at targetStackNotes
    have runtime : RuntimeInventory ⟨callNote (.obj getter) (.obj a) [],tail,notes.runtime.cells⟩
        ν₀ ν C₀ C R live ({s₀ with stack := frames}.go (.call (.obj getter) (.obj a) []))
        ({s with stack := targetFrames}.go (.call (.obj (R.a getter)) (.obj (R.a a)) [])) :=
      ⟨inventory.runtime.keyLive,
        ⟨callNote_holds (.obj getter) (.obj a) .nil,sourceStack.tail,inventory.runtime.source.cells⟩,
        ⟨callNote_holds (.obj getter) (.obj a) .nil,targetStackNotes.tail,inventory.runtime.target.cells⟩⟩
    exact ⟨targetFrames,left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
end Host.Ts.Owned.Annotated
