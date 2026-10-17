import models.qwen.TokenReadyMemory
import models.qwen.CheckpointSecondTokenMemory

-- A shared proof adapter. Concrete growth/reuse constructors supply Witness;
-- numerical token/cache correctness follows from the existing execution proof.
namespace Inference.Models.Qwen.TokenReadyStepMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory
open TokenBoundaryHighWater (Before)
open DecodeHighWaterGeometry (After)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {time parameterCut : Nat}

structure Witness (ready : Ready p time parameterCut) (context : Context p) where
  plan : TokenParameterConstruction.Plan ready.parameters (context.angles.value time) context.sampling
  safe : ready.parameters.Protected (TokenParameterMemory.StepSafe plan.step)
  frontier : ResidualDeltaHighWater.Frontier
  ordered : parameterCut≤frontier.cursor
  tokenBound : Before frontier.cursor plan.sampled.sampler.selection.destination 4
  cachesBound : DecodePreservation.Protected (Before frontier.cursor) p.graph.stages
    (DecodeChain.run p.graph.stages ready.state.logical.cache (p.embedding.forward ready.state.logical.token) (context.angles.value time)).2
    plan.sampled.memory plan.sampled.afterCache
  cachesAbove : DecodePreservation.Protected (After parameterCut) p.graph.stages
    (DecodeChain.run p.graph.stages ready.state.logical.cache (p.embedding.forward ready.state.logical.token) (context.angles.value time)).2
    plan.sampled.memory plan.sampled.afterCache
  pairwise : DecodeCacheGeometry.Pairwise p.graph.stages
    (DecodeChain.run p.graph.stages ready.state.logical.cache (p.embedding.forward ready.state.logical.token) (context.angles.value time)).2
    plan.sampled.memory plan.sampled.afterCache

variable {ready : Ready p time parameterCut} {context : Context p} (w : Witness ready context) (supported : time+1≤262144)

noncomputable def Witness.afterState : TokenAutoregressiveMemory.State p (time+1) :=
  TokenAutoregressiveMemory.advance p context.parameters context.primitive context.sampling context.samplingPrimitive ready.state
    (context.angles.value time) (context.angles.ranges time (by omega)) supported
    (context.angles.target time) (context.angles.error time) (context.angles.accuracy time (by omega)) (context.angles.base time (by omega)) w.plan.step

def Witness.afterParameters : TokenParameterMemory.Storage p (w.afterState supported).index.bytes :=
  w.plan.nextParameters (parameters:=context.parameters) (primitive:=context.primitive) (samplingPrimitive:=context.samplingPrimitive)
    (context.angles.ranges time (by omega)) supported (context.angles.target time) (context.angles.error time)
    (context.angles.accuracy time (by omega)) (context.angles.base time (by omega)) w.safe

theorem Witness.afterParameters_protected (property : Nat → Nat → Prop) :
    (w.afterParameters supported).Protected property ↔ ready.parameters.Protected property :=
  ready.parameters.afterAdvance_protected (parameters:=context.parameters) (primitive:=context.primitive) (samplingPrimitive:=context.samplingPrimitive)
    (context.angles.ranges time (by omega)) supported (context.angles.target time) (context.angles.error time)
    (context.angles.accuracy time (by omega)) (context.angles.base time (by omega)) w.plan.step w.safe property

theorem Witness.after_regions :
    DecodeCacheGeometry.regions p.graph.stages (w.afterState supported).logical.cache
      (w.afterState supported).index.bytes (w.afterState supported).caches=
    DecodeCacheGeometry.regions p.graph.stages
      (DecodeChain.run p.graph.stages ready.state.logical.cache (p.embedding.forward ready.state.logical.token) (context.angles.value time)).2
      w.plan.step.sampled.memory w.plan.step.sampled.afterCache :=
  TokenFirstCacheGeometry.advance_regions context.parameters context.primitive context.sampling context.samplingPrimitive
    (context.angles.value time) (context.angles.ranges time (by omega)) supported
    (context.angles.target time) (context.angles.error time) (context.angles.accuracy time (by omega)) (context.angles.base time (by omega)) w.plan.step

theorem Witness.after_cache_bound :
    DecodePreservation.Protected (Before w.frontier.cursor) p.graph.stages (w.afterState supported).logical.cache
      (w.afterState supported).index.bytes (w.afterState supported).caches := by
  apply CheckpointSecondTokenMemory.protected_transport _ (w.after_regions supported)
  exact w.cachesBound

theorem Witness.after_cache_geometry :
    DecodePreservation.Protected (After parameterCut) p.graph.stages (w.afterState supported).logical.cache
      (w.afterState supported).index.bytes (w.afterState supported).caches ∧
    DecodeCacheGeometry.Pairwise p.graph.stages (w.afterState supported).logical.cache
      (w.afterState supported).index.bytes (w.afterState supported).caches := by
  apply TokenFirstCacheGeometry.geometry_transport (w.after_regions supported)
  exact ⟨w.cachesAbove,w.pairwise⟩

theorem Witness.after_index_base : (w.afterState supported).index.base=w.plan.sampled.sampler.selection.destination :=
  CheckpointSecondTokenMemory.advance_index_base context.parameters context.primitive context.sampling context.samplingPrimitive
    (context.angles.value time) (context.angles.ranges time (by omega)) supported
    (context.angles.target time) (context.angles.error time) (context.angles.accuracy time (by omega)) (context.angles.base time (by omega)) w.plan.step

theorem Witness.after_token_bound : Before w.frontier.cursor (w.afterState supported).index.base 4 := by
  rw [w.after_index_base]
  exact w.tokenBound

noncomputable def Witness.next : Ready p (time+1) parameterCut where
  state := w.afterState supported
  parameters := w.afterParameters supported
  frontier := w.frontier
  ordered := w.ordered
  token := w.after_token_bound supported
  parametersBound := (w.afterParameters_protected supported _).mpr ready.parametersBound
  cachesBound := w.after_cache_bound supported
  cachesAbove := (w.after_cache_geometry supported).1
  pairwise := (w.after_cache_geometry supported).2

theorem Witness.parameters_protected (property : Nat → Nat → Prop) :
    (w.next supported).parameters.Protected property ↔ ready.parameters.Protected property :=
  w.afterParameters_protected supported property

theorem Witness.logical : (w.next supported).state.logical=
    TokenAutoregressive.advance p context.parameters context.primitive context.sampling context.samplingPrimitive ready.state.logical
      (context.angles.value time) (context.angles.ranges time (by omega)) supported
      (context.angles.target time) (context.angles.error time) (context.angles.accuracy time (by omega)) (context.angles.base time (by omega)) :=
  TokenAutoregressiveMemory.advance_logical _ _ _ _ _ _ _ _ _ _ _ _ _ _

theorem Witness.other_region (region : TokenParameterConstruction.Region ready.parameters base size) (offset : Nat) (bound : offset<size) :
    (w.next supported).state.index.bytes (base+offset)=ready.state.index.bytes (base+offset) :=
  TokenParameterMemory.step_frame w.plan.step (region _ w.safe) offset bound

section Trace
variable {token : Fin 248320} {initialPlan : InitialCacheMemory.Plan p.graph.stages} {initialMemory : ByteMemory.Bytes}
  {index : Inference.State.TokenStorage.Buffer token}
  {shared : index.bytes=InitialCacheMemory.execute p.graph.stages initialPlan initialMemory}
  {original : TokenParameterMemory.Storage p index.bytes}

theorem Witness.extend
    (trace : TokenParameterConstruction.Trace p context.parameters context.primitive context.sampling context.samplingPrimitive
      token initialPlan initialMemory index shared original context.angles ready.state ready.parameters) :
    TokenParameterConstruction.Trace p context.parameters context.primitive context.sampling context.samplingPrimitive
      token initialPlan initialMemory index shared original context.angles (w.next supported).state (w.next supported).parameters :=
  TokenParameterConstruction.Trace.step (before:=ready.state) (current:=ready.parameters) trace supported w.plan w.safe
end Trace
end Inference.Models.Qwen.TokenReadyStepMemory
