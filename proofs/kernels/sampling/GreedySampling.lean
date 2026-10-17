import kernels.sampling.LogSumExpRanges
import kernels.sampling.NormalizedArgmaxExecution

namespace Inference.Kernels.Sampling.GreedySampling
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := NormalizedScores.BF

def sample (p : LogSumExpRanges.Platform) (logits : Fin 248320 → BF) : Nat :=
  (NormalizedArgmaxExecution.run (NormalizedScores.candidates logits (LogSumExpRanges.value p logits))).index
noncomputable def score (p : LogSumExpRanges.Platform) (logits : Fin 248320 → BF) (i : Fin 248320) : ℝ :=
  real (NormalizedScores.value (logits i) (LogSumExpRanges.value p logits))
noncomputable def error (p : LogSumExpRanges.Platform) (logits : Fin 248320 → BF)
    (inputError : Fin 248320 → ℝ) (i : Fin 248320) : ℝ :=
  NormalizedScores.budget (logits i) (LogSumExpRanges.value p logits) (inputError i)

theorem correct (p : LogSumExpRanges.Platform) (primitive : LogSumExpRanges.Primitives p)
    (logits : Fin 248320 → BF)
    (hl : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat)) :
    LogSumExpRanges.Trace p (fun i => BFloat16.widen (logits i)) ∧
      (∀ i, (NormalizedScores.value (logits i) (LogSumExpRanges.value p logits)).isFinite = true) ∧
      ∃ selected : Fin 248320, sample p logits = selected.val ∧
        (∀ i, score p logits i ≤ score p logits selected) ∧
        (∀ i, score p logits selected = score p logits i → selected.val ≤ i.val) := by
  have hn := LogSumExpRanges.bf16_ranges p primitive logits hl
  exact ⟨hn.1, fun i => (NormalizedScores.ranges _ _ (hl i) hn.2).1,
    NormalizedArgmaxExecution.normalized_correct logits _ hl hn.2⟩

theorem accuracy (p : LogSumExpRanges.Platform) (primitive : LogSumExpRanges.Primitives p)
    (logits : Fin 248320 → BF)
    (hl : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat))
    (target inputError : Fin 248320 → ℝ)
    (he : ∀ i, |Model.toReal (logits i)-target i| ≤ inputError i) (i : Fin 248320) :
    |score p logits i - (target i-Model.toReal (LogSumExpRanges.value p logits))| ≤ error p logits inputError i :=
  NormalizedScores.accuracy _ _ (hl i) (LogSumExpRanges.bf16_ranges p primitive logits hl).2
    _ _ (he i)

-- A common normalization offset cancels in comparisons. The margin still
-- includes the actual BF16 subtraction rounding and every upstream error.
-- No unconditional agreement with the exact-real model is claimed.
theorem target_winner (p : LogSumExpRanges.Platform) (primitive : LogSumExpRanges.Primitives p)
    (logits : Fin 248320 → BF)
    (hl : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat))
    (target inputError : Fin 248320 → ℝ)
    (he : ∀ i, |Model.toReal (logits i)-target i| ≤ inputError i) (winner : Fin 248320)
    (margin : ∀ i, i ≠ winner → target i + error p logits inputError i <
      target winner-error p logits inputError winner) : sample p logits = winner.val := by
  obtain ⟨selected, selectedEq, largest, _⟩ := (correct p primitive logits hl).2.2
  have eq := Argmax.target_margin (score p logits)
    (fun i => target i-Model.toReal (LogSumExpRanges.value p logits)) (error p logits inputError)
    winner selected (accuracy p primitive logits hl target inputError he) largest (by
      intro i different
      have h := margin i different
      linarith)
  exact selectedEq.trans (congrArg Fin.val eq)

theorem observed_winner (p : LogSumExpRanges.Platform) (primitive : LogSumExpRanges.Primitives p)
    (logits : Fin 248320 → BF)
    (hl : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat))
    (target inputError : Fin 248320 → ℝ)
    (he : ∀ i, |Model.toReal (logits i)-target i| ≤ inputError i) (winner : Fin 248320)
    (margin : ∀ i, i ≠ winner → error p logits inputError winner + error p logits inputError i <
      score p logits winner-score p logits i) : ∀ i, i ≠ winner → target i < target winner := by
  have h := Argmax.observed_margin (score p logits)
    (fun i => target i-Model.toReal (LogSumExpRanges.value p logits)) (error p logits inputError)
    winner (accuracy p primitive logits hl target inputError he) margin
  intro i different
  have hi := h i different
  linarith

end Inference.Kernels.Sampling.GreedySampling
