import models.qwen.DecodeInitialConstruction
import models.qwen.TokenBoundaryHighWater

-- The generic BF16 null-cache route, from the existing token and parameter
-- heap through embedding, direct initial cache writes, logits, and sampling.
-- Native host/compiler/allocator correspondence is a separate obligation.
namespace Inference.Models.Qwen.TokenDirectInitialConstruction
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open TokenBoundaryHighWater (Before)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages DecodeInitialConstruction.bytes

variable {p : Pipeline} {state : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p state.index.bytes}

def bytes (p : Pipeline) : Nat := 13120+DecodeInitialConstruction.bytes p.graph.stages+506880+1952

private theorem room_sampler (cursor work : Nat) {limit : Nat} (h : cursor+(13120+work+506880+1952)≤limit) :
    cursor+13120+work+506880+1952≤limit := by simpa only [Nat.add_assoc] using h
private theorem room_final (cursor work : Nat) {limit : Nat} (h : cursor+(13120+work+506880+1952)≤limit) :
    cursor+13120+work+506880≤limit := (Nat.le_add_right _ 1952).trans (room_sampler cursor work h)
private theorem room_chain (cursor work : Nat) {limit : Nat} (h : cursor+(13120+work+506880+1952)≤limit) :
    cursor+13120+work≤limit := (Nat.le_add_right _ 506880).trans (room_final cursor work h)
private theorem room_embedding (cursor work : Nat) {limit : Nat} (h : cursor+(13120+work+506880+1952)≤limit) :
    cursor+13120≤limit := (Nat.le_add_right _ work).trans (room_chain cursor work h)

structure Request (original : TokenParameterMemory.Storage p state.index.bytes) where
  cursor : Nat
  aligned : cursor%16=0
  room : cursor+bytes p≤2^64
  token : Before cursor state.index.base 4
  parameters : original.Protected (Before cursor)
  caches : DecodePreservation.Protected (Before cursor) p.graph.stages state.logical.cache state.index.bytes state.caches
  dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages
  keyCopied : Bool
  valueCopied : Bool

variable (request : Request original)

def Request.embedding : TokenParameterConstruction.EmbeddingPlan original :=
  TokenBoundaryHighWater.embeddingPlan request.aligned (room_embedding _ _ request.room)
    request.token request.parameters request.caches

def Request.frontier : ResidualDeltaHighWater.Frontier :=
  ⟨request.cursor+13120,TokenBoundaryHighWater.embedding_next request.aligned⟩

theorem Request.embedding_parameters : request.embedding.afterEmbedding.Protected (Before request.frontier.cursor) :=
  TokenBoundaryHighWater.embedding_parameters request.aligned _ request.token request.parameters request.caches

theorem Request.embedding_caches : DecodePreservation.Protected (Before request.frontier.cursor)
    p.graph.stages state.logical.cache request.embedding.entry.source.bytes request.embedding.entry.storage :=
  TokenBoundaryHighWater.embedding_caches request.aligned _ request.token request.parameters request.caches

def Request.chain (angle : RopeAngles.Inputs) :=
  DecodeInitialConstruction.build p.graph.stages .root state.logical.cache (p.embedding.forward state.logical.token)
    angle request.embedding.entry.source request.embedding.entry.storage request.embedding.afterEmbedding.graph.stages request.frontier
    (room_chain _ _ request.room)
    (TokenBoundaryHighWater.embedding_output request.aligned _ request.token request.parameters request.caches).2
    request.embedding_parameters.2.2.2.1 request.embedding_caches request.dispatch request.keyCopied request.valueCopied

attribute [local irreducible] Request.chain
  TokenAutoregressiveMemoryConstruction.Entry.source TokenAutoregressiveMemoryConstruction.Entry.storage
  TokenParameterConstruction.EmbeddingPlan.afterEmbedding Qwen38TrellisM1Max.Graph.hidden

def Request.finalCursor : Nat := request.frontier.cursor+DecodeInitialConstruction.bytes p.graph.stages

theorem Request.final_aligned : request.finalCursor%16=0 :=
  TokenBoundaryHighWater.aligned_next request.frontier.aligned (DecodeInitialConstruction.bytes_aligned _)

theorem Request.final_room : request.finalCursor+506880≤2^64 := room_final _ _ request.room

def Request.chainParameters (angle : RopeAngles.Inputs) : TokenParameterMemory.Storage p (request.chain angle).outputBuffer.bytes :=
  TokenBoundaryHighWater.retainParameters request.embedding.afterEmbedding _ request.embedding_parameters
    (fun _ _ inside => (request.chain angle).other_region inside)

theorem Request.chain_parameter_regions (angle : RopeAngles.Inputs) (property : Nat → Nat → Prop) :
    (request.chainParameters angle).Protected property ↔ original.Protected property :=
  (request.embedding.afterEmbedding.reframe_protected _
    (request.embedding.afterEmbedding.protected_mono
      (fun _ _ inside => (request.chain angle).other_region inside) request.embedding_parameters) property).trans
    (request.embedding.afterEmbedding_protected property)

theorem Request.chain_parameters_bound (angle : RopeAngles.Inputs) :
    (request.chainParameters angle).Protected (Before request.finalCursor) :=
  TokenBoundaryHighWater.retainParameters_before request.embedding.afterEmbedding _ request.embedding_parameters
    (fun _ _ inside => (request.chain angle).other_region inside)

attribute [local irreducible] Request.chainParameters

def Request.finalStorage (angle : RopeAngles.Inputs) :
    FinalProjectionConstruction.Storage p.graph.finalNorm p.graph.output
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).1 where
  source := (request.chain angle).outputBuffer
  normWeights := (request.chainParameters angle).graph.norm
  normShared := (request.chainParameters angle).graph.normShared
  outputWeights := (request.chainParameters angle).graph.output
  outputShared := (request.chainParameters angle).graph.outputShared

theorem Request.final_source (angle : RopeAngles.Inputs) :
    (request.finalStorage angle).source=(request.chain angle).outputBuffer := rfl

def Request.finalWorkspace (angle : RopeAngles.Inputs) : FinalProjectionAllocation.Workspace (request.finalStorage angle) :=
  TokenBoundaryHighWater.finalWorkspace request.final_aligned request.final_room (request.chain angle).outputBound
    (request.chain_parameters_bound angle).2.2.2.2.1 (request.chain_parameters_bound angle).2.2.2.2.2

def Request.logits (angle : RopeAngles.Inputs) : Fin 248320 → ArrayStorage.BF := (request.finalWorkspace angle).output.output

theorem Request.final_base (angle : RopeAngles.Inputs) : (request.finalWorkspace angle).base=request.finalCursor := rfl

def Request.logitsBuffer (angle : RopeAngles.Inputs) : ArrayStorage.BFBuffer (request.logits angle) :=
  (request.finalWorkspace angle).output.outputBuffer

theorem Request.logits_eq (angle : RopeAngles.Inputs) :
    request.logits angle=p.graph.forward state.logical.cache (p.embedding.forward state.logical.token) angle := by
  unfold Qwen38TrellisM1Max.Graph.forward Qwen38TrellisM1Max.Graph.normalized Qwen38TrellisM1Max.Graph.hidden
  exact (request.finalWorkspace angle).output.output_eq

theorem Request.logits_bound (angle : RopeAngles.Inputs) :
    Before (request.finalCursor+506880) (request.logitsBuffer angle).base 496640 :=
  (TokenBoundaryHighWater.final_output_buffer (storage:=request.finalStorage angle)
    request.final_aligned request.final_room (request.chain angle).outputBound
    (request.chain_parameters_bound angle).2.2.2.2.1 (request.chain_parameters_bound angle).2.2.2.2.2).2

attribute [local irreducible] Request.finalWorkspace Request.finalStorage

theorem Request.final_frame (angle : RopeAngles.Inputs) {base size : Nat}
    (inside : Before request.finalCursor base size) (offset : Nat) (bound : offset<size) :
    (request.logitsBuffer angle).bytes (base+offset)=(request.chain angle).outputBuffer.bytes (base+offset) :=
  ((request.finalWorkspace angle).other_region (by rw [request.final_base]; exact TokenBoundaryHighWater.fresh inside) offset bound).trans
    (congrArg (fun buffer => buffer.bytes (base+offset)) (request.final_source angle))

def Request.logitCaches (angle : RopeAngles.Inputs) : DecodeFrame.Storage p.graph.stages
    (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2
    (request.logitsBuffer angle).bytes :=
  TokenBoundaryHighWater.retainCaches _ _ _ _ (request.chain angle).after (request.chain angle).cachesBound
    (fun _ _ inside => request.final_frame angle inside)

theorem Request.logit_caches_bound (angle : RopeAngles.Inputs) : DecodePreservation.Protected
    (Before (request.finalCursor+506880)) p.graph.stages
    (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2
    (request.logitsBuffer angle).bytes (request.logitCaches angle) :=
  TokenBoundaryHighWater.retainCaches_before _ _ _ _ (request.chain angle).after (request.chain angle).cachesBound
    (fun _ _ inside => request.final_frame angle inside)

theorem Request.sampler_room : request.finalCursor+506880+1952≤2^64 := room_sampler _ _ request.room

def Request.samplerPlan (angle : RopeAngles.Inputs) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :=
  TokenBoundaryHighWater.samplerPlan (TokenBoundaryHighWater.final_next request.final_aligned) request.sampler_room
    (request.logits_bound angle) lseLocal tileLocal finishLocal

def Request.sampler (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :=
  (request.samplerPlan angle lseLocal tileLocal finishLocal).build sampling

def Request.afterCaches (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) : DecodeFrame.Storage p.graph.stages
    (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2
    (request.sampler angle sampling lseLocal tileLocal finishLocal).memory :=
  TokenBoundaryHighWater.samplerCachesAfter (TokenBoundaryHighWater.final_next request.final_aligned) request.sampler_room
    (request.logits_bound angle) sampling lseLocal tileLocal finishLocal _ _ (request.logitCaches angle) (request.logit_caches_bound angle)

def Request.nextCursor : Nat := request.finalCursor+506880+1952

theorem Request.next_aligned : request.nextCursor%16=0 :=
  TokenBoundaryHighWater.sampler_next (TokenBoundaryHighWater.final_next request.final_aligned)

theorem Request.next_cursor : request.nextCursor=request.cursor+bytes p := by
  simp only [Request.nextCursor,Request.finalCursor,Request.frontier,bytes,Nat.add_assoc]

theorem Request.after_caches_bound (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) : DecodePreservation.Protected
    (Before request.nextCursor) p.graph.stages
    (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2
    (request.sampler angle sampling lseLocal tileLocal finishLocal).memory (request.afterCaches angle sampling lseLocal tileLocal finishLocal) :=
  TokenBoundaryHighWater.sampler_caches_before (TokenBoundaryHighWater.final_next request.final_aligned) request.sampler_room
    (request.logits_bound angle) sampling lseLocal tileLocal finishLocal _ _ (request.logitCaches angle) (request.logit_caches_bound angle)

theorem Request.token_bound (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    Before request.nextCursor (request.sampler angle sampling lseLocal tileLocal finishLocal).selection.destination 4 :=
  (TokenBoundaryHighWater.sampler_output (TokenBoundaryHighWater.final_next request.final_aligned) request.sampler_room
    (request.logits_bound angle) sampling lseLocal tileLocal finishLocal).2

theorem Request.other_region (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    {base size : Nat} (inside : Before request.cursor base size) (offset : Nat) (bound : offset<size) :
    (request.sampler angle sampling lseLocal tileLocal finishLocal).memory (base+offset)=state.index.bytes (base+offset) := by
  have frontier : Before request.frontier.cursor base size := TokenBoundaryHighWater.before_next inside
  have finalBound : Before request.finalCursor base size := TokenBoundaryHighWater.before_next frontier
  have sampleBound : Before (request.finalCursor+506880) base size := TokenBoundaryHighWater.before_next finalBound
  exact (TokenBoundaryHighWater.sampler_frame (TokenBoundaryHighWater.final_next request.final_aligned) request.sampler_room
    (request.logits_bound angle) sampling lseLocal tileLocal finishLocal sampleBound offset bound).trans
    ((request.final_frame angle finalBound offset bound).trans
    (((request.chain angle).other_region frontier offset bound).trans
    (request.embedding.entry.frame
      ((TokenBoundaryHighWater.embeddingWorkspace request.aligned (room_embedding _ _ request.room)
        request.token request.parameters).live (TokenBoundaryHighWater.fresh inside)) offset bound)))

def Request.afterParameters (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    TokenParameterMemory.Storage p (request.sampler angle sampling lseLocal tileLocal finishLocal).memory :=
  TokenBoundaryHighWater.retainParameters original _ request.parameters
    (fun _ _ inside => request.other_region angle sampling lseLocal tileLocal finishLocal inside)

theorem Request.after_parameter_regions (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) (property : Nat → Nat → Prop) :
    (request.afterParameters angle sampling lseLocal tileLocal finishLocal).Protected property ↔ original.Protected property :=
  original.reframe_protected _ (original.protected_mono
    (fun _ _ inside => request.other_region angle sampling lseLocal tileLocal finishLocal inside) request.parameters) property

end Inference.Models.Qwen.TokenDirectInitialConstruction
