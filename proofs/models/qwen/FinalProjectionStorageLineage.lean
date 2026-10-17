import layers.AffineStorageLineage
import models.qwen.InitialCopiedTokenConstruction
import models.qwen.CapacityCopiedTokenConstruction

namespace Inference.Models.Qwen.FinalProjectionStorageLineage
open Contracts.Mlx Layers TokenInference AffineStorageLineage Kernels.Attention
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  TokenAutoregressiveMemoryConstruction.Entry.source TokenAutoregressiveMemoryConstruction.Entry.storage

theorem graph_addresses {graph : Qwen38TrellisM1Max.Graph} {memory : ByteMemory.Bytes}
    (original : Qwen38TrellisM1MaxParameterMemory.Storage graph memory) (after : ByteMemory.Bytes)
    (same : original.Protected (fun base size => ∀ offset<size,after (base+offset)=memory (base+offset))) :
    addresses graph.output (original.reframe after same).output=addresses graph.output original.output :=
  reframe_addresses graph.output original.output after
    (AffineMemoryFrames.stable _ _ _ _ original.outputShared same.2.2)

theorem token_addresses {p : Pipeline} {memory : ByteMemory.Bytes}
    (original : TokenParameterMemory.Storage p memory) (after : ByteMemory.Bytes)
    (same : original.Protected (fun base size => ∀ offset<size,after (base+offset)=memory (base+offset))) :
    addresses p.graph.output (original.reframe after same).graph.output=addresses p.graph.output original.graph.output :=
  graph_addresses original.graph after same.2.2.2

attribute [local irreducible] TokenParameterMemory.Storage.reframe Qwen38TrellisM1MaxParameterMemory.Storage.reframe

theorem embedding_addresses {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p n}
    {original : TokenParameterMemory.Storage p before.index.bytes}
    (embedding : TokenParameterConstruction.EmbeddingPlan original) :
    addresses p.graph.output embedding.afterEmbedding.graph.output=addresses p.graph.output original.graph.output := by
  unfold TokenParameterConstruction.EmbeddingPlan.afterEmbedding
  exact token_addresses original _ _

theorem frame_addresses {norm : Blocks.Norm} {projection : AffineVerifyLinear.Projection 10 248320}
    {input : Fin 5120 → ArrayStorage.BF}
    (before : ByteMemory.Bytes) (source : ArrayStorage.BFBuffer input) (region : Nat → Nat → Prop)
    (frame : ∀ base size,region base size → ∀ offset<size,source.bytes (base+offset)=before (base+offset))
    (normWeights : ArrayStorage.BFBuffer norm.weight) (normShared : normWeights.bytes=before)
    (outputWeights : AffineDevice.Storage projection) (outputShared : AffineMemory.Shared projection outputWeights before)
    (normSafe : region normWeights.base 10240) (outputSafe : AffineMemoryFrames.Protected projection outputWeights region) :
    addresses projection
      (FinalProjectionConstruction.fromFrame before source region frame normWeights normShared outputWeights outputShared normSafe outputSafe).outputWeights=
      addresses projection outputWeights :=
  reframe_addresses projection outputWeights source.bytes
    (AffineMemoryFrames.stable projection outputWeights before source.bytes outputShared
      (AffineMemoryFrames.protected_mono projection outputWeights (fun _ _ safe => frame _ _ safe) outputSafe))

theorem output_addresses {norm : Blocks.Norm} {projection : AffineVerifyLinear.Projection 10 248320}
    {input : Fin 5120 → ArrayStorage.BF}
    (storage : FinalProjectionConstruction.Storage norm projection input)
    (allocation : FinalProjectionConstruction.Allocation storage) :
    addresses projection (launchWeights (FinalProjectionConstruction.output storage allocation))=
      addresses projection storage.outputWeights := by
  unfold FinalProjectionConstruction.output
  rw [fromStorage_addresses (steps:=10) (groups:=62080)]
  exact reframe_addresses projection storage.outputWeights _ _

theorem initial_addresses {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
    {original : TokenParameterMemory.Storage p before.index.bytes}
    {embedding : TokenParameterConstruction.EmbeddingPlan original} {angle : RopeAngles.Inputs}
    (body : InitialCopiedTokenConstruction.BodyPlan embedding angle) :
    addresses p.graph.output body.finalStorage.outputWeights=addresses p.graph.output original.graph.output :=
  (frame_addresses embedding.entry.source.bytes body.hiddenBuffer (InitialCopiedTokenConstruction.ChainSafe embedding body.chain)
    (fun _ _ safe => body.frame safe) embedding.afterEmbedding.graph.norm embedding.afterEmbedding.graph.normShared
    embedding.afterEmbedding.graph.output embedding.afterEmbedding.graph.outputShared
    body.parameters.2.2.2.2.1 body.parameters.2.2.2.2.2).trans (embedding_addresses embedding)

theorem capacity_addresses {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p (n+1)}
    {original : TokenParameterMemory.Storage p before.index.bytes}
    {embedding : TokenParameterConstruction.EmbeddingPlan original} {angle : RopeAngles.Inputs}
    (body : CapacityCopiedTokenConstruction.BodyPlan embedding angle) :
    addresses p.graph.output body.finalStorage.outputWeights=addresses p.graph.output original.graph.output :=
  (frame_addresses embedding.entry.source.bytes body.hiddenBuffer (CapacityCopiedTokenConstruction.ChainSafe embedding body.chain)
    (fun _ _ safe => body.frame safe) embedding.afterEmbedding.graph.norm embedding.afterEmbedding.graph.normShared
    embedding.afterEmbedding.graph.output embedding.afterEmbedding.graph.outputShared
    body.parameters.2.2.2.2.1 body.parameters.2.2.2.2.2).trans (embedding_addresses embedding)

end Inference.Models.Qwen.FinalProjectionStorageLineage
