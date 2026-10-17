import kernels.attention.SdpaVector
import contracts.mlx.Float32OverflowMargin

namespace Inference.Kernels.Attention.SdpaExponentRanges
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure Primitive (p : Platform) : Prop where
  nonpositive : ∀ x, x.isFinite = true → real x ≤ 0 →
    (p.exp x).isFinite = true ∧ 0 ≤ real (p.exp x) ∧ real (p.exp x) ≤ 1
  zero : ∀ x, x.isFinite = true → real x = 0 → real (p.exp x) = 1

theorem initial_real : real SdpaVector.initialShift = -Float32OverflowMargin.maximum := by
  rw [real_unpack, Float32OverflowMargin.maximum_value]
  change Model.unpackedToReal (.finite .negative 16777215 104 (by decide)) = _
  norm_num [Model.unpackedToReal_finite, Model.modelSignBit, Formats.Flocq.bpow,
    FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal]

theorem initial_flush : FlushToZero.flush SdpaVector.initialShift = SdpaVector.initialShift := by
  apply FlushToZero.flush_eq_of_threshold_lt
  rw [initial_real, abs_neg, Float32OverflowMargin.maximum_value]
  norm_num [FlushToZero.threshold]

theorem subtraction_real (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (hf : (FlushToZero.flush x - FlushToZero.flush y).isFinite = true) :
    real (FlushToZero.flush x - FlushToZero.flush y) =
      Model.roundAt FloatFormat.binary32 (real (FlushToZero.flush x) - real (FlushToZero.flush y)) := by
  have h := Model.toReal_sub_eq_roundAt (model (FlushToZero.flush x)) (model (FlushToZero.flush y)) (by decide)
    (by rw [finite_model]; exact FlushToZero.finite_flush x hx)
    (by rw [finite_model]; exact FlushToZero.finite_flush y hy)
    (by rw [← Float32Bounds.sub_model _ _ (FlushToZero.finite_flush x hx) (FlushToZero.finite_flush y hy), finite_model]; exact hf)
  rw [← Float32Bounds.sub_model _ _ (FlushToZero.finite_flush x hx) (FlushToZero.finite_flush y hy)] at h
  exact h

theorem diagonal (p : Platform) (primitive : Primitive p) (x : Float32) (hx : x.isFinite = true) :
    ExponentFinite p x x ∧ real (exponential p x x) = 1 := by
  have hf : (FlushToZero.flush x - FlushToZero.flush x).isFinite = true := by
    apply Float32OverflowMargin.sub_finite _ _ (FlushToZero.finite_flush x hx) (FlushToZero.finite_flush x hx)
    rw [sub_self, abs_zero, Float32OverflowMargin.maximum_value]
    positivity
  have hz : real (difference x x) = 0 := by
    have h := FlushToZero.flush_abs_le (FlushToZero.flush x - FlushToZero.flush x)
    rw [subtraction_real x x hx hx hf, sub_self, Model.roundAt_zero, abs_zero] at h
    exact abs_nonpos_iff.mp h
  have hd : (difference x x).isFinite = true := FlushToZero.finite_flush _ hf
  exact ⟨⟨hx, hx, hf, (primitive.nonpositive _ hd hz.le).1⟩, primitive.zero _ hd hz⟩

theorem initial (p : Platform) (primitive : Primitive p) (shift : Float32)
    (hf : shift.isFinite = true) (bound : |real shift| ≤ (2 : ℝ)^(24 : Nat)) :
    ExponentFinite p SdpaVector.initialShift shift ∧
      0 ≤ real (exponential p SdpaVector.initialShift shift) ∧
      real (exponential p SdpaVector.initialShift shift) ≤ 1 := by
  have hb := (FlushToZero.flush_abs_le shift).trans bound
  have hd : (FlushToZero.flush SdpaVector.initialShift - FlushToZero.flush shift).isFinite = true := by
    apply Float32OverflowMargin.sub_finite _ _ (FlushToZero.finite_flush _ SdpaVector.initial_finite)
      (FlushToZero.finite_flush _ hf)
    calc
      _ ≤ |real (FlushToZero.flush SdpaVector.initialShift)| + |real (FlushToZero.flush shift)| := abs_sub _ _
      _ ≤ Float32OverflowMargin.maximum + (2 : ℝ)^(24 : Nat) := by
        rw [initial_flush, initial_real, abs_neg]
        have hm : 0 ≤ Float32OverflowMargin.maximum := by rw [Float32OverflowMargin.maximum_value]; positivity
        rw [abs_of_nonneg hm]
        exact add_le_add_right hb _
      _ ≤ _ := by norm_num
  have hn : real (difference SdpaVector.initialShift shift) ≤ 0 := by
    apply FlushToZero.flush_nonpositive
    rw [subtraction_real _ _ SdpaVector.initial_finite hf hd]
    have h := Model.roundAt_mono FloatFormat.binary32 (show
        real (FlushToZero.flush SdpaVector.initialShift) - real (FlushToZero.flush shift) ≤ 0 from by
      rw [initial_flush, initial_real, Float32OverflowMargin.maximum_value]
      have := (abs_le.mp hb).1
      norm_num at this ⊢
      linarith)
    simpa only [Model.roundAt_zero] using h
  have he := primitive.nonpositive _ (FlushToZero.finite_flush _ hd) hn
  exact ⟨⟨SdpaVector.initial_finite, hf, hd, he.1⟩, he.2⟩

end Inference.Kernels.Attention.SdpaExponentRanges
