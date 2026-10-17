import models.qwen.ResidualAttentionWorkspaceConstruction
import models.qwen.ResidualDeltaHighWater

namespace Inference.Models.Qwen.ResidualAttentionHighWater
open Contracts.Mlx Layers Kernels Kernels.Attention State
open ResidualDeltaHighWater (Before before_mono fresh cacheProtected_mono remaining_protected)
set_option maxRecDepth 10000
attribute [local irreducible] AttentionHeads.Projections.forward Blocks.Norm.forward AttentionHeads.Norm.forward
  RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor
  Copy2DMemory.programs CopyExecution.Trace.memory RopeRowsMemory.programs MultiOutputWrites.programs
  ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

theorem first_token_grows : KvAllocation.capacity 0<0+1 := by decide

abbrev Frontier := ResidualDeltaHighWater.Frontier

def fixedBytes (layer : ResidualAttention.Layer) (n : Nat) :=
  ResidualAttentionWorkspaceConstruction.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))
def next (frontier : Frontier) (layer : ResidualAttention.Layer) (n : Nat) : Frontier where
  cursor := frontier.cursor+fixedBytes layer n+KvGrowthAllocation.bytes n
  aligned := by
    have := frontier.aligned
    dsimp [fixedBytes,ResidualAttentionWorkspaceConstruction.bytes,AttentionTailWorkspaceConstruction.bytes,
      SdpaWorkspace.bytes,KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]
    omega

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n} {input : Fin 5120 → ArrayStorage.BF}
  (origin : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer (.attention layer) cache origin.bytes)
  (checkpoint : DecodeParameterMemory.AttentionStorage layer origin.bytes) (frontier : Frontier)
  (capacity : (next frontier layer n).cursor≤2^64)
  (sourceBound : Before frontier.cursor origin.base 10240)
  (parameterBound : checkpoint.Protected (Before frontier.cursor))
  (cacheBound : DecodePreservation.StageProtected (Before frontier.cursor) (.attention layer) cache storage.storage)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2)

abbrev selectedSource := DecodeParameterConstruction.attentionSource layer cache input origin storage checkpoint

def allocation : ResidualAttentionWorkspaceConstruction.Workspace (selectedSource origin storage checkpoint) where
  base := frontier.cursor
  aligned := frontier.aligned
  bounded := (Nat.le_add_right (frontier.cursor+fixedBytes layer n) (KvGrowthAllocation.bytes n)).trans capacity
  sourceSeparate := fresh sourceBound
  parametersSeparate := checkpoint.protected_mono (fun _ _ h => fresh h) parameterBound
  keysSeparate := fresh cacheBound.1
  valuesSeparate := fresh cacheBound.2
  queryDispatch := queryDispatch
  keyDispatch := keyDispatch

variable (angle : RopeAngles.Inputs)

-- Reframing the original cache changes bytes, never its physical layout.
theorem old_layout (s : ResidualAttentionConstruction.Input layer cache input angle) : s.oldAfter.layout=s.storage.layout := rfl

def growthWorkspace : KvGrowthAllocation.Workspace
    ((allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch).cachePlan angle).input.oldAfter where
  base := frontier.cursor+fixedBytes layer n
  aligned := by
    have := frontier.aligned
    dsimp [fixedBytes,ResidualAttentionWorkspaceConstruction.bytes,AttentionTailWorkspaceConstruction.bytes,SdpaWorkspace.bytes]
    omega
  bounded := capacity
  keys := by
    rw [old_layout]
    change MemoryRegions.Disjoint (frontier.cursor+fixedBytes layer n) _ storage.storage.layout.keyBase _
    exact Or.inr (cacheBound.1.trans (Nat.le_add_right _ _))
  values := by
    rw [old_layout]
    change MemoryRegions.Disjoint (frontier.cursor+fixedBytes layer n) _ storage.storage.layout.valueBase _
    exact Or.inr (cacheBound.2.trans (Nat.le_add_right _ _))

variable (growing : KvAllocation.capacity n<n+1)

def choice : ResidualAttentionWorkspaceConstruction.CacheChoice
    (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch) angle :=
  .growth (growthWorkspace origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle) growing
    (Or.inr (Nat.le_refl _))
    (Or.inr (sourceBound.trans (Nat.le_add_right _ _)))
    (checkpoint.protected_mono (fun _ _ h => Or.inr (h.trans (Nat.le_add_right _ _))) parameterBound)

def attentionPlan := (choice origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).fullPlan

def execution := (choice origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).execution

theorem source_linked : (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).source=origin :=
  (choice origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).source_eq

theorem cache_linked : (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).storage=storage.storage :=
  (choice origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).storage_eq

theorem safe_before (bound : Before frontier.cursor base size) : ResidualAttentionMemory.Safe
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing) base size :=
  (choice origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).execution_safe
    (fresh bound) (Or.inr (bound.trans (Nat.le_add_right _ _)))

theorem output_base :
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).outputBuffer.base=
    frontier.cursor+79872+SdpaWorkspace.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))+34816+720896 := by
  exact (choice origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).tailArena.output_base

theorem output_bound : Before (next frontier layer n).cursor
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).outputBuffer.base 10240 := by
  rw [output_base]
  dsimp [Before,next,fixedBytes,ResidualAttentionWorkspaceConstruction.bytes,AttentionTailWorkspaceConstruction.bytes]
  omega

theorem cache_layout (e : ResidualAttentionMemory.Execution layer cache input angle) :
    e.afterCache.layout=e.block.append.preparation.storage.layout := e.block.tail.cache_layout

theorem cache_bases :
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).afterCache.layout.keyBase=
      frontier.cursor+fixedBytes layer n+524288 ∧
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).afterCache.layout.valueBase=
      frontier.cursor+fixedBytes layer n+1048576+KvGrowthAllocation.tensorBytes n := by
  rw [cache_layout]
  exact (growthWorkspace origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle).layout growing

theorem cache_bound :
    Before (next frontier layer n).cursor (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).afterCache.layout.keyBase (KvRegions.bytes (n+1)) ∧
    Before (next frontier layer n).cursor (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).afterCache.layout.valueBase (KvRegions.bytes (n+1)) := by
  rw [(cache_bases origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).1,
    (cache_bases origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).2]
  rw [KvRegions.bytes,KvAllocation.next_capacity,ite_eq_left growing]
  dsimp [Before,next,KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]
  omega


def stageTrace := DecodeParameterConstruction.stage (.attention layer) cache input angle origin storage checkpoint
  (attentionPlan origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing)

theorem stage_safe_before (bound : Before frontier.cursor base size) :
    (stageTrace origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).Safe base size := safe_before origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing bound

theorem stage_output_bound : Before (next frontier layer n).cursor (stageTrace origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).buffer.base 10240 :=
  Eq.mpr (congrArg (fun base => Before (next frontier layer n).cursor base 10240)
    (ResidualDeltaHighWater.trace_buffer_base (stageTrace origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing)))
    (output_bound origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing)

theorem stage_cache_bound : DecodePreservation.StageProtected (Before (next frontier layer n).cursor) (.attention layer)
    (DecodeStage.cacheAfter (.attention layer) cache input angle) (stageTrace origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing).cacheAfter.storage :=
  cache_bound origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle growing

section BoundChain
variable {all rest : List DecodeStage.Stage} {layer : ResidualAttention.Layer} {tokens : Nat}
  (position : DecodeParameterConstruction.Cursor all (.attention layer::rest))
  (chainCache : DecodeChain.Caches (.attention layer::rest) tokens) (values : Fin 5120 → ArrayStorage.BF)
  (angle : RopeAngles.Inputs) (source : ArrayStorage.BFBuffer values)
  (caches : DecodeFrame.Storage (.attention layer::rest) chainCache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)
  (capacity : (next frontier layer tokens).cursor≤2^64) (sourceBound : Before frontier.cursor source.base 10240)
  (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
  (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (.attention layer::rest) chainCache source.bytes caches)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2)
  (growing : KvAllocation.capacity tokens<tokens+1)

def boundStep : DecodeParameterConstruction.StepPlan position chainCache values angle source caches parameters := by
  let selected := (DecodeParameterConstruction.remainingParameters position parameters).1
  have parameterBound : selected.Protected (Before frontier.cursor) := (remaining_protected position parameters parametersBound).1
  let plan := attentionPlan source caches.1 selected frontier capacity sourceBound parameterBound cachesBound.1 queryDispatch keyDispatch angle growing
  exact ⟨plan,
    cacheProtected_mono rest chainCache.2 caches.2
      (fun _ _ h => stage_safe_before source caches.1 selected frontier capacity sourceBound parameterBound cachesBound.1 queryDispatch keyDispatch angle growing h) cachesBound.2,
    DecodeParameterMemory.protected_mono all parameters
      (fun _ _ h => stage_safe_before source caches.1 selected frontier capacity sourceBound parameterBound cachesBound.1 queryDispatch keyDispatch angle growing h) parametersBound⟩

include parametersBound cachesBound in
theorem boundStep_safe_before (bound : Before frontier.cursor base size) :
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersBound cachesBound queryDispatch keyDispatch growing).step.first.Safe base size := stage_safe_before source caches.1 (DecodeParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
    (remaining_protected position parameters parametersBound).1 cachesBound.1 queryDispatch keyDispatch angle growing bound

include parametersBound cachesBound in
theorem boundStep_output : Before (next frontier layer tokens).cursor (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersBound cachesBound queryDispatch keyDispatch growing).step.first.buffer.base 10240 :=
  stage_output_bound source caches.1 (DecodeParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
    (remaining_protected position parameters parametersBound).1 cachesBound.1 queryDispatch keyDispatch angle growing

include parametersBound cachesBound in
theorem boundStep_updated : DecodePreservation.StageProtected (Before (next frontier layer tokens).cursor) (.attention layer)
    (DecodeStage.cacheAfter (.attention layer) chainCache.1 values angle) (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersBound cachesBound queryDispatch keyDispatch growing).step.first.cacheAfter.storage :=
  stage_cache_bound source caches.1 (DecodeParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
    (remaining_protected position parameters parametersBound).1 cachesBound.1 queryDispatch keyDispatch angle growing

include parametersBound cachesBound in
theorem boundStep_parameters : DecodeParameterMemory.Protected all (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersBound cachesBound queryDispatch keyDispatch growing).nextParameters
    (Before (next frontier layer tokens).cursor) :=
  (DecodeParameterMemory.reframe_protected all parameters _ _ _).mpr
    (DecodeParameterMemory.protected_mono all parameters
      (fun _ _ h => before_mono (by dsimp [next]; omega) h) parametersBound)

include parametersBound cachesBound in
theorem boundStep_retained : DecodePreservation.Protected (Before (next frontier layer tokens).cursor) rest chainCache.2 _
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersBound cachesBound queryDispatch keyDispatch growing).step.nextStorage :=
  DecodePreservation.preserves_geometry _ _ _ _ _ rest chainCache.2 caches.2
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersBound cachesBound queryDispatch keyDispatch growing).retained
    (cacheProtected_mono rest chainCache.2 caches.2 (fun _ _ h => before_mono (by dsimp [next]; omega) h) cachesBound.2)

end BoundChain
end Inference.Models.Qwen.ResidualAttentionHighWater
