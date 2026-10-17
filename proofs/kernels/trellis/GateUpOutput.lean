import contracts.mlx.HalfMemory
import contracts.mlx.BFloat16Arithmetic
import contracts.mlx.BFloat16
import contracts.mlx.WriteOwnership
import kernels.trellis.GateUpCodebook

namespace Inference.Kernels.Trellis.GateUpOutput
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

def entry (base : Nat) (values : Nat → BF) (group thread iteration : Nat) : HalfMemory.Store :=
  let row := GateUpCodebook.row group (thread/32) iteration
  ⟨base/2+row, (values row).bits⟩

def threadStores (base : Nat) (values : Nat → BF) (group thread : Nat) : List HalfMemory.Store :=
  if thread%32=0 then
    ((List.range 4).filter (fun iteration => decide (GateUpCodebook.row group (thread/32) iteration<17408))).map
      (entry base values group thread)
  else []

def programs (base : Nat) (values : Nat → BF) : List (List HalfMemory.Store) :=
  ((List.range 160).product (List.range 1024)).map fun pair => threadStores base values pair.1 pair.2

theorem thread_member (base : Nat) (values : Nat → BF) (group thread : Nat) (store : HalfMemory.Store)
    (inside : store ∈ threadStores base values group thread) :
    thread%32=0 ∧ ∃ iteration, iteration<4 ∧ GateUpCodebook.row group (thread/32) iteration<17408 ∧
      store=entry base values group thread iteration := by
  unfold threadStores at inside
  split at inside
  next active =>
    obtain ⟨iteration, hi, equal⟩ := List.mem_map.mp inside
    obtain ⟨range, valid⟩ := List.mem_filter.mp hi
    exact ⟨active, iteration, List.mem_range.mp range, of_decide_eq_true valid, equal.symm⟩
  next inactive => simp at inside

theorem entry_member (base : Nat) (values : Nat → BF) (group thread iteration : Nat)
    (hg : group<160) (ht : thread<1024) (active : thread%32=0) (hi : iteration<4)
    (valid : GateUpCodebook.row group (thread/32) iteration<17408) :
    entry base values group thread iteration ∈ (programs base values).flatten := by
  apply List.mem_flatten.mpr
  refine ⟨_, List.mem_map.mpr ⟨(group, thread), List.mem_product.mpr ⟨List.mem_range.mpr hg, List.mem_range.mpr ht⟩, rfl⟩, ?_⟩
  unfold threadStores
  rw [ite_eq_left active]
  exact List.mem_map.mpr ⟨iteration, List.mem_filter.mpr ⟨List.mem_range.mpr hi, by simp [valid]⟩, rfl⟩

theorem covers (base : Nat) (values : Nat → BF) (row : Nat) (bound : row<17408) :
    ∃ store ∈ (programs base values).flatten, store.word=base/2+row := by
  obtain ⟨hg, hs, hi, same⟩ := GateUpCodebook.row_coverage row bound
  have thread : row%32*32/32=row%32 := by omega
  refine ⟨entry base values (row%5120/32) (row%32*32) (row/5120),
    entry_member base values _ _ _ hg (by omega) (by omega) hi (by rwa [thread, same]), ?_⟩
  simp only [entry, thread, same]

theorem correct_value (base : Nat) (values : Nat → BF) (row : Nat)
    (store : HalfMemory.Store) (inside : store ∈ (programs base values).flatten) (equal : store.word=base/2+row) :
    store.value=(values row).bits := by
  obtain ⟨stores, hm, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨pair, _, rfl⟩ := List.mem_map.mp hm
  obtain ⟨_, iteration, _, _, rfl⟩ := thread_member base values pair.1 pair.2 store hs
  simp only [entry] at equal ⊢
  rw [show GateUpCodebook.row pair.1 (pair.2/32) iteration=row by omega]

theorem stored (before : HalfMemory.Words) (base : Nat) (values : Nat → BF)
    (schedule : List HalfMemory.Store) (remaining : List (List HalfMemory.Store))
    (execution : ThreadgroupWrites.Executes (programs base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (row : Nat) (bound : row<17408) :
    MemoryCells.execute schedule before (base/2+row)=(values row).bits :=
  MemoryCells.completed_value execution completed before _ _
    (fun store inside equal => correct_value base values row store inside equal) (covers base values row bound)

private def owner (base word : Nat) : Nat × Nat :=
  let row := word-base/2
  (row%5120/32, row%32*32)

theorem separated (base : Nat) (values : Nat → BF) :
    Contracts.Mlx.WriteOwnership.Separated MemoryCells.Store.word (programs base values) := by
  unfold programs
  apply Contracts.Mlx.WriteOwnership.owned _
    ((show (List.range 160).Nodup from List.nodup_range).product (show (List.range 1024).Nodup from List.nodup_range)) _ _ (owner base)
  intro pair hp store hs
  obtain ⟨group, thread⟩ := pair
  obtain ⟨hg, ht⟩ := List.mem_product.mp hp
  obtain ⟨active, iteration, _, _, rfl⟩ := thread_member base values group thread store hs
  have threadBound := List.mem_range.mp ht
  have inverse := GateUpCodebook.row_inverse group (thread/32) iteration (List.mem_range.mp hg) (by omega)
  simp only [owner, entry, Nat.add_sub_cancel_left, inverse.1, inverse.2.1, show thread/32*32=thread by omega]

-- The producer completes before down reads the immutable activation buffer.
-- Native command dependencies and allocation implement this logical handoff.
structure Trace (values : Nat → BF) where
  before : HalfMemory.Bytes
  base : Nat
  aligned : base%2=0
  bounded : base+2*17408 ≤ 2^64
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs base values) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (values : Nat → BF) (before : HalfMemory.Bytes) (base : Nat)
    (aligned : base%2=0) (bounded : base+2*17408 ≤ 2^64) : Trace values :=
  let stores := programs base values
  ⟨before, base, aligned, bounded, stores.flatten, List.replicate stores.length [],
    ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

def Trace.memory (trace : Trace values) : HalfMemory.Bytes := HalfMemory.execute trace.schedule trace.before
def Trace.read (trace : Trace values) (row : Nat) : Float32 :=
  BFloat16.widen (Model.ofBits (HalfMemory.load trace.memory (trace.base+2*row)))

theorem Trace.read_correct (trace : Trace values) (row : Nat) (bound : row<17408) :
    trace.read row=BFloat16.widen (values row) := by
  unfold Trace.read Trace.memory
  rw [HalfMemory.execute_load _ _ _ (by have := trace.aligned; omega),
    show (trace.base+2*row)/2=trace.base/2+row by have := trace.aligned; omega,
    stored _ trace.base values trace.schedule trace.remaining trace.execution trace.completed row bound]
  rfl

theorem Trace.read_bounds (trace : Trace values) (row : Nat) (bound : row<17408) :
    (trace.base+2*row)%2=0 ∧ trace.base ≤ trace.base+2*row ∧ trace.base+2*row+2 ≤ 2^64 := by
  have := trace.aligned
  have := trace.bounded
  omega

end Inference.Kernels.Trellis.GateUpOutput
