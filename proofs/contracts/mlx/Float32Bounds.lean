import contracts.mlx.Arithmetic
import FloatLib.Floats.Formats.IEEE754.Native.AddSub

namespace Inference.Contracts.Mlx.Float32Bounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Numerics

theorem add_model (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) :
    model (x+y) = Model.add (model x) (model y) := by
  change Model.ofFloat32Model (Float32.Model.add x.toModel y.toModel) = _
  rw [Float32.Model.add, Model.ofFloat32Model_pack]
  have h := Model.add_eq_ofModel_add_of_isFinite (fmt := FloatFormat.binary32) (by decide) (model x) (model y)
    (by simpa only [model, Model.toModel_ofFloat32Model, Float32.isFinite, Float32.Model.isFinite] using hx)
    (by simpa only [model, Model.toModel_ofFloat32Model, Float32.isFinite, Float32.Model.isFinite] using hy)
  simpa only [model, Model.toModel_ofFloat32Model, show FloatFormat.binary32.toModel = Float.Model.Format.binary32 from rfl] using h.symm
theorem sub_model (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) :
    model (x-y) = Model.sub (model x) (model y) := by
  change Model.ofFloat32Model (Float32.Model.sub x.toModel y.toModel) = _
  rw [Float32.Model.sub, Model.ofFloat32Model_pack]
  have h := Model.sub_eq_ofModel_sub_of_isFinite (fmt := FloatFormat.binary32) (by decide) (model x) (model y)
    (by simpa only [model, Model.toModel_ofFloat32Model, Float32.isFinite, Float32.Model.isFinite] using hx)
    (by simpa only [model, Model.toModel_ofFloat32Model, Float32.isFinite, Float32.Model.isFinite] using hy)
  simpa only [model, Model.toModel_ofFloat32Model, show FloatFormat.binary32.toModel = Float.Model.Format.binary32 from rfl] using h.symm

theorem rounded_bound (cap : Float32) (hc : cap.isFinite = true) (x : ℝ) (hx : |x| ≤ real cap) :
    |Model.roundAt FloatFormat.binary32 x| ≤ real cap := by
  have he : Model.roundAt FloatFormat.binary32 (real cap) = real cap :=
    Model.roundAt_toReal_eq (model cap) (by rw [finite_model]; exact hc)
  have lo := Model.roundAt_mono FloatFormat.binary32 (abs_le.mp hx).1
  have hi := Model.roundAt_mono FloatFormat.binary32 (abs_le.mp hx).2
  rw [Model.roundAt_neg, he] at lo
  rw [he] at hi
  exact abs_le.mpr ⟨lo, hi⟩
theorem ceiling_max (cap : Float32) (hc : cap.isFinite = true) :
    real cap ≤ Model.toReal (Model.posMaxFinite FloatFormat.binary32) :=
  (le_abs_self _).trans (Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite (model cap) (by decide) (by rw [finite_model]; exact hc))

theorem add_range (x y cap : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) (hc : cap.isFinite = true)
    (bound : |real x| + |real y| ≤ real cap) :
    (FlushToZero.flush x + FlushToZero.flush y).isFinite = true ∧ |real (FlushToZero.add x y)| ≤ real cap := by
  have hxf := FlushToZero.finite_flush x hx
  have hyf := FlushToZero.finite_flush y hy
  have hp := (add_le_add (FlushToZero.flush_abs_le x) (FlushToZero.flush_abs_le y)).trans bound
  have hf : (FlushToZero.flush x + FlushToZero.flush y).isFinite = true := by
    rw [← finite_model, add_model _ _ hxf hyf]
    apply Model.isFinite_add_of_abs_add_le_posMaxFinite _ _ (by decide)
      (by rw [finite_model]; exact hxf) (by rw [finite_model]; exact hyf)
    exact hp.trans (ceiling_max cap hc)
  refine ⟨hf, (FlushToZero.flush_abs_le _).trans ?_⟩
  rw [Numerics.add_real _ _ hxf hyf hf]
  exact rounded_bound cap hc _ ((abs_add_le _ _).trans hp)

theorem sub_range (x y cap : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) (hc : cap.isFinite = true)
    (bound : |real x| + |real y| ≤ real cap) :
    (FlushToZero.flush x - FlushToZero.flush y).isFinite = true ∧ |real (Arithmetic.sub x y)| ≤ real cap := by
  have hxf := FlushToZero.finite_flush x hx
  have hyf := FlushToZero.finite_flush y hy
  have hp := (add_le_add (FlushToZero.flush_abs_le x) (FlushToZero.flush_abs_le y)).trans bound
  have hf : (FlushToZero.flush x - FlushToZero.flush y).isFinite = true := by
    rw [← finite_model, sub_model _ _ hxf hyf]
    apply Model.isFinite_sub_of_abs_toReal_sub_le_posMaxFinite _ _ (by decide)
      (by rw [finite_model]; exact hxf) (by rw [finite_model]; exact hyf)
    exact ((abs_sub _ _).trans hp).trans (ceiling_max cap hc)
  refine ⟨hf, (FlushToZero.flush_abs_le _).trans ?_⟩
  have hs := Model.toReal_sub_eq_roundAt (model (FlushToZero.flush x)) (model (FlushToZero.flush y)) (by decide)
    (by rw [finite_model]; exact hxf) (by rw [finite_model]; exact hyf)
    (by rw [← sub_model _ _ hxf hyf, finite_model]; exact hf)
  rw [← sub_model _ _ hxf hyf] at hs
  change real (FlushToZero.flush x - FlushToZero.flush y) = _ at hs
  rw [hs]
  exact rounded_bound cap hc _ ((abs_sub _ _).trans hp)

end Inference.Contracts.Mlx.Float32Bounds
