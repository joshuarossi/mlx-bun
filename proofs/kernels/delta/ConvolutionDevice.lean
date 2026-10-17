import state.ConvolutionStorage

namespace Inference.Kernels.Delta.ConvolutionDevice
open Contracts.Mlx State.ConvolutionStorage
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def weightIndex (channel : Fin 10240) (tap : Fin 4) : Fin 40960 :=
  ⟨channel.val*4+tap.val, by have := channel.isLt; have := tap.isLt; omega⟩

def weightWords (weight : Fin 10240 → Fin 4 → BF) (i : Fin 40960) : BF :=
  weight ⟨i.val/4, by have := i.isLt; omega⟩ ⟨i.val%4, by omega⟩

theorem weight_index (weight : Fin 10240 → Fin 4 → BF) (channel : Fin 10240) (tap : Fin 4) :
    weightWords weight (weightIndex channel tap)=weight channel tap := by
  unfold weightWords
  congr 1 <;> apply Fin.ext <;> dsimp [weightIndex] <;> have := tap.isLt <;> omega

-- The selected depthwise kernel dispatches (10240,1,1), loads four BF16
-- taps at row stride 10240 and four contiguous weights, accumulates in
-- binary32, then narrows once and writes one BF16 output per channel.
@[irreducible] def produced (contracted : Bool) {values : Fin (4*10240) → BF} {weights : Fin 40960 → BF}
    (input : ArrayStorage.BFBuffer values) (weight : ArrayStorage.BFBuffer weights) (channel : Fin 10240) : BF :=
  Convolution.value contracted (fun tap => input.read (index tap channel)) (fun tap => weight.read (weightIndex channel tap))

structure Execution (contracted : Bool) (history : History) (next : Fin 10240 → BF) (weights : Fin 10240 → Fin 4 → BF) where
  convolution : State.ConvolutionStorage.Execution history next
  weight : ArrayStorage.BFBuffer (weightWords weights)
  stores : HalfArrayWrites.Trace 0 (fun channel => ArrayStorage.bits (produced contracted convolution.joined.buffer weight channel))

def Execution.fromStorage (contracted : Bool) (history : History) (next : Fin 10240 → BF) (weights : Fin 10240 → Fin 4 → BF)
    (storage : Storage history) : Execution contracted history next weights :=
  let convolution := State.ConvolutionStorage.Execution.fromStorage history next storage
  let weight := ArrayStorage.BFBuffer.canonical (weightWords weights) (by decide)
  ⟨convolution, weight, HalfArrayWrites.Trace.canonical _ (by decide)⟩

variable {contracted : Bool} {history : History} {next : Fin 10240 → BF} {weights : Fin 10240 → Fin 4 → BF}

def Execution.output (execution : Execution contracted history next weights) : Fin 10240 → BF := execution.stores.buffer.read

theorem Execution.output_eq (execution : Execution contracted history next weights) (channel : Fin 10240) :
    execution.output channel=Convolution.value contracted (fun tap => Convolution.streamWindow history next tap channel) (weights channel) := by
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct]
  unfold produced
  congr 1
  · funext tap
    rw [ArrayStorage.BFBuffer.read_correct, flatten_index]
  · funext tap
    rw [ArrayStorage.BFBuffer.read_correct, weight_index]

theorem Execution.window_eq (execution : Execution contracted history next weights) (channel : Fin 10240) :
    execution.output channel=Convolution.value contracted (Convolution.window (fun row => history row channel) (fun _ => next channel) 0) (weights channel) := by
  rw [execution.output_eq]
  congr 1
  funext tap
  by_cases h : tap.val<3 <;> simp only [Convolution.streamWindow, Convolution.window, Convolution.joined, Nat.zero_add, h, ↓reduceDIte]

def Execution.retained (execution : Execution contracted history next weights) : History := execution.convolution.retained

theorem Execution.history_eq (execution : Execution contracted history next weights) :
    execution.retained=Convolution.tail history (fun _ => next) 1 := execution.convolution.history_eq

def Execution.after (execution : Execution contracted history next weights) : Storage execution.retained := execution.convolution.after

theorem Execution.history_bytes (execution : Execution contracted history next weights) :
    execution.after.bytes=execution.convolution.tail.memory := rfl

theorem grid_addresses (channel : Fin 10240) (tap : Fin 4) :
    ((0*1+0)*10240+channel.val)=channel.val ∧
    (0*40960+0*10240+channel.val+tap.val*10240)=(index tap channel).val ∧
    channel.val*4+tap.val=(weightIndex channel tap).val := by
  dsimp [index, weightIndex]
  omega

theorem signed_input_index (channel : Fin 10240) (tap : Fin 4) :
    (CopyIndices.elem2 channel.val tap.val 1 10240).toInt=Int.ofNat (index tap channel).val := by
  have hc := channel.isLt
  have ht := tap.isLt
  have exactIndex := CopyIndices.elem2_signed channel.val tap.val 1 10240 (by omega) (by omega) (by decide) (by decide) (by omega)
  simpa only [index, Nat.mul_one, Nat.add_comm channel.val] using exactIndex

end Inference.Kernels.Delta.ConvolutionDevice
