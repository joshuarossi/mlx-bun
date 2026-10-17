import contracts.mlx.NormalizationBounds

namespace Inference.Contracts.Mlx.RsqrtBounds
open Numerics

-- This is a scalar-instruction envelope. It is deliberately weaker than
-- the accuracy contract used by numerical error propagation, and can be
-- derived from that contract plus a relative error and finiteness guarantee.
structure Envelope (rsqrt : Float32 → Float32) : Prop where
  finite : ∀ x, x.isFinite = true → 0 < real x → (rsqrt x).isFinite = true
  bound : ∀ x, x.isFinite = true → 0 < real x → |real (rsqrt x)| * Real.sqrt (real x) ≤ 2

theorem from_accuracy (rsqrt : Float32 → Float32) (error : Float32 → ℝ)
    (accuracy : Normalization.RsqrtContract rsqrt error)
    (finite : ∀ x, x.isFinite = true → 0 < real x → (rsqrt x).isFinite = true)
    (relative : ∀ x, x.isFinite = true → 0 < real x → error x ≤ 1 / Real.sqrt (real x)) : Envelope rsqrt := by
  refine ⟨finite, ?_⟩
  intro x hx positive
  have hs := Real.sqrt_pos.mpr positive
  have he := accuracy.accuracy x hx positive (finite x hx positive)
  have hb : |real (rsqrt x)| ≤ 2 / Real.sqrt (real x) := by
    calc
      _ = |(real (rsqrt x) - 1 / Real.sqrt (real x)) + 1 / Real.sqrt (real x)| := by congr 1; ring
      _ ≤ |real (rsqrt x) - 1 / Real.sqrt (real x)| + |1 / Real.sqrt (real x)| := abs_add_le _ _
      _ ≤ error x + |1 / Real.sqrt (real x)| := add_le_add he (le_refl _)
      _ ≤ 1 / Real.sqrt (real x) + |1 / Real.sqrt (real x)| := add_le_add (relative x hx positive) (le_refl _)
      _ = _ := by rw [abs_of_pos (div_pos (by norm_num) hs)]; ring
  exact (le_div_iff₀ hs).mp hb

theorem range (rsqrt : Float32 → Float32) (envelope : Envelope rsqrt) (floor cap : Float32)
    (positive : 0 < real floor) (nonnegative : 0 ≤ real cap)
    (capacity : 4 ≤ real floor * real cap ^ 2) : NormalizationBounds.RsqrtRange rsqrt floor cap := by
  constructor
  intro x hx lower
  have xp : 0 < real x := positive.trans_le lower
  have sp := Real.sqrt_pos.mpr xp
  have hb := envelope.bound x hx xp
  have hcap : 4 ≤ real x * real cap ^ 2 := capacity.trans (mul_le_mul_of_nonneg_right lower (sq_nonneg _))
  have hs : 2 ≤ real cap * Real.sqrt (real x) := by
    have he : (real cap * Real.sqrt (real x)) ^ 2 = real cap ^ 2 * real x := by
      rw [mul_pow, Real.sq_sqrt xp.le]
    have hp : 0 ≤ real cap * Real.sqrt (real x) := mul_nonneg nonnegative sp.le
    nlinarith
  exact ⟨envelope.finite x hx xp, (mul_le_mul_iff_left₀ sp).mp (hb.trans hs)⟩

end Inference.Contracts.Mlx.RsqrtBounds
