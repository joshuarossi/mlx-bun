import host.ts.RenameParametricStringMap
import host.ts.RenameRetainedHeapFrame

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- A cached buffer lookup obtains its object role from the current source
map and structural heap relation. Every retained buffer byte and other
annotation remains valid; there is no target lookup or result premise. -/
theorem RetainedInventory.string_map_object_get
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (relation : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (callee owner buffer : Nat) (function object : Obj) (data : List Val) (key : Name)
    (extra : List Val) (entries : List (Val × Val))
    (control : source.ctl = .call (.obj callee) (.obj owner) (.str key::extra))
    (functionRead : source.heap.get callee = some (.obj function))
    (functionKind : function.kind = .fn (.native (.map .get) data))
    (objectRead : source.heap.get owner = some (.obj object))
    (objectKind : object.kind = .map entries)
    (cached : StringIndex.firstValue (pack key) entries = some (.obj buffer)) :
    interpC (step F source).run C₀ = some (source.ret (.obj buffer),C₀) ∧
    interpC (step F target).run C = some (target.ret (.obj (R.a buffer)),C) ∧
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      (source.ret (.obj buffer)) (target.ret (.obj (R.a buffer))) ∧
    RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote (.obj buffer)})
      ν₀ ν C₀ C R live (source.ret (.obj buffer)) (target.ret (.obj (R.a buffer))) := by
  obtain ⟨value,left,right,post,valueRelation⟩ := step_string_map_get_from_source F _ FR R C₀ C live framed
    before after old old' source target relation callee owner function object data key extra entries
    control functionRead functionKind objectRead objectKind
  rw [cached,Option.getD_some] at left post valueRelation
  cases valueRelation
  have runtime := inventory.runtime.returning (role:=.obj buffer) (.obj buffer) (.obj buffer)
  exact ⟨left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
