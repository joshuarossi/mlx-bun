import models.qwen.TokenParameterConstruction
import layers.QuantizedEmbeddingParsedPipeline
import models.qwen.EmbeddingRanges

namespace Inference.Models.Qwen.TokenEmbeddingParsedConstruction
open Contracts.Mlx Layers TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {time : Nat} {before : TokenAutoregressiveMemory.State p time}
  (original : TokenParameterMemory.Storage p before.index.bytes)
  (plan : TokenParameterConstruction.EmbeddingPlan original)

-- The source execution is constructed from the preceding physical token
-- and the one original model bundle. The plan supplies only output regions
-- and spatial protection, not another token or embedding weight witness.
theorem original_weights : plan.entry.embedding.storage=original.embedding := rfl

theorem original_token : plan.entry.embedding.tokenBuffer=before.index := rfl

theorem parsed (unsigned : Bool) :
    QuantizedEmbeddingParsedPipeline.Certificate plan.entry.embedding unsigned :=
  QuantizedEmbeddingParsedPipeline.checked plan.entry.embedding unsigned

theorem source_and_output (unsigned : Bool) :
    QuantizedEmbeddingParsedPipeline.Certificate plan.entry.embedding unsigned ∧
    plan.entry.embedding.tokenBuffer.read=before.index.read ∧
    (∀ column, plan.entry.source.read column=p.embedding.forward before.logical.token column) :=
  ⟨parsed original plan unsigned,rfl,fun column => plan.entry.source.read_correct column⟩

-- Every remaining layer parameter and cache is retained on precisely the
-- actual embedding output heap used as the first stage's input.
theorem output_heap : plan.entry.source.bytes=plan.entry.embedding.outputBuffer.bytes :=
  plan.entry.embedding.buffers_shared.1

theorem retained_parameters (property : Nat → Nat → Prop) :
    plan.afterEmbedding.Protected property ↔ original.Protected property :=
  plan.afterEmbedding_protected property

theorem cache_readback : DecodeFrameRead.caches p.graph.stages before.logical.cache
    plan.entry.source.bytes plan.entry.storage=before.logical.cache :=
  DecodeFrameRead.caches_eq _ _ _ _

theorem retained_bytes (region : TokenParameterConstruction.Region original base size)
    (offset : Nat) (bound : offset<size) :
    plan.entry.source.bytes (base+offset)=before.index.bytes (base+offset) :=
  plan.entry.frame (region plan.regions.Live plan.parameters) offset bound

theorem source_and_error (parameters : TokenSequenceRanges.Parameters p) (unsigned : Bool) :
    QuantizedEmbeddingParsedPipeline.Certificate plan.entry.embedding unsigned ∧
    ∀ column, Model.isFinite (plan.entry.embedding.outputBuffer.read column)=true ∧
      |Model.toReal (plan.entry.embedding.outputBuffer.read column)-p.embedding.target before.logical.token column|≤
        p.embedding.budget before.logical.token column :=
  QuantizedEmbeddingParsedPipeline.source_and_error plan.entry.embedding unsigned
    (EmbeddingRanges.embedding_finite p.embedding parameters.embedding before.logical.token)

end Inference.Models.Qwen.TokenEmbeddingParsedConstruction
