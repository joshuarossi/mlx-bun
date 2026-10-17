import models.qwen.Qwen38CopiedAttentionSamplerSource
import models.qwen.TokenInference
import layers.QuantizedEmbeddingParsedPipeline

namespace Inference.Models.Qwen.Qwen38CopiedTokenSource
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- The retained entry is the actual token-buffer/embedding memory execution.
-- Its output buffer is the copied model's input; the final sampler is built
-- from that model's actual logits buffer. Original global attention parameter
-- attachment and native cache-route eligibility remain separate obligations.
structure Execution (p : Pipeline) (sampling : LogSumExpRanges.Platform)
    (cache : p.graph.Cache n) (token : Fin 248320) (angle : RopeAngles.Inputs) where
  embedding : QuantizedEmbeddingMemory.Execution p.embedding token
  decode : Qwen38CopiedAttentionSamplerSource.Execution p.graph cache (p.embedding.forward token) angle sampling
  linked : decode.forward.source=embedding.forwardBuffer

variable {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache n}
  {token : Fin 248320} {angle : RopeAngles.Inputs}
  (execution : Execution p sampling cache token angle)

theorem actual_input : execution.decode.forward.source.bytes=
    execution.embedding.outputBuffer.bytes := by
  rw [execution.linked]
  exact execution.embedding.buffers_shared.1

theorem token_input : execution.embedding.tokenBuffer.read=token.val := execution.embedding.tokenBuffer.read_correct

theorem logits (column : Fin 248320) :
    (Qwen38CopiedAttentionExecution.logitsBuffer execution.decode.forward).read column=(p.run cache token angle).1 column :=
  Qwen38CopiedAttentionExecution.read_eq execution.decode.forward column

theorem source_token (unsigned : Bool)
    (native : CopiedAttentionChainParsed.Native p.graph.stages cache (p.embedding.forward token) angle
      execution.decode.forward.source execution.decode.forward.storage execution.decode.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native execution.decode.forward.finalParameters execution.decode.forward.allocation)
    (ranges : p.Ranges cache token angle) (lseNative : LogSumExpSourceHost.Attachment)
    (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)|≤(2:ℝ)^(23:Nat)) :
    QuantizedEmbeddingParsedPipeline.Certificate execution.embedding unsigned ∧
    FinalProjectionParsedSource.Certificate execution.decode.forward.finalParameters execution.decode.forward.allocation finalNative ∧
    Qwen38CopiedAttentionSamplerSource.Certificate execution.decode native lseNative ∧
    (ArgmaxLaunchSourceMemory.tokenMemory execution.decode.sampler.selection).map
      (fun memory=>(ByteMemory.load32 memory execution.decode.sampler.selection.destination).toNat)=
      some (GreedySampling.sample sampling (p.run cache token angle).1) :=
  ⟨QuantizedEmbeddingParsedPipeline.checked execution.embedding unsigned,
    Qwen38CopiedAttentionSamplerSource.complete_source_token execution.decode native finalNative ranges.graph.output
      lseNative primitive bound⟩

theorem token_read (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)|≤(2:ℝ)^(23:Nat)) :
    (ByteMemory.load32 execution.decode.sampler.memory execution.decode.sampler.selection.destination).toNat=
      GreedySampling.sample sampling (p.run cache token angle).1 :=
  Qwen38CopiedAttentionSamplerSource.token_read execution.decode primitive bound

end Inference.Models.Qwen.Qwen38CopiedTokenSource
