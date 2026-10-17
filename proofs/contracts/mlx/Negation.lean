import contracts.mlx.BFloat16
import FloatLib.Floats.Formats.IEEE754.Native.AddSub

namespace Inference.Contracts.Mlx.Negation
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Finite binary32 negation flips the sign exactly, including signed zero.
theorem execution (x : Float32) (hx : x.isFinite = true) :
    -x = Float32.ofModel (Model.toFloat32Model (Model.neg (model x))) := by
  change Float32.ofModel (Float32.Model.pack (Float.Model.UnpackedFloat.neg x.toModel.unpack)) =
    Float32.ofModel (Float32.Model.pack (Model.toModel (Model.neg (model x))))
  rw [Model.toModel_neg_of_isFinite (by decide) (model x)
    (by simpa only [model, Model.toModel_ofFloat32Model, Float32.isFinite, Float32.Model.isFinite] using hx)]
  rfl

theorem real_neg (x : Float32) (hx : x.isFinite = true) : real (-x) = -real x := by
  rw [execution x hx, BFloat16.bridge, Model.toReal_neg _ (by rw [finite_model]; exact hx)]
  rfl

theorem finite_neg (x : Float32) (hx : x.isFinite = true) : (-x).isFinite = true := by
  rw [execution x hx]
  change (Model.toFloat32Model (Model.neg (model x))).unpack.isFinite = true
  rw [Model.unpack_toFloat32Model, Model.isFinite_toModel (by decide), Model.isFinite_neg, finite_model]
  exact hx

end Inference.Contracts.Mlx.Negation
