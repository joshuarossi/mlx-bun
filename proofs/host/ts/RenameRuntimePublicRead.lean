import host.ts.RenamePublicInventory
import host.ts.RenameRuntimeDispatch
import host.ts.RenameParametricReads
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Direct ordinary own-data lookup uses the field's retained fixed meaning.
Accessor and prototype traversal have separate source dispatch rules. -/
theorem RuntimeInventory.public_read_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (publics : PublicNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publics ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (name : Name) (role : Value) (value : Val) (w e : Bool) (o₀ : Obj)
    (frames : List Frame) (headNote : Tree) (tailNotes : List Tree)
    (control : s₀.ctl = .ret (.obj a)) (stack : s₀.stack = .e (.member (.str name) false)::frames)
    (object : s₀.heap.get a = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findProp (.str name) o₀.props = some (.data value w e))
    (entry : publics.fields a name = some role) (stackNotes : notes.stack = headNote::tailNotes) :
    ∃ (targetValue : Val) (targetFrames : List Frame),
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret value,C₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) ∧
      RuntimeInventory {notes with control := returnNote role,stack := tailNotes} ν₀ ν C₀ C R live
        ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) ∧
      PublicInventory publics ν₀ ν C₀ C R live
        ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) := by
  have alive := publicInventory.keyLive a name role entry
  obtain ⟨sourceValue,sourceField,sourceRole⟩ := publicInventory.source a name role entry
  have actualField : PublicData s₀ a name value := ⟨o₀,w,e,object,descriptor⟩
  have sourceEq : sourceValue = value := sourceField.unique actualField
  subst sourceValue
  obtain ⟨targetValue,targetField,targetRole⟩ := publicInventory.target a name role entry
  obtain ⟨o,read,objectRelation,objectLive⟩ := h.heap.readOrdinary a o₀ alive object ordinary
  obtain ⟨targetObject,tw,te,targetRead,targetDescriptor⟩ := targetField
  have same : targetObject = o := HObj.obj.inj (Option.some.inj (targetRead.symm.trans read))
  subst targetObject
  obtain ⟨receiver,targetControl,receiverRole⟩ := (h.control_view control).ret_view
  cases receiverRole
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.member_view] at targetStack
  have sourceStack := inventory.source.stack
  have targetStackRole := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  have support := h.stackLive
  rw [stack] at support
  have valueLive : valueSupport live value := (PropsR.support_find objectLive.2.2.1 name descriptor).1
  refine ⟨targetValue,targetFrames,?_,?_,?_,?_,?_⟩
  · rw [step_member_data_eq F s₀ a name value w e o₀ frames control stack (by simp only [St.obj?,object]) ordinary descriptor]; rfl
  · rw [step_member_data_eq F s (R.a a) name targetValue tw te o targetFrames targetControl targetStack
      (by simp only [St.obj?,read]) (objectRelation.ordinary ordinary) targetDescriptor]; rfl
  · exact (h.restack tailRelation support.2).go (.node _ (.cons (.value (Value.paired sourceRole targetRole)) .nil)) ⟨valueLive,True.intro⟩
  · exact ⟨inventory.keyLive,⟨returnNote_holds sourceRole,sourceStack.tail,inventory.source.cells⟩,
      ⟨returnNote_holds targetRole,targetStackRole.tail,inventory.target.cells⟩⟩
  · exact publicInventory.frame (fun _ h => h) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)
end Host.Ts.Owned.Annotated
