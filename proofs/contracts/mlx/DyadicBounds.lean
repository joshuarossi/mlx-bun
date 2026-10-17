import contracts.mlx.IntegerBounds
import contracts.mlx.BFloat16

namespace Inference.Contracts.Mlx.DyadicBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange Numerics

-- Exact representable ceilings for accumulators: count * 2^exponent.
-- These are proof-side constants, not new inference operations.
def ceiling (count : Nat) (exponent : Int) : Float32 := Float32.ofModel (Model.toFloat32Model
  (Model.roundDyadic FloatFormat.binary32 ⟨false, count, exponent⟩))

def large : Float32 := Float32.ofBits 0x7f000000
theorem large_finite : large.isFinite = true := by decide +kernel
theorem large_real : real large = (2 : ℝ) ^ (127 : Nat) := by
  rw [real_unpack]
  change Model.unpackedToReal (.finite .positive 8388608 104 (by decide)) = _
  norm_num [Model.unpackedToReal_finite, Model.modelSignBit, Formats.Flocq.bpow,
    FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal]

theorem ceiling_range (count : Nat) (exponent : Int) (hc : count < 16777216)
    (lo : -149 ≤ exponent) (hi : exponent ≤ 100) :
    (ceiling count exponent).isFinite = true ∧ real (ceiling count exponent) = (count : ℝ) * (2 : ℝ)^exponent := by
  let d : FloatLib.Numerics.Dyadic := ⟨false, count, exponent⟩
  have hd : d.toReal = (count : ℝ) * (2 : ℝ)^exponent := by
    simp [d, FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand]
  have he : (2 : ℝ)^exponent ≤ (2 : ℝ)^(100 : Int) := zpow_le_zpow_right₀ (by norm_num) hi
  have hb : |d.toReal| ≤ Model.toReal (Model.posMaxFinite FloatFormat.binary32) := by
    rw [hd, abs_of_nonneg (mul_nonneg (Nat.cast_nonneg _) (zpow_nonneg (by norm_num) _))]
    apply le_trans ?_ (Float32Bounds.ceiling_max large large_finite)
    rw [large_real]
    calc
      _ ≤ (16777216 : ℝ) * (2 : ℝ)^(100 : Int) :=
        mul_le_mul (by exact_mod_cast hc.le) he (zpow_nonneg (by norm_num) _) (by norm_num)
      _ ≤ _ := by norm_num
  have h := Model.roundDyadic_of_representable FloatFormat.binary32 (by decide) d count 0
    (by simp [d]) hc lo hb
  constructor
  · change (Model.toFloat32Model (Model.roundDyadic FloatFormat.binary32 d)).unpack.isFinite = true
    rw [Model.unpack_toFloat32Model, Model.isFinite_toModel (by decide)]
    exact h.1
  · unfold ceiling
    rw [BFloat16.bridge, h.2, hd]

-- Smaller reductions admit larger squared inputs without binary32 overflow.
theorem ceiling_range_wide (count : Nat) (exponent : Int) (hc : count ≤ 16384)
    (lo : -149 ≤ exponent) (hi : exponent ≤ 112) :
    (ceiling count exponent).isFinite = true ∧ real (ceiling count exponent) = (count : ℝ) * (2 : ℝ)^exponent := by
  let d : FloatLib.Numerics.Dyadic := ⟨false, count, exponent⟩
  have hd : d.toReal = (count : ℝ) * (2 : ℝ)^exponent := by
    simp [d, FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand]
  have he : (2 : ℝ)^exponent ≤ (2 : ℝ)^(112 : Int) := zpow_le_zpow_right₀ (by norm_num) hi
  have hb : |d.toReal| ≤ Model.toReal (Model.posMaxFinite FloatFormat.binary32) := by
    rw [hd, abs_of_nonneg (mul_nonneg (Nat.cast_nonneg _) (zpow_nonneg (by norm_num) _))]
    apply le_trans ?_ (Float32Bounds.ceiling_max large large_finite)
    rw [large_real]
    calc
      _ ≤ (16384 : ℝ) * (2 : ℝ)^(112 : Int) :=
        mul_le_mul (by exact_mod_cast hc) he (zpow_nonneg (by norm_num) _) (by norm_num)
      _ ≤ _ := by norm_num
  have h := Model.roundDyadic_of_representable FloatFormat.binary32 (by decide) d count 0
    (by simp [d]) (by change count < 16777216; omega) lo hb
  constructor
  · change (Model.toFloat32Model (Model.roundDyadic FloatFormat.binary32 d)).unpack.isFinite = true
    rw [Model.unpack_toFloat32Model, Model.isFinite_toModel (by decide)]
    exact h.1
  · unfold ceiling
    rw [BFloat16.bridge, h.2, hd]

end Inference.Contracts.Mlx.DyadicBounds
