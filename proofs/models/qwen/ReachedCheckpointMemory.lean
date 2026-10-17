import models.qwen.ReachedTokenInitialMemory
import models.qwen.ReachedTokenSequenceMemory
import models.qwen.InitialDirectRequestConstruction
import models.qwen.CheckpointDictionaryBinding
import models.qwen.RopeInputConstruction

-- Complete constructed token memory from checkpoint certificates, using the
-- normal-input rsqrt contract and proved IEEE division envelopes. Loading,
-- physical primitives, source correspondence and address headroom remain explicit.
namespace Inference.Models.Qwen.ReachedCheckpointMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory (Ready Locals)
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  InitialDirectRequestConstruction.Request.first InitialDirectRequestConstruction.Request.initialized

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  {original : TokenParameterMemory.Storage p initialHeap}
  (request : InitialDirectRequestConstruction.Request original)

section First
variable (context : ReachedTokenContext.Context p)

noncomputable def firstReady : Ready p 1 request.frontier.cursor :=
  ReachedTokenInitialMemory.ready request.first context request.frontier.cursor
    request.first_ordered request.initial_parameters_cut

theorem first_cursor : (firstReady request context).frontier.cursor=
    request.frontier.cursor+InitialDirectRequestConstruction.bytes p := by
  rw [firstReady,ReachedTokenInitialMemory.ready_cursor]
  unfold InitialDirectRequestConstruction.Request.first
  simp only [TokenInitializationHighWater.next,InitialDirectRequestConstruction.Request.initialFrontier,
    InitialDirectRequestConstruction.bytes,Nat.add_assoc]

theorem first_parameters (property : Nat → Nat → Prop) :
    (firstReady request context).parameters.Protected property ↔ original.Protected property :=
  (ReachedTokenInitialMemory.ready_parameters request.first context request.frontier.cursor
    request.first_ordered request.initial_parameters_cut property).trans (request.initial_parameter_regions property)

theorem first_frame (region : TokenParameterConstruction.Region original base size)
    (offset : Nat) (bound : offset<size) :
    (firstReady request context).state.index.bytes (base+offset)=initialHeap (base+offset) := by
  have retained : TokenParameterConstruction.Region request.initialized.parameters base size :=
    fun property safe => region property ((request.initial_parameter_regions property).mp safe)
  exact (ReachedTokenInitialMemory.ready_frame request.first context request.frontier.cursor
    request.first_ordered request.initial_parameters_cut retained offset bound).trans
    (request.initial_frame region offset bound)

theorem first_logical : (firstReady request context).state.logical=context.run request.token 1 (by decide) :=
  ReachedTokenInitialMemory.ready_logical request.first context request.frontier.cursor
    request.first_ordered request.initial_parameters_cut request.token request.initial_logical

end First

variable (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (selected : ReachedTokenContext.Primitive.Selections p.graph)
  (other : ReachedTokenContext.Primitive.Other p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (locals : Nat → Locals)

noncomputable def context : ReachedTokenContext.Context p :=
  ReachedTokenContext.ofNormal (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    selected other sampling samplingPrimitive RopeInputConstruction.angles locals

variable (steps : Nat) (supported : 1+steps≤262144)
  (room : request.frontier.cursor+InitialDirectRequestConstruction.bytes p+
    TokenConstructedSequenceMemory.bytes p 1 steps≤2^64)

include room in
private theorem continuation_room :
    (firstReady request (context encoded binding selected other sampling samplingPrimitive locals)).frontier.cursor+
      TokenConstructedSequenceMemory.bytes p 1 steps≤2^64 := by
  rw [first_cursor]
  exact room

noncomputable def result :=
  ReachedTokenSequenceMemory.run (context encoded binding selected other sampling samplingPrimitive locals)
    request.dispatch (firstReady request (context encoded binding selected other sampling samplingPrimitive locals))
    steps supported (continuation_room request encoded binding selected other sampling samplingPrimitive locals steps room)

attribute [local irreducible] result

private theorem token_time (c : ReachedTokenContext.Context p) (token : Fin 248320)
    (first second : Nat) (hf : first≤262144) (hs : second≤262144) (same : first=second) :
    (c.run token first hf).token=(c.run token second hs).token := by
  cases same
  rfl

theorem readback :
    let reference := (context encoded binding selected other sampling samplingPrimitive locals).run request.token (1+steps) supported
    let actual := (result request encoded binding selected other sampling samplingPrimitive locals steps supported room).ready.state
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) := by
  exact (result request encoded binding selected other sampling samplingPrimitive locals steps supported room).path.readback
    (by decide) (first_logical request _) supported

theorem readback_invariant :
    let reference := (context encoded binding selected other sampling samplingPrimitive locals).run request.token (1+steps) supported
    let actual := (result request encoded binding selected other sampling samplingPrimitive locals steps supported room).ready.state
    actual.index.read<248320 ∧
      DecodeChainSequenceRanges.CachesBound p.graph.stages actual.readCaches ∧
      DecodeChain.CacheErrors p.graph.stages actual.readCaches reference.targetCache reference.errorCache ∧
      DecodeChain.CachesFinite p.graph.stages actual.readCaches := by
  have equal := readback request encoded binding selected other sampling samplingPrimitive locals steps supported room
  dsimp only at equal ⊢
  have token := congrArg Prod.fst equal
  have cache := congrArg Prod.snd equal
  dsimp only at token cache
  rw [token,cache]
  exact ⟨((context encoded binding selected other sampling samplingPrimitive locals).run request.token (1+steps) supported).token.isLt,
    (context encoded binding selected other sampling samplingPrimitive locals).run_invariant request.token (1+steps) supported⟩

theorem parameter_bytes (region : TokenParameterConstruction.Region original base size)
    (offset : Nat) (bound : offset<size) :
    (result request encoded binding selected other sampling samplingPrimitive locals steps supported room).ready.state.index.bytes (base+offset)=
      initialHeap (base+offset) := by
  have retained : TokenParameterConstruction.Region
      (firstReady request (context encoded binding selected other sampling samplingPrimitive locals)).parameters base size :=
    fun property safe => region property ((first_parameters request _ property).mp safe)
  exact ((result request encoded binding selected other sampling samplingPrimitive locals steps supported room).path.frame
    retained offset bound).trans (first_frame request _ region offset bound)

theorem selected_token :
    let before := (context encoded binding selected other sampling samplingPrimitive locals).run request.token steps (by omega)
    let logits := TokenSampledSequenceRanges.logits p before.cache before.token (RopeInputConstruction.inputs steps)
    let actual := (result request encoded binding selected other sampling samplingPrimitive locals steps supported room).ready.state
    ∃ winner : Fin 248320, actual.index.read=winner.val ∧
      (∀ i, GreedySampling.score sampling logits i≤GreedySampling.score sampling logits winner) ∧
      (∀ i, GreedySampling.score sampling logits winner=GreedySampling.score sampling logits i → winner.val ≤ i.val) := by
  let c := context encoded binding selected other sampling samplingPrimitive locals
  have correct := ReachedTokenContext.Logical.run_correct p c.parameters c.primitive c.sampling c.samplingPrimitive
    request.token c.angles steps (by omega : steps+1≤262144)
  have equal := readback request encoded binding selected other sampling samplingPrimitive locals steps supported room
  dsimp only at equal ⊢
  refine ⟨(c.run request.token (1+steps) supported).token,congrArg Prod.fst equal,?_⟩
  rw [token_time c request.token (1+steps) (steps+1) supported (by omega) (Nat.add_comm 1 steps)]
  exact correct.2.2.2

theorem last_logits_error :
    let c := context encoded binding selected other sampling samplingPrimitive locals
    let before := c.run request.token steps (by omega)
    let logits := TokenSampledSequenceRanges.logits p before.cache before.token (RopeInputConstruction.inputs steps)
    ∀ i, |Model.toReal (logits i)-(p.targetRun before.targetCache before.token (RopeInputConstruction.target steps)).1 i|≤
      (ReachedSequenceRanges.Sample.budget p c.parameters c.primitive before.cache before.cacheBound
        before.targetCache before.errorCache before.token (RopeInputConstruction.inputs steps)
        (RopeInputConstruction.inputs_bound steps (by omega)) (by omega : steps+1≤262144)
        (RopeInputConstruction.target steps) RopeInputConstruction.error).1 i := by
  exact (ReachedTokenContext.Logical.run_correct p
    (context encoded binding selected other sampling samplingPrimitive locals).parameters
    (context encoded binding selected other sampling samplingPrimitive locals).primitive sampling samplingPrimitive
    request.token RopeInputConstruction.angles steps (by omega)).1

theorem initialized_source :
    InitialCacheParsedSourceConstruction.Executes p.graph.stages request.initialWorkspace.caches
      (InitialCacheParsedSourceConstruction.entrySources request.scalars initialHeap request.initialWorkspace
        request.initial_separate (token:=request.token)) request.parsedSources ∧
    request.initialized.state.index.bytes=request.parsedSources.history.bytes :=
  ⟨request.parsed_executions,request.initial_state_heap⟩

end Inference.Models.Qwen.ReachedCheckpointMemory
