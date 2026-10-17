import contracts.mlx.FloatMemory
import contracts.mlx.WriteOwnership
import Mathlib.Data.List.ProdSigma

namespace Inference.Contracts.Mlx.CopyFloatContiguous

-- Two FP32 scalar-copy stores per thread. Recurrent-state initialization
-- uses the full-width copy_s branch, with no partial final thread.
def index (thread : Fin blocks) (offset : Fin 2) : Fin (2*blocks) :=
  ⟨thread.val*2+offset.val, by have := thread.isLt; have := offset.isLt; omega⟩

theorem no_tail (thread : Fin blocks) : thread.val*2+2 ≤ 2*blocks := by
  have := thread.isLt
  omega

theorem index_unique (a b : Fin blocks) (i j : Fin 2) (same : (index a i).val=(index b j).val) : a=b ∧ i=j := by
  have := i.isLt
  have := j.isLt
  dsimp only [index] at same
  constructor <;> apply Fin.ext <;> omega

def entry (base : Nat) (values : Fin (2*blocks) → Float32) (thread : Fin blocks) (offset : Fin 2) : ByteMemory.Store :=
  ⟨base/4+(index thread offset).val, FloatMemory.bits (values (index thread offset))⟩
def threadStores (base : Nat) (values : Fin (2*blocks) → Float32) (thread : Fin blocks) : List ByteMemory.Store :=
  (List.finRange 2).map (entry base values thread)
def programs (base : Nat) (values : Fin (2*blocks) → Float32) : List (List ByteMemory.Store) :=
  (List.finRange blocks).map (threadStores base values)

theorem member (base : Nat) (values : Fin (2*blocks) → Float32) (store : ByteMemory.Store)
    (inside : store ∈ (programs base values).flatten) : ∃ thread offset, store=entry base values thread offset := by
  obtain ⟨stores, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨thread, _, rfl⟩ := List.mem_map.mp ht
  obtain ⟨offset, _, rfl⟩ := List.mem_map.mp hs
  exact ⟨thread, offset, rfl⟩

theorem covers (base : Nat) (values : Fin (2*blocks) → Float32) (i : Fin (2*blocks)) :
    ∃ store ∈ (programs base values).flatten, store.word=base/4+i.val := by
  let thread : Fin blocks := ⟨i.val/2, by have := i.isLt; omega⟩
  let offset : Fin 2 := ⟨i.val%2, by omega⟩
  refine ⟨entry base values thread offset, ?_, ?_⟩
  · exact List.mem_flatten.mpr ⟨threadStores base values thread,
      List.mem_map.mpr ⟨thread, List.mem_finRange _, rfl⟩,
      List.mem_map.mpr ⟨offset, List.mem_finRange _, rfl⟩⟩
  · dsimp [entry, index, thread, offset]
    omega

theorem separated (base : Nat) (values : Fin (2*blocks) → Float32) :
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

theorem stored (base : Nat) (values : Fin (2*blocks) → Float32) (before : ByteMemory.Words)
    (schedule : List ByteMemory.Store) (remaining : List (List ByteMemory.Store))
    (execution : ThreadgroupWrites.Executes (programs base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (i : Fin (2*blocks)) :
    MemoryCells.execute schedule before (base/4+i.val)=FloatMemory.bits (values i) := by
  apply MemoryCells.completed_value execution completed before _ _
  · intro store inside same
    obtain ⟨thread, offset, rfl⟩ := member base values store inside
    have equal : index thread offset=i := Fin.ext (Nat.add_left_cancel same)
    simp only [entry, equal]
  · exact covers base values i

structure Trace (base : Nat) (values : Fin (2*blocks) → Float32) where
  before : ByteMemory.Bytes
  aligned : base%4=0
  schedule : List ByteMemory.Store
  remaining : List (List ByteMemory.Store)
  execution : ThreadgroupWrites.Executes (programs base values) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (base : Nat) (values : Fin (2*blocks) → Float32) (before : ByteMemory.Bytes) (aligned : base%4=0) : Trace base values :=
  let stores := programs base values
  ⟨before, aligned, stores.flatten, List.replicate stores.length [], ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

variable {blocks base : Nat} {values : Fin (2*blocks) → Float32}

def Trace.memory (trace : Trace base values) : ByteMemory.Bytes := ByteMemory.execute trace.schedule trace.before

theorem Trace.raw_read (trace : Trace base values) (i : Fin (2*blocks)) :
    ByteMemory.load32 trace.memory (base+4*i.val)=FloatMemory.bits (values i) := by
  unfold Trace.memory
  rw [ByteMemory.execute_bytes_load32 _ _ _ (by have := trace.aligned; omega),
    show (base+4*i.val)/4=base/4+i.val by omega]
  exact stored base values _ _ _ trace.execution trace.completed i

theorem Trace.read_correct (trace : Trace base values) (i : Fin (2*blocks)) :
    FloatMemory.load trace.memory (base+4*i.val)=values i := by
  unfold FloatMemory.load
  rw [trace.raw_read, FloatMemory.decode_bits]

theorem Trace.read_bounds (trace : Trace base values) (bounded : base+4*(2*blocks) ≤ 2^64) (i : Fin (2*blocks)) :
    (base+4*i.val)%4=0 ∧ base+4*i.val+4 ≤ 2^64 := by
  have := trace.aligned
  have := i.isLt
  omega

def vectorValues (source : ByteMemory.Bytes) (sourceBase : Nat) (i : Fin (2*blocks)) : Float32 :=
  FloatMemory.load source (sourceBase+4*i.val)

theorem vector_read (source : ByteMemory.Bytes) (sourceBase : Nat)
    (trace : Trace base (vectorValues (blocks := blocks) source sourceBase)) (i : Fin (2*blocks)) :
    FloatMemory.load trace.memory (base+4*i.val)=FloatMemory.load source (sourceBase+4*i.val) := trace.read_correct i

theorem scalar_read (value : Float32) (trace : Trace base (fun _ : Fin (2*blocks) => value)) (i : Fin (2*blocks)) :
    FloatMemory.load trace.memory (base+4*i.val)=value := trace.read_correct i

end Inference.Contracts.Mlx.CopyFloatContiguous
