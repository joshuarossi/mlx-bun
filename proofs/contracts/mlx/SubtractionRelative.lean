import contracts.mlx.Arithmetic
import contracts.mlx.RelativeRounding

namespace Inference.Contracts.Mlx.SubtractionRelative
open Numerics

theorem budget (x y : Float32) :
    Arithmetic.subBudget x y ≤ (2 : ℝ)^(-24 : Int)*(|real x|+|real y|)+
      (2 : ℝ)^(-150 : Int)+3*FlushToZero.threshold := by
  have h := RelativeRounding.binary32_epsilon (real (FlushToZero.flush x)-real (FlushToZero.flush y))
  have hi := (abs_sub _ _).trans (add_le_add (FlushToZero.flush_abs_le x) (FlushToZero.flush_abs_le y))
  have hs := mul_le_mul_of_nonneg_left hi (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-24 : Int))
  unfold Arithmetic.subBudget
  linarith only [h, hs]

theorem error (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (hf : (FlushToZero.flush x-FlushToZero.flush y).isFinite = true) :
    |real (Arithmetic.sub x y)-(real x-real y)| ≤
      (2 : ℝ)^(-24 : Int)*(|real x|+|real y|)+(2 : ℝ)^(-150 : Int)+3*FlushToZero.threshold :=
  (Arithmetic.sub_error x y hx hy hf).trans (budget x y)

end Inference.Contracts.Mlx.SubtractionRelative
