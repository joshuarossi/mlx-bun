import kernels.delta.GatedPredictionRelative
import contracts.mlx.SubtractionRelative

namespace Inference.Kernels.Delta.GatedDeltaRelative
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic
open scoped BigOperators

noncomputable def ideal (input : Nat → Float32) : ℝ :=
  (real (input 384)-GatedPredictionRelative.ideal input)*real (input 386)

theorem error (input : Nat → Float32) (flags : Gated.Contraction) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32))
    (hs : ∀ i : Fin 128, (input i.val).isFinite = true ∧ |real (input i.val)| ≤ (2 : ℝ)^(62 : Nat))
    (hk : ∀ i : Fin 128, (input (128+i.val)).isFinite = true ∧ |real (input (128+i.val))| ≤ 2)
    (hg : (input 385).isFinite = true ∧ |real (input 385)| ≤ 1)
    (stateBound : RecurrenceStability.magnitude (GatedPredictionRelative.state input) ≤ (2 : ℝ)^(59 : Nat))
    (keyBound : RecurrenceStability.magnitude (GatedPredictionRelative.key input) ≤ 2)
    (valueBound : |real (input 384)| ≤ (2 : ℝ)^(36 : Nat))
    (betaBound : |real (input 386)| ≤ 1)
    (hf : Arithmetic.Finite input (Gated.deltaExpr flags tree)) :
    |real (evaluate input (Gated.deltaExpr flags tree))| ≤ (2 : ℝ)^(62 : Nat) ∧
      |real (evaluate input (Gated.deltaExpr flags tree))-ideal input| ≤
        51*(2 : ℝ)^(-24 : Int)*RecurrenceStability.magnitude (GatedPredictionRelative.state input)*
          RecurrenceStability.magnitude (GatedPredictionRelative.key input)+
            3*(2 : ℝ)^(-24 : Int)*|real (input 384)|+(2 : ℝ)^(-47 : Int) := by
  let prediction := evaluate input (Gated.predictionExpr flags tree)
  let difference := Arithmetic.sub (input 384) prediction
  let stateSize := RecurrenceStability.magnitude (GatedPredictionRelative.state input)
  let keySize := RecurrenceStability.magnitude (GatedPredictionRelative.key input)
  have predError := GatedPredictionRelative.error input flags tree coverage hs hk hg keyBound hf.1.2.1
  have predIdeal := GatedPredictionRelative.ideal_bound input hg.2
  have predAbs := NormalizedCastBounds.absolute_of_error _ _ _ predError
  have predBound : |real prediction| ≤ (1+47*(2 : ℝ)^(-24 : Int))*stateSize*keySize+(2 : ℝ)^(-49 : Int) := by
    change |real prediction| ≤ _ at predAbs
    change |GatedPredictionRelative.ideal input| ≤ stateSize*keySize at predIdeal
    change _ ≤ 47*(2 : ℝ)^(-24 : Int)*stateSize*keySize+(2 : ℝ)^(-49 : Int) at predError
    nlinarith only [predAbs, predIdeal]
  have sizes : stateSize*keySize ≤ (2 : ℝ)^(60 : Nat) := by
    have h := mul_le_mul stateBound keyBound (RecurrenceStability.magnitude_nonnegative _) (by positivity)
    norm_num at h ⊢
    exact h
  have predCap : |real prediction| ≤ (2 : ℝ)^(61 : Nat) := by
    norm_num at predBound sizes ⊢
    nlinarith only [predBound, sizes]
  have subError := SubtractionRelative.error (input 384) prediction hf.1.1
    (finite_evaluate input _ hf.1.2.1) hf.1.2.2
  have diffBound : |real difference| ≤ (1+(2 : ℝ)^(-24 : Int))*(|real (input 384)|+|real prediction|)+
      (2 : ℝ)^(-150 : Int)+3*FlushToZero.threshold := by
    have h := NormalizedCastBounds.absolute_of_error _ _ _ subError
    have hi := abs_sub (real (input 384)) (real prediction)
    change |real difference| ≤ _ at h
    linarith only [h, hi]
  have diffCap : |real difference| ≤ (2 : ℝ)^(62 : Nat) := by
    norm_num [FlushToZero.threshold] at diffBound valueBound predCap ⊢
    linarith only [diffBound, valueBound, predCap]
  have diffFinite : difference.isFinite = true := FlushToZero.finite_flush _ hf.1.2.2
  have multiply := ContractiveMultiplication.bounded_error difference (input 386) diffFinite hf.2.1 betaBound diffCap
  have contraction := ContractiveMultiplication.range difference (input 386) diffFinite hf.2.1 betaBound
  refine ⟨contraction.2.trans diffCap, ?_⟩
  have differenceError : |real difference-(real (input 384)-GatedPredictionRelative.ideal input)| ≤
      (2 : ℝ)^(-24 : Int)*(|real (input 384)|+|real prediction|)+(2 : ℝ)^(-150 : Int)+3*FlushToZero.threshold+
        (47*(2 : ℝ)^(-24 : Int)*stateSize*keySize+(2 : ℝ)^(-49 : Int)) := by
    have predDifference : |(real (input 384)-real prediction)-
        (real (input 384)-GatedPredictionRelative.ideal input)| = |real prediction-GatedPredictionRelative.ideal input| := by
      rw [sub_sub_sub_cancel_left, abs_sub_comm]
    have triangle := abs_sub_le (real difference) (real (input 384)-real prediction)
      (real (input 384)-GatedPredictionRelative.ideal input)
    rw [predDifference] at triangle
    exact triangle.trans (add_le_add subError predError)
  have scaled := mul_le_mul_of_nonneg_right differenceError (abs_nonneg (real (input 386)))
  have nonnegative := (abs_nonneg _).trans differenceError
  have beta := mul_le_mul_of_nonneg_left betaBound nonnegative
  have productError : |real difference*real (input 386)-ideal input| ≤
      (2 : ℝ)^(-24 : Int)*(|real (input 384)|+|real prediction|)+(2 : ℝ)^(-150 : Int)+3*FlushToZero.threshold+
        (47*(2 : ℝ)^(-24 : Int)*stateSize*keySize+(2 : ℝ)^(-49 : Int)) := by
    calc
      _ = |real difference-(real (input 384)-GatedPredictionRelative.ideal input)| * |real (input 386)| := by
        rw [← abs_mul]
        congr 1
        unfold ideal
        ring
      _ ≤ _ := (scaled.trans beta).trans_eq (mul_one _)
  have total := (abs_sub_le (real (FlushToZero.mul difference (input 386)))
    (real difference*real (input 386)) (ideal input)).trans (add_le_add multiply productError)
  have productNonnegative := mul_nonneg (RecurrenceStability.magnitude_nonnegative (GatedPredictionRelative.state input))
    (RecurrenceStability.magnitude_nonnegative (GatedPredictionRelative.key input))
  change 0 ≤ stateSize*keySize at productNonnegative
  change |real (FlushToZero.mul difference (input 386))-ideal input| ≤
    51*(2 : ℝ)^(-24 : Int)*stateSize*keySize+3*(2 : ℝ)^(-24 : Int)*|real (input 384)|+(2 : ℝ)^(-47 : Int)
  norm_num [FlushToZero.threshold] at total diffBound predBound ⊢
  nlinarith only [total, diffBound, predBound, productNonnegative, abs_nonneg (real (input 384))]

end Inference.Kernels.Delta.GatedDeltaRelative
