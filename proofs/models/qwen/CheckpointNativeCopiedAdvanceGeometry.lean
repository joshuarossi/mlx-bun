import models.qwen.NativeCopiedAdvanceGeometry
import models.qwen.CheckpointNativeCopiedSequence
import models.qwen.TokenBoundaryHighWater
namespace Inference.Models.Qwen.CheckpointNativeCopiedAdvanceGeometry
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open NativeCopiedTokenConstruction
open TokenBoundaryHighWater (Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenConstruction.step NativeCopiedTokenConstruction.after
  NativeCopiedTokenRoute.final

variable {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (selected : ReachedTokenContext.Primitive.Selections p.graph)
  (other : ReachedTokenContext.Primitive.Other p.graph)
  (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  {n : Nat} {before : TokenAutoregressiveMemory.State p n}
  {current : TokenParameterMemory.Storage p before.index.bytes}
  (plan : Plan p sampling (RopeInputConstruction.inputs n) before current)
  (supported : n+1≤262144)

-- The full-primitive advance geometry and this reached-checkpoint advance
-- share their physical Step. The latter uses its own proved address theorem,
-- without upgrading the reached-input numerical primitive contract.
theorem token_bound (cursor : Nat)
    (bound : Before cursor (NativeCopiedTokenRoute.final (step plan).execution).sampler.selection.destination 4) :
    Before cursor
      (CheckpointNativeCopiedSequence.advance encoded binding selected other samplingPrimitive plan supported).index.base 4 := by
  rw [CheckpointNativeCopiedSequence.advance,CheckpointNativeCopiedTokenState.advance_address]
  exact bound

theorem cache_geometry (property : Nat → Nat → Prop)
    (bound : DecodePreservation.Protected property p.graph.stages
      (p.run before.logical.cache before.logical.token (RopeInputConstruction.inputs n)).2
      (NativeCopiedTokenRoute.final (step plan).execution).sampler.memory
      (NativeCopiedTokenMemory.after (step plan).execution (step plan).safe)) :
    let actual := CheckpointNativeCopiedSequence.advance encoded binding selected other samplingPrimitive plan supported
    DecodePreservation.Protected property p.graph.stages actual.logical.cache actual.index.bytes actual.caches := bound

theorem parameters_geometry (safe : Safe plan) (property : Nat → Nat → Prop)
    (bound : (after plan safe).Protected property) :
    (CheckpointNativeCopiedSequence.nextParameters encoded binding selected other samplingPrimitive plan safe supported).Protected property := bound

-- Original parameter addresses are retained by the actual source execution;
-- they need not be bounded again on an independently supplied result bundle.
theorem parameters_before (safe : Safe plan) (cursor : Nat)
    (bound : current.Protected (Before cursor)) :
    (CheckpointNativeCopiedSequence.nextParameters encoded binding selected other samplingPrimitive plan safe supported).Protected (Before cursor) :=
  parameters_geometry encoded binding selected other samplingPrimitive plan supported safe (Before cursor)
    ((NativeCopiedTokenConstruction.parameters_preserved plan safe (Before cursor)).mpr bound)

theorem bounds (safe : Safe plan) (cursor : Nat)
    (token : Before cursor (NativeCopiedTokenRoute.final (step plan).execution).sampler.selection.destination 4)
    (caches : DecodePreservation.Protected (Before cursor) p.graph.stages
      (p.run before.logical.cache before.logical.token (RopeInputConstruction.inputs n)).2
      (NativeCopiedTokenRoute.final (step plan).execution).sampler.memory
      (NativeCopiedTokenMemory.after (step plan).execution (step plan).safe))
    (parameters : (after plan safe).Protected (Before cursor)) :
    let actual := CheckpointNativeCopiedSequence.advance encoded binding selected other samplingPrimitive plan supported
    Before cursor actual.index.base 4 ∧
      DecodePreservation.Protected (Before cursor) p.graph.stages actual.logical.cache actual.index.bytes actual.caches ∧
      (CheckpointNativeCopiedSequence.nextParameters encoded binding selected other samplingPrimitive plan safe supported).Protected (Before cursor) :=
  ⟨token_bound encoded binding selected other samplingPrimitive plan supported cursor token,
    cache_geometry encoded binding selected other samplingPrimitive plan supported (Before cursor) caches,
    parameters_geometry encoded binding selected other samplingPrimitive plan supported safe (Before cursor) parameters⟩

end Inference.Models.Qwen.CheckpointNativeCopiedAdvanceGeometry
