import host.ts.RuntimeInventoryPrivateOther
import host.ts.RenameRetainedStores
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric
section
variable {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes} {ν₀ ν : Nat → F64}
  {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
  {s₀ s : St F.S}

theorem RetainedInventory.private_store_other_step
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (owner brand : Nat) (name : Name) (role : Value) (value prior previous : Val) (e : Bool) (o₀ : Obj)
    (frames : List Frame) (head : Tree) (tail : List Tree) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .a (.put none (.priv (.obj owner) brand name) prior)::frames)
    (object : s₀.heap.get owner = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findPriv brand name o₀.priv = some (.data previous true e))
    (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = head::tail)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64)
    (different : ∀ note, notes.privates.owners owner = some note → nameEq note.name name = false) :
    ∃ (targetValue : Val) (targetObject : Obj) (targetFrames : List Frame),
      let t₀ := privateStoreState s₀ owner brand name value e o₀ frames
      let t := privateStoreState s (R.a owner) (R.a brand) name targetValue e targetObject targetFrames
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote role,stack := tail}) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetObject,targetFrames,left,right,post,runtime,heap,arrays,publics,buffers⟩ :=
    inventory.runtime.private_store_other_step F FR notes.runtime notes.privates notes.captures notes.arrays notes.publicFields
      notes.buffers ν₀ ν C₀ C R live framed before after old old' s₀ s h inventory.heapInventory inventory.arrays
      inventory.publicFields inventory.buffers owner brand name role value prior previous e o₀ frames head tail
      control stack object ordinary descriptor controlNote stackNotes sourceBound targetBound different
  exact ⟨targetValue,targetObject,targetFrames,left,right,post,runtime,heap.privates,heap.captures,arrays,publics,buffers⟩

end
end Host.Ts.Owned.Annotated
