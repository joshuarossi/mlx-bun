import kernels.delta.GatedDotRelative
import kernels.delta.DecayStateBounds

namespace Inference.Kernels.Delta.GatedPredictionRelative
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic
open scoped BigOperators

noncomputable def state (input : Nat → Float32) : Fin 128 → ℝ := fun i => real (input i.val)
noncomputable def key (input : Nat → Float32) : Fin 128 → ℝ := fun i => real (input (128+i.val))
noncomputable def ideal (input : Nat → Float32) : ℝ :=
  real (input 385)*RecurrenceStability.dot (state input) (key input)

theorem error (input : Nat → Float32) (flags : Gated.Contraction) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32))
    (hs : ∀ i : Fin 128, (input i.val).isFinite = true ∧ |real (input i.val)| ≤ (2 : ℝ)^(62 : Nat))
    (hk : ∀ i : Fin 128, (input (128+i.val)).isFinite = true ∧ |real (input (128+i.val))| ≤ 2)
    (hg : (input 385).isFinite = true ∧ |real (input 385)| ≤ 1)
    (keyBound : RecurrenceStability.magnitude (key input) ≤ 2)
    (hf : Arithmetic.Finite input (Gated.predictionExpr flags tree)) :
    |real (evaluate input (Gated.predictionExpr flags tree))-ideal input| ≤
      47*(2 : ℝ)^(-24 : Int)*RecurrenceStability.magnitude (state input)*
        RecurrenceStability.magnitude (key input)+(2 : ℝ)^(-49 : Int) := by
  let decayed := fun i : Fin 128 => real (FlushToZero.mul (input i.val) (input 385))
  let errors := fun i : Fin 128 => decayed i-state input i*real (input 385)
  have contraction := DecayStateBounds.contraction (fun i : Fin 128 => input i.val) (input 385)
    (fun i => (hs i).1) hg.1 hg.2
  have decayError := DecayStateBounds.error (fun i : Fin 128 => input i.val) (input 385) hs hg.1 hg.2
  have hi (i : Fin 128) : |real (evaluate input (Gated.decayedExpr i))| ≤ (2 : ℝ)^(62 : Nat) :=
    ((ContractiveMultiplication.range (input i.val) (input 385) (hs i).1 hg.1 hg.2).2).trans (hs i).2
  have dotError := GatedDotRelative.dot_norm_error input flags.prediction tree coverage
    Gated.decayedExpr (fun i => .input (128+i.val)) hi (fun i => (hk i).2) hf
  change |real (evaluate input (Gated.predictionExpr flags tree))-
      (∑ i : Fin 128, decayed i*key input i)| ≤
        46*(2 : ℝ)^(-24 : Int)*RecurrenceStability.magnitude decayed*
          RecurrenceStability.magnitude (key input)+(2 : ℝ)^(-50 : Int) at dotError
  have decayScaled := mul_le_mul_of_nonneg_right contraction.2 (RecurrenceStability.magnitude_nonnegative (key input))
  have dotBound : |real (evaluate input (Gated.predictionExpr flags tree))-
      (∑ i : Fin 128, decayed i*key input i)| ≤
        46*(2 : ℝ)^(-24 : Int)*RecurrenceStability.magnitude (state input)*
          RecurrenceStability.magnitude (key input)+(2 : ℝ)^(-50 : Int) := by
    change RecurrenceStability.magnitude decayed*RecurrenceStability.magnitude (key input) ≤
      RecurrenceStability.magnitude (state input)*RecurrenceStability.magnitude (key input) at decayScaled
    have scaled := mul_le_mul_of_nonneg_left decayScaled (by positivity : (0 : ℝ) ≤ 46*(2 : ℝ)^(-24 : Int))
    nlinarith only [dotError, scaled]
  have difference : (∑ i : Fin 128, decayed i*key input i)-ideal input =
      RecurrenceStability.dot errors (key input) := by
    unfold ideal RecurrenceStability.dot
    rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro i _
    dsimp [errors]
    ring
  have cauchy := RecurrenceStability.cauchy errors (key input)
  have errorScaled := mul_le_mul_of_nonneg_right decayError (RecurrenceStability.magnitude_nonnegative (key input))
  have errorTail := mul_le_mul_of_nonneg_left keyBound (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-59 : Int))
  have propagated : |(∑ i : Fin 128, decayed i*key input i)-ideal input| ≤
      (2 : ℝ)^(-24 : Int)*RecurrenceStability.magnitude (state input)*
        RecurrenceStability.magnitude (key input)+(2 : ℝ)^(-58 : Int) := by
    rw [difference]
    change RecurrenceStability.magnitude errors*RecurrenceStability.magnitude (key input) ≤
      ((2 : ℝ)^(-24 : Int)*RecurrenceStability.magnitude (state input)+(2 : ℝ)^(-59 : Int))*
        RecurrenceStability.magnitude (key input) at errorScaled
    norm_num at errorScaled errorTail ⊢
    nlinarith only [cauchy, errorScaled, errorTail]
  have total := (abs_sub_le (real (evaluate input (Gated.predictionExpr flags tree)))
    (∑ i : Fin 128, decayed i*key input i) (ideal input)).trans (add_le_add dotBound propagated)
  norm_num at total ⊢
  linarith only [total]

theorem ideal_bound (input : Nat → Float32) (hg : |real (input 385)| ≤ 1) :
    |ideal input| ≤ RecurrenceStability.magnitude (state input)*RecurrenceStability.magnitude (key input) := by
  unfold ideal
  rw [abs_mul]
  exact (mul_le_mul_of_nonneg_right hg (abs_nonneg _)).trans
    (by simpa only [one_mul] using RecurrenceStability.cauchy (state input) (key input))

end Inference.Kernels.Delta.GatedPredictionRelative
