import host.ts.RenameRuntimeNotes
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def RuntimeNotes.subst (notes : RuntimeNotes) (θ : Nat → SymE) : RuntimeNotes :=
  ⟨notes.control.subst θ,substForest θ notes.stack,notes.cells.mapRoles (Value.subst θ)⟩

theorem RuntimeNotes.Holds.subst_iff {S : Type} {notes : RuntimeNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (θ : Nat → SymE) :
    (notes.subst θ).Holds ν C R s ↔ notes.Holds (nextValuation θ ν) C R s := by
  constructor
  · intro h
    exact ⟨Tree.subst_holds θ notes.control _ h.control,substForest_holds θ notes.stack _ h.stack,
      (Notes.Holds.subst θ).mp h.cells⟩
  · intro h
    exact ⟨Tree.holds_subst_of θ notes.control _ h.control,holds_substForest_of θ notes.stack _ h.stack,
      (Notes.Holds.subst θ).mpr h.cells⟩

theorem RuntimeInventory.subst {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live : Nat → Prop} {s₀ s : St S} (θ : Nat → SymE)
    (inventory : RuntimeInventory notes (nextValuation θ ν₀) (nextValuation θ ν) C₀ C R live s₀ s) :
    RuntimeInventory (notes.subst θ) ν₀ ν C₀ C R live s₀ s :=
  ⟨inventory.keyLive.mapRoles _,(RuntimeNotes.Holds.subst_iff θ).mpr inventory.source,
    (RuntimeNotes.Holds.subst_iff θ).mpr inventory.target⟩

structure RuntimeNotes.RenameCovers (notes renamed : RuntimeNotes) (K : Ren) : Prop where
  control : renamed.control = notes.control.rename K
  stack : renamed.stack = renameForest K notes.stack
  cells : notes.cells.RenameCovers renamed.cells K

/-- The next-iteration control, saved frames and cells use one common resource
map and numeric substitution. Matching these retained notes is sufficient to
reuse the original template's meanings; actual execution is proved separately. -/
theorem RuntimeNotes.Holds.rebase {S : Type} {notes renamed : RuntimeNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (K : Ren) (θ : Nat → SymE) (covers : notes.RenameCovers renamed K)
    (h : (renamed.subst θ).Holds ν C R s) :
    notes.Holds (nextValuation θ ν) C (composeResources R K) s := by
  have rebased := (RuntimeNotes.Holds.subst_iff θ).mp h
  have control := rebased.control
  have stack := rebased.stack
  rw [covers.control] at control
  rw [covers.stack] at stack
  exact ⟨Tree.rename_holds R K notes.control _ control,renameForest_holds R K notes.stack _ stack,
    Notes.Holds.rebase K θ covers.cells h.cells⟩
end Host.Ts.Owned.Annotated
