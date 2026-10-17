import contracts.mlx.NativeDivisionBounds

namespace Inference.Contracts.Mlx.Float32UnitInterval
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem flush_interval (x : Float32) (hx : 0 ≤ real x ∧ real x ≤ 1) :
    0 ≤ real (FlushToZero.flush x) ∧ real (FlushToZero.flush x) ≤ 1 := by
  refine ⟨FlushToZero.flush_nonnegative x hx.1, ?_⟩
  exact (le_abs_self _).trans ((FlushToZero.flush_abs_le x).trans (by rw [abs_of_nonneg hx.1]; exact hx.2))

theorem rounded_interval (x : ℝ) (hx : 0 ≤ x ∧ x ≤ 1) :
    0 ≤ Model.roundAt FloatFormat.binary32 x ∧ Model.roundAt FloatFormat.binary32 x ≤ 1 := by
  refine ⟨FlushToZero.round_nonnegative _ hx.1, ?_⟩
  have h := Model.roundAt_mono FloatFormat.binary32 hx.2
  have he := Model.roundAt_toReal_eq (model (1 : Float32)) (by rw [finite_model]; decide)
  change Model.roundAt FloatFormat.binary32 (real (1 : Float32)) = real (1 : Float32) at he
  rw [real_one] at he
  rwa [he] at h

theorem reciprocal (x : Float32) (hx : x.isFinite = true) (lower : 1 ≤ real x) :
    ((1 : Float32)/x).isFinite = true ∧ (FlushToZero.div 1 x).isFinite = true ∧
      (0 ≤ real (FlushToZero.div 1 x) ∧ real (FlushToZero.div 1 x) ≤ 1) := by
  have hf := NativeDivisionBounds.reciprocal_finite x hx lower
  have hp : 0 < real x := by linarith
  have hi : 0 ≤ (1 : ℝ)/real x ∧ (1 : ℝ)/real x ≤ 1 := ⟨by positivity, (div_le_one hp).mpr lower⟩
  have hr : 0 ≤ real ((1 : Float32)/x) ∧ real ((1 : Float32)/x) ≤ 1 := by
    rw [Numerics.div_real _ x hx hf, real_one]
    exact rounded_interval _ hi
  refine ⟨hf, ?_, ?_⟩
  · unfold FlushToZero.div
    rw [FlushToZero.flush_one, FlushToZero.flush_eq_of_one_le x lower]
    exact FlushToZero.finite_flushExact _ _ hf
  · unfold FlushToZero.div
    rw [FlushToZero.flush_one, FlushToZero.flush_eq_of_one_le x lower]
    rcases FlushToZero.flushExact_cases (FlushToZero.divExact (model 1) (model x)) ((1 : Float32)/x) with h | h
    · rw [h]; exact hr
    · rw [h]; norm_num


theorem complement (x : Float32) (hx : x.isFinite = true) (interval : 0 ≤ real x ∧ real x ≤ 1) :
    (FlushToZero.flush (1 : Float32) - FlushToZero.flush x).isFinite = true ∧
      (Arithmetic.sub 1 x).isFinite = true ∧ (0 ≤ real (Arithmetic.sub 1 x) ∧ real (Arithmetic.sub 1 x) ≤ 1) := by
  have hi := flush_interval x interval
  have hd : 0 ≤ (1 : ℝ)-real (FlushToZero.flush x) ∧ (1 : ℝ)-real (FlushToZero.flush x) ≤ 1 := by
    constructor <;> linarith [hi.1, hi.2]
  have hf : ((1 : Float32) - FlushToZero.flush x).isFinite = true := by
    rw [← finite_model, Float32Bounds.sub_model _ _ (by decide) (FlushToZero.finite_flush x hx)]
    apply Model.isFinite_sub_of_abs_toReal_sub_le_posMaxFinite _ _ (by decide)
      (by rw [finite_model]; decide) (by rw [finite_model]; exact FlushToZero.finite_flush x hx)
    change |real (1 : Float32)-real (FlushToZero.flush x)| ≤ _
    apply le_trans _ (Float32Bounds.ceiling_max (1 : Float32) (by decide))
    rw [real_one, abs_of_nonneg hd.1]
    exact hd.2
  have hr : 0 ≤ real ((1 : Float32)-FlushToZero.flush x) ∧ real ((1 : Float32)-FlushToZero.flush x) ≤ 1 := by
    have hs := Model.toReal_sub_eq_roundAt (model (1 : Float32)) (model (FlushToZero.flush x)) (by decide)
      (by rw [finite_model]; decide) (by rw [finite_model]; exact FlushToZero.finite_flush x hx)
      (by rw [← Float32Bounds.sub_model _ _ (by decide) (FlushToZero.finite_flush x hx), finite_model]; exact hf)
    rw [← Float32Bounds.sub_model _ _ (by decide) (FlushToZero.finite_flush x hx)] at hs
    change real ((1 : Float32)-FlushToZero.flush x) = _ at hs
    rw [hs]
    change 0 ≤ Model.roundAt FloatFormat.binary32 (real (1 : Float32)-real (FlushToZero.flush x)) ∧
      Model.roundAt FloatFormat.binary32 (real (1 : Float32)-real (FlushToZero.flush x)) ≤ 1
    rw [real_one]
    exact rounded_interval _ hd
  refine ⟨by simpa only [FlushToZero.flush_one] using hf, ?_, ?_⟩
  · simpa only [Arithmetic.sub, FlushToZero.flush_one] using FlushToZero.finite_flush _ hf
  · simpa only [Arithmetic.sub, FlushToZero.flush_one] using flush_interval _ hr

end Inference.Contracts.Mlx.Float32UnitInterval
