import contracts.mlx.Arithmetic
import contracts.mlx.RelativeRounding
import contracts.mlx.NormalizedCastBounds
import contracts.mlx.FlushedIdentities

namespace Inference.Contracts.Mlx.AdditionMagnitude
open Numerics Arithmetic

def Only : Expr → Prop
  | .input _ | .zero => True
  | .add a b => Only a ∧ Only b
  | _ => False

def sites : Expr → Nat
  | .add a b => sites a+sites b+1
  | _ => 0

theorem mass_nonnegative (input : Nat → Float32) (expr : Expr) (only : Only expr) :
    0 ≤ ideal (fun i => |real (input i)|) expr := by
  induction expr with
  | input i => exact abs_nonneg _
  | zero => exact le_rfl
  | add a b ia ib => exact add_nonneg (ia only.1) (ib only.2)
  | sub | mul | fma => exact False.elim only

theorem addition (a b : Float32) (ha : a.isFinite = true) (hb : b.isFinite = true)
    (hf : (FlushToZero.flush a+FlushToZero.flush b).isFinite = true) :
    |real (FlushToZero.add a b)| ≤
      (1+(2 : ℝ)^(-24 : Int))*(|real a|+|real b|)+(2 : ℝ)^(-123 : Int) := by
  have h := NormalizedCastBounds.absolute_of_error _ _ _ (RelativeRounding.addition a b ha hb hf)
  norm_num [FlushToZero.threshold] at h ⊢
  linarith only [h, abs_add_le (real a) (real b)]

theorem combine (a b ea eb out ca cb : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hca : 0 ≤ ca) (hcb : 0 ≤ cb) (count : ca+cb ≤ 1048575)
    (left : ea ≤ (1+ca/1048576)*a+ca*(2 : ℝ)^(-110 : Int))
    (right : eb ≤ (1+cb/1048576)*b+cb*(2 : ℝ)^(-110 : Int))
    (rounded : out ≤ (1+(2 : ℝ)^(-24 : Int))*(ea+eb)+(2 : ℝ)^(-123 : Int)) :
    out ≤ (1+(ca+cb+1)/1048576)*(a+b)+(ca+cb+1)*(2 : ℝ)^(-110 : Int) := by
  have caBound : ca ≤ 1048576 := by linarith only [count, hcb]
  have cbBound : cb ≤ 1048576 := by linarith only [count, hca]
  have aa := mul_le_mul_of_nonneg_right caBound ha
  have bb := mul_le_mul_of_nonneg_right cbBound hb
  have ab := mul_nonneg hca hb
  have ba := mul_nonneg hcb ha
  norm_num at left right rounded ⊢
  nlinarith only [left, right, rounded, aa, bb, ab, ba, ha, hb, count]

-- A linear error envelope in the number of actual addition sites, with no
-- associativity assumption. Leaves retain their own absolute magnitudes.
theorem expression (input : Nat → Float32) (expr : Expr) (only : Only expr)
    (hf : Arithmetic.Finite input expr) (size : sites expr ≤ 1048576) :
    |real (evaluate input expr)| ≤
      (1+(sites expr : ℝ)/1048576)*ideal (fun i => |real (input i)|) expr+
        (sites expr : ℝ)*(2 : ℝ)^(-110 : Int) := by
  induction expr with
  | input i => simp [evaluate, ideal, sites]
  | zero => simp [evaluate, ideal, sites, FlushedIdentities.zero_real]
  | add a b ia ib =>
    have count : (sites a : ℝ)+(sites b : ℝ) ≤ 1048575 := by
      have h : sites a+sites b ≤ 1048575 := by change sites a+sites b+1 ≤ 1048576 at size; omega
      exact_mod_cast h
    have h := combine _ _ _ _ _ (sites a) (sites b)
      (mass_nonnegative input a only.1) (mass_nonnegative input b only.2) (by positivity) (by positivity) count
      (ia only.1 hf.1 (by change sites a+sites b+1 ≤ 1048576 at size; omega))
      (ib only.2 hf.2.1 (by change sites a+sites b+1 ≤ 1048576 at size; omega))
      (addition _ _ (finite_evaluate input a hf.1) (finite_evaluate input b hf.2.1) hf.2.2)
    simpa only [evaluate, ideal, sites, Nat.cast_add, Nat.cast_one] using h
  | sub | mul | fma => exact False.elim only

theorem fold_only (value : α → Expr) (leaf : ∀ i, Only (value i)) (indices : List α)
    (acc : Expr) (ha : Only acc) : Only (indices.foldl (fun acc i => .add acc (value i)) acc) := by
  induction indices generalizing acc with
  | nil => exact ha
  | cons i rest ih => exact ih (.add acc (value i)) ⟨ha, leaf i⟩

theorem fold_sites (value : α → Expr) (leaf : ∀ i, sites (value i)=0) (indices : List α) (acc : Expr) :
    sites (indices.foldl (fun acc i => .add acc (value i)) acc) = sites acc+indices.length := by
  induction indices generalizing acc with
  | nil => simp
  | cons i rest ih =>
    simp only [List.foldl_cons, ih, sites, leaf i, Nat.add_zero, List.length_cons]
    omega

end Inference.Contracts.Mlx.AdditionMagnitude
