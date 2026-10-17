import contracts.mlx.BFloat16Fma
import FloatLib.Floats.Formats.BinaryInterchange.DirectedSemantics.Basic

namespace Inference.Contracts.Mlx.BFloat16Bounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open BFloat16Arithmetic

-- A representable ceiling gives a closed interval invariant under nearest
-- rounding and flushing. These lemmas discharge arithmetic range hypotheses
-- from operand bounds, without assuming that the result is already finite.
theorem rounded_bound (cap : Value) (hf : Model.isFinite cap = true) (x : ℝ) (hx : |x| ≤ Model.toReal cap) :
    |Model.roundAt FloatFormat.bfloat16 x| ≤ Model.toReal cap := by
  have lo := Model.roundAt_mono FloatFormat.bfloat16 (abs_le.mp hx).1
  have hi := Model.roundAt_mono FloatFormat.bfloat16 (abs_le.mp hx).2
  rw [Model.roundAt_neg, Model.roundAt_toReal_eq cap hf] at lo
  rw [Model.roundAt_toReal_eq cap hf] at hi
  exact abs_le.mpr ⟨lo, hi⟩

theorem ceiling_max (cap : Value) (hf : Model.isFinite cap = true) :
    Model.toReal cap ≤ Model.toReal (Model.posMaxFinite FloatFormat.bfloat16) :=
  (le_abs_self _).trans (Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite cap (by decide) hf)

theorem mul_range (x y cap : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true)
    (hc : Model.isFinite cap = true) (bound : |Model.toReal x| * |Model.toReal y| ≤ Model.toReal cap) :
    Model.isFinite (Model.mul (flush x) (flush y)) = true ∧ |Model.toReal (mul x y)| ≤ Model.toReal cap := by
  have hp := (mul_le_mul (flush_abs_le x) (flush_abs_le y) (abs_nonneg _) (abs_nonneg _)).trans bound
  have hf := Model.isFinite_mul_of_abs_mul_le_posMaxFinite (flush x) (flush y) (by decide)
    (finite_flush x hx) (finite_flush y hy) (hp.trans (ceiling_max cap hc))
  refine ⟨hf, (flush_abs_le _).trans ?_⟩
  rw [Model.toReal_mul_eq_roundAt _ _ (by decide) (finite_flush x hx) (finite_flush y hy) hf]
  apply rounded_bound cap hc
  simpa only [abs_mul] using hp

theorem add_range (x y cap : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true)
    (hc : Model.isFinite cap = true) (bound : |Model.toReal x| + |Model.toReal y| ≤ Model.toReal cap) :
    Model.isFinite (Model.add (flush x) (flush y)) = true ∧ |Model.toReal (add x y)| ≤ Model.toReal cap := by
  have hp := (add_le_add (flush_abs_le x) (flush_abs_le y)).trans bound
  have hf := Model.isFinite_add_of_abs_add_le_posMaxFinite (flush x) (flush y) (by decide)
    (finite_flush x hx) (finite_flush y hy) (hp.trans (ceiling_max cap hc))
  refine ⟨hf, (flush_abs_le _).trans ?_⟩
  rw [Model.toReal_add_eq_roundAt _ _ (by decide) (finite_flush x hx) (finite_flush y hy) hf]
  exact rounded_bound cap hc _ ((abs_add_le _ _).trans hp)

theorem fma_range (x y z cap : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true) (hz : Model.isFinite z = true)
    (hc : Model.isFinite cap = true) (bound : |Model.toReal x| * |Model.toReal y| + |Model.toReal z| ≤ Model.toReal cap) :
    Model.isFinite (Model.fma (flush x) (flush y) (flush z)) = true ∧ |Model.toReal (BFloat16Fma.value x y z)| ≤ Model.toReal cap := by
  have hp := (add_le_add (mul_le_mul (flush_abs_le x) (flush_abs_le y) (abs_nonneg _) (abs_nonneg _)) (flush_abs_le z)).trans bound
  have hf := BFloat16Fma.raw_finite x y z hx hy hz (bound.trans (ceiling_max cap hc))
  refine ⟨hf, (flush_abs_le _).trans ?_⟩
  rw [Model.toReal_fma_eq_roundAt _ _ _ (by decide) (finite_flush x hx) (finite_flush y hy) (finite_flush z hz) hf]
  apply rounded_bound cap hc
  exact (abs_add_le _ _).trans (by simpa only [abs_mul] using hp)

end Inference.Contracts.Mlx.BFloat16Bounds
