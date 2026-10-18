import host.ts.RenamePublicInventory
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def PublicNotes.mapRoles (notes : PublicNotes) (f : Value → Value) : PublicNotes :=
  ⟨fun a name => (notes.fields a name).map f⟩

theorem PublicFieldHolds.subst_iff {S : Type} {role : Value} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {a : Nat} {name : Name} {s : St S} (θ : Nat → SymE) :
    PublicFieldHolds (role.subst θ) ν C R a name s ↔ PublicFieldHolds role (nextValuation θ ν) C R a name s := by
  constructor
  · rintro ⟨value,field,meaning⟩
    exact ⟨value,field,(Value.holds_subst θ role value).mp meaning⟩
  · rintro ⟨value,field,meaning⟩
    exact ⟨value,field,(Value.holds_subst θ role value).mpr meaning⟩

theorem PublicNotes.mapped_entry (notes : PublicNotes) (f : Value → Value) (a : Nat) (name : Name) (role : Value)
    (entry : (notes.mapRoles f).fields a name = some role) :
    ∃ prior, notes.fields a name = some prior ∧ f prior = role := by
  cases original : notes.fields a name with
  | none => simp only [PublicNotes.mapRoles,original,Option.map_none] at entry; cases entry
  | some prior => exact ⟨prior,rfl,Option.some.inj (by simpa only [PublicNotes.mapRoles,original,Option.map_some] using entry)⟩

theorem PublicNotes.Holds.subst_iff {S : Type} {notes : PublicNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (θ : Nat → SymE) :
    (notes.mapRoles (Value.subst θ)).Holds ν C R s ↔ notes.Holds (nextValuation θ ν) C R s := by
  constructor
  · intro h a name role entry
    have mapped : (notes.mapRoles (Value.subst θ)).fields a name = some (role.subst θ) := by
      simp only [PublicNotes.mapRoles,entry,Option.map_some]
    exact (PublicFieldHolds.subst_iff θ).mp (h a name _ mapped)
  · intro h a name role entry
    obtain ⟨prior,oldEntry,rfl⟩ := notes.mapped_entry (Value.subst θ) a name role entry
    exact (PublicFieldHolds.subst_iff θ).mpr (h a name prior oldEntry)

theorem PublicInventory.subst {S : Type} {notes : PublicNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live : Nat → Prop} {s₀ s : St S} (θ : Nat → SymE)
    (inventory : PublicInventory notes (nextValuation θ ν₀) (nextValuation θ ν) C₀ C R live s₀ s) :
    PublicInventory (notes.mapRoles (Value.subst θ)) ν₀ ν C₀ C R live s₀ s := by
  refine ⟨?_,(PublicNotes.Holds.subst_iff θ).mpr inventory.source,(PublicNotes.Holds.subst_iff θ).mpr inventory.target⟩
  intro a name role entry
  obtain ⟨prior,oldEntry,_⟩ := notes.mapped_entry (Value.subst θ) a name role entry
  exact inventory.keyLive a name prior oldEntry

def PublicNotes.RenameCovers (notes renamed : PublicNotes) (K : Ren) : Prop :=
  ∀ a name role, notes.fields a name = some role → renamed.fields (K.a a) name = some (role.rename K)

theorem PublicFieldHolds.rename_iff {S : Type} {role : Value} {ν : Nat → F64} {C : CSrv}
    {a : Nat} {name : Name} {s : St S} (R K : Ren) :
    PublicFieldHolds (role.rename K) ν C R (K.a a) name s ↔ PublicFieldHolds role ν C (composeResources R K) a name s := by
  constructor
  · rintro ⟨value,field,meaning⟩
    exact ⟨value,field,(Value.holds_rename R K role value).mp meaning⟩
  · rintro ⟨value,field,meaning⟩
    exact ⟨value,field,(Value.holds_rename R K role value).mpr meaning⟩

/-- Public counters and configuration fields retain their fixed meanings when
reusing the original source template at the next cache/token valuation. -/
theorem PublicNotes.Holds.rebase {S : Type} {notes renamed : PublicNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (K : Ren) (θ : Nat → SymE) (covers : notes.RenameCovers renamed K)
    (h : (renamed.mapRoles (Value.subst θ)).Holds ν C R s) :
    notes.Holds (nextValuation θ ν) C (composeResources R K) s := by
  have rebased := (PublicNotes.Holds.subst_iff θ).mp h
  intro a name role entry
  exact (PublicFieldHolds.rename_iff R K).mp (rebased (K.a a) name _ (covers a name role entry))
end Host.Ts.Owned.Annotated
