import models.qwen.CopiedAttentionInitialArenaHighWater
import models.qwen.CopiedAttentionEntryHighWater
import models.qwen.InitialCopiedWorkspace
import models.qwen.EmptyKvLineage
import models.qwen.CopiedAttentionOriginalTailChains
namespace Inference.Models.Qwen.InitialCopiedAttentionHighWater
open Contracts.Mlx Layers DecodeStage DecodeChain State Kernels.Attention
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

private theorem buffer_eq {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF 0}
    {input : Row BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (.attention layer) cache source.bytes}
    {parameters : DecodeParameterMemory.AttentionStorage layer source.bytes}
    (factory : CopiedAttentionInitialFactory.Plan layer cache input angle source parameters)
    (canonical : EmptyKvLineage.StageCanonical (.attention layer) cache storage) :
    (InitialCopiedParameterConstruction.stage (.attention layer) cache input angle source storage parameters
      (EmptyKvLineage.attention_plan factory canonical)).buffer=
        AttentionGateCopyInitialResidualStage.forwardBuffer (CopiedAttentionInitialFactory.stage factory) := rfl

private theorem cache_eq {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF 0}
    {input : Row BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (.attention layer) cache source.bytes}
    {parameters : DecodeParameterMemory.AttentionStorage layer source.bytes}
    (factory : CopiedAttentionInitialFactory.Plan layer cache input angle source parameters)
    (canonical : EmptyKvLineage.StageCanonical (.attention layer) cache storage) :
    (InitialCopiedParameterConstruction.stage (.attention layer) cache input angle source storage parameters
      (EmptyKvLineage.attention_plan factory canonical)).cacheAfter.storage=
        AttentionGateCopyInitialResidualStage.afterCache (CopiedAttentionInitialFactory.stage factory) := rfl

private theorem safe_eq {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF 0}
    {input : Row BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (.attention layer) cache source.bytes}
    {parameters : DecodeParameterMemory.AttentionStorage layer source.bytes}
    (factory : CopiedAttentionInitialFactory.Plan layer cache input angle source parameters)
    (canonical : EmptyKvLineage.StageCanonical (.attention layer) cache storage) (base size : Nat) :
    (InitialCopiedParameterConstruction.stage (.attention layer) cache input angle source storage parameters
      (EmptyKvLineage.attention_plan factory canonical)).Safe base size ↔
        AttentionGateCopyInitialResidualStage.Safe (CopiedAttentionInitialFactory.stage factory) base size := Iff.rfl

variable {all rest : List Stage} {layer : ResidualAttention.Layer}
  (position : DecodeParameterConstruction.Cursor all (.attention layer::rest))
  (cache : Caches (.attention layer::rest) 0) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (.attention layer::rest) cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)
  (capacity : (InitialCopiedWorkspace.next frontier (.attention layer)).cursor≤2^64)
  (sourceBound : Before frontier.cursor source.base 10240)
  (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
  (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (.attention layer::rest) cache source.bytes storage)
  (canonical : EmptyKvLineage.Canonical (.attention layer::rest) cache source.bytes storage)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2)

private def selected := (DecodeParameterConstruction.remainingParameters position parameters).1
include parametersBound in
private theorem selectedBound : (selected (position := position) (parameters := parameters)).Protected (Before frontier.cursor) :=
  (ResidualDeltaHighWater.remaining_protected position parameters parametersBound).1

include capacity in
private theorem entryRoom : frontier.cursor+CopiedAttentionEntryAllocation.bytes≤2^64 := by
  change frontier.cursor+(CopiedAttentionEntryAllocation.bytes+CopiedAttentionInitialReadAllocation.bytes+
    CopiedAttentionTailArena.bytes layer.mixer.architectureSuffix 1+ResidualMlpAllocation.bytes)≤2^64 at capacity
  omega

private def workspace := CopiedAttentionEntryHighWater.workspace source (selected (position := position) (parameters := parameters))
  frontier.cursor frontier.aligned (entryRoom (frontier := frontier) (capacity := capacity)) sourceBound (selectedBound (position := position) (parameters := parameters) (frontier := frontier) (parametersBound := parametersBound))

include capacity sourceBound parametersBound in
private theorem aligned : (CopiedAttentionEntryAllocation.projectionWorkspace
    (workspace (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound))).base%16=0 := by
  change (frontier.cursor+10240)%16=0
  have := frontier.aligned
  omega

include capacity sourceBound parametersBound in
private theorem room : (workspace (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)).base+
    CopiedAttentionInitialArenaHighWater.bytes layer.mixer.architectureSuffix≤2^64 := capacity

private def factory := CopiedAttentionInitialArenaHighWater.plan
  (workspace (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)) queryDispatch keyDispatch angle cache.1
  (aligned (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound))
  sourceBound (selectedBound (position := position) (parameters := parameters) (frontier := frontier) (parametersBound := parametersBound))
  (room (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound))

include cachesBound canonical in
def step : InitialCopiedParameterConstruction.StepPlan position cache input angle source storage parameters := by
  let f := factory (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)
  have writes : ∀ base size, Before frontier.cursor base size →
      (InitialCopiedParameterConstruction.stage (.attention layer) cache.1 input angle source storage.1
        (selected (position := position) (parameters := parameters)) (EmptyKvLineage.attention_plan f canonical.1)).Safe base size := by
    intro base size before
    apply (safe_eq f canonical.1 base size).mpr
    exact CopiedAttentionInitialArenaHighWater.safe _ _ _ _ _ _ _ _ _ before
  exact ⟨EmptyKvLineage.attention_plan f canonical.1,
    ResidualDeltaHighWater.cacheProtected_mono rest cache.2 storage.2 writes cachesBound.2,
    DecodeParameterMemory.protected_mono all parameters writes parametersBound⟩

include cachesBound canonical in
theorem writes {base size : Nat} (bound : Before frontier.cursor base size) :
    (step (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (canonical := canonical) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)).step.first.Safe base size := by
  apply (safe_eq (factory (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)) canonical.1 base size).mpr
  exact CopiedAttentionInitialArenaHighWater.safe (workspace (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)) queryDispatch keyDispatch angle cache.1 (aligned (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)) sourceBound (selectedBound (position := position) (parameters := parameters) (frontier := frontier) (parametersBound := parametersBound)) (room (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)) bound

include cachesBound canonical in
theorem output_bound : Before (InitialCopiedWorkspace.next frontier (.attention layer)).cursor (step (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (canonical := canonical) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)).step.first.buffer.base 10240 := by
  exact (congrArg (fun buffer : ArrayStorage.BFBuffer (forward (.attention layer) cache.1 input angle) =>
    Before (InitialCopiedWorkspace.next frontier (.attention layer)).cursor buffer.base 10240) (buffer_eq (factory (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)) canonical.1)).mpr
      (CopiedAttentionInitialArenaHighWater.output_bound (workspace (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)) queryDispatch keyDispatch angle cache.1 (aligned (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)) sourceBound (selectedBound (position := position) (parameters := parameters) (frontier := frontier) (parametersBound := parametersBound)) (room (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)))

include cachesBound canonical in
theorem updated_bound : DecodePreservation.StageProtected (Before (InitialCopiedWorkspace.next frontier (.attention layer)).cursor) (.attention layer)
    (cacheAfter (.attention layer) cache.1 input angle) (step (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (canonical := canonical) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)).step.first.cacheAfter.storage := by
  exact (congrArg (fun stored => DecodePreservation.StageProtected (Before (InitialCopiedWorkspace.next frontier (.attention layer)).cursor) (.attention layer)
    (cacheAfter (.attention layer) cache.1 input angle) stored) (cache_eq (factory (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)) canonical.1)).mpr
      (CopiedAttentionInitialArenaHighWater.cache_bounds (workspace (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)) queryDispatch keyDispatch angle cache.1 (aligned (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)) sourceBound (selectedBound (position := position) (parameters := parameters) (frontier := frontier) (parametersBound := parametersBound)) (room (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)))

include cachesBound canonical in
theorem parameters_bound : DecodeParameterMemory.Protected all (step (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (canonical := canonical) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)).nextParameters (Before (InitialCopiedWorkspace.next frontier (.attention layer)).cursor) :=
  (DecodeParameterMemory.reframe_protected all parameters _ _ _).mpr
    (DecodeParameterMemory.protected_mono all parameters
      (fun _ _ h => ResidualDeltaHighWater.before_mono (by rw [InitialCopiedWorkspace.next_cursor]; omega) h) parametersBound)

include cachesBound canonical in
theorem retained_bound : DecodePreservation.Protected (Before (InitialCopiedWorkspace.next frontier (.attention layer)).cursor) rest cache.2 _ (step (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (canonical := canonical) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)).step.nextStorage :=
  DecodePreservation.preserves_geometry _ _ _ _ _ rest cache.2 storage.2
    (step (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (canonical := canonical) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)).retained
    (ResidualDeltaHighWater.cacheProtected_mono rest cache.2 storage.2
      (fun _ _ h => ResidualDeltaHighWater.before_mono (by rw [InitialCopiedWorkspace.next_cursor]; omega) h) cachesBound.2)

include cachesBound canonical in
theorem retained_canonical : EmptyKvLineage.Canonical rest cache.2 (step (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (canonical := canonical) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)).step.first.buffer.bytes (step (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (canonical := canonical) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)).step.nextStorage :=
  EmptyKvLineage.retained _ rest cache.2 storage.2 (step (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (canonical := canonical) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)).retained canonical.2

include cachesBound canonical in
theorem built : CopiedAttentionOriginalTailChains.Initial.StageBuilt (.attention layer) cache.1 input angle source storage.1
    (DecodeParameterConstruction.remainingParameters position parameters).1 (step (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (canonical := canonical) (queryDispatch := queryDispatch) (keyDispatch := keyDispatch)).first :=
  CopiedAttentionInitialArenaHighWater.built (workspace (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)) queryDispatch keyDispatch angle cache.1 (aligned (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound)) sourceBound (selectedBound (position := position) (parameters := parameters) (frontier := frontier) (parametersBound := parametersBound)) (room (position := position) (source := source) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound))
end Inference.Models.Qwen.InitialCopiedAttentionHighWater
