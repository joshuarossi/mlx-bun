import contracts.mlx.ArithmeticMaddRelative

namespace Inference.Contracts.Mlx.TwoProductsRelative
open Numerics Arithmetic

-- The products retain their scale factors in the relative error term.
-- Dropping those factors would lose the online-softmax rescaling invariant.
theorem error (input : Nat → Float32) (contracted : Bool) (a b c d : Expr)
    (hf : Finite input (ArithmeticFold.madd contracted a b (.mul c d)))
    (firstBound : |real (evaluate input a)|+|real (evaluate input b)| ≤ (2 : ℝ)^(62 : Nat)+2)
    (secondBound : |real (evaluate input c)|+|real (evaluate input d)| ≤ (2 : ℝ)^(62 : Nat)+2) :
    |real (evaluate input (ArithmeticFold.madd contracted a b (.mul c d)))-
      (real (evaluate input a)*real (evaluate input b)+real (evaluate input c)*real (evaluate input d))| ≤
        8*(2 : ℝ)^(-24 : Int)*
          (|real (evaluate input a)| * |real (evaluate input b)|+
            |real (evaluate input c)| * |real (evaluate input d)|)+(2 : ℝ)^(-58 : Int) := by
  have productFinite : Finite input (.mul c d) := by
    cases contracted with
    | false => exact hf.1
    | true => exact hf.2.2.1
  have multiply := RelativeRounding.multiplication (evaluate input c) (evaluate input d) productFinite.2.2
  have tail := ArithmeticMaddRelative.product_tail_sum (evaluate input c) (evaluate input d) secondBound
  have small : (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*
      (1+|real (evaluate input c)|+|real (evaluate input d)|) ≤ (2 : ℝ)^(-63 : Int) := by
    linarith only [tail, FlushToZero.threshold_pos]
  have multiplication : |real (evaluate input (.mul c d))-
      real (evaluate input c)*real (evaluate input d)| ≤
        (2 : ℝ)^(-24 : Int)*(|real (evaluate input c)| * |real (evaluate input d)|)+(2 : ℝ)^(-63 : Int) := by
    change |real (FlushToZero.mul (evaluate input c) (evaluate input d))-
      real (evaluate input c)*real (evaluate input d)| ≤ _
    linarith only [multiply, small]
  have productBound := NormalizedCastBounds.absolute_of_error _ _ _ multiplication
  rw [abs_mul] at productBound
  have add := ArithmeticMaddRelative.error_sum input contracted a b (.mul c d) hf firstBound
  have triangle := abs_sub_le (real (evaluate input (ArithmeticFold.madd contracted a b (.mul c d))))
    (real (evaluate input a)*real (evaluate input b)+real (evaluate input (.mul c d)))
    (real (evaluate input a)*real (evaluate input b)+real (evaluate input c)*real (evaluate input d))
  rw [add_sub_add_left_eq_sub] at triangle
  have total := triangle.trans (add_le_add add multiplication)
  have firstNonnegative := mul_nonneg (abs_nonneg (real (evaluate input a))) (abs_nonneg (real (evaluate input b)))
  have secondNonnegative := mul_nonneg (abs_nonneg (real (evaluate input c))) (abs_nonneg (real (evaluate input d)))
  norm_num at productBound total ⊢
  linarith only [total, productBound, firstNonnegative, secondNonnegative]

theorem product_add (input : Nat → Float32) (a b acc : Expr)
    (hf : Finite input (.add (.mul a b) acc))
    (bound : |real (evaluate input a)|+|real (evaluate input b)| ≤ (2 : ℝ)^(62 : Nat)+2) :
    |real (evaluate input (.add (.mul a b) acc))-
      (real (evaluate input a)*real (evaluate input b)+real (evaluate input acc))| ≤
      3*(2 : ℝ)^(-24 : Int)*
        (|real (evaluate input a)| * |real (evaluate input b)|+|real (evaluate input acc)|)+(2 : ℝ)^(-60 : Int) := by
  let x := evaluate input a
  let y := evaluate input b
  let z := evaluate input acc
  have tail := ArithmeticMaddRelative.product_tail_sum x y bound
  have small : (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*(1+|real x|+|real y|) ≤ (2 : ℝ)^(-63 : Int) := by
    linarith only [tail, FlushToZero.threshold_pos]
  have multiply := RelativeRounding.multiplication x y hf.1.2.2
  have product := NormalizedCastBounds.absolute_of_error _ _ _ multiply
  rw [abs_mul] at product
  have add := RelativeRounding.addition (FlushToZero.mul x y) z
    (FlushToZero.mul_finite _ _ hf.1.2.2) (finite_evaluate _ _ hf.2.1) hf.2.2
  have triangle := abs_sub_le (real (FlushToZero.add (FlushToZero.mul x y) z))
    (real (FlushToZero.mul x y)+real z) (real x*real y+real z)
  rw [add_sub_add_right_eq_sub] at triangle
  have total := triangle.trans (add_le_add add multiply)
  have pn := mul_nonneg (abs_nonneg (real x)) (abs_nonneg (real y))
  have zn := abs_nonneg (real z)
  change |real (FlushToZero.add (FlushToZero.mul x y) z)-(real x*real y+real z)| ≤ _
  change _ ≤ 3*(2 : ℝ)^(-24 : Int)*(|real x| * |real y|+|real z|)+(2 : ℝ)^(-60 : Int)
  norm_num [FlushToZero.threshold] at total product small ⊢
  linarith only [total, product, small, pn, zn]

end Inference.Contracts.Mlx.TwoProductsRelative
