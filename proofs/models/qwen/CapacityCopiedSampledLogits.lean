import models.qwen.CapacityCopiedCheckpointParameters
namespace Inference.Models.Qwen.CapacityCopiedSampledLogits
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache n}
  {token : Fin 248320} {angle : RopeAngles.Inputs}
  (execution : CapacityCopiedTokenSource.Execution p sampling cache token angle)

def buffer := ArrayFrame.bf (Qwen38CapacityAttentionExecution.logitsBuffer execution.forward)
  execution.final.sampler.memory
  (FinalProjectionSamplerSource.preserve_region execution.final execution.final.workspace.separate)

theorem current_heap : (buffer execution).bytes=execution.final.sampler.memory := rfl

theorem read_eq (column : Fin 248320) : (buffer execution).read column=(p.run cache token angle).1 column :=
  ((buffer execution).read_correct column).trans
    (((Qwen38CapacityAttentionExecution.logitsBuffer execution.forward).read_correct column).symm.trans
      (CapacityCopiedTokenSource.logits execution column))

section Checkpoint
variable {execution : CapacityCopiedTokenSource.Execution p sampling cache token (RopeInputConstruction.inputs n)}
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (selected : ReachedTokenContext.Primitive.Selections p.graph)
  (other : ReachedTokenContext.Primitive.Other p.graph)
  (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache) (supported : n+1≤262144)

include binding selected other cacheBound supported in
theorem finite_bound (column : Fin 248320) :
    Model.isFinite ((buffer execution).read column)=true ∧
    |Model.toReal ((buffer execution).read column)|≤(2:ℝ)^(23:Nat) := by
  rw [read_eq]
  exact CapacityCopiedCheckpointSource.model_bound encoded binding selected other cacheBound supported column

theorem logit_error (targetCache cacheError : p.graph.ReferenceCache n)
    (accuracy : DecodeChain.CacheErrors p.graph.stages cache targetCache cacheError) (column : Fin 248320) :
    |Model.toReal ((buffer execution).read column)-
      (p.targetRun targetCache token (RopeInputConstruction.target n)).1 column|≤
      (ReachedSequenceRanges.Sample.budget p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
        (ReachedTokenContext.Primitive.graphPrimitives selected other) cache cacheBound targetCache cacheError
        token (RopeInputConstruction.inputs n) (RopeInputConstruction.inputs_bound n (by omega)) supported
        (RopeInputConstruction.target n) RopeInputConstruction.error).1 column := by
  rw [read_eq]
  exact (ReachedSequenceRanges.Token.run_correct p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    (ReachedTokenContext.Primitive.graphPrimitives selected other) cache cacheBound targetCache cacheError accuracy token
    (RopeInputConstruction.inputs n) (RopeInputConstruction.inputs_bound n (by omega)) supported
    (RopeInputConstruction.target n) RopeInputConstruction.error (RopeInputConstruction.input_error n (by omega))
    (RopeInputConstruction.target_base_nonnegative n)).1 column
end Checkpoint
end Inference.Models.Qwen.CapacityCopiedSampledLogits
