import models.qwen.CopiedAttentionCapacityArenaHighWater
import models.qwen.CapacityCopiedDeltaHighWater
import models.qwen.CapacityCopiedWorkspace
import models.qwen.CopiedAttentionOriginalTailChains
namespace Inference.Models.Qwen.CapacityCopiedAttentionHighWater
open Contracts.Mlx Layers DecodeStage DecodeChain State Kernels.Attention
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

private theorem buffer_eq {n : Nat} {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF n}
    {input : Row BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (.attention layer) cache source.bytes}
    {parameters : DecodeParameterMemory.AttentionStorage layer source.bytes}
    (factory : CopiedAttentionCapacityFactory.Plan layer cache input angle source storage.storage storage.shared parameters) :
    (CapacityAttentionParameterConstruction.stage (.attention layer) cache input angle source storage parameters factory).buffer=
      AttentionGateCopyCapacityResidualStage.forwardBuffer (CopiedAttentionCapacityFactory.stage factory) := rfl

private theorem cache_eq {n : Nat} {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF n}
    {input : Row BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (.attention layer) cache source.bytes}
    {parameters : DecodeParameterMemory.AttentionStorage layer source.bytes}
    (factory : CopiedAttentionCapacityFactory.Plan layer cache input angle source storage.storage storage.shared parameters) :
    (CapacityAttentionParameterConstruction.stage (.attention layer) cache input angle source storage parameters factory).cacheAfter.storage=
      AttentionGateCopyCapacityResidualStage.afterCache (CopiedAttentionCapacityFactory.stage factory) := rfl

private theorem safe_eq {n : Nat} {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF n}
    {input : Row BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (.attention layer) cache source.bytes}
    {parameters : DecodeParameterMemory.AttentionStorage layer source.bytes}
    (factory : CopiedAttentionCapacityFactory.Plan layer cache input angle source storage.storage storage.shared parameters) (base size : Nat) :
    (CapacityAttentionParameterConstruction.stage (.attention layer) cache input angle source storage parameters factory).Safe base size ↔
      AttentionGateCopyCapacityResidualStage.Safe (CopiedAttentionCapacityFactory.stage factory) base size := Iff.rfl

variable {n : Nat} {all rest : List Stage} {layer : ResidualAttention.Layer}
  (position : CapacityAttentionParameterConstruction.Cursor all (.attention layer::rest))
  (cache : Caches (.attention layer::rest) n) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (.attention layer::rest) cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)
  (capacity : (CapacityCopiedWorkspace.next n frontier (.attention layer)).cursor≤2^64)
  (sourceBound : Before frontier.cursor source.base 10240)
  (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
  (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (.attention layer::rest) cache source.bytes storage)
  (positive : 0<n)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2)
include position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch

private def request : CopiedAttentionCapacityArenaHighWater.Request source
    (CapacityAttentionParameterConstruction.remainingParameters position parameters).1 storage.1.storage storage.1.shared where
  frontier := frontier
  queryDispatch := queryDispatch
  keyDispatch := keyDispatch
  positive := positive
  sourceBefore := sourceBound
  parametersBefore := (CapacityCopiedDeltaHighWater.remaining_protected position parameters parametersBound).1
  keysBelow := cachesBound.1.1
  valuesBelow := cachesBound.1.2
  capacity := capacity

private abbrev factory := CopiedAttentionCapacityArenaHighWater.plan (request position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch) angle

def step : CapacityAttentionParameterConstruction.StepPlan position cache input angle source storage parameters where
  first := factory position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch
  retained := ResidualDeltaHighWater.cacheProtected_mono rest cache.2 storage.2
    (fun base size before => (safe_eq (factory position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch) base size).mpr
      (CopiedAttentionCapacityArenaHighWater.safe_below (request position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch) angle before)) cachesBound.2
  parametersSafe := DecodeParameterMemory.protected_mono all parameters
    (fun base size before => (safe_eq (factory position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch) base size).mpr
      (CopiedAttentionCapacityArenaHighWater.safe_below (request position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch) angle before)) parametersBound

theorem writes {base size : Nat} (bound : Before frontier.cursor base size) :
    (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch).step.first.Safe base size :=
  (safe_eq (factory position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch) base size).mpr
    (CopiedAttentionCapacityArenaHighWater.safe_below (request position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch) angle bound)

theorem output_bound : Before (CapacityCopiedWorkspace.next n frontier (.attention layer)).cursor (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch).step.first.buffer.base 10240 :=
  (congrArg (fun buffer : ArrayStorage.BFBuffer (forward (.attention layer) cache.1 input angle) =>
    Before (CapacityCopiedWorkspace.next n frontier (.attention layer)).cursor buffer.base 10240) (buffer_eq (factory position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch))).mpr
      (CopiedAttentionCapacityArenaHighWater.output_bound (request position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch) angle)

theorem updated_bound : DecodePreservation.StageProtected (Before (CapacityCopiedWorkspace.next n frontier (.attention layer)).cursor) (.attention layer)
    (cacheAfter (.attention layer) cache.1 input angle) (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch).step.first.cacheAfter.storage :=
  (congrArg (fun stored => DecodePreservation.StageProtected (Before (CapacityCopiedWorkspace.next n frontier (.attention layer)).cursor) (.attention layer)
    (cacheAfter (.attention layer) cache.1 input angle) stored) (cache_eq (factory position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch))).mpr
      (CopiedAttentionCapacityArenaHighWater.cache_bounds (request position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch) angle)

theorem parameters_bound : DecodeParameterMemory.Protected all (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch).nextParameters
    (Before (CapacityCopiedWorkspace.next n frontier (.attention layer)).cursor) :=
  (DecodeParameterMemory.reframe_protected all parameters _ _ _).mpr
    (DecodeParameterMemory.protected_mono all parameters
      (fun _ _ before => ResidualDeltaHighWater.before_mono (Nat.le_add_right _ _) before) parametersBound)

theorem retained_bound : DecodePreservation.Protected (Before (CapacityCopiedWorkspace.next n frontier (.attention layer)).cursor) rest cache.2 _ (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch).step.nextStorage :=
  DecodePreservation.preserves_geometry _ _ _ _ _ rest cache.2 storage.2 (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch).retained
    (ResidualDeltaHighWater.cacheProtected_mono rest cache.2 storage.2
      (fun _ _ before => ResidualDeltaHighWater.before_mono (Nat.le_add_right _ _) before) cachesBound.2)

theorem built : CopiedAttentionOriginalTailChains.Capacity.StageBuilt (.attention layer) cache.1 input angle source storage.1
    (CapacityAttentionParameterConstruction.remainingParameters position parameters).1 (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch).first :=
  CopiedAttentionCapacityArenaHighWater.built (request position cache input source storage parameters frontier capacity sourceBound parametersBound cachesBound positive queryDispatch keyDispatch) angle
end Inference.Models.Qwen.CapacityCopiedAttentionHighWater
