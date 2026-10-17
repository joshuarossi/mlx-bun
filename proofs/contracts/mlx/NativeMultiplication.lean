import contracts.mlx.Float32Bounds

namespace Inference.Contracts.Mlx.NativeMultiplication
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Float.Model.UnpackedFloat
open Numerics

-- Bridge the actual logical Float32 multiplication, including overflow,
-- to FloatLib's packed IEEE operation before deriving range invariants.
theorem model_mul_eq_unpacked {fmt : FloatFormat} (hfmt : fmt.isIEEE = true)
    (x y : Model fmt) (hx : (Model.toModel x).isFinite = true) (hy : (Model.toModel y).isFinite = true) :
    Model.mul x y = Model.ofModel fmt (mul fmt.toModel (Model.toModel x) (Model.toModel y)) := by
  cases hxm : Model.toModel x <;> cases hym : Model.toModel y <;>
    simp only [hxm, hym, Float.Model.UnpackedFloat.isFinite, Bool.false_eq_true] at hx hy
  case zero.zero sx sy =>
    rw [Model.Proof.mul_eq_spec, Model.Spec.mul, Model.toDyadic?_ieee_eq_model fmt hfmt x,
      Model.toDyadic?_ieee_eq_model fmt hfmt y, hxm, hym]
    cases sx <;> cases sy <;> simp [Model.unpackedToDyadic?, mul, Model.modelSignBit, Model.zero,
      Model.posZero_eq_ofModel_zero, Model.negZero_eq_ofModel_zero,
      FloatFormat.supportsSignedZero_eq_true_of_isIEEE fmt hfmt] <;> rfl
  case zero.finite sx sy my ey hmy =>
    rw [Model.Proof.mul_eq_spec, Model.Spec.mul, Model.toDyadic?_ieee_eq_model fmt hfmt x,
      Model.toDyadic?_ieee_eq_model fmt hfmt y, hxm, hym]
    cases sx <;> cases sy <;> simp [Model.unpackedToDyadic?, mul, Model.modelSignBit, Model.zero,
      Model.posZero_eq_ofModel_zero, Model.negZero_eq_ofModel_zero,
      FloatFormat.supportsSignedZero_eq_true_of_isIEEE fmt hfmt] <;> rfl
  case finite.zero sx mx ex hmx sy =>
    rw [Model.Proof.mul_eq_spec, Model.Spec.mul, Model.toDyadic?_ieee_eq_model fmt hfmt x,
      Model.toDyadic?_ieee_eq_model fmt hfmt y, hxm, hym]
    cases sx <;> cases sy <;> simp [Model.unpackedToDyadic?, mul, Model.modelSignBit, Model.zero,
      Model.posZero_eq_ofModel_zero, Model.negZero_eq_ofModel_zero,
      FloatFormat.supportsSignedZero_eq_true_of_isIEEE fmt hfmt] <;> rfl
  case finite.finite sx mx ex hmx sy my ey hmy =>
    have hle := Model.add_le_targetExponent_totalExponent_mul fmt.toModel hmx hmy
      (Model.le_targetExponent_totalExponent_of_toModel_eq_finite x hxm)
      (Model.le_targetExponent_totalExponent_of_toModel_eq_finite y hym)
    rw [Model.Proof.mul_eq_spec, Model.Spec.mul, Model.toDyadic?_ieee_eq_model fmt hfmt x,
      Model.toDyadic?_ieee_eq_model fmt hfmt y, hxm, hym]
    have hmx0 : (mx == 0) = false := by simp [hmx.ne']
    have hmy0 : (my == 0) = false := by simp [hmy.ne']
    simp only [Model.unpackedToDyadic?, hmx0, hmy0, Bool.false_or, Bool.false_eq_true, ite_false,
      Model.roundDyadic, hfmt, ite_true, Model.ieeeRoundDyadic, mul]
    rw [Model.roundWithAccuracy_exact_eq_round_of_le_targetExponent _ _ _ _ hle]
    cases sx <;> cases sy <;> rfl

theorem float32_model (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) :
    model (x*y) = Model.mul (model x) (model y) := by
  change Model.ofFloat32Model (Float32.Model.mul x.toModel y.toModel) = _
  rw [Float32.Model.mul, Model.ofFloat32Model_pack]
  have h := model_mul_eq_unpacked (fmt := FloatFormat.binary32) (by decide) (model x) (model y)
    (by simpa only [model, Model.toModel_ofFloat32Model, Float32.isFinite, Float32.Model.isFinite] using hx)
    (by simpa only [model, Model.toModel_ofFloat32Model, Float32.isFinite, Float32.Model.isFinite] using hy)
  simpa only [model, Model.toModel_ofFloat32Model, show FloatFormat.binary32.toModel = Float.Model.Format.binary32 from rfl] using h.symm

theorem range (x y cap : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) (hc : cap.isFinite = true)
    (bound : |real x| * |real y| ≤ real cap) :
    (FlushToZero.flush x * FlushToZero.flush y).isFinite = true ∧ |real (FlushToZero.mul x y)| ≤ real cap := by
  have hxf := FlushToZero.finite_flush x hx
  have hyf := FlushToZero.finite_flush y hy
  have hp := (mul_le_mul (FlushToZero.flush_abs_le x) (FlushToZero.flush_abs_le y) (abs_nonneg _) (abs_nonneg _)).trans bound
  have hf : (FlushToZero.flush x * FlushToZero.flush y).isFinite = true := by
    rw [← finite_model, float32_model _ _ hxf hyf]
    apply Model.isFinite_mul_of_abs_mul_le_posMaxFinite _ _ (by decide)
      (by rw [finite_model]; exact hxf) (by rw [finite_model]; exact hyf)
    exact hp.trans (Float32Bounds.ceiling_max cap hc)
  refine ⟨hf, (FlushToZero.flush_abs_le _).trans ?_⟩
  rw [Numerics.mul_real _ _ hf]
  apply Float32Bounds.rounded_bound cap hc
  simpa only [abs_mul] using hp

end Inference.Contracts.Mlx.NativeMultiplication
