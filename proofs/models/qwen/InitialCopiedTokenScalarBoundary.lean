import models.qwen.InitialCopiedScalarBoundary
import models.qwen.NativeCopiedHighWaterFrame

namespace Inference.Models.Qwen.InitialCopiedTokenScalarBoundary
open Contracts.Mlx Layers DecodeStage DecodeChain TokenInference Kernels.Attention Kernels.Copy Kernels.Sampling
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  TokenAutoregressiveMemoryConstruction.Entry.source TokenAutoregressiveMemoryConstruction.Entry.storage
  CopiedAttentionOriginalTailChains.Initial.TokenBuilt

private def lift {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
    {original : TokenParameterMemory.Storage p before.index.bytes} {angle : RopeAngles.Inputs}
    {sampling : LogSumExpRanges.Platform} (plan : InitialCopiedTokenConstruction.Plan original angle sampling)
    (tails : CopiedAttentionOriginalTailChains.Initial.TokenBuilt plan)
    (boundary : NativeCopiedConstructedInputs.Initial.BoundaryInputs p.graph.stages before.logical.cache
      (p.embedding.forward before.logical.token) angle plan.embedding.entry.source plan.embedding.entry.storage plan.graph.forward.chain) :
    NativeCopiedConstructedInputs.BoundaryInputs (NativeCopiedTokenConstruction.step (.initial plan tails)).execution := boundary

variable {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p before.index.bytes} {frontier : Frontier}
  (r : InitialCopiedTokenHighWater.Request original frontier) (angle : RopeAngles.Inputs)

include r in
private theorem embeddingRoom : frontier.cursor+13120≤2^64 := by
  have total := r.room
  dsimp only [InitialCopiedTokenHighWater.bytes] at total
  omega

private def currentZero (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
    (shared : zero.bytes=before.index.bytes) (below : zero.base+2≤frontier.cursor) :
    ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues :=
  ArrayFrame.bf zero (InitialCopiedTokenHighWater.embedding r).entry.source.bytes
    (fun offset bound => (NativeCopiedHighWaterFrame.embedding_frame frontier.aligned (embeddingRoom r)
      r.token r.parameters r.caches below offset bound).trans (congrFun shared _).symm)

abbrev chainSource := (InitialCopiedTokenHighWater.embedding r).entry.source
abbrev chainStorage := (InitialCopiedTokenHighWater.embedding r).entry.storage
abbrev chainParameters := (InitialCopiedTokenHighWater.embedding r).afterEmbedding.graph.stages
abbrev chainTrace := InitialCopiedTokenConstruction.buildChain (InitialCopiedTokenHighWater.embedding r)
  (InitialCopiedTokenHighWater.body r angle).chain

def BoundaryInputs := InitialCopiedScalarBoundary.BoundaryInputs p.graph.stages before.logical.cache
  (p.embedding.forward before.logical.token) angle (chainSource r) (chainStorage r) (chainTrace r angle)

include r in
private theorem chainRoom : (InitialCopiedTokenHighWater.start r).cursor+InitialCopiedWorkspace.bytes p.graph.stages≤2^64 := by
  have total := r.room
  dsimp only [InitialCopiedTokenHighWater.start,InitialCopiedTokenHighWater.bytes] at *
  omega

def chainInputs (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
    (shared : zero.bytes=before.index.bytes) (below : zero.base+2≤frontier.cursor)
    (boundary : BoundaryInputs r angle) :
    NativeCopiedConstructedInputs.Initial.BoundaryInputs p.graph.stages before.logical.cache
      (p.embedding.forward before.logical.token) angle (chainSource r) (chainStorage r) (chainTrace r angle) :=
  InitialCopiedScalarBoundary.inputs .root before.logical.cache (p.embedding.forward before.logical.token) angle
    (chainSource r) (chainStorage r) (chainParameters r) (InitialCopiedTokenHighWater.start r) (chainRoom r)
    (TokenBoundaryHighWater.embedding_output frontier.aligned (embeddingRoom r) r.token r.parameters r.caches).2
    (TokenBoundaryHighWater.embedding_parameters frontier.aligned (embeddingRoom r) r.token r.parameters r.caches).2.2.2.1
    (TokenBoundaryHighWater.embedding_caches frontier.aligned (embeddingRoom r) r.token r.parameters r.caches)
    (InitialCopiedEntryLineage.canonical (InitialCopiedTokenHighWater.embedding r).entry r.canonical) r.dispatches
    (currentZero r zero shared below) rfl (below.trans (Nat.le_add_right _ _)) boundary

variable (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
  (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

def inputs (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
    (shared : zero.bytes=before.index.bytes) (below : zero.base+2≤frontier.cursor)
    (boundary : BoundaryInputs r angle) : NativeCopiedConstructedInputs.BoundaryInputs
      (NativeCopiedTokenConstruction.step (InitialCopiedTokenHighWater.nativePlan r angle sampling lseLocal tileLocal finishLocal)).execution :=
  lift (InitialCopiedTokenHighWater.plan r angle sampling lseLocal tileLocal finishLocal)
    (InitialCopiedTokenHighWater.tails r angle sampling lseLocal tileLocal finishLocal)
    (chainInputs r angle zero shared below boundary)

theorem currentZero_base (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
    (shared : zero.bytes=before.index.bytes) (below : zero.base+2≤frontier.cursor) :
    (currentZero r zero shared below).base=zero.base := rfl

end Inference.Models.Qwen.InitialCopiedTokenScalarBoundary
