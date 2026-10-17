import models.qwen.ResidualAttentionHighWater
import models.qwen.DecodeCacheGeometry

namespace Inference.Models.Qwen.ResidualAttentionExistingHighWater
open Contracts.Mlx Layers Kernels Kernels.Attention State
open ResidualDeltaHighWater (Before Frontier before_mono fresh cacheProtected_mono remaining_protected)
set_option maxRecDepth 10000
attribute [local irreducible] AttentionHeads.Projections.forward Blocks.Norm.forward AttentionHeads.Norm.forward
  RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor
  Copy2DMemory.programs CopyExecution.Trace.memory RopeRowsMemory.programs MultiOutputWrites.programs
  ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

-- Existing-capacity steps reuse the actual old KV regions. Their writes need
-- separation from live values; an endpoint bound alone cannot establish that.
def CacheSafe {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n} {memory : ByteMemory.Bytes}
    (stored : DecodeFrame.StageBuffer (.attention layer) cache memory) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint stored.storage.layout.keyBase (KvRegions.bytes n) base size ∧
  MemoryRegions.Disjoint stored.storage.layout.valueBase (KvRegions.bytes n) base size

theorem cache_safe_below {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n} {memory : ByteMemory.Bytes}
    (stored : DecodeFrame.StageBuffer (.attention layer) cache memory) (cut base size : Nat)
    (lower : DecodePreservation.StageProtected (fun address _ => cut≤address) (.attention layer) cache stored.storage)
    (bound : Before cut base size) : CacheSafe stored base size :=
  ⟨Or.inr (bound.trans lower.1),Or.inr (bound.trans lower.2)⟩

theorem cache_safe_above {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n} {memory : ByteMemory.Bytes}
    (stored : DecodeFrame.StageBuffer (.attention layer) cache memory) (cut base size : Nat)
    (upper : DecodePreservation.StageProtected (Before cut) (.attention layer) cache stored.storage)
    (bound : cut≤base) : CacheSafe stored base size :=
  ⟨Or.inl (upper.1.trans bound),Or.inl (upper.2.trans bound)⟩

theorem second_token_reuses : ¬KvAllocation.capacity 1<1+1 := by decide

def next (frontier : Frontier) (layer : ResidualAttention.Layer) (n : Nat) : Frontier where
  cursor := frontier.cursor+ResidualAttentionHighWater.fixedBytes layer n
  aligned := by
    have := frontier.aligned
    dsimp [ResidualAttentionHighWater.fixedBytes,ResidualAttentionWorkspaceConstruction.bytes,
      AttentionTailWorkspaceConstruction.bytes,SdpaWorkspace.bytes]
    omega

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {input : Fin 5120 → ArrayStorage.BF}
  (origin : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer (.attention layer) cache origin.bytes)
  (checkpoint : DecodeParameterMemory.AttentionStorage layer origin.bytes) (frontier : Frontier)
  (capacity : (next frontier layer n).cursor≤2^64)
  (sourceBound : Before frontier.cursor origin.base 10240)
  (parameterBound : checkpoint.Protected (Before frontier.cursor))
  (cacheBound : DecodePreservation.StageProtected (Before frontier.cursor) (.attention layer) cache storage.storage)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2)

def allocation : ResidualAttentionWorkspaceConstruction.Workspace
    (DecodeParameterConstruction.attentionSource layer cache input origin storage checkpoint) where
  base := frontier.cursor
  aligned := frontier.aligned
  bounded := capacity
  sourceSeparate := fresh sourceBound
  parametersSeparate := checkpoint.protected_mono (fun _ _ h => fresh h) parameterBound
  keysSeparate := fresh cacheBound.1
  valuesSeparate := fresh cacheBound.2
  queryDispatch := queryDispatch
  keyDispatch := keyDispatch

variable (angle : RopeAngles.Inputs) (room : ¬KvAllocation.capacity n<n+1)
  (sourceSafe : CacheSafe storage origin.base 10240)
  (parametersSafe : checkpoint.Protected (CacheSafe storage))

def choice : ResidualAttentionWorkspaceConstruction.CacheChoice
    (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch) angle :=
  .existing room sourceSafe.1 sourceSafe.2 parametersSafe

def attentionPlan :=
  (choice origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).fullPlan

def execution :=
  (choice origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).execution

theorem source_linked :
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).source=origin :=
  (choice origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).source_eq

theorem cache_linked :
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).storage=storage.storage :=
  (choice origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).storage_eq

theorem safe_before {base size : Nat} (bound : Before frontier.cursor base size) (separate : CacheSafe storage base size) :
    ResidualAttentionMemory.Safe
      (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe) base size :=
  (choice origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).execution_safe (fresh bound) separate

theorem output_base :
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).outputBuffer.base=
      frontier.cursor+79872+SdpaWorkspace.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))+34816+720896 :=
  (choice origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).tailArena.output_base

theorem output_bound : Before (next frontier layer n).cursor
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).outputBuffer.base 10240 := by
  rw [output_base]
  dsimp [Before,next,ResidualAttentionHighWater.fixedBytes,ResidualAttentionWorkspaceConstruction.bytes,
    AttentionTailWorkspaceConstruction.bytes]
  omega

theorem cache_bases :
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).afterCache.layout.keyBase=storage.storage.layout.keyBase ∧
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).afterCache.layout.valueBase=storage.storage.layout.valueBase := by
  rw [ResidualAttentionHighWater.cache_layout]
  exact ⟨rfl,rfl⟩

theorem cache_bound :
    Before (next frontier layer n).cursor
      (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).afterCache.layout.keyBase (KvRegions.bytes (n+1)) ∧
    Before (next frontier layer n).cursor
      (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).afterCache.layout.valueBase (KvRegions.bytes (n+1)) := by
  rw [(cache_bases origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).1,
    (cache_bases origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).2]
  have sizes : KvRegions.bytes (n+1)=KvRegions.bytes n := by
    simp only [KvRegions.bytes,← AttentionReadAllocation.same_capacity room]
  rw [sizes]
  exact ⟨before_mono (Nat.le_add_right _ _) cacheBound.1,before_mono (Nat.le_add_right _ _) cacheBound.2⟩

-- The unchanged layout also preserves all cache-region predicates, including
-- pairwise cache separation and separation from the original checkpoint.
theorem cache_geometry (property : Nat → Nat → Prop)
    (safe : DecodePreservation.StageProtected property (.attention layer) cache storage.storage) :
    property (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).afterCache.layout.keyBase (KvRegions.bytes (n+1)) ∧
    property (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).afterCache.layout.valueBase (KvRegions.bytes (n+1)) := by
  rw [(cache_bases origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).1,
    (cache_bases origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound queryDispatch keyDispatch angle room sourceSafe parametersSafe).2]
  change property storage.storage.layout.keyBase (KvRegions.bytes n) ∧
    property storage.storage.layout.valueBase (KvRegions.bytes n) at safe
  simpa only [KvRegions.bytes,← AttentionReadAllocation.same_capacity room] using safe

theorem footprint : (next frontier layer n).cursor≤frontier.cursor+13637632 :=
  Nat.add_le_add_left (ResidualAttentionWorkspaceConstruction.footprint layer.mixer.architectureSuffix (n+1)) frontier.cursor

section BoundChain
variable {all rest : List DecodeStage.Stage} {layer : ResidualAttention.Layer} {tokens : Nat}
  (position : DecodeParameterConstruction.Cursor all (.attention layer::rest))
  (chainCache : DecodeChain.Caches (.attention layer::rest) tokens) (values : Fin 5120 → ArrayStorage.BF)
  (angle : RopeAngles.Inputs) (source : ArrayStorage.BFBuffer values)
  (caches : DecodeFrame.Storage (.attention layer::rest) chainCache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)
  (capacity : (next frontier layer tokens).cursor≤2^64) (sourceBound : Before frontier.cursor source.base 10240)
  (parametersLive : DecodeParameterMemory.Protected all parameters
    (fun base size => Before frontier.cursor base size ∧ CacheSafe caches.1 base size))
  (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (.attention layer::rest) chainCache source.bytes caches)
  (pairwise : DecodeCacheGeometry.Pairwise (.attention layer::rest) chainCache source.bytes caches)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2)
  (room : ¬KvAllocation.capacity tokens<tokens+1)
  (sourceSafe : CacheSafe caches.1 source.base 10240)

include pairwise in
theorem retained_separate :
    DecodePreservation.Protected (CacheSafe caches.1) rest chainCache.2 source.bytes caches.2 := by
  have key := DecodeCacheGeometry.head_separate_tail (.attention layer) rest chainCache source.bytes caches pairwise
    (caches.1.storage.layout.keyBase,KvRegions.bytes tokens) (by simp [DecodeCacheGeometry.stageRegions])
  have value := DecodeCacheGeometry.head_separate_tail (.attention layer) rest chainCache source.bytes caches pairwise
    (caches.1.storage.layout.valueBase,KvRegions.bytes tokens) (by simp [DecodeCacheGeometry.stageRegions])
  apply (DecodeCacheGeometry.protected_iff _ _ _ _ _).mpr
  intro region member
  exact ⟨(DecodeCacheGeometry.protected_iff _ _ _ _ _).mp key region member,
    (DecodeCacheGeometry.protected_iff _ _ _ _ _).mp value region member⟩

def selectedChoice : ResidualAttentionWorkspaceConstruction.CacheChoice
    (allocation source caches.1 (DecodeParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
      ((DecodeParameterConstruction.remainingParameters position parameters).1.protected_mono
        (first := fun base size => Before frontier.cursor base size ∧ CacheSafe caches.1 base size) (fun _ _ live => live.1)
        (remaining_protected position parameters parametersLive).1)
      cachesBound.1 queryDispatch keyDispatch) angle :=
  choice source caches.1 (DecodeParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
    ((DecodeParameterConstruction.remainingParameters position parameters).1.protected_mono
      (first := fun base size => Before frontier.cursor base size ∧ CacheSafe caches.1 base size) (fun _ _ live => live.1)
      (remaining_protected position parameters parametersLive).1)
    cachesBound.1 queryDispatch keyDispatch angle room sourceSafe
    ((DecodeParameterConstruction.remainingParameters position parameters).1.protected_mono
      (first := fun base size => Before frontier.cursor base size ∧ CacheSafe caches.1 base size) (fun _ _ live => live.2)
      (remaining_protected position parameters parametersLive).1)

def boundStep : DecodeParameterConstruction.StepPlan position chainCache values angle source caches parameters := by
  let selected := selectedChoice position chainCache values angle source caches parameters frontier capacity sourceBound
    parametersLive cachesBound queryDispatch keyDispatch room sourceSafe
  refine ⟨selected.fullPlan,?_,?_⟩
  · apply (DecodeCacheGeometry.protected_iff _ _ _ _ _).mpr
    intro region member
    exact selected.execution_safe
      (fresh ((DecodeCacheGeometry.protected_iff _ _ _ _ _).mp cachesBound.2 region member))
      ((DecodeCacheGeometry.protected_iff _ _ _ _ _).mp (retained_separate chainCache values source caches pairwise) region member)
  · exact DecodeParameterMemory.protected_mono all parameters
      (fun _ _ live => selected.execution_safe (fresh live.1) live.2) parametersLive

include parametersLive cachesBound pairwise in
theorem boundStep_safe_before {base size : Nat} (bound : Before frontier.cursor base size)
    (separate : CacheSafe caches.1 base size) :
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersLive cachesBound pairwise
      queryDispatch keyDispatch room sourceSafe).step.first.Safe base size :=
  (selectedChoice position chainCache values angle source caches parameters frontier capacity sourceBound parametersLive cachesBound
    queryDispatch keyDispatch room sourceSafe).execution_safe (fresh bound) separate

include parametersLive cachesBound pairwise in
theorem boundStep_output : Before (next frontier layer tokens).cursor
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersLive cachesBound pairwise
      queryDispatch keyDispatch room sourceSafe).step.first.buffer.base 10240 := by
  rw [ResidualDeltaHighWater.trace_buffer_base]
  exact output_bound source caches.1 (DecodeParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
    ((DecodeParameterConstruction.remainingParameters position parameters).1.protected_mono
      (first := fun base size => Before frontier.cursor base size ∧ CacheSafe caches.1 base size) (fun _ _ live => live.1)
      (remaining_protected position parameters parametersLive).1)
    cachesBound.1 queryDispatch keyDispatch angle room sourceSafe
    ((DecodeParameterConstruction.remainingParameters position parameters).1.protected_mono
      (first := fun base size => Before frontier.cursor base size ∧ CacheSafe caches.1 base size) (fun _ _ live => live.2)
      (remaining_protected position parameters parametersLive).1)

include parametersLive cachesBound pairwise in
theorem boundStep_geometry (property : Nat → Nat → Prop)
    (headSafe : DecodePreservation.StageProtected property (.attention layer) chainCache.1 caches.1.storage) :
    DecodePreservation.StageProtected property (.attention layer)
      (DecodeStage.cacheAfter (.attention layer) chainCache.1 values angle)
      (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersLive cachesBound pairwise
        queryDispatch keyDispatch room sourceSafe).step.first.cacheAfter.storage :=
  cache_geometry source caches.1 (DecodeParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
    ((DecodeParameterConstruction.remainingParameters position parameters).1.protected_mono
      (first := fun base size => Before frontier.cursor base size ∧ CacheSafe caches.1 base size) (fun _ _ live => live.1)
      (remaining_protected position parameters parametersLive).1)
    cachesBound.1 queryDispatch keyDispatch angle room sourceSafe
    ((DecodeParameterConstruction.remainingParameters position parameters).1.protected_mono
      (first := fun base size => Before frontier.cursor base size ∧ CacheSafe caches.1 base size) (fun _ _ live => live.2)
      (remaining_protected position parameters parametersLive).1) property headSafe

include parametersLive cachesBound pairwise in
theorem boundStep_updated : DecodePreservation.StageProtected (Before (next frontier layer tokens).cursor) (.attention layer)
    (DecodeStage.cacheAfter (.attention layer) chainCache.1 values angle)
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersLive cachesBound pairwise
      queryDispatch keyDispatch room sourceSafe).step.first.cacheAfter.storage :=
  boundStep_geometry position chainCache values angle source caches parameters frontier capacity sourceBound parametersLive cachesBound pairwise
    queryDispatch keyDispatch room sourceSafe _
    ⟨before_mono (Nat.le_add_right _ _) cachesBound.1.1,before_mono (Nat.le_add_right _ _) cachesBound.1.2⟩

include parametersLive cachesBound pairwise in
theorem boundStep_parameters : DecodeParameterMemory.Protected all
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersLive cachesBound pairwise
      queryDispatch keyDispatch room sourceSafe).nextParameters (Before (next frontier layer tokens).cursor) :=
  (DecodeParameterMemory.reframe_protected all parameters _ _ _).mpr
    (DecodeParameterMemory.protected_mono all parameters (fun _ _ live => before_mono (Nat.le_add_right _ _) live.1) parametersLive)

include parametersLive cachesBound pairwise in
theorem boundStep_retained : DecodePreservation.Protected (Before (next frontier layer tokens).cursor) rest chainCache.2 _
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersLive cachesBound pairwise
      queryDispatch keyDispatch room sourceSafe).step.nextStorage :=
  DecodePreservation.preserves_geometry _ _ _ _ _ rest chainCache.2 caches.2
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersLive cachesBound pairwise
      queryDispatch keyDispatch room sourceSafe).retained
    (cacheProtected_mono rest chainCache.2 caches.2 (fun _ _ bound => before_mono (Nat.le_add_right _ _) bound) cachesBound.2)

end BoundChain

end Inference.Models.Qwen.ResidualAttentionExistingHighWater
