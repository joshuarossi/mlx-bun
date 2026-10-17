import kernels.trellis.DownDevice
import contracts.mlx.HalfMemory
import contracts.mlx.WriteOwnership
import contracts.mlx.BFloat16Arithmetic

namespace Inference.Kernels.Trellis.DownOutput
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

def column (group thread component : Nat) : Nat := group*32+(thread/32)*4+component

def entry (base : Nat) (values : Nat → BF) (group thread component : Nat) : HalfMemory.Store :=
  ⟨base/2+column group thread component, (values (column group thread component)).bits⟩

def threadStores (base : Nat) (values : Nat → BF) (group thread : Nat) : List HalfMemory.Store :=
  if thread%32=0 then (List.range 4).map (entry base values group thread) else []

def programs (base : Nat) (values : Nat → BF) : List (List HalfMemory.Store) :=
  ((List.range 160).product (List.range 256)).map fun pair => threadStores base values pair.1 pair.2

theorem thread_member (base : Nat) (values : Nat → BF) (group thread : Nat) (store : HalfMemory.Store)
    (inside : store ∈ threadStores base values group thread) :
    thread%32=0 ∧ ∃ component, component<4 ∧ store=entry base values group thread component := by
  unfold threadStores at inside
  split at inside
  next active =>
    obtain ⟨component, hi, equal⟩ := List.mem_map.mp inside
    exact ⟨active, component, List.mem_range.mp hi, equal.symm⟩
  next inactive => simp at inside

theorem entry_member (base : Nat) (values : Nat → BF) (group thread component : Nat)
    (hg : group<160) (ht : thread<256) (active : thread%32=0) (hi : component<4) :
    entry base values group thread component ∈ (programs base values).flatten := by
  apply List.mem_flatten.mpr
  refine ⟨_, List.mem_map.mpr ⟨(group, thread), List.mem_product.mpr ⟨List.mem_range.mpr hg, List.mem_range.mpr ht⟩, rfl⟩, ?_⟩
  unfold threadStores
  rw [ite_eq_left active]
  exact List.mem_map.mpr ⟨component, List.mem_range.mpr hi, rfl⟩

theorem covers (base : Nat) (values : Nat → BF) (index : Nat) (bound : index<5120) :
    ∃ store ∈ (programs base values).flatten, store.word=base/2+index := by
  have coverage := DownDevice.vector_coverage index bound
  refine ⟨entry base values (index/32) ((index%32/4)*32) (index%4),
    entry_member base values _ _ _ coverage.1 (by omega) (by omega) coverage.2.2.1, ?_⟩
  simp only [entry, column]
  omega

theorem correct_value (base : Nat) (values : Nat → BF) (index : Nat)
    (store : HalfMemory.Store) (inside : store ∈ (programs base values).flatten) (equal : store.word=base/2+index) :
    store.value=(values index).bits := by
  obtain ⟨stores, hm, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨pair, _, rfl⟩ := List.mem_map.mp hm
  obtain ⟨_, component, _, rfl⟩ := thread_member base values pair.1 pair.2 store hs
  simp only [entry] at equal ⊢
  rw [show column pair.1 pair.2 component=index by omega]

theorem stored (before : HalfMemory.Words) (base : Nat) (values : Nat → BF)
    (schedule : List HalfMemory.Store) (remaining : List (List HalfMemory.Store))
    (execution : ThreadgroupWrites.Executes (programs base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (index : Nat) (bound : index<5120) :
    MemoryCells.execute schedule before (base/2+index)=(values index).bits :=
  MemoryCells.completed_value execution completed before _ _
    (fun store inside equal => correct_value base values index store inside equal) (covers base values index bound)

private def owner (base word : Nat) : Nat × Nat :=
  let index := word-base/2
  (index/32, (index%32/4)*32)

theorem separated (base : Nat) (values : Nat → BF) :
    Contracts.Mlx.WriteOwnership.Separated MemoryCells.Store.word (programs base values) := by
  unfold programs
  apply Contracts.Mlx.WriteOwnership.owned _
    ((show (List.range 160).Nodup from List.nodup_range).product (show (List.range 256).Nodup from List.nodup_range)) _ _ (owner base)
  intro pair hp store hs
  obtain ⟨group, thread⟩ := pair
  obtain ⟨_, ht⟩ := List.mem_product.mp hp
  obtain ⟨active, component, hi, rfl⟩ := thread_member base values group thread store hs
  have threadBound := List.mem_range.mp ht
  simp only [owner, entry, column, Nat.add_sub_cancel_left]
  apply Prod.ext <;> dsimp only <;> omega

theorem entry_bounds (base : Nat) (values : Nat → BF) (group thread component : Nat)
    (aligned : base%2=0) (bounded : base+2*5120 ≤ 2^64)
    (hg : group<160) (ht : thread<256) (hi : component<4) :
    let address := 2*(entry base values group thread component).word
    address%2=0 ∧ base ≤ address ∧ address+2 ≤ base+2*5120 ∧ address+2 ≤ 2^64 := by
  simp only [entry, column]
  omega

-- This is the value produced by FOLD's four ordered component operations,
-- including the BF16 conversion at each output store.
def foldValues (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction) (index : Nat) : BF :=
  BFloat16.narrow (DownDevice.output trace reduce id index)

theorem component_value (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction) (group thread : Nat) (component : Fin 4) :
    BFloat16.narrow (reduce (fun lane => DownDevice.readVector trace group (thread/32) lane.val component))=
      foldValues trace reduce (column group thread component.val) := by
  unfold foldValues DownDevice.output column
  simp only [DownDevice.vector_component, id_eq]

-- Completion here is the dependency before the output is consumed by the
-- next kernel. It is not a device-wide Metal threadgroup barrier.
structure Trace (values : Nat → BF) where
  before : HalfMemory.Bytes
  base : Nat
  aligned : base%2=0
  bounded : base+2*5120 ≤ 2^64
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs base values) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (values : Nat → BF) (before : HalfMemory.Bytes) (base : Nat)
    (aligned : base%2=0) (bounded : base+2*5120 ≤ 2^64) : Trace values :=
  let stores := programs base values
  ⟨before, base, aligned, bounded, stores.flatten, List.replicate stores.length [],
    ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

def Trace.memory (trace : Trace values) : HalfMemory.Bytes := HalfMemory.execute trace.schedule trace.before
def Trace.read (trace : Trace values) (index : Nat) : BF :=
  Model.ofBits (HalfMemory.load trace.memory (trace.base+2*index))

theorem Trace.read_correct (trace : Trace values) (index : Nat) (bound : index<5120) :
    trace.read index=values index := by
  unfold Trace.read Trace.memory
  rw [HalfMemory.execute_load _ _ _ (by have := trace.aligned; omega),
    show (trace.base+2*index)/2=trace.base/2+index by have := trace.aligned; omega,
    stored _ trace.base values trace.schedule trace.remaining trace.execution trace.completed index bound]
  rfl

end Inference.Kernels.Trellis.DownOutput
