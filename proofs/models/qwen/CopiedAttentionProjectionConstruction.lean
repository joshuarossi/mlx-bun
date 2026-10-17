import models.qwen.CopiedAttentionProjectionLaunch
import models.qwen.AttentionGateCopyKvMemory
namespace Inference.Models.Qwen.CopiedAttentionProjectionConstruction
open Contracts.Mlx Layers Kernels.Attention
set_option maxRecDepth 10000
variable {p : AttentionHeads.Projections} {input : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer input} {live : Nat → Nat → Prop}

structure Plan (p : AttentionHeads.Projections) (source : ArrayStorage.BFBuffer input)
    (weights : AttentionAffineConstruction.Weights p source.bytes) (live : Nat → Nat → Prop) where
  inputLive : live source.base 10240
  qLive : AffineMemoryFrames.Protected p.q weights.q live
  kLive : AffineMemoryFrames.Protected p.k weights.k live
  vLive : AffineMemoryFrames.Protected p.v weights.v live
  q : CopiedAttentionProjectionLaunch.Allocation (groups:=3072) p.q weights.q (source:=source)
  k : CopiedAttentionProjectionLaunch.Allocation (groups:=256) p.k weights.k (source:=source)
  v : CopiedAttentionProjectionLaunch.Allocation (groups:=256) p.v weights.v (source:=source)
  copyBase : Nat
  copyAligned : copyBase%2=0
  copyBounded : copyBase+12288≤2^64
  qSafe : ∀ base size, live base size → MemoryRegions.Disjoint q.base 24576 base size
  kSafe : ∀ base size, live base size → MemoryRegions.Disjoint k.base 2048 base size
  vSafe : ∀ base size, live base size → MemoryRegions.Disjoint v.base 2048 base size
  copySafe : ∀ base size, live base size → MemoryRegions.Disjoint copyBase 12288 base size
  copyQ : MemoryRegions.Disjoint copyBase 12288 q.base 24576
  kQ : MemoryRegions.Disjoint k.base 2048 q.base 24576
  vQ : MemoryRegions.Disjoint v.base 2048 q.base 24576
  vK : MemoryRegions.Disjoint v.base 2048 k.base 2048
  kCopy : MemoryRegions.Disjoint k.base 2048 copyBase 12288
  vCopy : MemoryRegions.Disjoint v.base 2048 copyBase 12288

variable (weights : AttentionAffineConstruction.Weights p source.bytes) (plan : Plan p source weights live)
def initial := CopiedAttentionProjectionHeap.initial source live
def query := CopiedAttentionProjectionLaunch.execution (initial (source:=source) (live:=live)) (groups:=3072) p.q weights.q weights.qShared plan.qLive plan.q

theorem query_base : (query weights plan).base=plan.q.base :=
  CopiedAttentionProjectionLaunch.base _ _ _ _ _ _
theorem query_source : (query weights plan).source=source :=
  CopiedAttentionProjectionLaunch.source_current _ _ _ _ _ _
def afterQuery : CopiedAttentionProjectionHeap.Heap source live :=
  CopiedAttentionProjectionHeap.afterAffine (initial (source:=source) (live:=live)) (query weights plan)
    (query_source weights plan) (by rw [query_base]; exact plan.qSafe)

def copy : MlxAttentionGateCopyMemory.Execution (p.q.forward input) :=
  MlxAttentionGateCopyMemory.canonical (query weights plan).forwardBuffer plan.copyBase plan.copyAligned plan.copyBounded
    (by rw [AttentionAffineConstruction.forward_base,query_base]; exact MemoryRegions.disjoint_symm plan.copyQ)

theorem copy_base : (copy weights plan).base=plan.copyBase := rfl
theorem copy_source : (copy weights plan).source=(query weights plan).forwardBuffer := rfl

def afterCopy : CopiedAttentionProjectionHeap.Heap source live :=
  CopiedAttentionProjectionHeap.afterCopy (afterQuery weights plan) (copy weights plan)
    (by rfl)
    (by rw [copy_base,(afterQuery weights plan).base]; exact plan.copySafe _ _ plan.inputLive)
    (by rw [copy_base]; exact plan.copySafe)

def key := CopiedAttentionProjectionLaunch.execution (afterCopy weights plan) (groups:=256) p.k weights.k weights.kShared plan.kLive plan.k
theorem key_base : (key weights plan).base=plan.k.base :=
  CopiedAttentionProjectionLaunch.base _ _ _ _ _ _
theorem key_source : (key weights plan).source=(afterCopy weights plan).current :=
  CopiedAttentionProjectionLaunch.source_current _ _ _ _ _ _
def afterKey : CopiedAttentionProjectionHeap.Heap source live :=
  CopiedAttentionProjectionHeap.afterAffine (afterCopy weights plan) (key weights plan)
    (key_source weights plan) (by rw [key_base]; exact plan.kSafe)
def value := CopiedAttentionProjectionLaunch.execution (afterKey weights plan) (groups:=256) p.v weights.v weights.vShared plan.vLive plan.v
theorem value_base : (value weights plan).base=plan.v.base :=
  CopiedAttentionProjectionLaunch.base _ _ _ _ _ _
theorem value_source : (value weights plan).source=(afterKey weights plan).current :=
  CopiedAttentionProjectionLaunch.source_current _ _ _ _ _ _

attribute [local irreducible] query key value copy afterQuery afterCopy afterKey

def execution : AttentionGateCopyKvMemory.Execution p input where
  q := query weights plan
  gateCopy := copy weights plan
  gateCopySource := copy_source weights plan
  k := key weights plan
  keyInputMemory := by rw [key_source,afterCopy]; rfl
  keyInputBase := by rw [key_source,(afterCopy weights plan).base,query_source]
  v := value weights plan
  valueInput := by rw [value_source,afterKey]; rfl
  copyQuery := by rw [copy_base,AttentionAffineConstruction.forward_base,query_base]; exact plan.copyQ
  keyQuery := by rw [key_base,AttentionAffineConstruction.forward_base,query_base]; exact plan.kQ
  valueQuery := by rw [value_base,AttentionAffineConstruction.forward_base,query_base]; exact plan.vQ
  valueKey := by rw [value_base,AttentionAffineConstruction.forward_base,key_base]; exact plan.vK
  keyGate := by rw [key_base,copy_base]; exact plan.kCopy
  valueGate := by rw [value_base,copy_base]; exact plan.vCopy

end Inference.Models.Qwen.CopiedAttentionProjectionConstruction
