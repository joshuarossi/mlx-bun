import contracts.mlx.Numerics
import kernels.trellis.CodebookLoad

namespace Inference.Kernels.Trellis.CodebookAccuracy
open Contracts.Mlx.Numerics FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Float.Model.UnpackedFloat

-- Interpret the existing integer-scaled, exhaustively checked decoder bounds
-- in the same real-valued semantics used by the accumulator error theorem.
theorem scaled_real (v : Float32) (h : Codebook.FloatingPoint.representable v = true) :
    real v = (Codebook.FloatingPoint.scaled v : ℝ) / 2^32 := by
  rw [real_unpack]
  unfold Codebook.FloatingPoint.representable at h
  unfold Codebook.FloatingPoint.scaled
  cases hv : v.toModel.unpack <;> simp only [hv] at h ⊢
  case zero sign => simp
  case infinity => cases h
  case notANumber => cases h
  case finite sign mantissa exponent hm =>
    have he : -32 ≤ exponent := of_decide_eq_true h
    have hn : ((exponent+32).toNat : ℤ) = exponent+32 := Int.toNat_of_nonneg (by omega)
    have hp : (2 : ℝ)^((exponent+32).toNat) = (2 : ℝ)^exponent * 2^32 := by
      rw [← zpow_natCast, hn, zpow_add₀ (by norm_num)]
      norm_num
    cases sign <;>
      simp [Model.unpackedToReal_finite, Sign.apply, Formats.Flocq.bpow, Numerics.binaryRadix,
        Numerics.Radix.toReal, Model.modelSignBit, hp] <;> ring

noncomputable def ideal (s : BitVec 32) : ℝ := (Codebook.specification s : ℝ) * 4096 / 605391

theorem relative_error (s : BitVec 32) :
    |real (CodebookLoad.mathematicalCode s) - ideal s| ≤ |ideal s| / 2^23 := by
  obtain ⟨representable, accuracy⟩ := CodebookLoad.mathematicalCode_accuracy s
  have value := scaled_real _ representable
  have numeric :
      |(Codebook.FloatingPoint.scaled (CodebookLoad.mathematicalCode s) : ℝ)*605391 -
        (Codebook.specification s : ℝ)*4096*2^32| * 2^23 ≤
      |(Codebook.specification s : ℝ)*4096*2^32| := by
    unfold Codebook.FloatingPoint.errorNumerator at accuracy
    have castAccuracy := (Nat.cast_le (α := ℝ)).mpr accuracy
    norm_num at castAccuracy ⊢
    simpa using castAccuracy
  have he : (Codebook.FloatingPoint.scaled (CodebookLoad.mathematicalCode s) : ℝ)*605391 -
      (Codebook.specification s : ℝ)*4096*2^32 =
      (real (CodebookLoad.mathematicalCode s) - ideal s)*(2^32*605391) := by
    rw [value]
    unfold ideal
    ring
  have ht : (Codebook.specification s : ℝ)*4096*2^32 = ideal s*(2^32*605391) := by
    unfold ideal
    ring
  rw [he, ht, abs_mul, abs_mul] at numeric
  norm_num at numeric ⊢
  linarith

end Inference.Kernels.Trellis.CodebookAccuracy
