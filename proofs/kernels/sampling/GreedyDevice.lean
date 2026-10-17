import kernels.sampling.LogSumExpDevice
import kernels.sampling.NormalizedArgmaxDevice
import kernels.sampling.GreedySampling

namespace Inference.Kernels.Sampling.GreedyDevice
open Contracts.Mlx ArgmaxPairs
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

@[irreducible] def candidates {logits : Fin 248320 → BF} {normalizer : BF}
    (source : ArrayStorage.BFBuffer logits) (lse : ArrayStorage.BFBuffer (fun _ : Fin 1 => normalizer)) (i : Fin 248320) : Candidate :=
  ⟨some (NormalizedScores.value (source.read i) (lse.read 0)), i.val⟩

theorem candidates_eq {logits : Fin 248320 → BF} {normalizer : BF}
    (source : ArrayStorage.BFBuffer logits) (lse : ArrayStorage.BFBuffer (fun _ : Fin 1 => normalizer)) :
    candidates source lse=NormalizedScores.candidates logits normalizer := by
  funext i
  unfold candidates
  rw [ArrayStorage.BFBuffer.read_correct, ArrayStorage.BFBuffer.read_correct]
  rfl

structure Execution (p : LogSumExpRanges.Platform) (logits : Fin 248320 → BF) where
  lse : LogSumExpDevice.Execution p logits
  selection : NormalizedArgmaxDevice.Execution (candidates lse.source lse.outputBuffer)

def Execution.fromLse (p : LogSumExpRanges.Platform) (logits : Fin 248320 → BF) (lse : LogSumExpDevice.Execution p logits) : Execution p logits :=
  ⟨lse, NormalizedArgmaxDevice.Execution.canonical (candidates lse.source lse.outputBuffer)⟩

def Execution.fromStorage (p : LogSumExpRanges.Platform) (logits : Fin 248320 → BF) (source : ArrayStorage.BFBuffer logits) : Execution p logits :=
  Execution.fromLse p logits (LogSumExpDevice.Execution.fromStorage p logits source)

variable {p : LogSumExpRanges.Platform} {logits : Fin 248320 → BF}

theorem Execution.input_eq (execution : Execution p logits) :
    candidates execution.lse.source execution.lse.outputBuffer=NormalizedScores.candidates logits (LogSumExpRanges.value p logits) := by
  rw [candidates_eq, execution.lse.value_eq]

theorem Execution.input_valid (execution : Execution p logits) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat)) :
    ∀ i, ArgmaxStorage.Valid (candidates execution.lse.source execution.lse.outputBuffer i) := by
  rw [execution.input_eq]
  intro i
  refine ⟨NormalizedScores.candidates_finite logits _ bound (LogSumExpRanges.bf16_ranges p primitive logits bound).2 i, ?_⟩
  change i.val<2^32
  omega

@[irreducible] def Execution.token (execution : Execution p logits) : Nat := execution.selection.token

theorem Execution.token_eq (execution : Execution p logits) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat)) :
    execution.token=GreedySampling.sample p logits := by
  unfold Execution.token
  rw [execution.selection.token_eq (execution.input_valid primitive bound), execution.input_eq]
  rfl

theorem Execution.token_bound (execution : Execution p logits) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat)) : execution.token<248320 := by
  obtain ⟨selected, same, _, _⟩ := (GreedySampling.correct p primitive logits bound).2.2
  rw [execution.token_eq primitive bound, same]
  exact selected.isLt

theorem Execution.token_read (execution : Execution p logits) :
    execution.token=(ByteMemory.load32 execution.selection.output.memory 0).toNat := by
  unfold Execution.token
  rfl

theorem Execution.lse_bytes (execution : Execution p logits) : execution.lse.outputBuffer.bytes=execution.lse.output.memory :=
  execution.lse.output_bytes

theorem Execution.fromStorage_input (p : LogSumExpRanges.Platform) (logits : Fin 248320 → BF) (source : ArrayStorage.BFBuffer logits) :
    (Execution.fromStorage p logits source).lse.source=source := rfl

end Inference.Kernels.Sampling.GreedyDevice
