import kernels.StableSigmoid
import contracts.mlx.Float32UnitInterval

namespace Inference.Kernels.StableSigmoidRanges
open Contracts.Mlx Contracts.Mlx.Numerics StableSigmoid

-- Scalar exp behavior remains an explicit platform obligation. In the
-- overflow case the source sigmoid evaluates exactly to zero or one.
structure ExponentialRange (expAbs : Float32 → Float32) where
  ceiling : Float32
  denominatorCap : Float32
  denominatorFinite : denominatorCap.isFinite = true
  headroom : 1 + real ceiling ≤ real denominatorCap
  result : ∀ x, x.isFinite = true →
    ((expAbs x).isFinite = true ∧ |real (expAbs x)| ≤ real ceiling) ∨ expAbs x = Float32.inf

theorem finite_branch (expAbs : Float32 → Float32) (error : Float32 → ℝ)
    (exponential : ExpContract expAbs error) (range : ExponentialRange expAbs)
    (x : Float32) (hx : x.isFinite = true)
    (he : (expAbs x).isFinite = true ∧ |real (expAbs x)| ≤ real range.ceiling) :
    StableSigmoid.Finite expAbs x ∧ (value expAbs x).isFinite = true ∧
      (0 ≤ real (value expAbs x) ∧ real (value expAbs x) ≤ 1) := by
  have hd := Float32Bounds.add_range (1 : Float32) (expAbs x) range.denominatorCap (by decide) he.1
    range.denominatorFinite (by rw [real_one, abs_one]; exact (add_le_add_right he.2 1).trans range.headroom)
  have hd' : ((1 : Float32)+FlushToZero.flush (expAbs x)).isFinite = true := by
    simpa only [FlushToZero.flush_one] using hd.1
  have hden : (denominator expAbs x).isFinite = true := FlushToZero.finite_flush _ hd.1
  have lower : 1 ≤ real (denominator expAbs x) :=
    FlushToZero.add_one_ge_one _ he.1 (exponential.nonnegative x hx he.1) hd'
  have hq := Float32UnitInterval.reciprocal (denominator expAbs x) hden lower
  have hs := Float32UnitInterval.complement (quotient expAbs x) hq.2.1 hq.2.2
  refine ⟨⟨hx, he.1, hd', hq.1, fun _ => hs.1⟩, ?_, ?_⟩
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
  · have h := finite_branch expAbs error exponential range x hx he
    exact ⟨Or.inl h.1, h.2⟩
  · refine ⟨Or.inr he, ?_, ?_⟩
    · rw [value_overflow expAbs x he]
      split <;> decide +kernel
    · rw [value_overflow expAbs x he]
      split
      · rw [real_zero]; norm_num
      · rw [real_one]; norm_num

end Inference.Kernels.StableSigmoidRanges
