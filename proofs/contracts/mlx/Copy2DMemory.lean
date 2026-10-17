import contracts.mlx.CopyExecution
import contracts.mlx.Copy2D

namespace Inference.Contracts.Mlx.Copy2DMemory

def operation (layout : Copy2D.Layout) (label : Copy2D.Label rows columns) : CopyExecution.Operation :=
  ⟨Copy2D.sourceAddress layout label/2, layout.destinationBase/2+Copy2D.destination layout.destinationRow label⟩

def programs (layout : Copy2D.Layout) (rows columns : Nat) : List (List CopyExecution.Operation) :=
  (Copy2D.labels rows columns).map (fun label => [operation layout label])

theorem source_aligned (layout : Copy2D.Layout) (aligned : layout.sourceBase%2=0) (label : Copy2D.Label rows columns) :
    (Copy2D.sourceAddress layout label)%2=0 := by
  dsimp [Copy2D.sourceAddress]
  omega

theorem store_entry (layout : Copy2D.Layout) (aligned : layout.sourceBase%2=0) (memory : ByteMemory.Bytes)
    (label : Copy2D.Label rows columns) :
    CopyExecution.store memory (operation layout label)=Copy2D.entry layout memory label := by
  have alignedAddress := source_aligned layout aligned label
  have address : 2*(Copy2D.sourceAddress layout label/2)=Copy2D.sourceAddress layout label := by omega
  simp only [CopyExecution.store, operation, Copy2D.entry, address]

theorem fixed_programs (layout : Copy2D.Layout) (aligned : layout.sourceBase%2=0) (memory : ByteMemory.Bytes) :
    (programs layout rows columns).map (List.map (CopyExecution.store memory))=Copy2D.programs layout memory rows columns := by
  simp only [programs, List.map_map, Function.comp_def, List.map_singleton, store_entry layout aligned, Copy2D.programs]

abbrev Trace (layout : Copy2D.Layout) (rows columns : Nat) := CopyExecution.Trace (programs layout rows columns)

def toCopy (layout : Copy2D.Layout) (sourceAligned : layout.sourceBase%2=0)
    (destinationAligned : layout.destinationBase%2=0) (room : columns ≤ layout.destinationRow)
    (trace : Trace layout rows columns) : Copy2D.Trace layout trace.before rows columns where
  before := trace.before
  aligned := destinationAligned
  room := room
  schedule := trace.schedule.map (CopyExecution.store trace.before)
  remaining := trace.remaining.map (List.map (CopyExecution.store trace.before))
  execution := by rw [← fixed_programs layout sourceAligned]; exact trace.fixed_execution
  completed := trace.fixed_completed

theorem memory_equal (layout : Copy2D.Layout) (sourceAligned : layout.sourceBase%2=0)
    (destinationAligned : layout.destinationBase%2=0) (room : columns ≤ layout.destinationRow)
    (trace : Trace layout rows columns) (separate : CopyExecution.NoAlias (programs layout rows columns).flatten) :
    trace.memory=(toCopy layout sourceAligned destinationAligned room trace).memory := trace.memory_fixed separate

theorem read_correct (layout : Copy2D.Layout) (sourceAligned : layout.sourceBase%2=0)
    (destinationAligned : layout.destinationBase%2=0) (room : columns ≤ layout.destinationRow)
    (trace : Trace layout rows columns) (separate : CopyExecution.NoAlias (programs layout rows columns).flatten)
    (label : Copy2D.Label rows columns) :
    HalfMemory.load trace.memory (layout.destinationBase+2*Copy2D.destination layout.destinationRow label)=
      HalfMemory.load trace.before (Copy2D.sourceAddress layout label) := by
  rw [memory_equal layout sourceAligned destinationAligned room trace separate]
  exact (toCopy layout sourceAligned destinationAligned room trace).read_correct label

-- Native aliasing obligations can be expressed per source/destination
-- address, including strided views, rather than declaring a whole input
-- allocation immutable as a primitive contract.
theorem member (layout : Copy2D.Layout) (op : CopyExecution.Operation) (inside : op ∈ (programs layout rows columns).flatten) :
    ∃ label : Copy2D.Label rows columns, op=operation layout label := by
  obtain ⟨thread, threadMember, opMember⟩ := List.mem_flatten.mp inside
  obtain ⟨label, _, rfl⟩ := List.mem_map.mp threadMember
  exact ⟨label, List.mem_singleton.mp opMember⟩

theorem no_alias (layout : Copy2D.Layout)
    (separate : ∀ reader writer : Copy2D.Label rows columns,
      Copy2D.sourceAddress layout reader/2≠layout.destinationBase/2+Copy2D.destination layout.destinationRow writer) :
    CopyExecution.NoAlias (programs layout rows columns).flatten := by
  intro reader hr writer hw
  obtain ⟨a, rfl⟩ := member layout reader hr
  obtain ⟨b, rfl⟩ := member layout writer hw
  exact separate a b

end Inference.Contracts.Mlx.Copy2DMemory
