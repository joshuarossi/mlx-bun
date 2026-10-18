import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRuntimeHeapReads
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- These source constructors have a unique structural role under ValueR.
Numeric and bigint fields require their retained occurrence annotations. -/
inductive StaticValue : Val → Value → Prop where
  | undef : StaticValue .undef .undef
  | null : StaticValue .null .null
  | bool (b : Bool) : StaticValue (.bool b) (.bool b)
  | str (s : Name) : StaticValue (.str s) (.str s)

theorem StaticValue.source {value : Val} {role : Value} (static : StaticValue value role)
    (ν : Nat → F64) (C : CSrv) : role.Holds ν C identity value := by
  cases static <;> constructor

theorem StaticValue.target {value target : Val} {role : Value} {NR : NumV → NumV → Prop}
    {R : Ren} (static : StaticValue value role) (relation : Parametric.ValueR NR R value target)
    (ν : Nat → F64) (C : CSrv) : role.Holds ν C R target := by
  cases static <;> cases relation <;> constructor

/-- A structural boolean/null/string read does not consume the owner's one
numeric/native private-field note. Its target constructor is forced by the
original heap relation; all retained inventories are preserved. -/
theorem RetainedInventory.private_static_read_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (owner brand : Nat) (name : Name) (value : Val) (w e : Bool) (object : Obj) (role : Value)
    (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret (.obj owner)) (stack : s₀.stack = .e (.priv brand name false)::frames)
    (read : s₀.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (descriptor : findPriv brand name object.priv = some (.data value w e))
    (static : StaticValue value role) (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetValue targetFrames,
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret value,C₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote role,stack := tail})
        ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) := by
  obtain ⟨receiver,targetControl,receiverRole⟩ := (h.control_view control).ret_view
  cases receiverRole
  obtain ⟨frame,targetFrames,targetStack,frameRole,_⟩ := h.stack_view stack
  rw [frameRole.private_view] at targetStack
  have alive : live owner := by have support := h.controlLive; rw [control] at support; exact support.1
  have stackLive := h.stackLive
  rw [stack] at stackLive
  have brandLive : live brand := stackLive.1.1.1
  obtain ⟨property,left,right,post,propertyRole⟩ := step_private_read_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h owner brand name object (.data value w e) frames targetFrames
    control targetControl stack targetStack alive brandLive read ordinary descriptor
  obtain ⟨targetValue,rfl,valueRole⟩ := propertyRole.data
  have sourceStack := inventory.runtime.source.stack
  have targetStackRole := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  have runtime : RuntimeInventory {notes.runtime with control := returnNote role,stack := tail}
      ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) :=
    ⟨inventory.runtime.keyLive,⟨returnNote_holds (static.source ν₀ C₀),sourceStack.tail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (static.target valueRole ν C),targetStackRole.tail,inventory.runtime.target.cells⟩⟩
  exact ⟨targetValue,targetFrames,left,right,post,
    inventory.heap_step runtime rfl rfl (TableExtends.refl C₀) (TableExtends.refl C)⟩

end Host.Ts.Owned.Annotated
