import contracts.mlx.DivisionBounds

namespace Inference.Contracts.Mlx.DivisionDirectedBounds
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Scalar division bounds retain the divisor, so normalization and input
-- scaling can exploit it. These facts are derived for the IEEE reference.
structure Contract (divide : Float32 → Float32 → Float32) extends DivisionBounds.Contract divide where
  quotientBounded : ∀ x y cap, x.isFinite = true → y.isFinite = true → Division.DivisorDomain y →
    cap.isFinite = true → |real x| / real y ≤ real cap → |real (divide x y)| ≤ real cap
  lower : ∀ x y floor, x.isFinite = true → y.isFinite = true → Division.DivisorDomain y →
    floor.isFinite = true → FlushToZero.threshold < real floor →
    real floor ≤ real (FlushToZero.flush x) / real y → real floor ≤ real (divide x y)

theorem reference : Contract DivisionBounds.value := by
  refine ⟨DivisionBounds.referenceRange, ?_, ?_⟩
  · intro x y cap hx hy hd hc hb
    apply (FlushToZero.flush_abs_le _).trans
    rw [DivisionBounds.raw_real x y hx hy hd]
    apply Float32Bounds.rounded_bound cap hc
    rw [abs_div, abs_of_pos (by linarith [hd.1] : 0 < real y)]
    exact (div_le_div_of_nonneg_right (FlushToZero.flush_abs_le x) (by linarith [hd.1])).trans hb
  · intro x y floor hx hy hd hf normal bound
    have h := Model.roundAt_mono FloatFormat.binary32 bound
    have he : Model.roundAt FloatFormat.binary32 (real floor) = real floor :=
      Model.roundAt_toReal_eq (model floor) (by rw [finite_model]; exact hf)
    rw [he, ← DivisionBounds.raw_real x y hx hy hd] at h
    have hp : 0 < real (DivisionBounds.raw x y) := (FlushToZero.threshold_pos.trans normal).trans_le h
    unfold DivisionBounds.value
    rw [FlushToZero.flush_eq_of_threshold_lt _ (by rw [abs_of_pos hp]; exact normal.trans_le h)]
    exact h

end Inference.Contracts.Mlx.DivisionDirectedBounds
