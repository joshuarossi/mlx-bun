import contracts.mlx.BFloat16Arithmetic

namespace Inference.Contracts.Mlx.BFloat16Fma
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open BFloat16Arithmetic
open FlushToZero (threshold threshold_pos)

def value (x y z : Value) : Value :=
  flushExact (FlushToZero.fmaExact (flush x) (flush y) (flush z)) (Model.fma (flush x) (flush y) (flush z))
noncomputable def budget (x y z : Value) : ℝ :=
  2*threshold + epsilon (Model.toReal (flush x)*Model.toReal (flush y)+Model.toReal (flush z)) +
    threshold*(|Model.toReal x|+|Model.toReal y|)

theorem product_input_error (x y : Value) :
    |Model.toReal (flush x)*Model.toReal (flush y)-Model.toReal x*Model.toReal y| ≤
      threshold*(|Model.toReal x|+|Model.toReal y|) := by
  have ex := mul_le_mul_of_nonneg_right (flush_error x) (abs_nonneg (Model.toReal y))
  have ey := mul_le_mul_of_nonneg_left (flush_error y) (abs_nonneg (Model.toReal (flush x)))
  have hx := mul_le_mul_of_nonneg_right (flush_abs_le x) threshold_pos.le
  calc
    _ = |Model.toReal (flush x)*(Model.toReal (flush y)-Model.toReal y)+(Model.toReal (flush x)-Model.toReal x)*Model.toReal y| := by congr 1; ring
    _ ≤ _ := by
      have h := abs_add_le (Model.toReal (flush x)*(Model.toReal (flush y)-Model.toReal y)) ((Model.toReal (flush x)-Model.toReal x)*Model.toReal y)
      simp only [abs_mul] at h
      nlinarith

theorem error (x y z : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true) (hz : Model.isFinite z = true)
    (hf : Model.isFinite (Model.fma (flush x) (flush y) (flush z)) = true) :
    |Model.toReal (value x y z) - (Model.toReal x*Model.toReal y+Model.toReal z)| ≤ budget x y z := by
  have e : |Model.toReal (value x y z)-(Model.toReal (flush x)*Model.toReal (flush y)+Model.toReal (flush z))| ≤
      threshold + epsilon (Model.toReal (flush x)*Model.toReal (flush y)+Model.toReal (flush z)) :=
    flushExact_error (FlushToZero.exact_fma _ _ _ (finite_flush x hx) (finite_flush y hy) (finite_flush z hz)) _
      (Model.toReal_fma_eq_roundAt _ _ _ (by decide) (finite_flush x hx) (finite_flush y hy) (finite_flush z hz) hf)
  have ei := product_input_error x y
  have ez := flush_error z
  unfold budget
  calc
    _ = |(Model.toReal (value x y z)-(Model.toReal (flush x)*Model.toReal (flush y)+Model.toReal (flush z))) +
      ((Model.toReal (flush x)*Model.toReal (flush y)-Model.toReal x*Model.toReal y)+(Model.toReal (flush z)-Model.toReal z))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add e ((abs_add_le _ _).trans (add_le_add ei ez)))
      linarith

theorem real_value (x y z : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true)
    (hz : Model.isFinite z = true) (hf : Model.isFinite (Model.fma (flush x) (flush y) (flush z)) = true) :
    Model.toReal (value x y z) =
      if |Model.toReal (flush x)*Model.toReal (flush y)+Model.toReal (flush z)|<threshold then 0
      else Model.roundAt FloatFormat.bfloat16 (Model.toReal (flush x)*Model.toReal (flush y)+Model.toReal (flush z)) :=
  real_flushExact (FlushToZero.exact_fma _ _ _ (finite_flush x hx) (finite_flush y hy) (finite_flush z hz)) _
    (Model.toReal_fma_eq_roundAt _ _ _ (by decide) (finite_flush x hx) (finite_flush y hy) (finite_flush z hz) hf)

theorem raw_finite (x y z : Value)
 (hx : Model.isFinite x = true) (hy : Model.isFinite y = true) (hz : Model.isFinite z = true)
    (bound : |Model.toReal x| * |Model.toReal y| + |Model.toReal z| ≤ Model.toReal (Model.posMaxFinite FloatFormat.bfloat16)) :
    Model.isFinite (Model.fma (flush x) (flush y) (flush z)) = true := by
  apply Model.isFinite_fma_of_abs_mul_add_le_posMaxFinite _ _ _ (by decide)
    (finite_flush x hx) (finite_flush y hy) (finite_flush z hz)
  exact (add_le_add (mul_le_mul (flush_abs_le x) (flush_abs_le y) (abs_nonneg _) (abs_nonneg _)) (flush_abs_le z)).trans bound

theorem finite (x y z : Value) (hf : Model.isFinite (Model.fma (flush x) (flush y) (flush z)) = true) :
    Model.isFinite (value x y z) = true := finite_flushExact _ _ hf


end Inference.Contracts.Mlx.BFloat16Fma
