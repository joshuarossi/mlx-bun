import models.qwen.ResidualAttentionStorageConstruction
import state.KvGrowthAllocation

namespace Inference.Models.Qwen.AttentionReadAllocation
open Contracts.Mlx Kernels Kernels.Attention State Layers ResidualAttentionConstruction
set_option maxRecDepth 10000
attribute [local irreducible] Copy2DMemory.programs CopyExecution.Trace.memory
  KvConcatMemory.programs CopyContiguous.programs

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {original : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : Input layer cache original angle}

-- One region predicate covers all live rows entering cache preparation.
structure Live (s : Input layer cache original angle) (property : Nat → Nat → Prop) : Prop where
  key : property s.front.keySource.base (KvAppendMemory.sourceBytes s.front.keySource)
  value : property s.front.valueSource.base (KvAppendMemory.sourceBytes s.front.valueSource)
  queries : ∀ head, property (s.front.query head).base 512
  gates : ∀ head, property (s.front.gate head).base 512
  residual : property s.savedResidual.base 10240

variable {w : KvGrowthAllocation.Workspace s.oldAfter}

def growthPreparation (w : KvGrowthAllocation.Workspace s.oldAfter)
    (growing : KvAllocation.capacity n<n+1) : AttentionBlockMemory.Preparation s.oldAfter :=
  .growth (w.allocation growing)

theorem growth_preparation_safe (w : KvGrowthAllocation.Workspace s.oldAfter)
    (growing : KvAllocation.capacity n<n+1) {other size : Nat}
    (safe : MemoryRegions.Disjoint w.base (KvGrowthAllocation.bytes n) other size) :
    (growthPreparation w growing).Safe other size := by
  change MemoryRegions.Disjoint (2*(w.base/2)) 524288 other size ∧
    MemoryRegions.Disjoint (2*((w.base+524288)/2)) (2*(4*(n+256)*256)) other size ∧
    MemoryRegions.Disjoint (2*((w.base+524288+KvGrowthAllocation.tensorBytes n)/2)) 524288 other size ∧
    MemoryRegions.Disjoint (2*((w.base+1048576+KvGrowthAllocation.tensorBytes n)/2)) (2*(4*(n+256)*256)) other size
  rw [w.half_bases.1,w.half_bases.2.1,w.half_bases.2.2.1,w.half_bases.2.2.2]
  refine ⟨?_,?_,?_,?_⟩
  · simpa using w.separate (offset := 0) (count := 524288) (by dsimp [KvGrowthAllocation.bytes]; omega) safe
  · exact w.separate (by dsimp [KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]; omega) safe
  · simpa only [Nat.add_assoc] using w.separate (offset := 524288+KvGrowthAllocation.tensorBytes n) (count := 524288)
      (by dsimp [KvGrowthAllocation.bytes]; omega) safe
  · simpa only [Nat.add_assoc] using w.separate (offset := 1048576+KvGrowthAllocation.tensorBytes n) (count := 2*(4*(n+256)*256))
      (by dsimp [KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]; omega) safe

theorem growth_cache_safe (w : KvGrowthAllocation.Workspace s.oldAfter)
    (growing : KvAllocation.capacity n<n+1) {other size : Nat}
    (safe : MemoryRegions.Disjoint w.base (KvGrowthAllocation.bytes n) other size) :
    MemoryRegions.Disjoint (growthPreparation w growing).storage.layout.keyBase (KvRegions.bytes (n+1)) other size ∧
    MemoryRegions.Disjoint (growthPreparation w growing).storage.layout.valueBase (KvRegions.bytes (n+1)) other size := by
  change MemoryRegions.Disjoint (w.execution growing).prepared.layout.keyBase (KvRegions.bytes (n+1)) other size ∧
    MemoryRegions.Disjoint (w.execution growing).prepared.layout.valueBase (KvRegions.bytes (n+1)) other size
  rw [(w.layout growing).1,(w.layout growing).2,KvRegions.bytes,(w.execution growing).capacity_next]
  constructor
  · exact w.separate (by dsimp [KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]; omega) safe
  · simpa only [Nat.add_assoc] using w.separate (offset := 1048576+KvGrowthAllocation.tensorBytes n) (count := 2*(4*(n+256)*256))
      (by dsimp [KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]; omega) safe

def growthAppend (w : KvGrowthAllocation.Workspace s.oldAfter)
    (growing : KvAllocation.capacity n<n+1)
    (live : Live s (MemoryRegions.Disjoint w.base (KvGrowthAllocation.bytes n))) : AppendPlan s where
  preparation := growthPreparation w growing
  keyPrepared := growth_preparation_safe w growing live.key
  valuePrepared := growth_preparation_safe w growing live.value
  keySeparate := (growth_cache_safe w growing live.key).1
  valueSeparate := (growth_cache_safe w growing live.value).2
  valueKeySeparate := (growth_cache_safe w growing live.value).1

theorem growth_append_safe (w : KvGrowthAllocation.Workspace s.oldAfter)
    (growing : KvAllocation.capacity n<n+1)
    (live : Live s (MemoryRegions.Disjoint w.base (KvGrowthAllocation.bytes n))) {other size : Nat}
    (safe : MemoryRegions.Disjoint w.base (KvGrowthAllocation.bytes n) other size) :
    (growthAppend w growing live).append.Safe other size :=
  ⟨growth_preparation_safe w growing safe,growth_cache_safe w growing safe⟩

def growthRead (w : KvGrowthAllocation.Workspace s.oldAfter)
    (growing : KvAllocation.capacity n<n+1)
    (live : Live s (MemoryRegions.Disjoint w.base (KvGrowthAllocation.bytes n))) : ReadPlan s where
  allocation := growthAppend w growing live
  queriesSafe := fun head => growth_append_safe w growing live (live.queries head)
  gatesSafe := fun head => growth_append_safe w growing live (live.gates head)
  residualSafe := growth_append_safe w growing live live.residual

theorem growth_frame (w : KvGrowthAllocation.Workspace s.oldAfter)
    (growing : KvAllocation.capacity n<n+1)
    (live : Live s (MemoryRegions.Disjoint w.base (KvGrowthAllocation.bytes n))) {other size : Nat}
    (prefixSafe : s.front.Safe other size)
    (safe : MemoryRegions.Disjoint w.base (KvGrowthAllocation.bytes n) other size) (offset : Nat) (bound : offset<size) :
    (growthRead w growing live).input.cache.memory (other+offset)=s.front.entry.source.lhs.bytes (other+offset) :=
  (growthRead w growing live).other_region ⟨prefixSafe,growth_append_safe w growing live safe⟩ offset bound

def ExistingSafe (s : Input layer cache original angle) (other size : Nat) : Prop :=
  MemoryRegions.Disjoint s.oldAfter.layout.keyBase (KvRegions.bytes n) other size ∧
  MemoryRegions.Disjoint s.oldAfter.layout.valueBase (KvRegions.bytes n) other size

theorem same_capacity (room : ¬KvAllocation.capacity n<n+1) : KvAllocation.capacity n=KvAllocation.capacity (n+1) := by
  rw [KvAllocation.next_capacity,ite_eq_right room]

def existingAppend (room : ¬KvAllocation.capacity n<n+1) (live : Live s (ExistingSafe s)) : AppendPlan s where
  preparation := .existing (same_capacity room)
  keyPrepared := trivial
  valuePrepared := trivial
  keySeparate := by
    change MemoryRegions.Disjoint s.oldAfter.layout.keyBase (KvRegions.bytes (n+1)) s.front.keySource.base _
    simpa only [KvRegions.bytes,← same_capacity room] using live.key.1
  valueSeparate := by
    change MemoryRegions.Disjoint s.oldAfter.layout.valueBase (KvRegions.bytes (n+1)) s.front.valueSource.base _
    simpa only [KvRegions.bytes,← same_capacity room] using live.value.2
  valueKeySeparate := by
    change MemoryRegions.Disjoint s.oldAfter.layout.keyBase (KvRegions.bytes (n+1)) s.front.valueSource.base _
    simpa only [KvRegions.bytes,← same_capacity room] using live.value.1

theorem existing_append_safe (room : ¬KvAllocation.capacity n<n+1) (live : Live s (ExistingSafe s))
    {other size : Nat} (safe : ExistingSafe s other size) : (existingAppend room live).append.Safe other size := by
  refine ⟨trivial,?_,?_⟩
  · change MemoryRegions.Disjoint s.oldAfter.layout.keyBase (KvRegions.bytes (n+1)) other size
    simpa only [KvRegions.bytes,← same_capacity room] using safe.1
  · change MemoryRegions.Disjoint s.oldAfter.layout.valueBase (KvRegions.bytes (n+1)) other size
    simpa only [KvRegions.bytes,← same_capacity room] using safe.2

def existingRead (room : ¬KvAllocation.capacity n<n+1) (live : Live s (ExistingSafe s)) : ReadPlan s where
  allocation := existingAppend room live
  queriesSafe := fun head => existing_append_safe room live (live.queries head)
  gatesSafe := fun head => existing_append_safe room live (live.gates head)
  residualSafe := existing_append_safe room live live.residual

theorem existing_frame (room : ¬KvAllocation.capacity n<n+1) (live : Live s (ExistingSafe s))
    {other size : Nat} (prefixSafe : s.front.Safe other size) (safe : ExistingSafe s other size)
    (offset : Nat) (bound : offset<size) :
    (existingRead room live).input.cache.memory (other+offset)=s.front.entry.source.lhs.bytes (other+offset) :=
  (existingRead room live).other_region ⟨prefixSafe,existing_append_safe room live safe⟩ offset bound

end Inference.Models.Qwen.AttentionReadAllocation
