import host.ts.RenameRetainedAllocation
import host.ts.RenameParametricCallback
import host.ts.RenameParametricEmptyObject
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

section
variable {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes} {ν₀ ν : Nat → F64}
  {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
  {s₀ s : St F.S}

/-- An actual arrow expression captures its original environment and returns
the fresh closure address, retaining every fixed cell/field/byte meaning. -/
theorem RetainedInventory.callback_step
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (fn : Func) (env : Env) (control : s₀.ctl = .ev (.arrow fn) env)
    (prototypeLive : live aFunctionProto) (prototypeFixed : R.a aFunctionProto = aFunctionProto)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    interpC (step F s₀).run C₀ = some ((s₀.alloc (callbackObject fn env)).2.ret (.obj s₀.next),C₀) ∧
      interpC (step F s).run C = some ((s.alloc (callbackObject fn (R.env env))).2.ret (.obj s.next),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next) framed before after old old'
        ((s₀.alloc (callbackObject fn env)).2.ret (.obj s₀.next)) ((s.alloc (callbackObject fn (R.env env))).2.ret (.obj s.next)) ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote (.obj s₀.next)})
        ν₀ ν C₀ C R (LiveAfter live s₀.next)
        ((s₀.alloc (callbackObject fn env)).2.ret (.obj s₀.next)) ((s.alloc (callbackObject fn (R.env env))).2.ret (.obj s.next)) := by
  obtain ⟨sourceRun,targetRun,post⟩ := step_callback_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h fn env control prototypeLive prototypeFixed sourceBound targetBound
  exact ⟨sourceRun,targetRun,post,inventory.allocate_return h.heap _ _ sourceBound targetBound⟩

theorem RetainedInventory.empty_object_step
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (env : Env) (control : s₀.ctl = .ev (.object []) env)
    (prototypeLive : live aObjectProto) (prototypeFixed : R.a aObjectProto = aObjectProto)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    let object : HObj := .obj ⟨.ordinary,.obj aObjectProto,[],[],true⟩
    interpC (step F s₀).run C₀ = some ((s₀.alloc object).2.ret (.obj s₀.next),C₀) ∧
      interpC (step F s).run C = some ((s.alloc object).2.ret (.obj s.next),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next) framed before after old old'
        ((s₀.alloc object).2.ret (.obj s₀.next)) ((s.alloc object).2.ret (.obj s.next)) ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote (.obj s₀.next)})
        ν₀ ν C₀ C R (LiveAfter live s₀.next) ((s₀.alloc object).2.ret (.obj s₀.next)) ((s.alloc object).2.ret (.obj s.next)) := by
  obtain ⟨sourceRun,targetRun,post⟩ := step_empty_object_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h env control prototypeLive prototypeFixed sourceBound targetBound
  exact ⟨sourceRun,targetRun,post,inventory.allocate_return h.heap _ _ sourceBound targetBound⟩
end
end Host.Ts.Owned.Annotated
