import host.ts.RenamePrivateInventory

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

/-- Replacing an object's kind preserves its private descriptors, including
when the selected private owner is the object being updated. -/
theorem PrivateData.setKind {S : Type} {s : St S} {owner brand : Nat} {name : Name} {value : Val}
    (field : PrivateData s owner brand name value) (address : Nat) (object : Obj) (kind : Kind)
    (read : s.heap.get address = some (.obj object)) (bound : address < 2^64) :
    PrivateData (s.setObj address {object with kind := kind}) owner brand name value := by
  by_cases same : owner = address
  · subst owner
    obtain ⟨prior,w,e,priorRead,descriptor⟩ := field
    have equal := HObj.obj.inj (Option.some.inj (priorRead.symm.trans read))
    subst prior
    refine ⟨{object with kind := kind},w,e,?_,descriptor⟩
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_true]
  · apply field.heap_at
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_eq_right same]

end Host.Ts.Owned.Parametric

namespace Host.Ts.Owned.Annotated
open Parametric

theorem PrivateNote.Holds.setKind {S : Type} {note : PrivateNote} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {owner : Nat} {s : St S} (h : note.Holds ν C R owner s) (address : Nat) (object : Obj) (kind : Kind)
    (read : s.heap.get address = some (.obj object)) (bound : address < 2^64) :
    note.Holds ν C R owner (s.setObj address {object with kind := kind}) := by
  obtain ⟨value,field,role⟩ := h
  exact ⟨value,field.setKind address object kind read bound,role⟩

/-- Fixed private-field roles survive a source/target kind update. There is no
owner-disjointness or post-field-role premise; the actual .priv headers stay. -/
theorem PrivateInventory.setKind {S : Type} {notes : PrivateNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (h : PrivateInventory notes ν₀ ν C₀ C R live s₀ s)
    (address : Nat) (object₀ object : Obj) (kind₀ kind : Kind)
    (source : s₀.heap.get address = some (.obj object₀))
    (target : s.heap.get (R.a address) = some (.obj object))
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    PrivateInventory notes ν₀ ν C₀ C R live
      (s₀.setObj address {object₀ with kind := kind₀}) (s.setObj (R.a address) {object with kind := kind}) :=
  ⟨h.keyLive,fun a note entry => (h.source a note entry).setKind address object₀ kind₀ source sourceBound,
    fun a note entry => (h.target a note entry).setKind (R.a address) object kind target targetBound⟩

end Host.Ts.Owned.Annotated
