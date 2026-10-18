import host.ts.renameOrdinary.RankOriginInitialCells
import host.ts.renameOrdinary.RankOriginInitializedCacheEntry

set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitialStreamSeed
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- The slice implementation reads the same initialized stream occurrence
already retained for the default GPU stream. -/
theorem address_eq : Parameter45.address = 435 := by host_kernel_rfl

theorem source_stream : input.heap.get 435 = some (.cell (some (.big (Int.ofNat 2)))) := by
  rw [←address_eq]
  exact InitialRetained.source_default_gpu

theorem stream_owned : input.ffi.mlx.objs.get 2 = some .stream :=
  InitialRetained.source_stream_object

theorem selected : InitialRetained.cells.cells 435 = some (.handle 2) := by
  rw [←address_eq]
  exact InitialCells.stream_entry

/-- The rank/pointer initialization and oracle namespace preserve the fixed
stream handle role. Its ownership comes from the reached source initialization. -/
theorem entry_selected (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control fnRole thisRole saved caller).runtime.cells.cells 435 = some (.handle 2) := by
  have nr : 435 ≠ RetainedPrefix.Source5.address := by decide +kernel
  have np : 435 ≠ RetainedPrefix.Source0.address := by decide +kernel
  simp only [RankShapeRetained.EntryNotes,RetainedSeed.seededCells,Notes.write,
    ite_eq_right nr,ite_eq_right np]
  change (InitialRetained.cells.cells 435).map (Annotated.Value.subst LoopVariables.oracleVariables) = _
  rw [selected]
  rfl

end Host.Load.Run.Full.Ordinary.RankOrigin.InitialStreamSeed
