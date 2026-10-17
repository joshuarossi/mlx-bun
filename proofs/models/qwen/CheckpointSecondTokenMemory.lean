import models.qwen.TokenNextPlanConstruction

-- Two constructed token steps on one evolving heap. This bump-allocation
-- model still requires explicit headroom, loaded attachment and primitives;
-- it is not a bounded-chip RAM or native compiler correspondence theorem.
namespace Inference.Models.Qwen.CheckpointSecondTokenMemory
open Contracts.Mlx TokenInference DecodeStage DecodeChain Kernels.Attention Kernels.Sampling
open TokenBoundaryHighWater (Before)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  TokenFirstInitializedConstruction.Request.ready TokenFirstInitializedConstruction.Request.first
  TokenFirstInitializedConstruction.Request.plan Qwen38TrellisM1MaxMemory.Execution.logitsBuffer

section Transfer
variable {stages : List Stage} {tokens : Nat} {first second : Caches stages tokens}
  {before after : ByteMemory.Bytes} {storedFirst : DecodeFrame.Storage stages first before}
  {storedSecond : DecodeFrame.Storage stages second after}

theorem protected_transport (property : Nat → Nat → Prop)
    (same : DecodeCacheGeometry.regions stages first before storedFirst=DecodeCacheGeometry.regions stages second after storedSecond)
    (safe : DecodePreservation.Protected property stages second after storedSecond) :
    DecodePreservation.Protected property stages first before storedFirst :=
  (DecodeCacheGeometry.protected_iff _ _ _ _ _).mpr
    ((congrArg (fun regions => ∀ region ∈ regions, property region.1 region.2) same).mpr
      ((DecodeCacheGeometry.protected_iff _ _ _ _ _).mp safe))
end Transfer

section Index
variable {p : Pipeline} {time : Nat} {state : TokenAutoregressiveMemory.State p time}
  (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angle : RopeAngles.Inputs) (angleBound : RopeAnglesRanges.InputsBound angle) (supported : time+1≤262144)
  (aim ae : RopeAngles.Target) (angleError : RopeAngles.InputError angle aim ae) (baseNonnegative : 0≤aim.base)
  (step : TokenAutoregressiveMemory.Step p sampling state angle)

theorem advance_index_base :
    (TokenAutoregressiveMemory.advance p parameters primitive sampling samplingPrimitive state
      angle angleBound supported aim ae angleError baseNonnegative step).index.base=step.sampled.sampler.selection.destination := rfl
end Index

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes} {original : TokenParameterMemory.Storage p initialHeap}
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (request : TokenFirstInitializedConstruction.Request original)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angles : TokenAutoregressive.Angles)
  (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

noncomputable abbrev firstState := CheckpointFirstTokenMemory.after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal
abbrev firstParameters := CheckpointFirstTokenMemory.parametersAfter encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal

theorem first_base :
    (firstState encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).index.base=
      (request.plan sampling angles lseLocal tileLocal finishLocal).sampled.sampler.selection.destination :=
  advance_index_base (state:=request.ready.state) (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    primitive sampling samplingPrimitive (angles.value 0) (angles.ranges 0 (by decide)) (by decide)
    (angles.target 0) (angles.error 0) (angles.accuracy 0 (by decide)) (angles.base 0 (by decide))
    (request.plan sampling angles lseLocal tileLocal finishLocal).step

theorem first_token_bound :
    Before request.first.nextCursor
      (firstState encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).index.base 4 := by
  rw [first_base]
  unfold TokenFirstInitializedConstruction.Request.plan
  exact request.first.token_bound (angles.value 0) sampling lseLocal tileLocal finishLocal

theorem first_cache_bound :
    let state := firstState encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal
    DecodePreservation.Protected (Before request.first.nextCursor) p.graph.stages state.logical.cache state.index.bytes state.caches := by
  have regions := TokenFirstCacheGeometry.advance_regions (state:=request.ready.state)
    (CheckpointDictionaryBinding.pipeline_parameters p encoded binding) primitive sampling samplingPrimitive
    (angles.value 0) (angles.ranges 0 (by decide)) (by decide) (angles.target 0) (angles.error 0)
    (angles.accuracy 0 (by decide)) (angles.base 0 (by decide))
    (request.plan sampling angles lseLocal tileLocal finishLocal).step
  have safe : DecodePreservation.Protected (Before request.first.nextCursor) p.graph.stages
      (DecodeChain.run p.graph.stages request.ready.state.logical.cache (p.embedding.forward request.ready.state.logical.token) (angles.value 0)).2
      (request.plan sampling angles lseLocal tileLocal finishLocal).step.sampled.memory
      (request.plan sampling angles lseLocal tileLocal finishLocal).step.sampled.afterCache := by
    unfold TokenFirstInitializedConstruction.Request.plan
    exact request.first.caches_bound (angles.value 0) sampling lseLocal tileLocal finishLocal
  exact protected_transport _
    (storedFirst:=(firstState encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).caches)
    regions safe

theorem first_cut : request.frontier.cursor≤request.first.frontier.cursor := by
  unfold TokenFirstInitializedConstruction.Request.first TokenFirstPlanConstruction.Request.frontier TokenInitializationHighWater.next
  change request.frontier.cursor≤request.frontier.cursor+TokenInitializationHighWater.bytes+13120
  exact (Nat.le_add_right _ _).trans (Nat.le_add_right _ _)

def nextRequest
    (room : request.first.nextCursor+TokenNextPlanConstruction.bytes p 1≤2^64) :
    TokenNextPlanConstruction.Request
      (state:=firstState encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal)
      (firstParameters encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal) where
  cursor := request.first.nextCursor
  aligned := request.first.next_aligned
  room := room
  token := first_token_bound encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal
  parameterCut := request.frontier.cursor
  cacheCut := request.first.nextCursor
  ordered := ⟨(first_cut request).trans ((Nat.le_add_right _ _).trans ((Nat.le_add_right _ _).trans (Nat.le_add_right _ _))),Nat.le_refl _⟩
  parameters := (CheckpointFirstTokenMemory.parameter_regions encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal _).mpr request.parameters
  cachesBelow := first_cache_bound encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal
  cachesAbove := ResidualDeltaHighWater.cacheProtected_mono _ _ _
    (fun _ _ lower => (first_cut request).trans lower)
    (TokenFirstCacheGeometry.checkpoint_after_geometry encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).1
  pairwise := (TokenFirstCacheGeometry.checkpoint_after_geometry encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).2
  dispatch := request.dispatch
  reuse := by decide


variable (room : request.first.nextCursor+TokenNextPlanConstruction.bytes p 1≤2^64)
  (nextLseLocal : ByteMemory.Bytes) (nextTileLocal : Fin 243 → ByteMemory.Bytes) (nextFinishLocal : ByteMemory.Bytes)

noncomputable def plan : TokenParameterConstruction.Plan
    (before:=firstState encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal)
    (firstParameters encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal) (angles.value 1) sampling :=
  (nextRequest encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room).plan
    (angles.value 1) sampling nextLseLocal nextTileLocal nextFinishLocal

theorem plan_safe :
    (firstParameters encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).Protected
      (TokenParameterMemory.StepSafe (plan encoded binding request primitive sampling samplingPrimitive angles
        lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).step) :=
  (nextRequest encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room).parameters_safe
    (angles.value 1) sampling nextLseLocal nextTileLocal nextFinishLocal

noncomputable def after : TokenAutoregressiveMemory.State p 2 :=
  TokenAutoregressiveMemory.advance p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding) primitive sampling samplingPrimitive
    (firstState encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal)
    (angles.value 1) (angles.ranges 1 (by decide)) (by decide) (angles.target 1) (angles.error 1)
    (angles.accuracy 1 (by decide)) (angles.base 1 (by decide))
    (plan encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).step

noncomputable def parametersAfter : TokenParameterMemory.Storage p
    (after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).index.bytes :=
  (plan encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).nextParameters
    (parameters:=CheckpointDictionaryBinding.pipeline_parameters p encoded binding) (primitive:=primitive) (samplingPrimitive:=samplingPrimitive)
    (angles.ranges 1 (by decide)) (by decide) (angles.target 1) (angles.error 1)
    (angles.accuracy 1 (by decide)) (angles.base 1 (by decide))
    (plan_safe encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal)

theorem trace : CheckpointTokenMemory.Trace encoded binding original request.initialization request.initial_safe
    primitive sampling samplingPrimitive angles
    (after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal)
    (parametersAfter encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal) :=
  TokenParameterConstruction.Trace.step
    (before:=firstState encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal)
    (current:=firstParameters encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal)
    (CheckpointFirstTokenMemory.trace encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal) (by decide)
    (plan encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal)
    (plan_safe encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal)

theorem readback :
    let reference := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive request.token angles 2 (by decide)
    let actual := after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  CheckpointTokenMemory.readback
    (trace encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal) (by decide)

theorem parameter_bytes (region : TokenParameterConstruction.Region original base size) (offset : Nat) (bound : offset<size) :
    (after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).index.bytes (base+offset)=initialHeap (base+offset) :=
  CheckpointTokenMemory.parameter_bytes
    (trace encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal) region offset bound

theorem parameter_regions (property : Nat → Nat → Prop) :
    (parametersAfter encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).Protected property ↔ original.Protected property :=
  CheckpointTokenMemory.parameter_regions
    (trace encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal) property


theorem after_regions :
    let actual := after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal
    DecodeCacheGeometry.regions p.graph.stages actual.logical.cache actual.index.bytes actual.caches=
      DecodeCacheGeometry.regions p.graph.stages
        (DecodeChain.run p.graph.stages
          (firstState encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).logical.cache
          (p.embedding.forward (firstState encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).logical.token) (angles.value 1)).2
        (plan encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).step.sampled.memory
        (plan encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).step.sampled.afterCache :=
  TokenFirstCacheGeometry.advance_regions
    (CheckpointDictionaryBinding.pipeline_parameters p encoded binding) primitive sampling samplingPrimitive
    (angles.value 1) (angles.ranges 1 (by decide)) (by decide) (angles.target 1) (angles.error 1)
    (angles.accuracy 1 (by decide)) (angles.base 1 (by decide))
    (plan encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).step

theorem cache_bound :
    let actual := after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal
    DecodePreservation.Protected
      (Before (nextRequest encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room).nextCursor)
      p.graph.stages actual.logical.cache actual.index.bytes actual.caches := by
  apply protected_transport _
    (after_regions encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal)
  unfold plan
  exact (nextRequest encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room).caches_bound
    (angles.value 1) sampling nextLseLocal nextTileLocal nextFinishLocal

theorem cache_geometry :
    let actual := after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal
    DecodePreservation.Protected (DecodeHighWaterGeometry.After request.frontier.cursor)
      p.graph.stages actual.logical.cache actual.index.bytes actual.caches ∧
      DecodeCacheGeometry.Pairwise p.graph.stages actual.logical.cache actual.index.bytes actual.caches := by
  apply TokenFirstCacheGeometry.geometry_transport
    (after_regions encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal)
  unfold plan
  exact (nextRequest encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room).caches_geometry
    (angles.value 1) sampling nextLseLocal nextTileLocal nextFinishLocal

theorem after_base :
    (after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).index.base=
      (plan encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).sampled.sampler.selection.destination :=
  advance_index_base (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    primitive sampling samplingPrimitive (angles.value 1) (angles.ranges 1 (by decide)) (by decide)
    (angles.target 1) (angles.error 1) (angles.accuracy 1 (by decide)) (angles.base 1 (by decide))
    (plan encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).step

theorem token_bound :
    Before (nextRequest encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room).nextCursor
      (after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).index.base 4 := by
  rw [after_base]
  unfold plan
  exact (nextRequest encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room).token_bound
    (angles.value 1) sampling nextLseLocal nextTileLocal nextFinishLocal

theorem parameters_bound :
    (parametersAfter encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal).Protected
      (Before request.frontier.cursor) :=
  (parameter_regions encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal room nextLseLocal nextTileLocal nextFinishLocal _).mpr request.parameters

end Inference.Models.Qwen.CheckpointSecondTokenMemory
