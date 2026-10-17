import models.qwen.CheckpointCopiedInitializedRun
import models.qwen.CheckpointCopiedHighWaterSource
namespace Inference.Models.Qwen.CheckpointCopiedInitializedSource
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open ResidualDeltaHighWater (Frontier Before)
open CheckpointCopiedInitializedRun (initial run state runRoom)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenConstruction.step NativeCopiedTokenRoute.final
  NativeCopiedTokenRoute.finalStorage NativeCopiedTokenRoute.finalAllocation

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  (original : TokenParameterMemory.Storage p initialHeap) (token : Fin 248320) (frontier : Frontier)
  (room : frontier.cursor+CheckpointCopiedInitializedRun.bytes≤2^64)
  (parameters : original.Protected (Before frontier.cursor))

include room in
private theorem seedRoom : frontier.cursor+InitialCopiedSequenceSeed.bytes p≤2^64 := by
  have first := NativeCopiedAllocationBudget.token_bound p (time:=0) (by decide)
  have budgets : NativeCopiedAllocationBudget.perToken≤NativeCopiedAllocationBudget.budget := by decide +kernel
  change InitialCopiedTokenHighWater.bytes p≤NativeCopiedAllocationBudget.perToken at first
  have total := room
  dsimp only [InitialCopiedSequenceSeed.bytes,CheckpointCopiedInitializedRun.bytes] at *
  omega

def initializationPlan : TokenInitializationMemory.Plan p token initialHeap :=
  CheckpointCopiedHighWaterSeed.initializationPlan token frontier (seedRoom frontier room)

variable (ctx : CheckpointCopiedHighWaterRun.Context p)

-- The only remaining native inputs describe the actually reached launches.
-- Initialization and every allocation/execution plan are already constructed.
abbrev Attachments := CheckpointCopiedHighWaterSource.Attachments ctx (initial original token frontier room parameters)
  (runRoom original token frontier room parameters)

private theorem initialTrace :
    CheckpointNativeCopiedSequence.Trace p ctx.sampling ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive token
      (initializationPlan (p:=p) (initialHeap:=initialHeap) token frontier room).caches
      (initializationPlan (p:=p) (initialHeap:=initialHeap) token frontier room).tokenWrite.memory
      (initializationPlan (p:=p) (initialHeap:=initialHeap) token frontier room).index rfl
      (initial original token frontier room parameters).parameters
      (initial original token frontier room parameters).memory
      (initial original token frontier room parameters).parameters :=
  CheckpointCopiedHighWaterSeed.trace original token frontier (seedRoom frontier room) parameters
    ctx.sampling ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive

theorem trace (attached : Attachments original token frontier room parameters ctx) (n : Nat) (supported : n≤262144) :
    CheckpointNativeCopiedSequence.Trace p ctx.sampling ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive token
      (initializationPlan (p:=p) (initialHeap:=initialHeap) token frontier room).caches
      (initializationPlan (p:=p) (initialHeap:=initialHeap) token frontier room).tokenWrite.memory
      (initializationPlan (p:=p) (initialHeap:=initialHeap) token frontier room).index rfl
      (initial original token frontier room parameters).parameters
      (state original token frontier room parameters ctx n supported).memory
      (state original token frontier room parameters ctx n supported).parameters :=
  CheckpointCopiedHighWaterSource.trace ctx (initial original token frontier room parameters)
    (runRoom original token frontier room parameters) (initialTrace original token frontier room parameters ctx) attached n supported

theorem readback (attached : Attachments original token frontier room parameters ctx) (n : Nat) (supported : n≤262144) :
    ((state original token frontier room parameters ctx n supported).memory.index.read,
      (state original token frontier room parameters ctx n supported).memory.readCaches)=
      ((CheckpointNativeCopiedSequence.reference ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive token n supported).token.val,
        (CheckpointNativeCopiedSequence.reference ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive token n supported).cache) :=
  CheckpointCopiedHighWaterSource.readback ctx (initial original token frontier room parameters)
    (runRoom original token frontier room parameters) (initialTrace original token frontier room parameters ctx) attached n supported

noncomputable def reachedPlan (n : Nat) (supported : n+1≤262144) :=
  CheckpointCopiedHighWaterSource.reachedPlan ctx (initial original token frontier room parameters)
    (runRoom original token frontier room parameters) n supported

theorem token_source (attached : Attachments original token frontier room parameters ctx) (n : Nat) (supported : n+1≤262144) :
    (ArgmaxLaunchSourceMemory.tokenMemory
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx n supported)).execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory
        (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx n supported)).execution).sampler.selection.destination).toNat)=
      some (state original token frontier room parameters ctx (n+1) supported).memory.index.read :=
  CheckpointCopiedHighWaterSource.token_source ctx (initial original token frontier room parameters)
    (runRoom original token frontier room parameters) attached n supported

theorem feedback_heap (n : Nat) (supported : n+2≤262144) :
    (NativeCopiedTokenRoute.embedding (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx (n+1) supported)).execution).tokenBuffer.bytes=
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx n (by omega))).execution).sampler.memory ∧
    (NativeCopiedTokenRoute.embedding (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx (n+1) supported)).execution).tokenBuffer.base=
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx n (by omega))).execution).sampler.selection.destination :=
  CheckpointCopiedHighWaterSource.feedback_heap ctx (initial original token frontier room parameters)
    (runRoom original token frontier room parameters) n supported

theorem feedback_source (attached : Attachments original token frontier room parameters ctx) (n : Nat) (supported : n+2≤262144) :
    (ArgmaxLaunchSourceMemory.tokenMemory
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx n (by omega))).execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory
        (NativeCopiedTokenRoute.embedding (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx (n+1) supported)).execution).tokenBuffer.base).toNat)=
      some (NativeCopiedTokenRoute.embedding (NativeCopiedTokenConstruction.step (reachedPlan original token frontier room parameters ctx (n+1) supported)).execution).tokenBuffer.read :=
  CheckpointCopiedHighWaterSource.feedback_source ctx (initial original token frontier room parameters)
    (runRoom original token frontier room parameters) attached n supported

end Inference.Models.Qwen.CheckpointCopiedInitializedSource
