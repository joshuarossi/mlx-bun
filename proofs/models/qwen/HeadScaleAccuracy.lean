import models.qwen.HeadScaleConstruction
import Mathlib.Analysis.Real.Sqrt

namespace Inference.Models.Qwen.HeadScaleAccuracy
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem inverse_sqrt_bound : |(181 : ℝ)/2048 - 1/Real.sqrt 128| ≤ 1/65536 := by
  have positive : 0 < Real.sqrt 128 := Real.sqrt_pos.mpr (by norm_num)
  have square : (Real.sqrt 128)^2 = 128 := Real.sq_sqrt (by norm_num)
  have lower : ((181 : ℝ)/2048 - 1/65536)*Real.sqrt 128 ≤ 1 := by nlinarith
  have upper : 1 ≤ ((181 : ℝ)/2048 + 1/65536)*Real.sqrt 128 := by nlinarith
  have lo := (le_div_iff₀ positive).mpr lower
  have hi := (div_le_iff₀ positive).mpr upper
  exact abs_le.mpr ⟨by linarith, by linarith⟩

theorem query_exact (i : Fin 128) : Model.toReal (HeadScaleConstruction.query i) = (1 : ℝ)/128 :=
  (HeadScaleConstruction.query_bound i).2

theorem key_accuracy (i : Fin 128) :
    |Model.toReal (HeadScaleConstruction.key i) - 1/Real.sqrt 128| ≤ (1 : ℝ)/65536 := by
  rw [(HeadScaleConstruction.key_bound i).2]
  exact inverse_sqrt_bound

theorem key_scaled_error (i : Fin 128) (x : ℝ) :
    |Model.toReal (HeadScaleConstruction.key i)*x - x/Real.sqrt 128| ≤ |x|/65536 := by
  calc
    _ = |(Model.toReal (HeadScaleConstruction.key i)-1/Real.sqrt 128)*x| := by congr 1; ring
    _ = |Model.toReal (HeadScaleConstruction.key i)-1/Real.sqrt 128| * |x| := abs_mul _ _
    _ ≤ (1/65536) * |x| := mul_le_mul_of_nonneg_right (key_accuracy i) (abs_nonneg _)
    _ = _ := by ring

end Inference.Models.Qwen.HeadScaleAccuracy
