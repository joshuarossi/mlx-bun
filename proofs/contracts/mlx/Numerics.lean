import FloatLib.Floats.Formats.BinaryInterchange.Analysis.StandardModel
import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.LeanModel.MulDiv
import FloatLib.Floats.Formats.IEEE754.Native.Model

namespace Inference.Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Float.Model.UnpackedFloat

/- Binary32 operations are connected to independent real-valued nearest-even
   rounding and half-ULP error bounds, including gradual underflow and signed
   zero. Finiteness hypotheses exclude overflow and NaNs from real semantics.
   These are proofs about Lean's logical operations. Hardware/compiler
   conformance to those operations is a separate platform obligation. -/

theorem fma_nonzero_real (fmt : FloatFormat) (hfmt : fmt.isIEEE = true)
    (s₁ s₂ s₃ : Sign) (m₁ m₂ m₃ : Nat) (e₁ e₂ e₃ : Int)
    (hm₁ : 0<m₁) (hm₂ : 0<m₂) (hm₃ : 0<m₃)
    (hfinite : Model.isFinite (Model.ofModel fmt (fma (FloatFormat.toModel fmt)
      (.finite s₁ m₁ e₁ hm₁) (.finite s₂ m₂ e₂ hm₂) (.finite s₃ m₃ e₃ hm₃))) = true) :
    Model.toReal (Model.ofModel fmt (fma (FloatFormat.toModel fmt)
      (.finite s₁ m₁ e₁ hm₁) (.finite s₂ m₂ e₂ hm₂) (.finite s₃ m₃ e₃ hm₃))) =
      Model.roundAt fmt (Model.unpackedToReal (.finite s₁ m₁ e₁ hm₁) *
        Model.unpackedToReal (.finite s₂ m₂ e₂ hm₂) + Model.unpackedToReal (.finite s₃ m₃ e₃ hm₃)) := by
  change Model.toReal (Model.ofModel fmt (add (FloatFormat.toModel fmt)
    (.finite (s₁*s₂) (m₁*m₂) (e₁+e₂) (Nat.mul_pos hm₁ hm₂)) (.finite s₃ m₃ e₃ hm₃))) = _
  rw [Model.toReal_ofModel_add_finite_eq_roundAt fmt hfmt (s₁*s₂) s₃ (m₁*m₂) m₃ (e₁+e₂) e₃
    (Nat.mul_pos hm₁ hm₂) hm₃ hfinite]
  congr 2
  rw [Model.unpackedToReal_finite, Model.unpackedToReal_finite, Model.unpackedToReal_finite,
    Nat.cast_mul, Formats.Flocq.bpow.add_exp]
  cases s₁ <;> cases s₂ <;> simp [Model.modelSignBit] <;> ring


def model (x : Float32) := Model.ofFloat32Model x.toModel
noncomputable def real (x : Float32) : ℝ := Model.toReal (model x)

theorem real_unpack (x : Float32) : real x = Model.unpackedToReal x.toModel.unpack := by
  exact Model.toReal_eq_unpackedToReal_toModel (by decide) (model x)

theorem finite_model (x : Float32) : Model.isFinite (model x) = x.isFinite := by
  rw [← Model.isFinite_toModel (by decide)]
  rfl

theorem repack (x : Float32) : Model.ofModel FloatFormat.binary32 x.toModel.unpack = model x := by
  exact Model.canonicalizeModel_eq_self (model x) (Model.isModelCanonical_ofFloat32Model x.toModel)

theorem mul_real (x y : Float32) (hout : (x*y).isFinite=true) :
    real (x*y) = Model.roundAt FloatFormat.binary32 (real x*real y) := by
  exact Model.toReal_ofModel_mul_toModel_eq_roundAt (by decide) (model x) (model y)
    (by change Model.isFinite (model (x*y))=true; rw [finite_model]; exact hout)

theorem div_real (x y : Float32) (hy : y.isFinite=true) (hout : (x/y).isFinite=true) :
    real (x/y) = Model.roundAt FloatFormat.binary32 (real x / real y) := by
  exact Model.toReal_ofModel_div_toModel_eq_roundAt (by decide) (model x) (model y)
    (by rw [finite_model]; exact hy)
    (by change Model.isFinite (model (x/y))=true; rw [finite_model]; exact hout)

theorem real_one : real (1 : Float32) = 1 := by
  rw [real_unpack]
  change Model.unpackedToReal (.finite .positive 8388608 (-23) (by decide)) = 1
  rw [Model.unpackedToReal_finite]
  norm_num [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow]
  change 8388608 * ((2 : ℝ)^23)⁻¹ = 1
  norm_num


theorem fma_real (x y z : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true) (hz : z.isFinite=true)
    (hout : (Float32.fma x y z).isFinite=true) :
    real (Float32.fma x y z) = Model.roundAt FloatFormat.binary32 (real x*real y+real z) := by
  have hf : Model.isFinite (model (Float32.fma x y z))=true := by rw [finite_model]; exact hout
  change Model.isFinite (Model.ofModel FloatFormat.binary32
    (fma Float.Model.Format.binary32 x.toModel.unpack y.toModel.unpack z.toModel.unpack))=true at hf
  change Model.toReal (Model.ofModel FloatFormat.binary32
    (fma Float.Model.Format.binary32 x.toModel.unpack y.toModel.unpack z.toModel.unpack)) = _
  rw [real_unpack x, real_unpack y, real_unpack z]
  cases hux : x.toModel.unpack <;> cases huy : y.toModel.unpack <;> cases huz : z.toModel.unpack <;>
    simp only [Float32.isFinite, Float32.Model.isFinite, hux, huy, huz,
      Float.Model.UnpackedFloat.isFinite, Bool.false_eq_true] at hx hy hz
  case zero.zero.zero s₁ s₂ s₃ =>
    simp only [fma, Model.unpackedToReal_zero, zero_mul, zero_add, Model.roundAt_zero]
    split <;> exact Model.toReal_ofModel_zero _ (by decide) _
  case zero.finite.zero s₁ s₂ m₂ e₂ hm₂ s₃ =>
    simp only [fma, Model.unpackedToReal_zero, zero_mul, zero_add, Model.roundAt_zero]
    split <;> exact Model.toReal_ofModel_zero _ (by decide) _
  case finite.zero.zero s₁ m₁ e₁ hm₁ s₂ s₃ =>
    simp only [fma, Model.unpackedToReal_zero, mul_zero, zero_add, Model.roundAt_zero]
    split <;> exact Model.toReal_ofModel_zero _ (by decide) _
  case zero.zero.finite s₁ s₂ s₃ m₃ e₃ hm₃ =>
    simp only [fma, Model.unpackedToReal_zero, zero_mul, zero_add]
    rw [← huz, repack, ← real_unpack]
    exact (Model.roundAt_toReal_eq (model z) (by rw [finite_model]; simp only [Float32.isFinite, Float32.Model.isFinite, huz, Float.Model.UnpackedFloat.isFinite])).symm
  case zero.finite.finite s₁ s₂ m₂ e₂ hm₂ s₃ m₃ e₃ hm₃ =>
    simp only [fma, Model.unpackedToReal_zero, zero_mul, zero_add]
    rw [← huz, repack, ← real_unpack]
    exact (Model.roundAt_toReal_eq (model z) (by rw [finite_model]; simp only [Float32.isFinite, Float32.Model.isFinite, huz, Float.Model.UnpackedFloat.isFinite])).symm
  case finite.zero.finite s₁ m₁ e₁ hm₁ s₂ s₃ m₃ e₃ hm₃ =>
    simp only [fma, Model.unpackedToReal_zero, mul_zero, zero_add]
    rw [← huz, repack, ← real_unpack]
    exact (Model.roundAt_toReal_eq (model z) (by rw [finite_model]; simp only [Float32.isFinite, Float32.Model.isFinite, huz, Float.Model.UnpackedFloat.isFinite])).symm
  case finite.finite.zero s₁ m₁ e₁ hm₁ s₂ m₂ e₂ hm₂ s₃ =>
    simp only [Model.unpackedToReal_zero, add_zero]
    have hmul := Model.toReal_ofModel_mul_toModel_eq_roundAt (fmt := FloatFormat.binary32)
      (by decide) (model x) (model y)
    simp only [model, Model.toModel_ofFloat32Model, hux, huy] at hmul
    simp only [hux, huy, huz, fma] at hf
    have hfmt : FloatFormat.binary32.toModel = Float.Model.Format.binary32 := by rfl
    simpa only [fma, mul, hfmt, Model.toReal_eq_unpackedToReal_toModel (fmt := FloatFormat.binary32) (by decide),
      Model.toModel_ofFloat32Model, hux, huy] using hmul hf
  case finite.finite.finite s₁ m₁ e₁ hm₁ s₂ m₂ e₂ hm₂ s₃ m₃ e₃ hm₃ =>
    simp only [hux, huy, huz] at hf
    exact fma_nonzero_real _ (by decide) s₁ s₂ s₃ m₁ m₂ m₃ e₁ e₂ e₃ hm₁ hm₂ hm₃ hf


theorem add_real (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (hout : (x+y).isFinite=true) :
    real (x+y) = Model.roundAt FloatFormat.binary32 (real x+real y) := by
  have hf : Model.isFinite (model (x+y))=true := by rw [finite_model]; exact hout
  change Model.isFinite (Model.ofModel FloatFormat.binary32
    (add Float.Model.Format.binary32 x.toModel.unpack y.toModel.unpack))=true at hf
  change Model.toReal (Model.ofModel FloatFormat.binary32
    (add Float.Model.Format.binary32 x.toModel.unpack y.toModel.unpack)) = _
  rw [real_unpack x, real_unpack y]
  cases hux : x.toModel.unpack <;> cases huy : y.toModel.unpack <;>
    simp only [Float32.isFinite, Float32.Model.isFinite, hux, huy,
      Float.Model.UnpackedFloat.isFinite, Bool.false_eq_true] at hx hy
  case zero.zero s₁ s₂ =>
    cases s₁ <;> cases s₂ <;>
      simp [add, Model.toReal_ofModel_zero FloatFormat.binary32 (by decide)]
  case zero.finite s₁ s₂ m₂ e₂ hm₂ =>
    simp only [add, Model.unpackedToReal_zero, zero_add]
    rw [← huy, repack, ← real_unpack]
    exact (Model.roundAt_toReal_eq (model y)
      (by rw [finite_model]; simp only [Float32.isFinite, Float32.Model.isFinite, huy, Float.Model.UnpackedFloat.isFinite])).symm
  case finite.zero s₁ m₁ e₁ hm₁ s₂ =>
    simp only [add, Model.unpackedToReal_zero, add_zero]
    rw [← hux, repack, ← real_unpack]
    exact (Model.roundAt_toReal_eq (model x)
      (by rw [finite_model]; simp only [Float32.isFinite, Float32.Model.isFinite, hux, Float.Model.UnpackedFloat.isFinite])).symm
  case finite.finite s₁ m₁ e₁ hm₁ s₂ m₂ e₂ hm₂ =>
    simp only [hux, huy] at hf
    exact Model.toReal_ofModel_add_finite_eq_roundAt _ (by decide) s₁ s₂ m₁ m₂ e₁ e₂ hm₁ hm₂ hf

noncomputable abbrev epsilon (x : ℝ) := Model.epsilonAt FloatFormat.binary32 x

theorem mul_error (x y : Float32) (hout : (x*y).isFinite=true) :
    |real (x*y) - real x*real y| ≤ epsilon (real x*real y) := by
  rw [mul_real x y hout]
  exact Model.abs_roundAt_sub_le _ _

theorem div_error (x y : Float32) (hy : y.isFinite=true) (hout : (x/y).isFinite=true) :
    |real (x/y) - real x / real y| ≤ epsilon (real x / real y) := by
  rw [div_real x y hy hout]
  exact Model.abs_roundAt_sub_le _ _

theorem fma_error (x y z : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true) (hz : z.isFinite=true)
    (hout : (Float32.fma x y z).isFinite=true) :
    |real (Float32.fma x y z) - (real x*real y+real z)| ≤ epsilon (real x*real y+real z) := by
  rw [fma_real x y z hx hy hz hout]
  exact Model.abs_roundAt_sub_le _ _

theorem add_error (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (hout : (x+y).isFinite=true) :
    |real (x+y) - (real x+real y)| ≤ epsilon (real x+real y) := by
  rw [add_real x y hx hy hout]
  exact Model.abs_roundAt_sub_le _ _

theorem scaled_fma_error (code scale input acc : Float32)
    (hweight : (code*scale).isFinite=true) (hinput : input.isFinite=true) (hacc : acc.isFinite=true)
    (hout : (Float32.fma (code*scale) input acc).isFinite=true) :
    |real (Float32.fma (code*scale) input acc) - (real code*real scale*real input+real acc)| ≤
      epsilon (real code*real scale) * |real input| + epsilon (real (code*scale)*real input+real acc) := by
  have hmul := mul_error code scale hweight
  have hfma := fma_error (code*scale) input acc hweight hinput hacc hout
  calc
    _ = |(real (Float32.fma (code*scale) input acc) - (real (code*scale)*real input+real acc)) +
        (real (code*scale) - real code*real scale)*real input| := by congr 1; ring
    _ ≤ |real (Float32.fma (code*scale) input acc) - (real (code*scale)*real input+real acc)| +
        |(real (code*scale) - real code*real scale)*real input| := abs_add_le _ _
    _ ≤ epsilon (real code*real scale) * |real input| + epsilon (real (code*scale)*real input+real acc) := by
      rw [abs_mul]
      have hp := mul_le_mul_of_nonneg_right hmul (abs_nonneg (real input))
      linarith

end Inference.Contracts.Mlx.Numerics
