import kernels.delta.SiluRmsHeads
import contracts.mlx.SquaredSumRelativeBounds
import contracts.mlx.DyadicCover

namespace Inference.Kernels.Delta.SiluRmsHeadsSumBounds
open Contracts.Mlx Contracts.Mlx.Numerics SiluRmsHeads
open scoped BigOperators

theorem lane_size (contracted : Bool) (lane : Fin 32) :
    (SquaredSum.indices (laneExpr contracted lane)).length = 4 := by
  have h := (SquaredSum.accumulate_indices contracted (columns lane) .zero).length_eq
  simpa only [laneExpr, SquaredSum.indices, List.nil_append, columns, List.length_map, List.length_finRange] using h

theorem lane_cost (contracted : Bool) (lane : Fin 32) :
    SquaredSumRelativeBounds.cost (laneExpr contracted lane) ≤ 22 := by
  have checked : ∀ c : Bool, ∀ i : Fin 32, SquaredSumRelativeBounds.cost (laneExpr c i) ≤ 22 := by decide +kernel
  exact checked contracted lane

theorem tree_size (contracted : Bool) (tree : Reduction.Tree 32) :
    (SquaredSum.indices (expression contracted tree)).length = 4*(Reduction.leaves tree).length := by
  induction tree with
  | leaf i => simpa only [expression, SquaredSum.reduceTree, Reduction.leaves, List.length_singleton, Nat.mul_one] using lane_size contracted i
  | add a b ia ib =>
    change (SquaredSum.indices (expression contracted a) ++ SquaredSum.indices (expression contracted b)).length = _
    rw [List.length_append, ia, ib]
    simp only [Reduction.leaves, List.length_append, Nat.mul_add]

theorem tree_cost (contracted : Bool) (tree : Reduction.Tree 32) (size : (Reduction.leaves tree).length ≤ 32) :
    SquaredSumRelativeBounds.cost (expression contracted tree)+129 ≤ 151*(Reduction.leaves tree).length := by
  induction tree with
  | leaf i =>
    have h := lane_cost contracted i
    change SquaredSumRelativeBounds.cost (laneExpr contracted i)+129 ≤ 151*1
    omega
  | add a b ia ib =>
    have ss : (Reduction.leaves a).length+(Reduction.leaves b).length ≤ 32 := by
      simpa only [Reduction.leaves, List.length_append] using size
    have ha := ia (by omega)
    have hb := ib (by omega)
    change SquaredSumRelativeBounds.cost (expression contracted a)+SquaredSumRelativeBounds.cost (expression contracted b)+
      (SquaredSum.indices (expression contracted a)).length+(SquaredSum.indices (expression contracted b)).length+1+129 ≤ _
    rw [tree_size, tree_size]
    simp only [Reduction.leaves, List.length_append]
    omega

theorem sum_error (input : Fin 128 → Float32) (contracted : Bool) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (e : Int) (lo : -10 ≤ e) (hi : e ≤ 50)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^e) :
    SquaredSum.Finite input (expression contracted tree) ∧
      |real (SquaredSum.evaluate input (expression contracted tree)) - ∑ i : Fin 128, (real (input i))^2| ≤
        4832*SquaredSumRelativeBounds.unit e := by
  have hl : (Reduction.leaves tree).length = 32 := by simpa only [List.length_finRange] using coverage.length_eq
  have hs : (SquaredSum.indices (expression contracted tree)).length = 128 := by rw [tree_size, hl]
  have hf := SquaredSumDyadicBounds.range input e (by omega) (by omega) hx (expression contracted tree) (by omega)
  have he := SquaredSum.sum_error input (expression contracted tree) (expression_coverage contracted tree coverage) hf.1
  have hb := SquaredSumRelativeBounds.budget_bound input e lo hi hx (expression contracted tree) (by omega)
  have hc : (SquaredSumRelativeBounds.cost (expression contracted tree) : ℝ) ≤ 4832 := by
    have h := tree_cost contracted tree (by omega)
    rw [hl] at h
    exact_mod_cast (show SquaredSumRelativeBounds.cost (expression contracted tree) ≤ 4832 by omega)
  exact ⟨hf.1, he.trans (hb.trans (mul_le_mul_of_nonneg_right hc (by
    unfold SquaredSumRelativeBounds.unit SquaredSumRelativeBounds.scale
    positivity)))⟩

theorem relative_error (input : Fin 128 → Float32) (contracted : Bool) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (e : Int) (lo : -10 ≤ e) (hi : e ≤ 50)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^e)
    (witness : Fin 128) (large : (2 : ℝ)^(e-1) < |real (input witness)|) :
    |real (SquaredSum.evaluate input (expression contracted tree)) - ∑ i : Fin 128, (real (input i))^2| ≤
      (∑ i : Fin 128, (real (input i))^2)/512 := by
  have h := (sum_error input contracted tree coverage e lo hi hx).2
  have single : (real (input witness))^2 ≤ ∑ i : Fin 128, (real (input i))^2 :=
    Finset.single_le_sum (fun i _ => sq_nonneg (real (input i))) (Finset.mem_univ witness)
  have hs := (sq_le_sq₀ (by positivity : 0 ≤ (2 : ℝ)^(e-1)) (abs_nonneg _)).mpr large.le
  rw [sq_abs] at hs
  have powers : ((2 : ℝ)^(e-1))^2 = SquaredSumRelativeBounds.scale e/4 := by
    rw [pow_two, ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
    unfold SquaredSumRelativeBounds.scale
    rw [show e-1+(e-1) = (e+e)-2 from by ring, zpow_sub₀ (by norm_num : (2 : ℝ) ≠ 0)]
    norm_num
  rw [powers] at hs
  unfold SquaredSumRelativeBounds.unit at h
  norm_num at h
  have pos : 0 ≤ ∑ i : Fin 128, (real (input i))^2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  linarith

theorem uniform_error (input : Fin 128 → Float32) (contracted : Bool) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32))
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^(50 : Nat)) :
    |real (SquaredSum.evaluate input (expression contracted tree)) - ∑ i : Fin 128, (real (input i))^2| ≤
      (∑ i : Fin 128, (real (input i))^2)/512+(2 : ℝ)^(-30 : Int) := by
  rcases DyadicCover.interval (fun i => real (input i)) (-10) 60
    (fun i => by simpa only [show (-10 : Int)+(60 : Nat) = 50 from by decide, zpow_ofNat] using (hx i).2) with
    small | ⟨e, lo, hi, upper, i, lower⟩
  · have h := (sum_error input contracted tree coverage (-10) (by decide) (by decide)
      (fun i => ⟨(hx i).1, small i⟩)).2
    have hn : 0 ≤ ∑ i : Fin 128, (real (input i))^2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
    norm_num [SquaredSumRelativeBounds.unit, SquaredSumRelativeBounds.scale] at h ⊢
    linarith
  · have h := relative_error input contracted tree coverage e lo.le (by norm_num at hi; exact hi)
      (fun i => ⟨(hx i).1, upper i⟩) i lower
    exact h.trans (le_add_of_nonneg_right (by positivity))

end Inference.Kernels.Delta.SiluRmsHeadsSumBounds
