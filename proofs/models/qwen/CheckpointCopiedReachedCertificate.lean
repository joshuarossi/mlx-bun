import models.qwen.CheckpointCopiedInitializedSource
namespace Inference.Models.Qwen.CheckpointCopiedReachedCertificate
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open ResidualDeltaHighWater (Frontier Before)
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenConstruction.step NativeCopiedTokenRoute.final
  NativeCopiedTokenRoute.finalStorage NativeCopiedTokenRoute.finalAllocation

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  (original : TokenParameterMemory.Storage p initialHeap) (token : Fin 248320) (frontier : Frontier)
  (room : frontier.cursor+CheckpointCopiedInitializedRun.bytes≤2^64)
  (parameters : original.Protected (Before frontier.cursor))
  (ctx : CheckpointCopiedHighWaterRun.Context p)

-- Numerical ranges are derived from checkpoint binding and the actually
-- reached state, using the existing narrower reached-input primitive contract.
noncomputable def ranges (n : Nat) (supported : n+1≤262144) :
    p.Ranges (CheckpointCopiedInitializedRun.state original token frontier room parameters ctx n (by omega)).memory.logical.cache
      (CheckpointCopiedInitializedRun.state original token frontier room parameters ctx n (by omega)).memory.logical.token
      (RopeInputConstruction.inputs n) :=
  ReachedNativeCopiedTokenState.ranges
    (before:=(CheckpointCopiedInitializedRun.state original token frontier room parameters ctx n (by omega)).memory)
    (CheckpointDictionaryBinding.pipeline_parameters p ctx.encoded ctx.binding)
    (ReachedTokenContext.Primitive.graphPrimitives ctx.selected ctx.other)
    (RopeInputConstruction.inputs_bound n (by omega)) supported

theorem certificate (attached : CheckpointCopiedInitializedSource.Attachments original token frontier room parameters ctx)
    (n : Nat) (supported : n+1≤262144) :
    NativeCopiedTokenRoute.Certificate
      (NativeCopiedTokenConstruction.step (CheckpointCopiedInitializedSource.reachedPlan original token frontier room parameters ctx n supported)).execution
      (attached n supported).unsigned (attached n supported).inputs
      (ranges original token frontier room parameters ctx n supported) supported
      (attached n supported).finalNative (attached n supported).lseNative :=
  (CheckpointNativeCopiedSequence.step_source ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive
    (CheckpointCopiedInitializedSource.reachedPlan original token frontier room parameters ctx n supported)
    supported (attached n supported).unsigned (attached n supported).inputs
    (attached n supported).finalNative (attached n supported).lseNative).1

-- These invariants concern reads from the very cache heap consumed by the
-- reached plan; no replacement cache or expected kernel result is supplied.
theorem cache_invariant (n : Nat) (supported : n≤262144) :
    let actual := (CheckpointCopiedInitializedRun.state original token frontier room parameters ctx n supported).memory
    DecodeChainSequenceRanges.CachesBound p.graph.stages actual.readCaches ∧
      DecodeChain.CacheErrors p.graph.stages actual.readCaches actual.logical.targetCache actual.logical.errorCache ∧
      DecodeChain.CachesFinite p.graph.stages actual.readCaches := by
  dsimp only
  rw [TokenAutoregressiveMemory.State.caches_eq]
  let actual := (CheckpointCopiedInitializedRun.state original token frontier room parameters ctx n supported).memory
  exact ⟨actual.logical.cacheBound,actual.logical.cacheError,
    DecodeChainSequenceRanges.caches_finite _ _ actual.logical.cacheBound⟩

theorem logits_bound (n : Nat) (supported : n+1≤262144) :
    let actual := (CheckpointCopiedInitializedRun.state original token frontier room parameters ctx n (by omega)).memory
    ∀ i, Model.isFinite ((p.run actual.logical.cache actual.logical.token (RopeInputConstruction.inputs n)).1 i)=true ∧
      |Model.toReal ((p.run actual.logical.cache actual.logical.token (RopeInputConstruction.inputs n)).1 i)|≤(2:ℝ)^(23:Nat) :=
  ReachedNativeCopiedTokenState.model_bound
    (before:=(CheckpointCopiedInitializedRun.state original token frontier room parameters ctx n (by omega)).memory)
    (CheckpointDictionaryBinding.pipeline_parameters p ctx.encoded ctx.binding)
    (ReachedTokenContext.Primitive.graphPrimitives ctx.selected ctx.other)
    (RopeInputConstruction.inputs_bound n (by omega)) supported

end Inference.Models.Qwen.CheckpointCopiedReachedCertificate
