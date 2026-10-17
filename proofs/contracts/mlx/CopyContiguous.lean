import contracts.mlx.HalfMemory
import contracts.mlx.WriteOwnership
import Mathlib.Data.List.ProdSigma

namespace Inference.Contracts.Mlx.CopyContiguous

-- copy_s / copy_v with four 16-bit words per thread and a multiple-of-four
-- length. KV allocations and zero extensions meet the host >=65536-element
-- threshold. The native tail branch is unreachable for these allocations.
def index (thread : Fin blocks) (offset : Fin 4) : Fin (4*blocks) :=
  ⟨thread.val*4+offset.val, by have := thread.isLt; have := offset.isLt; omega⟩

theorem no_tail (thread : Fin blocks) : thread.val*4+4 ≤ 4*blocks := by
  have := thread.isLt
  omega

theorem index_unique (a b : Fin blocks) (i j : Fin 4) (same : (index a i).val=(index b j).val) : a=b ∧ i=j := by
  have := i.isLt
  have := j.isLt
  dsimp only [index] at same
  constructor <;> apply Fin.ext <;> omega

def entry (base : Nat) (values : Fin (4*blocks) → BitVec 16) (thread : Fin blocks) (offset : Fin 4) : HalfMemory.Store :=
  ⟨base/2+(index thread offset).val, values (index thread offset)⟩
def threadStores (base : Nat) (values : Fin (4*blocks) → BitVec 16) (thread : Fin blocks) : List HalfMemory.Store :=
  (List.finRange 4).map (entry base values thread)
def programs (base : Nat) (values : Fin (4*blocks) → BitVec 16) : List (List HalfMemory.Store) :=
  (List.finRange blocks).map (threadStores base values)

theorem member (base : Nat) (values : Fin (4*blocks) → BitVec 16) (store : HalfMemory.Store)
    (inside : store ∈ (programs base values).flatten) : ∃ thread offset, store=entry base values thread offset := by
  obtain ⟨stores, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨thread, _, rfl⟩ := List.mem_map.mp ht
  obtain ⟨offset, _, rfl⟩ := List.mem_map.mp hs
  exact ⟨thread, offset, rfl⟩

theorem covers (base : Nat) (values : Fin (4*blocks) → BitVec 16) (i : Fin (4*blocks)) :
    ∃ store ∈ (programs base values).flatten, store.word=base/2+i.val := by
  let thread : Fin blocks := ⟨i.val/4, by have := i.isLt; omega⟩
  let offset : Fin 4 := ⟨i.val%4, by omega⟩
  refine ⟨entry base values thread offset, ?_, ?_⟩
  · exact List.mem_flatten.mpr ⟨threadStores base values thread,
      List.mem_map.mpr ⟨thread, List.mem_finRange _, rfl⟩,
      List.mem_map.mpr ⟨offset, List.mem_finRange _, rfl⟩⟩
  · dsimp [entry, index, thread, offset]
    omega

theorem separated (base : Nat) (values : Fin (4*blocks) → BitVec 16) :
    WriteOwnership.Separated MemoryCells.Store.word (programs base values) := by
  apply List.pairwise_map.mpr
  apply (List.nodup_finRange blocks).imp_of_mem
  intro first second _ _ different word left right
  obtain ⟨a, ha, ea⟩ := List.mem_map.mp left
  obtain ⟨b, hb, eb⟩ := List.mem_map.mp right
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp ha
  obtain ⟨j, _, rfl⟩ := List.mem_map.mp hb
  have same : (index first i).val=(index second j).val := Nat.add_left_cancel (ea.trans eb.symm)
  exact different (index_unique first second i j same).1

theorem stored (base : Nat) (values : Fin (4*blocks) → BitVec 16) (before : HalfMemory.Words)
    (schedule : List HalfMemory.Store) (remaining : List (List HalfMemory.Store))
    (execution : ThreadgroupWrites.Executes (programs base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (i : Fin (4*blocks)) :
    MemoryCells.execute schedule before (base/2+i.val)=values i := by
  apply MemoryCells.completed_value execution completed before _ _
  · intro store inside same
    obtain ⟨thread, offset, rfl⟩ := member base values store inside
    have equal : index thread offset=i := Fin.ext (Nat.add_left_cancel same)
    simp only [entry, equal]
  · exact covers base values i

structure Trace (base : Nat) (values : Fin (4*blocks) → BitVec 16) where
  before : HalfMemory.Bytes
  aligned : base%2=0
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs base values) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (base : Nat) (values : Fin (4*blocks) → BitVec 16) (before : HalfMemory.Bytes) (aligned : base%2=0) : Trace base values :=
  let stores := programs base values
  ⟨before, aligned, stores.flatten, List.replicate stores.length [], ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

variable {blocks base : Nat} {values : Fin (4*blocks) → BitVec 16}

def Trace.memory (trace : Trace base values) : HalfMemory.Bytes := HalfMemory.execute trace.schedule trace.before

theorem Trace.read_correct (trace : Trace base values) (i : Fin (4*blocks)) :
    HalfMemory.load trace.memory (base+2*i.val)=values i := by
  unfold Trace.memory
  rw [HalfMemory.execute_load _ _ _ (by have := trace.aligned; omega),
    show (base+2*i.val)/2=base/2+i.val by omega]
  exact stored base values _ _ _ trace.execution trace.completed i

theorem Trace.read_bounds (trace : Trace base values) (bounded : base+2*(4*blocks) ≤ 2^64) (i : Fin (4*blocks)) :
    (base+2*i.val)%2=0 ∧ base+2*i.val+2 ≤ 2^64 := by
  have := trace.aligned
  have := i.isLt
  omega

def vectorValues (source : HalfMemory.Bytes) (sourceBase : Nat) (i : Fin (4*blocks)) : BitVec 16 :=
  HalfMemory.load source (sourceBase+2*i.val)

theorem vector_read (source : HalfMemory.Bytes) (sourceBase : Nat)
    (trace : Trace base (vectorValues (blocks := blocks) source sourceBase)) (i : Fin (4*blocks)) :
    HalfMemory.load trace.memory (base+2*i.val)=HalfMemory.load source (sourceBase+2*i.val) := trace.read_correct i

theorem scalar_read (value : BitVec 16) (trace : Trace base (fun _ : Fin (4*blocks) => value)) (i : Fin (4*blocks)) :
    HalfMemory.load trace.memory (base+2*i.val)=value := trace.read_correct i

end Inference.Contracts.Mlx.CopyContiguous
