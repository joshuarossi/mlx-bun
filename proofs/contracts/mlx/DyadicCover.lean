import contracts.mlx.DyadicBounds

namespace Inference.Contracts.Mlx.DyadicCover
open Numerics

-- A proof-only case split: either the whole vector is at most one, or some
-- component witnesses the lower edge of a shared power-of-two input bound.
-- No numerical scan or dispatch is added to the program being verified.
theorem cover (x : α → ℝ) (limit : Nat) (bound : ∀ i, |x i| ≤ (2 : ℝ)^limit) :
    (∀ i, |x i| ≤ 1) ∨
      ∃ exponent : Nat, 0 < exponent ∧ exponent ≤ limit ∧
        (∀ i, |x i| ≤ (2 : ℝ)^exponent) ∧ ∃ i, (2 : ℝ)^(exponent-1) < |x i| := by
  classical
  induction limit with
  | zero => exact Or.inl (by simpa only [pow_zero] using bound)
  | succ limit ih =>
    by_cases smaller : ∀ i, |x i| ≤ (2 : ℝ)^limit
    · rcases ih smaller with small | ⟨exponent, positive, size, upper, lower⟩
      · exact Or.inl small
      · exact Or.inr ⟨exponent, positive, Nat.le_succ_of_le size, upper, lower⟩
    · push Not at smaller
      exact Or.inr ⟨limit+1, by omega, le_refl _, bound, by simpa only [Nat.add_sub_cancel] using smaller⟩

theorem interval (x : α → ℝ) (lower : Int) (span : Nat)
    (bound : ∀ i, |x i| ≤ (2 : ℝ)^(lower + (span : Int))) :
    (∀ i, |x i| ≤ (2 : ℝ)^lower) ∨
      ∃ exponent : Int, lower < exponent ∧ exponent ≤ lower + (span : Int) ∧
        (∀ i, |x i| ≤ (2 : ℝ)^exponent) ∧ ∃ i, (2 : ℝ)^(exponent-1) < |x i| := by
  classical
  induction span with
  | zero => exact Or.inl (by simpa only [Nat.cast_zero, add_zero] using bound)
  | succ span ih =>
    by_cases smaller : ∀ i, |x i| ≤ (2 : ℝ)^(lower + (span : Int))
    · rcases ih smaller with small | ⟨exponent, positive, size, upper, witness⟩
      · exact Or.inl small
      · exact Or.inr ⟨exponent, positive, by omega, upper, witness⟩
    · push Not at smaller
      refine Or.inr ⟨lower + ((span+1 : Nat) : Int), by omega, le_refl _, bound, ?_⟩
      rcases smaller with ⟨i, hi⟩
      refine ⟨i, ?_⟩
      rw [show lower + ((span+1 : Nat) : Int) - 1 = lower + (span : Int) from by omega]
      exact hi

end Inference.Contracts.Mlx.DyadicCover
