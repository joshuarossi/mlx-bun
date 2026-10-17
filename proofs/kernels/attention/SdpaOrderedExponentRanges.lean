import kernels.attention.SdpaInitialLoopRanges
import contracts.mlx.FlushOrder

namespace Inference.Kernels.Attention.SdpaOrderedExponentRanges
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem ordered (p : Platform) (primitive : SdpaExponentRanges.Primitive p) (x shift : Float32)
    (hx : x.isFinite = true ∧ |real x| ≤ (2 : ℝ)^(24 : Nat))
    (hs : shift.isFinite = true ∧ |real shift| ≤ (2 : ℝ)^(24 : Nat))
    (order : real x ≤ real shift) :
    ExponentFinite p x shift ∧ 0 ≤ real (exponential p x shift) ∧ real (exponential p x shift) ≤ 1 := by
  have finite : (FlushToZero.flush x-FlushToZero.flush shift).isFinite = true := by
    apply Float32OverflowMargin.sub_finite _ _ (FlushToZero.finite_flush _ hx.1) (FlushToZero.finite_flush _ hs.1)
    have bound := (abs_sub (real (FlushToZero.flush x)) (real (FlushToZero.flush shift))).trans
      (add_le_add ((FlushToZero.flush_abs_le x).trans hx.2) ((FlushToZero.flush_abs_le shift).trans hs.2))
    exact bound.trans (by norm_num [Float32OverflowMargin.maximum_value])
  have nonpositive : real (difference x shift) ≤ 0 := by
    apply FlushToZero.flush_nonpositive
    rw [SdpaExponentRanges.subtraction_real x shift hx.1 hs.1 finite]
    have h := Model.roundAt_mono FloatFormat.binary32
      (sub_nonpos.mpr (FlushOrder.monotone x shift hx.1 hs.1 order))
    simpa only [Model.roundAt_zero] using h
  have h := primitive.nonpositive _ (FlushToZero.finite_flush _ finite) nonpositive
  exact ⟨⟨hx.1, hs.1, finite, h.1⟩, h.2⟩

theorem selected (p : SdpaVector.Platform) (maximum : SdpaInitialLoopRanges.Maximum p)
    (primitive : SdpaExponentRanges.Primitive p.merge.scalar) (old score : Float32)
    (ho : old.isFinite = true ∧ |real old| ≤ (2 : ℝ)^(24 : Nat))
    (hs : score.isFinite = true ∧ |real score| ≤ (2 : ℝ)^(24 : Nat)) :
    (p.maximum old score).isFinite = true ∧ |real (p.maximum old score)| ≤ (2 : ℝ)^(24 : Nat) ∧
      (ExponentFinite p.merge.scalar old (p.maximum old score) ∧
        0 ≤ real (exponential p.merge.scalar old (p.maximum old score)) ∧
          real (exponential p.merge.scalar old (p.maximum old score)) ≤ 1) ∧
      (ExponentFinite p.merge.scalar score (p.maximum old score) ∧
        0 ≤ real (exponential p.merge.scalar score (p.maximum old score)) ∧
          real (exponential p.merge.scalar score (p.maximum old score)) ≤ 1) ∧
      (real (exponential p.merge.scalar old (p.maximum old score)) = 1 ∨
        real (exponential p.merge.scalar score (p.maximum old score)) = 1) := by
  have maximumSpec := maximum.pair old score ho.1 hs.1
  have bound : (p.maximum old score).isFinite = true ∧ |real (p.maximum old score)| ≤ (2 : ℝ)^(24 : Nat) := by
    rcases maximumSpec.1 with h | h
    · rwa [h]
    · rwa [h]
  refine ⟨bound.1, bound.2,
    ordered _ primitive old _ ho bound (by rw [maximumSpec.2]; exact le_max_left _ _),
    ordered _ primitive score _ hs bound (by rw [maximumSpec.2]; exact le_max_right _ _), ?_⟩
  rcases maximumSpec.1 with h | h
  · left
    rw [h]
    exact (SdpaExponentRanges.diagonal _ primitive old ho.1).2
  · right
    rw [h]
    exact (SdpaExponentRanges.diagonal _ primitive score hs.1).2

end Inference.Kernels.Attention.SdpaOrderedExponentRanges
