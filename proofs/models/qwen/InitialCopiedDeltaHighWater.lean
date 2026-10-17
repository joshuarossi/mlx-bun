import models.qwen.ResidualDeltaHighWater
import models.qwen.InitialCopiedParameterConstruction
import models.qwen.EmptyKvLineage
namespace Inference.Models.Qwen.InitialCopiedDeltaHighWater
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
variable {all rest : List Stage} {layer : ResidualDelta.Layer}
  (position : DecodeParameterConstruction.Cursor all (.delta layer::rest))
  (cache : Caches (.delta layer::rest) 0) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (.delta layer::rest) cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)
  (capacity : frontier.next.cursor≤2^64) (sourceBound : Before frontier.cursor source.base 10240)
  (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
  (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (.delta layer::rest) cache source.bytes storage)

private theorem buffer_eq {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Row BF}
    {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (n:=0) (.delta layer) cache source.bytes}
    {parameters : DecodeParameterMemory.DeltaStorage layer source.bytes}
    (plan : DecodeParameterConstruction.DeltaPlan layer cache input source storage parameters) :
    (InitialCopiedParameterConstruction.stage (.delta layer) cache input angle source storage parameters plan).buffer=
      (DecodeParameterConstruction.stage (.delta layer) cache input angle source storage parameters plan).buffer := rfl

private theorem cache_eq {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Row BF}
    {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (n:=0) (.delta layer) cache source.bytes}
    {parameters : DecodeParameterMemory.DeltaStorage layer source.bytes}
    (plan : DecodeParameterConstruction.DeltaPlan layer cache input source storage parameters) :
    (InitialCopiedParameterConstruction.stage (.delta layer) cache input angle source storage parameters plan).cacheAfter.storage=
      (DecodeParameterConstruction.stage (.delta layer) cache input angle source storage parameters plan).cacheAfter.storage := rfl

private def original := ResidualDeltaHighWater.boundStep position cache input angle source storage parameters
  frontier capacity sourceBound parametersBound cachesBound

def step : InitialCopiedParameterConstruction.StepPlan position cache input angle source storage parameters where
  first := (original position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).first
  retained := (original position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).retained
  parametersSafe := (original position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).parametersSafe

theorem output_bound : Before frontier.next.cursor (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).step.first.buffer.base 10240 :=
  (congrArg (fun buffer : ArrayStorage.BFBuffer (forward (.delta layer) cache.1 input angle) => Before frontier.next.cursor buffer.base 10240)
    (buffer_eq ((original position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).first))).mpr
      (ResidualDeltaHighWater.boundStep_output position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound)

theorem updated_bound : DecodePreservation.StageProtected (Before frontier.next.cursor) (.delta layer)
    (cacheAfter (.delta layer) cache.1 input angle) (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).step.first.cacheAfter.storage :=
  (congrArg (fun stored => DecodePreservation.StageProtected (Before frontier.next.cursor) (.delta layer)
    (cacheAfter (.delta layer) cache.1 input angle) stored) (cache_eq ((original position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).first))).mpr
      (ResidualDeltaHighWater.boundStep_updated position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound)

theorem parameters_bound : DecodeParameterMemory.Protected all (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).nextParameters (Before frontier.next.cursor) :=
  (DecodeParameterMemory.reframe_protected all parameters _ _ _).mpr
    (DecodeParameterMemory.protected_mono all parameters
      (fun _ _ h => ResidualDeltaHighWater.before_mono (by dsimp [Frontier.next]; omega) h) parametersBound)

theorem retained_bound : DecodePreservation.Protected (Before frontier.next.cursor) rest cache.2 _ (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).step.nextStorage :=
  DecodePreservation.preserves_geometry _ _ _ _ _ rest cache.2 storage.2
    (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).retained
    (ResidualDeltaHighWater.cacheProtected_mono rest cache.2 storage.2
      (fun _ _ h => ResidualDeltaHighWater.before_mono (by dsimp [Frontier.next]; omega) h) cachesBound.2)

theorem writes {base size : Nat} (bound : Before frontier.cursor base size) :
    (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).step.first.Safe base size :=
  ResidualDeltaHighWater.stage_safe_before source storage.1
    (DecodeParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
    (ResidualDeltaHighWater.remaining_protected position parameters parametersBound).1 cachesBound.1 angle bound

theorem retained_canonical (canonical : EmptyKvLineage.Canonical rest cache.2 source.bytes storage.2) :
    EmptyKvLineage.Canonical rest cache.2 (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).step.first.buffer.bytes (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).step.nextStorage :=
  EmptyKvLineage.retained _ rest cache.2 storage.2 (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound).retained canonical
end Inference.Models.Qwen.InitialCopiedDeltaHighWater
