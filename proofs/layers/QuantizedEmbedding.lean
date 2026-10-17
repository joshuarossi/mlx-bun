import kernels.quantization.AffineDequantizeBounds

namespace Inference.Layers.QuantizedEmbedding
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels.Quantization
abbrev BF := BFloat16Arithmetic.Value

-- The selected artifact's embedding is affine 4-bit, group size 64, with
-- 248320 rows of width 5120. takeAxis selects packed words, scales and biases
-- for the same token before affine_dequantize is applied to that row.
structure Layer where
  words : Fin 248320 → Fin 640 → BitVec 32
  scales : Fin 248320 → Fin 80 → BF
  biases : Fin 248320 → Fin 80 → BF
  contracted : Bool

def wordIndex (i : Fin 5120) : Fin 640 := ⟨i.val/8, by have := i.isLt; omega⟩
def wordByte (b : Fin 2560) : Fin 640 := ⟨b.val/4, by have := b.isLt; omega⟩
def bytes (words : Fin 640 → BitVec 32) (b : Fin 2560) : BitVec 8 :=
  (words (wordByte b) >>> (8*(b.val%4))).setWidth 8
def packedCode (words : Fin 640 → BitVec 32) (i : Fin 5120) : Fin 16 :=
  ⟨(words (wordIndex i)).toNat / 2^(4*(i.val%8)) % 16, Nat.mod_lt _ (by decide)⟩

theorem byte_code (w : BitVec 32) (b : Fin 4) (i : Fin 2) :
    (AffineDequantize.code ((w >>> (8*b.val)).setWidth 8) i).val = w.toNat / 2^(4*(2*b.val+i.val)) % 16 := by
  fin_cases b <;> fin_cases i <;>
    norm_num [AffineDequantize.code, BitVec.toNat_setWidth, BitVec.toNat_ushiftRight, Nat.shiftRight_eq_div_pow] <;> omega

theorem coordinate_code (words : Fin 640 → BitVec 32) (i : Fin 5120) :
    AffineDequantize.code (bytes words (AffineDequantize.byteIndex i)) (AffineDequantize.byteCoordinate i) = packedCode words i := by
  have hw : wordByte (AffineDequantize.byteIndex i) = wordIndex i := by
    apply Fin.ext
    dsimp [wordByte, wordIndex, AffineDequantize.byteIndex]
    omega
  have hi : 2*((i.val/2)%4)+i.val%2 = i.val%8 := by omega
  apply Fin.ext
  unfold bytes
  rw [hw]
  have h := byte_code (words (wordIndex i)) ⟨(i.val/2)%4, Nat.mod_lt _ (by decide)⟩ (AffineDequantize.byteCoordinate i)
  simpa only [AffineDequantize.byteIndex, AffineDequantize.byteCoordinate, hi, packedCode] using h

def Layer.forward (l : Layer) (token : Fin 248320) : Fin 5120 → BF :=
  AffineDequantize.row l.contracted (bytes (l.words token)) (l.scales token) (l.biases token)
noncomputable def Layer.target (l : Layer) (token : Fin 248320) (i : Fin 5120) : ℝ :=
  Model.toReal (l.scales token (AffineDequantize.groupIndex i)) * (packedCode (l.words token) i).val +
    Model.toReal (l.biases token (AffineDequantize.groupIndex i))
noncomputable def Layer.budget (l : Layer) (token : Fin 248320) : Fin 5120 → ℝ :=
  AffineDequantize.rowBudget l.contracted (bytes (l.words token)) (l.scales token) (l.biases token)
def Layer.Finite (l : Layer) (token : Fin 248320) : Prop :=
  AffineDequantize.RowFinite l.contracted (bytes (l.words token)) (l.scales token) (l.biases token)

theorem Layer.forward_error (l : Layer) (token : Fin 248320) (hf : l.Finite token) (i : Fin 5120) :
    |Model.toReal (l.forward token i) - l.target token i| ≤ l.budget token i := by
  have h := AffineDequantize.row_error l.contracted (bytes (l.words token)) (l.scales token) (l.biases token) hf i
  simp only [AffineDequantize.rowTarget, AffineDequantize.target, coordinate_code] at h
  exact h
theorem Layer.forward_finite (l : Layer) (token : Fin 248320) (hf : l.Finite token) (i : Fin 5120) :
    Model.isFinite (l.forward token i) = true :=
  AffineDequantize.row_finite l.contracted (bytes (l.words token)) (l.scales token) (l.biases token) hf i

theorem Layer.finite_of_bounds (l : Layer) (token : Fin 248320)
    (bounds : ∀ g, AffineDequantizeBounds.Bounds (l.scales token g) (l.biases token g)) : l.Finite token :=
  AffineDequantizeBounds.row_finite l.contracted (bytes (l.words token)) (l.scales token) (l.biases token) bounds

theorem Layer.forward_bounded (l : Layer) (token : Fin 248320)
    (bounds : ∀ g, AffineDequantizeBounds.Bounds (l.scales token g) (l.biases token g)) (i : Fin 5120) :
    |Model.toReal (l.forward token i)| ≤ Model.toReal (bounds (AffineDequantize.groupIndex i)).outputCeiling :=
  AffineDequantizeBounds.row_bounded l.contracted (bytes (l.words token)) (l.scales token) (l.biases token) bounds i

-- Logical takeAxis offsets for contiguous rows; out-of-range token IDs are
-- excluded by the input contract, not silently wrapped into the vocabulary.
def takeRow (width : Nat) (storage : Nat → α) (token : Fin 248320) (i : Fin width) : α :=
  storage (token.val*width+i.val)
theorem takeRow_bounds (width : Nat) (token : Fin 248320) (i : Fin width) :
    token.val*width+i.val < 248320*width := by
  have := token.isLt
  have := i.isLt
  nlinarith
theorem takeRow_exact (width : Nat) (storage : Nat → α) (rows : Fin 248320 → Fin width → α)
    (layout : ∀ token i, storage (token.val*width+i.val) = rows token i) (token : Fin 248320) (i : Fin width) :
    takeRow width storage token i = rows token i := layout token i

end Inference.Layers.QuantizedEmbedding
