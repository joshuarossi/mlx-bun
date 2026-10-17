import kernels.StableSigmoid
import contracts.mlx.Float32UnitInterval
import contracts.mlx.Float32OverflowMargin

namespace Inference.Kernels.StableSigmoidRanges
open Contracts.Mlx Contracts.Mlx.Numerics StableSigmoid
open FloatLib.Floats.Formats.BinaryInterchange

-- Scalar exp behavior remains an explicit platform obligation: a finite
-- result or +inf. In the overflow case the source sigmoid evaluates exactly
-- to zero or one; 1+e cannot overflow under nearest-even rounding.
structure ExponentialRange (expAbs : Float32 → Float32) : Prop where
  result : ∀ x, x.isFinite = true → (expAbs x).isFinite = true ∨ expAbs x = Float32.inf

theorem finite_branch (expAbs : Float32 → Float32) (error : Float32 → ℝ)
    (exponential : ExpContract expAbs error) (x : Float32) (hx : x.isFinite = true)
    (he' : (expAbs x).isFinite = true) :
    StableSigmoid.Finite expAbs x ∧ (value expAbs x).isFinite = true ∧
      (0 ≤ real (value expAbs x) ∧ real (value expAbs x) ≤ 1) := by
  have hn := exponential.nonnegative x hx he'
  have hf := FlushToZero.finite_flush _ he'
  have hd' : ((1 : Float32)+FlushToZero.flush (expAbs x)).isFinite = true := by
    rw [← finite_model, Float32Bounds.add_model _ _ (by decide) hf]
    apply Float32OverflowMargin.add_finite _ _ (by rw [finite_model]; decide) (by rw [finite_model]; exact hf)
    change |real (1 : Float32)+real (FlushToZero.flush (expAbs x))| ≤ _
    have hm := Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite (model (FlushToZero.flush (expAbs x)))
      (by decide) (by rw [finite_model]; exact hf)
    change |real (FlushToZero.flush (expAbs x))| ≤ Float32OverflowMargin.maximum at hm
    have hz := FlushToZero.flush_nonnegative _ hn
    rw [real_one, abs_of_nonneg (by linarith)]
    rw [abs_of_nonneg hz] at hm
    have ht : (1 : ℝ) ≤ (2 : ℝ)^(100 : Int) := one_le_zpow₀ (by norm_num) (by norm_num)
    linarith
  have hden : (denominator expAbs x).isFinite = true := by
    unfold denominator FlushToZero.add; rw [FlushToZero.flush_one]; exact FlushToZero.finite_flush _ hd'
  have lower : 1 ≤ real (denominator expAbs x) :=
    FlushToZero.add_one_ge_one _ he' hn hd'
  have hq := Float32UnitInterval.reciprocal (denominator expAbs x) hden lower
  have hs := Float32UnitInterval.complement (quotient expAbs x) hq.2.1 hq.2.2
  refine ⟨⟨hx, he', hd', hq.1, fun _ => hs.1⟩, ?_, ?_⟩
  · unfold value
    split
    · exact hq.2.1
    · exact hs.2.1
  · unfold value
    split
    · exact hq.2.2
    · exact hs.2.2

theorem ranges (expAbs : Float32 → Float32) (error : Float32 → ℝ)
    (exponential : ExpContract expAbs error) (range : ExponentialRange expAbs)
    (x : Float32) (hx : x.isFinite = true) :
    Valid expAbs x ∧ (value expAbs x).isFinite = true ∧ (0 ≤ real (value expAbs x) ∧ real (value expAbs x) ≤ 1) := by
  rcases range.result x hx with he | he
  · have h := finite_branch expAbs error exponential x hx he
    exact ⟨Or.inl h.1, h.2⟩
  · refine ⟨Or.inr he, ?_, ?_⟩
    · rw [value_overflow expAbs x he]
      split <;> decide +kernel
    · rw [value_overflow expAbs x he]
      split
      · rw [real_zero]; norm_num
      · rw [real_one]; norm_num

end Inference.Kernels.StableSigmoidRanges
