import kernels.quantization.AffineInputBounds
import contracts.mlx.AdditionFoldBounds

namespace Inference.Kernels.Quantization.AffineSumBounds
open Contracts.Mlx Contracts.Mlx.Numerics AffineInput
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem sum_range (values : Fin groups → Float32) (weight : Nat) (exponent : Int)
    (lo : -149 ≤ exponent) (hi : exponent ≤ 100) (size : groups * weight < 16777216)
    (hv : ∀ i, (values i).isFinite = true ∧ |real (values i)| ≤ (weight : ℝ) * (2 : ℝ)^exponent) :
    Arithmetic.Finite (bind values) (sumExpression groups) ∧
      (sumGroups values).isFinite = true ∧
      |real (sumGroups values)| ≤ ((groups * weight : Nat) : ℝ) * (2 : ℝ)^exponent := by
  have h := AdditionFoldBounds.from_zero (bind values) (fun i : Fin groups => .input i.val)
    exponent weight lo hi
    (fun i => by simpa only [Arithmetic.Finite, Arithmetic.evaluate, bind_read] using hv i)
    (List.finRange groups) (by simpa only [List.length_finRange] using size)
  change Arithmetic.Finite (bind values) (sumExpression groups) ∧ _ at h
  have hf := Arithmetic.finite_evaluate (bind values) (sumExpression groups) h.1
  rw [sum_execution] at hf
  refine ⟨h.1, hf, ?_⟩
  have hb := h.2
  change |real (Arithmetic.evaluate (bind values) (sumExpression groups))| ≤ _ at hb
  simpa only [sum_execution, List.length_finRange] using hb

theorem range4 (x : Fin 16 → BF) (exponent : Int) (lo : -133 ≤ exponent) (hi : exponent ≤ 100)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^exponent) :
    (∀ i, AffineInput.Finite x (groups4 i)) ∧
    Arithmetic.Finite (bind (fun i => BFloat16.widen (evaluate x (groups4 i)))) (sumExpression 4) ∧
    (summed x groups4).isFinite = true ∧ |real (summed x groups4)| ≤ 16 * (2 : ℝ)^exponent := by
  have hg := AffineInputBounds.group4_range x exponent lo (by omega) hx
  have h := sum_range (fun i => BFloat16.widen (evaluate x (groups4 i))) 4 exponent (by omega) hi (by decide)
    (fun i => ⟨BFloat16.widen_finite _ (hg i).2.1, (hg i).2.2⟩)
  exact ⟨fun i => (hg i).1, h.1, h.2.1, by simpa only [summed, show (4 : Nat)*4=16 from rfl, Nat.cast_ofNat] using h.2.2⟩

theorem range3 (x : Fin 16 → BF) (exponent : Int) (lo : -133 ≤ exponent) (hi : exponent ≤ 100)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^exponent) :
    (∀ i, AffineInput.Finite x (groups3 i)) ∧
    Arithmetic.Finite (bind (fun i => BFloat16.widen (evaluate x (groups3 i)))) (sumExpression 2) ∧
    (summed x groups3).isFinite = true ∧ |real (summed x groups3)| ≤ 16 * (2 : ℝ)^exponent := by
  have hg := AffineInputBounds.group3_range x exponent lo (by omega) hx
  have h := sum_range (fun i => BFloat16.widen (evaluate x (groups3 i))) 8 exponent (by omega) hi (by decide)
    (fun i => ⟨BFloat16.widen_finite _ (hg i).2.1, (hg i).2.2⟩)
  exact ⟨fun i => (hg i).1, h.1, h.2.1, by simpa only [summed, show (2 : Nat)*8=16 from rfl, Nat.cast_ofNat] using h.2.2⟩

end Inference.Kernels.Quantization.AffineSumBounds
