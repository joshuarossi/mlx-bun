import host.ts.RenameNativeCaptureInventory

set_option Elab.async false

namespace Host.Ts.Owned.Annotated
open Parametric

/-- An update to a source array/buffer/ordinary object is disjoint from each
selected native closure. The target disjointness follows from heap injectivity,
without inspecting a target owner or assuming a target source kind. -/
theorem NativeCaptureInventory.setNonNativeKind {S : Type} {notes : NativeCaptureNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {s₀ s : St S}
    (inventory : NativeCaptureInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR (NumberRoles ν₀ ν C₀ C) R live framed before after s₀ s)
    (address : Nat) (old₀ new₀ new : Obj) (value₀ value : Val)
    (alive : live address) (object : s₀.heap.get address = some (.obj old₀))
    (nonNative : ∀ code data, old₀.kind ≠ .fn (.native code data))
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    NativeCaptureInventory notes ν₀ ν C₀ C R live
      ((s₀.setObj address new₀).ret value₀) ((s.setObj (R.a address) new).ret value) := by
  have distinct : ∀ owner note, notes.owners owner = some note → owner ≠ address := by
    intro owner note selected same
    obtain ⟨closure,data,read,kind,_⟩ := inventory.source owner note selected
    have sourceRead : s₀.heap.get owner = some (.obj closure) := read
    rw [same,object] at sourceRead
    have equal := HObj.obj.inj (Option.some.inj sourceRead)
    subst closure
    exact nonNative note.code data kind
  apply inventory.frame (fun _ h => h)
  · intro owner note selected
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right (distinct owner note selected)]
  · intro owner note selected
    have targetDistinct : R.a owner ≠ R.a address := fun same => distinct owner note selected
      (heap.inj owner address (inventory.keyLive owner note selected) alive same)
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right targetDistinct]

end Host.Ts.Owned.Annotated
