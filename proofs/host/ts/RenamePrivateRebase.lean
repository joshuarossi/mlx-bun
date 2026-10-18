import host.ts.RenamePrivateInventory
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def PrivateNote.mapRole (note : PrivateNote) (f : Value → Value) : PrivateNote := {note with role := f note.role}
def PrivateNotes.mapRoles (notes : PrivateNotes) (f : Value → Value) : PrivateNotes :=
  ⟨fun a => (notes.owners a).map (fun note => note.mapRole f)⟩
def PrivateNote.rename (note : PrivateNote) (K : Ren) : PrivateNote :=
  ⟨K.a note.brand,note.name,note.role.rename K⟩

theorem PrivateNote.Holds.subst_iff {S : Type} {note : PrivateNote} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {a : Nat} {s : St S} (θ : Nat → SymE) :
    (note.mapRole (Value.subst θ)).Holds ν C R a s ↔ note.Holds (nextValuation θ ν) C R a s := by
  constructor
  · rintro ⟨value,field,role⟩
    exact ⟨value,field,(Value.holds_subst θ note.role value).mp role⟩
  · rintro ⟨value,field,role⟩
    exact ⟨value,field,(Value.holds_subst θ note.role value).mpr role⟩

theorem PrivateNotes.mapped_entry (notes : PrivateNotes) (f : Value → Value) (a : Nat) (note : PrivateNote)
    (entry : (notes.mapRoles f).owners a = some note) :
    ∃ original, notes.owners a = some original ∧ original.mapRole f = note := by
  cases original : notes.owners a with
  | none => simp only [PrivateNotes.mapRoles,original,Option.map_none] at entry; cases entry
  | some prior => exact ⟨prior,rfl,Option.some.inj (by simpa only [PrivateNotes.mapRoles,original,Option.map_some] using entry)⟩

theorem PrivateNotes.Holds.subst_iff {S : Type} {notes : PrivateNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (θ : Nat → SymE) :
    (notes.mapRoles (Value.subst θ)).Holds ν C R s ↔ notes.Holds (nextValuation θ ν) C R s := by
  constructor
  · intro h a note entry
    have mapped : (notes.mapRoles (Value.subst θ)).owners a = some (note.mapRole (Value.subst θ)) := by
      simp only [PrivateNotes.mapRoles,entry,Option.map_some]
    exact (PrivateNote.Holds.subst_iff θ).mp (h a _ mapped)
  · intro h a note entry
    obtain ⟨prior,oldEntry,rfl⟩ := notes.mapped_entry (Value.subst θ) a note entry
    exact (PrivateNote.Holds.subst_iff θ).mpr (h a prior oldEntry)

theorem PrivateInventory.subst {S : Type} {notes : PrivateNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live : Nat → Prop} {s₀ s : St S} (θ : Nat → SymE)
    (inventory : PrivateInventory notes (nextValuation θ ν₀) (nextValuation θ ν) C₀ C R live s₀ s) :
    PrivateInventory (notes.mapRoles (Value.subst θ)) ν₀ ν C₀ C R live s₀ s := by
  refine ⟨?_,(PrivateNotes.Holds.subst_iff θ).mpr inventory.source,(PrivateNotes.Holds.subst_iff θ).mpr inventory.target⟩
  intro a note entry
  obtain ⟨prior,oldEntry,rfl⟩ := notes.mapped_entry (Value.subst θ) a note entry
  exact inventory.keyLive a prior oldEntry

def PrivateNotes.RenameCovers (notes renamed : PrivateNotes) (K : Ren) : Prop :=
  ∀ a note, notes.owners a = some note → renamed.owners (K.a a) = some (note.rename K)

theorem PrivateNote.Holds.rename_iff {S : Type} {note : PrivateNote} {ν : Nat → F64} {C : CSrv}
    {a : Nat} {s : St S} (R K : Ren) :
    (note.rename K).Holds ν C R (K.a a) s ↔ note.Holds ν C (composeResources R K) a s := by
  constructor
  · rintro ⟨value,field,role⟩
    exact ⟨value,field,(Value.holds_rename R K note.role value).mp role⟩
  · rintro ⟨value,field,role⟩
    exact ⟨value,field,(Value.holds_rename R K note.role value).mpr role⟩

/-- Rebase the owner, private brand and field meaning together. The selected
future inventory may contain extra fields but cannot change a selected role. -/
theorem PrivateNotes.Holds.rebase {S : Type} {notes renamed : PrivateNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (K : Ren) (θ : Nat → SymE) (covers : notes.RenameCovers renamed K)
    (h : (renamed.mapRoles (Value.subst θ)).Holds ν C R s) :
    notes.Holds (nextValuation θ ν) C (composeResources R K) s := by
  have rebased := (PrivateNotes.Holds.subst_iff θ).mp h
  intro a note entry
  exact (PrivateNote.Holds.rename_iff R K).mp (rebased (K.a a) _ (covers a note entry))
end Host.Ts.Owned.Annotated
