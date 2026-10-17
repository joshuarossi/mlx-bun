import contracts.mlx.BFloat16Bounds
import contracts.mlx.BFloat16

namespace Inference.Contracts.Mlx.BFloat16ConversionBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange Numerics

theorem narrow_finite (x : Float32) (hx : x.isFinite = true)
    (bound : |real x| ≤ Model.toReal (Model.posMaxFinite FloatFormat.bfloat16)) :
    Model.isFinite (BFloat16.narrow x) = true := by
  have hf : Model.isFinite (model x) = true := by rw [finite_model]; exact hx
  have hn := Model.isNaN_eq_false_of_isFinite_eq_true (model x) hf
  have hi := Model.isInf_eq_false_of_isFinite_eq_true (model x) hf
  obtain ⟨d, hd⟩ := Model.exists_toDyadic?_of_isFinite hf
  have hcast : BFloat16.narrow x = Model.roundDyadic FloatFormat.bfloat16 d := by
    simp [BFloat16.narrow, Model.cast, hn, hi, hd,
      show FloatFormat.binary32 ≠ FloatFormat.bfloat16 from by decide,
      show ¬FloatFormat.binary32.fracWidth ≤ FloatFormat.bfloat16.fracWidth from by decide]
  rw [hcast]
  apply Model.isFinite_roundDyadic_of_isIEEE_of_abs_toReal_le_posMaxFinite _ (by decide)
  simpa only [real, Model.toReal_eq, hd] using bound

theorem narrow_range (x : Float32) (cap : Model FloatFormat.bfloat16)
    (hx : x.isFinite = true) (hc : Model.isFinite cap = true) (bound : |real x| ≤ Model.toReal cap) :
    Model.isFinite (BFloat16.narrow x) = true ∧ |Model.toReal (BFloat16.narrow x)| ≤ Model.toReal cap := by
  have hf := narrow_finite x hx (bound.trans (BFloat16Bounds.ceiling_max cap hc))
  refine ⟨hf, ?_⟩
  rw [show Model.toReal (BFloat16.narrow x) = Model.roundAt FloatFormat.bfloat16 (real x) from
    Model.cast_eq_roundAt (by decide) (by decide) (model x) (by rw [finite_model]; exact hx) hf]
  exact BFloat16Bounds.rounded_bound cap hc _ bound

end Inference.Contracts.Mlx.BFloat16ConversionBounds
