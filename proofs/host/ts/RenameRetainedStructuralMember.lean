import host.ts.RenameStructuralCellSeed
import host.ts.RenameRuntimePublicRead
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRetainedUndefined
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Structural own-data fields get their role from the related heap. Numeric
fields still require their separately retained provenance. -/
theorem RetainedInventory.structural_member_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a : Nat) (name : Name) (value : Val) (role : Value) (w e : Bool) (object : Obj) (frames : List Frame)
    (control : s₀.ctl = .ret (.obj a)) (stack : s₀.stack = .e (.member (.str name) false)::frames)
    (read : s₀.heap.get a = some (.obj object)) (ordinary : object.kind = .ordinary)
    (descriptor : findProp (.str name) object.props = some (.data value w e))
    (static : StructuralValue value role) :
    ∃ (targetValue : Val) (targetFrames : List Frame),
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret value,C₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) ∧
      RetainedInventory (notes.withRuntime (notes.runtime.binaryResult role notes.runtime.stack.tail))
        ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) := by
  obtain ⟨_,targetControl,receiverRole⟩ := (h.control_view control).ret_view
  cases receiverRole
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.member_view] at targetStack
  have alive : live a := by have support := h.controlLive; rw [control] at support; exact support.1
  obtain ⟨targetObject,targetRead,objectRelation,objectLive⟩ := h.heap.readOrdinary a object alive read ordinary
  obtain ⟨targetValue,targetDescriptor,valueRelation⟩ := objectRelation.properties.find_data name value w e descriptor
  have sourceRole := static.source ν₀ C₀
  have targetRole := static.target valueRelation ν C
  have sourceStack := inventory.runtime.source.stack
  have targetStackNotes := inventory.runtime.target.stack
  rw [stack,List.map_cons] at sourceStack
  rw [targetStack,List.map_cons] at targetStackNotes
  have sourceTail : ForestHolds ν₀ C₀ identity notes.runtime.stack.tail (List.map Encode.frame frames) := by
    simpa only [List.tail_cons] using sourceStack.tails
  have targetTail : ForestHolds ν C R notes.runtime.stack.tail (List.map Encode.frame targetFrames) := by
    simpa only [List.tail_cons] using targetStackNotes.tails
  have runtime : RuntimeInventory (notes.runtime.binaryResult role notes.runtime.stack.tail)
      ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds sourceRole,sourceTail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds targetRole,targetTail,inventory.runtime.target.cells⟩⟩
  have support := h.stackLive
  rw [stack] at support
  have valueLive := (PropsR.support_find objectLive.2.2.1 name descriptor).1
  refine ⟨targetValue,targetFrames,?_,?_,?_,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
  · rw [step_member_data_eq F s₀ a name value w e object frames control stack
      (by simp only [St.obj?,read]) ordinary descriptor]; rfl
  · rw [step_member_data_eq F s (R.a a) name targetValue w e targetObject targetFrames targetControl targetStack
      (by simp only [St.obj?,targetRead]) (objectRelation.ordinary ordinary) targetDescriptor]; rfl
  · exact (h.restack tailRelation support.2).go (.node _ (.cons (.value valueRelation) .nil)) ⟨valueLive,True.intro⟩

end Host.Ts.Owned.Annotated
