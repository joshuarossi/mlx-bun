import models.qwen.CapacityCopiedHighWaterConstruction
import models.qwen.TokenBoundaryHighWater
import models.qwen.CopiedTokenFinishHighWater
namespace Inference.Models.Qwen.CapacityCopiedTokenHighWater
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  TokenAutoregressiveMemoryConstruction.Entry.source TokenAutoregressiveMemoryConstruction.Entry.storage
  CapacityCopiedTokenConstruction.BodyPlan.hiddenBuffer
  CopiedAttentionOriginalTailChains.Capacity.TokenBuilt

-- One monotone frontier covers the actual embedding, constructed layers,
-- final normalization/projection and sampler. Native primitive attachments
-- remain in the pipeline and supplied angle/platform values.
def bytes (p : Pipeline) (n : Nat) : Nat := 13120+CapacityCopiedWorkspace.bytes (n+1) p.graph.stages+FinalProjectionSamplerAllocation.bytes

structure Request {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p (n+1)}
    (original : TokenParameterMemory.Storage p before.index.bytes) (frontier : Frontier) where
  room : frontier.cursor+bytes p n≤2^64
  token : Before frontier.cursor before.index.base 4
  parameters : original.Protected (Before frontier.cursor)
  caches : DecodePreservation.Protected (Before frontier.cursor) p.graph.stages before.logical.cache before.index.bytes before.caches
  dispatches : CapacityCopiedHighWaterConstruction.Dispatches p.graph.stages

variable {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p (n+1)}
  {original : TokenParameterMemory.Storage p before.index.bytes} {frontier : Frontier}
  (r : Request original frontier)

include r in
private theorem embeddingRoom : frontier.cursor+13120≤2^64 := by
  have room := r.room
  unfold bytes at room
  omega

def embedding : TokenParameterConstruction.EmbeddingPlan original :=
  TokenBoundaryHighWater.embeddingPlan frontier.aligned (embeddingRoom r) r.token r.parameters r.caches

def start (_r : Request original frontier) : Frontier where
  cursor := frontier.cursor+13120
  aligned := TokenBoundaryHighWater.embedding_next frontier.aligned

private theorem chainRoom : (start r).cursor+CapacityCopiedWorkspace.bytes (n+1) p.graph.stages≤2^64 := by
  have room := r.room
  dsimp only [start,bytes] at *
  omega

-- Every layer execution is synthesized by the recursive source-backed arena
-- constructors, rather than supplied as a completed per-layer plan.
def chainResult (angle : RopeAngles.Inputs) :
    CapacityCopiedHighWaterConstruction.Result .root before.logical.cache (p.embedding.forward before.logical.token) angle
      (embedding r).entry.source (embedding r).entry.storage (embedding r).afterEmbedding.graph.stages (start r) :=
  CapacityCopiedHighWaterConstruction.build p.graph.stages .root before.logical.cache
    (p.embedding.forward before.logical.token) angle (embedding r).entry.source (embedding r).entry.storage
    (embedding r).afterEmbedding.graph.stages (start r) (chainRoom r)
    (TokenBoundaryHighWater.embedding_output frontier.aligned (embeddingRoom r) r.token r.parameters r.caches).2
    (TokenBoundaryHighWater.embedding_parameters frontier.aligned (embeddingRoom r) r.token r.parameters r.caches).2.2.2.1
    (TokenBoundaryHighWater.embedding_caches frontier.aligned (embeddingRoom r) r.token r.parameters r.caches)
    (Nat.succ_pos n) r.dispatches

def body (angle : RopeAngles.Inputs) : CapacityCopiedTokenConstruction.BodyPlan (embedding r) angle where
  chain := (chainResult r angle).plan
  caches := (chainResult r angle).cacheSafe
  parameters := (embedding r).afterEmbedding.protected_mono
    (fun _ _ below => (chainResult r angle).safeBefore _ _ below)
    (TokenBoundaryHighWater.embedding_parameters frontier.aligned (embeddingRoom r) r.token r.parameters r.caches)

def finishCursor (_r : Request original frontier) : Frontier where
  cursor := frontier.cursor+13120+CapacityCopiedWorkspace.bytes (n+1) p.graph.stages
  aligned := by rw [Nat.add_mod,TokenBoundaryHighWater.embedding_next frontier.aligned,CapacityCopiedWorkspace.bytes_aligned]

private theorem finishRoom : (finishCursor r).cursor+FinalProjectionSamplerAllocation.bytes≤2^64 := by
  simpa only [finishCursor,bytes,Nat.add_assoc] using r.room

private theorem originalBefore : original.Protected (Before (finishCursor r).cursor) :=
  original.protected_mono (fun _ _ below => below.trans (by dsimp only [finishCursor]; omega)) r.parameters

private theorem hiddenBound (angle : RopeAngles.Inputs) : Before (finishCursor r).cursor (body r angle).hiddenBuffer.base 10240 :=
  (congrArg (fun buffer : ArrayStorage.BFBuffer (p.graph.hidden before.logical.cache (p.embedding.forward before.logical.token) angle) => Before (finishCursor r).cursor buffer.base 10240) (body r angle).hidden_eq).mpr
    (chainResult r angle).outputBound

def request (angle : RopeAngles.Inputs) : FinalProjectionSamplerAllocation.Request (body r angle).finalStorage :=
  CopiedTokenFinishRequest.Capacity.request (body r angle) (finishCursor r).cursor (finishCursor r).aligned
    (finishRoom r) (hiddenBound r angle) (originalBefore r)

private theorem cachesBound (angle : RopeAngles.Inputs) : CopiedTokenFinishAllocation.Capacity.CacheBound (body r angle) (request r angle) :=
  (chainResult r angle).cachesBound

variable (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform)
  (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

def plan : CapacityCopiedTokenConstruction.Plan original angle sampling :=
  CopiedTokenFinishAllocation.Capacity.plan (body r angle) (request r angle) sampling lseLocal tileLocal finishLocal (cachesBound r angle)

theorem tails : CopiedAttentionOriginalTailChains.Capacity.TokenBuilt (plan r angle sampling lseLocal tileLocal finishLocal) :=
  by
    unfold CopiedAttentionOriginalTailChains.Capacity.TokenBuilt
    exact (chainResult r angle).built

def nativePlan : NativeCopiedTokenConstruction.Plan p sampling angle before original :=
  CopiedTokenFinishSafety.Capacity.nativePlan (body r angle) (request r angle) sampling lseLocal tileLocal finishLocal
    (cachesBound r angle) (tails r angle sampling lseLocal tileLocal finishLocal)

theorem safe : NativeCopiedTokenConstruction.Safe (nativePlan r angle sampling lseLocal tileLocal finishLocal) :=
  CopiedTokenFinishSafety.Capacity.safe (body r angle) (request r angle) sampling lseLocal tileLocal finishLocal
    (cachesBound r angle) (tails r angle sampling lseLocal tileLocal finishLocal) (originalBefore r)

-- The next token starts beyond the actual sampler writes, with all original
-- parameter spans and the newly updated cache still on that same heap.
def next : Frontier where
  cursor := (finishCursor r).cursor+FinalProjectionSamplerAllocation.bytes
  aligned := by
    rw [Nat.add_mod,(finishCursor r).aligned]
    decide +kernel

theorem next_eq : (next r).cursor=frontier.cursor+bytes p n := by
  simp only [next,finishCursor,bytes,Nat.add_assoc]

theorem next_bounded : (next r).cursor≤2^64 := by
  rw [next_eq]
  exact r.room

theorem token_bound : Before (next r).cursor
    (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step
      (nativePlan r angle sampling lseLocal tileLocal finishLocal)).execution).sampler.selection.destination 4 :=
  CopiedTokenFinishHighWater.Capacity.token_bound (body r angle) (request r angle) sampling lseLocal tileLocal finishLocal
    (cachesBound r angle) (tails r angle sampling lseLocal tileLocal finishLocal)

theorem caches_bound :
    let step := NativeCopiedTokenConstruction.step (nativePlan r angle sampling lseLocal tileLocal finishLocal)
    DecodePreservation.Protected (Before (next r).cursor) p.graph.stages
      (p.run before.logical.cache before.logical.token angle).2
      (NativeCopiedTokenRoute.final step.execution).sampler.memory
      (NativeCopiedTokenMemory.after step.execution step.safe) :=
  CopiedTokenFinishHighWater.Capacity.caches_bound (body r angle) (request r angle) sampling lseLocal tileLocal finishLocal
    (cachesBound r angle) (tails r angle sampling lseLocal tileLocal finishLocal)

theorem parameters_bound :
    (NativeCopiedTokenConstruction.after (nativePlan r angle sampling lseLocal tileLocal finishLocal)
      (safe r angle sampling lseLocal tileLocal finishLocal)).Protected (Before (next r).cursor) :=
  CopiedTokenFinishHighWater.Capacity.parameters_bound (body r angle) (request r angle) sampling lseLocal tileLocal finishLocal
    (cachesBound r angle) (tails r angle sampling lseLocal tileLocal finishLocal) (originalBefore r)

end Inference.Models.Qwen.CapacityCopiedTokenHighWater
