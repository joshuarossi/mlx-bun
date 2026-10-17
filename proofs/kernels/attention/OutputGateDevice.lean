import kernels.attention.OutputGate
import contracts.mlx.HalfArrayWrites
import contracts.mlx.ArrayViews

namespace Inference.Kernels.Attention.OutputGateDevice
open Contracts.Mlx
abbrev BF := ArrayStorage.BF
abbrev Heads := Fin 24 → Fin 256 → BF

def headOf (i : Fin 6144) : Fin 24 := ⟨i.val/256, by have := i.isLt; omega⟩
def coordinate (i : Fin 6144) : Fin 256 := ⟨i.val%256, by omega⟩

structure Storage (x gate : Heads) where
  source : ∀ head, ArrayStorage.BFBuffer (x head)
  gate : ∀ head, ArrayStorage.BFBuffer (gate head)

@[irreducible] def sigmoid (p : OutputGate.Platform) (storage : Storage x gate) (i : Fin 6144) : BF :=
  OutputGate.sigmoid p ((storage.gate (headOf i)).read (coordinate i))

@[irreducible] def multiply (storage : Storage x gate) {values : Fin 6144 → BF}
    (activation : ArrayStorage.BFBuffer values) (i : Fin 6144) : BF :=
  BFloat16Arithmetic.mul ((storage.source (headOf i)).read (coordinate i)) (activation.read i)

structure Execution (p : OutputGate.Platform) (x gate : Heads) where
  storage : Storage x gate
  activations : HalfArrayWrites.Trace 0 (fun i => ArrayStorage.bits (sigmoid p storage i))
  stores : HalfArrayWrites.Trace 0 (fun i => ArrayStorage.bits (multiply storage activations.buffer i))

def Execution.fromStorage (p : OutputGate.Platform) (x gate : Heads) (storage : Storage x gate) : Execution p x gate :=
  let activations := HalfArrayWrites.Trace.canonical (fun i => ArrayStorage.bits (sigmoid p storage i)) (by decide)
  ⟨storage, activations, HalfArrayWrites.Trace.canonical _ (by decide)⟩

variable {p : OutputGate.Platform} {x gate : Heads}

def Execution.output (execution : Execution p x gate) : Fin 6144 → BF := execution.stores.buffer.read
def Execution.outputBuffer (execution : Execution p x gate) : ArrayStorage.BFBuffer execution.output :=
  ArrayViews.readback execution.stores.buffer

theorem Execution.output_eq (execution : Execution p x gate) :
    execution.output=fun i => OutputGate.forward p (x (headOf i) (coordinate i)) (gate (headOf i) (coordinate i)) := by
  funext i
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct]
  unfold multiply
  rw [ArrayStorage.BFBuffer.read_correct, ArrayStorage.BFBuffer.read_correct]
  unfold sigmoid
  rw [ArrayStorage.BFBuffer.read_correct]
  rfl

theorem Execution.activation_read (execution : Execution p x gate) (i : Fin 6144) :
    execution.activations.buffer.read i=OutputGate.sigmoid p (gate (headOf i) (coordinate i)) := by
  rw [ArrayStorage.BFBuffer.read_correct]
  unfold sigmoid
  rw [ArrayStorage.BFBuffer.read_correct]

theorem Execution.output_bytes (execution : Execution p x gate) : execution.outputBuffer.bytes=execution.stores.memory := rfl

end Inference.Kernels.Attention.OutputGateDevice
