import contracts.mlx.WeightedFold
import contracts.mlx.ArithmeticFoldBounds
import contracts.mlx.AdditionFoldBounds
import contracts.mlx.FlushedReductionRelative
import contracts.mlx.ArithmeticDependencies
import kernels.attention.SdpaLayout

namespace Inference.Kernels.Attention.SdpaTwoPassReduction
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic
open scoped BigOperators

-- Second-pass sum: ordered products within each lane, followed by SIMD
-- reduction. The host block-count proof supplies divisibility by 32, so
-- these strided lists have exactly blocks/32 entries, including every block.
def lane (contracted : Bool) (a b : Fin blocks → Expr) (thread : Fin 32) : Expr :=
  WeightedFold.ordered contracted a b (SdpaLayout.keys blocks thread)
def expression (contracted : Bool) (a b : Fin blocks → Expr) (tree : Reduction.Tree 32) : Expr :=
  ArithmeticFold.reduceExpr (lane contracted a b) tree

theorem lane_length (blocks : Nat) (supported : blocks ≤ 1024) (thread : Fin 32) :
    (SdpaLayout.keys blocks thread).length ≤ 32 := by
  unfold SdpaLayout.keys
  rw [List.length_ofFn]
  unfold SdpaLayout.count
  omega

theorem partition_sum (f : Fin blocks → ℝ) :
    (∑ thread : Fin 32, ((SdpaLayout.keys blocks thread).map f).sum) = ∑ i, f i := by
  have flatten (groups : List (Fin 32)) :
      ((groups.flatMap (SdpaLayout.keys blocks)).map f).sum =
        (groups.map (fun g => ((SdpaLayout.keys blocks g).map f).sum)).sum := by
    induction groups with
    | nil => rfl
    | cons g rest ih => simp only [List.flatMap_cons, List.map_append, List.sum_append, List.map_cons, List.sum_cons, ih]
  have h := ((SdpaLayout.coverage blocks).map f).sum_eq
  rw [SdpaLayout.allKeys, flatten] at h
  simpa only [← Fin.sum_univ_def] using h

theorem ranges (input : Nat → Float32) (contracted : Bool) (a b : Fin blocks → Expr)
    (exponent : Int) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (ha : ∀ i, Arithmetic.Finite input (a i) ∧ |real (evaluate input (a i))| ≤ 1)
    (hb : ∀ i, Arithmetic.Finite input (b i) ∧ |real (evaluate input (b i))| ≤ (2 : ℝ)^exponent)
    (supported : blocks ≤ 1024) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) :
    Arithmetic.Finite input (expression contracted a b tree) ∧
      |real (evaluate input (expression contracted a b tree))| ≤ 1024*(2 : ℝ)^exponent := by
  have lanes thread := ArithmeticFoldBounds.from_zero input contracted a b 0 exponent (by simpa only [zero_add] using lo) (by simpa only [zero_add] using hi)
    (by simpa only [zpow_zero] using ha) hb
    (SdpaLayout.keys blocks thread) (by have := lane_length blocks supported thread; omega)
  have bounded (thread : Fin 32) : Arithmetic.Finite input (lane contracted a b thread) ∧
      |real (evaluate input (lane contracted a b thread))| ≤ (32 : ℝ)*(2 : ℝ)^exponent := by
    refine ⟨(lanes thread).1, ?_⟩
    have length : (((SdpaLayout.keys blocks thread).length : Nat) : ℝ) ≤ 32 := by
      exact_mod_cast lane_length blocks supported thread
    exact (lanes thread).2.trans (by simpa only [zero_add] using mul_le_mul_of_nonneg_right length (by positivity : (0 : ℝ) ≤ 2^exponent))
  have count : (Reduction.leaves tree).length = 32 := by simpa only [List.length_finRange] using coverage.length_eq
  have result := AdditionFoldBounds.reduce_range input (lane contracted a b) exponent 32 lo hi
    bounded tree (by rw [count]; decide)
  exact ⟨result.1, by simpa only [count, expression, show (32 : Nat)*32 = 1024 from rfl, Nat.cast_ofNat] using result.2⟩

theorem error (input : Nat → Float32) (contracted : Bool) (a b : Fin blocks → Expr)
    (bound : ∀ i, |real (evaluate input (a i))|+|real (evaluate input (b i))| ≤ (2 : ℝ)^(62 : Nat)+2)
    (supported : blocks ≤ 1024) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32))
    (hf : Arithmetic.Finite input (expression contracted a b tree)) :
    |real (evaluate input (expression contracted a b tree))-(∑ i, WeightedFold.term input a b i)| ≤
      (2 : ℝ)^(-16 : Int)*(∑ i, |WeightedFold.term input a b i|)+(2 : ℝ)^(-22 : Int) := by
  let actual := fun thread => evaluate input (lane contracted a b thread)
  let target := fun thread => ((SdpaLayout.keys blocks thread).map (WeightedFold.term input a b)).sum
  let masses := fun thread => WeightedFold.mass input a b (SdpaLayout.keys blocks thread)
  have laneFinite thread : Arithmetic.Finite input (lane contracted a b thread) :=
    ArithmeticDependencies.reduce_finite input _ tree hf thread (coverage.mem_iff.mpr (List.mem_finRange thread))
  have lanes thread : |real (actual thread)-target thread| ≤
      (2 : ℝ)^(-17 : Int)*masses thread+(2 : ℝ)^(-28 : Int) :=
    WeightedFold.ordered_error input contracted a b bound _ (lane_length blocks supported thread) (laneFinite thread)
  have massSum : (∑ thread : Fin 32, masses thread) = ∑ i, |WeightedFold.term input a b i| := partition_sum _
  have targetSum : (∑ thread : Fin 32, target thread) = ∑ i, WeightedFold.term input a b i := partition_sum _
  have magnitudes thread : |real (actual thread)| ≤
      (1+(2 : ℝ)^(-17 : Int))*masses thread+(2 : ℝ)^(-28 : Int) := by
    have h := NormalizedCastBounds.absolute_of_error _ _ _ (lanes thread)
    have ht := WeightedFold.sum_bound input a b (SdpaLayout.keys blocks thread)
    change |target thread| ≤ masses thread at ht
    linarith only [h, ht]
  have magnitudeSum := Finset.sum_le_sum (s := Finset.univ) (fun thread _ => magnitudes thread)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul, massSum] at magnitudeSum
  have errors : |(∑ thread : Fin 32, real (actual thread))-(∑ thread : Fin 32, target thread)| ≤
      (2 : ℝ)^(-17 : Int)*(∑ i, |WeightedFold.term input a b i|)+32*(2 : ℝ)^(-28 : Int) := by
    have h := (Finset.abs_sum_le_sum_abs (fun thread => real (actual thread)-target thread) Finset.univ).trans
      (Finset.sum_le_sum (fun thread _ => lanes thread))
    simpa only [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, Nat.cast_ofNat, massSum] using h
  have reduction := FlushedReductionRelative.covered_error actual tree coverage
    (FlushedReductionRelative.from_expression input _ tree hf)
  have total := (abs_sub_le (real (FlushedReduction.evaluate actual tree))
    (∑ thread : Fin 32, real (actual thread)) (∑ thread : Fin 32, target thread)).trans (add_le_add reduction errors)
  rw [targetSum] at total
  have nonnegative : 0 ≤ ∑ i, |WeightedFold.term input a b i| := Finset.sum_nonneg (fun i _ => abs_nonneg _)
  rw [expression, ArithmeticFold.evaluate_reduce]
  change |real (FlushedReduction.evaluate actual tree)-_| ≤ _
  norm_num at total magnitudeSum ⊢
  linarith only [total, magnitudeSum, nonnegative]

end Inference.Kernels.Attention.SdpaTwoPassReduction
