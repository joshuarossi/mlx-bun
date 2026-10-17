import models.qwen.CheckpointCopiedHighWaterRun

namespace Inference.Models.Qwen.CheckpointCopiedHighWaterSource
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open CheckpointCopiedHighWaterState (State)
open CheckpointCopiedHighWaterRun (Context run stepPlan stepSafe)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenConstruction.step NativeCopiedTokenRoute.final
  NativeCopiedTokenRoute.finalStorage NativeCopiedTokenRoute.finalAllocation

structure Attachment {p : Pipeline} {sampling : LogSumExpRanges.Platform} {n : Nat}
    {before : TokenAutoregressiveMemory.State p n} {current : TokenParameterMemory.Storage p before.index.bytes}
    (plan : NativeCopiedTokenConstruction.Plan p sampling (RopeInputConstruction.inputs n) before current) where
  unsigned : Bool
  inputs : NativeCopiedTokenRoute.Inputs (NativeCopiedTokenConstruction.step plan).execution
  finalNative : FinalProjectionParsedSource.Native
    (NativeCopiedTokenRoute.finalStorage (NativeCopiedTokenConstruction.step plan).execution)
    (NativeCopiedTokenRoute.finalAllocation (NativeCopiedTokenConstruction.step plan).execution)
  lseNative : LogSumExpSourceHost.Attachment

variable {p : Pipeline} (ctx : Context p) (initial : State p 0)
  (room : initial.frontier.cursor+NativeCopiedAllocationBudget.budget≤2^64)

noncomputable def reachedPlan (n : Nat) (supported : n+1≤262144) :=
  stepPlan ctx initial room (run ctx initial room n (by omega)) supported

-- Attachments refer only to the plans this recursion actually constructs.
-- They bind the source model to native metadata and primitive interfaces;
-- no allocation plan or arbitrary-heap execution oracle is requested.
def Attachments := ∀ (n : Nat) (supported : n+1≤262144), Attachment (reachedPlan ctx initial room n supported)

variable {token : Fin 248320} {initialPlan : InitialCacheMemory.Plan p.graph.stages}
  {initialMemory : ByteMemory.Bytes} {index : Inference.State.TokenStorage.Buffer token}
  {shared : index.bytes=InitialCacheMemory.execute p.graph.stages initialPlan initialMemory}
  {original : TokenParameterMemory.Storage p index.bytes}
  (initialTrace : CheckpointNativeCopiedSequence.Trace p ctx.sampling ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive
    token initialPlan initialMemory index shared original initial.memory initial.parameters)

include initialTrace

theorem trace (attached : Attachments ctx initial room) (n : Nat) (supported : n≤262144) :
    CheckpointNativeCopiedSequence.Trace p ctx.sampling ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive
      token initialPlan initialMemory index shared original
      (run ctx initial room n supported).state.memory (run ctx initial room n supported).state.parameters := by
  induction n with
  | zero => exact initialTrace
  | succ n ih =>
    exact CheckpointNativeCopiedSequence.Trace.step (ih (by omega)) supported
      (reachedPlan ctx initial room n supported)
      (stepSafe ctx initial room (run ctx initial room n (by omega)) supported)
      (attached n supported).unsigned (attached n supported).inputs
      (attached n supported).finalNative (attached n supported).lseNative

theorem readback (attached : Attachments ctx initial room) (n : Nat) (supported : n≤262144) :
    ((run ctx initial room n supported).state.memory.index.read,(run ctx initial room n supported).state.memory.readCaches)=
      ((CheckpointNativeCopiedSequence.reference ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive token n supported).token.val,
       (CheckpointNativeCopiedSequence.reference ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive token n supported).cache) :=
  (trace ctx initial room initialTrace attached n supported).readback ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive supported

omit initialTrace in
theorem token_source (attached : Attachments ctx initial room) (n : Nat) (supported : n+1≤262144) :
    (ArgmaxLaunchSourceMemory.tokenMemory
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan ctx initial room n supported)).execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory
        (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan ctx initial room n supported)).execution).sampler.selection.destination).toNat)=
      some (run ctx initial room (n+1) supported).state.memory.index.read :=
  (CheckpointNativeCopiedSequence.step_source ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive
    (reachedPlan ctx initial room n supported) supported (attached n supported).unsigned
    (attached n supported).inputs (attached n supported).finalNative (attached n supported).lseNative).2

omit initialTrace in
theorem feedback_heap (n : Nat) (supported : n+2≤262144) :
    (NativeCopiedTokenRoute.embedding (NativeCopiedTokenConstruction.step (reachedPlan ctx initial room (n+1) supported)).execution).tokenBuffer.bytes=
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan ctx initial room n (by omega))).execution).sampler.memory ∧
    (NativeCopiedTokenRoute.embedding (NativeCopiedTokenConstruction.step (reachedPlan ctx initial room (n+1) supported)).execution).tokenBuffer.base=
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan ctx initial room n (by omega))).execution).sampler.selection.destination :=
  CheckpointNativeCopiedSequence.feedback_heap ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive
    (reachedPlan ctx initial room n (by omega)) (stepSafe ctx initial room (run ctx initial room n (by omega)) (by omega)) (by omega)
    (reachedPlan ctx initial room (n+1) supported)

omit initialTrace in
theorem feedback_source (attached : Attachments ctx initial room) (n : Nat) (supported : n+2≤262144) :
    (ArgmaxLaunchSourceMemory.tokenMemory
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step (reachedPlan ctx initial room n (by omega))).execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory
        (NativeCopiedTokenRoute.embedding (NativeCopiedTokenConstruction.step (reachedPlan ctx initial room (n+1) supported)).execution).tokenBuffer.base).toNat)=
      some (NativeCopiedTokenRoute.embedding (NativeCopiedTokenConstruction.step (reachedPlan ctx initial room (n+1) supported)).execution).tokenBuffer.read :=
  CheckpointNativeCopiedSequence.feedback_source ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive
    (reachedPlan ctx initial room n (by omega)) (stepSafe ctx initial room (run ctx initial room n (by omega)) (by omega)) (by omega)
    (reachedPlan ctx initial room (n+1) supported) (attached n (by omega)).unsigned (attached n (by omega)).inputs
    (attached n (by omega)).finalNative (attached n (by omega)).lseNative

end Inference.Models.Qwen.CheckpointCopiedHighWaterSource
