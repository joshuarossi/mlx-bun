import models.qwen.TokenParameterConstruction
namespace Inference.Models.Qwen.FinalParameterFrameBases
open Contracts.Mlx Layers TokenInference
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  TokenAutoregressiveMemoryConstruction.Entry.source TokenAutoregressiveMemoryConstruction.Entry.storage

-- Prove projection-only facts with symbolic bundles before substituting a
-- concrete embedding plan or a 64-stage chain into their dependent fields.
theorem graph_norm_base {graph : Qwen38TrellisM1Max.Graph} {memory : ByteMemory.Bytes}
    (s : Qwen38TrellisM1MaxParameterMemory.Storage graph memory) (after : ByteMemory.Bytes)
    (same : s.Protected (fun base size => ∀ offset<size,after (base+offset)=memory (base+offset))) :
    (s.reframe after same).norm.base=s.norm.base := rfl

theorem token_norm_base {p : Pipeline} {memory : ByteMemory.Bytes}
    (s : TokenParameterMemory.Storage p memory) (after : ByteMemory.Bytes)
    (same : s.Protected (fun base size => ∀ offset<size,after (base+offset)=memory (base+offset))) :
    (s.reframe after same).graph.norm.base=s.graph.norm.base :=
  graph_norm_base s.graph after same.2.2.2

attribute [local irreducible] TokenParameterMemory.Storage.reframe Qwen38TrellisM1MaxParameterMemory.Storage.reframe

theorem afterEmbedding_norm_base {p : Pipeline} {time : Nat} {before : TokenAutoregressiveMemory.State p time}
    {original : TokenParameterMemory.Storage p before.index.bytes}
    (embedding : TokenParameterConstruction.EmbeddingPlan original) :
    embedding.afterEmbedding.graph.norm.base=original.graph.norm.base := by
  unfold TokenParameterConstruction.EmbeddingPlan.afterEmbedding
  exact token_norm_base original _ _

theorem fromFrame_norm_base {norm : Blocks.Norm} {projection : AffineVerifyLinear.Projection 10 248320}
    {input : Fin 5120 → ArrayStorage.BF}
    (before : ByteMemory.Bytes) (source : ArrayStorage.BFBuffer input) (region : Nat → Nat → Prop)
    (frame : ∀ base size,region base size → ∀ offset<size,source.bytes (base+offset)=before (base+offset))
    (normWeights : ArrayStorage.BFBuffer norm.weight) (normShared : normWeights.bytes=before)
    (outputWeights : AffineDevice.Storage projection) (outputShared : AffineMemory.Shared projection outputWeights before)
    (normSafe : region normWeights.base 10240)
    (outputSafe : AffineMemoryFrames.Protected projection outputWeights region) :
    (FinalProjectionConstruction.fromFrame before source region frame normWeights normShared outputWeights outputShared normSafe outputSafe).normWeights.base=
      normWeights.base := rfl
end Inference.Models.Qwen.FinalParameterFrameBases
