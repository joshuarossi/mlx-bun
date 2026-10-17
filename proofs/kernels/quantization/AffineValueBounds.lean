import kernels.quantization.AffineTileBounds
import kernels.quantization.AffineSumBounds

namespace Inference.Kernels.Quantization.AffineValueBounds
open Contracts.Mlx Contracts.Mlx.Numerics AffineTile
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Separate multiplication and contracted FMA are both proved at their actual
-- rounding sites. The scale and bias bounds are obligations on loaded weights.
theorem tail_range (contracted : Bool) (scale bias : BF) (dot sum : Float32)
    (count : Nat) (ed eu es eb exponent : Int)
    (lo : -149 ≤ exponent) (hi : exponent ≤ 100) (size : count+16 < 16777216)
    (scaled : ed+es ≤ exponent) (biased : eu+eb ≤ exponent)
    (hs : Model.isFinite scale = true ∧ |Model.toReal scale| ≤ (2 : ℝ)^es)
    (hb : Model.isFinite bias = true ∧ |Model.toReal bias| ≤ (2 : ℝ)^eb)
    (hd : dot.isFinite = true ∧ |real dot| ≤ (count : ℝ) * (2 : ℝ)^ed)
    (hu : sum.isFinite = true ∧ |real sum| ≤ 16 * (2 : ℝ)^eu) :
    Arithmetic.Finite (tailBind (BFloat16.widen scale) dot sum (BFloat16.widen bias)) (tailExpr contracted) ∧
      (combine contracted scale dot sum bias).isFinite = true ∧
      |real (combine contracted scale dot sum bias)| ≤ ((count+16 : Nat) : ℝ) * (2 : ℝ)^exponent := by
  have hsf := BFloat16.widen_finite scale hs.1
  have hbf := BFloat16.widen_finite bias hb.1
  have hdp : |real (BFloat16.widen scale)| * |real dot| ≤ (count : ℝ) * (2 : ℝ)^exponent := by
    rw [BFloat16.widen_real _ hs.1]
    calc
      _ ≤ (2 : ℝ)^es * ((count : ℝ) * (2 : ℝ)^ed) :=
        mul_le_mul hs.2 hd.2 (abs_nonneg _) (zpow_nonneg (by norm_num) _)
      _ = (count : ℝ) * (2 : ℝ)^(ed+es) := by rw [zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]; ring
      _ ≤ _ := mul_le_mul_of_nonneg_left (zpow_le_zpow_right₀ (by norm_num) scaled) (Nat.cast_nonneg _)
  have hup : |real sum| * |real (BFloat16.widen bias)| ≤ 16 * (2 : ℝ)^exponent := by
    rw [BFloat16.widen_real _ hb.1]
    calc
      _ ≤ (16 * (2 : ℝ)^eu) * (2 : ℝ)^eb :=
        mul_le_mul hu.2 hb.2 (abs_nonneg _) (mul_nonneg (by norm_num) (zpow_nonneg (by norm_num) _))
      _ = 16 * (2 : ℝ)^(eu+eb) := by rw [zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]; ring
      _ ≤ _ := mul_le_mul_of_nonneg_left (zpow_le_zpow_right₀ (by norm_num) biased) (by norm_num)
  have cb := DyadicBounds.ceiling_range 16 exponent (by decide) lo hi
  have co := DyadicBounds.ceiling_range (count+16) exponent size lo hi
  have hm := NativeMultiplication.range sum (BFloat16.widen bias) (DyadicBounds.ceiling 16 exponent)
    hu.1 hbf cb.1 (by simpa only [cb.2, Nat.cast_ofNat] using hup)
  have hmb : |real (FlushToZero.mul sum (BFloat16.widen bias))| ≤ 16 * (2 : ℝ)^exponent := by
    simpa only [cb.2, Nat.cast_ofNat] using hm.2
  have hmf := FlushToZero.finite_flush _ hm.1
  have ht : Arithmetic.Finite (tailBind (BFloat16.widen scale) dot sum (BFloat16.widen bias)) (tailExpr contracted) ∧
      |real (combine contracted scale dot sum bias)| ≤ ((count+16 : Nat) : ℝ) * (2 : ℝ)^exponent := by
    cases contracted
    · have cd := DyadicBounds.ceiling_range count exponent (by omega) lo hi
      have hd' := NativeMultiplication.range (BFloat16.widen scale) dot (DyadicBounds.ceiling count exponent)
        hsf hd.1 cd.1 (by rwa [cd.2])
      have hadd := Float32Bounds.add_range (FlushToZero.mul sum (BFloat16.widen bias))
        (FlushToZero.mul (BFloat16.widen scale) dot) (DyadicBounds.ceiling (count+16) exponent)
        hmf (FlushToZero.finite_flush _ hd'.1) co.1
        (by rw [co.2]; have hdv := hd'.2; rw [cd.2] at hdv; calc
            _ ≤ 16 * (2 : ℝ)^exponent + (count : ℝ) * (2 : ℝ)^exponent := add_le_add hmb hdv
            _ = _ := by push_cast; ring)
      exact ⟨⟨⟨hu.1, hbf, hm.1⟩, ⟨hsf, hd.1, hd'.1⟩, hadd.1⟩,
        by simpa only [combine, ArithmeticFold.maddFloat, Bool.false_eq_true, ite_false, co.2] using hadd.2⟩
    · have hfma := NativeFma.range (BFloat16.widen scale) dot (FlushToZero.mul sum (BFloat16.widen bias))
        (DyadicBounds.ceiling (count+16) exponent) hsf hd.1 hmf co.1
        (by rw [co.2]; calc
            _ ≤ (count : ℝ) * (2 : ℝ)^exponent + 16 * (2 : ℝ)^exponent := add_le_add hdp hmb
            _ = _ := by push_cast; ring)
      exact ⟨⟨hsf, hd.1, ⟨hu.1, hbf, hm.1⟩, hfma.1⟩,
        by simpa only [combine, ArithmeticFold.maddFloat, ite_true, co.2] using hfma.2⟩
  have hf := Arithmetic.finite_evaluate
    (tailBind (BFloat16.widen scale) dot sum (BFloat16.widen bias)) (tailExpr contracted) ht.1
  rw [tail_execution] at hf
  exact ⟨ht.1, hf, ht.2⟩

theorem range3 (p : Platform) (division : DivisionBounds.Contract p.divide)
    (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (scale bias : BF)
    (ex es eb out : Int) (lo : -133 ≤ ex) (hi : ex+16 ≤ 100)
    (outLo : -149 ≤ out) (outHi : out ≤ 100) (scaled : ex+16+es ≤ out) (biased : ex+eb ≤ out)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^ex)
    (hs : Model.isFinite scale = true ∧ |Model.toReal scale| ≤ (2 : ℝ)^es)
    (hb : Model.isFinite bias = true ∧ |Model.toReal bias| ≤ (2 : ℝ)^eb) :
    Finite3 p x w scale bias ∧ (value3 p x w scale bias).isFinite = true ∧
      |real (value3 p x w scale bias)| ≤ 36 * (2 : ℝ)^out := by
  have hd := AffineTileBounds.dot3_range p division x w ex (by omega) hi hx
  have hu := AffineSumBounds.range3 x ex lo (by omega) hx
  have ht := tail_range p.tailContracted scale bias (dot3 p x w) (AffineInput.summed x AffineInput.groups3)
    20 (ex+16) ex es eb out outLo outHi (by decide) scaled biased hs hb hd.2 hu.2.2
  exact ⟨⟨hd.1, hu.1, hu.2.1, hs.1, hb.1, ht.1⟩, ht.2.1,
    by simpa only [value3, show (20 : Nat)+16=36 from rfl, Nat.cast_ofNat] using ht.2.2⟩

theorem range4 (p : Platform) (division : DivisionBounds.Contract p.divide)
    (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (scale bias : BF)
    (ex es eb out : Int) (lo : -133 ≤ ex) (hi : ex+16 ≤ 100)
    (outLo : -149 ≤ out) (outHi : out ≤ 100) (scaled : ex+16+es ≤ out) (biased : ex+eb ≤ out)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^ex)
    (hs : Model.isFinite scale = true ∧ |Model.toReal scale| ≤ (2 : ℝ)^es)
    (hb : Model.isFinite bias = true ∧ |Model.toReal bias| ≤ (2 : ℝ)^eb) :
    Finite4 p x w scale bias ∧ (value4 p x w scale bias).isFinite = true ∧
      |real (value4 p x w scale bias)| ≤ 32 * (2 : ℝ)^out := by
  have hd := AffineTileBounds.dot4_range p division x w ex (by omega) hi hx
  have hu := AffineSumBounds.range4 x ex lo (by omega) hx
  have ht := tail_range p.tailContracted scale bias (dot4 p x w) (AffineInput.summed x AffineInput.groups4)
    16 (ex+16) ex es eb out outLo outHi (by decide) scaled biased hs hb hd.2 hu.2.2
  exact ⟨⟨hd.1, hu.1, hu.2.1, hs.1, hb.1, ht.1⟩, ht.2.1,
    by simpa only [value4, show (16 : Nat)+16=32 from rfl, Nat.cast_ofNat] using ht.2.2⟩

end Inference.Kernels.Quantization.AffineValueBounds
