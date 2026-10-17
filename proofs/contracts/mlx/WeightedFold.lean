import contracts.mlx.ArithmeticMaddRelative
import contracts.mlx.NonnegativeArithmetic

namespace Inference.Contracts.Mlx.WeightedFold
open Numerics Arithmetic

def chain (contracted : Bool) (a b : α → Expr) : List (α) → Expr
  | [] => .zero
  | i::rest => ArithmeticFold.madd contracted (a i) (b i) (chain contracted a b rest)

noncomputable def term (input : Nat → Float32) (a b : α → Expr) (i : α) : ℝ :=
  real (evaluate input (a i))*real (evaluate input (b i))
noncomputable def mass (input : Nat → Float32) (a b : α → Expr) (indices : List (α)) : ℝ :=
  (indices.map (fun i => |term input a b i|)).sum
noncomputable def factor (length : Nat) : ℝ := (1+3*(2 : ℝ)^(-24 : Int))^length
noncomputable def tail (length : Nat) : ℝ := ((2 : ℝ)^length-1)*(2 : ℝ)^(-60 : Int)

theorem mass_nonnegative (input : Nat → Float32) (a b : α → Expr) (indices : List (α)) :
    0 ≤ mass input a b indices := by
  induction indices with
  | nil => simp [mass]
  | cons i rest ih =>
    change 0 ≤ |term input a b i|+mass input a b rest
    exact add_nonneg (abs_nonneg _) ih

theorem sum_bound (input : Nat → Float32) (a b : α → Expr) (indices : List (α)) :
    |(indices.map (term input a b)).sum| ≤ mass input a b indices := by
  induction indices with
  | nil => simp [mass]
  | cons i rest ih =>
    exact (abs_add_le _ _).trans (add_le_add (le_refl _) ih)

theorem factor_lower (length : Nat) : 1 ≤ factor length := one_le_pow₀ (by norm_num)
theorem tail_nonnegative (length : Nat) : 0 ≤ tail length :=
  mul_nonneg (sub_nonneg.mpr (one_le_pow₀ (by norm_num : (1 : ℝ) ≤ 2))) (by positivity)

theorem chain_error (input : Nat → Float32) (contracted : Bool) (a b : α → Expr)
    (bound : ∀ i, |real (evaluate input (a i))|+|real (evaluate input (b i))| ≤ (2 : ℝ)^(62 : Nat)+2)
    (indices : List (α)) (hf : Arithmetic.Finite input (chain contracted a b indices)) :
    |real (evaluate input (chain contracted a b indices))-(indices.map (term input a b)).sum| ≤
      (factor indices.length-1)*mass input a b indices+tail indices.length := by
  induction indices with
  | nil =>
    have hz : real (0 : Float32) = 0 := by
      rw [real_unpack]
      exact FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal_zero .positive
    simp [chain, evaluate, hz, factor, tail, mass]
  | cons i rest ih =>
    have hacc : Arithmetic.Finite input (chain contracted a b rest) := by
      cases contracted
      · exact hf.1
      · exact hf.2.2.1
    have previous := ih hacc
    have current := ArithmeticMaddRelative.error_sum input contracted (a i) (b i) (chain contracted a b rest) hf (bound i)
    have accabs := NormalizedCastBounds.absolute_of_error _ _ _ previous
    have bounded : |real (evaluate input (chain contracted a b rest))| ≤ factor rest.length*mass input a b rest+tail rest.length := by
      linarith only [accabs, sum_bound input a b rest]
    have inherited : |(real (evaluate input (a i))*real (evaluate input (b i))+
        real (evaluate input (chain contracted a b rest)))-((i::rest).map (term input a b)).sum| ≤
        (factor rest.length-1)*mass input a b rest+tail rest.length := by
      simpa only [List.map_cons, List.sum_cons, term, add_sub_add_left_eq_sub] using previous
    have total := (abs_sub_le (real (evaluate input (chain contracted a b (i::rest))))
      (real (evaluate input (a i))*real (evaluate input (b i))+real (evaluate input (chain contracted a b rest)))
      (((i::rest).map (term input a b)).sum)).trans (add_le_add current inherited)
    have factorStep : factor (rest.length+1) = (1+3*(2 : ℝ)^(-24 : Int))*factor rest.length := by
      unfold factor
      rw [pow_succ]
      ring
    have tailStep : tail (rest.length+1) = 2*tail rest.length+(2 : ℝ)^(-60 : Int) := by
      unfold tail
      rw [pow_succ]
      ring
    have scaled := mul_le_mul_of_nonneg_left bounded
      (by positivity : (0 : ℝ) ≤ 3*(2 : ℝ)^(-24 : Int))
    have productNonnegative : 0 ≤ |real (evaluate input (a i))| * |real (evaluate input (b i))| :=
      mul_nonneg (abs_nonneg _) (abs_nonneg _)
    have factorNonnegative := factor_lower rest.length
    have productSlack := mul_nonneg (sub_nonneg.mpr factorNonnegative) productNonnegative
    have tailNonnegative := tail_nonnegative rest.length
    change _ ≤ (factor (rest.length+1)-1)*(|term input a b i|+mass input a b rest)+tail (rest.length+1)
    rw [factorStep, tailStep, term, abs_mul]
    norm_num at total scaled ⊢
    nlinarith only [total, scaled, productSlack, tailNonnegative]

-- A two-pass merge lane contains at most 32 products for the selected
-- 32--1024 block family. The absolute allowance includes every FTZ term.
theorem short_error (input : Nat → Float32) (contracted : Bool) (a b : α → Expr)
    (bound : ∀ i, |real (evaluate input (a i))|+|real (evaluate input (b i))| ≤ (2 : ℝ)^(62 : Nat)+2)
    (indices : List α) (length : indices.length ≤ 32)
    (hf : Arithmetic.Finite input (chain contracted a b indices)) :
    |real (evaluate input (chain contracted a b indices))-(indices.map (term input a b)).sum| ≤
      (2 : ℝ)^(-17 : Int)*mass input a b indices+(2 : ℝ)^(-28 : Int) := by
  have h := chain_error input contracted a b bound indices hf
  have powers : factor indices.length ≤ factor 32 := pow_le_pow_right₀ (by norm_num) length
  have tails : tail indices.length ≤ tail 32 := by
    apply mul_le_mul_of_nonneg_right _ (by positivity)
    exact sub_le_sub_right (pow_le_pow_right₀ (by norm_num : (1 : ℝ) ≤ 2) length) 1
  have q : factor indices.length-1 ≤ (2 : ℝ)^(-17 : Int) := by
    have explicit : factor 32-1 ≤ (2 : ℝ)^(-17 : Int) := by norm_num [factor]
    linarith
  have t : tail indices.length ≤ (2 : ℝ)^(-28 : Int) := tails.trans (by norm_num [tail])
  exact h.trans (add_le_add (mul_le_mul_of_nonneg_right q (mass_nonnegative input a b indices)) t)

def ordered (contracted : Bool) (a b : α → Expr) (indices : List α) : Expr :=
  indices.foldl (fun acc i => ArithmeticFold.madd contracted (a i) (b i) acc) .zero

theorem chain_foldr (contracted : Bool) (a b : α → Expr) (indices : List α) :
    chain contracted a b indices = indices.foldr (fun i acc => ArithmeticFold.madd contracted (a i) (b i) acc) .zero := by
  induction indices with
  | nil => rfl
  | cons i rest ih => simp only [chain, List.foldr_cons, ih]

theorem ordered_chain (contracted : Bool) (a b : α → Expr) (indices : List α) :
    ordered contracted a b indices = chain contracted a b indices.reverse := by
  rw [chain_foldr, ordered, List.foldl_eq_foldr_reverse]

theorem ordered_error (input : Nat → Float32) (contracted : Bool) (a b : α → Expr)
    (bound : ∀ i, |real (evaluate input (a i))|+|real (evaluate input (b i))| ≤ (2 : ℝ)^(62 : Nat)+2)
    (indices : List α) (length : indices.length ≤ 32)
    (hf : Arithmetic.Finite input (ordered contracted a b indices)) :
    |real (evaluate input (ordered contracted a b indices))-(indices.map (term input a b)).sum| ≤
      (2 : ℝ)^(-17 : Int)*mass input a b indices+(2 : ℝ)^(-28 : Int) := by
  rw [ordered_chain] at hf ⊢
  have h := short_error input contracted a b bound indices.reverse (by simpa only [List.length_reverse] using length) hf
  simpa only [mass, List.map_reverse, List.sum_reverse] using h

theorem chain_nonnegative (input : Nat → Float32) (contracted : Bool) (a b : α → Expr)
    (ha : ∀ i, NonnegativeArithmetic.Nonnegative input (a i))
    (hb : ∀ i, NonnegativeArithmetic.Nonnegative input (b i)) (indices : List α) :
    NonnegativeArithmetic.Nonnegative input (chain contracted a b indices) := by
  induction indices with
  | nil => exact .zero
  | cons i rest ih =>
    cases contracted
    · exact .add ih (.mul (ha i) (hb i))
    · exact .fma (ha i) (hb i) ih

theorem chain_lower_one (input : Nat → Float32) (contracted : Bool) (a b : α → Expr)
    (ha : ∀ i, NonnegativeArithmetic.Nonnegative input (a i))
    (hb : ∀ i, NonnegativeArithmetic.Nonnegative input (b i)) (indices : List α)
    (witness : α) (member : witness ∈ indices)
    (haone : real (evaluate input (a witness)) = 1)
    (hbone : NonnegativeArithmetic.LowerOne input (b witness)) :
    NonnegativeArithmetic.LowerOne input (chain contracted a b indices) := by
  induction indices with
  | nil => exact False.elim (List.not_mem_nil member)
  | cons i rest ih =>
    rcases List.mem_cons.mp member with rfl | member
    · cases contracted
      · exact .addRight (chain_nonnegative input false a b ha hb rest) (.mulLeftOne haone hbone)
      · exact .fmaProductRight haone hbone (chain_nonnegative input true a b ha hb rest)
    · cases contracted
      · exact .addLeft (ih member) (.mul (ha i) (hb i))
      · exact .fmaAddend (ha i) (hb i) (ih member)

theorem ordered_nonnegative (input : Nat → Float32) (contracted : Bool) (a b : α → Expr)
    (ha : ∀ i, NonnegativeArithmetic.Nonnegative input (a i))
    (hb : ∀ i, NonnegativeArithmetic.Nonnegative input (b i)) (indices : List α) :
    NonnegativeArithmetic.Nonnegative input (ordered contracted a b indices) := by
  rw [ordered_chain]
  exact chain_nonnegative input contracted a b ha hb indices.reverse

theorem ordered_lower_one (input : Nat → Float32) (contracted : Bool) (a b : α → Expr)
    (ha : ∀ i, NonnegativeArithmetic.Nonnegative input (a i))
    (hb : ∀ i, NonnegativeArithmetic.Nonnegative input (b i)) (indices : List α)
    (witness : α) (member : witness ∈ indices)
    (haone : real (evaluate input (a witness)) = 1)
    (hbone : NonnegativeArithmetic.LowerOne input (b witness)) :
    NonnegativeArithmetic.LowerOne input (ordered contracted a b indices) := by
  rw [ordered_chain]
  exact chain_lower_one input contracted a b ha hb indices.reverse witness
    (List.mem_reverse.mpr member) haone hbone

end Inference.Contracts.Mlx.WeightedFold
