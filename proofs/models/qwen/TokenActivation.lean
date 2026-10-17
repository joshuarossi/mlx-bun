import models.qwen.DecodeActivation
import layers.QuantizedEmbeddingDevice

namespace Inference.Models.Qwen.TokenActivation
open Contracts.Mlx TokenInference DecodeStage Kernels.Attention
set_option maxRecDepth 10000

-- Logical row labels are attached to actual producer bytes by the proven
-- refinements. Reindexing a label never copies or replaces the byte image.
structure Execution (p : Pipeline) (cache : p.graph.Cache n) (token : Fin 248320) (angle : RopeAngles.Inputs)
    (storage : DecodeStorage.Storage p.graph.stages cache) where
  embedding : Layers.QuantizedEmbeddingDevice.Execution p.embedding token
  chain : DecodeActivation.ChainTrace p.graph.stages cache (p.embedding.forward token) angle storage embedding.forwardBuffer
  normalization : NormalizationDevice.Execution p.graph.finalNorm (p.graph.hidden cache (p.embedding.forward token) angle)
  normalizationInput : normalization.source=DecodeActivation.outputBuffer p.graph.stages cache (p.embedding.forward token) angle
    storage embedding.forwardBuffer chain
  projection : Layers.AffineDevice.Execution (groups := 62080) p.graph.output (p.graph.normalized cache (p.embedding.forward token) angle)
  projectionInput : projection.inputStorage=NormalizationDevice.forwardBuffer p.graph.finalNorm _ normalization

def Execution.fromNormalization (p : Pipeline) (cache : p.graph.Cache n) (token : Fin 248320) (angle : RopeAngles.Inputs)
    (storage : DecodeStorage.Storage p.graph.stages cache)
    (embedding : Layers.QuantizedEmbeddingDevice.Execution p.embedding token)
    (chain : DecodeActivation.ChainTrace p.graph.stages cache (p.embedding.forward token) angle storage embedding.forwardBuffer)
    (normalization : NormalizationDevice.Execution p.graph.finalNorm (p.graph.hidden cache (p.embedding.forward token) angle))
    (normalizationInput : normalization.source=DecodeActivation.outputBuffer p.graph.stages cache (p.embedding.forward token) angle
      storage embedding.forwardBuffer chain)
    (outputWeights : Layers.AffineDevice.Storage p.graph.output) :
    Execution p cache token angle storage :=
  let projection := Layers.AffineDevice.Execution.fromStorage (groups := 62080) p.graph.output _ outputWeights
    (NormalizationDevice.forwardBuffer p.graph.finalNorm _ normalization) (by decide)
  ⟨embedding, chain, normalization, normalizationInput, projection, Layers.AffineDevice.Execution.input_fromStorage _ _ _⟩

def Execution.fromChain (p : Pipeline) (cache : p.graph.Cache n) (token : Fin 248320) (angle : RopeAngles.Inputs)
    (storage : DecodeStorage.Storage p.graph.stages cache)
    (embedding : Layers.QuantizedEmbeddingDevice.Execution p.embedding token)
    (chain : DecodeActivation.ChainTrace p.graph.stages cache (p.embedding.forward token) angle storage embedding.forwardBuffer)
    (normWeights : ArrayStorage.BFBuffer p.graph.finalNorm.weight) (outputWeights : Layers.AffineDevice.Storage p.graph.output) :
    Execution p cache token angle storage :=
  Execution.fromNormalization p cache token angle storage embedding chain
    (NormalizationDevice.fromStorage p.graph.finalNorm _
      (DecodeActivation.outputBuffer p.graph.stages cache (p.embedding.forward token) angle storage embedding.forwardBuffer chain) normWeights)
    rfl outputWeights

def Execution.fromEmbedding (p : Pipeline) (cache : p.graph.Cache n) (token : Fin 248320) (angle : RopeAngles.Inputs)
    (storage : DecodeStorage.Storage p.graph.stages cache) (embedding : Layers.QuantizedEmbeddingDevice.Execution p.embedding token) :
    Execution p cache token angle storage :=
  Execution.fromChain p cache token angle storage embedding
    (DecodeActivation.ChainTrace.fromStorage p.graph.stages cache (p.embedding.forward token) angle storage embedding.forwardBuffer)
    (ArrayStorage.BFBuffer.canonical _ (by decide))
    (Layers.AffineDevice.Storage.canonical _ (by decide) (by decide) (by decide))

def Execution.fromStorage (p : Pipeline) (cache : p.graph.Cache n) (token : Fin 248320) (angle : RopeAngles.Inputs)
    (storage : DecodeStorage.Storage p.graph.stages cache) (weights : Layers.QuantizedEmbeddingDevice.Storage p.embedding) :
    Execution p cache token angle storage :=
  Execution.fromEmbedding p cache token angle storage (Layers.QuantizedEmbeddingDevice.Execution.fromStorage p.embedding token weights)

variable {n : Nat} {p : Pipeline} {cache : p.graph.Cache n} {token : Fin 248320} {angle : RopeAngles.Inputs}
  {storage : DecodeStorage.Storage p.graph.stages cache}

def Execution.logits (execution : Execution p cache token angle storage) : Fin 248320 → BF := execution.projection.output
def Execution.logitsBuffer (execution : Execution p cache token angle storage) : ArrayStorage.BFBuffer execution.logits :=
  execution.projection.outputBuffer

theorem Execution.logits_eq (execution : Execution p cache token angle storage) : execution.logits=(p.run cache token angle).1 :=
  execution.projection.output_eq

def Execution.after (execution : Execution p cache token angle storage) : DecodeStorage.Storage p.graph.stages (p.run cache token angle).2 :=
  DecodeActivation.after p.graph.stages cache (p.embedding.forward token) angle storage execution.embedding.forwardBuffer execution.chain

def Execution.run (execution : Execution p cache token angle storage) : (Fin 248320 → BF) × p.graph.Cache (n+1) :=
  (execution.logits, (p.run cache token angle).2)

theorem Execution.run_eq (execution : Execution p cache token angle storage) : execution.run=p.run cache token angle := by
  apply Prod.ext
  · exact execution.logits_eq
  · rfl

theorem Execution.embedding_bytes (execution : Execution p cache token angle storage) :
    execution.embedding.forwardBuffer.bytes=execution.embedding.output.memory := execution.embedding.forward_bytes

theorem Execution.normalization_bytes (execution : Execution p cache token angle storage) :
    execution.normalization.source.bytes=
      (DecodeActivation.outputBuffer p.graph.stages cache (p.embedding.forward token) angle storage execution.embedding.forwardBuffer execution.chain).bytes :=
  congrArg ArrayStorage.BFBuffer.bytes execution.normalizationInput

theorem Execution.projection_bytes (execution : Execution p cache token angle storage) :
    execution.projection.inputStorage.bytes=execution.normalization.stores.memory := by
  rw [execution.projectionInput, NormalizationDevice.forward_bytes]

theorem Execution.logits_bytes (execution : Execution p cache token angle storage) :
    execution.logitsBuffer.bytes=execution.projection.outputBuffer.bytes := rfl

theorem output_launch : 248320%8=0 ∧ 248320/4=62080 := by decide

end Inference.Models.Qwen.TokenActivation
