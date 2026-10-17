import contracts.mlx.Concat1D
import kernels.delta.Convolution

namespace Inference.State.ConvolutionStorage
open Contracts.Mlx Kernels.Delta
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := ArrayStorage.BF
abbrev History := Fin 3 → Fin 10240 → BF

def index (row : Fin rows) (channel : Fin 10240) : Fin (rows*10240) :=
  ⟨row.val*10240+channel.val, by have := row.isLt; have := channel.isLt; omega⟩

def flatten (values : Fin rows → Fin 10240 → α) (i : Fin (rows*10240)) : α :=
  values ⟨i.val/10240, by have := i.isLt; omega⟩ ⟨i.val%10240, by omega⟩

theorem flatten_index (values : Fin rows → Fin 10240 → α) (row : Fin rows) (channel : Fin 10240) :
    flatten values (index row channel)=values row channel := by
  unfold flatten
  congr 1 <;> apply Fin.ext <;> dsimp [index] <;> have := channel.isLt <;> omega

abbrev Storage (history : History) := ArrayStorage.BFBuffer (flatten history)

def Storage.canonical (history : History) : Storage history := ArrayStorage.BFBuffer.canonical _ (by decide)

def sourceWords {values : Fin n → BF} (storage : ArrayStorage.BFBuffer values) : Fin n → BitVec 16 :=
  Copy1D.values storage.bytes storage.base 1

theorem source_words {values : Fin n → BF} (storage : ArrayStorage.BFBuffer values) (i : Fin n) :
    sourceWords storage i=ArrayStorage.bits (values i) := by
  simpa only [sourceWords, Copy1D.values, Nat.mul_one] using storage.attached i

abbrev JoinTrace (history : History) (next : Fin 10240 → BF) (old : Storage history) (source : ArrayStorage.BFBuffer next) :=
  Concat1D.Trace (sourceWords old) (sourceWords source)

def JoinTrace.canonical (history : History) (next : Fin 10240 → BF) (old : Storage history) (source : ArrayStorage.BFBuffer next) :
    JoinTrace history next old source := Concat1D.Trace.canonical _ _ (by decide)

variable {history : History} {next : Fin 10240 → BF} {old : Storage history} {source : ArrayStorage.BFBuffer next}

theorem JoinTrace.read_correct (trace : JoinTrace history next old source) (tap : Fin 4) (channel : Fin 10240) :
    HalfMemory.load trace.memory (2*(index tap channel).val)=
      ArrayStorage.bits (Convolution.streamWindow history next tap channel) := by
  by_cases h : tap.val<3
  · let i : Fin (3*10240) := index ⟨tap.val, h⟩ channel
    have read := trace.left_read i
    rw [source_words, flatten_index] at read
    simpa only [Convolution.streamWindow, h, ↓reduceDIte, i, index] using read
  · have ht : tap.val=3 := by have := tap.isLt; omega
    have read := trace.right_read channel
    rw [source_words] at read
    simpa only [Convolution.streamWindow, h, ↓reduceDIte, index, ht, show ¬3<3 by decide] using read

def JoinTrace.buffer (trace : JoinTrace history next old source) :
    ArrayStorage.BFBuffer (flatten (Convolution.streamWindow history next)) where
  bytes := trace.memory
  base := 0
  aligned := by decide
  bounded := by decide
  attached := by
    intro i
    let tap : Fin 4 := ⟨i.val/10240, by have := i.isLt; omega⟩
    let channel : Fin 10240 := ⟨i.val%10240, by omega⟩
    have same : index tap channel=i := by apply Fin.ext; dsimp [index, tap, channel]; omega
    have read := trace.read_correct tap channel
    rw [← flatten_index (Convolution.streamWindow history next) tap channel, same] at read
    simpa only [Nat.zero_add] using read

structure Execution (history : History) (next : Fin 10240 → BF) where
  old : Storage history
  source : ArrayStorage.BFBuffer next
  joined : JoinTrace history next old source
  tail : Copy1D.Trace joined.memory 20480 1 0 30720

def Execution.fromStorage (history : History) (next : Fin 10240 → BF) (old : Storage history) : Execution history next :=
  let source := ArrayStorage.BFBuffer.canonical next (by decide)
  let joined := JoinTrace.canonical history next old source
  ⟨old, source, joined, Copy1D.Trace.canonical joined.memory 20480 1 30720 (by decide)⟩

def Execution.retained (execution : Execution history next) (row : Fin 3) (channel : Fin 10240) : BF :=
  Model.ofBits (HalfMemory.load execution.tail.memory (2*(index row channel).val))

theorem Execution.tail_read (execution : Execution history next) (row : Fin 3) (channel : Fin 10240) :
    HalfMemory.load execution.tail.memory (2*(index row channel).val)=
      ArrayStorage.bits (Convolution.streamWindow history next ⟨row.val+1, by have := row.isLt; omega⟩ channel) := by
  have read := Copy1D.vector_read _ _ _ _ execution.tail (index row channel)
  have address : 20480+2*(index row channel).val=2*(index (rows := 4) ⟨row.val+1, by have := row.isLt; omega⟩ channel).val := by
    dsimp [index]
    omega
  rw [address, execution.joined.read_correct] at read
  simpa only [Nat.zero_add] using read

theorem Execution.history_eq (execution : Execution history next) :
    execution.retained=Convolution.tail history (fun _ => next) 1 := by
  funext row channel
  unfold Execution.retained
  rw [execution.tail_read]
  change Convolution.streamWindow history next ⟨row.val+1, by have := row.isLt; omega⟩ channel=_
  unfold Convolution.streamWindow Convolution.tail Convolution.joined
  simp only [Nat.add_comm row.val 1]

def Execution.after (execution : Execution history next) : Storage execution.retained where
  bytes := execution.tail.memory
  base := 0
  aligned := by decide
  bounded := by decide
  attached := by
    intro i
    change HalfMemory.load execution.tail.memory (0+2*i.val)=
      ArrayStorage.bits (execution.retained ⟨i.val/10240, by have := i.isLt; omega⟩ ⟨i.val%10240, by omega⟩)
    change HalfMemory.load execution.tail.memory (0+2*i.val)=
      HalfMemory.load execution.tail.memory (2*(i.val/10240*10240+i.val%10240))
    congr 1
    omega

theorem Execution.next_bytes (execution : Execution history next) : execution.after.bytes=execution.tail.memory := rfl

theorem allocation_bounds : 2*40960<2^64 ∧ 40960<2^31 ∧ 30720<65536 ∧ 10240<65536 := by decide

end Inference.State.ConvolutionStorage
