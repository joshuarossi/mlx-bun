import contracts.mlx.ArithmeticMaddRelative
import contracts.mlx.ArithmeticDependencies

namespace Inference.Contracts.Mlx.MaddMagnitude
open Numerics Arithmetic ArithmeticFold

theorem combine (a b ea eb out ca cb : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hca : 0 ≤ ca) (hcb : 0 ≤ cb) (count : ca+cb ≤ 31)
    (left : ea ≤ (1+ca/1048576)*a+ca*(2 : ℝ)^(-50 : Int))
    (right : eb ≤ (1+cb/1048576)*b+cb*(2 : ℝ)^(-50 : Int))
    (rounded : out ≤ (1+3*(2 : ℝ)^(-24 : Int))*(ea+eb)+(2 : ℝ)^(-60 : Int)) :
    out ≤ (1+(ca+cb+1)/1048576)*(a+b)+(ca+cb+1)*(2 : ℝ)^(-50 : Int) := by
  have caBound : ca ≤ 31 := by linarith only [count, hcb]
  have cbBound : cb ≤ 31 := by linarith only [count, hca]
  have aa := mul_le_mul_of_nonneg_right caBound ha
  have bb := mul_le_mul_of_nonneg_right cbBound hb
  have ab := mul_nonneg hca hb
  have ba := mul_nonneg hcb ha
  norm_num at left right rounded ⊢
  nlinarith only [left, right, rounded, aa, bb, ab, ba, ha, hb, count]

theorem madd_bound (input : Nat → Float32) (contracted : Bool) (a b acc : Expr)
    (hf : Arithmetic.Finite input (madd contracted a b acc))
    (operands : |real (evaluate input a)|+|real (evaluate input b)| ≤ (2 : ℝ)^62+2)
    (mass accMass : ℝ) (count : Nat) (size : count < 32) (an : 0 ≤ accMass)
    (product : |real (evaluate input a)| * |real (evaluate input b)| ≤ mass)
    (previous : |real (evaluate input acc)| ≤ (1+(count : ℝ)/1048576)*accMass+(count : ℝ)*(2 : ℝ)^(-50 : Int)) :
    |real (evaluate input (madd contracted a b acc))| ≤
      (1+((count+1 : Nat) : ℝ)/1048576)*(mass+accMass)+((count+1 : Nat) : ℝ)*(2 : ℝ)^(-50 : Int) := by
  have error := ArithmeticMaddRelative.error_sum input contracted a b acc hf operands
  have h := NormalizedCastBounds.absolute_of_error _ _ _ error
  have triangle := abs_add_le (real (evaluate input a)*real (evaluate input b)) (real (evaluate input acc))
  rw [abs_mul] at triangle
  have rounded : |real (evaluate input (madd contracted a b acc))| ≤
      (1+3*(2 : ℝ)^(-24 : Int))*(|real (evaluate input a)| * |real (evaluate input b)|+
        |real (evaluate input acc)|)+(2 : ℝ)^(-60 : Int) := by linarith only [h, triangle]
  have mn : 0 ≤ mass := (mul_nonneg (abs_nonneg _) (abs_nonneg _)).trans product
  have combined := combine mass accMass _ _ _ 0 count mn an (by positivity) (by positivity)
    (by norm_num; exact_mod_cast (by omega : count ≤ 31)) (by simpa using product) previous rounded
  simpa only [zero_add, Nat.cast_add, Nat.cast_one] using combined

-- The final expression proves finiteness of every executed prefix. A static
-- fold retains its source order and the product mass of each actual operand.
theorem fold_bound (input : Nat → Float32) (contracted : Bool) (a b : α → Expr)
    (mass : α → ℝ) (indices : List α) (acc : Expr) (accMass : ℝ) (count : Nat)
    (size : count+indices.length ≤ 32)
    (hf : Arithmetic.Finite input (indices.foldl (fun acc i => madd contracted (a i) (b i) acc) acc))
    (operands : ∀ i, |real (evaluate input (a i))|+|real (evaluate input (b i))| ≤ (2 : ℝ)^62+2)
    (products : ∀ i, |real (evaluate input (a i))| * |real (evaluate input (b i))| ≤ mass i)
    (an : 0 ≤ accMass)
    (previous : |real (evaluate input acc)| ≤ (1+(count : ℝ)/1048576)*accMass+(count : ℝ)*(2 : ℝ)^(-50 : Int)) :
    |real (evaluate input (indices.foldl (fun acc i => madd contracted (a i) (b i) acc) acc))| ≤
      (1+((count+indices.length : Nat) : ℝ)/1048576)*(accMass+(indices.map mass).sum)+
        ((count+indices.length : Nat) : ℝ)*(2 : ℝ)^(-50 : Int) := by
  induction indices generalizing acc accMass count with
  | nil => simpa using previous
  | cons i rest ih =>
    have stepFinite := (ArithmeticDependencies.fold_finite input contracted a b rest (madd contracted (a i) (b i) acc) hf).1
    have hm : 0 ≤ mass i := (mul_nonneg (abs_nonneg _) (abs_nonneg _)).trans (products i)
    have step := madd_bound input contracted (a i) (b i) acc stepFinite (operands i) (mass i) accMass count
      (by simp only [List.length_cons] at size; omega) an (products i) previous
    have h := ih (madd contracted (a i) (b i) acc) (mass i+accMass) (count+1)
      (by simp only [List.length_cons] at size; omega) hf (add_nonneg hm an) step
    simpa only [List.foldl_cons, List.length_cons, List.map_cons, List.sum_cons,
      Nat.add_assoc, Nat.add_comm 1 rest.length, add_assoc, add_comm (mass i) accMass] using h

end Inference.Contracts.Mlx.MaddMagnitude
