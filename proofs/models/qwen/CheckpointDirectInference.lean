import models.qwen.CheckpointDirectSequenceMemory
import models.qwen.GraphDivisionPrimitives
import models.qwen.RopeInputConstruction

-- The constructed checkpoint path with proved position inputs and division
-- envelopes. This fixes the proof bundles; it does not identify a native run.
-- Physical primitive selection, remaining primitive envelopes, checkpoint
-- attachment and available address space are still explicit conditions.
namespace Inference.Models.Qwen.CheckpointDirectInference
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling TokenReadyMemory
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  GraphDivisionPrimitives.graphPrimitives GreedySampling.sample GreedySampling.score
  CheckpointDictionaryBinding.run

private theorem token_time (p : Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles)
    (first second : Nat) (hf : first≤262144) (hs : second≤262144) (same : first=second) :
    (CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive token angles first hf).token=
      (CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive token angles second hs).token := by
  cases same
  rfl

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  {original : TokenParameterMemory.Storage p initialHeap}
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (request : InitialDirectRequestConstruction.Request original)
  (selected : GraphDivisionPrimitives.Selections p.graph) (other : GraphDivisionPrimitives.Other p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (locals : Nat → Locals)
  (steps : Nat) (supported : 1+steps≤262144)
  (room : request.frontier.cursor+InitialDirectRequestConstruction.bytes p+
    TokenConstructedSequenceMemory.bytes p 1 steps≤2^64)

noncomputable def run :=
  CheckpointDirectSequenceMemory.result encoded binding request
    (GraphDivisionPrimitives.graphPrimitives selected other) sampling samplingPrimitive
    RopeInputConstruction.angles locals steps supported room

attribute [local irreducible] run

theorem readback :
    let reference := CheckpointDictionaryBinding.run p encoded binding
      (GraphDivisionPrimitives.graphPrimitives selected other) sampling samplingPrimitive request.token
      RopeInputConstruction.angles (1+steps) supported
    let actual := (run encoded binding request selected other sampling samplingPrimitive locals steps supported room).ready.state
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) := by
  unfold run
  exact CheckpointDirectSequenceMemory.readback encoded binding request
    (GraphDivisionPrimitives.graphPrimitives selected other) sampling samplingPrimitive
    RopeInputConstruction.angles locals steps supported room

theorem cache_invariant :
    let reference := CheckpointDictionaryBinding.run p encoded binding
      (GraphDivisionPrimitives.graphPrimitives selected other) sampling samplingPrimitive request.token
      RopeInputConstruction.angles (1+steps) supported
    let actual := (run encoded binding request selected other sampling samplingPrimitive locals steps supported room).ready.state
    actual.index.read<248320 ∧
      DecodeChainSequenceRanges.CachesBound p.graph.stages actual.readCaches ∧
      DecodeChain.CacheErrors p.graph.stages actual.readCaches reference.targetCache reference.errorCache ∧
      DecodeChain.CachesFinite p.graph.stages actual.readCaches := by
  unfold run
  exact CheckpointDirectSequenceMemory.readback_invariant encoded binding request
    (GraphDivisionPrimitives.graphPrimitives selected other) sampling samplingPrimitive
    RopeInputConstruction.angles locals steps supported room

-- The emitted token read from memory is the actual floating-point greedy
-- winner, with the specified lowest-index tie break. It need not equal the
-- winner of an independently generated exact-real token sequence.
theorem selected_token :
    let before := CheckpointDictionaryBinding.run p encoded binding
      (GraphDivisionPrimitives.graphPrimitives selected other) sampling samplingPrimitive request.token
      RopeInputConstruction.angles steps (by omega)
    let logits := TokenSampledSequenceRanges.logits p before.cache before.token (RopeInputConstruction.inputs steps)
    let actual := (run encoded binding request selected other sampling samplingPrimitive locals steps supported room).ready.state
    ∃ winner : Fin 248320, actual.index.read=winner.val ∧
      (∀ i, GreedySampling.score sampling logits i≤GreedySampling.score sampling logits winner) ∧
      (∀ i, GreedySampling.score sampling logits winner=GreedySampling.score sampling logits i → winner.val ≤ i.val) := by
  have correct := CheckpointDictionaryBinding.run_correct p encoded binding
    (GraphDivisionPrimitives.graphPrimitives selected other) sampling samplingPrimitive request.token
    RopeInputConstruction.angles steps (by omega : steps+1≤262144)
  have equal := readback encoded binding request selected other sampling samplingPrimitive locals steps supported room
  dsimp only at equal ⊢
  refine ⟨(CheckpointDictionaryBinding.run p encoded binding
    (GraphDivisionPrimitives.graphPrimitives selected other) sampling samplingPrimitive request.token
    RopeInputConstruction.angles (1+steps) supported).token,?_,?_⟩
  · exact congrArg Prod.fst equal
  · rw [token_time p encoded binding (GraphDivisionPrimitives.graphPrimitives selected other)
      sampling samplingPrimitive request.token RopeInputConstruction.angles (1+steps) (steps+1)
      supported (by omega) (Nat.add_comm 1 steps)]
    exact correct.2.2.2

-- This is the compositional rounding-error budget for the final modeled
-- logits. A practically small final bound and winner margins remain separate
-- obligations; no such guarantee is inferred merely from finiteness.
theorem last_logits_error :
    let primitive := GraphDivisionPrimitives.graphPrimitives selected other
    let parameters := CheckpointDictionaryBinding.pipeline_parameters p encoded binding
    let before := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive request.token
      RopeInputConstruction.angles steps (by omega)
    let logits := TokenSampledSequenceRanges.logits p before.cache before.token (RopeInputConstruction.inputs steps)
    ∀ i, |Model.toReal (logits i)-(p.targetRun before.targetCache before.token (RopeInputConstruction.target steps)).1 i|≤
      (TokenSampledSequenceRanges.budget p parameters primitive before.cache before.cacheBound before.targetCache
        before.errorCache before.token (RopeInputConstruction.inputs steps) (RopeInputConstruction.inputs_bound steps (by omega))
        (by omega : steps+1≤262144) (RopeInputConstruction.target steps) RopeInputConstruction.error).1 i :=
  (CheckpointDictionaryBinding.run_correct p encoded binding (GraphDivisionPrimitives.graphPrimitives selected other)
    sampling samplingPrimitive request.token RopeInputConstruction.angles steps (by omega)).1

theorem parameter_bytes (region : TokenParameterConstruction.Region original base size)
    (offset : Nat) (bound : offset<size) :
    (run encoded binding request selected other sampling samplingPrimitive locals steps supported room).ready.state.index.bytes (base+offset)=
      initialHeap (base+offset) := by
  unfold run
  exact CheckpointDirectSequenceMemory.parameter_bytes encoded binding request
    (GraphDivisionPrimitives.graphPrimitives selected other) sampling samplingPrimitive
    RopeInputConstruction.angles locals steps supported room region offset bound

end Inference.Models.Qwen.CheckpointDirectInference
