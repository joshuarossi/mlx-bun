import models.qwen.NativeCopiedConstructedInputs
import models.qwen.CheckpointCopiedHighWaterSource
import models.qwen.NativeCopiedHighWaterFinalNative

namespace Inference.Models.Qwen.CheckpointCopiedAllocatedAttachment
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling Kernels.Normalization
open FloatLib.Floats.Formats.BinaryInterchange
open CheckpointCopiedHighWaterState (State)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenConstruction.step NativeCopiedTokenRoute.finalStorage NativeCopiedTokenRoute.finalAllocation
  CheckpointCopiedHighWaterRun.run

namespace AtState
variable {p : Pipeline} {n : Nat} (before : State p n)
  (room : before.frontier.cursor+NativeCopiedHighWater.bytes p n≤2^64)
  (dispatches : NativeCopiedHighWater.Dispatches p n)
  (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
  (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
  (kernel : MlxRmsHostSelection.KernelLimit)
  (threads : p.graph.finalNorm.platform.groups*32=kernel.threads)
  (scratch inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat)
  (projectionBefore : Nat → Float32)

def native : FinalProjectionParsedSource.Native
    (NativeCopiedTokenRoute.finalStorage (NativeCopiedTokenConstruction.step
      (CheckpointCopiedHighWaterState.plan before room dispatches sampling lseLocal tileLocal finishLocal)).execution)
    (NativeCopiedTokenRoute.finalAllocation (NativeCopiedTokenConstruction.step
      (CheckpointCopiedHighWaterState.plan before room dispatches sampling lseLocal tileLocal finishLocal)).execution) :=
  NativeCopiedHighWaterFinalNative.native (CheckpointCopiedHighWaterState.request before room dispatches)
    (RopeInputConstruction.inputs n) sampling lseLocal tileLocal finishLocal kernel threads scratch inverseBefore
    scratchBase inverseBase projectionBefore

def attachment (unsigned : Bool)
    (inputs : NativeCopiedTokenRoute.Inputs (NativeCopiedTokenConstruction.step
      (CheckpointCopiedHighWaterState.plan before room dispatches sampling lseLocal tileLocal finishLocal)).execution)
    (lseNative : LogSumExpSourceHost.Attachment) :
    CheckpointCopiedHighWaterSource.Attachment
      (CheckpointCopiedHighWaterState.plan before room dispatches sampling lseLocal tileLocal finishLocal) where
  unsigned := unsigned
  inputs := inputs
  finalNative := native before room dispatches sampling lseLocal tileLocal finishLocal kernel threads scratch inverseBefore scratchBase inverseBase projectionBefore
  lseNative := lseNative

theorem donated_false :
    (native before room dispatches sampling lseLocal tileLocal finishLocal kernel threads scratch inverseBefore
      scratchBase inverseBase projectionBefore).donated=false :=
  NativeCopiedHighWaterFinalNative.donated_false _ _ _ _ _ _ _ _ _ _ _ _ _
end AtState

variable {p : Pipeline} (ctx : CheckpointCopiedHighWaterRun.Context p) (initial : State p 0)
  (room : initial.frontier.cursor+NativeCopiedAllocationBudget.budget≤2^64)
  {n : Nat} (previous : CheckpointCopiedHighWaterRun.Result initial n) (supported : n+1≤262144)
  (kernel : MlxRmsHostSelection.KernelLimit)
  (threads : p.graph.finalNorm.platform.groups*32=kernel.threads)
  (scratch inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat)
  (projectionBefore : Nat → Float32)
  (unsigned : Bool)
  (inputs : NativeCopiedTokenRoute.Inputs (NativeCopiedTokenConstruction.step
    (CheckpointCopiedHighWaterRun.stepPlan ctx initial room previous supported)).execution)
  (lseNative : LogSumExpSourceHost.Attachment)

def stepAttachment : CheckpointCopiedHighWaterSource.Attachment
    (CheckpointCopiedHighWaterRun.stepPlan ctx initial room previous supported) :=
  AtState.attachment previous.state (CheckpointCopiedHighWaterRun.stepRoom initial room previous supported)
    (ctx.dispatches n) ctx.sampling (ctx.lseLocal n) (ctx.tileLocal n) (ctx.finishLocal n)
    kernel threads scratch inverseBefore scratchBase inverseBase projectionBefore unsigned inputs lseNative

theorem step_donated_false :
    (stepAttachment ctx initial room previous supported kernel threads scratch inverseBefore scratchBase inverseBase
      projectionBefore unsigned inputs lseNative).finalNative.donated=false :=
  AtState.donated_false _ _ _ _ _ _ _ _ _ _ _ _ _ _

theorem step_inputs :
    (stepAttachment ctx initial room previous supported kernel threads scratch inverseBefore scratchBase inverseBase
      projectionBefore unsigned inputs lseNative).inputs=inputs := rfl

-- The remaining attachment inputs contain no final ownership witness.
structure Remaining {p : Pipeline} {sampling : LogSumExpRanges.Platform} {n : Nat}
    {before : TokenAutoregressiveMemory.State p n} {current : TokenParameterMemory.Storage p before.index.bytes}
    (plan : NativeCopiedTokenConstruction.Plan p sampling (RopeInputConstruction.inputs n) before current) where
  unsigned : Bool
  boundary : NativeCopiedConstructedInputs.BoundaryInputs (NativeCopiedTokenConstruction.step plan).execution
  lseNative : LogSumExpSourceHost.Attachment
  kernel : MlxRmsHostSelection.KernelLimit
  threads : p.graph.finalNorm.platform.groups*32=kernel.threads
  scratch : M1Max.WordMemory
  inverseBefore : M1Max.WordMemory
  scratchBase : Nat
  inverseBase : Nat
  projectionBefore : Nat → Float32

noncomputable def reached (n : Nat) (supported : n+1≤262144)
    (data : Remaining (CheckpointCopiedHighWaterSource.reachedPlan ctx initial room n supported)) :
    CheckpointCopiedHighWaterSource.Attachment (CheckpointCopiedHighWaterSource.reachedPlan ctx initial room n supported) :=
  stepAttachment ctx initial room (CheckpointCopiedHighWaterRun.run ctx initial room n (Nat.le_trans (Nat.le_succ n) supported)) supported
    data.kernel data.threads data.scratch data.inverseBefore data.scratchBase data.inverseBase data.projectionBefore
    data.unsigned (NativeCopiedConstructedInputs.inputs (cache:=(CheckpointCopiedHighWaterRun.run ctx initial room n (Nat.le_trans (Nat.le_succ n) supported)).state.memory.logical.cache) (CheckpointCopiedHighWaterSource.reachedPlan ctx initial room n supported) data.boundary) data.lseNative

noncomputable def attachments
    (data : ∀ (n : Nat) (supported : n+1≤262144), Remaining (CheckpointCopiedHighWaterSource.reachedPlan ctx initial room n supported)) :
    CheckpointCopiedHighWaterSource.Attachments ctx initial room :=
  fun n supported => reached ctx initial room n supported (data n supported)

theorem reached_donated_false (n : Nat) (supported : n+1≤262144)
    (data : Remaining (CheckpointCopiedHighWaterSource.reachedPlan ctx initial room n supported)) :
    (reached ctx initial room n supported data).finalNative.donated=false :=
  step_donated_false ctx initial room _ supported data.kernel data.threads data.scratch data.inverseBefore
    data.scratchBase data.inverseBase data.projectionBefore data.unsigned (NativeCopiedConstructedInputs.inputs (cache:=(CheckpointCopiedHighWaterRun.run ctx initial room n (Nat.le_trans (Nat.le_succ n) supported)).state.memory.logical.cache) (CheckpointCopiedHighWaterSource.reachedPlan ctx initial room n supported) data.boundary) data.lseNative

end Inference.Models.Qwen.CheckpointCopiedAllocatedAttachment
