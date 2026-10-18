import host.ts.RenameRuntimeArithmetic
import host.ts.RenameArrayInventory
import host.ts.RenameParametricArrayIndex
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- A fixed element annotation is selected by the actual array index. The
index guard is a pure arithmetic fact about its retained meaning; the target
read and returned annotation follow from the existing array inventory. -/
theorem RuntimeInventory.array_index_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (arrays : ArrayNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrays ν₀ ν C₀ C R live s₀ s)
    (a i : Nat) (roles : List Value) (role : Value) (indexMeaning : SymE) (key : Val)
    (frames : List Frame) (headNote : Tree) (tailNotes : List Tree)
    (entry : arrays.owners a = some roles) (element : nth? roles i = some role)
    (control : s₀.ctl = .ret key) (stack : s₀.stack = .e (.indexR (.obj a))::frames)
    (index : numIndex key = some i)
    (meaningIndex : numIndex (.num (.lit (indexMeaning.eval ν))) = some i)
    (controlNote : notes.control = returnNote (.literal indexMeaning))
    (stackNotes : notes.stack = headNote::tailNotes) :
    ∃ (value targetValue : Val) (targetFrames : List Frame),
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret value,C₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) ∧
      RuntimeInventory {notes with control := returnNote role,stack := tailNotes} ν₀ ν C₀ C R live
        ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) ∧
      ArrayInventory arrays ν₀ ν C₀ C R live
        ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) := by
  obtain ⟨o₀,o,values,targetValues,sourceObject,sourceKind,targetObject,targetKind,sourceElements,targetElements,_,elementsLive⟩ :=
    arrayInventory.selected a roles entry
  obtain ⟨value,valueAt,sourceRole⟩ := listR_nth_some sourceElements i role element
  obtain ⟨targetValue,targetAt,targetRole⟩ := listR_nth_some targetElements i role element
  obtain ⟨targetKey,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨receiver,frameEq,receiverRelation⟩ := frameRelation.indexRight_view
  cases receiverRelation
  rw [frameEq] at targetStack
  have targetControlRole := inventory.target.control
  rw [controlNote,targetControl] at targetControlRole
  obtain ⟨x,keyEq,meaning⟩ := (returnNote_view targetControlRole).literal_view
  have targetIndex : numIndex targetKey = some i := by
    rw [keyEq]
    have same : x = indexMeaning.eval ν := Option.some.inj meaning
    rw [same]
    exact meaningIndex
  have sourceStack := inventory.source.stack
  have targetStackRole := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  have support := h.stackLive
  rw [stack] at support
  refine ⟨value,targetValue,targetFrames,?_,?_,?_,?_,?_⟩
  · rw [step_array_index_eq F s₀ key a i o₀ values value frames control stack index sourceObject sourceKind valueAt]; rfl
  · rw [step_array_index_eq F s targetKey (R.a a) i o targetValues targetValue targetFrames targetControl targetStack targetIndex
      targetObject targetKind targetAt]; rfl
  · exact (h.restack tailRelation support.2).go (.node _ (.cons (.value (Value.paired sourceRole targetRole)) .nil))
      ⟨listSupport_nth (valueSupport live) values elementsLive i value valueAt,True.intro⟩
  · exact ⟨inventory.keyLive,⟨returnNote_holds sourceRole,sourceStack.tail,inventory.source.cells⟩,
      ⟨returnNote_holds targetRole,targetStackRole.tail,inventory.target.cells⟩⟩
  · exact arrayInventory.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
end Host.Ts.Owned.Annotated
