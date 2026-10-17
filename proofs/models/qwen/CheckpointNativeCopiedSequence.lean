import models.qwen.NativeCopiedTokenConstruction
import models.qwen.CheckpointNativeCopiedTokenState

namespace Inference.Models.Qwen.CheckpointNativeCopiedSequence
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling NativeCopiedTokenConstruction
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (selected : ReachedTokenContext.Primitive.Selections p.graph)
  (other : ReachedTokenContext.Primitive.Other p.graph)
  (samplingPrimitive : LogSumExpRanges.Primitives sampling)

noncomputable def reference (token : Fin 248320) (time : Nat) (supported : time≤262144) :=
  ReachedTokenContext.Logical.run p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    (ReachedTokenContext.Primitive.graphPrimitives selected other) sampling samplingPrimitive token
    RopeInputConstruction.angles time supported

variable {n : Nat} {before : TokenAutoregressiveMemory.State p n}
  {current : TokenParameterMemory.Storage p before.index.bytes}

noncomputable def advance (plan : Plan p sampling (RopeInputConstruction.inputs n) before current) (supported : n+1≤262144) :=
  CheckpointNativeCopiedTokenState.advance (step plan) encoded binding selected other samplingPrimitive supported

def nextParameters (plan : Plan p sampling (RopeInputConstruction.inputs n) before current)
    (safe : Safe plan) (supported : n+1≤262144) :
    TokenParameterMemory.Storage p (advance encoded binding selected other samplingPrimitive plan supported).index.bytes :=
  after plan safe

-- Allocations and native attachments are required only for reached states.
-- Every successor uses the exact preceding token/cache heap and the bundle
-- retained on it; no schedule for arbitrary unreachable heaps is assumed.
inductive Trace (p : Pipeline) (sampling : LogSumExpRanges.Platform)
    (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (selected : ReachedTokenContext.Primitive.Selections p.graph)
    (other : ReachedTokenContext.Primitive.Other p.graph) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (initialPlan : InitialCacheMemory.Plan p.graph.stages) (initialMemory : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token)
    (shared : index.bytes=InitialCacheMemory.execute p.graph.stages initialPlan initialMemory)
    (original : TokenParameterMemory.Storage p index.bytes) :
    {time : Nat} → (before : TokenAutoregressiveMemory.State p time) →
      TokenParameterMemory.Storage p before.index.bytes → Prop where
  | initial : Trace p sampling encoded binding selected other samplingPrimitive token initialPlan initialMemory index shared original
      (TokenAutoregressiveMemory.initial p token initialPlan initialMemory index shared) original
  | step {time : Nat} {before : TokenAutoregressiveMemory.State p time}
      {current : TokenParameterMemory.Storage p before.index.bytes}
      (previous : Trace p sampling encoded binding selected other samplingPrimitive token initialPlan initialMemory index shared original before current)
      (supported : time+1≤262144)
      (plan : Plan p sampling (RopeInputConstruction.inputs time) before current) (safe : Safe plan)
      (unsigned : Bool) (inputs : NativeCopiedTokenRoute.Inputs (NativeCopiedTokenConstruction.step plan).execution)
      (finalNative : FinalProjectionParsedSource.Native
        (NativeCopiedTokenRoute.finalStorage (NativeCopiedTokenConstruction.step plan).execution)
        (NativeCopiedTokenRoute.finalAllocation (NativeCopiedTokenConstruction.step plan).execution))
      (lseNative : LogSumExpSourceHost.Attachment) :
      Trace p sampling encoded binding selected other samplingPrimitive token initialPlan initialMemory index shared original
        (advance encoded binding selected other samplingPrimitive plan supported)
        (nextParameters encoded binding selected other samplingPrimitive plan safe supported)

variable {token : Fin 248320} {initialPlan : InitialCacheMemory.Plan p.graph.stages} {initialMemory : ByteMemory.Bytes}
  {index : Inference.State.TokenStorage.Buffer token}
  {shared : index.bytes=InitialCacheMemory.execute p.graph.stages initialPlan initialMemory}
  {original : TokenParameterMemory.Storage p index.bytes}

theorem Trace.logical_eq
    (trace : Trace p sampling encoded binding selected other samplingPrimitive token initialPlan initialMemory index shared original before current)
    (supported : n≤262144) : before.logical=reference encoded binding selected other samplingPrimitive token n supported := by
  induction trace with
  | initial => rfl
  | step previous bound plan safe unsigned inputs finalNative lseNative ih =>
    rw [advance,CheckpointNativeCopiedTokenState.advance_logical]
    unfold reference ReachedTokenContext.Logical.run
    unfold CheckpointNativeCopiedTokenState.logical
    rw [ih (by omega)]
    rfl

theorem Trace.readback
    (trace : Trace p sampling encoded binding selected other samplingPrimitive token initialPlan initialMemory index shared original before current)
    (supported : n≤262144) :
    (before.index.read,before.readCaches)=
      ((reference encoded binding selected other samplingPrimitive token n supported).token.val,
        (reference encoded binding selected other samplingPrimitive token n supported).cache) := by
  rw [Inference.State.TokenStorage.Buffer.read_correct,TokenAutoregressiveMemory.State.caches_eq]
  exact congrArg (fun state : TokenAutoregressive.State p n => (state.token.val,state.cache))
    (trace.logical_eq encoded binding selected other samplingPrimitive supported)

theorem Trace.parameters_preserved
    (trace : Trace p sampling encoded binding selected other samplingPrimitive token initialPlan initialMemory index shared original before current)
    (property : Nat → Nat → Prop) : current.Protected property ↔ original.Protected property := by
  induction trace with
  | initial => exact Iff.rfl
  | step previous bound plan safe unsigned inputs finalNative lseNative ih =>
    exact (NativeCopiedTokenConstruction.parameters_preserved plan safe property).trans ih

theorem Trace.frame
    (trace : Trace p sampling encoded binding selected other samplingPrimitive token initialPlan initialMemory index shared original before current)
    (region : TokenParameterConstruction.Region original base size) (offset : Nat) (inside : offset<size) :
    before.index.bytes (base+offset)=index.bytes (base+offset) := by
  induction trace with
  | initial => rfl
  | step previous bound plan safe unsigned inputs finalNative lseNative ih =>
    have currentRegion : TokenParameterConstruction.Region _ base size :=
      fun property kept => region property
        ((previous.parameters_preserved encoded binding selected other samplingPrimitive property).mp kept)
    exact (NativeCopiedTokenConstruction.frame plan safe currentRegion offset inside).trans ih

theorem Trace.output_addresses
    (trace : Trace p sampling encoded binding selected other samplingPrimitive token initialPlan initialMemory index shared original before current) :
    AffineStorageLineage.addresses p.graph.output current.graph.output=
      AffineStorageLineage.addresses p.graph.output original.graph.output := by
  induction trace with
  | initial => rfl
  | step previous bound plan safe unsigned inputs finalNative lseNative ih =>
    exact (output_addresses_after plan safe).trans ih

theorem Trace.head_addresses
    (trace : Trace p sampling encoded binding selected other samplingPrimitive token initialPlan initialMemory index shared original before current)
    (plan : Plan p sampling (RopeInputConstruction.inputs n) before current) :
    AffineStorageLineage.addresses p.graph.output (AffineStorageLineage.launchWeights
      (FinalProjectionConstruction.output (NativeCopiedTokenRoute.finalStorage (NativeCopiedTokenConstruction.step plan).execution)
        (NativeCopiedTokenRoute.finalAllocation (NativeCopiedTokenConstruction.step plan).execution)))=
      AffineStorageLineage.addresses p.graph.output original.graph.output :=
  (final_launch_addresses plan).trans
    (trace.output_addresses encoded binding selected other samplingPrimitive)

-- The parsed uint32 store is the very buffer handed to the next embedding.
theorem step_source (plan : Plan p sampling (RopeInputConstruction.inputs n) before current)
    (supported : n+1≤262144) (unsigned : Bool) (inputs : NativeCopiedTokenRoute.Inputs (step plan).execution)
    (finalNative : FinalProjectionParsedSource.Native
      (NativeCopiedTokenRoute.finalStorage (step plan).execution) (NativeCopiedTokenRoute.finalAllocation (step plan).execution))
    (lseNative : LogSumExpSourceHost.Attachment) :
    NativeCopiedTokenRoute.Certificate (step plan).execution unsigned inputs
      (ReachedNativeCopiedTokenState.ranges (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
        (ReachedTokenContext.Primitive.graphPrimitives selected other)
        (RopeInputConstruction.inputs_bound n (by omega)) supported)
      supported finalNative lseNative ∧
    (ArgmaxLaunchSourceMemory.tokenMemory (NativeCopiedTokenRoute.final (step plan).execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory (NativeCopiedTokenRoute.final (step plan).execution).sampler.selection.destination).toNat)=
      some (advance encoded binding selected other samplingPrimitive plan supported).index.read :=
  CheckpointNativeCopiedTokenState.source_token (step plan) encoded binding selected other samplingPrimitive supported
    unsigned inputs finalNative lseNative

-- The consumer's actual buffer address and heap are the producer's parsed
-- uint32 destination and completed sampler heap, including at the first
-- initial-to-positive transition.
theorem feedback_heap (plan : Plan p sampling (RopeInputConstruction.inputs n) before current)
    (safe : Safe plan) (supported : n+1≤262144)
    (next : Plan p sampling (RopeInputConstruction.inputs (n+1))
      (advance encoded binding selected other samplingPrimitive plan supported)
      (nextParameters encoded binding selected other samplingPrimitive plan safe supported)) :
    (NativeCopiedTokenRoute.embedding (step next).execution).tokenBuffer.bytes=
      (NativeCopiedTokenRoute.final (step plan).execution).sampler.memory ∧
    (NativeCopiedTokenRoute.embedding (step next).execution).tokenBuffer.base=
      (NativeCopiedTokenRoute.final (step plan).execution).sampler.selection.destination := by
  rw [original_token next]
  exact ⟨rfl,rfl⟩

theorem feedback_source (plan : Plan p sampling (RopeInputConstruction.inputs n) before current)
    (safe : Safe plan) (supported : n+1≤262144)
    (next : Plan p sampling (RopeInputConstruction.inputs (n+1))
      (advance encoded binding selected other samplingPrimitive plan supported)
      (nextParameters encoded binding selected other samplingPrimitive plan safe supported))
    (unsigned : Bool) (inputs : NativeCopiedTokenRoute.Inputs (step plan).execution)
    (finalNative : FinalProjectionParsedSource.Native
      (NativeCopiedTokenRoute.finalStorage (step plan).execution) (NativeCopiedTokenRoute.finalAllocation (step plan).execution))
    (lseNative : LogSumExpSourceHost.Attachment) :
    (ArgmaxLaunchSourceMemory.tokenMemory (NativeCopiedTokenRoute.final (step plan).execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory
        (NativeCopiedTokenRoute.embedding (step next).execution).tokenBuffer.base).toNat)=
      some (NativeCopiedTokenRoute.embedding (step next).execution).tokenBuffer.read := by
  have linked := feedback_heap encoded binding selected other samplingPrimitive plan safe supported next
  rw [linked.2,original_token next]
  exact (step_source encoded binding selected other samplingPrimitive plan supported unsigned inputs finalNative lseNative).2

end Inference.Models.Qwen.CheckpointNativeCopiedSequence
