import models.qwen.AttentionPrefixAllocation
import models.qwen.AttentionReadAllocation

namespace Inference.Models.Qwen.AttentionPrefixReadAllocation
open Contracts.Mlx Kernels Kernels.Attention State Layers
set_option maxRecDepth 10000
attribute [local irreducible] AttentionHeads.Projections.forward Blocks.Norm.forward AttentionHeads.Norm.forward
  Copy2DMemory.programs CopyExecution.Trace.memory RopeRowsMemory.programs MultiOutputWrites.programs
  ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

theorem key_source_first {layer : ResidualAttention.Layer} {original : Fin 5120 → ArrayStorage.BF}
    {angle : RopeAngles.Inputs} (front : ResidualAttentionMemory.Prefix layer original angle) :
    front.keySource.base=(front.key 0).base := by
  change front.rope.key.destination=front.rope.key.destination+512*0
  omega

attribute [local irreducible] AttentionPrefixAllocation.Arena.entryPlan
  AttentionPrefixAllocation.Arena.copyAllocation AttentionPrefixAllocation.Arena.rmsPlan
  AttentionPrefixAllocation.Arena.ropePlan AttentionPrefixAllocation.Arena.prefixAllocation
  AttentionPrefixAllocation.Arena.front

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {original : Fin 5120 → ArrayStorage.BF}
  {source : ResidualAttentionStorageConstruction.Source layer cache original}

theorem outside_subregion {base size arena first count : Nat}
    (safe : MemoryRegions.Disjoint base size arena 79872)
    (lower : arena≤first) (upper : first+count≤arena+79872) : MemoryRegions.Disjoint base size first count :=
  MemoryRegions.disjoint_symm (AttentionPrefixAllocation.contained_disjoint lower upper (MemoryRegions.disjoint_symm safe))

variable (arena : AttentionPrefixAllocation.Arena source) (angle : RopeAngles.Inputs)
  (cachePlan : ResidualAttentionStorageConstruction.CacheAllocation (arena.prefixAllocation angle))

theorem key_source_base : (arena.front angle).keySource.base=arena.base+77824 := by
  rw [key_source_first,(arena.physical_bases angle).2.1 0]
  simp

theorem front_eq : cachePlan.input.front=arena.front angle := by
  unfold AttentionPrefixAllocation.Arena.front
  exact cachePlan.front_eq

theorem residual_base : cachePlan.input.savedResidual.base=source.source.base := by
  change cachePlan.input.front.entry.source.lhs.base=source.source.base
  rw [front_eq]
  unfold AttentionPrefixAllocation.Arena.front
  rw [(arena.prefixAllocation angle).entry_eq,arena.entryPlan.source_eq]

theorem live_of_arena {base size : Nat}
    (separate : MemoryRegions.Disjoint base size arena.base 79872)
    (residual : MemoryRegions.Disjoint base size source.source.base 10240) :
    AttentionReadAllocation.Live cachePlan.input (MemoryRegions.Disjoint base size) where
  key := by
    change MemoryRegions.Disjoint base size cachePlan.input.front.keySource.base 2048
    rw [front_eq]
    rw [key_source_base]
    exact outside_subregion separate (by omega) (by omega)
  value := by
    change MemoryRegions.Disjoint base size cachePlan.input.front.valueBuffer.base 2048
    rw [front_eq]
    rw [(arena.physical_bases angle).2.2.2]
    exact outside_subregion separate (by omega) (by omega)
  queries := by
    intro head
    rw [front_eq]
    rw [(arena.physical_bases angle).1 head]
    exact outside_subregion separate (by omega) (by have := head.isLt; omega)
  gates := by
    intro head
    rw [front_eq]
    rw [(arena.physical_bases angle).2.2.1 head]
    exact outside_subregion separate (by omega) (by have := head.isLt; omega)
  residual := by rw [residual_base]; exact residual

def growthRead (workspace : KvGrowthAllocation.Workspace cachePlan.input.oldAfter)
    (growing : KvAllocation.capacity n<n+1)
    (separate : MemoryRegions.Disjoint workspace.base (KvGrowthAllocation.bytes n) arena.base 79872)
    (residual : MemoryRegions.Disjoint workspace.base (KvGrowthAllocation.bytes n) source.source.base 10240) :
    ResidualAttentionConstruction.ReadPlan cachePlan.input :=
  AttentionReadAllocation.growthRead workspace growing (live_of_arena arena angle cachePlan separate residual)

theorem growth_safe (workspace : KvGrowthAllocation.Workspace cachePlan.input.oldAfter)
    (growing : KvAllocation.capacity n<n+1)
    (separate : MemoryRegions.Disjoint workspace.base (KvGrowthAllocation.bytes n) arena.base 79872)
    (residual : MemoryRegions.Disjoint workspace.base (KvGrowthAllocation.bytes n) source.source.base 10240)
    {base size : Nat} (frontSafe : MemoryRegions.Disjoint arena.base 79872 base size)
    (cacheSafe : MemoryRegions.Disjoint workspace.base (KvGrowthAllocation.bytes n) base size) :
    (growthRead arena angle cachePlan workspace growing separate residual).Safe base size :=
by
  refine ⟨?_,AttentionReadAllocation.growth_append_safe workspace growing
    (live_of_arena arena angle cachePlan separate residual) cacheSafe⟩
  rw [front_eq]
  exact arena.safe angle frontSafe

theorem existing_live
    (keys : MemoryRegions.Disjoint arena.base 79872 source.storage.layout.keyBase (KvRegions.bytes n))
    (values : MemoryRegions.Disjoint arena.base 79872 source.storage.layout.valueBase (KvRegions.bytes n))
    (keyResidual : MemoryRegions.Disjoint source.storage.layout.keyBase (KvRegions.bytes n) source.source.base 10240)
    (valueResidual : MemoryRegions.Disjoint source.storage.layout.valueBase (KvRegions.bytes n) source.source.base 10240) :
    AttentionReadAllocation.Live cachePlan.input (AttentionReadAllocation.ExistingSafe cachePlan.input) := by
  have k := live_of_arena arena angle cachePlan (MemoryRegions.disjoint_symm keys) keyResidual
  have v := live_of_arena arena angle cachePlan (MemoryRegions.disjoint_symm values) valueResidual
  exact ⟨⟨k.key,v.key⟩,⟨k.value,v.value⟩,fun head => ⟨k.queries head,v.queries head⟩,
    fun head => ⟨k.gates head,v.gates head⟩,⟨k.residual,v.residual⟩⟩

def existingRead (room : ¬KvAllocation.capacity n<n+1)
    (keys : MemoryRegions.Disjoint arena.base 79872 source.storage.layout.keyBase (KvRegions.bytes n))
    (values : MemoryRegions.Disjoint arena.base 79872 source.storage.layout.valueBase (KvRegions.bytes n))
    (keyResidual : MemoryRegions.Disjoint source.storage.layout.keyBase (KvRegions.bytes n) source.source.base 10240)
    (valueResidual : MemoryRegions.Disjoint source.storage.layout.valueBase (KvRegions.bytes n) source.source.base 10240) :
    ResidualAttentionConstruction.ReadPlan cachePlan.input :=
  AttentionReadAllocation.existingRead room (existing_live arena angle cachePlan keys values keyResidual valueResidual)

theorem existing_safe (room : ¬KvAllocation.capacity n<n+1)
    (keys : MemoryRegions.Disjoint arena.base 79872 source.storage.layout.keyBase (KvRegions.bytes n))
    (values : MemoryRegions.Disjoint arena.base 79872 source.storage.layout.valueBase (KvRegions.bytes n))
    (keyResidual : MemoryRegions.Disjoint source.storage.layout.keyBase (KvRegions.bytes n) source.source.base 10240)
    (valueResidual : MemoryRegions.Disjoint source.storage.layout.valueBase (KvRegions.bytes n) source.source.base 10240)
    {base size : Nat} (frontSafe : MemoryRegions.Disjoint arena.base 79872 base size)
    (cacheSafe : AttentionReadAllocation.ExistingSafe cachePlan.input base size) :
    (existingRead arena angle cachePlan room keys values keyResidual valueResidual).Safe base size :=
by
  refine ⟨?_,AttentionReadAllocation.existing_append_safe room
    (existing_live arena angle cachePlan keys values keyResidual valueResidual) cacheSafe⟩
  rw [front_eq]
  exact arena.safe angle frontSafe

end Inference.Models.Qwen.AttentionPrefixReadAllocation
