import contracts.mlx.CopyContiguous
import contracts.mlx.ArrayFrame
import contracts.mlx.MemoryProjection

namespace Inference.Contracts.Mlx.MultiOutputWrites
set_option maxRecDepth 10000

structure Vector where
  blocks : Nat
  base : Nat
  values : Fin (4*blocks) → BitVec 16

structure Layout (count : Nat) where
  output : Fin count → Vector
  aligned : ∀ i, (output i).base%2=0
  bounded : ∀ i, (output i).base+2*(4*(output i).blocks) ≤ 2^64
  separate : ∀ i j, i≠j → MemoryRegions.Disjoint (output i).base (2*(4*(output i).blocks))
    (output j).base (2*(4*(output j).blocks))

def programs (layout : Layout count) : List (List HalfMemory.Store) :=
  (List.finRange count).flatMap (fun i => CopyContiguous.programs (layout.output i).base (layout.output i).values)

theorem member (layout : Layout count) (store : HalfMemory.Store) (present : store ∈ (programs layout).flatten) :
    ∃ i, store ∈ (CopyContiguous.programs (layout.output i).base (layout.output i).values).flatten := by
  obtain ⟨thread, present, member⟩ := List.mem_flatten.mp present
  obtain ⟨i, _, present⟩ := List.mem_flatMap.mp present
  exact ⟨i, List.mem_flatten.mpr ⟨thread, present, member⟩⟩

theorem program_member (layout : Layout count) (i : Fin count) (store : HalfMemory.Store)
    (present : store ∈ (CopyContiguous.programs (layout.output i).base (layout.output i).values).flatten) :
    store ∈ (programs layout).flatten := by
  obtain ⟨thread, present, member⟩ := List.mem_flatten.mp present
  exact List.mem_flatten.mpr ⟨thread, List.mem_flatMap.mpr ⟨i, List.mem_finRange _, present⟩, member⟩

theorem vector_inside (layout : Layout count) (i : Fin count) (store : HalfMemory.Store)
    (present : store ∈ (CopyContiguous.programs (layout.output i).base (layout.output i).values).flatten) :
    (layout.output i).base ≤ 2*store.word ∧ 2*store.word+2 ≤ (layout.output i).base+2*(4*(layout.output i).blocks) := by
  obtain ⟨thread, offset, rfl⟩ := CopyContiguous.member _ _ store present
  have bound := (CopyContiguous.index thread offset).isLt
  have aligned := layout.aligned i
  dsimp only [CopyContiguous.entry]
  omega

-- All output arrays use one concurrent thread schedule and one byte heap.
-- A legal execution may interleave writes to different arrays arbitrarily.
structure Trace (layout : Layout count) where
  before : ByteMemory.Bytes
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs layout) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def canonical (layout : Layout count) (before : ByteMemory.Bytes) : Trace layout :=
  ⟨before, (programs layout).flatten, List.replicate (programs layout).length [],
    ThreadgroupWrites.canonical _, ThreadgroupWrites.canonical_barrier _⟩

variable {layout : Layout count}

def Trace.memory (trace : Trace layout) : ByteMemory.Bytes := HalfMemory.execute trace.schedule trace.before

theorem Trace.read_correct (trace : Trace layout) (i : Fin count) (index : Fin (4*(layout.output i).blocks)) :
    HalfMemory.load trace.memory ((layout.output i).base+2*index.val)=(layout.output i).values index := by
  unfold Trace.memory
  rw [HalfMemory.execute_load _ _ _ (by have := layout.aligned i; omega),
    show ((layout.output i).base+2*index.val)/2=(layout.output i).base/2+index.val by omega]
  apply MemoryCells.completed_value trace.execution trace.completed _ _ _
  · intro store present same
    obtain ⟨other, present⟩ := member layout store present
    by_cases equal : other=i
    · subst other
      obtain ⟨thread, offset, rfl⟩ := CopyContiguous.member _ _ store present
      have equal : CopyContiguous.index thread offset=index := Fin.ext (Nat.add_left_cancel same)
      simp only [CopyContiguous.entry, equal]
    · have inside := vector_inside layout other store present
      have separate := layout.separate other i equal
      have aligned := layout.aligned i
      have bound := index.isLt
      rcases separate with left | right <;> omega
  · obtain ⟨store, present, address⟩ := CopyContiguous.covers (layout.output i).base (layout.output i).values index
    exact ⟨store, program_member layout i store present, address⟩

theorem Trace.during_other (trace : Trace layout) {base size : Nat}
    (stores : List HalfMemory.Store) (subset : ∀ store ∈ stores, store ∈ trace.schedule)
    (separate : ∀ i, MemoryRegions.Disjoint (layout.output i).base (2*(4*(layout.output i).blocks)) base size)
    (offset : Nat) (bound : offset<size) : HalfMemory.execute stores trace.before (base+offset)=trace.before (base+offset) := by
  rw [← MemoryProjection.halves]
  apply MemoryProjection.frame
  intro store present memory
  have original := (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp (subset store present)
  obtain ⟨i, member⟩ := member layout store original
  exact MemoryProjection.half_misses store (vector_inside layout i store member) (separate i) offset bound memory

theorem Trace.other_region (trace : Trace layout) {base size : Nat}
    (separate : ∀ i, MemoryRegions.Disjoint (layout.output i).base (2*(4*(layout.output i).blocks)) base size)
    (offset : Nat) (bound : offset<size) : trace.memory (base+offset)=trace.before (base+offset) :=
  trace.during_other trace.schedule (fun _ member => member) separate offset bound

end Inference.Contracts.Mlx.MultiOutputWrites
