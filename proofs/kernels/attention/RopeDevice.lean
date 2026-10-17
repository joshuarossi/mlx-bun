import kernels.attention.Rope
import contracts.mlx.Copy1D
import contracts.mlx.ArrayViews

namespace Inference.Kernels.Attention.RopeDevice
open Contracts.Mlx
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

def index (lane : Fin 32) (half : Fin 2) : Fin 64 :=
  ⟨lane.val+32*half.val, by have := lane.isLt; have := half.isLt; omega⟩

def entry (values : Fin 64 → BitVec 16) (lane : Fin 32) (half : Fin 2) : HalfMemory.Store :=
  ⟨(index lane half).val, values (index lane half)⟩

def programs (values : Fin 64 → BitVec 16) : List (List HalfMemory.Store) :=
  (List.finRange 32).map (fun lane => (List.finRange 2).map (entry values lane))

theorem member (values : Fin 64 → BitVec 16) (store : HalfMemory.Store)
    (inside : store ∈ (programs values).flatten) : ∃ lane half, store=entry values lane half := by
  obtain ⟨thread, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨lane, _, rfl⟩ := List.mem_map.mp ht
  obtain ⟨half, _, rfl⟩ := List.mem_map.mp hs
  exact ⟨lane, half, rfl⟩

theorem separated (values : Fin 64 → BitVec 16) :
    WriteOwnership.Separated MemoryCells.Store.word (programs values) := by
  apply List.pairwise_map.mpr
  apply (List.nodup_finRange 32).imp_of_mem
  intro first second _ _ different word left right
  obtain ⟨a, ha, ea⟩ := List.mem_map.mp left
  obtain ⟨b, hb, eb⟩ := List.mem_map.mp right
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp ha
  obtain ⟨j, _, rfl⟩ := List.mem_map.mp hb
  have same := ea.trans eb.symm
  have := first.isLt
  have := second.isLt
  apply different
  apply Fin.ext
  dsimp [entry, index] at same
  omega

theorem covers (values : Fin 64 → BitVec 16) (i : Fin 64) :
    ∃ store ∈ (programs values).flatten, store.word=i.val := by
  let lane : Fin 32 := ⟨i.val%32, by omega⟩
  let half : Fin 2 := ⟨i.val/32, by have := i.isLt; omega⟩
  refine ⟨entry values lane half, ?_, ?_⟩
  · exact List.mem_flatten.mpr ⟨(List.finRange 2).map (entry values lane),
      List.mem_map.mpr ⟨lane, List.mem_finRange _, rfl⟩,
      List.mem_map.mpr ⟨half, List.mem_finRange _, rfl⟩⟩
  · dsimp [entry, index, lane, half]
    omega

structure Trace (values : Fin 64 → BitVec 16) where
  before : HalfMemory.Bytes
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs values) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (values : Fin 64 → BitVec 16) (before : HalfMemory.Bytes) : Trace values :=
  let stores := programs values
  ⟨before, stores.flatten, List.replicate stores.length [], ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

def Trace.memory (trace : Trace values) : HalfMemory.Bytes := HalfMemory.execute trace.schedule trace.before

theorem Trace.read_correct (trace : Trace values) (i : Fin 64) : HalfMemory.load trace.memory (2*i.val)=values i := by
  unfold Trace.memory
  rw [HalfMemory.execute_load _ _ _ (by omega), show 2*i.val/2=i.val by omega]
  apply MemoryCells.completed_value trace.execution trace.completed _ _ _
  · intro store inside same
    obtain ⟨lane, half, rfl⟩ := member values store inside
    have equal : index lane half=i := Fin.ext same
    simp only [entry, equal]
  · exact covers values i

theorem Trace.frame (trace : Trace values) (word : Nat) (outside : 64 ≤ word) :
    HalfMemory.load trace.memory (2*word)=HalfMemory.load trace.before (2*word) := by
  unfold Trace.memory
  rw [HalfMemory.execute_load _ _ _ (by omega), show 2*word/2=word by omega]
  apply MemoryCells.frame
  intro store inside
  obtain ⟨lane, half, rfl⟩ := member values store ((ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp inside)
  have := (index lane half).isLt
  change (index lane half).val≠word
  omega

def copied {x : Fin 256 → BF} (source : ArrayStorage.BFBuffer x)
    (copy : Copy1D.Trace source.bytes source.base 1 0 256) : ArrayStorage.BFBuffer x where
  bytes := copy.memory
  base := 0
  aligned := by decide
  bounded := by decide
  attached := by
    intro i
    rw [Copy1D.vector_read, source.attached]

@[irreducible] def rotated (p : Rope.Platform) {x : Fin 256 → BF} (source : ArrayStorage.BFBuffer x)
    (theta : Fin 32 → Float32) (i : Fin 64) : BitVec 16 :=
  ArrayStorage.bits (Rope.head p source.read theta ⟨i.val, by have := i.isLt; omega⟩)

structure Execution (p : Rope.Platform) (x : Fin 256 → BF) (theta : Fin 32 → Float32) where
  source : ArrayStorage.BFBuffer x
  copy : Copy1D.Trace source.bytes source.base 1 0 256
  rotation : Trace (rotated p (copied source copy) theta)
  afterCopy : rotation.before=copy.memory

@[irreducible] def Execution.fromStorage (p : Rope.Platform) (x : Fin 256 → BF) (theta : Fin 32 → Float32)
    (source : ArrayStorage.BFBuffer x) : Execution p x theta :=
  let copy := Copy1D.Trace.canonical source.bytes source.base 1 256 (by decide)
  ⟨source, copy, Trace.canonical _ copy.memory, rfl⟩

theorem Execution.fromStorage_source (p : Rope.Platform) (x : Fin 256 → BF) (theta : Fin 32 → Float32)
    (source : ArrayStorage.BFBuffer x) : (Execution.fromStorage p x theta source).source=source := by
  unfold Execution.fromStorage
  rfl

variable {p : Rope.Platform} {x : Fin 256 → BF} {theta : Fin 32 → Float32}

theorem Execution.raw_read (execution : Execution p x theta) (i : Fin 256) :
    HalfMemory.load execution.rotation.memory (2*i.val)=ArrayStorage.bits (Rope.head p x theta i) := by
  by_cases h : i.val<64
  · rw [execution.rotation.read_correct ⟨i.val, h⟩]
    unfold rotated
    have equal : (copied execution.source execution.copy).read=x :=
      funext (ArrayStorage.BFBuffer.read_correct _)
    rw [equal]
  · rw [execution.rotation.frame i.val (by omega), execution.afterCopy,
      Rope.unchanged p x theta i (by omega)]
    simpa only [copied, Nat.zero_add] using (copied execution.source execution.copy).attached i

def Execution.buffer (execution : Execution p x theta) : ArrayStorage.BFBuffer (Rope.head p x theta) where
  bytes := execution.rotation.memory
  base := 0
  aligned := by decide
  bounded := by decide
  attached := by intro i; simpa only [Nat.zero_add] using execution.raw_read i

def Execution.output (execution : Execution p x theta) : Fin 256 → BF := execution.buffer.read
def Execution.outputBuffer (execution : Execution p x theta) : ArrayStorage.BFBuffer execution.output := ArrayViews.readback execution.buffer

theorem Execution.output_eq (execution : Execution p x theta) : execution.output=Rope.head p x theta :=
  funext execution.buffer.read_correct

theorem Execution.output_bytes (execution : Execution p x theta) : execution.outputBuffer.bytes=execution.rotation.memory := rfl

theorem rotated_first (p : Rope.Platform) {x : Fin 256 → BF} (source : ArrayStorage.BFBuffer x)
    (theta : Fin 32 → Float32) (lane : Fin 32) :
    rotated p source theta (index lane 0)=ArrayStorage.bits (Rope.value p (Rope.headInputs source.read theta lane) false) := by
  unfold rotated
  exact congrArg ArrayStorage.bits (Rope.head_first p source.read theta lane)

theorem rotated_second (p : Rope.Platform) {x : Fin 256 → BF} (source : ArrayStorage.BFBuffer x)
    (theta : Fin 32 → Float32) (lane : Fin 32) :
    rotated p source theta (index lane 1)=ArrayStorage.bits (Rope.value p (Rope.headInputs source.read theta lane) true) := by
  unfold rotated
  exact congrArg ArrayStorage.bits (Rope.head_second p source.read theta lane)

end Inference.Kernels.Attention.RopeDevice
