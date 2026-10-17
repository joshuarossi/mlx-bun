import contracts.mlx.NativeMultiplication
import contracts.mlx.Negation
import contracts.mlx.RelativeRounding

namespace Inference.Contracts.Mlx.ContractiveMultiplication
open Numerics

-- Multiplication by a finite factor of magnitude at most one cannot enlarge
-- a representable operand, even after nearest rounding and flushing. This
-- avoids charging an unnecessary relative growth factor to state decay.
theorem range (x factor : Float32) (hx : x.isFinite = true) (hf : factor.isFinite = true)
    (bound : |real factor| ≤ 1) :
    (FlushToZero.flush x*FlushToZero.flush factor).isFinite = true ∧
      |real (FlushToZero.mul x factor)| ≤ |real x| := by
  have product : |real x| * |real factor| ≤ |real x| := by
    exact (mul_le_mul_of_nonneg_left bound (abs_nonneg _)).trans_eq (mul_one _)
  by_cases positive : 0 ≤ real x
  · have h := NativeMultiplication.range x factor x hx hf hx (product.trans_eq (abs_of_nonneg positive))
    simpa only [abs_of_nonneg positive] using h
  · have negative : real x ≤ 0 := (lt_of_not_ge positive).le
    have h := NativeMultiplication.range x factor (-x) hx hf (Negation.finite_neg x hx) (by
      rw [Negation.real_neg x hx]
      exact product.trans_eq (abs_of_nonpos negative))
    simpa only [Negation.real_neg x hx, abs_of_nonpos negative] using h

theorem budget (x factor : Float32) (bound : |real factor| ≤ 1) :
    FlushToZero.mulBudget x factor ≤ (2 : ℝ)^(-24 : Int)*|real x|+(2 : ℝ)^(-150 : Int)+
      FlushToZero.threshold*(2+|real x|) := by
  have h := RelativeRounding.multiplication_budget x factor
  have product := mul_le_mul_of_nonneg_left bound (abs_nonneg (real x))
  have scaled := mul_le_mul_of_nonneg_left product (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-24 : Int))
  have tail := mul_le_mul_of_nonneg_left bound FlushToZero.threshold_pos.le
  nlinarith only [h, scaled, tail]

theorem bounded_error (x factor : Float32) (hx : x.isFinite = true) (hf : factor.isFinite = true)
    (bound : |real factor| ≤ 1) (size : |real x| ≤ (2 : ℝ)^(62 : Nat)) :
    |real (FlushToZero.mul x factor)-real x*real factor| ≤
      (2 : ℝ)^(-24 : Int)*|real x|+(2 : ℝ)^(-63 : Int) := by
  have h := (FlushToZero.mul_error x factor (range x factor hx hf bound).1).trans (budget x factor bound)
  have tail : (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*(2+|real x|) ≤ (2 : ℝ)^(-63 : Int) := by
    norm_num [FlushToZero.threshold] at size ⊢
    linarith only [size]
  linarith only [h, tail]

end Inference.Contracts.Mlx.ContractiveMultiplication
