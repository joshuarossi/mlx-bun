import kernels.attention.SdpaExponentRanges
import contracts.mlx.FlushOrder
import contracts.mlx.DyadicBounds

namespace Inference.Kernels.Sampling.LogSumExpExponentRanges
open Contracts.Mlx Contracts.Mlx.Numerics Attention.SdpaUpdate
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- The same scalar fast-exp contract used by attention is reused here.
-- Maximum order and flushing are proved, rather than made extra contracts.
-- Flushed comparisons select the shift, so only the flushed order is known.
theorem ordered_flushed (p : Platform) (primitive : Attention.SdpaExponentRanges.Primitive p)
    (x shift : Float32) (hx : x.isFinite = true) (hs : shift.isFinite = true)
    (bx : |real x| ≤ (2 : ℝ)^(24 : Nat)) (bs : |real shift| ≤ (2 : ℝ)^(24 : Nat))
    (order' : real (FlushToZero.flush x) ≤ real (FlushToZero.flush shift)) :
    ExponentFinite p x shift ∧ 0 ≤ real (exponential p x shift) ∧ real (exponential p x shift) ≤ 1 := by
  have cap := DyadicBounds.ceiling_range 1 25 (by decide) (by decide) (by decide)
  have hd := Float32Bounds.sub_range x shift (DyadicBounds.ceiling 1 25) hx hs cap.1 (by
    rw [cap.2]
    have h := add_le_add bx bs
    norm_num at h ⊢
    exact h)
  have hn : real (difference x shift) ≤ 0 := by
    apply FlushToZero.flush_nonpositive
    rw [Attention.SdpaExponentRanges.subtraction_real x shift hx hs hd.1]
    have h := Model.roundAt_mono FloatFormat.binary32 (sub_nonpos.mpr order')
    simpa only [Model.roundAt_zero] using h
  have h := primitive.nonpositive _ (FlushToZero.finite_flush _ hd.1) hn
  exact ⟨⟨hx, hs, hd.1, h.1⟩, h.2⟩

theorem ordered (p : Platform) (primitive : Attention.SdpaExponentRanges.Primitive p)
    (x shift : Float32) (hx : x.isFinite = true) (hs : shift.isFinite = true)
    (bx : |real x| ≤ (2 : ℝ)^(24 : Nat)) (bs : |real shift| ≤ (2 : ℝ)^(24 : Nat))
    (order : real x ≤ real shift) :
    ExponentFinite p x shift ∧ 0 ≤ real (exponential p x shift) ∧ real (exponential p x shift) ≤ 1 :=
  ordered_flushed p primitive x shift hx hs bx bs (FlushOrder.monotone x shift hx hs order)


theorem equal_real (p : Platform) (primitive : Attention.SdpaExponentRanges.Primitive p)
    (x shift : Float32) (hx : x.isFinite = true) (hs : shift.isFinite = true)
    (bx : |real x| ≤ (2 : ℝ)^(24 : Nat)) (bs : |real shift| ≤ (2 : ℝ)^(24 : Nat))
    (same : real x = real shift) : real (exponential p x shift) = 1 := by
  have h := ordered p primitive x shift hx hs bx bs same.le
  have eq : real (FlushToZero.flush x) = real (FlushToZero.flush shift) :=
    le_antisymm (FlushOrder.monotone x shift hx hs same.le) (FlushOrder.monotone shift x hs hx same.ge)
  have hz : real (difference x shift) = 0 := by
    apply FlushedIdentities.flush_zero
    rw [Attention.SdpaExponentRanges.subtraction_real x shift hx hs h.1.difference, eq,
      sub_self, Model.roundAt_zero]
  exact primitive.zero _ (FlushToZero.finite_flush _ h.1.difference) hz

def negativeInfinity : Float32 := Float32.ofBits 0xff800000
theorem negative_infinity_unpack : negativeInfinity.toModel.unpack = .infinity .negative := rfl
theorem negative_infinity_flush : FlushToZero.flush negativeInfinity = negativeInfinity := by decide +kernel

theorem negative_infinity_sub (shift : Float32) (hs : shift.isFinite = true) :
    negativeInfinity - shift = negativeInfinity := by
  cases hu : shift.toModel.unpack with
  | notANumber => simp [Float32.isFinite, Float32.Model.isFinite, hu, Float.Model.UnpackedFloat.isFinite] at hs
  | infinity s => simp [Float32.isFinite, Float32.Model.isFinite, hu, Float.Model.UnpackedFloat.isFinite] at hs
  | zero s =>
    change Float32.ofModel (Float32.Model.pack (Float.Model.UnpackedFloat.sub .binary32
      negativeInfinity.toModel.unpack shift.toModel.unpack)) = negativeInfinity
    rw [negative_infinity_unpack, hu]
    cases s <;> rfl
  | finite s m e hm =>
    change Float32.ofModel (Float32.Model.pack (Float.Model.UnpackedFloat.sub .binary32
      negativeInfinity.toModel.unpack shift.toModel.unpack)) = negativeInfinity
    rw [negative_infinity_unpack, hu]
    cases s <;> rfl

theorem padded_difference (shift : Float32) (hs : shift.isFinite = true) :
    difference negativeInfinity shift = negativeInfinity := by
  unfold difference Arithmetic.sub
  rw [negative_infinity_flush, negative_infinity_sub _ (FlushToZero.finite_flush shift hs), negative_infinity_flush]

structure PaddingPrimitive (p : Platform) : Prop where
  finite : (p.exp negativeInfinity).isFinite = true
  zero : real (p.exp negativeInfinity) = 0

theorem padding (p : Platform) (primitive : PaddingPrimitive p) (shift : Float32)
    (hs : shift.isFinite = true) :
    (exponential p negativeInfinity shift).isFinite = true ∧ real (exponential p negativeInfinity shift) = 0 := by
  unfold exponential
  rw [padded_difference shift hs]
  exact ⟨primitive.finite, primitive.zero⟩

end Inference.Kernels.Sampling.LogSumExpExponentRanges
