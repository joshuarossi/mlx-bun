import host.ts.RenameBufferInventory

set_option Elab.async false

namespace Host.Ts.Owned.Annotated
open Parametric

/-- Updating a source non-buffer object is disjoint from every retained
buffer owner. Target disjointness follows from live heap injectivity. -/
theorem BufferInventory.setNonBufferKind {S : Type} {notes : BufferNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {s₀ s : St S}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR (NumberRoles ν₀ ν C₀ C) R live framed before after s₀ s)
    (address : Nat) (old₀ new₀ new : Obj) (value₀ value : Val)
    (alive : live address) (object : s₀.heap.get address = some (.obj old₀))
    (nonBuffer : ∀ bytes, old₀.kind ≠ .buf bytes)
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    BufferInventory notes ν₀ ν C₀ C R live
      ((s₀.setObj address new₀).ret value₀) ((s.setObj (R.a address) new).ret value) := by
  have distinct : ∀ owner roles, notes.owners owner = some roles → owner ≠ address := by
    intro owner roles selected same
    obtain ⟨prior,bytes,read,kind,_⟩ := inventory.source owner roles selected
    have sourceRead : s₀.heap.get owner = some (.obj prior) := read
    rw [same,object] at sourceRead
    have equal := HObj.obj.inj (Option.some.inj sourceRead)
    subst prior
    exact nonBuffer bytes kind
  apply inventory.frame (fun _ h => h)
  · intro owner roles selected
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right (distinct owner roles selected)]
  · intro owner roles selected
    have mapped : R.a owner ≠ R.a address := fun same => distinct owner roles selected
      (heap.inj owner address (inventory.keyLive owner roles selected) alive same)
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right mapped]

end Host.Ts.Owned.Annotated
