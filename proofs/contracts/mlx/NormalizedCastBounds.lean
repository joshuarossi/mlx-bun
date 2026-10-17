import contracts.mlx.RelativeRounding
import contracts.mlx.NativeMultiplication
import contracts.mlx.DyadicBounds
import contracts.mlx.BFloat16ConversionBounds
import contracts.mlx.BFloat16DyadicBounds

namespace Inference.Contracts.Mlx.NormalizedCastBounds
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def value (x inverse : Float32) (weight : BFloat16Arithmetic.Value) : BFloat16Arithmetic.Value :=
  BFloat16Arithmetic.mul weight (BFloat16.narrow (FlushToZero.mul x inverse))

theorem absolute_of_error (a b error : ℝ) (h : |a-b| ≤ error) : |a| ≤ |b|+error := by
  calc
    |a| = |(a-b)+b| := by congr 1; ring
    _ ≤ |a-b|+|b| := abs_add_le _ _
    _ ≤ |b|+error := by linarith

-- Keep the three actual rounding stages: float multiplication, BF16 cast,
-- then BF16 weight multiplication. No exact-normalization substitution.
theorem component (x inverse : Float32) (weight : BFloat16Arithmetic.Value)
    (hx : x.isFinite = true) (hi : inverse.isFinite = true) (hw : Model.isFinite weight = true)
    (xb : |real x| ≤ (2 : ℝ)^(50 : Nat)) (ib : |real inverse| ≤ (2 : ℝ)^(12 : Nat))
    (wb : |Model.toReal weight| ≤ 1) :
    Model.isFinite (value x inverse weight) = true ∧
      |Model.toReal (value x inverse weight)| ≤
        (17/16 : ℝ)*|Model.toReal weight| * (|real x| * |real inverse|)+(2 : ℝ)^(-60 : Int) := by
  let product := FlushToZero.mul x inverse
  let converted := BFloat16.narrow product
  let a := |real x| * |real inverse|
  have an : 0 ≤ a := mul_nonneg (abs_nonneg _) (abs_nonneg _)
  have fc := DyadicBounds.ceiling_range 1 62 (by decide) (by decide) (by decide)
  have bc := BFloat16DyadicBounds.ceiling_range 1 62 (by decide) (by decide) (by decide)
  norm_num at fc bc
  have productBound : |real x| * |real inverse| ≤ real (DyadicBounds.ceiling 1 62) := by
    rw [fc.2]
    have h := mul_le_mul xb ib (abs_nonneg _) (by positivity : (0 : ℝ) ≤ 2^50)
    norm_num at h ⊢
    exact h
  have pr := NativeMultiplication.range x inverse (DyadicBounds.ceiling 1 62) hx hi fc.1 productBound
  have pf : product.isFinite = true := FlushToZero.finite_flush _ pr.1
  have pb : |real product| ≤ (2 : ℝ)^(62 : Nat) := by
    calc
      _ ≤ real (DyadicBounds.ceiling 1 62) := pr.2
      _ = _ := by rw [fc.2]; norm_num
  have cr := BFloat16ConversionBounds.narrow_range product (BFloat16DyadicBounds.ceiling 1 62) pf bc.1
    (by rw [bc.2]; norm_num at pb ⊢; exact pb)
  have cf : Model.isFinite converted = true := cr.1
  have cb : |Model.toReal converted| ≤ (2 : ℝ)^(62 : Nat) := by
    calc
      _ ≤ Model.toReal (BFloat16DyadicBounds.ceiling 1 62) := cr.2
      _ = _ := by rw [bc.2]; norm_num
  have wr := BFloat16Bounds.mul_range weight converted (BFloat16DyadicBounds.ceiling 1 62) hw cf bc.1 (by
    rw [bc.2]
    calc
      _ ≤ 1*(2 : ℝ)^(62 : Nat) := mul_le_mul wb cb (abs_nonneg _) (by norm_num)
      _ = _ := by ring)
  refine ⟨BFloat16Arithmetic.finite_flush _ wr.1, ?_⟩
  have pe := RelativeRounding.multiplication x inverse pr.1
  have pt : (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*(1+|real x|+|real inverse|) ≤
      (2 : ℝ)^(-74 : Int) := by
    norm_num [FlushToZero.threshold] at xb ib ⊢
    linarith only [xb, ib]
  have pab : |real product| ≤ (1+(2 : ℝ)^(-24 : Int))*a+(2 : ℝ)^(-74 : Int) := by
    have h := absolute_of_error _ _ _ pe
    rw [abs_mul] at h
    change |real product| ≤ a + _ at h
    linarith only [h, pt]
  have ce := (BFloat16.narrow_error product pf cf).trans (RelativeRounding.bfloat16_epsilon (real product))
  have cab : |Model.toReal converted| ≤ (129/128 : ℝ)*a+(2 : ℝ)^(-72 : Int) := by
    have h := absolute_of_error _ _ _ ce
    change |Model.toReal converted| ≤ _ at h
    norm_num at pab h ⊢
    linarith only [pab, h, an]
  have we := (BFloat16Arithmetic.mul_error weight converted hw cf wr.1).trans
    (RelativeRounding.bfloat16_multiplication_budget weight converted)
  have wt : (2 : ℝ)^(-134 : Int)+FlushToZero.threshold*(1+|Model.toReal weight|+|Model.toReal converted|) ≤
      (2 : ℝ)^(-63 : Int) := by
    norm_num [FlushToZero.threshold] at cb ⊢
    linarith only [wb, cb]
  have wa := absolute_of_error _ _ _ we
  rw [abs_mul] at wa
  have scaled := mul_le_mul_of_nonneg_left cab (abs_nonneg (Model.toReal weight))
  have tail := mul_le_mul_of_nonneg_right wb (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-72 : Int))
  have wan := mul_nonneg (abs_nonneg (Model.toReal weight)) an
  change |Model.toReal (BFloat16Arithmetic.mul weight converted)| ≤ _
  norm_num at wa wt scaled tail ⊢
  nlinarith only [wa, wt, scaled, tail, wan]

end Inference.Contracts.Mlx.NormalizedCastBounds
