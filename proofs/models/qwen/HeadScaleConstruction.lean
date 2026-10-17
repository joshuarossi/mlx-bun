import contracts.mlx.TensorWords
import contracts.mlx.BFloat16DyadicBounds
import FloatLib.Floats.Formats.BinaryInterchange.Conversion.Cast.Proof

namespace Inference.Models.Qwen.HeadScaleConstruction
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value
abbrev Double := Model FloatFormat.binary64

-- Source translation of packages/mlx/src/ops.ts bf16Bytes/filledBf16.
-- JS Float32Array conversion uses the IEEE binary64 -> binary32 cast;
-- unsigned bit operations use their 32-bit modular semantics.
def bf16Word (bits : BitVec 32) : BitVec 16 :=
  if ((bits >>> 23) &&& 0xff) = 0xff then
    if (bits &&& 0x7fffff) ≠ 0 then ((bits >>> 16).setWidth 16 ||| 0x40)
    else (bits >>> 16).setWidth 16
  else ((bits + 0x7fff + ((bits >>> 16) &&& 1)) >>> 16).setWidth 16

def hostWord (value : Double) : BitVec 16 :=
  bf16Word (Model.cast FloatFormat.binary64 FloatFormat.binary32 value).bits
def filledBytes (word : BitVec 16) (i : Fin (2*128)) : BitVec 8 :=
  if i.val % 2 = 0 then TensorWords.lowByte word else TensorWords.highByte word
def filled (value : Double) : Fin 128 → BF := TensorWords.readBFloat16 (filledBytes (hostWord value))

theorem filled_word (word : BitVec 16) (i : Fin 128) :
    TensorWords.readWord (filledBytes word) i = word := by
  apply TensorWords.readWord_exact (filledBytes word) (fun _ => word)
  · intro j
    simp [filledBytes]
  · intro j
    simp [filledBytes]

theorem filled_value (value : Double) (i : Fin 128) : filled value i = (Model.ofBits (hostWord value) : BF) := by
  unfold filled TensorWords.readBFloat16
  rw [filled_word]

-- Observed Math.pow(128,-0.5) result in the selected Bun host. The proof
-- below certifies construction FROM these bits; binding Math.pow to them
-- remains an explicit host-execution premise, not a claimed pow proof.
def inverse : Double := Model.ofBits 0x3fb6a09e667f3bcc
def query : Fin 128 → BF := filled (Model.mul inverse inverse)
def key : Fin 128 → BF := filled inverse

theorem query_word : hostWord (Model.mul inverse inverse) = 0x3c00 := by decide +kernel
theorem key_word : hostWord inverse = 0x3db5 := by decide +kernel

theorem query_value (i : Fin 128) : query i = BFloat16DyadicBounds.ceiling 1 (-7) := by
  rw [query, filled_value, query_word]
  decide +kernel
theorem key_value (i : Fin 128) : key i = BFloat16DyadicBounds.ceiling 181 (-11) := by
  rw [key, filled_value, key_word]
  decide +kernel

theorem query_bound (i : Fin 128) :
    Model.isFinite (query i) = true ∧ Model.toReal (query i) = (1/128 : ℝ) := by
  rw [query_value]
  have h := BFloat16DyadicBounds.ceiling_range 1 (-7) (by decide) (by decide) (by decide)
  norm_num at h
  exact h
theorem key_bound (i : Fin 128) :
    Model.isFinite (key i) = true ∧ Model.toReal (key i) = (181/2048 : ℝ) := by
  rw [key_value]
  have h := BFloat16DyadicBounds.ceiling_range 181 (-11) (by decide) (by decide) (by decide)
  norm_num at h
  exact h
theorem key_energy_scale (i : Fin 128) : |Model.toReal (key i)| ≤ (23/256 : ℝ) := by
  rw [(key_bound i).2]
  norm_num

-- These equalities connect the exact host construction to the constants
-- used by the graph's range proof without replacing it with a bounds test.
theorem construction (powResult : Double) (host : powResult = inverse) :
    filled (Model.mul powResult powResult) = query ∧ filled powResult = key := by
  subst powResult
  exact ⟨rfl, rfl⟩

end Inference.Models.Qwen.HeadScaleConstruction
