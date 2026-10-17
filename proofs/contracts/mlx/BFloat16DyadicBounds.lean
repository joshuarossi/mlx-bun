import contracts.mlx.DyadicBounds
import contracts.mlx.BFloat16Bounds

namespace Inference.Contracts.Mlx.BFloat16DyadicBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

def ceiling (count : Nat) (exponent : Int) : BF := Model.roundDyadic FloatFormat.bfloat16 ⟨false, count, exponent⟩
def large : BF := Model.ofBits 0x7f00
theorem large_finite : Model.isFinite large = true := by decide +kernel
theorem large_real : Model.toReal large = (2 : ℝ)^(127 : Nat) := by
  rw [Model.toReal_eq_unpackedToReal_toModel (by decide)]
  change Model.unpackedToReal (.finite .positive 128 120 (by decide)) = _
  norm_num [Model.unpackedToReal_finite, Model.modelSignBit, Formats.Flocq.bpow,
    FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal]

theorem ceiling_range (count : Nat) (exponent : Int) (hc : count < 256)
    (lo : -133 ≤ exponent) (hi : exponent ≤ 119) :
    Model.isFinite (ceiling count exponent) = true ∧ Model.toReal (ceiling count exponent) = (count : ℝ) * (2 : ℝ)^exponent := by
  let d : FloatLib.Numerics.Dyadic := ⟨false, count, exponent⟩
  have hd : d.toReal = (count : ℝ) * (2 : ℝ)^exponent := by
    simp [d, FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand]
  have he : (2 : ℝ)^exponent ≤ (2 : ℝ)^(119 : Int) := zpow_le_zpow_right₀ (by norm_num) hi
  have hb : |d.toReal| ≤ Model.toReal (Model.posMaxFinite FloatFormat.bfloat16) := by
    rw [hd, abs_of_nonneg (mul_nonneg (Nat.cast_nonneg _) (zpow_nonneg (by norm_num) _))]
    apply le_trans ?_ (BFloat16Bounds.ceiling_max large large_finite)
    rw [large_real]
    calc
      _ ≤ (256 : ℝ) * (2 : ℝ)^(119 : Int) :=
        mul_le_mul (by exact_mod_cast hc.le) he (zpow_nonneg (by norm_num) _) (by norm_num)
      _ ≤ _ := by norm_num
  have h := Model.roundDyadic_of_representable FloatFormat.bfloat16 (by decide) d count 0
    (by simp [d]) hc lo hb
  exact ⟨h.1, h.2.trans hd⟩

end Inference.Contracts.Mlx.BFloat16DyadicBounds
