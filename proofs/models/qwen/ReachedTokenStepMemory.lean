import models.qwen.ReachedTokenContext
import models.qwen.TokenGrowthStepMemory
import models.qwen.TokenReuseStepMemory
import models.qwen.TokenWorkspaceFootprint

-- Attach the existing concrete workspace constructors using only reached-domain
-- numerical contracts. No universal rsqrt envelope or old Context is supplied.
namespace Inference.Models.Qwen.ReachedTokenStepMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory (Ready)
open TokenBoundaryHighWater (Before)
open DecodeHighWaterGeometry (After)
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {time parameterCut : Nat}

structure Witness (ready : Ready p time parameterCut) (context : ReachedTokenContext.Context p) where
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

variable {ready : Ready p time parameterCut} {context : ReachedTokenContext.Context p}
  (w : Witness ready context) (supported : time+1≤262144)

theorem logits_bound (supported : time+1≤262144) : ∀ i,
    Model.isFinite (p.graph.forward ready.state.logical.cache (p.embedding.forward ready.state.logical.token) (context.angles.value time) i)=true ∧
      |Model.toReal (p.graph.forward ready.state.logical.cache (p.embedding.forward ready.state.logical.token) (context.angles.value time) i)|≤(2:ℝ)^(23:Nat) :=
  (ReachedSequenceRanges.Graph.checked p.graph context.parameters.graph context.primitive
    ready.state.logical.cache ready.state.logical.cacheBound (p.embedding.forward ready.state.logical.token)
    (TokenSequenceRanges.embedding_bound p context.parameters ready.state.logical.token)
    (context.angles.value time) (context.angles.ranges time (by omega)) supported).output

noncomputable def Witness.logical (_w : Witness ready context) :=
  ReachedTokenContext.Logical.advance p context.parameters context.primitive context.sampling context.samplingPrimitive
    ready.state.logical (context.angles.value time) (context.angles.ranges time (by omega)) supported
    (context.angles.target time) (context.angles.error time)
    (context.angles.accuracy time (by omega)) (context.angles.base time (by omega))

noncomputable def Witness.afterState : TokenAutoregressiveMemory.State p (time+1) := by
  have token : w.plan.sampled.selected context.samplingPrimitive (logits_bound supported)=(w.logical supported).token := by
    apply Fin.ext
    change w.plan.sampled.sampler.selection.token=(w.logical supported).token.val
    rw [w.plan.sampled.token_eq context.samplingPrimitive (logits_bound supported)]
    rfl
  exact ⟨w.logical supported,
    TokenAutoregressiveMemory.reindexToken token (w.plan.sampled.index context.samplingPrimitive (logits_bound supported)),
    w.plan.sampled.afterCache⟩

noncomputable def Witness.afterParameters : TokenParameterMemory.Storage p (w.afterState supported).index.bytes :=
  ready.parameters.reframe _ (ready.parameters.protected_mono
    (fun _ _ safe => TokenParameterMemory.step_frame w.plan.step safe) w.safe)

theorem Witness.afterParameters_protected (property : Nat → Nat → Prop) :
    (w.afterParameters supported).Protected property ↔ ready.parameters.Protected property :=
  ready.parameters.reframe_protected _ _ property

noncomputable def Witness.next : Ready p (time+1) parameterCut where
  state := w.afterState supported
  parameters := w.afterParameters supported
  frontier := w.frontier
  ordered := w.ordered
  token := w.tokenBound
  parametersBound := (w.afterParameters_protected supported _).mpr ready.parametersBound
  cachesBound := w.cachesBound
  cachesAbove := w.cachesAbove
  pairwise := w.pairwise

theorem Witness.next_logical : (w.next supported).state.logical=w.logical supported := rfl

theorem Witness.parameters_protected (property : Nat → Nat → Prop) :
    (w.next supported).parameters.Protected property ↔ ready.parameters.Protected property :=
  w.afterParameters_protected supported property

theorem Witness.other_region (region : TokenParameterConstruction.Region ready.parameters base size)
    (offset : Nat) (bound : offset<size) :
    (w.next supported).state.index.bytes (base+offset)=ready.state.index.bytes (base+offset) :=
  TokenParameterMemory.step_frame w.plan.step (region _ w.safe) offset bound

theorem Witness.readback :
    ((w.next supported).state.index.read,(w.next supported).state.readCaches)=
      ((w.logical supported).token.val,(w.logical supported).cache) :=
  Prod.ext (w.next supported).state.index.read_correct (w.next supported).state.caches_eq

end Inference.Models.Qwen.ReachedTokenStepMemory
