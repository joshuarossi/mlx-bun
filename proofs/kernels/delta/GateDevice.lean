import kernels.delta.Inputs
import contracts.mlx.FloatArrayWrites
import contracts.mlx.HalfArrayWrites

namespace Inference.Kernels.Delta.GateDevice
open Contracts.Mlx
abbrev BF := ArrayStorage.BF
abbrev Heads := Fin 48 → BF

structure Storage (aLog a dtBias b : Heads) where
  logarithm : ArrayStorage.BFBuffer aLog
  projectionA : ArrayStorage.BFBuffer a
  bias : ArrayStorage.BFBuffer dtBias
  projectionB : ArrayStorage.BFBuffer b

-- The fused decay expression and the sigmoid expression retain their
-- existing BF16/FP32 rounding points. Relating generated MLX code to these
-- expressions remains a separate compiler obligation.
@[irreducible] def producedDecay (p : Inputs.Platform) (storage : Storage aLog a dtBias b) (head : Fin 48) : Float32 :=
  Decay.value p.decay (BFloat16.widen (storage.logarithm.read head))
    (storage.projectionA.read head) (storage.bias.read head)

@[irreducible] def producedBeta (p : Inputs.Platform) (storage : Storage aLog a dtBias b) (head : Fin 48) : BF :=
  Trellis.GateUpSplitTail.sigmoidValue p.expAbs (storage.projectionB.read head)

theorem produced_decay (p : Inputs.Platform) (storage : Storage aLog a dtBias b) (head : Fin 48) :
    producedDecay p storage head=Decay.value p.decay (BFloat16.widen (aLog head)) (a head) (dtBias head) := by
  unfold producedDecay
  simp only [ArrayStorage.BFBuffer.read_correct]

theorem produced_beta (p : Inputs.Platform) (storage : Storage aLog a dtBias b) (head : Fin 48) :
    producedBeta p storage head=Trellis.GateUpSplitTail.sigmoidValue p.expAbs (b head) := by
  unfold producedBeta
  rw [ArrayStorage.BFBuffer.read_correct]

structure Execution (p : Inputs.Platform) (aLog a dtBias b : Heads) where
  storage : Storage aLog a dtBias b
  decayStores : FloatArrayWrites.Trace 0 (producedDecay p storage)
  betaStores : HalfArrayWrites.Trace 0 (fun head => ArrayStorage.bits (producedBeta p storage head))

def Execution.fromStorage (p : Inputs.Platform) (aLog a dtBias b : Heads) (storage : Storage aLog a dtBias b) :
    Execution p aLog a dtBias b :=
  ⟨storage, FloatArrayWrites.Trace.canonical _ (by decide), HalfArrayWrites.Trace.canonical _ (by decide)⟩

variable {p : Inputs.Platform} {aLog a dtBias b : Heads}

def Execution.decay (execution : Execution p aLog a dtBias b) : Fin 48 → Float32 := execution.decayStores.buffer.read
def Execution.beta (execution : Execution p aLog a dtBias b) : Heads := execution.betaStores.buffer.read

theorem Execution.decay_eq (execution : Execution p aLog a dtBias b) :
    execution.decay=fun head => Decay.value p.decay (BFloat16.widen (aLog head)) (a head) (dtBias head) := by
  funext head
  unfold Execution.decay
  rw [ArrayStorage.FloatBuffer.read_correct, produced_decay]

theorem Execution.beta_eq (execution : Execution p aLog a dtBias b) :
    execution.beta=fun head => Trellis.GateUpSplitTail.sigmoidValue p.expAbs (b head) := by
  funext head
  unfold Execution.beta
  rw [ArrayStorage.BFBuffer.read_correct, produced_beta]

def Execution.decayBuffer (execution : Execution p aLog a dtBias b) : ArrayStorage.FloatBuffer execution.decay where
  bytes := execution.decayStores.memory
  base := 0
  aligned := by decide
  bounded := by decide
  attached := fun _ => rfl

def Execution.betaBuffer (execution : Execution p aLog a dtBias b) : ArrayStorage.BFBuffer execution.beta where
  bytes := execution.betaStores.memory
  base := 0
  aligned := by decide
  bounded := by decide
  attached := fun _ => rfl

theorem Execution.decay_bytes (execution : Execution p aLog a dtBias b) :
    execution.decayBuffer.bytes=execution.decayStores.memory := rfl

theorem Execution.beta_bytes (execution : Execution p aLog a dtBias b) :
    execution.betaBuffer.bytes=execution.betaStores.memory := rfl

end Inference.Kernels.Delta.GateDevice
