import kernels.quantization.AffineTileBounds
import contracts.mlx.DivisionDirectedBounds
import contracts.mlx.ArithmeticVaryingBounds

namespace Inference.Kernels.Quantization.AffineScaledBounds
open Contracts.Mlx Contracts.Mlx.Numerics AffineTile
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem prepare_range (divide : Float32 → Float32 → Float32) (division : DivisionDirectedBounds.Contract divide)
    (x : BF) (shift : Fin 13) (exponent : Int) (lo : -133 ≤ exponent) (hi : exponent ≤ 100)
    (hx : Model.isFinite x = true ∧ |Model.toReal x| ≤ (2 : ℝ)^exponent) :
    (AffineInput.prepare divide x shift).isFinite = true ∧
      |real (AffineInput.prepare divide x shift)| ≤ (2 : ℝ)^(exponent-(shift.val : Int)) := by
  have hf := BFloat16.widen_finite x hx.1
  have hb : |real (BFloat16.widen x)| ≤ (2 : ℝ)^exponent := by rw [BFloat16.widen_real _ hx.1]; exact hx.2
  unfold AffineInput.prepare
  split
  · rename_i zero
    simp only [zero, Nat.cast_zero, sub_zero]
    exact ⟨hf, hb⟩
  · have hc := DyadicBounds.ceiling_range 1 (exponent-(shift.val : Int)) (by decide)
      (by have := shift.isLt; omega) (by omega)
    have hd := AffineInput.divisors_checked shift
    have hdom := AffineInput.divisor_domain shift
    have hr := division.quotientBounded (BFloat16.widen x) (AffineInput.divisor shift)
      (DyadicBounds.ceiling 1 (exponent-(shift.val : Int))) hf hd.2 hdom hc.1
      (by rw [hc.2, Nat.cast_one, one_mul, AffineInput.divisor_value, zpow_sub₀ (by norm_num : (2 : ℝ) ≠ 0), zpow_natCast]
          exact div_le_div_of_nonneg_right hb (by positivity))
    exact ⟨division.finite _ _ hf hd.2 hdom, by simpa only [hc.2, Nat.cast_one, one_mul] using hr⟩

end Inference.Kernels.Quantization.AffineScaledBounds
