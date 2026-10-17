import models.qwen.NativeCopiedHighWater
import models.qwen.FinalProjectionAllocatedNative

namespace Inference.Models.Qwen.NativeCopiedHighWaterFinalNative
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling Kernels.Normalization
open FloatLib.Floats.Formats.BinaryInterchange
open ResidualDeltaHighWater (Frontier)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  CopiedAttentionOriginalTailChains.Initial.TokenBuilt CopiedAttentionOriginalTailChains.Capacity.TokenBuilt
  InitialCopiedTokenConstruction.BodyPlan.hiddenBuffer CapacityCopiedTokenConstruction.BodyPlan.hiddenBuffer
  InitialCopiedTokenConstruction.BodyPlan.finalStorage CapacityCopiedTokenConstruction.BodyPlan.finalStorage
  TokenAutoregressiveMemoryConstruction.Entry.source TokenAutoregressiveMemoryConstruction.Entry.storage
  TokenParameterConstruction.EmbeddingPlan.afterEmbedding
  InitialCopiedTokenHighWater.body CapacityCopiedTokenHighWater.body
  InitialCopiedTokenHighWater.request CapacityCopiedTokenHighWater.request

namespace Initial
variable {p : Pipeline}  {before : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  {angle : RopeAngles.Inputs} {sampling : LogSumExpRanges.Platform}
  (plan : InitialCopiedTokenConstruction.Plan original angle sampling)
  (tails : CopiedAttentionOriginalTailChains.Initial.TokenBuilt plan)

def lift (native : FinalProjectionParsedSource.Native plan.graph.body.finalStorage plan.graph.allocation) :
    FinalProjectionParsedSource.Native
      (NativeCopiedTokenRoute.finalStorage (NativeCopiedTokenConstruction.step (.initial plan tails)).execution)
      (NativeCopiedTokenRoute.finalAllocation (NativeCopiedTokenConstruction.step (.initial plan tails)).execution) := native
end Initial

namespace Capacity
variable {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p (n+1)}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  {angle : RopeAngles.Inputs} {sampling : LogSumExpRanges.Platform}
  (plan : CapacityCopiedTokenConstruction.Plan original angle sampling)
  (tails : CopiedAttentionOriginalTailChains.Capacity.TokenBuilt plan)

def lift (native : FinalProjectionParsedSource.Native plan.graph.body.finalStorage plan.graph.allocation) :
    FinalProjectionParsedSource.Native
      (NativeCopiedTokenRoute.finalStorage (NativeCopiedTokenConstruction.step (.positive plan tails)).execution)
      (NativeCopiedTokenRoute.finalAllocation (NativeCopiedTokenConstruction.step (.positive plan tails)).execution) := native
end Capacity

variable {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p n}
  {original : TokenParameterMemory.Storage p before.index.bytes} {frontier : Frontier}
  (r : NativeCopiedHighWater.Request original frontier) (angle : RopeAngles.Inputs)
  (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
  (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
  (kernel : MlxRmsHostSelection.KernelLimit)
  (threads : p.graph.finalNorm.platform.groups*32=kernel.threads)
  (scratch inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat)
  (projectionBefore : Nat → Float32)

abbrev execution := (NativeCopiedTokenConstruction.step
  (NativeCopiedHighWater.plan r angle sampling lseLocal tileLocal finishLocal)).execution

-- The branch-specific finish request supplies the actual fresh destination.
-- No equality to an independently supplied final execution is assumed.
def native : FinalProjectionParsedSource.Native
    (NativeCopiedTokenRoute.finalStorage (execution r angle sampling lseLocal tileLocal finishLocal))
    (NativeCopiedTokenRoute.finalAllocation (execution r angle sampling lseLocal tileLocal finishLocal)) := by
  cases n with
  | zero =>
      exact Initial.lift (InitialCopiedTokenHighWater.plan r angle sampling lseLocal tileLocal finishLocal) (InitialCopiedTokenHighWater.tails r angle sampling lseLocal tileLocal finishLocal)
        (FinalProjectionAllocatedNative.samplerRequest (InitialCopiedTokenHighWater.request r angle) kernel threads scratch inverseBefore scratchBase inverseBase projectionBefore)
  | succ n =>
      exact Capacity.lift (CapacityCopiedTokenHighWater.plan r angle sampling lseLocal tileLocal finishLocal) (CapacityCopiedTokenHighWater.tails r angle sampling lseLocal tileLocal finishLocal)
        (FinalProjectionAllocatedNative.samplerRequest (CapacityCopiedTokenHighWater.request r angle) kernel threads scratch inverseBefore scratchBase inverseBase projectionBefore)

theorem donated_false :
    (native r angle sampling lseLocal tileLocal finishLocal kernel threads scratch inverseBefore
      scratchBase inverseBase projectionBefore).donated=false := by
  cases n <;> rfl

theorem checked (finite : p.graph.output.Finite
    (p.graph.finalNorm.forward (p.graph.hidden before.logical.cache (p.embedding.forward before.logical.token) angle))) :
    FinalProjectionParsedSource.Certificate
      (NativeCopiedTokenRoute.finalStorage (execution r angle sampling lseLocal tileLocal finishLocal))
      (NativeCopiedTokenRoute.finalAllocation (execution r angle sampling lseLocal tileLocal finishLocal))
      (native r angle sampling lseLocal tileLocal finishLocal kernel threads scratch inverseBefore
        scratchBase inverseBase projectionBefore) :=
  FinalProjectionParsedSource.checked _ _ _ finite

end Inference.Models.Qwen.NativeCopiedHighWaterFinalNative
