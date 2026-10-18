import host.ts.RenameBufferInventory
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def BufferNotes.mapRoles (notes : BufferNotes) (f : Byte → Byte) : BufferNotes :=
  ⟨fun a => (notes.owners a).map (List.map f)⟩
theorem buffer_roles_transform {roles : List Byte} {values : List Host.Ts.Byte} {f : Byte → Byte}
    {P Q : Byte → Host.Ts.Byte → Prop} (equiv : ∀ role value, P (f role) value ↔ Q role value) :
    ListR P (roles.map f) values ↔ ListR Q roles values := by
  induction roles generalizing values with
  | nil => cases values <;> constructor <;> intro h <;> cases h <;> exact .nil
  | cons role roles ih => cases values with
    | nil => constructor <;> intro h <;> cases h
    | cons value values =>
      constructor
      · intro h
        cases h with | cons head tail => exact .cons ((equiv role value).mp head) (ih.mp tail)
      · intro h
        cases h with | cons head tail => exact .cons ((equiv role value).mpr head) (ih.mpr tail)
theorem BufferNotes.mapped_entry (notes : BufferNotes) (f : Byte → Byte) (a : Nat) (roles : List Byte)
    (entry : (notes.mapRoles f).owners a = some roles) :
    ∃ original, notes.owners a = some original ∧ original.map f = roles := by
  cases original : notes.owners a with
  | none => simp only [BufferNotes.mapRoles,original,Option.map_none] at entry; cases entry
  | some prior => exact ⟨prior,rfl,Option.some.inj (by simpa only [BufferNotes.mapRoles,original,Option.map_some] using entry)⟩
theorem BufferContents.subst_iff {S : Type} {roles : List Byte} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {a : Nat} {s : St S} (θ : Nat → SymE) :
    BufferContents (roles.map (Byte.subst θ)) ν C R a s ↔ BufferContents roles (nextValuation θ ν) C R a s := by
  constructor
  · rintro ⟨o,bytes,object,kind,roles⟩
    exact ⟨o,bytes,object,kind,(buffer_roles_transform (fun role value => Byte.holds_subst θ role value)).mp roles⟩
  · rintro ⟨o,bytes,object,kind,roles⟩
    exact ⟨o,bytes,object,kind,(buffer_roles_transform (fun role value => Byte.holds_subst θ role value)).mpr roles⟩
theorem BufferNotes.Holds.subst_iff {S : Type} {notes : BufferNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (θ : Nat → SymE) :
    (notes.mapRoles (Byte.subst θ)).Holds ν C R s ↔ notes.Holds (nextValuation θ ν) C R s := by
  constructor
  · intro h a roles entry
    have mapped : (notes.mapRoles (Byte.subst θ)).owners a = some (roles.map (Byte.subst θ)) := by
      simp only [BufferNotes.mapRoles,entry,Option.map_some]
    exact (BufferContents.subst_iff θ).mp (h a _ mapped)
  · intro h a roles entry
    obtain ⟨prior,oldEntry,rfl⟩ := notes.mapped_entry (Byte.subst θ) a roles entry
    exact (BufferContents.subst_iff θ).mpr (h a prior oldEntry)
theorem BufferInventory.subst {S : Type} {notes : BufferNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live : Nat → Prop} {s₀ s : St S} (θ : Nat → SymE)
    (inventory : BufferInventory notes (nextValuation θ ν₀) (nextValuation θ ν) C₀ C R live s₀ s) :
    BufferInventory (notes.mapRoles (Byte.subst θ)) ν₀ ν C₀ C R live s₀ s := by
  refine ⟨?_,(BufferNotes.Holds.subst_iff θ).mpr inventory.source,(BufferNotes.Holds.subst_iff θ).mpr inventory.target⟩
  intro a roles entry
  obtain ⟨prior,oldEntry,_⟩ := notes.mapped_entry (Byte.subst θ) a roles entry
  exact inventory.keyLive a prior oldEntry

def BufferNotes.RenameCovers (notes renamed : BufferNotes) (K : Ren) : Prop :=
  ∀ a roles, notes.owners a = some roles → renamed.owners (K.a a) = some (roles.map (Byte.rename K))
theorem BufferContents.rename_iff {S : Type} {roles : List Byte} {ν : Nat → F64} {C : CSrv}
    {a : Nat} {s : St S} (R K : Ren) :
    BufferContents (roles.map (Byte.rename K)) ν C R (K.a a) s ↔
      BufferContents roles ν C (composeResources R K) a s := by
  constructor
  · rintro ⟨o,bytes,object,kind,roles⟩
    exact ⟨o,bytes,object,kind,(buffer_roles_transform (fun role value => Byte.holds_rename R K role value)).mp roles⟩
  · rintro ⟨o,bytes,object,kind,roles⟩
    exact ⟨o,bytes,object,kind,(buffer_roles_transform (fun role value => Byte.holds_rename R K role value)).mpr roles⟩

/-- Reusing a source cut moves the byte owners and each handle/pointer/numeric
cell meaning together. It never reinterprets a current numeric byte pattern. -/
theorem BufferNotes.Holds.rebase {S : Type} {notes renamed : BufferNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (K : Ren) (θ : Nat → SymE) (covers : notes.RenameCovers renamed K)
    (h : (renamed.mapRoles (Byte.subst θ)).Holds ν C R s) :
    notes.Holds (nextValuation θ ν) C (composeResources R K) s := by
  have rebased := (BufferNotes.Holds.subst_iff θ).mp h
  intro a roles entry
  exact (BufferContents.rename_iff R K).mp (rebased (K.a a) _ (covers a roles entry))
end Host.Ts.Owned.Annotated
