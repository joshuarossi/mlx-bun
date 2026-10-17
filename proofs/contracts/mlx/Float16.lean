import contracts.mlx.BFloat16
import FloatLib.Floats.Formats.BinaryInterchange.Analysis.Error

namespace Inference.Contracts.Mlx.Float16
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange Numerics
abbrev Value := Model FloatFormat.binary16

-- Trellis row scales are stored as IEEE binary16, rather than BF16.
-- Every finite binary16 value widens exactly to binary32, including its
-- subnormals. Native load/cast conformance remains an execution binding.
def widen (x : Value) : Float32 :=
  Float32.ofModel (Model.toFloat32Model (Model.cast FloatFormat.binary16 FloatFormat.binary32 x))

theorem maximum_fits : Model.toReal (Model.posMaxFinite FloatFormat.binary16) ≤
    Model.toReal (Model.posMaxFinite FloatFormat.binary32) := by
  have half : Model.toDyadic? (Model.posMaxFinite FloatFormat.binary16) =
      some ⟨false, 2047, 5⟩ := by decide +kernel
  have single : Model.toDyadic? (Model.posMaxFinite FloatFormat.binary32) =
      some ⟨false, 16777215, 104⟩ := by decide +kernel
  rw [Model.toReal_eq, half, Model.toReal_eq, single]
  norm_num [FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand]

theorem cast_finite (x : Value) (hx : Model.isFinite x = true) :
    Model.isFinite (Model.cast FloatFormat.binary16 FloatFormat.binary32 x) = true :=
  Model.isFinite_cast_of_abs_toReal_le_posMaxFinite x (by decide) hx
    ((Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite x (by decide) hx).trans maximum_fits)

theorem widen_finite (x : Value) (hx : Model.isFinite x = true) : (widen x).isFinite = true := by
  change (Model.toFloat32Model (Model.cast FloatFormat.binary16 FloatFormat.binary32 x)).unpack.isFinite = true
  rw [Model.unpack_toFloat32Model, Model.isFinite_toModel (by decide)]
  exact cast_finite x hx

theorem widen_real (x : Value) (hx : Model.isFinite x = true) : real (widen x) = Model.toReal x := by
  unfold widen
  rw [BFloat16.bridge]
  exact Model.cast_exact_of_gridExtension x (by decide) (by decide) (by decide) (by decide) hx (cast_finite x hx)

theorem widen_bound (x : Value) (cap : ℝ) (hx : Model.isFinite x = true ∧ |Model.toReal x| ≤ cap) :
    (widen x).isFinite = true ∧ |real (widen x)| ≤ cap :=
  ⟨widen_finite x hx.1, by rw [widen_real x hx.1]; exact hx.2⟩

end Inference.Contracts.Mlx.Float16
