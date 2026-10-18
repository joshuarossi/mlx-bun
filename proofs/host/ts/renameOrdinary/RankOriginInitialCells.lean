import host.ts.renameOrdinary.RankOriginInitializedShape
import host.load.RuntimeShapeBatch

set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitialCells
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem source_export : input.heap.get 518 = some (.cell (some (.obj 2790))) := by host_kernel_rfl
theorem source_namespace : input.heap.get Preparation28.address = some (.cell (some (.obj 607))) := by host_kernel_rfl
theorem source_first : input.heap.get Preparation32.address =
    some (.cell (some (.obj RetainedShapeBatch.initialObject32))) := by host_kernel_rfl
theorem source_second : input.heap.get Preparation34.address =
    some (.cell (some (.obj RetainedShapeBatch.initialObject34))) := by host_kernel_rfl

theorem object_entry (a owner : Nat) (alive : InitialRetained.live a)
    (cell : input.heap.get a = some (.cell (some (.obj owner)))) (other : a ≠ Parameter45.address) :
    InitialRetained.cells.cells a = some (.obj owner) := by
  simp only [InitialRetained.cells,Notes.write,ite_eq_right other]
  exact structuralCells.entry alive cell rfl

theorem export_entry : InitialRetained.cells.cells 518 = some (.obj 2790) :=
  object_entry 518 2790 (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel)
    source_export (by decide +kernel)
theorem namespace_entry : InitialRetained.cells.cells Preparation28.address = some (.obj 607) :=
  object_entry _ 607 (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel)
    source_namespace (by decide +kernel)
theorem first_entry : InitialRetained.cells.cells Preparation32.address = some (.obj RetainedShapeBatch.initialObject32) :=
  object_entry _ _ (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel)
    source_first (by decide +kernel)
theorem second_entry : InitialRetained.cells.cells Preparation34.address = some (.obj RetainedShapeBatch.initialObject34) :=
  object_entry _ _ (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel)
    source_second (by decide +kernel)
theorem stream_entry : InitialRetained.cells.cells Parameter45.address = some (.handle 2) := by
  simp only [InitialRetained.cells,Notes.write,ite_true]

structure Seeds (notes : RetainedNotes) : Prop where
  exportEntry : notes.runtime.cells.cells 518 = some (.obj 2790)
  namespaceEntry : notes.runtime.cells.cells Preparation28.address = some (.obj 607)
  firstEntry : notes.runtime.cells.cells Preparation32.address = some (.obj RetainedShapeBatch.initialObject32)
  secondEntry : notes.runtime.cells.cells Preparation34.address = some (.obj RetainedShapeBatch.initialObject34)
  streamEntry : notes.runtime.cells.cells Parameter45.address = some (.handle 2)
  firstHandle : notes.privates.owners 2978923 = some ⟨4852,chars!"handle",.handle 25732⟩
  secondHandle : notes.privates.owners 3126165 = some ⟨4852,chars!"handle",.handle 29363⟩

theorem initial_seeds (control : Annotated.Tree) (stack : List Annotated.Tree) :
    Seeds (InitialRetained.notes control stack) :=
  ⟨export_entry,namespace_entry,first_entry,second_entry,stream_entry,PrivateSeed.first_entry,PrivateSeed.second_entry⟩

theorem entry_cell (initialControl : Annotated.Tree) (initialStack : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) (a : Nat)
    (notRank : a ≠ RetainedPrefix.Source5.address) (notPointer : a ≠ RetainedPrefix.Source0.address) :
    (RankShapeRetained.EntryNotes (InitialRetained.notes initialControl initialStack)
      control fnRole thisRole saved caller).runtime.cells.cells a = InitialRetained.cells.cells a := by
  simp only [RankShapeRetained.EntryNotes,RetainedSeed.seededCells,Notes.write,
    ite_eq_right notRank,ite_eq_right notPointer,InitialRetained.notes]

/-- These are the same initialized cell meanings consumed by the real
source14→39 and39→64 batches. The two rank-prefix writes are disjoint from
all five cells; the bigint GPU stream has its separately checked handle role. -/
theorem entry_seeds (initialControl : Annotated.Tree) (initialStack : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    Seeds (RankShapeRetained.EntryNotes (InitialRetained.notes initialControl initialStack)
      control fnRole thisRole saved caller) := by
  have same (a : Nat) (nr : a ≠ RetainedPrefix.Source5.address) (np : a ≠ RetainedPrefix.Source0.address) :=
    entry_cell initialControl initialStack control fnRole thisRole saved caller a nr np
  exact ⟨(same 518 (by decide +kernel) (by decide +kernel)).trans export_entry,
    (same _ (by decide +kernel) (by decide +kernel)).trans namespace_entry,
    (same _ (by decide +kernel) (by decide +kernel)).trans first_entry,
    (same _ (by decide +kernel) (by decide +kernel)).trans second_entry,
    (same _ (by decide +kernel) (by decide +kernel)).trans stream_entry,
    PrivateSeed.first_entry,PrivateSeed.second_entry⟩

end Host.Load.Run.Full.Ordinary.RankOrigin.InitialCells
