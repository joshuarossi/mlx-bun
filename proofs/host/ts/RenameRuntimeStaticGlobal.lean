import host.ts.RenameRuntimeStaticRead
import host.ts.RenameParametricGlobal
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Structural global constants keep their constructor under the heap
relation. Numeric globals still require a retained public-field meaning. -/
theorem RetainedInventory.global_static_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (object : Obj) (value : Val) (role : Value) (w e : Bool)
    (control : s₀.ctl = .ev (.id name) env) (localLookup : lookupEnv name env = none)
    (read : s₀.heap.get aGlobal = some (.obj object)) (ordinary : object.kind = .ordinary)
    (descriptor : findProp (.str name) object.props = some (.data value w e))
    (static : StaticValue value role) (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) :
    ∃ targetValue,
      interpC (step F s₀).run C₀ = some (s₀.ret value,C₀) ∧
      interpC (step F s).run C = some (s.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret value) (s.ret targetValue) ∧
      RetainedInventory (notes.withRuntime (notes.runtime.returning role)) ν₀ ν C₀ C R live (s₀.ret value) (s.ret targetValue) := by
  obtain ⟨targetValue,left,right,post,relation⟩ := step_global_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h name env object value w e control localLookup read ordinary descriptor
    globalLive globalFixed
  have runtime := inventory.runtime.returning (static.source ν₀ C₀) (static.target relation ν C)
  exact ⟨targetValue,left,right,post,inventory.heap_step runtime rfl rfl (TableExtends.refl C₀) (TableExtends.refl C)⟩

end Host.Ts.Owned.Annotated
