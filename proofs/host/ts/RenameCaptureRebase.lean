import host.ts.RenameNativeCaptureInventory
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def NativeCaptureNote.mapRoles (note : NativeCaptureNote) (f : Value → Value) : NativeCaptureNote :=
  {note with roles := fun i => (note.roles i).map f}
def NativeCaptureNotes.mapRoles (notes : NativeCaptureNotes) (f : Value → Value) : NativeCaptureNotes :=
  ⟨fun a => (notes.owners a).map (fun note => note.mapRoles f)⟩
def NativeCaptureNote.rename (note : NativeCaptureNote) (K : Ren) : NativeCaptureNote := note.mapRoles (Value.rename K)

theorem NativeCaptureNote.mapped_entry (note : NativeCaptureNote) (f : Value → Value) (i : Nat) (role : Value)
    (entry : (note.mapRoles f).roles i = some role) :
    ∃ original, note.roles i = some original ∧ f original = role := by
  cases original : note.roles i with
  | none => simp only [NativeCaptureNote.mapRoles,original,Option.map_none] at entry; cases entry
  | some prior => exact ⟨prior,rfl,Option.some.inj (by simpa only [NativeCaptureNote.mapRoles,original,Option.map_some] using entry)⟩

theorem NativeCaptureNotes.mapped_entry (notes : NativeCaptureNotes) (f : Value → Value) (a : Nat) (note : NativeCaptureNote)
    (entry : (notes.mapRoles f).owners a = some note) :
    ∃ original, notes.owners a = some original ∧ original.mapRoles f = note := by
  cases original : notes.owners a with
  | none => simp only [NativeCaptureNotes.mapRoles,original,Option.map_none] at entry; cases entry
  | some prior => exact ⟨prior,rfl,Option.some.inj (by simpa only [NativeCaptureNotes.mapRoles,original,Option.map_some] using entry)⟩

theorem NativeCaptureNote.Holds.subst_iff {S : Type} {note : NativeCaptureNote} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {a : Nat} {s : St S} (θ : Nat → SymE) :
    (note.mapRoles (Value.subst θ)).Holds ν C R a s ↔ note.Holds (nextValuation θ ν) C R a s := by
  constructor
  · rintro ⟨o,data,object,kind,roles⟩
    refine ⟨o,data,object,kind,?_⟩
    intro i role entry
    have mapped : (note.mapRoles (Value.subst θ)).roles i = some (role.subst θ) := by
      simp only [NativeCaptureNote.mapRoles,entry,Option.map_some]
    exact (Value.holds_subst θ role (Host.Ts.arg data i)).mp (roles i _ mapped)
  · rintro ⟨o,data,object,kind,roles⟩
    refine ⟨o,data,object,kind,?_⟩
    intro i role entry
    obtain ⟨prior,oldEntry,rfl⟩ := note.mapped_entry (Value.subst θ) i role entry
    exact (Value.holds_subst θ prior (Host.Ts.arg data i)).mpr (roles i prior oldEntry)

theorem NativeCaptureNotes.Holds.subst_iff {S : Type} {notes : NativeCaptureNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (θ : Nat → SymE) :
    (notes.mapRoles (Value.subst θ)).Holds ν C R s ↔ notes.Holds (nextValuation θ ν) C R s := by
  constructor
  · intro h a note entry
    have mapped : (notes.mapRoles (Value.subst θ)).owners a = some (note.mapRoles (Value.subst θ)) := by
      simp only [NativeCaptureNotes.mapRoles,entry,Option.map_some]
    exact (NativeCaptureNote.Holds.subst_iff θ).mp (h a _ mapped)
  · intro h a note entry
    obtain ⟨prior,oldEntry,rfl⟩ := notes.mapped_entry (Value.subst θ) a note entry
    exact (NativeCaptureNote.Holds.subst_iff θ).mpr (h a prior oldEntry)

theorem NativeCaptureInventory.subst {S : Type} {notes : NativeCaptureNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live : Nat → Prop} {s₀ s : St S} (θ : Nat → SymE)
    (inventory : NativeCaptureInventory notes (nextValuation θ ν₀) (nextValuation θ ν) C₀ C R live s₀ s) :
    NativeCaptureInventory (notes.mapRoles (Value.subst θ)) ν₀ ν C₀ C R live s₀ s := by
  refine ⟨?_,(NativeCaptureNotes.Holds.subst_iff θ).mpr inventory.source,(NativeCaptureNotes.Holds.subst_iff θ).mpr inventory.target⟩
  intro a note entry
  obtain ⟨prior,oldEntry,_⟩ := notes.mapped_entry (Value.subst θ) a note entry
  exact inventory.keyLive a prior oldEntry

def NativeCaptureNotes.RenameCovers (notes renamed : NativeCaptureNotes) (K : Ren) : Prop :=
  ∀ a note, notes.owners a = some note → renamed.owners (K.a a) = some (note.rename K)

theorem NativeCaptureNote.Holds.rename_iff {S : Type} {note : NativeCaptureNote} {ν : Nat → F64} {C : CSrv}
    {a : Nat} {s : St S} (R K : Ren) :
    (note.rename K).Holds ν C R (K.a a) s ↔ note.Holds ν C (composeResources R K) a s := by
  constructor
  · rintro ⟨o,data,object,kind,roles⟩
    refine ⟨o,data,object,kind,?_⟩
    intro i role entry
    have mapped : (note.rename K).roles i = some (role.rename K) := by
      simp only [NativeCaptureNote.rename,NativeCaptureNote.mapRoles,entry,Option.map_some]
    exact (Value.holds_rename R K role (Host.Ts.arg data i)).mp (roles i _ mapped)
  · rintro ⟨o,data,object,kind,roles⟩
    refine ⟨o,data,object,kind,?_⟩
    intro i role entry
    obtain ⟨prior,oldEntry,rfl⟩ := note.mapped_entry (Value.rename K) i role entry
    exact (Value.holds_rename R K prior (Host.Ts.arg data i)).mpr (roles i prior oldEntry)

/-- Builtin code stays fixed while all selected captured prototype, handle
and argument meanings follow the same next-iteration resource map. -/
theorem NativeCaptureNotes.Holds.rebase {S : Type} {notes renamed : NativeCaptureNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (K : Ren) (θ : Nat → SymE) (covers : notes.RenameCovers renamed K)
    (h : (renamed.mapRoles (Value.subst θ)).Holds ν C R s) :
    notes.Holds (nextValuation θ ν) C (composeResources R K) s := by
  have rebased := (NativeCaptureNotes.Holds.subst_iff θ).mp h
  intro a note entry
  exact (NativeCaptureNote.Holds.rename_iff R K).mp (rebased (K.a a) _ (covers a note entry))
end Host.Ts.Owned.Annotated
