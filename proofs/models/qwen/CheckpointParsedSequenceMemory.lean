import models.qwen.InitialParsedRequestConstruction
import models.qwen.CheckpointConstructedSequenceMemory

-- The parsed initialization and finite token run share the exact intermediate
-- heap. No post-initialization buffer attachment or per-token plan is supplied.
-- Source semantics still relies on explicit native binding/compiler/hardware
-- boundaries; later kernels are not all connected to parsed source here.
namespace Inference.Models.Qwen.CheckpointParsedSequenceMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  InitialParsedRequestConstruction.Request.first
  InitialParsedRequestConstruction.Request.parsedSources
  CheckpointConstructedSequenceMemory.result

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  {original : TokenParameterMemory.Storage p initialHeap}
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (request : InitialParsedRequestConstruction.Request original)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angles : TokenAutoregressive.Angles) (locals : Nat → Locals)
  (steps : Nat) (supported : 1+steps≤262144)
  (room : (CheckpointReadyMemory.ready encoded binding request.first primitive sampling samplingPrimitive angles locals).frontier.cursor+
    TokenConstructedSequenceMemory.bytes p 1 steps≤2^64)

noncomputable def result :=
  CheckpointConstructedSequenceMemory.result encoded binding request.first primitive sampling samplingPrimitive angles locals
    steps supported room

private theorem first_token : request.first.token=request.token := by
  unfold InitialParsedRequestConstruction.Request.first
  rfl

theorem readback :
    let reference := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive
      request.token angles (1+steps) supported
    let actual := (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.state
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) := by
  simpa only [result,first_token] using
    CheckpointConstructedSequenceMemory.readback encoded binding request.first primitive sampling samplingPrimitive angles locals
      steps supported room

-- These are the actual constructed source executions and the exact heap used
-- by the same request whose token sequence appears in the readback conclusion.
theorem readback_from_source :
    InitialCacheParsedSourceConstruction.Executes p.graph.stages request.initialWorkspace.caches
      (InitialCacheParsedSourceConstruction.entrySources request.scalars initialHeap
        request.initialWorkspace request.initial_separate (token:=request.token)) request.parsedSources ∧
    request.first.ready.state.index.bytes=request.parsedSources.history.bytes ∧
    let reference := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive
      request.token angles (1+steps) supported
    let actual := (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.state
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  ⟨request.parsed_executions,request.initial_state_heap,
    readback encoded binding request primitive sampling samplingPrimitive angles locals steps supported room⟩

theorem parameter_regions (property : Nat → Nat → Prop) :
    (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.parameters.Protected property ↔
      original.Protected property :=
  (CheckpointConstructedSequenceMemory.parameter_regions encoded binding request.first primitive sampling samplingPrimitive angles locals
    steps supported room property).trans (request.prefix_regions property)

theorem parameter_bytes (region : TokenParameterConstruction.Region original base size)
    (offset : Nat) (bound : offset<size) :
    (result encoded binding request primitive sampling samplingPrimitive angles locals steps supported room).ready.state.index.bytes (base+offset)=
      initialHeap (base+offset) :=
  (CheckpointConstructedSequenceMemory.parameter_bytes encoded binding request.first primitive sampling samplingPrimitive angles locals
    steps supported room (request.prefix_region region) offset bound).trans (request.prefix_bytes region offset bound)

noncomputable def full
    (headroom : (CheckpointReadyMemory.ready encoded binding request.first primitive sampling samplingPrimitive angles locals).frontier.cursor+
      TokenConstructedSequenceMemory.bytes p 1 262143≤2^64) :=
  result encoded binding request primitive sampling samplingPrimitive angles locals 262143 (by decide) headroom

theorem full_readback
    (headroom : (CheckpointReadyMemory.ready encoded binding request.first primitive sampling samplingPrimitive angles locals).frontier.cursor+
      TokenConstructedSequenceMemory.bytes p 1 262143≤2^64) :
    let reference := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive request.token angles 262144 (by decide)
    let actual := (full encoded binding request primitive sampling samplingPrimitive angles locals headroom).ready.state
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  readback encoded binding request primitive sampling samplingPrimitive angles locals 262143 (by decide) headroom

end Inference.Models.Qwen.CheckpointParsedSequenceMemory
