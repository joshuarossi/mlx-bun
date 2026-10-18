import host.ts.renameOrdinary.RankOriginInitializedCacheShape
import host.ts.renameOrdinary.RankOriginInitialCells

set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

private theorem entry_cell (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) (a : Nat)
    (notRank : a ≠ RetainedPrefix.Source5.address) (notPointer : a ≠ RetainedPrefix.Source0.address) :
    (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller).runtime.cells.cells a =
      (InitialRetained.cells.cells a).map (Value.subst LoopVariables.oracleVariables) := by
  simp only [RankShapeRetained.EntryNotes,RetainedSeed.seededCells,Notes.write,
    ite_eq_right notRank,ite_eq_right notPointer]
  rfl

/-- Structural cells and the two owning handle notes are unchanged by the
oracle namespace embedding and the disjoint rank/pointer stores. -/
theorem entry_seeds (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    InitialCells.Seeds (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller) := by
  have same (a : Nat) (nr : a ≠ RetainedPrefix.Source5.address) (np : a ≠ RetainedPrefix.Source0.address) :=
    entry_cell ic is control fnRole thisRole saved caller a nr np
  constructor
  · rw [same 518 (by decide +kernel) (by decide +kernel),InitialCells.export_entry]; rfl
  · rw [same _ (by decide +kernel) (by decide +kernel),InitialCells.namespace_entry]; rfl
  · rw [same _ (by decide +kernel) (by decide +kernel),InitialCells.first_entry]; rfl
  · rw [same _ (by decide +kernel) (by decide +kernel),InitialCells.second_entry]; rfl
  · rw [same _ (by decide +kernel) (by decide +kernel),InitialCells.stream_entry]; rfl
  · change (PrivateSeed.notes.owners 2978923).map
      (fun note => {note with role := note.role.subst LoopVariables.oracleVariables}) = _
    rw [PrivateSeed.first_entry]
    rfl
  · change (PrivateSeed.notes.owners 3126165).map
      (fun note => {note with role := note.role.subst LoopVariables.oracleVariables}) = _
    rw [PrivateSeed.second_entry]
    rfl

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache
