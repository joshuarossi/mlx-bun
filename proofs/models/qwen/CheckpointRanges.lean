import contracts.mlx.TensorWords
import models.qwen.CheckpointTransforms
import models.qwen.EmbeddingRanges

namespace Inference.Models.Qwen.CheckpointRanges
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- Certificate inputs are exact byte vectors. The acceptance equalities
-- are proof obligations for the offline verifier, not inference-time checks.
def flatIndex (row : Fin rows) (column : Fin columns) : Fin (rows * columns) :=
  ⟨row.val * columns + column.val, by have := row.isLt; have := column.isLt; nlinarith⟩
def matrix (bytes : Fin (2 * (rows * columns)) → BitVec 8) (row : Fin rows) (column : Fin columns) : BF :=
  TensorWords.readBFloat16 bytes (flatIndex row column)

theorem matrix_bound (bytes : Fin (2 * (rows * columns)) → BitVec 8) (cap : BF)
    (checked : TensorWords.check (List.ofFn (TensorWords.readBFloat16 bytes)) cap = true)
    (row : Fin rows) (column : Fin columns) :
    Model.isFinite (matrix bytes row column) = true ∧ |Model.toReal (matrix bytes row column)| ≤ Model.toReal cap :=
  TensorWords.readBFloat16_bound bytes cap checked (flatIndex row column)

def zeroCap : BF := Model.ofBits 0
def threeCap : BF := BFloat16DyadicBounds.ceiling 3 0
def embeddingScaleCap : BF := BFloat16DyadicBounds.ceiling 1 (-6)
def embeddingBiasCap : BF := BFloat16DyadicBounds.ceiling 1 (-3)

theorem zeroCap_real : Model.toReal zeroCap = 0 := by
  change Model.toReal (Model.zero FloatFormat.bfloat16 false) = 0
  exact Model.toReal_zero _ _
theorem threeCap_real : Model.toReal threeCap = 3 := by
  have h := (BFloat16DyadicBounds.ceiling_range 3 0 (by decide) (by decide) (by decide)).2
  norm_num at h
  exact h
theorem embeddingScaleCap_real : Model.toReal embeddingScaleCap = (1 : ℝ)/64 := by
  have h := (BFloat16DyadicBounds.ceiling_range 1 (-6) (by decide) (by decide) (by decide)).2
  norm_num at h
  exact h
theorem embeddingBiasCap_real : Model.toReal embeddingBiasCap = (1 : ℝ)/8 := by
  have h := (BFloat16DyadicBounds.ceiling_range 1 (-3) (by decide) (by decide) (by decide)).2
  norm_num at h
  exact h

theorem shifted_zero_norm (bytes : Fin (2*n) → BitVec 8)
    (checked : TensorWords.check (List.ofFn (TensorWords.readBFloat16 bytes)) zeroCap = true) :
    ∀ i, Model.isFinite (CheckpointTransforms.shiftNorm (TensorWords.readBFloat16 bytes) i) = true ∧
      |Model.toReal (CheckpointTransforms.shiftNorm (TensorWords.readBFloat16 bytes) i)| ≤ 1 := by
  have h i := TensorWords.readBFloat16_bound bytes zeroCap checked i
  apply CheckpointTransforms.zero_norm_bound _ (fun i => (h i).1)
  intro i
  exact abs_nonpos_iff.mp ((h i).2.trans_eq zeroCap_real)

theorem shifted_head_norm (bytes : Fin (2*n) → BitVec 8)
    (checked : TensorWords.check (List.ofFn (TensorWords.readBFloat16 bytes)) threeCap = true) :
    ∀ i, Model.isFinite (CheckpointTransforms.shiftNorm (TensorWords.readBFloat16 bytes) i) = true ∧
      |Model.toReal (CheckpointTransforms.shiftNorm (TensorWords.readBFloat16 bytes) i)| ≤ 4 := by
  apply CheckpointTransforms.head_norm_bound
  intro i
  simpa only [threeCap_real] using TensorWords.readBFloat16_bound bytes threeCap checked i

def embedding (words : Fin 248320 → Fin 640 → BitVec 32)
    (scales biases : Fin (2*(248320*80)) → BitVec 8) (contracted : Bool) : Layers.QuantizedEmbedding.Layer where
  words := words
  scales := matrix scales
  biases := matrix biases
  contracted := contracted

theorem embedding_parameters (words : Fin 248320 → Fin 640 → BitVec 32)
    (scales biases : Fin (2*(248320*80)) → BitVec 8) (contracted : Bool)
    (sc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 scales)) embeddingScaleCap = true)
    (bc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 biases)) embeddingBiasCap = true) :
    EmbeddingRanges.Parameters (embedding words scales biases contracted) where
  scalesFinite row column := (matrix_bound scales embeddingScaleCap sc row column).1
  biasesFinite row column := (matrix_bound biases embeddingBiasCap bc row column).1
  scalesBound row column := by
    simpa only [embedding, embeddingScaleCap_real] using (matrix_bound scales embeddingScaleCap sc row column).2
  biasesBound row column := by
    simpa only [embedding, embeddingBiasCap_real] using (matrix_bound biases embeddingBiasCap bc row column).2

theorem embedding_output (words : Fin 248320 → Fin 640 → BitVec 32)
    (scales biases : Fin (2*(248320*80)) → BitVec 8) (contracted : Bool)
    (sc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 scales)) embeddingScaleCap = true)
    (bc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 biases)) embeddingBiasCap = true)
    (token : Fin 248320) (i : Fin 5120) :
    Model.isFinite ((embedding words scales biases contracted).forward token i) = true ∧
      |Model.toReal ((embedding words scales biases contracted).forward token i)| ≤ (1 : ℝ)/2 := by
  let layer := embedding words scales biases contracted
  have parameters := embedding_parameters words scales biases contracted sc bc
  exact ⟨layer.forward_finite token (EmbeddingRanges.embedding_finite layer parameters token) i,
    EmbeddingRanges.embedding_bounded layer parameters token i⟩

def embeddingFromBytes (weights : Fin (4*(248320*640)) → BitVec 8)
    (scales biases : Fin (2*(248320*80)) → BitVec 8) (contracted : Bool) : Layers.QuantizedEmbedding.Layer :=
  embedding (fun row column => TensorWords.readWord32 weights (flatIndex row column)) scales biases contracted

theorem embeddingFromBytes_parameters (weights : Fin (4*(248320*640)) → BitVec 8)
    (scales biases : Fin (2*(248320*80)) → BitVec 8) (contracted : Bool)
    (sc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 scales)) embeddingScaleCap = true)
    (bc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 biases)) embeddingBiasCap = true) :
    EmbeddingRanges.Parameters (embeddingFromBytes weights scales biases contracted) :=
  embedding_parameters _ scales biases contracted sc bc

theorem embeddingFromBytes_error (weights : Fin (4*(248320*640)) → BitVec 8)
    (scales biases : Fin (2*(248320*80)) → BitVec 8) (contracted : Bool)
    (sc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 scales)) embeddingScaleCap = true)
    (bc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 biases)) embeddingBiasCap = true)
    (token : Fin 248320) (i : Fin 5120) :
    |Model.toReal ((embeddingFromBytes weights scales biases contracted).forward token i) -
      (embeddingFromBytes weights scales biases contracted).target token i| ≤
        (embeddingFromBytes weights scales biases contracted).budget token i := by
  let layer := embeddingFromBytes weights scales biases contracted
  exact layer.forward_error token (EmbeddingRanges.embedding_finite layer
    (embeddingFromBytes_parameters weights scales biases contracted sc bc) token) i

-- [C,1,4] and the materialized [C,4,1] share these exact contiguous words.
def convolution (bytes : Fin (2*(10240*4)) → BitVec 8) : Fin 10240 → Fin 4 → BF := matrix bytes
theorem convolution_bound (bytes : Fin (2*(10240*4)) → BitVec 8)
    (checked : TensorWords.check (List.ofFn (TensorWords.readBFloat16 bytes)) BFloat16Arithmetic.one = true) :
    ∀ c k, Model.isFinite (convolution bytes c k) = true ∧ |Model.toReal (convolution bytes c k)| ≤ 1 := by
  intro c k
  simpa only [convolution, BFloat16Arithmetic.real_one] using matrix_bound bytes BFloat16Arithmetic.one checked c k

end Inference.Models.Qwen.CheckpointRanges
