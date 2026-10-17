/-
The three dyadic-addition bridge lemmas below are adapted from FloatLib's
Arithmetic/LeanModel/AddSub.lean. They are private upstream; here they also
apply to the exact, unrounded product used by fused multiply-add.

MIT License

Copyright (c) 2026 FloatLib

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-/
import contracts.mlx.NativeMultiplication

namespace Inference.Contracts.Mlx.NativeFma
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Float.Model.UnpackedFloat
open Model

private theorem round_natAbs_eq_normalize (spec : Float.Model.Format)
    (mantissa exponent : Int) :
    Float.Model.UnpackedFloat.round spec (modelSign (mantissa < 0))
        mantissa.natAbs exponent =
      Float.Model.UnpackedFloat.normalize spec mantissa exponent .positive := by
  unfold Float.Model.UnpackedFloat.normalize
  split <;> rename_i hcompare
  · have hnegative := Int.compare_eq_lt.mp hcompare
    have habs : mantissa.natAbs = (-mantissa).toNat := by omega
    simp [modelSign, hnegative, habs]
  · have hzero := Int.compare_eq_eq.mp hcompare
    subst mantissa
    simp [modelSign]
  · have hpositive := Int.compare_eq_gt.mp hcompare
    have habs : mantissa.natAbs = mantissa.toNat := by omega
    simp [modelSign, not_lt.mpr hpositive.le, habs]

private theorem round_addFields_eq_normalize
    (fmt : FloatFormat) (hfmt : fmt.isIEEE = true)
    (sign₁ sign₂ : Bool) (mantissa₁ mantissa₂ : Nat) (exponent : Int)
    (hmantissa₁ : 0 < mantissa₁) (hmantissa₂ : 0 < mantissa₂) :
    roundDyadic fmt
        (FloatLib.Numerics.Dyadic.addFields
          sign₁ mantissa₁ exponent sign₂ mantissa₂ exponent) =
      ofModel fmt
        (Float.Model.UnpackedFloat.normalize (FloatFormat.toModel fmt)
          ((modelSign sign₁).apply mantissa₁ + (modelSign sign₂).apply mantissa₂)
          exponent .positive) := by
  unfold FloatLib.Numerics.Dyadic.addFields
  simp only [beq_iff_eq, hmantissa₁.ne', hmantissa₂.ne', ite_false,
    le_refl, ite_true, sub_self, Int.toNat_zero]
  cases sign₁ <;> cases sign₂ <;>
    simp only [Bool.false_eq_true, eq_self, ite_false, ite_true,
      modelSign_false, modelSign_true, Sign.apply]
  all_goals
    split_ifs with hzero
    · simp only [roundDyadic, hfmt, ite_true, ieeeRoundDyadic,
        Bool.false_and, Bool.true_and, modelSign_false, modelSign_true,
        round_exact_zero]
      simp_all [Float.Model.UnpackedFloat.normalize]
      all_goals omega
    · simp only [roundDyadic, hfmt, ite_true, ieeeRoundDyadic]
      rw [← round_natAbs_eq_normalize]
      rfl

private theorem round_addDyadic_eq_ofModel_add_finite
    (fmt : FloatFormat) (hfmt : fmt.isIEEE = true)
    (sign₁ sign₂ : Sign) (mantissa₁ mantissa₂ : Nat) (exponent₁ exponent₂ : Int)
    (hmantissa₁ : 0 < mantissa₁) (hmantissa₂ : 0 < mantissa₂) :
    roundDyadic fmt
        (addDyadic
          ⟨modelSignBit sign₁, mantissa₁, exponent₁⟩
          ⟨modelSignBit sign₂, mantissa₂, exponent₂⟩) =
      ofModel fmt
        (Float.Model.UnpackedFloat.add (FloatFormat.toModel fmt)
          (.finite sign₁ mantissa₁ exponent₁ hmantissa₁)
          (.finite sign₂ mantissa₂ exponent₂ hmantissa₂)) := by
  have hsign (sign : Sign) : modelSign (modelSignBit sign) = sign := by
    cases sign <;> rfl
  by_cases hexponents : exponent₁ ≤ exponent₂
  · rw [addDyadic, FloatLib.Numerics.Dyadic.add_align_right_to_left_exponent
      _ _ _ _ _ _ hmantissa₁.ne' hmantissa₂.ne' hexponents]
    have hshifted : 0 < mantissa₂ <<< (exponent₂ - exponent₁).toNat :=
      Nat.shiftLeft_pos_iff.mpr hmantissa₂
    simpa only [FloatLib.Numerics.Dyadic.add, Float.Model.UnpackedFloat.add,
      min_eq_left hexponents, Float.Model.UnpackedFloat.decreaseExponent,
      sub_self, Int.toNat_zero, Nat.shiftLeft_eq', Nat.shiftLeft_zero, hsign] using
      round_addFields_eq_normalize fmt hfmt (modelSignBit sign₁) (modelSignBit sign₂)
        mantissa₁ (mantissa₂ <<< (exponent₂ - exponent₁).toNat) exponent₁
        hmantissa₁ hshifted
  · have hlt : exponent₂ < exponent₁ := lt_of_not_ge hexponents
    rw [addDyadic, FloatLib.Numerics.Dyadic.add_align_left_to_right_exponent
      _ _ _ _ _ _ hmantissa₁.ne' hmantissa₂.ne' hlt]
    have hshifted : 0 < mantissa₁ <<< (exponent₁ - exponent₂).toNat :=
      Nat.shiftLeft_pos_iff.mpr hmantissa₁
    simpa only [FloatLib.Numerics.Dyadic.add, Float.Model.UnpackedFloat.add,
      min_eq_right hlt.le, Float.Model.UnpackedFloat.decreaseExponent,
      sub_self, Int.toNat_zero, Nat.shiftLeft_eq', Nat.shiftLeft_zero, hsign] using
      round_addFields_eq_normalize fmt hfmt (modelSignBit sign₁) (modelSignBit sign₂)
        (mantissa₁ <<< (exponent₁ - exponent₂).toNat) mantissa₂ exponent₂
        hshifted hmantissa₂


theorem finite (x y z cap : Float32)
    (hx : x.isFinite = true) (hy : y.isFinite = true) (hz : z.isFinite = true) (hc : cap.isFinite = true)
    (bound : |Numerics.real x| * |Numerics.real y| + |Numerics.real z| ≤ Numerics.real cap) :
    (Float32.fma x y z).isFinite = true := by
  have hx' := hx
  have hy' := hy
  have hz' := hz
  rw [← Numerics.finite_model]
  change Model.isFinite (Model.ofModel FloatFormat.binary32
    (Float.Model.UnpackedFloat.fma Float.Model.Format.binary32 x.toModel.unpack y.toModel.unpack z.toModel.unpack)) = true
  have hb := bound.trans (Float32Bounds.ceiling_max cap hc)
  rw [Numerics.real_unpack x, Numerics.real_unpack y, Numerics.real_unpack z] at hb
  cases hux : x.toModel.unpack <;> cases huy : y.toModel.unpack <;> cases huz : z.toModel.unpack <;>
    simp only [Float32.isFinite, Float32.Model.isFinite, hux, huy, huz,
      Float.Model.UnpackedFloat.isFinite, Bool.false_eq_true] at hx' hy' hz'
  case zero.zero.zero s₁ s₂ s₃ =>
    simp only [Float.Model.UnpackedFloat.fma]
    split <;> exact Model.isFinite_ofModel_zero _ (by decide) _
  case zero.finite.zero s₁ s₂ m₂ e₂ hm₂ s₃ =>
    simp only [Float.Model.UnpackedFloat.fma]
    split <;> exact Model.isFinite_ofModel_zero _ (by decide) _
  case finite.zero.zero s₁ m₁ e₁ hm₁ s₂ s₃ =>
    simp only [Float.Model.UnpackedFloat.fma]
    split <;> exact Model.isFinite_ofModel_zero _ (by decide) _
  case zero.zero.finite s₁ s₂ s₃ m₃ e₃ hm₃ =>
    simp only [Float.Model.UnpackedFloat.fma]
    rw [← huz, Numerics.repack, Numerics.finite_model]
    exact hz
  case zero.finite.finite s₁ s₂ m₂ e₂ hm₂ s₃ m₃ e₃ hm₃ =>
    simp only [Float.Model.UnpackedFloat.fma]
    rw [← huz, Numerics.repack, Numerics.finite_model]
    exact hz
  case finite.zero.finite s₁ m₁ e₁ hm₁ s₂ s₃ m₃ e₃ hm₃ =>
    simp only [Float.Model.UnpackedFloat.fma]
    rw [← huz, Numerics.repack, Numerics.finite_model]
    exact hz
  case finite.finite.zero s₁ m₁ e₁ hm₁ s₂ m₂ e₂ hm₂ s₃ =>
    have hzero : Numerics.real z = 0 := by rw [Numerics.real_unpack, huz, Model.unpackedToReal_zero]
    have hmul : (x*y).isFinite = true := by
      rw [← Numerics.finite_model, NativeMultiplication.float32_model x y hx hy]
      apply Model.isFinite_mul_of_abs_mul_le_posMaxFinite _ _ (by decide)
        (by rw [Numerics.finite_model]; exact hx) (by rw [Numerics.finite_model]; exact hy)
      change |Numerics.real x| * |Numerics.real y| ≤ _
      apply le_trans ?_ (Float32Bounds.ceiling_max cap hc)
      simpa only [hzero, abs_zero, add_zero] using bound
    rw [← Numerics.finite_model] at hmul
    change Model.isFinite (Model.ofModel FloatFormat.binary32
      (Float.Model.UnpackedFloat.mul Float.Model.Format.binary32 x.toModel.unpack y.toModel.unpack)) = true at hmul
    simpa only [hux, huy, Float.Model.UnpackedFloat.mul, Float.Model.UnpackedFloat.fma] using hmul
  case finite.finite.finite s₁ m₁ e₁ hm₁ s₂ m₂ e₂ hm₂ s₃ m₃ e₃ hm₃ =>
    change Model.isFinite (Model.ofModel FloatFormat.binary32
      (Float.Model.UnpackedFloat.add FloatFormat.binary32.toModel
        (.finite (s₁*s₂) (m₁*m₂) (e₁+e₂) (Nat.mul_pos hm₁ hm₂)) (.finite s₃ m₃ e₃ hm₃))) = true
    rw [← round_addDyadic_eq_ofModel_add_finite FloatFormat.binary32 (by decide)]
    apply Model.isFinite_roundDyadic_of_isIEEE_of_abs_toReal_le_posMaxFinite _ (by decide)
    rw [Dyadic.toReal_addDyadic]
    have hproduct : (FloatLib.Numerics.Dyadic.mk (Model.modelSignBit (s₁*s₂)) (m₁*m₂) (e₁+e₂)).toReal =
        Model.unpackedToReal (.finite s₁ m₁ e₁ hm₁) * Model.unpackedToReal (.finite s₂ m₂ e₂ hm₂) := by
      cases s₁ <;> cases s₂ <;>
        norm_num [FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand,
          Model.unpackedToReal_finite, Model.modelSignBit,
          Formats.Flocq.bpow, FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal,
          zpow_add₀] <;> ring
    rw [hproduct]
    change |Model.unpackedToReal (.finite s₁ m₁ e₁ hm₁) * Model.unpackedToReal (.finite s₂ m₂ e₂ hm₂) +
      Model.unpackedToReal (.finite s₃ m₃ e₃ hm₃)| ≤ _
    exact (abs_add_le _ _).trans (by simpa only [abs_mul, hux, huy, huz] using hb)

theorem range (x y z cap : Float32)
    (hx : x.isFinite = true) (hy : y.isFinite = true) (hz : z.isFinite = true) (hc : cap.isFinite = true)
    (bound : |Numerics.real x| * |Numerics.real y| + |Numerics.real z| ≤ Numerics.real cap) :
    (Float32.fma (FlushToZero.flush x) (FlushToZero.flush y) (FlushToZero.flush z)).isFinite = true ∧
      |Numerics.real (FlushToZero.fma x y z)| ≤ Numerics.real cap := by
  have hxf := FlushToZero.finite_flush x hx
  have hyf := FlushToZero.finite_flush y hy
  have hzf := FlushToZero.finite_flush z hz
  have hp := (add_le_add (mul_le_mul (FlushToZero.flush_abs_le x) (FlushToZero.flush_abs_le y)
    (abs_nonneg _) (abs_nonneg _)) (FlushToZero.flush_abs_le z)).trans bound
  have hf := finite _ _ _ cap hxf hyf hzf hc hp
  refine ⟨hf, (FlushToZero.flush_abs_le _).trans ?_⟩
  rw [Numerics.fma_real _ _ _ hxf hyf hzf hf]
  apply Float32Bounds.rounded_bound cap hc
  exact (abs_add_le _ _).trans (by simpa only [abs_mul] using hp)

end Inference.Contracts.Mlx.NativeFma
