import kernels.quantization.AffineInput
import contracts.mlx.RelativeRounding
import contracts.mlx.NormalizedCastBounds
import contracts.mlx.AdditionMagnitude

namespace Inference.Kernels.Quantization.AffineSumMagnitude
open Contracts.Mlx Contracts.Mlx.Numerics AffineInput
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

def additions : SumExpr n → Nat
  | .input _ => 0
  | .add a b => additions a+additions b+1

theorem ideal_nonnegative (x : Fin n → BF) (expr : SumExpr n) :
    0 ≤ ideal (fun i => |Model.toReal (x i)|) expr := by
  induction expr with
  | input i => exact abs_nonneg _
  | add a b ia ib => exact add_nonneg ia ib

theorem addition (a b : BF) (ha : Model.isFinite a = true) (hb : Model.isFinite b = true)
    (hf : Model.isFinite (Model.add (BFloat16Arithmetic.flush a) (BFloat16Arithmetic.flush b)) = true) :
    |Model.toReal (BFloat16Arithmetic.add a b)| ≤
      (257/256 : ℝ)*(|Model.toReal a|+|Model.toReal b|)+(2 : ℝ)^(-123 : Int) := by
  have he := NormalizedCastBounds.absolute_of_error _ _ _ (BFloat16Arithmetic.add_error a b ha hb hf)
  have hr := RelativeRounding.bfloat16_epsilon
    (Model.toReal (BFloat16Arithmetic.flush a)+Model.toReal (BFloat16Arithmetic.flush b))
  have hm := (abs_add_le _ _).trans
    (add_le_add (BFloat16Arithmetic.flush_abs_le a) (BFloat16Arithmetic.flush_abs_le b))
  have hs := mul_le_mul_of_nonneg_left hm (by positivity : (0 : ℝ) ≤ 2^(-8 : Int))
  unfold BFloat16Arithmetic.addBudget at he
  norm_num [FlushToZero.threshold, BFloat16Arithmetic.epsilon, BFloat16.epsilon] at he hr hs ⊢
  linarith only [he, hr, hs, abs_add_le (Model.toReal a) (Model.toReal b)]

theorem combine (a b ea eb out ca cb : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hca : 0 ≤ ca) (hcb : 0 ≤ cb) (count : ca+cb ≤ 6)
    (left : ea ≤ (1+ca/128)*a+ca*(2 : ℝ)^(-120 : Int))
    (right : eb ≤ (1+cb/128)*b+cb*(2 : ℝ)^(-120 : Int))
    (rounded : out ≤ (257/256 : ℝ)*(ea+eb)+(2 : ℝ)^(-123 : Int)) :
    out ≤ (1+(ca+cb+1)/128)*(a+b)+(ca+cb+1)*(2 : ℝ)^(-120 : Int) := by
  have caBound : ca ≤ 6 := by linarith only [count, hcb]
  have cbBound : cb ≤ 6 := by linarith only [count, hca]
  have aa := mul_le_mul_of_nonneg_right caBound ha
  have bb := mul_le_mul_of_nonneg_right cbBound hb
  have ab := mul_nonneg hca hb
  have ba := mul_nonneg hcb ha
  norm_num at left right rounded ⊢
  nlinarith only [left, right, rounded, aa, bb, ab, ba, ha, hb, count]

-- load_vector forms left-associated groups of four or eight BF16 inputs.
-- Their seven or fewer rounding sites retain a small multiplier on L1 mass.
theorem expression (x : Fin n → BF) (expr : SumExpr n) (hf : AffineInput.Finite x expr)
    (size : additions expr ≤ 7) :
    |Model.toReal (evaluate x expr)| ≤
      (1+(additions expr : ℝ)/128)*ideal (fun i => |Model.toReal (x i)|) expr+
        (additions expr : ℝ)*(2 : ℝ)^(-120 : Int) := by
  induction expr with
  | input i => simp [evaluate, ideal, additions]
  | add a b ia ib =>
    have count : (additions a : ℝ)+(additions b : ℝ) ≤ 6 := by
      have h : additions a+additions b ≤ 6 := by change additions a+additions b+1 ≤ 7 at size; omega
      exact_mod_cast h
    have h := combine _ _ _ _ _ (additions a) (additions b)
      (ideal_nonnegative x a) (ideal_nonnegative x b) (by positivity) (by positivity) count
      (ia hf.1 (by change additions a+additions b+1 ≤ 7 at size; omega))
      (ib hf.2.1 (by change additions a+additions b+1 ≤ 7 at size; omega))
      (addition _ _ (evaluate_finite x a hf.1) (evaluate_finite x b hf.2.1) hf.2.2)
    simpa only [evaluate, ideal, additions, Nat.cast_add, Nat.cast_one] using h

theorem group8 (x : Fin n → BF) (index : Fin 8 → Fin n)
    (hf : AffineInput.Finite x (AffineInput.group8 (fun i => .input (index i)))) :
    |Model.toReal (evaluate x (AffineInput.group8 (fun i => .input (index i))))| ≤
      (17/16 : ℝ)*(∑ i, |Model.toReal (x (index i))|)+7*(2 : ℝ)^(-120 : Int) := by
  have h := expression x (AffineInput.group8 (fun i => .input (index i))) hf (by simp [AffineInput.group8, additions])
  have hn : 0 ≤ ∑ i, |Model.toReal (x (index i))| := Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  rw [show additions (AffineInput.group8 (fun i => .input (index i))) = 7 from rfl, ideal_group8] at h
  simp only [ideal, Nat.cast_ofNat] at h
  linarith only [h, hn]

theorem group4 (x : Fin n → BF) (index : Fin 4 → Fin n)
    (hf : AffineInput.Finite x (AffineInput.group4 (fun i => .input (index i)))) :
    |Model.toReal (evaluate x (AffineInput.group4 (fun i => .input (index i))))| ≤
      (17/16 : ℝ)*(∑ i, |Model.toReal (x (index i))|)+3*(2 : ℝ)^(-120 : Int) := by
  have h := expression x (AffineInput.group4 (fun i => .input (index i))) hf (by simp [AffineInput.group4, additions])
  have hn : 0 ≤ ∑ i, |Model.toReal (x (index i))| := Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  rw [show additions (AffineInput.group4 (fun i => .input (index i))) = 3 from rfl, ideal_group4] at h
  simp only [ideal, Nat.cast_ofNat] at h
  linarith only [h, hn]

theorem bounded_expression (x : Fin n → BF) (expr : SumExpr n) (hf : AffineInput.Finite x expr)
    (size : additions expr ≤ 7) :
    |Model.toReal (evaluate x expr)| ≤
      (17/16 : ℝ)*ideal (fun i => |Model.toReal (x i)|) expr+7*(2 : ℝ)^(-120 : Int) := by
  have h := expression x expr hf size
  have count : (additions expr : ℝ) ≤ 7 := by exact_mod_cast size
  have mass := ideal_nonnegative x expr
  have scaled := mul_le_mul_of_nonneg_right count mass
  norm_num at h ⊢
  nlinarith only [h, count, scaled, mass]

theorem float_sum (values : Fin groups → Float32) (size : groups ≤ 32)
    (hf : Arithmetic.Finite (bind values) (sumExpression groups)) :
    |real (sumGroups values)| ≤ (17/16 : ℝ)*(∑ i, |real (values i)|)+(2 : ℝ)^(-100 : Int) := by
  have only : AdditionMagnitude.Only (sumExpression groups) :=
    AdditionMagnitude.fold_only (fun i : Fin groups => .input i.val) (fun _ => True.intro)
      (List.finRange groups) .zero True.intro
  have sites : AdditionMagnitude.sites (sumExpression groups) = groups := by
    simpa only [sumExpression, AdditionMagnitude.sites, List.length_finRange, Nat.zero_add] using
      AdditionMagnitude.fold_sites (fun i : Fin groups => .input i.val) (fun _ => rfl) (List.finRange groups) .zero
  have h := AdditionMagnitude.expression (bind values) (sumExpression groups) only hf (by rw [sites]; omega)
  have massEq : (fun i => |real (bind values i)|) = bindReal (fun i => |real (values i)|) := by
    funext i
    unfold AffineInput.bind bindReal
    split
    · rfl
    · simp [FlushedIdentities.zero_real]
  rw [sites, massEq, sum_execution, sum_ideal] at h
  have count : (groups : ℝ) ≤ 32 := by exact_mod_cast size
  have mass : 0 ≤ ∑ i, |real (values i)| := Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  have scaled := mul_le_mul_of_nonneg_right count mass
  norm_num at h ⊢
  nlinarith only [h, count, mass, scaled]

theorem grouped (x : Fin n → BF) (group : Fin groups → SumExpr n) (size : groups ≤ 4)
    (counts : ∀ i, additions (group i) ≤ 7)
    (coverage : (∑ i, ideal (fun j => |Model.toReal (x j)|) (group i)) = ∑ j, |Model.toReal (x j)|)
    (hg : ∀ i, AffineInput.Finite x (group i))
    (hf : Arithmetic.Finite (bind (fun i => BFloat16.widen (evaluate x (group i)))) (sumExpression groups)) :
    |real (summed x group)| ≤ 2*(∑ i, |Model.toReal (x i)|)+(2 : ℝ)^(-99 : Int) := by
  have leaf (i : Fin groups) : |real (BFloat16.widen (evaluate x (group i)))| ≤
      (17/16 : ℝ)*ideal (fun j => |Model.toReal (x j)|) (group i)+7*(2 : ℝ)^(-120 : Int) := by
    rw [BFloat16.widen_real _ (evaluate_finite x (group i) (hg i))]
    exact bounded_expression x (group i) (hg i) (counts i)
  have sumBound := Finset.sum_le_sum (s := Finset.univ) (fun i _ => leaf i)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, coverage] at sumBound
  have h := float_sum (fun i => BFloat16.widen (evaluate x (group i))) (by omega) hf
  have count : (groups : ℝ) ≤ 4 := by exact_mod_cast size
  have mass : 0 ≤ ∑ i, |Model.toReal (x i)| := Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  change |real (sumGroups _)| ≤ _
  norm_num at h sumBound ⊢
  linarith only [h, sumBound, count, mass]

theorem sum3 (x : Fin 16 → BF) (hg : ∀ i, AffineInput.Finite x (groups3 i))
    (hf : Arithmetic.Finite (bind (fun i => BFloat16.widen (evaluate x (groups3 i)))) (sumExpression 2)) :
    |real (summed x groups3)| ≤ 2*(∑ i, |Model.toReal (x i)|)+(2 : ℝ)^(-99 : Int) := by
  apply grouped x groups3 (by decide) _ (groups3_coverage _) hg hf
  intro i
  simp [groups3, AffineInput.group8, additions]

theorem sum4 (x : Fin 16 → BF) (hg : ∀ i, AffineInput.Finite x (groups4 i))
    (hf : Arithmetic.Finite (bind (fun i => BFloat16.widen (evaluate x (groups4 i)))) (sumExpression 4)) :
    |real (summed x groups4)| ≤ 2*(∑ i, |Model.toReal (x i)|)+(2 : ℝ)^(-99 : Int) := by
  apply grouped x groups4 (by decide) _ (groups4_coverage _) hg hf
  intro i
  simp [groups4, AffineInput.group4, additions]

end Inference.Kernels.Quantization.AffineSumMagnitude
