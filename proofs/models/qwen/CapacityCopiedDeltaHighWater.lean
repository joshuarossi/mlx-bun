import models.qwen.ResidualDeltaHighWater
import models.qwen.CapacityAttentionParameterConstruction
namespace Inference.Models.Qwen.CapacityCopiedDeltaHighWater
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

variable {n : Nat} {all rest : List Stage} {layer : ResidualDelta.Layer}
  (position : CapacityAttentionParameterConstruction.Cursor all (.delta layer::rest))
  (cache : Caches (.delta layer::rest) n) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (.delta layer::rest) cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)
  (capacity : frontier.next.cursor≤2^64) (sourceBound : Before frontier.cursor source.base 10240)
  (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
  (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (.delta layer::rest) cache source.bytes storage)

theorem remaining_protected (position : CapacityAttentionParameterConstruction.Cursor all stages)
    (parameters : DecodeParameterMemory.Storage all memory) (bound : DecodeParameterMemory.Protected all parameters property) :
    DecodeParameterMemory.Protected stages (CapacityAttentionParameterConstruction.remainingParameters position parameters) property := by
  induction position with
  | root => exact bound
  | next previous ih => exact ih.2

private theorem buffer_eq {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Row BF}
    {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (n:=n) (.delta layer) cache source.bytes}
    {parameters : DecodeParameterMemory.DeltaStorage layer source.bytes}
    (plan : DecodeParameterConstruction.DeltaPlan layer cache input source storage parameters) :
    (CapacityAttentionParameterConstruction.stage (.delta layer) cache input angle source storage parameters plan).buffer=
      (DecodeParameterConstruction.stage (.delta layer) cache input angle source storage parameters plan).buffer := rfl

private theorem cache_eq {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Row BF}
    {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (n:=n) (.delta layer) cache source.bytes}
    {parameters : DecodeParameterMemory.DeltaStorage layer source.bytes}
    (plan : DecodeParameterConstruction.DeltaPlan layer cache input source storage parameters) :
    (CapacityAttentionParameterConstruction.stage (.delta layer) cache input angle source storage parameters plan).cacheAfter.storage=
      (DecodeParameterConstruction.stage (.delta layer) cache input angle source storage parameters plan).cacheAfter.storage := rfl

private def workspace := ResidualDeltaHighWater.allocation source storage.1
  (CapacityAttentionParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
  (remaining_protected position parameters parametersBound).1 cachesBound.1

def step : CapacityAttentionParameterConstruction.StepPlan position cache input angle source storage parameters where
  first := (workspace position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound).deltaPlan
  retained := ResidualDeltaHighWater.cacheProtected_mono rest cache.2 storage.2
    (fun _ _ before => (workspace position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound).stage_safe angle (ResidualDeltaHighWater.fresh before)) cachesBound.2
  parametersSafe := DecodeParameterMemory.protected_mono all parameters
    (fun _ _ before => (workspace position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound).stage_safe angle (ResidualDeltaHighWater.fresh before)) parametersBound

theorem output_bound : Before frontier.next.cursor (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).step.first.buffer.base 10240 :=
  (congrArg (fun buffer : ArrayStorage.BFBuffer (forward (.delta layer) cache.1 input angle) => Before frontier.next.cursor buffer.base 10240)
    (buffer_eq ((workspace position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound).deltaPlan))).mpr
      (ResidualDeltaHighWater.stage_output_bound source storage.1
        (CapacityAttentionParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
        (remaining_protected position parameters parametersBound).1 cachesBound.1 angle)

theorem updated_bound : DecodePreservation.StageProtected (Before frontier.next.cursor) (.delta layer)
    (cacheAfter (.delta layer) cache.1 input angle) (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).step.first.cacheAfter.storage :=
  (congrArg (fun stored => DecodePreservation.StageProtected (Before frontier.next.cursor) (.delta layer)
    (cacheAfter (.delta layer) cache.1 input angle) stored)
    (cache_eq ((workspace position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound).deltaPlan))).mpr
      (ResidualDeltaHighWater.stage_cache_bound source storage.1
        (CapacityAttentionParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
        (remaining_protected position parameters parametersBound).1 cachesBound.1 angle)

theorem parameters_bound : DecodeParameterMemory.Protected all (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).nextParameters (Before frontier.next.cursor) :=
  (DecodeParameterMemory.reframe_protected all parameters _ _ _).mpr
    (DecodeParameterMemory.protected_mono all parameters
      (fun _ _ before => ResidualDeltaHighWater.before_mono (by dsimp [Frontier.next]; omega) before) parametersBound)

theorem retained_bound : DecodePreservation.Protected (Before frontier.next.cursor) rest cache.2 _ (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).step.nextStorage :=
  DecodePreservation.preserves_geometry _ _ _ _ _ rest cache.2 storage.2
    (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).retained
    (ResidualDeltaHighWater.cacheProtected_mono rest cache.2 storage.2
      (fun _ _ before => ResidualDeltaHighWater.before_mono (by dsimp [Frontier.next]; omega) before) cachesBound.2)

theorem writes {base size : Nat} (bound : Before frontier.cursor base size) :
    (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).step.first.Safe base size :=
  (workspace position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound).stage_safe angle (ResidualDeltaHighWater.fresh bound)

end Inference.Models.Qwen.CapacityCopiedDeltaHighWater
