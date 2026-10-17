import models.qwen.CheckpointNativeCopiedTokenState

namespace Inference.Models.Qwen.NativeCopiedSampledLogits
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference NativeCopiedTokenRoute
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenRoute.final NativeCopiedTokenRoute.finalStorage NativeCopiedTokenRoute.finalAllocation
  FinalProjectionSamplerSource.Execution.sampler

variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {cache : p.graph.Cache n} {token : Fin 248320} {angle : RopeAngles.Inputs}
  (run : Execution p sampling cache token angle)

-- Both indexed routes retain the actual final projection buffer on the
-- sampler heap, so numerical statements apply to those final byte reads.
def buffer := ArrayFrame.bf (FinalProjectionSamplerSource.logitsBuffer (finalStorage run) (finalAllocation run))
  (final run).sampler.memory
  (FinalProjectionSamplerSource.preserve_region (final run) (final run).workspace.separate)

theorem current_heap : (buffer run).bytes=(final run).sampler.memory := rfl

theorem read_eq (column : Fin 248320) : (buffer run).read column=(p.run cache token angle).1 column :=
  ((buffer run).read_correct column).trans
    (congrFun (FinalProjectionSamplerSource.Execution.logits_eq (final run)) column)

variable {before : TokenAutoregressiveMemory.State p n}
  (step : NativeCopiedTokenState.Step p sampling before (RopeInputConstruction.inputs n))
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (selected : ReachedTokenContext.Primitive.Selections p.graph)
  (other : ReachedTokenContext.Primitive.Other p.graph) (supported : n+1≤262144)

theorem advance_heap (samplingPrimitive : LogSumExpRanges.Primitives sampling) :
    (buffer step.execution).bytes=
      (CheckpointNativeCopiedTokenState.advance step encoded binding selected other samplingPrimitive supported).index.bytes := rfl

include encoded binding selected other supported in
theorem finite_bound (column : Fin 248320) :
    Model.isFinite ((buffer step.execution).read column)=true ∧
    |Model.toReal ((buffer step.execution).read column)|≤(2:ℝ)^(23:Nat) := by
  rw [read_eq]
  exact ReachedNativeCopiedTokenState.model_bound
    (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    (ReachedTokenContext.Primitive.graphPrimitives selected other)
    (RopeInputConstruction.inputs_bound n (by omega)) supported column

theorem logit_error (column : Fin 248320) :
    |Model.toReal ((buffer step.execution).read column)-
      (p.targetRun before.logical.targetCache before.logical.token (RopeInputConstruction.target n)).1 column|≤
      (ReachedSequenceRanges.Sample.budget p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
        (ReachedTokenContext.Primitive.graphPrimitives selected other) before.logical.cache before.logical.cacheBound
        before.logical.targetCache before.logical.errorCache before.logical.token
        (RopeInputConstruction.inputs n) (RopeInputConstruction.inputs_bound n (by omega)) supported
        (RopeInputConstruction.target n) RopeInputConstruction.error).1 column := by
  rw [read_eq]
  exact (ReachedSequenceRanges.Token.run_correct p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    (ReachedTokenContext.Primitive.graphPrimitives selected other) before.logical.cache before.logical.cacheBound
    before.logical.targetCache before.logical.errorCache before.logical.cacheError before.logical.token
    (RopeInputConstruction.inputs n) (RopeInputConstruction.inputs_bound n (by omega)) supported
    (RopeInputConstruction.target n) RopeInputConstruction.error (RopeInputConstruction.input_error n (by omega))
    (RopeInputConstruction.target_base_nonnegative n)).1 column

end Inference.Models.Qwen.NativeCopiedSampledLogits
