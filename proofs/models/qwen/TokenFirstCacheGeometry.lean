import models.qwen.DecodeHighWaterGeometry
import models.qwen.CheckpointFirstTokenMemory

namespace Inference.Models.Qwen.TokenFirstCacheGeometry
open Contracts.Mlx Layers TokenInference DecodeStage DecodeChain Kernels.Attention Kernels.Sampling
open DecodeHighWaterGeometry (After)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  TokenFirstInitializedConstruction.Request.ready TokenFirstInitializedConstruction.Request.first
  TokenFirstInitializedConstruction.Request.plan Qwen38TrellisM1MaxMemory.Execution.logitsBuffer

section Frames
variable {graph : Qwen38TrellisM1Max.Graph} {tokens : Nat} {cache : graph.Cache tokens}
  {input : Row BF} {angle : RopeAngles.Inputs} {sampling : LogSumExpRanges.Platform}

theorem graph_regions (execution : Qwen38TrellisM1MaxMemory.Execution graph cache input angle)
    (safe : Qwen38TrellisM1MaxMemory.CacheSafe execution) :
    DecodeCacheGeometry.regions graph.stages (DecodeChain.run graph.stages cache input angle).2 _ (execution.afterCache safe)=
      DecodeCacheGeometry.regions graph.stages (DecodeChain.run graph.stages cache input angle).2 _ execution.chainCache := by
  unfold Qwen38TrellisM1MaxMemory.Execution.afterCache
  exact DecodeCacheGeometry.reframe_regions _ _ _ _ _ _ _ _

theorem sampling_regions (execution : Qwen38TrellisM1MaxSamplingMemory.Execution graph cache input angle sampling) :
    DecodeCacheGeometry.regions graph.stages (DecodeChain.run graph.stages cache input angle).2 _ execution.afterCache=
      DecodeCacheGeometry.regions graph.stages (DecodeChain.run graph.stages cache input angle).2 _ execution.forward.chainCache := by
  unfold Qwen38TrellisM1MaxSamplingMemory.Execution.afterCache
  exact (DecodeCacheGeometry.reframe_regions _ _ _ _ _ _ _ _).trans
    (graph_regions execution.forward execution.forwardSafe)
end Frames

section Body
variable {p : Pipeline} {time : Nat} {state : TokenAutoregressiveMemory.State p time}
  {original : TokenParameterMemory.Storage p state.index.bytes}
  {embedding : TokenParameterConstruction.EmbeddingPlan original} {angle : RopeAngles.Inputs}

theorem body_regions (plan : TokenParameterConstruction.GraphPlan embedding angle) :
    DecodeCacheGeometry.regions p.graph.stages (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2 _ plan.forward.chainCache=
      DecodeCacheGeometry.regions p.graph.stages (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2 _
      (DecodeParameterConstruction.after p.graph.stages .root state.logical.cache (p.embedding.forward state.logical.token) angle
        embedding.entry.source embedding.entry.storage embedding.afterEmbedding.graph.stages plan.body.chain plan.body.caches) := by
  unfold TokenParameterConstruction.GraphPlan.forward Qwen38TrellisM1MaxConstruction.fromChain
    Qwen38TrellisM1MaxMemory.Execution.chainCache DecodeParameterConstruction.after
  rfl
end Body

variable {p : Pipeline} {state : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p state.index.bytes}
  (request : TokenFirstPlanConstruction.Request original) (angle : RopeAngles.Inputs)

theorem chain_geometry : DecodeHighWaterGeometry.Geometry (request.chain angle) := by
  unfold TokenFirstPlanConstruction.Request.chain
  apply DecodeHighWaterGeometry.build_geometry

theorem sampled_geometry (sampling : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    let execution := (request.plan angle sampling lseLocal tileLocal finishLocal).sampled
    DecodePreservation.Protected (After request.frontier.cursor) p.graph.stages
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2 _ execution.afterCache ∧
    DecodeCacheGeometry.Pairwise p.graph.stages
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2 _ execution.afterCache := by
  have geometry := chain_geometry request angle
  have regions := (sampling_regions (request.plan angle sampling lseLocal tileLocal finishLocal).sampled).trans
    (body_regions (request.graph angle))
  constructor
  · apply (DecodeCacheGeometry.protected_iff _ _ _ _ _).mpr
    rw [regions]
    exact (DecodeCacheGeometry.protected_iff _ _ _ _ _).mp geometry.1
  · unfold DecodeCacheGeometry.Pairwise
    rw [regions]
    exact geometry.2


section Advance
variable {p : Pipeline} {time : Nat} {state : TokenAutoregressiveMemory.State p time}
  (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angle : RopeAngles.Inputs) (angleBound : RopeAnglesRanges.InputsBound angle) (supported : time+1≤262144)
  (aim ae : RopeAngles.Target) (angleError : RopeAngles.InputError angle aim ae) (baseNonnegative : 0≤aim.base)
  (step : TokenAutoregressiveMemory.Step p sampling state angle)

theorem advance_regions :
    let after := TokenAutoregressiveMemory.advance p parameters primitive sampling samplingPrimitive state
      angle angleBound supported aim ae angleError baseNonnegative step
    DecodeCacheGeometry.regions p.graph.stages after.logical.cache after.index.bytes after.caches=
      DecodeCacheGeometry.regions p.graph.stages
        (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2
        step.sampled.memory step.sampled.afterCache := rfl
end Advance

theorem geometry_transport {stages : List Stage} {tokens : Nat} {first second : Caches stages tokens}
    {before after : ByteMemory.Bytes} {storedFirst : DecodeFrame.Storage stages first before}
    {storedSecond : DecodeFrame.Storage stages second after} {cursor : Nat}
    (same : DecodeCacheGeometry.regions stages first before storedFirst=DecodeCacheGeometry.regions stages second after storedSecond)
    (geometry : DecodePreservation.Protected (After cursor) stages second after storedSecond ∧
      DecodeCacheGeometry.Pairwise stages second after storedSecond) :
    DecodePreservation.Protected (After cursor) stages first before storedFirst ∧
      DecodeCacheGeometry.Pairwise stages first before storedFirst := by
  constructor
  · exact (DecodeCacheGeometry.protected_iff _ _ _ _ _).mpr
      ((congrArg (fun regions => ∀ region ∈ regions, After cursor region.1 region.2) same).mpr
        ((DecodeCacheGeometry.protected_iff _ _ _ _ _).mp geometry.1))
  · exact (congrArg (List.Pairwise DecodeCacheGeometry.Separate) same).mpr geometry.2

section Checkpoint
variable {p : Pipeline} {initialHeap : ByteMemory.Bytes} {original : TokenParameterMemory.Storage p initialHeap}
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (request : TokenFirstInitializedConstruction.Request original)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angles : TokenAutoregressive.Angles)
  (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

theorem checkpoint_after_geometry :
    let after := CheckpointFirstTokenMemory.after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal
    DecodePreservation.Protected (After request.first.frontier.cursor) p.graph.stages after.logical.cache after.index.bytes after.caches ∧
      DecodeCacheGeometry.Pairwise p.graph.stages after.logical.cache after.index.bytes after.caches := by
  have regions := advance_regions (state:=request.ready.state)
    (CheckpointDictionaryBinding.pipeline_parameters p encoded binding) primitive sampling samplingPrimitive
    (angles.value 0) (angles.ranges 0 (by decide)) (by decide) (angles.target 0) (angles.error 0)
    (angles.accuracy 0 (by decide)) (angles.base 0 (by decide))
    (request.plan sampling angles lseLocal tileLocal finishLocal).step
  have geometry :
      DecodePreservation.Protected (After request.first.frontier.cursor) p.graph.stages
        (DecodeChain.run p.graph.stages request.ready.state.logical.cache (p.embedding.forward request.ready.state.logical.token) (angles.value 0)).2
        (request.plan sampling angles lseLocal tileLocal finishLocal).step.sampled.memory
        (request.plan sampling angles lseLocal tileLocal finishLocal).step.sampled.afterCache ∧
      DecodeCacheGeometry.Pairwise p.graph.stages
        (DecodeChain.run p.graph.stages request.ready.state.logical.cache (p.embedding.forward request.ready.state.logical.token) (angles.value 0)).2
        (request.plan sampling angles lseLocal tileLocal finishLocal).step.sampled.memory
        (request.plan sampling angles lseLocal tileLocal finishLocal).step.sampled.afterCache := by
    unfold TokenFirstInitializedConstruction.Request.plan
    exact sampled_geometry request.first (angles.value 0) sampling lseLocal tileLocal finishLocal
  exact geometry_transport
    (first:=(CheckpointFirstTokenMemory.after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).logical.cache)
    (storedFirst:=(CheckpointFirstTokenMemory.after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).caches)
    regions geometry
theorem checkpoint_parameter_separate
    (region : TokenParameterConstruction.Region original base size) :
    let after := CheckpointFirstTokenMemory.after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal
    DecodePreservation.Protected (MemoryRegions.Disjoint base size) p.graph.stages after.logical.cache after.index.bytes after.caches := by
  have before : TokenBoundaryHighWater.Before request.frontier.cursor base size := region _ request.parameters
  have monotone : request.frontier.cursor≤request.first.frontier.cursor := by
    unfold TokenFirstInitializedConstruction.Request.first TokenFirstPlanConstruction.Request.frontier
      TokenInitializationHighWater.next
    change request.frontier.cursor≤request.frontier.cursor+TokenInitializationHighWater.bytes+13120
    exact (Nat.le_add_right _ _).trans (Nat.le_add_right _ _)
  exact ResidualDeltaHighWater.cacheProtected_mono _ _ _
    (fun _ _ lower => Or.inl (before.trans (monotone.trans lower)))
    (checkpoint_after_geometry encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).1

end Checkpoint

end Inference.Models.Qwen.TokenFirstCacheGeometry
