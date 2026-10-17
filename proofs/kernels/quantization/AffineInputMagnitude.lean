import kernels.quantization.AffineScaledBounds
import contracts.mlx.DyadicCover
import contracts.mlx.RelativeRounding
import contracts.mlx.NormalizedCastBounds

namespace Inference.Kernels.Quantization.AffineInputMagnitude
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- Bound every prepared input by its own magnitude. The dyadic cases belong
-- to the proof only; no scan, dispatch, or range check is added to the kernel.
theorem prepare (divide : Float32 → Float32 → Float32)
    (division : DivisionDirectedBounds.Contract divide) (x : BF) (shift : Fin 13)
    (hf : Model.isFinite x = true) (hx : |Model.toReal x| ≤ (2 : ℝ)^100) :
    (AffineInput.prepare divide x shift).isFinite = true ∧
      |real (AffineInput.prepare divide x shift)| * (2 : ℝ)^shift.val ≤
        2*|Model.toReal x|+(2 : ℝ)^(-133 : Int) := by
  have cancel (e : Int) : (2 : ℝ)^(e-(shift.val : Int))*(2 : ℝ)^shift.val = (2 : ℝ)^e := by
    rw [← zpow_natCast, ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
    congr 1
    omega
  rcases DyadicCover.interval (fun _ : Unit => Model.toReal x) (-133) 233
    (fun _ => by simpa only [show (-133 : Int)+(233 : Nat)=100 from by decide, zpow_ofNat] using hx)
    with small | ⟨e, lo, hi, upper, _, lower⟩
  · have hr := AffineScaledBounds.prepare_range divide division x shift (-133) (by decide) (by decide)
      ⟨hf, small ()⟩
    have h := mul_le_mul_of_nonneg_right hr.2 (by positivity : (0 : ℝ) ≤ 2^shift.val)
    rw [cancel] at h
    exact ⟨hr.1, by linarith only [h, abs_nonneg (Model.toReal x)]⟩
  · have hr := AffineScaledBounds.prepare_range divide division x shift e (by omega) (by norm_num at hi; exact hi)
      ⟨hf, upper ()⟩
    have h := mul_le_mul_of_nonneg_right hr.2 (by positivity : (0 : ℝ) ≤ 2^shift.val)
    rw [cancel] at h
    have power : (2 : ℝ)^e = 2*(2 : ℝ)^(e-1) := by
      rw [show e=(e-1)+1 from by omega, zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
      norm_num
      ring
    rw [power] at h
    exact ⟨hr.1, by linarith only [h, lower, show (0 : ℝ) ≤ 2^(-133 : Int) from by positivity]⟩

theorem lifted_product (divide : Float32 → Float32 → Float32)
    (division : DivisionDirectedBounds.Contract divide) (x : BF) (field : Fin 16) (shift : Fin 13)
    (hf : Model.isFinite x = true) (hx : |Model.toReal x| ≤ (2 : ℝ)^100) :
    |real (AffineInput.prepare divide x shift)| * |real (AffineLift.value (field.val*2^shift.val))| ≤
      2*(field.val : ℝ)*|Model.toReal x|+(field.val : ℝ)*(2 : ℝ)^(-133 : Int) := by
  have h := mul_le_mul_of_nonneg_left (prepare divide division x shift hf hx).2
    (Nat.cast_nonneg field.val : (0 : ℝ) ≤ field.val)
  rw [AffineLift.field_exact, abs_of_nonneg (show (0 : ℝ) ≤ (field.val : ℝ)*2^shift.val by positivity)]
  nlinarith only [h]

theorem rounded_product (divide : Float32 → Float32 → Float32)
    (division : DivisionDirectedBounds.Contract divide) (x : BF) (field : Fin 16) (shift : Fin 13)
    (hf : Model.isFinite x = true) (hx : |Model.toReal x| ≤ 512)
    (finite : (FlushToZero.flush (AffineInput.prepare divide x shift) *
      FlushToZero.flush (AffineLift.value (field.val*2^shift.val))).isFinite = true) :
    |real (FlushToZero.mul (AffineInput.prepare divide x shift)
      (AffineLift.value (field.val*2^shift.val)))| ≤ 31*|Model.toReal x|+(2 : ℝ)^(-100 : Int) := by
  have fieldBound : (field.val : ℝ) ≤ 15 := by have := field.isLt; exact_mod_cast (by omega : field.val ≤ 15)
  have shiftBound : shift.val ≤ 12 := by have := shift.isLt; omega
  have hp := (AffineScaledBounds.prepare_range divide division x shift 9 (by decide) (by decide)
    ⟨hf, by norm_num; exact hx⟩).2
  have prepBound : |real (AffineInput.prepare divide x shift)| ≤ 512 := by
    apply hp.trans
    have h := zpow_le_zpow_right₀ (by norm_num : (1 : ℝ) ≤ 2) (by omega : (9 : Int)-(shift.val : Int) ≤ 9)
    norm_num at h
    exact h
  have liftedBound : |real (AffineLift.value (field.val*2^shift.val))| ≤ 61440 := by
    rw [AffineLift.field_exact, abs_of_nonneg (by positivity)]
    have h := mul_le_mul fieldBound (pow_le_pow_right₀ (by norm_num : (1 : ℝ) ≤ 2) shiftBound)
      (by positivity : (0 : ℝ) ≤ 2^shift.val) (by norm_num : (0 : ℝ) ≤ 15)
    norm_num at h
    exact h
  have product := lifted_product divide division x field shift hf (hx.trans (by norm_num))
  have mass : |real (AffineInput.prepare divide x shift)| * |real (AffineLift.value (field.val*2^shift.val))| ≤
      30*|Model.toReal x|+15*(2 : ℝ)^(-133 : Int) := by
    have h1 := mul_le_mul_of_nonneg_right fieldBound (abs_nonneg (Model.toReal x))
    have h2 := mul_le_mul_of_nonneg_right fieldBound (by positivity : (0 : ℝ) ≤ 2^(-133 : Int))
    nlinarith only [product, h1, h2]
  have h := NormalizedCastBounds.absolute_of_error _ _ _ (RelativeRounding.multiplication
    (AffineInput.prepare divide x shift) (AffineLift.value (field.val*2^shift.val)) finite)
  rw [abs_mul] at h
  have tail : (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*
      (1+|real (AffineInput.prepare divide x shift)|+|real (AffineLift.value (field.val*2^shift.val))|) ≤
        (2 : ℝ)^(-109 : Int) := by
    norm_num [FlushToZero.threshold]
    linarith only [prepBound, liftedBound]
  norm_num at h mass tail ⊢
  linarith only [h, mass, tail, abs_nonneg (Model.toReal x)]

end Inference.Kernels.Quantization.AffineInputMagnitude
