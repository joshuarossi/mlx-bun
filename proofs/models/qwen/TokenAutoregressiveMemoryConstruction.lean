import models.qwen.TokenAutoregressiveMemory
import models.qwen.Qwen38TrellisM1MaxConstruction

namespace Inference.Models.Qwen.TokenAutoregressiveMemoryConstruction
open Contracts.Mlx TokenInference DecodeStage Kernels.Attention Kernels.Sampling
open Layers
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  Qwen38TrellisM1MaxMemory.Execution.logitsBuffer

variable {p : Pipeline} {time : Nat} {before : TokenAutoregressiveMemory.State p time}
  {angle : RopeAngles.Inputs} {sampling : LogSumExpRanges.Platform}

structure Entry (before : TokenAutoregressiveMemory.State p time) where
  weights : QuantizedEmbeddingDevice.Storage p.embedding
  shared : QuantizedEmbeddingMemory.Shared weights before.index
  regions : QuantizedEmbeddingMemory.Regions
  allocation : QuantizedEmbeddingMemory.Allocation weights before.index regions
  caches : DecodePreservation.Protected regions.Live p.graph.stages before.logical.cache before.index.bytes before.caches

def Entry.embedding (entry : Entry before) : QuantizedEmbeddingMemory.Execution p.embedding before.logical.token :=
  QuantizedEmbeddingMemory.fromStorage entry.weights before.index entry.shared entry.regions entry.allocation

def Entry.source (entry : Entry before) : ArrayStorage.BFBuffer (p.embedding.forward before.logical.token) := entry.embedding.forwardBuffer

def Entry.storage (entry : Entry before) : DecodeFrame.Storage p.graph.stages before.logical.cache entry.source.bytes :=
  TokenAutoregressiveMemory.embeddingCaches before entry.embedding rfl entry.caches

theorem Entry.frame (entry : Entry before) (safe : entry.regions.Live base size) (offset : Nat) (bound : offset<size) :
    entry.source.bytes (base+offset)=before.index.bytes (base+offset) :=
  (congrFun entry.embedding.buffers_shared.1 _).trans (entry.embedding.other_region safe offset bound)

-- Final norm/output weights start on the preceding token/cache heap and
-- survive the embedding's four actual gather/dequantization allocations.
structure FinalWeights (entry : Entry before) where
  norm : ArrayStorage.BFBuffer p.graph.finalNorm.weight
  normShared : norm.bytes=before.index.bytes
  output : AffineDevice.Storage p.graph.output
  outputShared : AffineMemory.Shared p.graph.output output before.index.bytes
  normLive : entry.regions.Live norm.base 10240
  outputLive : AffineMemoryFrames.Protected p.graph.output output entry.regions.Live

def FinalWeights.prepared {entry : Entry before} (weights : FinalWeights entry) :
    FinalProjectionConstruction.Storage p.graph.finalNorm p.graph.output (p.embedding.forward before.logical.token) :=
  FinalProjectionConstruction.fromFrame before.index.bytes entry.source entry.regions.Live
    (fun _ _ safe => entry.frame safe) weights.norm weights.normShared weights.output weights.outputShared weights.normLive weights.outputLive

theorem FinalWeights.source_eq {entry : Entry before} (weights : FinalWeights entry) : weights.prepared.source=entry.source := rfl

theorem FinalWeights.norm_shared {entry : Entry before} (weights : FinalWeights entry) : weights.prepared.normWeights.bytes=entry.source.bytes := by
  have shared := weights.prepared.normShared
  rw [weights.source_eq] at shared
  exact shared

theorem FinalWeights.output_shared {entry : Entry before} (weights : FinalWeights entry) :
    AffineMemory.Shared p.graph.output weights.prepared.outputWeights entry.source.bytes := by
  have shared := weights.prepared.outputShared
  rw [weights.source_eq] at shared
  exact shared

attribute [local irreducible] Entry.source Entry.storage FinalWeights.prepared

structure ForwardPlan (entry : Entry before) (angle : RopeAngles.Inputs) where
  chain : DecodeMemoryConstruction.ChainPlan p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle entry.source entry.storage
  caches : DecodeMemoryConstruction.CacheRegions p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle entry.source entry.storage chain
  weights : FinalWeights entry
  normSafe : Qwen38TrellisM1MaxConstruction.Safe chain weights.prepared.normWeights.base 10240
  outputSafe : AffineMemoryFrames.Protected p.graph.output weights.prepared.outputWeights (Qwen38TrellisM1MaxConstruction.Safe chain)
  allocation : FinalProjectionConstruction.Allocation (Qwen38TrellisM1MaxConstruction.finalStorage chain
    weights.prepared.normWeights weights.norm_shared weights.prepared.outputWeights weights.output_shared normSafe outputSafe)

variable {entry : Entry before}

def ForwardPlan.forward (plan : ForwardPlan entry angle) :
    Qwen38TrellisM1MaxMemory.Execution p.graph before.logical.cache (p.embedding.forward before.logical.token) angle :=
  Qwen38TrellisM1MaxConstruction.fromStorage plan.chain plan.caches plan.weights.prepared.normWeights plan.weights.norm_shared
    plan.weights.prepared.outputWeights plan.weights.output_shared plan.normSafe plan.outputSafe plan.allocation

theorem ForwardPlan.source (plan : ForwardPlan entry angle) : plan.forward.source=entry.source := rfl

theorem ForwardPlan.storage (plan : ForwardPlan entry angle) : plan.forward.storage=entry.storage := rfl

theorem ForwardPlan.norm_base (plan : ForwardPlan entry angle) : plan.forward.normalization.normalized.base=plan.allocation.normBase := rfl

theorem ForwardPlan.output_base (plan : ForwardPlan entry angle) : plan.forward.projection.base=plan.allocation.outputBase :=
  FinalProjectionConstruction.output_base _ plan.allocation

def ForwardPlan.TailRegion (plan : ForwardPlan entry angle) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint (2*plan.allocation.normBase) 10240 base size ∧
  MemoryRegions.Disjoint plan.allocation.outputBase 496640 base size

def ForwardPlan.TailSafe (plan : ForwardPlan entry angle) : Prop :=
  DecodePreservation.Protected plan.TailRegion p.graph.stages
    (DecodeChain.run p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle).2
    plan.forward.hiddenBuffer.bytes plan.forward.chainCache

theorem ForwardPlan.cache_safe (plan : ForwardPlan entry angle) (safe : plan.TailSafe) : Qwen38TrellisM1MaxMemory.CacheSafe plan.forward := by
  have property : plan.TailRegion=Qwen38TrellisM1MaxMemory.TailSafe plan.forward := by
    funext base size
    unfold ForwardPlan.TailRegion Qwen38TrellisM1MaxMemory.TailSafe
    rw [plan.norm_base,plan.output_base]
  unfold Qwen38TrellisM1MaxMemory.CacheSafe
  rw [← property]
  exact safe

-- The sampler's plan consists exclusively of addresses, local initial
-- memories, and spatial contracts for its four global output allocations.
variable {logits : Fin 248320 → ArrayStorage.BF}

structure SamplerPlan (source : ArrayStorage.BFBuffer logits) where
  normalizer : Nat
  normalizerAligned : normalizer%2=0
  normalizerBounded : normalizer+2≤2^64
  normalizerSafe : MemoryRegions.Disjoint normalizer 2 source.base 496640
  lseLocal : ByteMemory.Bytes
  partials : ArgmaxPairMemory.Layout 243
  tileLocal : Fin 243 → ByteMemory.Bytes
  finishLocal : ByteMemory.Bytes
  logitsSafe : ArgmaxPairMemory.Safe partials source.base 496640
  lseSafe : ArgmaxPairMemory.Safe partials normalizer 2
  token : Nat
  tokenAligned : token%4=0
  tokenBounded : token+4≤2^64
  tokenScores : MemoryRegions.Disjoint token 4 partials.scores 972
  tokenIds : MemoryRegions.Disjoint token 4 partials.ids 972
  tokenLogits : MemoryRegions.Disjoint token 4 source.base 496640
  tokenLse : MemoryRegions.Disjoint token 4 normalizer 2

def SamplerPlan.build {logits : Fin 248320 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer logits}
    (plan : SamplerPlan source) (sampling : LogSumExpRanges.Platform) : NormalizedArgmaxMemory.Pipeline sampling source :=
  NormalizedArgmaxMemory.Pipeline.canonical sampling source plan.lseLocal plan.normalizer plan.normalizerAligned plan.normalizerBounded
    plan.normalizerSafe plan.partials plan.tileLocal plan.finishLocal plan.logitsSafe plan.lseSafe plan.token plan.tokenAligned plan.tokenBounded
    plan.tokenScores plan.tokenIds plan.tokenLogits plan.tokenLse

def SamplerPlan.Region (plan : SamplerPlan source) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint plan.normalizer 2 base size ∧
  ArgmaxPairMemory.Safe plan.partials base size ∧ MemoryRegions.Disjoint plan.token 4 base size

theorem SamplerPlan.region_eq (plan : SamplerPlan source) : plan.Region=(plan.build sampling).Safe := rfl

structure Plan (before : TokenAutoregressiveMemory.State p time) (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform) where
  entry : Entry before
  forward : ForwardPlan entry angle
  tailSafe : forward.TailSafe
  sampler : SamplerPlan forward.forward.logitsBuffer
  samplingSafe : DecodePreservation.Protected sampler.Region p.graph.stages
    (DecodeChain.run p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle).2
    forward.forward.logitsBuffer.bytes (forward.forward.afterCache (forward.cache_safe tailSafe))

def Plan.sampled (plan : Plan before angle sampling) :
    Qwen38TrellisM1MaxSamplingMemory.Execution p.graph before.logical.cache (p.embedding.forward before.logical.token) angle sampling where
  forward := plan.forward.forward
  forwardSafe := plan.forward.cache_safe plan.tailSafe
  sampler := plan.sampler.build sampling
  cacheSafe := by
    rw [← plan.sampler.region_eq]
    exact plan.samplingSafe

def Plan.step (plan : Plan before angle sampling) : TokenAutoregressiveMemory.Step p sampling before angle where
  embedding := plan.entry.embedding
  indexLinked := rfl
  embeddingSafe := plan.entry.caches
  sampled := plan.sampled
  inputLinked := by
    change plan.forward.forward.source=plan.entry.embedding.forwardBuffer
    rw [plan.forward.source]
    unfold Entry.source
    rfl
  cacheLinked := by
    change plan.forward.forward.storage = _
    rw [plan.forward.storage]
    unfold Entry.storage Entry.source TokenAutoregressiveMemory.transportCaches
    with_unfolding_all rfl

abbrev Plans (p : Pipeline) (sampling : LogSumExpRanges.Platform) (angles : TokenAutoregressive.Angles) :=
  ∀ (time : Nat) (before : TokenAutoregressiveMemory.State p time), Plan before (angles.value time) sampling

def schedules (plans : Plans p sampling angles) : TokenAutoregressiveMemory.Schedules p sampling angles :=
  fun time before => (plans time before).step

noncomputable def run (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token) (shared : index.bytes=InitialCacheMemory.execute p.graph.stages plan before)
    (angles : TokenAutoregressive.Angles) (plans : Plans p sampling angles) (steps : Nat) (supported : steps≤262144) :=
  TokenAutoregressiveMemory.run p parameters primitive sampling samplingPrimitive token plan before index shared angles (schedules plans) steps supported

theorem run_readback (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token) (shared : index.bytes=InitialCacheMemory.execute p.graph.stages plan before)
    (angles : TokenAutoregressive.Angles) (plans : Plans p sampling angles) (steps : Nat) (supported : steps≤262144) :
    let actual := run p parameters primitive sampling samplingPrimitive token plan before index shared angles plans steps supported
    let reference := TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles steps supported
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  TokenAutoregressiveMemory.run_readback p parameters primitive sampling samplingPrimitive token plan before index shared angles (schedules plans) steps supported

-- A finite trace requests allocations only for the actual reachable heaps.
-- It does not require an allocator for arbitrary, uninitialized states.
inductive Trace (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (initialPlan : InitialCacheMemory.Plan p.graph.stages) (initialMemory : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token)
    (shared : index.bytes=InitialCacheMemory.execute p.graph.stages initialPlan initialMemory)
    (angles : TokenAutoregressive.Angles) : {time : Nat} → TokenAutoregressiveMemory.State p time → Prop where
  | initial : Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles
      (TokenAutoregressiveMemory.initial p token initialPlan initialMemory index shared)
  | step {time : Nat} {before : TokenAutoregressiveMemory.State p time}
      (previous : Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles before)
      (supported : time+1≤262144) (plan : Plan before (angles.value time) sampling) :
      Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles
        (TokenAutoregressiveMemory.advance p parameters primitive sampling samplingPrimitive before
          (angles.value time) (angles.ranges time (by omega)) supported (angles.target time) (angles.error time)
          (angles.accuracy time (by omega)) (angles.base time (by omega)) plan.step)

variable {parameters : TokenSequenceRanges.Parameters p}
  {primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph}
  {samplingPrimitive : LogSumExpRanges.Primitives sampling}
  {token : Fin 248320} {initialPlan : InitialCacheMemory.Plan p.graph.stages} {initialMemory : ByteMemory.Bytes}
  {index : Inference.State.TokenStorage.Buffer token}
  {shared : index.bytes=InitialCacheMemory.execute p.graph.stages initialPlan initialMemory}
  {angles : TokenAutoregressive.Angles}

theorem Trace.logical_eq (trace : Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles before)
    (supported : time≤262144) :
    before.logical=TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles time supported := by
  induction trace with
  | initial => rfl
  | @step time before previous bound plan ih =>
    rw [TokenAutoregressiveMemory.advance_logical]
    unfold TokenAutoregressive.run
    rw [ih (by omega)]

theorem Trace.readback (trace : Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles before)
    (supported : time≤262144) :
    let reference := TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles time supported
    (before.index.read,before.readCaches)=(reference.token.val,reference.cache) := by
  have logical := trace.logical_eq supported
  change (before.index.read,before.readCaches)=(_,_)
  rw [Inference.State.TokenStorage.Buffer.read_correct,TokenAutoregressiveMemory.State.caches_eq]
  exact congrArg (fun state : TokenAutoregressive.State p time => (state.token.val,state.cache)) logical

end Inference.Models.Qwen.TokenAutoregressiveMemoryConstruction
