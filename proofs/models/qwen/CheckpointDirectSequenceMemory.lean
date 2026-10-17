import models.qwen.InitialDirectRequestConstruction
import models.qwen.TokenConstructedSequenceLogical
import models.qwen.CheckpointReadyMemory

-- This first token uses the generic BF16 direct zero-slab branch. Continuation
-- consumes that exact resulting heap through the constructed growth/reuse path.
-- Source/compiler/hardware, loading, and native ownership remain boundaries.
namespace Inference.Models.Qwen.CheckpointDirectSequenceMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling TokenReadyMemory
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  InitialDirectRequestConstruction.Request.firstReady

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  {original : TokenParameterMemory.Storage p initialHeap}
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (request : InitialDirectRequestConstruction.Request original)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angles : TokenAutoregressive.Angles) (locals : Nat → Locals)

def context : Context p := CheckpointReadyMemory.context encoded binding primitive sampling samplingPrimitive angles locals

variable (steps : Nat) (supported : 1+steps≤262144)
  (room : request.frontier.cursor+InitialDirectRequestConstruction.bytes p+
    TokenConstructedSequenceMemory.bytes p 1 steps≤2^64)

include room in
private theorem continuation_room :
    (request.firstReady (context encoded binding primitive sampling samplingPrimitive angles locals)).frontier.cursor+
      TokenConstructedSequenceMemory.bytes p 1 steps≤2^64 := by
  rw [request.first_cursor]
  exact room

noncomputable def result :=
  TokenConstructedSequenceMemory.run (context encoded binding primitive sampling samplingPrimitive angles locals) request.dispatch
    (request.firstReady (context encoded binding primitive sampling samplingPrimitive angles locals)) steps supported
    (continuation_room encoded binding request primitive sampling samplingPrimitive angles locals steps room)

attribute [local irreducible] result

theorem readback :
    let reference := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive
      request.token angles (1+steps) supported
    let actual := (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.state
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) := by
  unfold result
  exact TokenConstructedSequenceLogical.run_readback
    (context encoded binding primitive sampling samplingPrimitive angles locals) request.dispatch _ steps supported
    (continuation_room encoded binding request primitive sampling samplingPrimitive angles locals steps room)
    (by decide) (request.first_logical _)

theorem readback_from_source :
    InitialCacheParsedSourceConstruction.Executes p.graph.stages request.initialWorkspace.caches
      (InitialCacheParsedSourceConstruction.entrySources request.scalars initialHeap request.initialWorkspace
        request.initial_separate (token:=request.token)) request.parsedSources ∧
    request.initialized.state.index.bytes=request.parsedSources.history.bytes ∧
    let reference := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive
      request.token angles (1+steps) supported
    let actual := (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.state
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  ⟨request.parsed_executions,request.initial_state_heap,
    readback encoded binding request primitive sampling samplingPrimitive angles locals steps supported room⟩

-- These are properties of the cache values read from the constructed heap,
-- including their propagated error against the real-valued reference cache.
theorem readback_invariant :
    let reference := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive
      request.token angles (1+steps) supported
    let actual := (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.state
    actual.index.read < 248320 ∧
      DecodeChainSequenceRanges.CachesBound p.graph.stages actual.readCaches ∧
      DecodeChain.CacheErrors p.graph.stages actual.readCaches reference.targetCache reference.errorCache ∧
      DecodeChain.CachesFinite p.graph.stages actual.readCaches := by
  have equal := readback encoded binding request primitive sampling samplingPrimitive angles locals steps supported room
  dsimp only at equal ⊢
  have token := congrArg Prod.fst equal
  have caches := congrArg Prod.snd equal
  dsimp only at token caches
  rw [token,caches]
  exact ⟨(CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive
      request.token angles (1+steps) supported).token.isLt,
    CheckpointDictionaryBinding.run_invariant p encoded binding primitive sampling samplingPrimitive
      request.token angles (1+steps) supported⟩

theorem parameter_regions (property : Nat → Nat → Prop) :
    (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.parameters.Protected property ↔
      original.Protected property :=
  ((result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).path.parameters_protected property).trans
    (request.first_parameters _ property)

theorem parameter_bytes (region : TokenParameterConstruction.Region original base size)
    (offset : Nat) (bound : offset<size) :
    (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.state.index.bytes (base+offset)=
      initialHeap (base+offset) := by
  have retained : TokenParameterConstruction.Region
      (request.firstReady (context encoded binding primitive sampling samplingPrimitive angles locals)).parameters base size :=
    fun property safe => region property ((request.first_parameters _ property).mp safe)
  exact ((result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).path.frame
    retained offset bound).trans (request.first_frame _ region offset bound)

noncomputable def full
    (headroom : request.frontier.cursor+InitialDirectRequestConstruction.bytes p+
      TokenConstructedSequenceMemory.bytes p 1 262143≤2^64) :=
  result encoded binding request primitive sampling samplingPrimitive angles locals 262143 (by decide) headroom

theorem full_readback
    (headroom : request.frontier.cursor+InitialDirectRequestConstruction.bytes p+
      TokenConstructedSequenceMemory.bytes p 1 262143≤2^64) :
    let reference := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive request.token angles 262144 (by decide)
    let actual := (full encoded binding request primitive sampling samplingPrimitive angles locals headroom).ready.state
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  readback encoded binding request primitive sampling samplingPrimitive angles locals 262143 (by decide) headroom

end Inference.Models.Qwen.CheckpointDirectSequenceMemory
