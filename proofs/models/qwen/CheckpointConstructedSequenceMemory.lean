import models.qwen.TokenConstructedSequenceMemory
import models.qwen.CheckpointReadyMemory
import models.qwen.Qwen38TrellisM1MaxCacheFootprint

-- A finite checkpoint-certified logical/heap run, with constructed growth and
-- reuse launches. Encoding/bindings, loaded storage, primitive contracts and
-- total fresh bump-address headroom remain explicit. Cache extent excludes
-- weights, workspaces and retained native buffers; no physical peak-RAM or
-- native compiler correspondence, small final error or exact-real winner
-- agreement is established here.
namespace Inference.Models.Qwen.CheckpointConstructedSequenceMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory
open TokenBoundaryHighWater (Before)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  CheckpointReadyMemory.ready TokenConstructedSequenceMemory.run

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes} {original : TokenParameterMemory.Storage p initialHeap}
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (request : TokenFirstInitializedConstruction.Request original)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angles : TokenAutoregressive.Angles) (locals : Nat → Locals)
  (steps : Nat) (supported : 1+steps≤262144)
  (room : (CheckpointReadyMemory.ready encoded binding request primitive sampling samplingPrimitive angles locals).frontier.cursor+
    TokenConstructedSequenceMemory.bytes p 1 steps≤2^64)

noncomputable def result : TokenConstructedSequenceMemory.Result
    (CheckpointReadyMemory.context encoded binding primitive sampling samplingPrimitive angles locals) request.dispatch
    (CheckpointReadyMemory.ready encoded binding request primitive sampling samplingPrimitive angles locals) steps :=
  TokenConstructedSequenceMemory.run
    (CheckpointReadyMemory.context encoded binding primitive sampling samplingPrimitive angles locals) request.dispatch
    (CheckpointReadyMemory.ready encoded binding request primitive sampling samplingPrimitive angles locals) steps supported room

attribute [local irreducible] result

theorem trace : CheckpointTokenMemory.Trace encoded binding original request.initialization request.initial_safe
    primitive sampling samplingPrimitive angles
    (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.state
    (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.parameters :=
  (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).path.extend
    (CheckpointReadyMemory.trace encoded binding request primitive sampling samplingPrimitive angles locals)

theorem readback :
    let reference := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive request.token angles (1+steps) supported
    let actual := (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.state
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  CheckpointTokenMemory.readback
    (trace encoded binding request primitive sampling samplingPrimitive angles locals steps supported room) supported

theorem parameter_bytes (region : TokenParameterConstruction.Region original base size) (offset : Nat) (bound : offset<size) :
    (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.state.index.bytes (base+offset)=initialHeap (base+offset) :=
  CheckpointTokenMemory.parameter_bytes
    (trace encoded binding request primitive sampling samplingPrimitive angles locals steps supported room) region offset bound

theorem parameter_regions (property : Nat → Nat → Prop) :
    (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.parameters.Protected property ↔ original.Protected property :=
  CheckpointTokenMemory.parameter_regions
    (trace encoded binding request primitive sampling samplingPrimitive angles locals steps supported room) property

theorem geometry :
    let final := (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready
    Before final.frontier.cursor final.state.index.base 4 ∧
      DecodePreservation.Protected (Before final.frontier.cursor) p.graph.stages final.state.logical.cache final.state.index.bytes final.state.caches ∧
      DecodePreservation.Protected (DecodeHighWaterGeometry.After request.frontier.cursor) p.graph.stages final.state.logical.cache final.state.index.bytes final.state.caches ∧
      DecodeCacheGeometry.Pairwise p.graph.stages final.state.logical.cache final.state.index.bytes final.state.caches :=
  ⟨(result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.token,
    (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.cachesBound,
    (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.cachesAbove,
    (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.pairwise⟩

theorem cursor_eq :
    (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.frontier.cursor=
      (CheckpointReadyMemory.ready encoded binding request primitive sampling samplingPrimitive angles locals).frontier.cursor+
        TokenConstructedSequenceMemory.bytes p 1 steps :=
  (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).cursor_eq

-- Sum of the actual final cache extents, not the peak allocator footprint.
theorem cache_bytes :
    let final := (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.state
    Qwen38TrellisM1MaxCacheFootprint.regionBytes
      (DecodeCacheGeometry.regions p.graph.stages final.logical.cache final.index.bytes final.caches)=
      153944064+65536*Inference.State.KvAllocation.capacity (1+steps) :=
  (Qwen38TrellisM1MaxCacheFootprint.actual_regions _ _ _ _).trans
    (Qwen38TrellisM1MaxCacheFootprint.graph_bytes p.graph (1+steps))

theorem cache_bound :
    let final := (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.state
    Qwen38TrellisM1MaxCacheFootprint.regionBytes
      (DecodeCacheGeometry.regions p.graph.stages final.logical.cache final.index.bytes final.caches)≤17333813248 :=
  Qwen38TrellisM1MaxCacheFootprint.actual_graph_bound p.graph (1+steps) _ _ _ supported

noncomputable def full
    (headroom : (CheckpointReadyMemory.ready encoded binding request primitive sampling samplingPrimitive angles locals).frontier.cursor+
      TokenConstructedSequenceMemory.bytes p 1 262143≤2^64) :=
  result encoded binding request primitive sampling samplingPrimitive angles locals 262143 (by decide) headroom

theorem full_readback
    (headroom : (CheckpointReadyMemory.ready encoded binding request primitive sampling samplingPrimitive angles locals).frontier.cursor+
      TokenConstructedSequenceMemory.bytes p 1 262143≤2^64) :
    let reference := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive request.token angles 262144 (by decide)
    let actual := (full encoded binding request primitive sampling samplingPrimitive angles locals headroom).ready.state
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  readback encoded binding request primitive sampling samplingPrimitive angles locals 262143 (by decide) headroom

end Inference.Models.Qwen.CheckpointConstructedSequenceMemory
