import host.ts.RenameParametricUsing
import host.ts.RenameUsingNotes
import host.ts.RenameRetainedHeapFrame

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def RetainedNotes.usingObject (notes : RetainedNotes) (resourceRole : Value) (method : Nat)
    (pattern : Pat) (rest : List (Pat × Option Expr)) (env : Env) (index : Nat) (tail : List Tree) : RetainedNotes :=
  notes.withRuntime (notes.runtime.bindValue resourceRole pattern .using rest env
    (registerUsingNotes resourceRole (.obj method) index tail))

/-- Register the source-selected inherited disposal method, retaining the
current resource role in both the binding and scope. Heap/native states and
all six occurrence inventories are preserved by the original step. -/
theorem RetainedInventory.using_object_step {F : Ffi} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (FR : Ren → F.S → F.S → Prop)
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a method : Nat) (pattern : Pat) (rest : List (Pat × Option Expr)) (env : Env) (frames : List Frame)
    (w e : Bool) (index : Nat)
    (control : s₀.ctl = .ret (.obj a)) (stack : s₀.stack = .s (.decl .using pattern rest env)::frames)
    (path : OrdinarySymbolLookup s₀ symDispose 16 a (some (.data (.obj method) w e)))
    (scope : ScopeAt frames index)
    (resourceRole : Value) (headNote : Tree) (tailNotes : List Tree)
    (controlNote : notes.runtime.control = returnNote resourceRole) (stackNotes : notes.runtime.stack = headNote::tailNotes) :
    ∃ registered targetRegistered,
      interpC (step F s₀).run C₀ = some (declarationValue {s₀ with stack := registered} .using pattern rest env (.obj a),C₀) ∧
      interpC (step F s).run C = some (declarationValue {s with stack := targetRegistered} .using pattern rest (R.env env) (.obj (R.a a)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (declarationValue {s₀ with stack := registered} .using pattern rest env (.obj a))
        (declarationValue {s with stack := targetRegistered} .using pattern rest (R.env env) (.obj (R.a a))) ∧
      RetainedInventory (notes.usingObject resourceRole method pattern rest env index tailNotes) ν₀ ν C₀ C R live
        (declarationValue {s₀ with stack := registered} .using pattern rest env (.obj a))
        (declarationValue {s with stack := targetRegistered} .using pattern rest (R.env env) (.obj (R.a a))) := by
  obtain ⟨targetFrames,registered,targetRegistered,targetStack,targetReg,sourceReg,left,right,post⟩ :=
    step_using_object_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old'
      s₀ s h a method pattern rest env frames w e index control stack path scope
  obtain ⟨value,targetControl,pairedValue⟩ := (h.control_view control).ret_view
  cases pairedValue
  have sourceHeld := inventory.runtime.source.control
  have targetHeld := inventory.runtime.target.control
  rw [controlNote,control] at sourceHeld
  rw [controlNote,targetControl] at targetHeld
  have sourceRole := returnNote_view sourceHeld
  have targetRole := returnNote_view targetHeld
  have sourceStack := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have frameRoles := h.stack
  rw [stack,targetStack] at frameRoles
  have tailRoles : ListR (Parametric.FrameR (NumberRoles ν₀ ν C₀ C) R) frames targetFrames := by cases frameRoles with | cons _ tail => exact tail
  have sourceRegisteredNotes := registerUsingNotes_holds sourceRole (Value.Holds.obj (ν := ν₀) (C := C₀) (R := identity) method)
    frames registered tailNotes index scope sourceStack.tail sourceReg
  have targetRegisteredNotes := registerUsingNotes_holds targetRole (Value.Holds.obj (ν := ν) (C := C) (R := R) method)
    targetFrames targetRegistered tailNotes index (ScopeAt.transport frames targetFrames index tailRoles scope) targetNotes.tail targetReg
  have runtime : RuntimeInventory (notes.runtime.bindValue resourceRole pattern .using rest env
      (registerUsingNotes resourceRole (.obj method) index tailNotes)) ν₀ ν C₀ C R live
      (declarationValue {s₀ with stack := registered} .using pattern rest env (.obj a))
      (declarationValue {s with stack := targetRegistered} .using pattern rest (R.env env) (.obj (R.a a))) :=
    ⟨inventory.runtime.keyLive,
      ⟨by simpa only [RuntimeNotes.bindValue,declarationValue,St.push,St.go,identity_environment] using bindingNote_holds pattern env .init .using sourceRole,
        .cons (by simpa only [identity_environment] using declarationNextNote_holds ν₀ C₀ identity .using rest env) sourceRegisteredNotes,
        inventory.runtime.source.cells⟩,
      ⟨bindingNote_holds pattern env .init .using targetRole,
        .cons (declarationNextNote_holds ν C R .using rest env) targetRegisteredNotes,inventory.runtime.target.cells⟩⟩
  exact ⟨registered,targetRegistered,left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
