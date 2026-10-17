import models.qwen.NativeCopiedHighWaterScalarBoundary
import models.qwen.CopiedScalarRunSources
import models.qwen.CheckpointCopiedAllocatedAttachment

namespace Inference.Models.Qwen.CheckpointCopiedProducedScalarAttachment
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Copy Kernels.Sampling Kernels.Normalization
open FloatLib.Floats.Formats.BinaryInterchange
open ResidualDeltaHighWater (Frontier Before)
open CheckpointCopiedHighWaterState (State)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages CheckpointCopiedHighWaterRun.run
  NativeCopiedTokenConstruction.step NativeCopiedTokenRoute.finalStorage NativeCopiedTokenRoute.finalAllocation

namespace AtState
variable {p : Pipeline} {n : Nat} (before : State p n)
  (room : before.frontier.cursor+NativeCopiedHighWater.bytes p n≤2^64)
  (dispatches : NativeCopiedHighWater.Dispatches p n)
  (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
  (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

-- Scalar source records, gate links and final ownership are absent. Native
-- scalar-object/descriptor sharing between separate calls is not established.
structure Remaining where
  boundary : NativeCopiedHighWaterScalarBoundary.BoundaryInputs
    (CheckpointCopiedHighWaterState.request before room dispatches) (RopeInputConstruction.inputs n)
  unsigned : Bool
  lseNative : LogSumExpSourceHost.Attachment
  kernel : MlxRmsHostSelection.KernelLimit
  threads : p.graph.finalNorm.platform.groups*32=kernel.threads
  scratch : M1Max.WordMemory
  inverseBefore : M1Max.WordMemory
  scratchBase : Nat
  inverseBase : Nat
  projectionBefore : Nat → Float32

variable (data : Remaining before room dispatches)
  (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
  (shared : zero.bytes=before.memory.index.bytes) (below : zero.base+2≤before.frontier.cursor)

def attachment : CheckpointCopiedHighWaterSource.Attachment
    (CheckpointCopiedHighWaterState.plan before room dispatches sampling lseLocal tileLocal finishLocal) :=
  CheckpointCopiedAllocatedAttachment.AtState.attachment before room dispatches sampling lseLocal tileLocal finishLocal
    data.kernel data.threads data.scratch data.inverseBefore data.scratchBase data.inverseBase data.projectionBefore
    data.unsigned (NativeCopiedHighWaterScalarBoundary.fullInputs (CheckpointCopiedHighWaterState.request before room dispatches)
      (RopeInputConstruction.inputs n) sampling lseLocal tileLocal finishLocal zero shared below data.boundary) data.lseNative

theorem donated_false : (attachment before room dispatches sampling lseLocal tileLocal finishLocal data zero shared below).finalNative.donated=false :=
  CheckpointCopiedAllocatedAttachment.AtState.donated_false _ _ _ _ _ _ _ _ _ _ _ _ _ _
end AtState

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  (original : TokenParameterMemory.Storage p initialHeap) (token : Fin 248320) (frontier : Frontier)
  (room : frontier.cursor+CopiedScalarInitialization.bytes≤2^64)
  (parameters : original.Protected (Before frontier.cursor)) (ctx : CheckpointCopiedHighWaterRun.Context p)

abbrev initial := CopiedScalarInitialization.initial original token frontier room parameters
abbrev runRoom := CheckpointCopiedInitializedRun.runRoom (CopiedScalarInitialization.originalAfter original frontier room parameters)
  token (CopiedScalarInitialization.nextFrontier frontier) (CopiedScalarInitialization.remainingRoom frontier room)
  (CopiedScalarInitialization.parametersBefore original frontier room parameters)

noncomputable def Remaining (n : Nat) (supported : n+1≤262144) :=
  AtState.Remaining (CopiedScalarInitialization.run original token frontier room parameters ctx n
    (Nat.le_trans (Nat.le_succ n) supported)).state
    (CheckpointCopiedHighWaterRun.stepRoom (initial original token frontier room parameters)
      (runRoom original token frontier room parameters)
      (CopiedScalarInitialization.run original token frontier room parameters ctx n (Nat.le_trans (Nat.le_succ n) supported)) supported)
    (ctx.dispatches n)

noncomputable def reachedPlan (n : Nat) (supported : n+1≤262144) :=
  CheckpointCopiedHighWaterSource.reachedPlan ctx (initial original token frontier room parameters)
    (runRoom original token frontier room parameters) n supported

noncomputable def reached (n : Nat) (supported : n+1≤262144)
    (data : Remaining original token frontier room parameters ctx n supported) :
    CheckpointCopiedHighWaterSource.Attachment (reachedPlan original token frontier room parameters ctx n supported) :=
  AtState.attachment _ _ (ctx.dispatches n) ctx.sampling (ctx.lseLocal n) (ctx.tileLocal n) (ctx.finishLocal n) data
    (CopiedScalarRunSources.zero original token frontier room parameters ctx n (Nat.le_trans (Nat.le_succ n) supported)).history
    (CopiedScalarRunSources.history_heap original token frontier room parameters ctx n (Nat.le_trans (Nat.le_succ n) supported))
    (by
      rw [CopiedScalarRunSources.history_base]
      exact (CopiedScalarRunSources.scalar_before original token frontier room parameters ctx n (Nat.le_trans (Nat.le_succ n) supported)).1)

noncomputable def attachments
    (data : ∀ (n : Nat) (supported : n+1≤262144), Remaining original token frontier room parameters ctx n supported) :
    CheckpointCopiedHighWaterSource.Attachments ctx (initial original token frontier room parameters)
      (runRoom original token frontier room parameters) :=
  fun n supported => reached original token frontier room parameters ctx n supported (data n supported)

theorem reached_fresh (n : Nat) (supported : n+1≤262144)
    (data : Remaining original token frontier room parameters ctx n supported) :
    (reached original token frontier room parameters ctx n supported data).finalNative.donated=false :=
  AtState.donated_false _ _ _ _ _ _ _ _ _ _ _

noncomputable def state (n : Nat) (supported : n≤262144) :=
  (CopiedScalarInitialization.run original token frontier room parameters ctx n supported).state

theorem readback (data : ∀ (n : Nat) (supported : n+1≤262144), Remaining original token frontier room parameters ctx n supported) (n : Nat) (supported : n≤262144) :
    ((state original token frontier room parameters ctx n supported).memory.index.read,
      (state original token frontier room parameters ctx n supported).memory.readCaches)=
      ((CheckpointNativeCopiedSequence.reference ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive token n supported).token.val,
        (CheckpointNativeCopiedSequence.reference ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive token n supported).cache) :=
  CheckpointCopiedInitializedSource.readback
    (CopiedScalarInitialization.originalAfter original frontier room parameters) token
    (CopiedScalarInitialization.nextFrontier frontier) (CopiedScalarInitialization.remainingRoom frontier room)
    (CopiedScalarInitialization.parametersBefore original frontier room parameters) ctx
    (attachments original token frontier room parameters ctx data) n supported

theorem token_source (data : ∀ (n : Nat) (supported : n+1≤262144), Remaining original token frontier room parameters ctx n supported) (n : Nat) (supported : n+1≤262144) :
    (ArgmaxLaunchSourceMemory.tokenMemory
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx n supported)).execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory
        (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx n supported)).execution).sampler.selection.destination).toNat)=
      some (state original token frontier room parameters ctx (n+1) supported).memory.index.read :=
  CheckpointCopiedInitializedSource.token_source
    (CopiedScalarInitialization.originalAfter original frontier room parameters) token
    (CopiedScalarInitialization.nextFrontier frontier) (CopiedScalarInitialization.remainingRoom frontier room)
    (CopiedScalarInitialization.parametersBefore original frontier room parameters) ctx
    (attachments original token frontier room parameters ctx data) n supported

theorem feedback_source (data : ∀ (n : Nat) (supported : n+1≤262144), Remaining original token frontier room parameters ctx n supported) (n : Nat) (supported : n+2≤262144) :
    (ArgmaxLaunchSourceMemory.tokenMemory
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx n (by omega))).execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory
        (NativeCopiedTokenRoute.embedding (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx (n+1) supported)).execution).tokenBuffer.base).toNat)=
      some (NativeCopiedTokenRoute.embedding (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx (n+1) supported)).execution).tokenBuffer.read :=
  CheckpointCopiedInitializedSource.feedback_source
    (CopiedScalarInitialization.originalAfter original frontier room parameters) token
    (CopiedScalarInitialization.nextFrontier frontier) (CopiedScalarInitialization.remainingRoom frontier room)
    (CopiedScalarInitialization.parametersBefore original frontier room parameters) ctx
    (attachments original token frontier room parameters ctx data) n supported

end Inference.Models.Qwen.CheckpointCopiedProducedScalarAttachment
