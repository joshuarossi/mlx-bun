import contracts.mlx.FlushedReduction
import contracts.mlx.RelativeRounding
import contracts.mlx.NormalizedCastBounds
import contracts.mlx.ArithmeticFold

namespace Inference.Contracts.Mlx.FlushedReductionRelative
open Numerics
open scoped BigOperators

def height : Reduction.Tree n → Nat
  | .leaf _ => 0
  | .add a b => max (height a) (height b)+1

def Finite (input : Fin n → Float32) : Reduction.Tree n → Prop
  | .leaf i => (input i).isFinite = true
  | .add a b => Finite input a ∧ Finite input b ∧
      (FlushToZero.flush (FlushedReduction.evaluate input a)+FlushToZero.flush (FlushedReduction.evaluate input b)).isFinite = true

theorem finite_evaluate (input : Fin n → Float32) (tree : Reduction.Tree n) (h : Finite input tree) :
    (FlushedReduction.evaluate input tree).isFinite = true := by
  cases tree with
  | leaf i => exact h
  | add a b => exact FlushToZero.finite_flush _ h.2.2

theorem from_expression (input : Nat → Float32) (lanes : Fin n → Arithmetic.Expr) (tree : Reduction.Tree n)
    (h : Arithmetic.Finite input (ArithmeticFold.reduceExpr lanes tree)) :
    Finite (fun i => Arithmetic.evaluate input (lanes i)) tree := by
  induction tree with
  | leaf i => exact Arithmetic.finite_evaluate input (lanes i) h
  | add a b ia ib =>
    refine ⟨ia h.1, ib h.2.1, ?_⟩
    simpa only [ArithmeticFold.evaluate_reduce] using h.2.2

theorem height_lt_leaves (tree : Reduction.Tree n) : height tree < (Reduction.leaves tree).length := by
  induction tree with
  | leaf i => simp [height, Reduction.leaves]
  | add a b ia ib => simp only [height, Reduction.leaves, List.length_append]; omega

noncomputable def mass (input : Fin n → Float32) (tree : Reduction.Tree n) : ℝ :=
  Reduction.ideal (fun i => |real (input i)|) tree
noncomputable def unit : ℝ := (2 : ℝ)^(-24 : Int)
noncomputable def allowance : ℝ := (2 : ℝ)^(-150 : Int)+3*FlushToZero.threshold
noncomputable def factor (depth : Nat) : ℝ := (1+unit)^depth
noncomputable def tail (depth : Nat) : ℝ := ((3 : ℝ)^depth-1)*allowance

theorem unit_nonnegative : 0 ≤ unit := by unfold unit; positivity
theorem unit_upper : unit ≤ 1/2 := by norm_num [unit]
theorem allowance_nonnegative : 0 ≤ allowance := by
  exact add_nonneg (by positivity) (mul_nonneg (by norm_num) FlushToZero.threshold_pos.le)
theorem factor_lower (depth : Nat) : 1 ≤ factor depth := one_le_pow₀ (by have := unit_nonnegative; linarith)
theorem factor_mono (a b : Nat) (h : a ≤ b) : factor a ≤ factor b :=
  pow_le_pow_right₀ (by have := unit_nonnegative; linarith) h
theorem tail_nonnegative (depth : Nat) : 0 ≤ tail depth :=
  mul_nonneg (sub_nonneg.mpr (one_le_pow₀ (by norm_num : (1 : ℝ) ≤ 3))) allowance_nonnegative
theorem tail_mono (a b : Nat) (h : a ≤ b) : tail a ≤ tail b :=
  mul_le_mul_of_nonneg_right (sub_le_sub_right (pow_le_pow_right₀ (by norm_num : (1 : ℝ) ≤ 3) h) 1) allowance_nonnegative

theorem mass_nonnegative (input : Fin n → Float32) (tree : Reduction.Tree n) : 0 ≤ mass input tree := by
  induction tree with
  | leaf i => exact abs_nonneg _
  | add a b ia ib => exact add_nonneg ia ib

theorem ideal_bound (input : Fin n → Float32) (tree : Reduction.Tree n) :
    |Reduction.ideal (fun i => real (input i)) tree| ≤ mass input tree := by
  induction tree with
  | leaf i => exact le_refl _
  | add a b ia ib => exact (abs_add_le _ _).trans (add_le_add ia ib)

theorem error (input : Fin n → Float32) (tree : Reduction.Tree n) (hf : Finite input tree) :
    |real (FlushedReduction.evaluate input tree)-Reduction.ideal (fun i => real (input i)) tree| ≤
      (factor (height tree)-1)*mass input tree+tail (height tree) := by
  induction tree with
  | leaf i => simp [FlushedReduction.evaluate, Reduction.ideal, height, factor, tail]
  | add a b ia ib =>
    let depth := max (height a) (height b)
    have ha := ia hf.1
    have hb := ib hf.2.1
    have qa := factor_mono (height a) depth (Nat.le_max_left _ _)
    have qb := factor_mono (height b) depth (Nat.le_max_right _ _)
    have ta := tail_mono (height a) depth (Nat.le_max_left _ _)
    have tb := tail_mono (height b) depth (Nat.le_max_right _ _)
    have ea : |real (FlushedReduction.evaluate input a)-Reduction.ideal (fun i => real (input i)) a| ≤
        (factor depth-1)*mass input a+tail depth := ha.trans
      (add_le_add (mul_le_mul_of_nonneg_right (sub_le_sub_right qa 1) (mass_nonnegative input a)) ta)
    have eb : |real (FlushedReduction.evaluate input b)-Reduction.ideal (fun i => real (input i)) b| ≤
        (factor depth-1)*mass input b+tail depth := hb.trans
      (add_le_add (mul_le_mul_of_nonneg_right (sub_le_sub_right qb 1) (mass_nonnegative input b)) tb)
    have va := NormalizedCastBounds.absolute_of_error _ _ _ ea
    have vb := NormalizedCastBounds.absolute_of_error _ _ _ eb
    have aa : |real (FlushedReduction.evaluate input a)| ≤ factor depth*mass input a+tail depth := by
      linarith only [va, ideal_bound input a]
    have ab : |real (FlushedReduction.evaluate input b)| ≤ factor depth*mass input b+tail depth := by
      linarith only [vb, ideal_bound input b]
    have rounding := RelativeRounding.addition (FlushedReduction.evaluate input a) (FlushedReduction.evaluate input b)
      (finite_evaluate input a hf.1) (finite_evaluate input b hf.2.1) hf.2.2
    have scaled := mul_le_mul_of_nonneg_left (add_le_add aa ab) unit_nonnegative
    have propagated : |(real (FlushedReduction.evaluate input a)+real (FlushedReduction.evaluate input b))-
        (Reduction.ideal (fun i => real (input i)) a+Reduction.ideal (fun i => real (input i)) b)| ≤
        (factor depth-1)*(mass input a+mass input b)+2*tail depth := by
      have h := (abs_add_le (real (FlushedReduction.evaluate input a)-Reduction.ideal (fun i => real (input i)) a)
        (real (FlushedReduction.evaluate input b)-Reduction.ideal (fun i => real (input i)) b)).trans (add_le_add ea eb)
      calc
        _ = |(real (FlushedReduction.evaluate input a)-Reduction.ideal (fun i => real (input i)) a)+
          (real (FlushedReduction.evaluate input b)-Reduction.ideal (fun i => real (input i)) b)| := by congr 1; ring
        _ ≤ _ := h
        _ = _ := by ring
    have total := (abs_sub_le (real (FlushedReduction.evaluate input (.add a b)))
      (real (FlushedReduction.evaluate input a)+real (FlushedReduction.evaluate input b))
      (Reduction.ideal (fun i => real (input i)) (.add a b))).trans (add_le_add rounding propagated)
    have tailStep : (1+unit)*(2*tail depth)+allowance ≤ tail (depth+1) := by
      have extra := mul_le_mul_of_nonneg_right unit_upper (tail_nonnegative depth)
      unfold tail at extra ⊢
      rw [pow_succ]
      nlinarith only [extra, allowance_nonnegative]
    change _ ≤ (factor (depth+1)-1)*(mass input a+mass input b)+tail (depth+1)
    have factorStep : factor (depth+1) = (1+unit)*factor depth := by unfold factor; rw [pow_succ]; ring
    rw [factorStep]
    change _ ≤ unit*(|real (FlushedReduction.evaluate input a)|+|real (FlushedReduction.evaluate input b)|)+
      (2 : ℝ)^(-150 : Int)+3*FlushToZero.threshold+_ at total
    unfold allowance at tailStep
    nlinarith only [total, scaled, tailStep]

theorem covered_error (input : Fin 32 → Float32) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (hf : Finite input tree) :
    |real (FlushedReduction.evaluate input tree)-(∑ i : Fin 32, real (input i))| ≤
      (2 : ℝ)^(-19 : Int)*(∑ i : Fin 32, |real (input i)|)+(2 : ℝ)^(-74 : Int) := by
  have depth : height tree ≤ 31 := by
    have h := height_lt_leaves tree
    have size : (Reduction.leaves tree).length = 32 := by simpa only [List.length_finRange] using coverage.length_eq
    omega
  have q : factor (height tree)-1 ≤ (2 : ℝ)^(-19 : Int) := by
    have h := factor_mono (height tree) 31 depth
    have upper : factor 31 ≤ 1+(2 : ℝ)^(-19 : Int) := by norm_num [factor, unit]
    linarith only [h, upper]
  have t : tail (height tree) ≤ (2 : ℝ)^(-74 : Int) :=
    (tail_mono (height tree) 31 depth).trans (by norm_num [tail, allowance, FlushToZero.threshold])
  have h := (error input tree hf).trans
    (add_le_add (mul_le_mul_of_nonneg_right q (mass_nonnegative input tree)) t)
  simpa only [mass, Reduction.ideal_complete _ tree coverage, ← Fin.sum_univ_def] using h

theorem simd_error (reduce : (Fin 32 → Float32) → Float32) (hardware : FlushedReduction.SimdContract reduce)
    (input : Fin 32 → Float32) (hf : Finite input hardware.tree) :
    |real (reduce input)-(∑ i : Fin 32, real (input i))| ≤
      (2 : ℝ)^(-19 : Int)*(∑ i : Fin 32, |real (input i)|)+(2 : ℝ)^(-74 : Int) := by
  rw [hardware.execution]
  exact covered_error input hardware.tree hardware.coverage hf

end Inference.Contracts.Mlx.FlushedReductionRelative
