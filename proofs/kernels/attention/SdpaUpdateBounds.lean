import kernels.attention.SdpaOrderedExponentRanges
import kernels.attention.SdpaUpdateRelative
import contracts.mlx.ArithmeticBounds

namespace Inference.Kernels.Attention.SdpaUpdateBounds
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate ArithmeticBounds

def inputCap (count : Nat) (i : Nat) : Float32 :=
  if i = 0 then DyadicBounds.ceiling count 0
  else if i = 1 then DyadicBounds.ceiling 1 38
  else if i = 2 ∨ i = 3 then 1 else DyadicBounds.ceiling 1 23

private theorem countCap (count : Nat) (hc : count ≤ 8193) :
    (DyadicBounds.ceiling count 0).isFinite = true ∧ real (DyadicBounds.ceiling count 0) = (count : ℝ) := by
  simpa only [zpow_zero, mul_one] using DyadicBounds.ceiling_range count 0 (by omega) (by decide) (by decide)

private theorem cap (exponent : Int) (lo : 0 ≤ exponent) (hi : exponent ≤ 100) :
    (DyadicBounds.ceiling 1 exponent).isFinite = true ∧ real (DyadicBounds.ceiling 1 exponent) = (2 : ℝ)^exponent := by
  simpa only [Nat.cast_one, one_mul] using DyadicBounds.ceiling_range 1 exponent (by decide) (by omega) hi

theorem denominator_certificate (p : Platform) (count : Nat) (hc : count ≤ 8192) :
    Certificate (inputCap count) (denominatorExpr p) (DyadicBounds.ceiling (count+1) 0) := by
  have old : Certificate (inputCap count) (.input 0) (DyadicBounds.ceiling count 0) := .input 0
  have alpha : Certificate (inputCap count) (.input 2) 1 := .input 2
  have beta : Certificate (inputCap count) (.input 3) 1 := .input 3
  have current := countCap count (by omega)
  have next := countCap (count+1) (by omega)
  cases h : p.sumContracted <;> simp only [denominatorExpr, h, Bool.false_eq_true, ite_false, ite_true]
  · exact .add (.mul old alpha _ current.1 (by rw [real_one, mul_one])) beta _ next.1 (by
      rw [current.2, next.2, real_one]; push_cast; rfl)
  · exact .fma old alpha beta _ next.1 (by
      rw [current.2, next.2, real_one]; push_cast; ring_nf; exact le_refl _)

theorem numerator_certificate (p : Platform) (count : Nat) :
    Certificate (inputCap count) (numeratorExpr p) (DyadicBounds.ceiling 1 39) := by
  have old : Certificate (inputCap count) (.input 1) (DyadicBounds.ceiling 1 38) := .input 1
  have alpha : Certificate (inputCap count) (.input 2) 1 := .input 2
  have beta : Certificate (inputCap count) (.input 3) 1 := .input 3
  have value : Certificate (inputCap count) (.input 4) (DyadicBounds.ceiling 1 23) := .input 4
  have left : Certificate (inputCap count) (.mul (.input 1) (.input 2)) (DyadicBounds.ceiling 1 38) :=
    .mul old alpha _ (cap 38 (by decide) (by decide)).1 (by rw [real_one, mul_one])
  have right : Certificate (inputCap count) (.mul (.input 3) (.input 4)) (DyadicBounds.ceiling 1 23) :=
    .mul beta value _ (cap 23 (by decide) (by decide)).1 (by rw [real_one, one_mul])
  have sum : real (DyadicBounds.ceiling 1 38)+real (DyadicBounds.ceiling 1 23) ≤ real (DyadicBounds.ceiling 1 39) := by
    rw [(cap 38 (by decide) (by decide)).2, (cap 23 (by decide) (by decide)).2, (cap 39 (by decide) (by decide)).2]
    norm_num
  cases h : p.numeratorContracted <;> simp only [numeratorExpr, h]
  · exact .add left right _ (cap 39 (by decide) (by decide)).1 sum
  · exact .fma old alpha right _ (cap 39 (by decide) (by decide)).1 (by rwa [real_one, mul_one])
  · exact .fma beta value left _ (cap 39 (by decide) (by decide)).1 (by
      rw [real_one, one_mul, add_comm]; exact sum)

structure Bounds (s : State) (count : Nat) (ratio : ℝ) : Prop where
  shift : s.shift.isFinite = true ∧ |real s.shift| ≤ (2 : ℝ)^(24 : Nat)
  denominator : s.denominator.isFinite = true ∧ 1 ≤ real s.denominator ∧ real s.denominator ≤ (count : ℝ)
  numerator : s.numerator.isFinite = true ∧ |real s.numerator| ≤ ratio*real s.denominator

theorem step (p : SdpaVector.Platform) (maximum : SdpaInitialLoopRanges.Maximum p)
    (primitive : SdpaExponentRanges.Primitive p.merge.scalar) (s : State) (score value : Float32)
    (count : Nat) (hc : count ≤ 8192) (ratio : ℝ)
    (lower : (2 : ℝ)^(23 : Nat) ≤ ratio) (upper : ratio ≤ (2 : ℝ)^(25 : Nat))
    (state : Bounds s count ratio)
    (hs : score.isFinite = true ∧ |real score| ≤ (2 : ℝ)^(24 : Nat))
    (hv : value.isFinite = true ∧ |real value| ≤ (2 : ℝ)^(23 : Nat)) :
    SdpaUpdate.Finite p.merge.scalar s score value (p.maximum s.shift score) ∧
      Bounds (SdpaUpdate.step p.merge.scalar s score value (p.maximum s.shift score)) (count+1)
        ((1+(2 : ℝ)^(-19 : Int))*ratio) := by
  let shift := p.maximum s.shift score
  let input := SdpaUpdate.bind p.merge.scalar s score value shift
  have exponents := SdpaOrderedExponentRanges.selected p maximum primitive s.shift score state.shift hs
  have denominatorNonnegative : 0 ≤ real s.denominator := by linarith only [state.denominator.2.1]
  have numeratorBound : |real s.numerator| ≤ (2 : ℝ)^(38 : Nat) := by
    have size := mul_le_mul upper state.denominator.2.2 denominatorNonnegative (by positivity)
    have countBound : (count : ℝ) ≤ 8192 := by exact_mod_cast hc
    have total := state.numerator.2.trans size
    norm_num at total ⊢
    linarith only [total, countBound]
  have bounded : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ real (inputCap count i) := by
    intro i
    by_cases h0 : i = 0
    · subst i
      exact ⟨state.denominator.1, by
        change |real s.denominator| ≤ real (DyadicBounds.ceiling count 0)
        rw [abs_of_nonneg denominatorNonnegative, (countCap count (by omega)).2]
        exact state.denominator.2.2⟩
    by_cases h1 : i = 1
    · subst i
      exact ⟨state.numerator.1, by
        change |real s.numerator| ≤ real (DyadicBounds.ceiling 1 38)
        simpa only [(cap 38 (by decide) (by decide)).2, zpow_ofNat] using numeratorBound⟩
    by_cases h2 : i = 2
    · subst i
      exact ⟨exponents.2.2.1.1.exponential, by
        change |real (exponential p.merge.scalar s.shift shift)| ≤ real (1 : Float32)
        rw [real_one, abs_of_nonneg exponents.2.2.1.2.1]
        exact exponents.2.2.1.2.2⟩
    by_cases h3 : i = 3
    · subst i
      exact ⟨exponents.2.2.2.1.1.exponential, by
        change |real (exponential p.merge.scalar score shift)| ≤ real (1 : Float32)
        rw [real_one, abs_of_nonneg exponents.2.2.2.1.2.1]
        exact exponents.2.2.2.1.2.2⟩
    · simpa only [input, SdpaUpdate.bind, inputCap, h0, h1, h2, h3, ite_false, or_self,
        (cap 23 (by decide) (by decide)).2, zpow_ofNat] using hv
  have denominator := ArithmeticBounds.sound input (inputCap count) bounded (denominator_certificate p.merge.scalar count hc)
  have numerator := ArithmeticBounds.sound input (inputCap count) bounded (numerator_certificate p.merge.scalar count)
  have finite : SdpaUpdate.Finite p.merge.scalar s score value shift :=
    ⟨exponents.2.2.1.1, exponents.2.2.2.1.1, denominator.1, numerator.1⟩
  have lowerDen := SdpaUpdateRelative.denominator_lower p.merge.scalar input denominator.1 state.denominator.2.1
    exponents.2.2.1.2.1 exponents.2.2.2.1.2.1 exponents.2.2.2.2
  have denBound : |real (input 0)|+|real (input 2)| ≤ (2 : ℝ)^(62 : Nat)+2 := by
    have d := (bounded 0).2
    have a := (bounded 2).2
    simp only [inputCap, ite_true, show ¬(2 : Nat) = 0 from by decide,
      show ¬(2 : Nat) = 1 from by decide, ite_false, true_or, real_one,
      (countCap count (by omega)).2] at d a
    have countBound : (count : ℝ) ≤ 8192 := by exact_mod_cast hc
    norm_num at d a ⊢
    linarith only [d, a, countBound]
  have firstBound : |real (input 1)|+|real (input 2)| ≤ (2 : ℝ)^(62 : Nat)+2 := by
    have a := (bounded 2).2
    change |real (input 2)| ≤ real (1 : Float32) at a
    rw [real_one] at a
    change |real s.numerator|+|real (input 2)| ≤ _
    norm_num at numeratorBound ⊢
    linarith only [numeratorBound, a]
  have secondBound : |real (input 3)|+|real (input 4)| ≤ (2 : ℝ)^(62 : Nat)+2 := by
    have b := (bounded 3).2
    change |real (input 3)| ≤ real (1 : Float32) at b
    rw [real_one] at b
    change |real (input 3)|+|real value| ≤ _
    have v := hv.2
    norm_num at v ⊢
    linarith only [b, v]
  have denError := SdpaUpdateRelative.denominator_error p.merge.scalar input denominator.1 denBound
    denominatorNonnegative exponents.2.2.1.2.1 exponents.2.2.2.1.2.1
  have numError := SdpaUpdateRelative.numerator_error p.merge.scalar input numerator.1 firstBound secondBound
  have alpha : 0 ≤ real (input 2) := exponents.2.2.1.2.1
  have beta : 0 ≤ real (input 3) := exponents.2.2.2.1.2.1
  rw [abs_of_nonneg alpha, abs_of_nonneg beta] at numError
  have ratioBound := SdpaUpdateRelative.ratio_growth (real s.denominator) (real s.numerator)
    (real (Arithmetic.evaluate input (denominatorExpr p.merge.scalar)))
    (real (Arithmetic.evaluate input (numeratorExpr p.merge.scalar)))
    (real (input 2)) (real (input 3)) (real value) ratio state.denominator.2.1
    (by norm_num at lower ⊢; linarith only [lower]) state.numerator.2 (hv.2.trans lower)
    alpha beta exponents.2.2.2.2 denError numError
  have stored := SdpaUpdate.step_finite _ _ _ _ _ finite
  simp only [input, denominator_execution, numerator_execution] at lowerDen ratioBound denominator
  exact ⟨finite, ⟨⟨exponents.1, exponents.2.1⟩,
    ⟨stored.2.1, lowerDen, (le_abs_self _).trans (denominator.2.trans_eq (countCap (count+1) (by omega)).2)⟩,
    ⟨stored.2.2, ratioBound⟩⟩⟩

end Inference.Kernels.Attention.SdpaUpdateBounds
