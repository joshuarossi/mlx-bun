import models.qwen.ReachedNativeCopiedTokenState
import models.qwen.CheckpointDictionaryBinding
import models.qwen.RopeInputConstruction
namespace Inference.Models.Qwen.CheckpointNativeCopiedTokenState
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference NativeCopiedTokenRoute
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenRoute.final NativeCopiedTokenRoute.finalStorage NativeCopiedTokenRoute.finalAllocation
  FinalProjectionSamplerSource.Execution.sampler
variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {before : TokenAutoregressiveMemory.State p n}
  (step : NativeCopiedTokenState.Step p sampling before (RopeInputConstruction.inputs n))
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (selected : ReachedTokenContext.Primitive.Selections p.graph)
  (other : ReachedTokenContext.Primitive.Other p.graph)
  (samplingPrimitive : LogSumExpRanges.Primitives sampling) (supported : n+1≤262144)

noncomputable def advance : TokenAutoregressiveMemory.State p (n+1) :=
  ReachedNativeCopiedTokenState.advance step (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    (ReachedTokenContext.Primitive.graphPrimitives selected other) samplingPrimitive
    (RopeInputConstruction.inputs_bound n (by omega)) supported (RopeInputConstruction.target n) RopeInputConstruction.error
    (RopeInputConstruction.input_error n (by omega)) (RopeInputConstruction.target_base_nonnegative n)

-- This is exactly the reached logical recurrence, including its original
-- reference-cache/error budget; only the physical source route is new.
noncomputable def logical :=
  ReachedTokenContext.Logical.advance p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    (ReachedTokenContext.Primitive.graphPrimitives selected other) sampling samplingPrimitive before.logical
    (RopeInputConstruction.inputs n) (RopeInputConstruction.inputs_bound n (by omega)) supported
    (RopeInputConstruction.target n) RopeInputConstruction.error
    (RopeInputConstruction.input_error n (by omega)) (RopeInputConstruction.target_base_nonnegative n)

theorem advance_logical : (advance step encoded binding selected other samplingPrimitive supported).logical=
    logical (before:=before) encoded binding selected other samplingPrimitive supported := rfl

theorem advance_heap : (advance step encoded binding selected other samplingPrimitive supported).index.bytes=
    (final step.execution).sampler.memory := rfl

theorem advance_address : (advance step encoded binding selected other samplingPrimitive supported).index.base=
    (final step.execution).sampler.selection.destination := rfl

theorem readback :
    let actual := advance step encoded binding selected other samplingPrimitive supported
    let reference := logical (before:=before) encoded binding selected other samplingPrimitive supported
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  ReachedNativeCopiedTokenState.readback step (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    (ReachedTokenContext.Primitive.graphPrimitives selected other) samplingPrimitive
    (RopeInputConstruction.inputs_bound n (by omega)) supported (RopeInputConstruction.target n) RopeInputConstruction.error
    (RopeInputConstruction.input_error n (by omega)) (RopeInputConstruction.target_base_nonnegative n)

theorem cache_invariant :
    let actual := advance step encoded binding selected other samplingPrimitive supported
    DecodeChainSequenceRanges.CachesBound p.graph.stages actual.readCaches ∧
      DecodeChain.CacheErrors p.graph.stages actual.readCaches actual.logical.targetCache actual.logical.errorCache ∧
      DecodeChain.CachesFinite p.graph.stages actual.readCaches :=
  ReachedNativeCopiedTokenState.cache_invariant step (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    (ReachedTokenContext.Primitive.graphPrimitives selected other) samplingPrimitive
    (RopeInputConstruction.inputs_bound n (by omega)) supported (RopeInputConstruction.target n) RopeInputConstruction.error
    (RopeInputConstruction.input_error n (by omega)) (RopeInputConstruction.target_base_nonnegative n)

theorem source_token (unsigned : Bool) (inputs : Inputs step.execution)
    (finalNative : FinalProjectionParsedSource.Native (finalStorage step.execution) (finalAllocation step.execution))
    (lseNative : LogSumExpSourceHost.Attachment) :
    Certificate step.execution unsigned inputs
      (ReachedNativeCopiedTokenState.ranges (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
        (ReachedTokenContext.Primitive.graphPrimitives selected other) (RopeInputConstruction.inputs_bound n (by omega)) supported)
      supported finalNative lseNative ∧
    (ArgmaxLaunchSourceMemory.tokenMemory (final step.execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory (final step.execution).sampler.selection.destination).toNat)=
      some (advance step encoded binding selected other samplingPrimitive supported).index.read :=
  ReachedNativeCopiedTokenState.source_token step (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    (ReachedTokenContext.Primitive.graphPrimitives selected other) samplingPrimitive
    (RopeInputConstruction.inputs_bound n (by omega)) supported (RopeInputConstruction.target n) RopeInputConstruction.error
    (RopeInputConstruction.input_error n (by omega)) (RopeInputConstruction.target_base_nonnegative n)
    unsigned inputs finalNative lseNative

noncomputable def context (locals : Nat → TokenReadyMemory.Locals) : ReachedTokenContext.Context p :=
  ReachedTokenContext.ofNormal (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    selected other sampling samplingPrimitive RopeInputConstruction.angles locals

theorem advance_context (locals : Nat → TokenReadyMemory.Locals) :
    let ctx := context encoded binding selected other samplingPrimitive locals
    (advance step encoded binding selected other samplingPrimitive supported).logical=
      ReachedTokenContext.Logical.advance p ctx.parameters ctx.primitive ctx.sampling ctx.samplingPrimitive before.logical
        (ctx.angles.value n) (ctx.angles.ranges n (by omega)) supported
        (ctx.angles.target n) (ctx.angles.error n) (ctx.angles.accuracy n (by omega)) (ctx.angles.base n (by omega)) := rfl

theorem follows_context (locals : Nat → TokenReadyMemory.Locals) (initialToken : Fin 248320)
    (same : before.logical=(context encoded binding selected other samplingPrimitive locals).run initialToken n (by omega)) :
    (advance step encoded binding selected other samplingPrimitive supported).logical=
      (context encoded binding selected other samplingPrimitive locals).run initialToken (n+1) supported := by
  rw [advance_context step encoded binding selected other samplingPrimitive supported locals]
  rw [same]
  rfl
end Inference.Models.Qwen.CheckpointNativeCopiedTokenState
