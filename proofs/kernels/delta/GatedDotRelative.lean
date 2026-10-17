import kernels.delta.GatedRanges
import contracts.mlx.WeightedFold
import contracts.mlx.FlushedReductionRelative
import contracts.mlx.ArithmeticDependencies
import kernels.delta.RecurrenceStability

namespace Inference.Kernels.Delta.GatedDotRelative
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic
open scoped BigOperators

abbrev chain (contracted : Bool) (a b : Fin 128 → Expr) : List (Fin 128) → Expr :=
  WeightedFold.chain contracted a b

noncomputable def term (input : Nat → Float32) (a b : Fin 128 → Expr) (i : Fin 128) : ℝ :=
  real (evaluate input (a i))*real (evaluate input (b i))
noncomputable def mass (input : Nat → Float32) (a b : Fin 128 → Expr) (indices : List (Fin 128)) : ℝ :=
  (indices.map (fun i => |term input a b i|)).sum
noncomputable def factor (length : Nat) : ℝ := (1+3*(2 : ℝ)^(-24 : Int))^length
noncomputable def tail (length : Nat) : ℝ := ((2 : ℝ)^length-1)*(2 : ℝ)^(-60 : Int)

theorem mass_nonnegative (input : Nat → Float32) (a b : Fin 128 → Expr) (indices : List (Fin 128)) :
    0 ≤ mass input a b indices := by
  induction indices with
  | nil => simp [mass]
  | cons i rest ih =>
    change 0 ≤ |term input a b i|+mass input a b rest
    exact add_nonneg (abs_nonneg _) ih

theorem sum_bound (input : Nat → Float32) (a b : Fin 128 → Expr) (indices : List (Fin 128)) :
    |(indices.map (term input a b)).sum| ≤ mass input a b indices := by
  induction indices with
  | nil => simp [mass]
  | cons i rest ih =>
    exact (abs_add_le _ _).trans (add_le_add (le_refl _) ih)

theorem factor_lower (length : Nat) : 1 ≤ factor length := one_le_pow₀ (by norm_num)
theorem tail_nonnegative (length : Nat) : 0 ≤ tail length :=
  mul_nonneg (sub_nonneg.mpr (one_le_pow₀ (by norm_num : (1 : ℝ) ≤ 2))) (by positivity)

theorem chain_error (input : Nat → Float32) (contracted : Bool) (a b : Fin 128 → Expr)
    (ha : ∀ i, |real (evaluate input (a i))| ≤ (2 : ℝ)^(62 : Nat))
    (hb : ∀ i, |real (evaluate input (b i))| ≤ 2)
    (indices : List (Fin 128)) (hf : Arithmetic.Finite input (chain contracted a b indices)) :
    |real (evaluate input (chain contracted a b indices))-(indices.map (term input a b)).sum| ≤
      (factor indices.length-1)*mass input a b indices+tail indices.length :=
  WeightedFold.chain_error input contracted a b (fun i => add_le_add (ha i) (hb i)) indices hf

def laneIndices (lane : Fin 32) : List (Fin 128) :=
  [Gated.laneIndex lane 3, Gated.laneIndex lane 2, Gated.laneIndex lane 1, Gated.laneIndex lane 0]

theorem lane_execution (contracted : Bool) (a b : Fin 128 → Expr) (lane : Fin 32) :
    Gated.laneExpr contracted a b lane = chain contracted a b (laneIndices lane) := by
  rfl

theorem lane_error (input : Nat → Float32) (contracted : Bool) (a b : Fin 128 → Expr) (lane : Fin 32)
    (ha : ∀ i, |real (evaluate input (a i))| ≤ (2 : ℝ)^(62 : Nat))
    (hb : ∀ i, |real (evaluate input (b i))| ≤ 2)
    (hf : Arithmetic.Finite input (Gated.laneExpr contracted a b lane)) :
    |real (evaluate input (Gated.laneExpr contracted a b lane))-
      ((laneIndices lane).map (term input a b)).sum| ≤
      13*(2 : ℝ)^(-24 : Int)*mass input a b (laneIndices lane)+(2 : ℝ)^(-56 : Int) := by
  rw [lane_execution] at hf ⊢
  have h := chain_error input contracted a b ha hb (laneIndices lane) hf
  have size : (laneIndices lane).length = 4 := rfl
  rw [size] at h
  have q : factor 4-1 ≤ 13*(2 : ℝ)^(-24 : Int) := by norm_num [factor]
  have t : tail 4 ≤ (2 : ℝ)^(-56 : Int) := by norm_num [tail]
  exact h.trans (add_le_add (mul_le_mul_of_nonneg_right q (mass_nonnegative input a b _)) t)

theorem lane_indices : ∀ lane : Fin 32, (laneIndices lane).Perm
    ((List.finRange 4).map (Gated.laneIndex lane)) := by decide +kernel

theorem lane_sum (f : Fin 128 → ℝ) (lane : Fin 32) :
    ((laneIndices lane).map f).sum = ∑ offset : Fin 4, f (Gated.laneIndex lane offset) := by
  have h := ((lane_indices lane).map f).sum_eq
  simpa only [List.map_map, Function.comp_def, ← Fin.sum_univ_def] using h

theorem dot_error (input : Nat → Float32) (contracted : Bool) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (a b : Fin 128 → Expr)
    (ha : ∀ i, |real (evaluate input (a i))| ≤ (2 : ℝ)^(62 : Nat))
    (hb : ∀ i, |real (evaluate input (b i))| ≤ 2)
    (hf : Arithmetic.Finite input (Gated.dotExpr contracted tree a b)) :
    |real (evaluate input (Gated.dotExpr contracted tree a b))-(∑ i : Fin 128, term input a b i)| ≤
      46*(2 : ℝ)^(-24 : Int)*(∑ i : Fin 128, |term input a b i|)+(2 : ℝ)^(-50 : Int) := by
  let actual := fun lane => evaluate input (Gated.laneExpr contracted a b lane)
  let target := fun lane => ((laneIndices lane).map (term input a b)).sum
  let masses := fun lane => mass input a b (laneIndices lane)
  have laneFinite (lane : Fin 32) : Arithmetic.Finite input (Gated.laneExpr contracted a b lane) :=
    ArithmeticDependencies.reduce_finite input _ tree hf lane (coverage.mem_iff.mpr (List.mem_finRange lane))
  have lanes (lane : Fin 32) : |real (actual lane)-target lane| ≤
      13*(2 : ℝ)^(-24 : Int)*masses lane+(2 : ℝ)^(-56 : Int) :=
    lane_error input contracted a b lane ha hb (laneFinite lane)
  have massSum : (∑ lane : Fin 32, masses lane) = ∑ i : Fin 128, |term input a b i| := by
    simp only [masses, mass, lane_sum]
    exact Gated.lanes_complete (fun i => |term input a b i|)
  have targetSum : (∑ lane : Fin 32, target lane) = ∑ i : Fin 128, term input a b i := by
    simp only [target, lane_sum]
    exact Gated.lanes_complete _
  have magnitudes (lane : Fin 32) : |real (actual lane)| ≤
      (1+13*(2 : ℝ)^(-24 : Int))*masses lane+(2 : ℝ)^(-56 : Int) := by
    have h := NormalizedCastBounds.absolute_of_error _ _ _ (lanes lane)
    have ht : |target lane| ≤ masses lane := sum_bound input a b (laneIndices lane)
    linarith only [h, ht]
  have magnitudeSum := Finset.sum_le_sum (s := Finset.univ) (fun lane _ => magnitudes lane)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul, massSum] at magnitudeSum
  have errors : |(∑ lane : Fin 32, real (actual lane))-(∑ lane : Fin 32, target lane)| ≤
      13*(2 : ℝ)^(-24 : Int)*(∑ i : Fin 128, |term input a b i|)+32*(2 : ℝ)^(-56 : Int) := by
    have h := (Finset.abs_sum_le_sum_abs (fun lane => real (actual lane)-target lane) Finset.univ).trans
      (Finset.sum_le_sum (fun lane _ => lanes lane))
    simpa only [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.mul_sum,
      Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, Nat.cast_ofNat, massSum] using h
  have reduction := FlushedReductionRelative.covered_error actual tree coverage
    (FlushedReductionRelative.from_expression input _ tree hf)
  have total := (abs_sub_le (real (FlushedReduction.evaluate actual tree))
    (∑ lane : Fin 32, real (actual lane)) (∑ lane : Fin 32, target lane)).trans (add_le_add reduction errors)
  rw [targetSum] at total
  have nonnegative : 0 ≤ ∑ i : Fin 128, |term input a b i| := Finset.sum_nonneg (fun i _ => abs_nonneg _)
  rw [Gated.dotExpr, ArithmeticFold.evaluate_reduce]
  change |real (FlushedReduction.evaluate actual tree)-_| ≤ _
  norm_num at total magnitudeSum ⊢
  linarith only [total, magnitudeSum, nonnegative]

theorem dot_norm_error (input : Nat → Float32) (contracted : Bool) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (a b : Fin 128 → Expr)
    (ha : ∀ i, |real (evaluate input (a i))| ≤ (2 : ℝ)^(62 : Nat))
    (hb : ∀ i, |real (evaluate input (b i))| ≤ 2)
    (hf : Arithmetic.Finite input (Gated.dotExpr contracted tree a b)) :
    |real (evaluate input (Gated.dotExpr contracted tree a b))-(∑ i : Fin 128, term input a b i)| ≤
      46*(2 : ℝ)^(-24 : Int)*RecurrenceStability.magnitude (fun i => real (evaluate input (a i)))*
        RecurrenceStability.magnitude (fun i => real (evaluate input (b i)))+(2 : ℝ)^(-50 : Int) := by
  have h := dot_error input contracted tree coverage a b ha hb hf
  have cauchy := RecurrenceStability.cauchy (fun i => |real (evaluate input (a i))|)
    (fun i => |real (evaluate input (b i))|)
  have nonnegative : 0 ≤ ∑ i : Fin 128, |real (evaluate input (a i))| * |real (evaluate input (b i))| :=
    Finset.sum_nonneg (fun i _ => mul_nonneg (abs_nonneg _) (abs_nonneg _))
  simp only [RecurrenceStability.dot, abs_of_nonneg nonnegative, RecurrenceStability.magnitude,
    RecurrenceStability.energy, sq_abs] at cauchy
  have scaled := mul_le_mul_of_nonneg_left cauchy (by positivity : (0 : ℝ) ≤ 46*(2 : ℝ)^(-24 : Int))
  simp only [term, abs_mul] at h
  apply h.trans
  simpa only [RecurrenceStability.magnitude, RecurrenceStability.energy, mul_assoc] using
    add_le_add scaled (le_refl ((2 : ℝ)^(-50 : Int)))

end Inference.Kernels.Delta.GatedDotRelative
