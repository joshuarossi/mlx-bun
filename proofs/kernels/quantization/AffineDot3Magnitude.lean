import kernels.quantization.AffineInputMagnitude
import kernels.quantization.AffineShiftedDotBounds
import contracts.mlx.MaddMagnitude

namespace Inference.Kernels.Quantization.AffineDot3Magnitude
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic ArithmeticFold AffineDot
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

def prepared (divide : Float32 → Float32 → Float32) (x : Fin 8 → BF) (i : Fin 8) : Float32 :=
  AffineInput.prepare divide (x i) (AffineTile.shift3 i)

theorem prepared_bound (divide : Float32 → Float32 → Float32) (division : DivisionDirectedBounds.Contract divide)
    (x : Fin 8 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ 512) (i : Fin 8) :
    (prepared divide x i).isFinite = true ∧ |real (prepared divide x i)| ≤ 512 := by
  have h := AffineScaledBounds.prepare_range divide division (x i) (AffineTile.shift3 i) 9 (by decide) (by decide)
    ⟨(hx i).1, by norm_num; exact (hx i).2⟩
  refine ⟨h.1, h.2.trans ?_⟩
  have hs := zpow_le_zpow_right₀ (by norm_num : (1 : ℝ) ≤ 2)
    (by have := (AffineTile.shift3 i).isLt; omega : (9 : Int)-((AffineTile.shift3 i).val : Int) ≤ 9)
  norm_num at hs
  exact hs

theorem coefficient_bound (w : Fin 3 → BitVec 8) (i : Fin 10) : |real (AffineLift.value (mask3 w i))| ≤ 1024 := by
  apply (AffineShiftedDotBounds.mask3_range w i).2.trans
  fin_cases i <;> norm_num [AffineShiftedDotBounds.maskExponent3, coordinate3, inputShift3, crossed3]

theorem crossed_bound (x : Float32) (hx : |real x| ≤ 512)
    (hf : (FlushToZero.flush x*FlushToZero.flush (256 : Float32)).isFinite = true) :
    |real (FlushToZero.mul x 256)| ≤ (1+(2 : ℝ)^(-24 : Int))*256*|real x|+(2 : ℝ)^(-110 : Int) ∧
      |real (FlushToZero.mul x 256)| ≤ (2 : ℝ)^18 := by
  have h := NormalizedCastBounds.absolute_of_error _ _ _ (RelativeRounding.multiplication x 256 hf)
  rw [abs_mul, AffineDotBounds.real256] at h
  have tail : (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*(1+|real x|+(2 : ℝ)^8) ≤ (2 : ℝ)^(-110 : Int) := by
    norm_num [FlushToZero.threshold]
    linarith only [hx]
  have first : |real (FlushToZero.mul x 256)| ≤
      (1+(2 : ℝ)^(-24 : Int))*256*|real x|+(2 : ℝ)^(-110 : Int) := by
    norm_num at h tail ⊢
    linarith only [h, tail]
  refine ⟨first, ?_⟩
  norm_num at first ⊢
  linarith only [first, hx]

end Inference.Kernels.Quantization.AffineDot3Magnitude
