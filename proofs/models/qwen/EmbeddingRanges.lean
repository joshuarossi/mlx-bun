import layers.QuantizedEmbedding

namespace Inference.Models.Qwen.EmbeddingRanges
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels.Quantization
abbrev BF := BFloat16Arithmetic.Value

def quarter : BF := BFloat16.narrow (Float32.ofBits 0x3e800000)
def half : BF := BFloat16.narrow (Float32.ofBits 0x3f000000)
theorem quarter_finite : Model.isFinite quarter = true := by decide +kernel
theorem half_finite : Model.isFinite half = true := by decide +kernel
theorem quarter_real : Model.toReal quarter = (1 : ℝ)/4 := by
  rw [Model.toReal_eq_unpackedToReal_toModel (by decide)]
  change Model.unpackedToReal (.finite .positive 128 (-9) (by decide)) = (1 : ℝ)/4
  rw [Model.unpackedToReal_finite]
  norm_num [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow]
  change 128 * ((2 : ℝ)^9)⁻¹ = 1/4
  norm_num
theorem half_real : Model.toReal half = (1 : ℝ)/2 := by
  rw [Model.toReal_eq_unpackedToReal_toModel (by decide)]
  change Model.unpackedToReal (.finite .positive 128 (-8) (by decide)) = (1 : ℝ)/2
  rw [Model.unpackedToReal_finite]
  norm_num [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow]
  change 128 * ((2 : ℝ)^8)⁻¹ = 1/2
  norm_num

-- A weight-data contract; no claim is made here that the checkpoint bytes
-- have already been formally bound to this predicate. These inequalities
-- imply a uniform half-unit embedding bound for all token IDs and codes.
structure Parameters (l : Layers.QuantizedEmbedding.Layer) : Prop where
  scalesFinite : ∀ token g, Model.isFinite (l.scales token g) = true
  biasesFinite : ∀ token g, Model.isFinite (l.biases token g) = true
  scalesBound : ∀ token g, |Model.toReal (l.scales token g)| ≤ (1 : ℝ)/64
  biasesBound : ∀ token g, |Model.toReal (l.biases token g)| ≤ (1 : ℝ)/8

def bounds (l : Layers.QuantizedEmbedding.Layer) (hp : Parameters l) (token : Fin 248320) (g : Fin 80) :
    AffineDequantizeBounds.Bounds (l.scales token g) (l.biases token g) where
  scaleFinite := hp.scalesFinite token g
  biasFinite := hp.biasesFinite token g
  productCeiling := quarter
  outputCeiling := half
  productCeilingFinite := quarter_finite
  outputCeilingFinite := half_finite
  scaleBound := by rw [quarter_real]; linarith [hp.scalesBound token g]
  capacity := by rw [quarter_real, half_real]; linarith [hp.biasesBound token g]

theorem embedding_finite (l : Layers.QuantizedEmbedding.Layer) (hp : Parameters l) (token : Fin 248320) : l.Finite token :=
  l.finite_of_bounds token (bounds l hp token)

theorem embedding_bounded (l : Layers.QuantizedEmbedding.Layer) (hp : Parameters l) (token : Fin 248320) (i : Fin 5120) :
    |Model.toReal (l.forward token i)| ≤ (1 : ℝ)/2 := by
  have h := l.forward_bounded token (bounds l hp token) i
  simpa only [bounds, half_real] using h

end Inference.Models.Qwen.EmbeddingRanges
