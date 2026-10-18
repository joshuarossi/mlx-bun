import host.ts.RenameArrayInventory
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def ArrayNotes.mapRoles (notes : ArrayNotes) (f : Value → Value) : ArrayNotes :=
  ⟨fun a => (notes.owners a).map (List.map f)⟩

theorem array_roles_transform {roles : List Value} {values : List Val} {f : Value → Value}
    {P Q : Value → Val → Prop} (equiv : ∀ role value, P (f role) value ↔ Q role value) :
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

theorem ArrayNotes.mapped_entry (notes : ArrayNotes) (f : Value → Value) (a : Nat) (roles : List Value)
    (entry : (notes.mapRoles f).owners a = some roles) :
    ∃ original, notes.owners a = some original ∧ original.map f = roles := by
  cases original : notes.owners a with
  | none => simp only [ArrayNotes.mapRoles,original,Option.map_none] at entry; cases entry
  | some prior => exact ⟨prior,rfl,Option.some.inj (by simpa only [ArrayNotes.mapRoles,original,Option.map_some] using entry)⟩

theorem ArrayContents.subst_iff {S : Type} {roles : List Value} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {a : Nat} {s : St S} (θ : Nat → SymE) :
    ArrayContents (roles.map (Value.subst θ)) ν C R a s ↔ ArrayContents roles (nextValuation θ ν) C R a s := by
  constructor
  · rintro ⟨o,values,object,kind,roles⟩
    exact ⟨o,values,object,kind,(array_roles_transform (fun role value => Value.holds_subst θ role value)).mp roles⟩
  · rintro ⟨o,values,object,kind,roles⟩
    exact ⟨o,values,object,kind,(array_roles_transform (fun role value => Value.holds_subst θ role value)).mpr roles⟩

theorem ArrayNotes.Holds.subst_iff {S : Type} {notes : ArrayNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (θ : Nat → SymE) :
    (notes.mapRoles (Value.subst θ)).Holds ν C R s ↔ notes.Holds (nextValuation θ ν) C R s := by
  constructor
  · intro h a roles entry
    have mapped : (notes.mapRoles (Value.subst θ)).owners a = some (roles.map (Value.subst θ)) := by
      simp only [ArrayNotes.mapRoles,entry,Option.map_some]
    exact (ArrayContents.subst_iff θ).mp (h a _ mapped)
  · intro h a roles entry
    obtain ⟨prior,oldEntry,rfl⟩ := notes.mapped_entry (Value.subst θ) a roles entry
    exact (ArrayContents.subst_iff θ).mpr (h a prior oldEntry)

/-- The same substitution is applied to every selected array element at once.
Array ownership and the source producer-support invariant are unchanged. -/
theorem ArrayInventory.subst {S : Type} {notes : ArrayNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live : Nat → Prop} {s₀ s : St S} (θ : Nat → SymE)
    (inventory : ArrayInventory notes (nextValuation θ ν₀) (nextValuation θ ν) C₀ C R live s₀ s) :
    ArrayInventory (notes.mapRoles (Value.subst θ)) ν₀ ν C₀ C R live s₀ s := by
  refine ⟨?_,(ArrayNotes.Holds.subst_iff θ).mpr inventory.source,(ArrayNotes.Holds.subst_iff θ).mpr inventory.target,?_⟩
  · intro a roles entry
    obtain ⟨prior,oldEntry,_⟩ := notes.mapped_entry (Value.subst θ) a roles entry
    exact inventory.keyLive a prior oldEntry
  · intro a roles entry o values object kind
    obtain ⟨prior,oldEntry,_⟩ := notes.mapped_entry (Value.subst θ) a roles entry
    exact inventory.sourceClosed a prior oldEntry o values object kind

/-- A next-cut inventory may include other arrays; every selected template
array must retain all its renamed element meanings at the mapped owner. -/
def ArrayNotes.RenameCovers (notes renamed : ArrayNotes) (K : Ren) : Prop :=
  ∀ a roles, notes.owners a = some roles → renamed.owners (K.a a) = some (roles.map (Value.rename K))

theorem ArrayContents.rename_iff {S : Type} {roles : List Value} {ν : Nat → F64} {C : CSrv}
    {a : Nat} {s : St S} (R K : Ren) :
    ArrayContents (roles.map (Value.rename K)) ν C R (K.a a) s ↔
      ArrayContents roles ν C (composeResources R K) a s := by
  constructor
  · rintro ⟨o,values,object,kind,roles⟩
    exact ⟨o,values,object,kind,(array_roles_transform (fun role value => Value.holds_rename R K role value)).mp roles⟩
  · rintro ⟨o,values,object,kind,roles⟩
    exact ⟨o,values,object,kind,(array_roles_transform (fun role value => Value.holds_rename R K role value)).mpr roles⟩

theorem ArrayNotes.Holds.rebase {S : Type} {notes renamed : ArrayNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (K : Ren) (θ : Nat → SymE) (covers : notes.RenameCovers renamed K)
    (h : (renamed.mapRoles (Value.subst θ)).Holds ν C R s) :
    notes.Holds (nextValuation θ ν) C (composeResources R K) s := by
  have rebased := (ArrayNotes.Holds.subst_iff θ).mp h
  intro a roles entry
  exact (ArrayContents.rename_iff R K).mp (rebased (K.a a) _ (covers a roles entry))
end Host.Ts.Owned.Annotated
