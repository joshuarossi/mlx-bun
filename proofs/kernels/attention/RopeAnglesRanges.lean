import kernels.attention.RopeAngles
import contracts.mlx.DivisionBounds
import contracts.mlx.NativeMultiplication
import contracts.mlx.DyadicBounds

namespace Inference.Kernels.Attention.RopeAnglesRanges
open Contracts.Mlx Contracts.Mlx.Numerics RopeAngles
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure InputsBound (x : Inputs) : Prop where
  baseFinite : x.base.isFinite = true
  baseNonnegative : 0 ≤ real x.base
  baseMagnitude : |real x.base| ≤ 32
  positionFinite : x.position.isFinite = true
  positionMagnitude : |real x.position| ≤ (2 : ℝ)^(18 : Nat)
  scaleFinite : x.scale.isFinite = true
  scaleMagnitude : |real x.scale| ≤ 1

def Exp2Range (p : Platform) : Prop := ∀ v, v.isFinite = true → real v ≤ 0 →
  (p.exp2 v).isFinite = true ∧ 0 ≤ real (p.exp2 v) ∧ real (p.exp2 v) ≤ 1

private theorem cap (e : Int) (bounds : 0 ≤ e ∧ e ≤ 100) :
    (DyadicBounds.ceiling 1 e).isFinite = true ∧ real (DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using DyadicBounds.ceiling_range 1 e (by decide) (by omega) bounds.2

theorem frequency (p : Platform) (division : DivisionBounds.Contract p.divide) (exponential : Exp2Range p)
    (x : Inputs) (hx : InputsBound x) (i : Fin 32) :
    FrequencyFinite p x i ∧ 0 ≤ real (RopeAngles.frequency p x i) ∧ real (RopeAngles.frequency p x i) ≤ 1 := by
  have hrf : (ratio p i).isFinite = true := division.finite (indexFloat i) width (index_checked i).2.2 width_finite width_domain
  have hr := division.bounded (indexFloat i) width width (index_checked i).2.2 width_finite width_domain width_finite (by
    rw [index_value, width_value, abs_of_nonneg (Nat.cast_nonneg _)]
    exact_mod_cast (show i.val ≤ 32 by have := i.isLt; omega))
  rw [width_value] at hr
  have hrn := p.division.nonnegative (indexFloat i) width (index_checked i).2.2 width_finite
    (by rw [index_value]; positivity) width_domain hrf
  have hp := NativeMultiplication.range (-ratio p i) x.base (DyadicBounds.ceiling 1 10)
    (Negation.finite_neg _ hrf) hx.baseFinite (cap 10 (by decide)).1 (by
      rw [Negation.real_neg _ hrf, abs_neg, (cap 10 (by decide)).2]
      exact (mul_le_mul hr hx.baseMagnitude (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 32)).trans (by norm_num))
  have hnonpos : real (argument p x i) ≤ 0 := FlushToZero.mul_nonpositive _ _
    (by rw [Negation.real_neg _ hrf]; exact neg_nonpos.mpr hrn) hx.baseNonnegative hp.1
  have he := exponential (argument p x i) (FlushToZero.finite_flush _ hp.1) hnonpos
  exact ⟨⟨hx.baseFinite, hx.baseNonnegative, hrf, hp.1, he.1⟩, he.2⟩

theorem ranges (p : Platform) (division : DivisionBounds.Contract p.divide) (exponential : Exp2Range p)
    (x : Inputs) (hx : InputsBound x) (i : Fin 32) :
    RopeAngles.Finite p x i ∧ |real (value p x i)| ≤ (2 : ℝ)^(18 : Nat) := by
  have hf := frequency p division exponential x hx i
  have he : (RopeAngles.frequency p x i).isFinite = true := hf.1.exponentialFinite
  have hp := NativeMultiplication.range x.scale x.position (DyadicBounds.ceiling 1 18)
    hx.scaleFinite hx.positionFinite (cap 18 (by decide)).1 (by
      rw [(cap 18 (by decide)).2]
      simpa only [one_mul, zpow_ofNat] using
        mul_le_mul hx.scaleMagnitude hx.positionMagnitude (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1))
  have ho := NativeMultiplication.range (FlushToZero.mul x.scale x.position) (RopeAngles.frequency p x i)
    (DyadicBounds.ceiling 1 18) (FlushToZero.finite_flush _ hp.1) he (cap 18 (by decide)).1 (by
      rw [abs_of_nonneg hf.2.1]
      exact (mul_le_of_le_one_right (abs_nonneg _) hf.2.2).trans hp.2)
  exact ⟨⟨hf.1, ⟨⟨hx.scaleFinite, hx.positionFinite, hp.1⟩, he, ho.1⟩⟩,
    by simpa only [value, (cap 18 (by decide)).2, zpow_ofNat] using ho.2⟩

-- The first token has zero position. Its computed angle has zero real
-- value, despite the separately rounded frequency and scale calculations.
theorem zero_position (p : Platform) (division : DivisionBounds.Contract p.divide) (exponential : Exp2Range p)
    (x : Inputs) (hx : InputsBound x) (zeroPosition : real x.position = 0) (i : Fin 32) :
    real (value p x i) = 0 := by
  have hz : real (0 : Float32) = 0 := by rw [real_unpack]; exact Model.unpackedToReal_zero .positive
  have hf := frequency p division exponential x hx i
  have hp := NativeMultiplication.range x.scale x.position 0 hx.scaleFinite hx.positionFinite (by decide)
    (by rw [zeroPosition, abs_zero, mul_zero, hz])
  have ho := NativeMultiplication.range (FlushToZero.mul x.scale x.position) (RopeAngles.frequency p x i) 0
    (FlushToZero.finite_flush _ hp.1) hf.1.exponentialFinite (by decide) (by
      have he : real (FlushToZero.mul x.scale x.position) = 0 := abs_nonpos_iff.mp (hp.2.trans_eq hz)
      rw [he, abs_zero, zero_mul, hz])
  exact abs_nonpos_iff.mp (ho.2.trans_eq hz)

end Inference.Kernels.Attention.RopeAnglesRanges
