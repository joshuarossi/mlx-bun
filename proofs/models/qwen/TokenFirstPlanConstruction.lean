import models.qwen.TokenBoundaryHighWater
import models.qwen.DecodeHighWaterConstruction

-- A first-token plan from one aligned frontier and explicit total headroom.
-- Loaded parameter attachment, dispatch contracts and primitive accuracy remain
-- explicit; this does not establish native allocator or compiler correspondence.
namespace Inference.Models.Qwen.TokenFirstPlanConstruction
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open TokenBoundaryHighWater (Before)
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages DecodeHighWaterConstruction.bytes

variable {p : Pipeline} {state : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p state.index.bytes}

def bytes (p : Pipeline) : Nat := 13120+DecodeHighWaterConstruction.bytes p.graph.stages 0+506880+1952

private theorem room_sampler (cursor work : Nat) {limit : Nat} (h : cursor+(13120+work+506880+1952)≤limit) : cursor+13120+work+506880+1952≤limit := by simpa only [Nat.add_assoc] using h
private theorem room_final (cursor work : Nat) {limit : Nat} (h : cursor+(13120+work+506880+1952)≤limit) : cursor+13120+work+506880≤limit :=
  (Nat.le_add_right _ 1952).trans (room_sampler cursor work h)
private theorem room_chain (cursor work : Nat) {limit : Nat} (h : cursor+(13120+work+506880+1952)≤limit) : cursor+13120+work≤limit :=
  (Nat.le_add_right _ 506880).trans (room_final cursor work h)
private theorem room_embedding (cursor work : Nat) {limit : Nat} (h : cursor+(13120+work+506880+1952)≤limit) : cursor+13120≤limit :=
  (Nat.le_add_right _ work).trans (room_chain cursor work h)

structure Request (original : TokenParameterMemory.Storage p state.index.bytes) where
  cursor : Nat
  aligned : cursor%16=0
  room : cursor+bytes p≤2^64
  token : Before cursor state.index.base 4
  parameters : original.Protected (Before cursor)
  caches : DecodePreservation.Protected (Before cursor) p.graph.stages state.logical.cache state.index.bytes state.caches
  dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages

variable (request : Request original)

def Request.embedding : TokenParameterConstruction.EmbeddingPlan original :=
  TokenBoundaryHighWater.embeddingPlan request.aligned (room_embedding _ _ request.room)
    request.token request.parameters request.caches

def Request.frontier : ResidualDeltaHighWater.Frontier :=
  ⟨request.cursor+13120,TokenBoundaryHighWater.embedding_next request.aligned⟩

theorem Request.embedding_parameters : request.embedding.afterEmbedding.Protected (Before request.frontier.cursor) :=
  TokenBoundaryHighWater.embedding_parameters request.aligned _ request.token request.parameters request.caches

theorem Request.embedding_caches :
    DecodePreservation.Protected (Before request.frontier.cursor) p.graph.stages state.logical.cache
      request.embedding.entry.source.bytes request.embedding.entry.storage :=
  TokenBoundaryHighWater.embedding_caches request.aligned _ request.token request.parameters request.caches

def Request.chain (angle : RopeAngles.Inputs) :=
  DecodeHighWaterConstruction.build p.graph.stages .root state.logical.cache (p.embedding.forward state.logical.token)
    angle request.embedding.entry.source request.embedding.entry.storage request.embedding.afterEmbedding.graph.stages request.frontier
    (room_chain _ _ request.room)
    (TokenBoundaryHighWater.embedding_output request.aligned _ request.token request.parameters request.caches).2
    request.embedding_parameters.2.2.2.1 request.embedding_caches request.dispatch ResidualAttentionHighWater.first_token_grows

def Request.body (angle : RopeAngles.Inputs) : TokenParameterConstruction.BodyPlan request.embedding angle where
  chain := (request.chain angle).plan
  caches := (request.chain angle).cacheSafe
  parameters := request.embedding.afterEmbedding.protected_mono
    (fun _ _ inside => (request.chain angle).safeBefore _ _ inside) request.embedding_parameters

def Request.finalCursor : Nat := request.frontier.cursor+DecodeHighWaterConstruction.bytes p.graph.stages 0

theorem Request.final_aligned : request.finalCursor%16=0 := by
  apply TokenBoundaryHighWater.aligned_next request.frontier.aligned
  exact DecodeHighWaterConstruction.bytes_aligned p.graph.stages 0

theorem Request.final_room : request.finalCursor+506880≤2^64 := room_final _ _ request.room

theorem Request.final_source (angle : RopeAngles.Inputs) : Before request.finalCursor (request.body angle).finalStorage.source.base 10240 :=
  (request.chain angle).outputBound

attribute [local irreducible] TokenParameterConstruction.BodyPlan.hiddenBuffer
  TokenAutoregressiveMemoryConstruction.Entry.source TokenAutoregressiveMemoryConstruction.Entry.storage
  TokenParameterConstruction.EmbeddingPlan.afterEmbedding
  Qwen38TrellisM1Max.Graph.hidden TokenParameterConstruction.BodyPlan.finalStorage

section Frame
variable {norm : Blocks.Norm} {projection : AffineVerifyLinear.Projection 10 248320}
  {input : Fin 5120 → ArrayStorage.BF}
  (before : ByteMemory.Bytes) (source : ArrayStorage.BFBuffer input)
  (region : Nat → Nat → Prop)
  (frame : ∀ base size, region base size → ∀ offset < size, source.bytes (base+offset)=before (base+offset))
  (normWeights : ArrayStorage.BFBuffer norm.weight) (normShared : normWeights.bytes=before)
  (outputWeights : AffineDevice.Storage projection) (outputShared : AffineMemory.Shared projection outputWeights before)
  (normSafe : region normWeights.base 10240)
  (outputSafe : AffineMemoryFrames.Protected projection outputWeights region)
private theorem frame_norm_base :
    (FinalProjectionConstruction.fromFrame before source region frame normWeights normShared outputWeights outputShared normSafe outputSafe).normWeights.base=normWeights.base := rfl
private theorem frame_output_regions (property : Nat → Nat → Prop) :
    AffineMemoryFrames.Protected projection (FinalProjectionConstruction.fromFrame before source region frame normWeights normShared outputWeights outputShared normSafe outputSafe).outputWeights property ↔
      AffineMemoryFrames.Protected projection outputWeights property :=
  AffineMemoryFrames.reframe_protected _ _ _ _ property
end Frame

private theorem norm_base {embedding : TokenParameterConstruction.EmbeddingPlan original}
    (body : TokenParameterConstruction.BodyPlan embedding angle) : body.finalStorage.normWeights.base=embedding.afterEmbedding.graph.norm.base := by
  unfold TokenParameterConstruction.BodyPlan.finalStorage
  exact frame_norm_base embedding.entry.source.bytes body.hiddenBuffer (embedding.ChainSafe body.chain)
    (fun _ _ safe => body.frame safe) embedding.afterEmbedding.graph.norm embedding.afterEmbedding.graph.normShared
    embedding.afterEmbedding.graph.output embedding.afterEmbedding.graph.outputShared body.parameters.2.2.2.2.1 body.parameters.2.2.2.2.2

private theorem output_regions {embedding : TokenParameterConstruction.EmbeddingPlan original}
    (body : TokenParameterConstruction.BodyPlan embedding angle) (property : Nat → Nat → Prop) :
    AffineMemoryFrames.Protected p.graph.output body.finalStorage.outputWeights property ↔
      AffineMemoryFrames.Protected p.graph.output embedding.afterEmbedding.graph.output property := by
  unfold TokenParameterConstruction.BodyPlan.finalStorage
  exact frame_output_regions embedding.entry.source.bytes body.hiddenBuffer (embedding.ChainSafe body.chain)
    (fun _ _ safe => body.frame safe) embedding.afterEmbedding.graph.norm embedding.afterEmbedding.graph.normShared
    embedding.afterEmbedding.graph.output embedding.afterEmbedding.graph.outputShared body.parameters.2.2.2.2.1 body.parameters.2.2.2.2.2 property

theorem Request.final_norm (angle : RopeAngles.Inputs) : Before request.finalCursor (request.body angle).finalStorage.normWeights.base 10240 := by
  rw [norm_base]
  exact TokenBoundaryHighWater.before_next request.embedding_parameters.2.2.2.2.1

theorem Request.final_weights (angle : RopeAngles.Inputs) :
    AffineMemoryFrames.Protected p.graph.output (request.body angle).finalStorage.outputWeights (Before request.finalCursor) :=
  (output_regions _ _).mpr (AffineMemoryFrames.protected_mono _ _
    (fun _ _ inside => TokenBoundaryHighWater.before_next inside) request.embedding_parameters.2.2.2.2.2)

def Request.graph (angle : RopeAngles.Inputs) : TokenParameterConstruction.GraphPlan request.embedding angle :=
  TokenBoundaryHighWater.graphPlan (request.body angle) request.final_aligned request.final_room
    (request.final_source angle) (request.final_norm angle) (request.final_weights angle)

theorem Request.chain_caches (angle : RopeAngles.Inputs) :
    DecodePreservation.Protected (Before request.finalCursor) p.graph.stages
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2
      (request.graph angle).forward.hiddenBuffer.bytes (request.graph angle).forward.chainCache :=
  (request.chain angle).cachesBound

theorem Request.tail_safe (angle : RopeAngles.Inputs) : Qwen38TrellisM1MaxMemory.CacheSafe (request.graph angle).forward :=
  TokenBoundaryHighWater.graph_cache_safe (request.body angle) request.final_aligned request.final_room
    (request.final_source angle) (request.final_norm angle) (request.final_weights angle) (request.chain_caches angle)

theorem Request.logits_bound (angle : RopeAngles.Inputs) :
    Before (request.finalCursor+506880) (request.graph angle).forward.logitsBuffer.base 496640 :=
  (TokenBoundaryHighWater.graph_output (request.body angle) request.final_aligned request.final_room
    (request.final_source angle) (request.final_norm angle) (request.final_weights angle)).2

theorem Request.logits_caches (angle : RopeAngles.Inputs) :
    DecodePreservation.Protected (Before (request.finalCursor+506880)) p.graph.stages
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2
      (request.graph angle).forward.logitsBuffer.bytes ((request.graph angle).forward.afterCache (request.tail_safe angle)) :=
  TokenBoundaryHighWater.graph_caches_before (request.body angle) request.final_aligned request.final_room
    (request.final_source angle) (request.final_norm angle) (request.final_weights angle) (request.chain_caches angle)

theorem Request.sampler_room : request.finalCursor+506880+1952≤2^64 := room_sampler _ _ request.room

def Request.sampler (angle : RopeAngles.Inputs) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :=
  TokenBoundaryHighWater.samplerPlan (TokenBoundaryHighWater.final_next request.final_aligned) request.sampler_room
    (request.logits_bound angle) lseLocal tileLocal finishLocal

def Request.plan (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    TokenParameterConstruction.Plan original angle sampling where
  embedding := request.embedding
  graph := request.graph angle
  tailSafe := request.tail_safe angle
  sampler := request.sampler angle lseLocal tileLocal finishLocal
  samplingSafe := TokenBoundaryHighWater.sampler_cache_regions
    (TokenBoundaryHighWater.final_next request.final_aligned) request.sampler_room (request.logits_bound angle)
    sampling lseLocal tileLocal finishLocal _ _ _ (request.logits_caches angle)


theorem Request.before_frontier (inside : Before request.cursor base size) : Before request.frontier.cursor base size :=
  TokenBoundaryHighWater.before_next inside

theorem Request.before_final (inside : Before request.cursor base size) : Before request.finalCursor base size :=
  TokenBoundaryHighWater.before_next (request.before_frontier inside)

theorem Request.before_sampler (inside : Before request.cursor base size) : Before (request.finalCursor+506880) base size :=
  TokenBoundaryHighWater.before_next (request.before_final inside)

theorem Request.safe_before (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (inside : Before request.cursor base size) :
    TokenParameterMemory.StepSafe (request.plan angle sampling lseLocal tileLocal finishLocal).step base size := by
  refine ⟨?_,⟨⟨?_,?_⟩,?_⟩⟩
  · exact (TokenBoundaryHighWater.embeddingWorkspace request.aligned (room_embedding _ _ request.room)
      request.token request.parameters).live (TokenBoundaryHighWater.fresh inside)
  · exact (request.chain angle).safeBefore base size (request.before_frontier inside)
  · exact TokenWorkspaceConstruction.graph_tail_protect (request.body angle)
      (TokenBoundaryHighWater.finalWorkspace request.final_aligned request.final_room
        (request.final_source angle) (request.final_norm angle) (request.final_weights angle))
      (TokenBoundaryHighWater.fresh (request.before_final inside))
  · exact TokenBoundaryHighWater.sampler_region (TokenBoundaryHighWater.final_next request.final_aligned)
      request.sampler_room (request.logits_bound angle) sampling lseLocal tileLocal finishLocal
      (request.before_sampler inside)

theorem Request.parameters_safe (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    original.Protected (TokenParameterMemory.StepSafe (request.plan angle sampling lseLocal tileLocal finishLocal).step) :=
  original.protected_mono (fun _ _ inside => request.safe_before angle sampling lseLocal tileLocal finishLocal inside) request.parameters

def Request.nextCursor : Nat := request.finalCursor+506880+1952

theorem Request.next_aligned : request.nextCursor%16=0 :=
  TokenBoundaryHighWater.sampler_next (TokenBoundaryHighWater.final_next request.final_aligned)

theorem Request.token_bound (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    Before request.nextCursor (request.plan angle sampling lseLocal tileLocal finishLocal).sampled.sampler.selection.destination 4 :=
  (TokenBoundaryHighWater.sampler_output (TokenBoundaryHighWater.final_next request.final_aligned)
    request.sampler_room (request.logits_bound angle) sampling lseLocal tileLocal finishLocal).2

theorem Request.caches_bound (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    DecodePreservation.Protected (Before request.nextCursor) p.graph.stages
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2
      (request.plan angle sampling lseLocal tileLocal finishLocal).sampled.memory
      (request.plan angle sampling lseLocal tileLocal finishLocal).sampled.afterCache :=
  TokenBoundaryHighWater.sampler_actual_caches_before (request.plan angle sampling lseLocal tileLocal finishLocal).sampled
    (request.logits_caches angle)

end Inference.Models.Qwen.TokenFirstPlanConstruction
