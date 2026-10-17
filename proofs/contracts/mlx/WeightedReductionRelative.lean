import contracts.mlx.FlushedReductionRelative
import contracts.mlx.ArithmeticMaddRelative
import contracts.mlx.ArithmeticDependencies

namespace Inference.Contracts.Mlx.WeightedReductionRelative
open Numerics Arithmetic
open scoped BigOperators

theorem error (input : Nat → Float32) (a b : Fin 32 → Expr) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32))
    (hf : Arithmetic.Finite input (ArithmeticFold.reduceExpr (fun i => .mul (a i) (b i)) tree))
    (bound : ∀ i, |real (evaluate input (a i))|+|real (evaluate input (b i))| ≤ (2 : ℝ)^(62 : Nat)+2) :
    |real (evaluate input (ArithmeticFold.reduceExpr (fun i => .mul (a i) (b i)) tree))-
      (∑ i : Fin 32, real (evaluate input (a i))*real (evaluate input (b i)))| ≤
      34*(2 : ℝ)^(-24 : Int)*(∑ i : Fin 32, |real (evaluate input (a i))| * |real (evaluate input (b i))|)+
        (2 : ℝ)^(-56 : Int) := by
  let actual := fun i : Fin 32 => evaluate input (.mul (a i) (b i))
  let target := fun i : Fin 32 => real (evaluate input (a i))*real (evaluate input (b i))
  let mass := fun i : Fin 32 => |real (evaluate input (a i))| * |real (evaluate input (b i))|
  have leafFinite (i : Fin 32) : Arithmetic.Finite input (.mul (a i) (b i)) :=
    ArithmeticDependencies.reduce_finite input _ tree hf i (coverage.mem_iff.mpr (List.mem_finRange i))
  have leafError (i : Fin 32) : |real (actual i)-target i| ≤ (2 : ℝ)^(-24 : Int)*mass i+(2 : ℝ)^(-63 : Int) := by
    have h := RelativeRounding.multiplication (evaluate input (a i)) (evaluate input (b i)) (leafFinite i).2.2
    have tail := ArithmeticMaddRelative.product_tail_sum (evaluate input (a i)) (evaluate input (b i)) (bound i)
    have small : (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*
        (1+|real (evaluate input (a i))|+|real (evaluate input (b i))|) ≤ (2 : ℝ)^(-63 : Int) := by
      linarith only [tail, FlushToZero.threshold_pos]
    change |real (FlushToZero.mul (evaluate input (a i)) (evaluate input (b i)))-
      real (evaluate input (a i))*real (evaluate input (b i))| ≤ _
    change _ ≤ (2 : ℝ)^(-24 : Int)*(|real (evaluate input (a i))| * |real (evaluate input (b i))|)+(2 : ℝ)^(-63 : Int)
    linarith only [h, small]
  have leafBound (i : Fin 32) : |real (actual i)| ≤ (1+(2 : ℝ)^(-24 : Int))*mass i+(2 : ℝ)^(-63 : Int) := by
    have h := NormalizedCastBounds.absolute_of_error _ _ _ (leafError i)
    have absTarget : |target i| = mass i := abs_mul _ _
    rw [absTarget] at h
    linarith only [h]
  have massSum := Finset.sum_le_sum (s := Finset.univ) (fun i _ => leafBound i)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul, Nat.cast_ofNat] at massSum
  have errors : |(∑ i : Fin 32, real (actual i))-(∑ i : Fin 32, target i)| ≤
      (2 : ℝ)^(-24 : Int)*(∑ i : Fin 32, mass i)+32*(2 : ℝ)^(-63 : Int) := by
    have h := (Finset.abs_sum_le_sum_abs (fun i => real (actual i)-target i) Finset.univ).trans
      (Finset.sum_le_sum (fun i _ => leafError i))
    simpa only [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.mul_sum,
      Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, Nat.cast_ofNat] using h
  have reduction := FlushedReductionRelative.covered_error actual tree coverage
    (FlushedReductionRelative.from_expression input _ tree hf)
  have total := (abs_sub_le (real (FlushedReduction.evaluate actual tree))
    (∑ i : Fin 32, real (actual i)) (∑ i : Fin 32, target i)).trans (add_le_add reduction errors)
  have nonnegative : 0 ≤ ∑ i : Fin 32, mass i := Finset.sum_nonneg
    (fun i _ => mul_nonneg (abs_nonneg _) (abs_nonneg _))
  rw [ArithmeticFold.evaluate_reduce]
  change |real (FlushedReduction.evaluate actual tree)-(∑ i : Fin 32, target i)| ≤
    34*(2 : ℝ)^(-24 : Int)*(∑ i : Fin 32, mass i)+(2 : ℝ)^(-56 : Int)
  norm_num at total massSum ⊢
  linarith only [total, massSum, nonnegative]

end Inference.Contracts.Mlx.WeightedReductionRelative
