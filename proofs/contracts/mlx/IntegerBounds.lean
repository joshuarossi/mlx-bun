import contracts.mlx.Float32Bounds
import FloatLib.Floats.Formats.IEEE754.Native.Integer.Constructors
import FloatLib.Floats.Formats.BinaryInterchange.DirectedSemantics.Exact

namespace Inference.Contracts.Mlx.IntegerBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange Numerics

def limit : Float32 := Float32.ofBits 0x4b800000

theorem limit_finite : limit.isFinite = true := by decide +kernel
theorem limit_real : real limit = 16777216 := by
  rw [real_unpack]
  change Model.unpackedToReal (.finite .positive 8388608 1 (by decide)) = 16777216
  norm_num [Model.unpackedToReal_finite, Model.modelSignBit, Formats.Flocq.bpow,
    FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal]

-- This covers dimensions, sequence positions and reduction counts used by
-- the graph. It proves the constructor itself exact; no native evaluation.
theorem natural (n : Nat) (hn : n < 16777216) :
    (Float32.ofInt n).isFinite = true ∧ real (Float32.ofInt n) = (n : ℝ) := by
  let d := FloatLib.Numerics.Dyadic.ofScaledInt (n : Int) 0
  have hd : d.toReal = (n : ℝ) := by
    simp [d, FloatLib.Numerics.Dyadic.ofScaledInt, FloatLib.Numerics.Dyadic.toReal,
      FloatLib.Numerics.Dyadic.signedSignificand]
  have hm : model (Float32.ofInt n) = Model.roundDyadic FloatFormat.binary32 d := by
    have h := ExecFloat.Binary.toModel_ofFloat32_ofInt (n : Int)
    rw [ExecFloat.Binary.toModel_ofFloat32] at h
    exact h
  have hbound : |d.toReal| ≤ Model.toReal (Model.posMaxFinite FloatFormat.binary32) := by
    rw [hd, abs_of_nonneg (Nat.cast_nonneg n)]
    apply le_trans ?_ (Float32Bounds.ceiling_max limit limit_finite)
    rw [limit_real]
    exact_mod_cast hn.le
  have h := Model.roundDyadic_of_representable FloatFormat.binary32 (by decide) d n 0
    (by simp [d, FloatLib.Numerics.Dyadic.ofScaledInt]) hn (by change (-149 : Int) ≤ 0; decide) hbound
  constructor
  · rw [← finite_model, hm]; exact h.1
  · change Model.toReal (model (Float32.ofInt n)) = _
    rw [hm, h.2, hd]

end Inference.Contracts.Mlx.IntegerBounds
