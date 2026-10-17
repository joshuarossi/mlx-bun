import contracts.mlx.RsqrtBounds

namespace Inference.Contracts.Mlx.RsqrtRelativeBounds
open Numerics

-- This is a scalar instruction contract. The bound is derived from the
-- existing accuracy contract when its supplied error has this relative size.
structure Envelope (rsqrt : Float32 → Float32) (factor : ℝ) : Prop where
  finite : ∀ x, x.isFinite = true → 0 < real x → (rsqrt x).isFinite = true
  bound : ∀ x, x.isFinite = true → 0 < real x → |real (rsqrt x)| * Real.sqrt (real x) ≤ factor

theorem from_accuracy (rsqrt : Float32 → Float32) (error : Float32 → ℝ) (factor : ℝ)
    (accuracy : Normalization.RsqrtContract rsqrt error)
    (finite : ∀ x, x.isFinite = true → 0 < real x → (rsqrt x).isFinite = true)
    (relative : ∀ x, x.isFinite = true → 0 < real x → error x ≤ (factor-1)/Real.sqrt (real x)) :
    Envelope rsqrt factor := by
  refine ⟨finite, ?_⟩
  intro x hx positive
  have sp := Real.sqrt_pos.mpr positive
  have he := accuracy.accuracy x hx positive (finite x hx positive)
  have hb : |real (rsqrt x)| ≤ factor/Real.sqrt (real x) := by
    calc
      _ = |(real (rsqrt x)-1/Real.sqrt (real x))+1/Real.sqrt (real x)| := by congr 1; ring
      _ ≤ |real (rsqrt x)-1/Real.sqrt (real x)|+|1/Real.sqrt (real x)| := abs_add_le _ _
      _ ≤ error x+|1/Real.sqrt (real x)| := add_le_add he (le_refl _)
      _ ≤ (factor-1)/Real.sqrt (real x)+|1/Real.sqrt (real x)| :=
        add_le_add (relative x hx positive) (le_refl _)
      _ = _ := by rw [abs_of_pos (div_pos (by norm_num) sp)]; ring
  exact (le_div_iff₀ sp).mp hb

theorem weaken (rsqrt : Float32 → Float32) (factor : ℝ)
    (h : Envelope rsqrt factor) (upper : factor ≤ 2) : RsqrtBounds.Envelope rsqrt :=
  ⟨h.finite, fun x hx hp => (h.bound x hx hp).trans upper⟩

theorem squared (rsqrt : Float32 → Float32) (factor : ℝ) (h : Envelope rsqrt factor)
    (x : Float32) (hx : x.isFinite = true) (positive : 0 < real x) :
    real (rsqrt x)^2*real x ≤ factor^2 := by
  have hb := h.bound x hx positive
  have hs := mul_self_le_mul_self (mul_nonneg (abs_nonneg (real (rsqrt x))) (Real.sqrt_nonneg (real x))) hb
  simpa only [← sq, mul_pow, sq_abs, Real.sq_sqrt positive.le] using hs

end Inference.Contracts.Mlx.RsqrtRelativeBounds
