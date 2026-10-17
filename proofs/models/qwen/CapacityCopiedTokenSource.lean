import models.qwen.CapacityAttentionDerivedNative
import models.qwen.Qwen38CapacityAttentionExecution
import models.qwen.FinalProjectionSamplerSource
import models.qwen.TokenInference
import layers.QuantizedEmbeddingParsedPipeline
namespace Inference.Models.Qwen.CapacityCopiedTokenSource
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- Positive capacity cache routes retain both optional preservation copies and
-- their parsed current-heap row updates throughout the complete token path.
structure Execution (p : Pipeline) (sampling : LogSumExpRanges.Platform) {n : Nat}
    (cache : p.graph.Cache n) (token : Fin 248320) (angle : RopeAngles.Inputs) where
  embedding : QuantizedEmbeddingMemory.Execution p.embedding token
  forward : Qwen38CapacityAttentionExecution.Execution p.graph cache (p.embedding.forward token) angle
  linked : forward.source=embedding.forwardBuffer
  final : FinalProjectionSamplerSource.Execution forward.finalParameters forward.allocation sampling

variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache n}
  {token : Fin 248320} {angle : RopeAngles.Inputs} (execution : Execution p sampling cache token angle)

theorem actual_input : execution.forward.source.bytes=execution.embedding.outputBuffer.bytes := by
  rw [execution.linked]
  exact execution.embedding.buffers_shared.1

theorem token_input : execution.embedding.tokenBuffer.read=token.val := execution.embedding.tokenBuffer.read_correct

theorem final_input : execution.forward.finalParameters.source=CapacityAttentionDecodeChain.outputBuffer
    p.graph.stages cache (p.embedding.forward token) angle execution.forward.source execution.forward.storage execution.forward.chain :=
  execution.forward.linked

theorem logits (column : Fin 248320) :
    (Qwen38CapacityAttentionExecution.logitsBuffer execution.forward).read column=(p.run cache token angle).1 column :=
  Qwen38CapacityAttentionExecution.read_eq execution.forward column

structure Certificate (unsigned : Bool)
    (native : CapacityAttentionChainParsed.Native p.graph.stages cache (p.embedding.forward token) angle
      execution.forward.source execution.forward.storage execution.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native execution.forward.finalParameters execution.forward.allocation)
    (lseNative : LogSumExpSourceHost.Attachment) : Prop where
  embedding : QuantizedEmbeddingParsedPipeline.Certificate execution.embedding unsigned
  initial : CapacityAttentionChainParsed.Parsed p.graph.stages cache (p.embedding.forward token) angle
    execution.forward.source execution.forward.storage execution.forward.chain native
  final : FinalProjectionSamplerSource.Certificate execution.final finalNative lseNative

theorem checked (unsigned : Bool)
    (native : CapacityAttentionChainParsed.Native p.graph.stages cache (p.embedding.forward token) angle
      execution.forward.source execution.forward.storage execution.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native execution.forward.finalParameters execution.forward.allocation)
    (ranges : p.Ranges cache token angle) (lseNative : LogSumExpSourceHost.Attachment)
    (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat)) :
    Certificate execution unsigned native finalNative lseNative :=
  ⟨QuantizedEmbeddingParsedPipeline.checked execution.embedding unsigned,
    CapacityAttentionChainParsed.checked _ _ _ _ _ _ _ native,
    FinalProjectionSamplerSource.checked execution.final finalNative ranges.graph.output lseNative primitive bound⟩

theorem source_token (unsigned : Bool)
    (native : CapacityAttentionChainParsed.Native p.graph.stages cache (p.embedding.forward token) angle
      execution.forward.source execution.forward.storage execution.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native execution.forward.finalParameters execution.forward.allocation)
    (ranges : p.Ranges cache token angle) (lseNative : LogSumExpSourceHost.Attachment)
    (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat)) :
    Certificate execution unsigned native finalNative lseNative ∧
      (ArgmaxLaunchSourceMemory.tokenMemory execution.final.sampler.selection).map
        (fun memory=>(ByteMemory.load32 memory execution.final.sampler.selection.destination).toNat)=
        some (GreedySampling.sample sampling (p.run cache token angle).1) :=
  ⟨checked execution unsigned native finalNative ranges lseNative primitive bound,
    (FinalProjectionSamplerSource.source_token execution.final finalNative ranges.graph.output lseNative primitive bound).2⟩

theorem token_read (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat)) :
    (ByteMemory.load32 execution.final.sampler.memory execution.final.sampler.selection.destination).toNat=
      GreedySampling.sample sampling (p.run cache token angle).1 :=
  FinalProjectionSamplerSource.token_read execution.final primitive bound

-- Native input records exclude finite fields. Original model ranges insert
-- those contracts along this exact positive-capacity chain.
theorem derived_source_token (unsigned : Bool)
    (inputs : CapacityAttentionDerivedNative.Inputs p.graph.stages cache (p.embedding.forward token) angle
      execution.forward.source execution.forward.storage execution.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native execution.forward.finalParameters execution.forward.allocation)
    (ranges : p.Ranges cache token angle) (supported : n+1≤262144) (lseNative : LogSumExpSourceHost.Attachment)
    (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat)) :
    Certificate execution unsigned
      (CapacityAttentionDerivedNative.native p.graph.stages cache (p.embedding.forward token) angle
        execution.forward.source execution.forward.storage execution.forward.chain inputs ranges.graph.chain supported)
      finalNative lseNative ∧
      (ArgmaxLaunchSourceMemory.tokenMemory execution.final.sampler.selection).map
        (fun memory=>(ByteMemory.load32 memory execution.final.sampler.selection.destination).toNat)=
        some (GreedySampling.sample sampling (p.run cache token angle).1) :=
  source_token execution unsigned
    (CapacityAttentionDerivedNative.native p.graph.stages cache (p.embedding.forward token) angle
      execution.forward.source execution.forward.storage execution.forward.chain inputs ranges.graph.chain supported)
    finalNative ranges lseNative primitive bound
end Inference.Models.Qwen.CapacityCopiedTokenSource
