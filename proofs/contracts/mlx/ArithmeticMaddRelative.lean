import contracts.mlx.ArithmeticFold
import contracts.mlx.RelativeRounding
import contracts.mlx.NormalizedCastBounds

namespace Inference.Contracts.Mlx.ArithmeticMaddRelative
open Numerics Arithmetic

theorem product_tail_sum (x y : Float32) (bound : |real x|+|real y| ≤ (2 : ℝ)^(62 : Nat)+2) :
    (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*(2+|real x|+|real y|) ≤ (2 : ℝ)^(-63 : Int) := by
  norm_num [FlushToZero.threshold] at bound ⊢
  linarith only [bound]

-- A common allowance covers separate multiply/add and a contracted FMA.
-- The relative term uses the actual operand magnitudes, so a dot-product
-- proof can use Cauchy-Schwarz instead of a coordinate-wise worst case.
theorem error_sum (input : Nat → Float32) (contracted : Bool) (a b acc : Expr)
    (hf : Arithmetic.Finite input (ArithmeticFold.madd contracted a b acc))
    (bound : |real (evaluate input a)|+|real (evaluate input b)| ≤ (2 : ℝ)^(62 : Nat)+2) :
    |real (evaluate input (ArithmeticFold.madd contracted a b acc))-
      (real (evaluate input a)*real (evaluate input b)+real (evaluate input acc))| ≤
      3*(2 : ℝ)^(-24 : Int)*
        (|real (evaluate input a)| * |real (evaluate input b)|+|real (evaluate input acc)|)+(2 : ℝ)^(-60 : Int) := by
  let x := evaluate input a
  let y := evaluate input b
  let z := evaluate input acc
  have pn : 0 ≤ |real x| * |real y| := mul_nonneg (abs_nonneg _) (abs_nonneg _)
  have zn := abs_nonneg (real z)
  have tail := product_tail_sum x y bound
  cases contracted with
  | true =>
    change Arithmetic.Finite input a ∧ Arithmetic.Finite input b ∧ Arithmetic.Finite input acc ∧
      (Float32.fma (FlushToZero.flush x) (FlushToZero.flush y) (FlushToZero.flush z)).isFinite = true at hf
    have h := (FlushToZero.fma_error x y z (finite_evaluate _ _ hf.1) (finite_evaluate _ _ hf.2.1)
      (finite_evaluate _ _ hf.2.2.1) hf.2.2.2).trans (RelativeRounding.fma_budget x y z)
    change |real (FlushToZero.fma x y z)-(real x*real y+real z)| ≤ _
    norm_num at h tail ⊢
    linarith only [h, tail, pn, zn]
  | false =>
    change Arithmetic.Finite input acc ∧ (Arithmetic.Finite input a ∧ Arithmetic.Finite input b ∧
      (FlushToZero.flush x*FlushToZero.flush y).isFinite = true) ∧
        (FlushToZero.flush z+FlushToZero.flush (FlushToZero.mul x y)).isFinite = true at hf
    have hm := RelativeRounding.multiplication x y hf.2.1.2.2
    have small : (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*(1+|real x|+|real y|) ≤ (2 : ℝ)^(-63 : Int) := by
      linarith only [tail, FlushToZero.threshold_pos]
    have product : |real (FlushToZero.mul x y)| ≤
        (1+(2 : ℝ)^(-24 : Int))*(|real x| * |real y|)+(2 : ℝ)^(-63 : Int) := by
      have h := NormalizedCastBounds.absolute_of_error _ _ _ hm
      rw [abs_mul] at h
      linarith only [h, small]
    have hadd := RelativeRounding.addition z (FlushToZero.mul x y) (finite_evaluate _ _ hf.1)
      (FlushToZero.finite_flushExact _ _ hf.2.1.2.2) hf.2.2
    have combine : |real (FlushToZero.add z (FlushToZero.mul x y))-(real x*real y+real z)| ≤
        |real (FlushToZero.add z (FlushToZero.mul x y))-(real z+real (FlushToZero.mul x y))|+
          |real (FlushToZero.mul x y)-real x*real y| := by
      calc
        _ = |(real (FlushToZero.add z (FlushToZero.mul x y))-(real z+real (FlushToZero.mul x y)))+
          (real (FlushToZero.mul x y)-real x*real y)| := by congr 1; ring
        _ ≤ _ := abs_add_le _ _
    have total := combine.trans (add_le_add hadd hm)
    change |real (FlushToZero.add z (FlushToZero.mul x y))-(real x*real y+real z)| ≤ _
    norm_num [FlushToZero.threshold] at total product small ⊢
    linarith only [total, product, small, pn, zn]

theorem error (input : Nat → Float32) (contracted : Bool) (a b acc : Expr)
    (hf : Arithmetic.Finite input (ArithmeticFold.madd contracted a b acc))
    (ha : |real (evaluate input a)| ≤ (2 : ℝ)^(62 : Nat))
    (hb : |real (evaluate input b)| ≤ 2) :
    |real (evaluate input (ArithmeticFold.madd contracted a b acc))-
      (real (evaluate input a)*real (evaluate input b)+real (evaluate input acc))| ≤
      3*(2 : ℝ)^(-24 : Int)*
        (|real (evaluate input a)| * |real (evaluate input b)|+|real (evaluate input acc)|)+(2 : ℝ)^(-60 : Int) :=
  error_sum input contracted a b acc hf (add_le_add ha hb)

end Inference.Contracts.Mlx.ArithmeticMaddRelative
