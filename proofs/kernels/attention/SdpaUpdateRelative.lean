import kernels.attention.SdpaUpdate
import contracts.mlx.TwoProductsRelative
import contracts.mlx.NonnegativeArithmetic

namespace Inference.Kernels.Attention.SdpaUpdateRelative
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate Arithmetic

theorem denominator_error (p : Platform) (input : Nat → Float32)
    (hf : Arithmetic.Finite input (denominatorExpr p))
    (bound : |real (input 0)|+|real (input 2)| ≤ (2 : ℝ)^(62 : Nat)+2)
    (hd : 0 ≤ real (input 0)) (ha : 0 ≤ real (input 2)) (hb : 0 ≤ real (input 3)) :
    |real (evaluate input (denominatorExpr p))-(real (input 0)*real (input 2)+real (input 3))| ≤
      3*(2 : ℝ)^(-24 : Int)*(real (input 0)*real (input 2)+real (input 3))+(2 : ℝ)^(-60 : Int) := by
  cases h : p.sumContracted with
  | false =>
    have e := TwoProductsRelative.product_add input (.input 0) (.input 2) (.input 3)
      (by simpa only [denominatorExpr, h, Bool.false_eq_true, ite_false] using hf) bound
    simpa only [denominatorExpr, h, Bool.false_eq_true, ite_false, evaluate,
      abs_of_nonneg hd, abs_of_nonneg ha, abs_of_nonneg hb] using e
  | true =>
    have e := ArithmeticMaddRelative.error_sum input true (.input 0) (.input 2) (.input 3)
      (by simpa only [denominatorExpr, h, ite_true, ArithmeticFold.madd] using hf) bound
    simpa only [denominatorExpr, h, ite_true, ArithmeticFold.madd, evaluate,
      abs_of_nonneg hd, abs_of_nonneg ha, abs_of_nonneg hb] using e

theorem numerator_error (p : Platform) (input : Nat → Float32)
    (hf : Arithmetic.Finite input (numeratorExpr p))
    (firstBound : |real (input 1)|+|real (input 2)| ≤ (2 : ℝ)^(62 : Nat)+2)
    (secondBound : |real (input 3)|+|real (input 4)| ≤ (2 : ℝ)^(62 : Nat)+2) :
    |real (evaluate input (numeratorExpr p))-(real (input 1)*real (input 2)+real (input 3)*real (input 4))| ≤
      8*(2 : ℝ)^(-24 : Int)*(|real (input 1)| * |real (input 2)|+|real (input 3)| * |real (input 4)|)+
        (2 : ℝ)^(-58 : Int) := by
  cases h : p.numeratorContracted with
  | separate =>
    have e := TwoProductsRelative.error input false (.input 3) (.input 4) (.input 1) (.input 2)
      (by simpa only [numeratorExpr, h, ArithmeticFold.madd, Bool.false_eq_true, ite_false] using hf) secondBound firstBound
    simpa only [numeratorExpr, h, ArithmeticFold.madd, Bool.false_eq_true, ite_false, evaluate, add_comm] using e
  | first =>
    have e := TwoProductsRelative.error input true (.input 1) (.input 2) (.input 3) (.input 4)
      (by simpa only [numeratorExpr, h, ArithmeticFold.madd, ite_true] using hf) firstBound secondBound
    simpa only [numeratorExpr, h, ArithmeticFold.madd, ite_true, evaluate] using e
  | second =>
    have e := TwoProductsRelative.error input true (.input 3) (.input 4) (.input 1) (.input 2)
      (by simpa only [numeratorExpr, h, ArithmeticFold.madd, ite_true] using hf) secondBound firstBound
    simpa only [numeratorExpr, h, ArithmeticFold.madd, ite_true, evaluate, add_comm] using e

theorem denominator_lower (p : Platform) (input : Nat → Float32)
    (hf : Arithmetic.Finite input (denominatorExpr p))
    (hd : 1 ≤ real (input 0)) (ha : 0 ≤ real (input 2)) (hb : 0 ≤ real (input 3))
    (unit : real (input 2) = 1 ∨ real (input 3) = 1) :
    1 ≤ real (evaluate input (denominatorExpr p)) := by
  apply NonnegativeArithmetic.lower_one input _ ?_ hf
  cases h : p.sumContracted <;> simp only [denominatorExpr, h, Bool.false_eq_true, ite_false, ite_true]
  · rcases unit with h | h
    · exact .addLeft (.mulRightOne (.input 0 hd) h) (.input 3 hb)
    · exact .addRight (.mul (.input 0 (by linarith only [hd])) (.input 2 ha)) (.input 3 h.ge)
  · rcases unit with h | h
    · exact .fmaProduct (.input 0 hd) h (.input 3 hb)
    · exact .fmaAddend (.input 0 (by linarith only [hd])) (.input 2 ha) (.input 3 h.ge)

-- A rounding-aware convexity invariant. The numerator is compared with
-- the computed denominator; this avoids a bound growing with key count.
theorem ratio_growth (den num nextDen nextNum alpha beta value cap : ℝ)
    (hd : 1 ≤ den) (hc : 1 ≤ cap) (hn : |num| ≤ cap*den) (hv : |value| ≤ cap)
    (ha : 0 ≤ alpha) (hb : 0 ≤ beta) (unit : alpha = 1 ∨ beta = 1)
    (denError : |nextDen-(den*alpha+beta)| ≤ 3*(2 : ℝ)^(-24 : Int)*(den*alpha+beta)+(2 : ℝ)^(-60 : Int))
    (numError : |nextNum-(num*alpha+beta*value)| ≤
      8*(2 : ℝ)^(-24 : Int)*(|num| * alpha+beta*|value|)+(2 : ℝ)^(-58 : Int)) :
    |nextNum| ≤ (1+(2 : ℝ)^(-19 : Int))*cap*nextDen := by
  have cp : 0 ≤ cap := by linarith only [hc]
  have idealLower : 1 ≤ den*alpha+beta := by
    rcases unit with h | h
    · rw [h, mul_one]; linarith only [hd, hb]
    · rw [h]; have := mul_nonneg (by linarith only [hd] : 0 ≤ den) ha; linarith
  have mass : |num| * alpha+beta*|value| ≤ cap*(den*alpha+beta) := by
    have n := mul_le_mul_of_nonneg_right hn ha
    have v := mul_le_mul_of_nonneg_left hv hb
    nlinarith only [n, v]
  have ideal : |num*alpha+beta*value| ≤ |num| * alpha+beta*|value| := by
    simpa only [abs_mul, abs_of_nonneg ha, abs_of_nonneg hb] using abs_add_le (num*alpha) (beta*value)
  have absolute := NormalizedCastBounds.absolute_of_error _ _ _ numError
  have denLower := (abs_le.mp denError).1
  have scaled := mul_le_mul_of_nonneg_left denLower
    (by positivity : 0 ≤ (1+(2 : ℝ)^(-19 : Int))*cap)
  have slack := mul_le_mul_of_nonneg_left idealLower cp
  norm_num at absolute denLower scaled ⊢
  nlinarith only [absolute, ideal, mass, scaled, slack, hc]

end Inference.Kernels.Attention.SdpaUpdateRelative
