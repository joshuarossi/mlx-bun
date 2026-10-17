import contracts.mlx.ArrayStorage
import contracts.mlx.WriteOwnership

namespace Inference.Contracts.Mlx.HalfArrayWrites

-- One 16-bit store per logical thread. Arithmetic producers and the scalar
-- copy variants instantiate the same ownership and completed-readback lemma.
def entry (base : Nat) (values : Fin n → BitVec 16) (i : Fin n) : HalfMemory.Store :=
  ⟨base/2+i.val, values i⟩
def programs (base : Nat) (values : Fin n → BitVec 16) : List (List HalfMemory.Store) :=
  (List.finRange n).map (fun i => [entry base values i])

theorem member (base : Nat) (values : Fin n → BitVec 16) (store : HalfMemory.Store)
    (inside : store ∈ (programs base values).flatten) : ∃ i, store=entry base values i := by
  obtain ⟨thread, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp ht
  exact ⟨i, List.mem_singleton.mp hs⟩

theorem covers (base : Nat) (values : Fin n → BitVec 16) (i : Fin n) :
    entry base values i ∈ (programs base values).flatten :=
  List.mem_flatten.mpr ⟨[entry base values i], List.mem_map.mpr ⟨i, List.mem_finRange _, rfl⟩, by simp⟩

theorem separated (base : Nat) (values : Fin n → BitVec 16) :
    WriteOwnership.Separated MemoryCells.Store.word (programs base values) := by
  apply List.pairwise_map.mpr
  apply (List.nodup_finRange n).imp_of_mem
  intro first second _ _ different word left right
  have leftEq : word=(entry base values first).word := by simpa only [List.map_singleton, List.mem_singleton] using left
  have rightEq : word=(entry base values second).word := by simpa only [List.map_singleton, List.mem_singleton] using right
  exact different (Fin.ext (Nat.add_left_cancel (leftEq.symm.trans rightEq)))

theorem stored (base : Nat) (values : Fin n → BitVec 16) (before : HalfMemory.Words)
    (schedule : List HalfMemory.Store) (remaining : List (List HalfMemory.Store))
    (execution : ThreadgroupWrites.Executes (programs base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (i : Fin n) :
    MemoryCells.execute schedule before (base/2+i.val)=values i := by
  apply MemoryCells.completed_value execution completed before _ _
  · intro store inside same
    obtain ⟨j, rfl⟩ := member base values store inside
    have equal : j=i := Fin.ext (Nat.add_left_cancel same)
    subst j
    rfl
  · exact ⟨entry base values i, covers base values i, rfl⟩

structure Trace (base : Nat) (values : Fin n → BitVec 16) where
  before : HalfMemory.Bytes
  aligned : base%2=0
  bounded : base+2*n ≤ 2^64
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs base values) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (values : Fin n → BitVec 16) (bounded : 2*n ≤ 2^64) : Trace 0 values :=
  let stores := programs 0 values
  ⟨fun _ => 0, by decide, by simpa using bounded, stores.flatten, List.replicate stores.length [],
    ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

variable {n base : Nat} {values : Fin n → BitVec 16}

def Trace.memory (trace : Trace base values) : HalfMemory.Bytes := HalfMemory.execute trace.schedule trace.before

theorem Trace.read_correct (trace : Trace base values) (i : Fin n) :
    HalfMemory.load trace.memory (base+2*i.val)=values i := by
  unfold Trace.memory
  rw [HalfMemory.execute_load _ _ _ (by have := trace.aligned; omega), show (base+2*i.val)/2=base/2+i.val by omega]
  exact stored base values _ _ _ trace.execution trace.completed i

theorem Trace.bounds (trace : Trace base values) (i : Fin n) :
    (base+2*i.val)%2=0 ∧ base+2*i.val+2 ≤ 2^64 := by
  have := trace.aligned; have := trace.bounded; have := i.isLt
  omega

def Trace.buffer {result : Fin n → ArrayStorage.BF} (trace : Trace base (fun i => ArrayStorage.bits (result i))) :
    ArrayStorage.BFBuffer result where
  bytes := trace.memory
  base := base
  aligned := trace.aligned
  bounded := trace.bounded
  attached := trace.read_correct

theorem Trace.buffer_bytes {result : Fin n → ArrayStorage.BF} (trace : Trace base (fun i => ArrayStorage.bits (result i))) :
    trace.buffer.bytes=trace.memory := rfl

end Inference.Contracts.Mlx.HalfArrayWrites
