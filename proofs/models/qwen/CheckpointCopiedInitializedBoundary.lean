import models.qwen.CheckpointCopiedInitializedSource
import models.qwen.CheckpointCopiedAllocatedAttachment

namespace Inference.Models.Qwen.CheckpointCopiedInitializedBoundary
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open ResidualDeltaHighWater (Frontier Before)
open CheckpointCopiedInitializedRun (initial state runRoom)
open CheckpointCopiedInitializedSource (reachedPlan)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  CheckpointCopiedHighWaterRun.run NativeCopiedTokenConstruction.step NativeCopiedTokenRoute.final
  NativeCopiedTokenRoute.finalStorage NativeCopiedTokenRoute.finalAllocation

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  (original : TokenParameterMemory.Storage p initialHeap) (token : Fin 248320) (frontier : Frontier)
  (room : frontier.cursor+CheckpointCopiedInitializedRun.bytes≤2^64)
  (parameters : original.Protected (Before frontier.cursor))
  (ctx : CheckpointCopiedHighWaterRun.Context p)

-- Only native boundary data for the actual reached plans remain supplied.
-- Gate-buffer identity and fresh final ownership come from their constructors.
def BoundaryInputs := ∀ (n : Nat) (supported : n+1≤262144),
  CheckpointCopiedAllocatedAttachment.Remaining (reachedPlan original token frontier room parameters ctx n supported)

noncomputable def attachments (data : BoundaryInputs original token frontier room parameters ctx) :
    CheckpointCopiedInitializedSource.Attachments original token frontier room parameters ctx :=
  CheckpointCopiedAllocatedAttachment.attachments ctx (initial original token frontier room parameters)
    (runRoom original token frontier room parameters) data

theorem readback (data : BoundaryInputs original token frontier room parameters ctx) (n : Nat) (supported : n≤262144) :
    ((state original token frontier room parameters ctx n supported).memory.index.read,
      (state original token frontier room parameters ctx n supported).memory.readCaches)=
      ((CheckpointNativeCopiedSequence.reference ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive token n supported).token.val,
        (CheckpointNativeCopiedSequence.reference ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive token n supported).cache) :=
  CheckpointCopiedInitializedSource.readback original token frontier room parameters ctx
    (attachments original token frontier room parameters ctx data) n supported

theorem token_source (data : BoundaryInputs original token frontier room parameters ctx) (n : Nat) (supported : n+1≤262144) :
    (ArgmaxLaunchSourceMemory.tokenMemory
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx n supported)).execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory
        (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx n supported)).execution).sampler.selection.destination).toNat)=
      some (state original token frontier room parameters ctx (n+1) supported).memory.index.read :=
  CheckpointCopiedInitializedSource.token_source original token frontier room parameters ctx
    (attachments original token frontier room parameters ctx data) n supported

theorem feedback_source (data : BoundaryInputs original token frontier room parameters ctx) (n : Nat) (supported : n+2≤262144) :
    (ArgmaxLaunchSourceMemory.tokenMemory
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx n (by omega))).execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory
        (NativeCopiedTokenRoute.embedding (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx (n+1) supported)).execution).tokenBuffer.base).toNat)=
      some (NativeCopiedTokenRoute.embedding (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx (n+1) supported)).execution).tokenBuffer.read :=
  CheckpointCopiedInitializedSource.feedback_source original token frontier room parameters ctx
    (attachments original token frontier room parameters ctx data) n supported

end Inference.Models.Qwen.CheckpointCopiedInitializedBoundary
