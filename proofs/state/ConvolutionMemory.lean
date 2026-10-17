import state.ConvolutionLayout
import contracts.mlx.ConcatMemory
import kernels.delta.ConvolutionDevice

namespace Inference.State.ConvolutionMemory
open Contracts.Mlx Kernels.Delta ConvolutionStorage
set_option maxRecDepth 10000
attribute [local irreducible] ConcatMemory.programs

def joinLayout {history : History} {next : Fin 10240 → BF}
    (old : Storage history) (source : ArrayStorage.BFBuffer next) (destination : Nat)
    (oldSeparate : MemoryRegions.Disjoint (2*destination) 81920 old.base 61440)
    (sourceSeparate : MemoryRegions.Disjoint (2*destination) 81920 source.base 20480) : ConcatMemory.Layout 30720 10240 where
  left := old.base/2
  right := source.base/2
  destination := destination
  leftSeparate := by
    have address : 2*(old.base/2)=old.base := by have := old.aligned; omega
    simpa only [address] using oldSeparate
  rightSeparate := by
    have address : 2*(source.base/2)=source.base := by have := source.aligned; omega
    simpa only [address] using sourceSeparate

-- The same heap contains both inputs and the newly allocated concat view.
-- Copy operations read the evolving heap, not separately encoded snapshots.
structure Join (history : History) (next : Fin 10240 → BF) where
  old : Storage history
  source : ArrayStorage.BFBuffer next
  shared : source.bytes=old.bytes
  destination : Nat
  bounded : 2*destination+81920 ≤ 2^64
  oldSeparate : MemoryRegions.Disjoint (2*destination) 81920 old.base 61440
  sourceSeparate : MemoryRegions.Disjoint (2*destination) 81920 source.base 20480
  copy : ConcatMemory.Trace (joinLayout old source destination oldSeparate sourceSeparate)
  initial : copy.before=old.bytes

variable {history : History} {next : Fin 10240 → BF}

def Join.fromBuffers (old : Storage history) (source : ArrayStorage.BFBuffer next) (shared : source.bytes=old.bytes)
    (destination : Nat) (bounded : 2*destination+81920 ≤ 2^64)
    (oldSeparate : MemoryRegions.Disjoint (2*destination) 81920 old.base 61440)
    (sourceSeparate : MemoryRegions.Disjoint (2*destination) 81920 source.base 20480) : Join history next :=
  ⟨old, source, shared, destination, bounded, oldSeparate, sourceSeparate,
    CopyExecution.Trace.canonical _ old.bytes, rfl⟩

theorem Join.read_correct (joined : Join history next) (tap : Fin 4) (channel : Fin 10240) :
    HalfMemory.load joined.copy.memory (2*(joined.destination+(index tap channel).val))=
      ArrayStorage.bits (Convolution.streamWindow history next tap channel) := by
  by_cases inside : tap.val<3
  · let i : Fin 30720 := index ⟨tap.val, inside⟩ channel
    have read := ConcatMemory.left_read _ joined.copy i
    have address : 2*(joined.old.base/2+i.val)=joined.old.base+2*i.val := by have := joined.old.aligned; omega
    change HalfMemory.load joined.copy.memory (2*(joined.destination+i.val))=
      HalfMemory.load joined.copy.before (2*(joined.old.base/2+i.val)) at read
    rw [joined.initial, address, joined.old.attached, flatten_index] at read
    simpa only [i, index, Convolution.streamWindow, inside, ↓reduceDIte] using read
  · have last : tap.val=3 := by have := tap.isLt; omega
    have read := ConcatMemory.right_read _ joined.copy channel
    have address : 2*(joined.source.base/2+channel.val)=joined.source.base+2*channel.val := by have := joined.source.aligned; omega
    change HalfMemory.load joined.copy.memory (2*(joined.destination+30720+channel.val))=
      HalfMemory.load joined.copy.before (2*(joined.source.base/2+channel.val)) at read
    rw [joined.initial, ← joined.shared, address, joined.source.attached] at read
    simpa only [index, last, Convolution.streamWindow, inside, show ¬3<3 by decide, ↓reduceDIte, Nat.add_assoc] using read

def Join.buffer (joined : Join history next) : ArrayStorage.BFBuffer (flatten (Convolution.streamWindow history next)) where
  bytes := joined.copy.memory
  base := 2*joined.destination
  aligned := by omega
  bounded := joined.bounded
  attached := by
    intro i
    let tap : Fin 4 := ⟨i.val/10240, by have := i.isLt; omega⟩
    let channel : Fin 10240 := ⟨i.val%10240, by omega⟩
    have same : index tap channel=i := by apply Fin.ext; dsimp [index, tap, channel]; omega
    have read := joined.read_correct tap channel
    rw [← flatten_index (Convolution.streamWindow history next) tap channel, same] at read
    simpa only [Nat.mul_add] using read

-- The retained three-row tail is one contiguous scalar copy; the empty
-- second input contributes no thread programs to ConcatMemory.
def tailLayout (joined destination : Nat)
    (separate : MemoryRegions.Disjoint (2*destination) 61440 (2*joined) 81920) : ConcatMemory.Layout 30720 0 where
  left := joined+10240
  right := 0
  destination := destination
  leftSeparate := by
    dsimp [MemoryRegions.Disjoint] at separate ⊢
    omega
  rightSeparate := Or.inr (Nat.zero_le _)

structure Execution (history : History) (next : Fin 10240 → BF) where
  joined : Join history next
  destination : Nat
  bounded : 2*destination+61440 ≤ 2^64
  separate : MemoryRegions.Disjoint (2*destination) 61440 (2*joined.destination) 81920
  tail : ConcatMemory.Trace (tailLayout joined.destination destination separate)
  initial : tail.before=joined.copy.memory

def Execution.fromJoin (joined : Join history next) (destination : Nat) (bounded : 2*destination+61440 ≤ 2^64)
    (separate : MemoryRegions.Disjoint (2*destination) 61440 (2*joined.destination) 81920) : Execution history next :=
  ⟨joined, destination, bounded, separate, CopyExecution.Trace.canonical _ joined.copy.memory, rfl⟩

theorem Execution.tail_read (execution : Execution history next) (row : Fin 3) (channel : Fin 10240) :
    HalfMemory.load execution.tail.memory (2*(execution.destination+(index row channel).val))=
      ArrayStorage.bits (Convolution.tail history (fun _ => next) 1 row channel) := by
  have read := ConcatMemory.left_read _ execution.tail (index row channel)
  change HalfMemory.load execution.tail.memory (2*(execution.destination+(index row channel).val))=
    HalfMemory.load execution.tail.before (2*(execution.joined.destination+10240+(index row channel).val)) at read
  rw [execution.initial] at read
  have address : execution.joined.destination+10240+(index row channel).val=
      execution.joined.destination+(index (rows := 4) ⟨row.val+1, by have := row.isLt; omega⟩ channel).val := by
    dsimp [index]
    omega
  rw [address, execution.joined.read_correct] at read
  simpa only [Convolution.streamWindow, Convolution.tail, Convolution.joined, Nat.add_comm row.val 1] using read

def Execution.after (execution : Execution history next) : Storage (Convolution.tail history (fun _ => next) 1) where
  bytes := execution.tail.memory
  base := 2*execution.destination
  aligned := by omega
  bounded := execution.bounded
  attached := by
    intro i
    let row : Fin 3 := ⟨i.val/10240, by have := i.isLt; omega⟩
    let channel : Fin 10240 := ⟨i.val%10240, by omega⟩
    have same : index row channel=i := by apply Fin.ext; dsimp [index, row, channel]; omega
    have read := execution.tail_read row channel
    rw [← flatten_index (Convolution.tail history (fun _ => next) 1) row channel, same] at read
    simpa only [Nat.mul_add] using read

-- Tail materialization leaves the whole convolution window attached to
-- the updated shared heap, so the depthwise convolution can consume it.
def Execution.window (execution : Execution history next) : ArrayStorage.BFBuffer (flatten (Convolution.streamWindow history next)) :=
  ArrayFrame.bf execution.joined.buffer execution.tail.memory (by
    intro offset bound
    have same := ConcatMemory.other_region _ execution.tail execution.separate offset bound
    rw [execution.initial] at same
    exact same)

theorem Execution.window_bytes (execution : Execution history next) : execution.window.bytes=execution.after.bytes := rfl

theorem Execution.convolution_value (execution : Execution history next) (contracted : Bool)
    (weights : Fin 10240 → Fin 4 → BF) (weight : ArrayStorage.BFBuffer (ConvolutionDevice.weightWords weights))
    (channel : Fin 10240) :
    ConvolutionDevice.produced contracted execution.window weight channel=
      Convolution.value contracted (fun tap => Convolution.streamWindow history next tap channel) (weights channel) := by
  unfold ConvolutionDevice.produced
  congr 1
  · funext tap
    rw [ArrayStorage.BFBuffer.read_correct, flatten_index]
  · funext tap
    rw [ArrayStorage.BFBuffer.read_correct, ConvolutionDevice.weight_index]

end Inference.State.ConvolutionMemory
