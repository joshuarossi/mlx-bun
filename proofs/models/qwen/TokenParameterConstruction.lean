import models.qwen.TokenParameterMemory
import models.qwen.DecodeParameterConstruction

namespace Inference.Models.Qwen.TokenParameterConstruction
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open TokenAutoregressiveMemoryConstruction
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {time : Nat} {before : TokenAutoregressiveMemory.State p time}

-- This plan chooses only output geometry. The original embedding parameters
-- are supplied by the fixed pipeline bundle, rather than another witness.
structure EmbeddingPlan (original : TokenParameterMemory.Storage p before.index.bytes) where
  regions : QuantizedEmbeddingMemory.Regions
  allocation : QuantizedEmbeddingMemory.Allocation original.embedding before.index regions
  caches : DecodePreservation.Protected regions.Live p.graph.stages before.logical.cache before.index.bytes before.caches
  parameters : original.Protected regions.Live

variable {original : TokenParameterMemory.Storage p before.index.bytes}

def EmbeddingPlan.entry (plan : EmbeddingPlan original) : Entry before where
  weights := original.embedding
  shared := ⟨original.packedShared,original.scalesShared,original.biasesShared⟩
  regions := plan.regions
  allocation := plan.allocation
  caches := plan.caches

theorem EmbeddingPlan.weights_eq (plan : EmbeddingPlan original) : plan.entry.weights=original.embedding := rfl

def EmbeddingPlan.afterEmbedding (plan : EmbeddingPlan original) : TokenParameterMemory.Storage p plan.entry.source.bytes :=
  original.reframe _ (original.protected_mono (fun _ _ safe => plan.entry.frame safe) plan.parameters)

theorem EmbeddingPlan.afterEmbedding_protected (plan : EmbeddingPlan original) (property : Nat → Nat → Prop) :
    plan.afterEmbedding.Protected property ↔ original.Protected property :=
  original.reframe_protected _ _ property

theorem EmbeddingPlan.embedding_bases (plan : EmbeddingPlan original) :
    plan.afterEmbedding.embedding.packedBase=original.embedding.packedBase ∧
    plan.afterEmbedding.embedding.scales.base=original.embedding.scales.base ∧
    plan.afterEmbedding.embedding.biases.base=original.embedding.biases.base := ⟨rfl,rfl,rfl⟩

-- The vocabulary projection and final normalization are taken from that
-- same original bundle; their attachment is reframed across the embedding.
def EmbeddingPlan.finalWeights (plan : EmbeddingPlan original) : FinalWeights plan.entry where
  norm := original.graph.norm
  normShared := original.graph.normShared
  output := original.graph.output
  outputShared := original.graph.outputShared
  normLive := plan.parameters.2.2.2.2.1
  outputLive := plan.parameters.2.2.2.2.2

theorem EmbeddingPlan.final_norm_eq (plan : EmbeddingPlan original) : plan.finalWeights.norm=original.graph.norm := rfl

theorem EmbeddingPlan.final_output_eq (plan : EmbeddingPlan original) : plan.finalWeights.output=original.graph.output := rfl

variable {angle : RopeAngles.Inputs}

def EmbeddingPlan.ChainPlan (embedding : EmbeddingPlan original) (angle : RopeAngles.Inputs) :=
  DecodeParameterConstruction.ChainPlan p.graph.stages .root before.logical.cache
    (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
    embedding.afterEmbedding.graph.stages

def EmbeddingPlan.chain (embedding : EmbeddingPlan original) (plan : embedding.ChainPlan angle) :=
  DecodeParameterConstruction.chain p.graph.stages .root before.logical.cache
    (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
    embedding.afterEmbedding.graph.stages plan

def EmbeddingPlan.ChainSafe (embedding : EmbeddingPlan original) (plan : embedding.ChainPlan angle) (base size : Nat) : Prop :=
  DecodeMemoryChain.Safe p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle
    embedding.entry.source embedding.entry.storage (embedding.chain plan) base size

def EmbeddingPlan.ChainCaches (embedding : EmbeddingPlan original) (plan : embedding.ChainPlan angle) :=
  DecodeParameterConstruction.CacheRegions p.graph.stages .root before.logical.cache
    (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
    embedding.afterEmbedding.graph.stages plan

attribute [local irreducible] Entry.source Entry.storage EmbeddingPlan.afterEmbedding

structure BodyPlan (embedding : EmbeddingPlan original) (angle : RopeAngles.Inputs) where
  chain : embedding.ChainPlan angle
  caches : embedding.ChainCaches chain
  parameters : embedding.afterEmbedding.Protected (embedding.ChainSafe chain)

variable {embedding : EmbeddingPlan original}

def BodyPlan.hiddenBuffer (body : BodyPlan embedding angle) :
    ArrayStorage.BFBuffer (p.graph.hidden before.logical.cache (p.embedding.forward before.logical.token) angle) :=
  DecodeMemoryChain.outputBuffer p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle
    embedding.entry.source embedding.entry.storage (embedding.chain body.chain)

theorem BodyPlan.hidden_eq (body : BodyPlan embedding angle) : body.hiddenBuffer=
    DecodeMemoryChain.outputBuffer p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle
      embedding.entry.source embedding.entry.storage (embedding.chain body.chain) := rfl

theorem BodyPlan.hidden_bytes (body : BodyPlan embedding angle) : body.hiddenBuffer.bytes=
    (DecodeMemoryChain.outputBuffer p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle
      embedding.entry.source embedding.entry.storage (embedding.chain body.chain)).bytes := rfl

attribute [local irreducible] BodyPlan.hiddenBuffer

theorem BodyPlan.frame (body : BodyPlan embedding angle) (safe : embedding.ChainSafe body.chain base size)
    (offset : Nat) (bound : offset<size) : body.hiddenBuffer.bytes (base+offset)=embedding.entry.source.bytes (base+offset) :=
  (congrFun body.hidden_bytes _).trans
    (DecodeMemoryChain.other_region p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle
      embedding.entry.source embedding.entry.storage (embedding.chain body.chain) base size safe offset bound)

def BodyPlan.finalStorage (body : BodyPlan embedding angle) :
    FinalProjectionConstruction.Storage p.graph.finalNorm p.graph.output
      (p.graph.hidden before.logical.cache (p.embedding.forward before.logical.token) angle) :=
  FinalProjectionConstruction.fromFrame embedding.entry.source.bytes body.hiddenBuffer (embedding.ChainSafe body.chain)
    (fun _ _ safe => body.frame safe) embedding.afterEmbedding.graph.norm embedding.afterEmbedding.graph.normShared
    embedding.afterEmbedding.graph.output embedding.afterEmbedding.graph.outputShared
    body.parameters.2.2.2.2.1 body.parameters.2.2.2.2.2

theorem BodyPlan.finalStorage_source (body : BodyPlan embedding angle) : body.finalStorage.source=body.hiddenBuffer := rfl

structure GraphPlan (embedding : EmbeddingPlan original) (angle : RopeAngles.Inputs) where
  body : BodyPlan embedding angle
  allocation : FinalProjectionConstruction.Allocation body.finalStorage

def GraphPlan.forward (plan : GraphPlan embedding angle) :
    Qwen38TrellisM1MaxMemory.Execution p.graph before.logical.cache (p.embedding.forward before.logical.token) angle :=
  Qwen38TrellisM1MaxConstruction.fromChain (embedding.chain plan.body.chain)
    (DecodeParameterConstruction.cacheSafe p.graph.stages .root before.logical.cache
      (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
      embedding.afterEmbedding.graph.stages plan.body.chain plan.body.caches)
    plan.body.finalStorage (plan.body.finalStorage_source.trans plan.body.hidden_eq) plan.allocation

theorem GraphPlan.source (plan : GraphPlan embedding angle) : plan.forward.source=embedding.entry.source := by
  unfold GraphPlan.forward Qwen38TrellisM1MaxConstruction.fromChain
  rfl

theorem GraphPlan.storage (plan : GraphPlan embedding angle) : plan.forward.storage=embedding.entry.storage := by
  unfold GraphPlan.forward Qwen38TrellisM1MaxConstruction.fromChain
  rfl

variable {sampling : LogSumExpRanges.Platform}

attribute [local irreducible] Qwen38TrellisM1MaxMemory.Execution.logitsBuffer
  Qwen38TrellisM1MaxMemory.Execution.afterCache Qwen38TrellisM1MaxMemory.CacheSafe

structure Plan (original : TokenParameterMemory.Storage p before.index.bytes) (angle : RopeAngles.Inputs)
    (sampling : LogSumExpRanges.Platform) where
  embedding : EmbeddingPlan original
  graph : GraphPlan embedding angle
  tailSafe : Qwen38TrellisM1MaxMemory.CacheSafe graph.forward
  sampler : SamplerPlan graph.forward.logitsBuffer
  samplingSafe : DecodePreservation.Protected sampler.Region p.graph.stages
    (DecodeChain.run p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle).2
    graph.forward.logitsBuffer.bytes (graph.forward.afterCache tailSafe)

def Plan.sampled (plan : Plan original angle sampling) :
    Qwen38TrellisM1MaxSamplingMemory.Execution p.graph before.logical.cache (p.embedding.forward before.logical.token) angle sampling where
  forward := plan.graph.forward
  forwardSafe := plan.tailSafe
  sampler := plan.sampler.build sampling
  cacheSafe := by
    rw [← plan.sampler.region_eq]
    exact plan.samplingSafe

def Plan.step (plan : Plan original angle sampling) : TokenAutoregressiveMemory.Step p sampling before angle where
  embedding := plan.embedding.entry.embedding
  indexLinked := rfl
  embeddingSafe := plan.embedding.caches
  sampled := plan.sampled
  inputLinked := by
    change plan.graph.forward.source=plan.embedding.entry.embedding.forwardBuffer
    rw [plan.graph.source]
    unfold Entry.source
    rfl
  cacheLinked := by
    change plan.graph.forward.storage = _
    rw [plan.graph.storage]
    unfold Entry.storage Entry.source TokenAutoregressiveMemory.transportCaches
    with_unfolding_all rfl

theorem Plan.embedding_weights (plan : Plan original angle sampling) : plan.step.embedding.storage=original.embedding := rfl

variable {parameters : TokenSequenceRanges.Parameters p}
  {primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph}
  {samplingPrimitive : LogSumExpRanges.Primitives sampling}

def Plan.nextParameters (plan : Plan original angle sampling)
    (angleBound : RopeAnglesRanges.InputsBound angle) (supported : time+1≤262144)
    (aim ae : RopeAngles.Target) (angleError : RopeAngles.InputError angle aim ae) (base : 0≤aim.base)
    (safe : original.Protected (TokenParameterMemory.StepSafe plan.step)) :
    TokenParameterMemory.Storage p (TokenAutoregressiveMemory.advance p parameters primitive sampling samplingPrimitive before
      angle angleBound supported aim ae angleError base plan.step).index.bytes :=
  original.afterAdvance angleBound supported aim ae angleError base plan.step safe

-- Only reached states require raw allocations. Each successor's parameters
-- are the preserved predecessor bundle, not another checkpoint witness.
inductive Trace (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (initialPlan : InitialCacheMemory.Plan p.graph.stages) (initialMemory : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token)
    (shared : index.bytes=InitialCacheMemory.execute p.graph.stages initialPlan initialMemory)
    (original : TokenParameterMemory.Storage p index.bytes) (angles : TokenAutoregressive.Angles) :
    {time : Nat} → (before : TokenAutoregressiveMemory.State p time) → TokenParameterMemory.Storage p before.index.bytes → Prop where
  | initial : Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared original angles
      (TokenAutoregressiveMemory.initial p token initialPlan initialMemory index shared) original
  | step {time : Nat} {before : TokenAutoregressiveMemory.State p time}
      {current : TokenParameterMemory.Storage p before.index.bytes}
      (previous : Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared original angles before current)
      (supported : time+1≤262144) (plan : Plan current (angles.value time) sampling)
      (safe : current.Protected (TokenParameterMemory.StepSafe plan.step)) :
      Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared original angles
        (TokenAutoregressiveMemory.advance p parameters primitive sampling samplingPrimitive before
          (angles.value time) (angles.ranges time (by omega)) supported (angles.target time) (angles.error time)
          (angles.accuracy time (by omega)) (angles.base time (by omega)) plan.step)
        (plan.nextParameters (angles.ranges time (by omega)) supported (angles.target time) (angles.error time)
          (angles.accuracy time (by omega)) (angles.base time (by omega)) safe)

variable {token : Fin 248320} {initialPlan : InitialCacheMemory.Plan p.graph.stages} {initialMemory : ByteMemory.Bytes}
  {index : Inference.State.TokenStorage.Buffer token}
  {shared : index.bytes=InitialCacheMemory.execute p.graph.stages initialPlan initialMemory}
  {initialParameters : TokenParameterMemory.Storage p index.bytes} {angles : TokenAutoregressive.Angles}
  {current : TokenParameterMemory.Storage p before.index.bytes}

theorem Trace.protected (trace : Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared initialParameters angles before current)
    (property : Nat → Nat → Prop) : current.Protected property ↔ initialParameters.Protected property := by
  induction trace with
  | initial => exact Iff.rfl
  | step previous supported plan safe ih =>
    exact (TokenParameterMemory.Storage.afterAdvance_protected _ _ _ _ _ _ _ _ _ property).trans ih

theorem Trace.logical_eq (trace : Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared initialParameters angles before current)
    (supported : time≤262144) :
    before.logical=TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles time supported := by
  induction trace with
  | initial => rfl
  | step previous bound plan safe ih =>
    rw [TokenAutoregressiveMemory.advance_logical]
    unfold TokenAutoregressive.run
    rw [ih (by omega)]

theorem Trace.readback (trace : Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared initialParameters angles before current)
    (supported : time≤262144) :
    let reference := TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles time supported
    (before.index.read,before.readCaches)=(reference.token.val,reference.cache) := by
  rw [Inference.State.TokenStorage.Buffer.read_correct,TokenAutoregressiveMemory.State.caches_eq]
  exact congrArg (fun state : TokenAutoregressive.State p time => (state.token.val,state.cache)) (trace.logical_eq supported)

-- Membership names an original allocation without choosing a replacement
-- heap or assuming its contents. It also covers any graph-parameter region
-- selected by the graph bundle's Protected predicate.
def Region (storage : TokenParameterMemory.Storage p memory) (base size : Nat) : Prop :=
  ∀ property, storage.Protected property → property base size

theorem packed_region (storage : TokenParameterMemory.Storage p memory) :
    Region storage storage.embedding.packedBase (4*(248320*640)) := fun _ safe => safe.1

theorem scales_region (storage : TokenParameterMemory.Storage p memory) :
    Region storage storage.embedding.scales.base (2*(248320*80)) := fun _ safe => safe.2.1

theorem biases_region (storage : TokenParameterMemory.Storage p memory) :
    Region storage storage.embedding.biases.base (2*(248320*80)) := fun _ safe => safe.2.2.1

theorem graph_region (storage : TokenParameterMemory.Storage p memory)
    (selected : ∀ property, storage.graph.Protected property → property base size) : Region storage base size :=
  fun property safe => selected property safe.2.2.2

theorem Trace.frame (trace : Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared initialParameters angles before current)
    (region : Region initialParameters base size) (offset : Nat) (bound : offset<size) :
    before.index.bytes (base+offset)=index.bytes (base+offset) := by
  induction trace with
  | initial => rfl
  | step previous supported plan safe ih =>
    have currentSafe := region _ ((previous.protected _).mp safe)
    exact (TokenParameterMemory.step_frame plan.step currentSafe offset bound).trans ih

end Inference.Models.Qwen.TokenParameterConstruction
