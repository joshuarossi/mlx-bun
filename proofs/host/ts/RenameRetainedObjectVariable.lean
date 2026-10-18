import host.ts.RenameRetainedInventory
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameParametricVariables
import host.ts.RenameParametricParameters

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- An initialized object cell has a unique structural object meaning. Its
source environment and live heap suffice; a selected cell note is unnecessary. -/
theorem RetainedInventory.variable_object_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (name : Name) (env : Env) (cell object : Nat)
    (control : source.ctl = .ev (.id name) env)
    (lookup : lookupEnv name env = some cell)
    (read : source.heap.get cell = some (.cell (some (.obj object)))) :
    interpC (step F source).run C₀ = some (source.ret (.obj object),C₀) ∧
      interpC (step F target).run C = some (target.ret (.obj (R.a object)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (source.ret (.obj object)) (target.ret (.obj (R.a object))) ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote (.obj object)}) ν₀ ν C₀ C R live
        (source.ret (.obj object)) (target.ret (.obj (R.a object))) := by
  have support := h.controlLive
  rw [control] at support
  have alive := env_lookup_live name env cell support.2.1 lookup
  obtain ⟨value,left,right,post,relation⟩ := step_variable_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' source target h name env cell (.obj object) control (h.control_view control).ev_view lookup alive read
  cases relation
  exact ⟨left,right,post,inventory.heap_step (inventory.runtime.returning (.obj object) (.obj object)) rfl rfl (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
