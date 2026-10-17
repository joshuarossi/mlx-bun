import contracts.mlx.FlushToZero
import contracts.mlx.BFloat16Arithmetic
import contracts.mlx.BFloat16

namespace Inference.Contracts.Mlx.RelativeRounding
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem epsilon_bound (format : FloatFormat) (x : ℝ) :
    Model.epsilonAt format x ≤ Model.unitRoundoffAt format*|x|+Model.underflowErrorAt format := by
  have hu : 0 ≤ Model.unitRoundoffAt format := by rw [Model.unitRoundoffAt_eq]; positivity
  have he : 0 ≤ Model.underflowErrorAt format := by rw [Model.underflowErrorAt_eq]; positivity
  by_cases normal : Model.minNormalAt format ≤ |x|
  · have h := Model.ulpAt_le_of_minNormalAt_le format normal
    rw [← Model.two_mul_unitRoundoffAt] at h
    change Model.ulpAt format x/2 ≤ _
    nlinarith
  · have h := Model.ulpAt_eq_of_abs_lt_minNormalAt format (lt_of_not_ge normal)
    rw [← Model.two_mul_underflowErrorAt] at h
    change Model.ulpAt format x/2 ≤ _
    rw [h]
    nlinarith [mul_nonneg hu (abs_nonneg x)]

theorem binary32_epsilon (x : ℝ) :
    epsilon x ≤ (2 : ℝ)^(-24 : Int)*|x|+(2 : ℝ)^(-150 : Int) := by
  have hu : Model.unitRoundoffAt FloatFormat.binary32 = (2 : ℝ)^(-24 : Int) := by
    rw [Model.unitRoundoffAt_eq]
    rfl
  have he : Model.underflowErrorAt FloatFormat.binary32 = (2 : ℝ)^(-150 : Int) := by
    rw [Model.underflowErrorAt_eq]
    rfl
  simpa only [hu, he] using epsilon_bound FloatFormat.binary32 x

-- The relative part is small even at large activation scales. The absolute
-- term retains gradual underflow; separate flush allowances are added below.
theorem grid_error (format : FloatFormat) (x : ℝ) :
    |Model.roundAt format x-x| ≤ Model.unitRoundoffAt format*|x| + Model.underflowErrorAt format := by
  obtain ⟨delta, eta, eq, hd, he, _⟩ := Model.roundAt_standardModel format x
  rw [eq]
  calc
    _ = |x*delta+eta| := by congr 1; ring
    _ ≤ |x*delta|+|eta| := abs_add_le _ _
    _ ≤ |x| * Model.unitRoundoffAt format+Model.underflowErrorAt format := by
      rw [abs_mul]
      exact add_le_add (mul_le_mul_of_nonneg_left hd (abs_nonneg _)) he
    _ = _ := by ring

theorem binary32_grid (x : ℝ) :
    |Model.roundAt FloatFormat.binary32 x-x| ≤ (2 : ℝ)^(-24 : Int)*|x|+(2 : ℝ)^(-150 : Int) := by
  have hu : Model.unitRoundoffAt FloatFormat.binary32 = (2 : ℝ)^(-24 : Int) := by
    rw [Model.unitRoundoffAt_eq]
    rfl
  have he : Model.underflowErrorAt FloatFormat.binary32 = (2 : ℝ)^(-150 : Int) := by
    rw [Model.underflowErrorAt_eq]
    rfl
  simpa only [hu, he] using grid_error FloatFormat.binary32 x

theorem bfloat16_grid (x : ℝ) :
    |Model.roundAt FloatFormat.bfloat16 x-x| ≤ (2 : ℝ)^(-8 : Int)*|x|+(2 : ℝ)^(-134 : Int) := by
  have hu : Model.unitRoundoffAt FloatFormat.bfloat16 = (2 : ℝ)^(-8 : Int) := by
    rw [Model.unitRoundoffAt_eq]
    rfl
  have he : Model.underflowErrorAt FloatFormat.bfloat16 = (2 : ℝ)^(-134 : Int) := by
    rw [Model.underflowErrorAt_eq]
    rfl
  simpa only [hu, he] using grid_error FloatFormat.bfloat16 x

theorem multiplication (x y : Float32)
    (hf : (FlushToZero.flush x*FlushToZero.flush y).isFinite = true) :
    |real (FlushToZero.mul x y)-real x*real y| ≤
      (2 : ℝ)^(-24 : Int)*(|real x| * |real y|) + (2 : ℝ)^(-150 : Int) +
      FlushToZero.threshold*(1+|real x|+|real y|) := by
  have ho := FlushToZero.mul_raw_error x y hf
  have hr := binary32_grid (real (FlushToZero.flush x)*real (FlushToZero.flush y))
  rw [← mul_real _ _ hf] at hr
  have hp := FlushToZero.product_input_error x y
  have hi := mul_le_mul (FlushToZero.flush_abs_le x) (FlushToZero.flush_abs_le y)
    (abs_nonneg _) (abs_nonneg _)
  have hu := mul_le_mul_of_nonneg_left hi (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-24 : Int))
  rw [← abs_mul] at hu
  have h := (abs_sub_le (real (FlushToZero.mul x y))
    (real (FlushToZero.flush x*FlushToZero.flush y)) (real x*real y)).trans
      (add_le_add ho ((abs_sub_le (real (FlushToZero.flush x*FlushToZero.flush y))
        (real (FlushToZero.flush x)*real (FlushToZero.flush y)) (real x*real y)).trans (add_le_add hr hp)))
  linarith

theorem addition (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (hf : (FlushToZero.flush x+FlushToZero.flush y).isFinite = true) :
    |real (FlushToZero.add x y)-(real x+real y)| ≤
      (2 : ℝ)^(-24 : Int)*(|real x|+|real y|) + (2 : ℝ)^(-150 : Int) + 3*FlushToZero.threshold := by
  have ho := FlushToZero.flush_error (FlushToZero.flush x+FlushToZero.flush y)
  have hr := binary32_grid (real (FlushToZero.flush x)+real (FlushToZero.flush y))
  rw [← add_real _ _ (FlushToZero.finite_flush _ hx) (FlushToZero.finite_flush _ hy) hf] at hr
  have hi := (abs_add_le _ _).trans (add_le_add (FlushToZero.flush_abs_le x) (FlushToZero.flush_abs_le y))
  have hu := mul_le_mul_of_nonneg_left hi (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-24 : Int))
  have hin : |(real (FlushToZero.flush x)+real (FlushToZero.flush y))-(real x+real y)| ≤ 2*FlushToZero.threshold := by
    have h := (abs_add_le (real (FlushToZero.flush x)-real x) (real (FlushToZero.flush y)-real y)).trans
      (add_le_add (FlushToZero.flush_error x) (FlushToZero.flush_error y))
    calc
      _ = |(real (FlushToZero.flush x)-real x)+(real (FlushToZero.flush y)-real y)| := by congr 1; ring
      _ ≤ _ := by linarith
  have h := (abs_sub_le (real (FlushToZero.add x y))
    (real (FlushToZero.flush x+FlushToZero.flush y)) (real x+real y)).trans
      (add_le_add ho ((abs_sub_le (real (FlushToZero.flush x+FlushToZero.flush y))
        (real (FlushToZero.flush x)+real (FlushToZero.flush y)) (real x+real y)).trans (add_le_add hr hin)))
  linarith

theorem multiplication_budget (x y : Float32) :
    FlushToZero.mulBudget x y ≤
      (2 : ℝ)^(-24 : Int)*(|real x| * |real y|)+(2 : ℝ)^(-150 : Int)+
      FlushToZero.threshold*(1+|real x|+|real y|) := by
  have h := binary32_epsilon (real (FlushToZero.flush x)*real (FlushToZero.flush y))
  have hp := mul_le_mul (FlushToZero.flush_abs_le x) (FlushToZero.flush_abs_le y) (abs_nonneg _) (abs_nonneg _)
  have hs := mul_le_mul_of_nonneg_left hp (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-24 : Int))
  rw [abs_mul] at h
  unfold FlushToZero.mulBudget
  linarith

theorem addition_budget (x y : Float32) :
    FlushToZero.addBudget x y ≤
      (2 : ℝ)^(-24 : Int)*(|real x|+|real y|)+(2 : ℝ)^(-150 : Int)+3*FlushToZero.threshold := by
  have h := binary32_epsilon (real (FlushToZero.flush x)+real (FlushToZero.flush y))
  have hp := (abs_add_le _ _).trans (add_le_add (FlushToZero.flush_abs_le x) (FlushToZero.flush_abs_le y))
  have hs := mul_le_mul_of_nonneg_left hp (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-24 : Int))
  unfold FlushToZero.addBudget
  linarith

theorem fma_budget (x y z : Float32) :
    FlushToZero.fmaBudget x y z ≤
      (2 : ℝ)^(-24 : Int)*(|real x| * |real y|+|real z|)+(2 : ℝ)^(-150 : Int)+
      FlushToZero.threshold*(2+|real x|+|real y|) := by
  have h := binary32_epsilon (real (FlushToZero.flush x)*real (FlushToZero.flush y)+real (FlushToZero.flush z))
  have hp := mul_le_mul (FlushToZero.flush_abs_le x) (FlushToZero.flush_abs_le y) (abs_nonneg _) (abs_nonneg _)
  have hs := (abs_add_le (real (FlushToZero.flush x)*real (FlushToZero.flush y)) (real (FlushToZero.flush z))).trans
    (add_le_add (by simpa only [abs_mul] using hp) (FlushToZero.flush_abs_le z))
  have hu := mul_le_mul_of_nonneg_left hs (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-24 : Int))
  unfold FlushToZero.fmaBudget
  linarith

theorem division_budget (x y : Float32) (hy : 1 ≤ real y) :
    FlushToZero.divBudget x y ≤ (2 : ℝ)^(-24 : Int)*(|real x|/real y)+
      (2 : ℝ)^(-150 : Int)+2*FlushToZero.threshold := by
  have positive : 0 < real y := by linarith
  have h := binary32_epsilon (real (FlushToZero.flush x)/real y)
  rw [abs_div, abs_of_pos positive] at h
  have hs := div_le_div_of_nonneg_right (FlushToZero.flush_abs_le x) positive.le
  have hu := mul_le_mul_of_nonneg_left hs (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-24 : Int))
  have ht : FlushToZero.threshold/real y ≤ FlushToZero.threshold := div_le_self FlushToZero.threshold_pos.le hy
  unfold FlushToZero.divBudget
  rw [abs_of_pos positive]
  linarith

theorem division (x y : Float32) (hy : y.isFinite = true) (lower : 1 ≤ real y)
    (hf : (FlushToZero.flush x/y).isFinite = true) :
    |real (FlushToZero.div x y)-real x/real y| ≤ (2 : ℝ)^(-24 : Int)*(|real x|/real y)+
      (2 : ℝ)^(-150 : Int)+2*FlushToZero.threshold :=
  (FlushToZero.div_normal_error x y hy lower hf).trans (division_budget x y lower)

theorem bfloat16_epsilon (x : ℝ) :
    BFloat16.epsilon x ≤ (2 : ℝ)^(-8 : Int)*|x|+(2 : ℝ)^(-134 : Int) := by
  have hu : Model.unitRoundoffAt FloatFormat.bfloat16 = (2 : ℝ)^(-8 : Int) := by
    rw [Model.unitRoundoffAt_eq]
    rfl
  have he : Model.underflowErrorAt FloatFormat.bfloat16 = (2 : ℝ)^(-134 : Int) := by
    rw [Model.underflowErrorAt_eq]
    rfl
  simpa only [hu, he, BFloat16.epsilon] using epsilon_bound FloatFormat.bfloat16 x

theorem bfloat16_multiplication_budget (x y : BFloat16Arithmetic.Value) :
    BFloat16Arithmetic.mulBudget x y ≤
      (2 : ℝ)^(-8 : Int)*(|Model.toReal x| * |Model.toReal y|)+(2 : ℝ)^(-134 : Int)+
      FlushToZero.threshold*(1+|Model.toReal x|+|Model.toReal y|) := by
  have h := bfloat16_epsilon (Model.toReal (BFloat16Arithmetic.flush x)*Model.toReal (BFloat16Arithmetic.flush y))
  have hp := mul_le_mul (BFloat16Arithmetic.flush_abs_le x) (BFloat16Arithmetic.flush_abs_le y)
    (abs_nonneg _) (abs_nonneg _)
  have hs := mul_le_mul_of_nonneg_left hp (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-8 : Int))
  rw [abs_mul] at h
  unfold BFloat16Arithmetic.mulBudget
  change _ + BFloat16.epsilon _ + _ ≤ _
  linarith

end Inference.Contracts.Mlx.RelativeRounding
