import models.qwen.CopiedAttentionAllocatedScalarSources
import models.qwen.CopiedAttentionInitialArenaFactory
import models.qwen.CopiedAttentionAllocatedPositiveRead
import models.qwen.AttentionGateCopyPositiveSources

namespace Inference.Models.Qwen.CopiedAttentionScalarPrefix
open Contracts.Mlx Layers State Kernels Kernels.Attention Kernels.Copy
set_option maxRecDepth 10000

variable {layer : ResidualAttention.Layer} {values : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer values} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  (w : CopiedAttentionEntryAllocation.Workspace source original)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2) (angle : RopeAngles.Inputs)

abbrev front := CopiedAttentionAllocatedPositiveInput.front w queryDispatch keyDispatch angle

theorem frame {base size : Nat} (below : base+size≤w.base) (offset : Nat) (bound : offset<size) :
    (front w queryDispatch keyDispatch angle).memory (base+offset)=source.bytes (base+offset) :=
  (CopiedAttentionAllocatedFrontFrame.frame (CopiedAttentionEntryAllocation.normalized w).projections
    (CopiedAttentionEntryAllocation.projectionWorkspace w) (CopiedAttentionEntryAllocation.normalized w).mixer
    (CopiedAttentionEntryAllocation.projection_regions w).2.2.1 queryDispatch keyDispatch angle
    (Or.inr (below.trans (Nat.le_add_right _ _))) offset bound).trans
    (CopiedAttentionOriginalBundle.normalization_frame source original (CopiedAttentionEntryAllocation.normal w)
      (by change MemoryRegions.Disjoint (2*(w.base/2)) 10240 base size;
          rw [CopiedAttentionEntryAllocation.half_base]; exact Or.inr below) offset bound)

variable (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
  (shared : zero.bytes=source.bytes) (below : zero.base+2≤w.base)

-- This transports the produced scalar through the actual RMS/Q/copy/K/V/
-- query-copy/head-normalization/RoPE heap, with no expected scalar bytes premise.
def currentZero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues :=
  ArrayFrame.bf zero (front w queryDispatch keyDispatch angle).memory
    (fun offset bound => (frame w queryDispatch keyDispatch angle below offset bound).trans (congrFun shared _).symm)

theorem current_base : (currentZero w queryDispatch keyDispatch angle zero shared below).base=zero.base := rfl

theorem current_heap : (currentZero w queryDispatch keyDispatch angle zero shared below).bytes=
    (front w queryDispatch keyDispatch angle).memory := rfl

namespace Initial
variable (cache : Kv.Cache Kv.BF 0)
  (aligned : (CopiedAttentionEntryAllocation.projectionWorkspace w).base%16=0)
  (room : (CopiedAttentionEntryAllocation.projectionWorkspace w).base+CopiedAttentionProjectionAllocation.bytes+
    CopiedAttentionInitialReadAllocation.bytes≤2^64)

def sources : InitialKvSourceMemory.Sources
    (CopiedAttentionInitialArenaFactory.read w queryDispatch keyDispatch angle cache aligned room).kv.zeros :=
  CopiedAttentionAllocatedScalarSources.Initial.sources
    (CopiedAttentionInitialArenaFactory.request w queryDispatch keyDispatch angle aligned room) cache
    (currentZero w queryDispatch keyDispatch angle zero shared below) rfl
    (by change zero.base+2≤w.base+10240+CopiedAttentionProjectionAllocation.bytes; omega)

theorem source_base : (sources w queryDispatch keyDispatch angle zero shared below cache aligned room).keyScalar.base=zero.base := rfl
end Initial

namespace Positive
variable {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache)
  (storageShared : storage.memory=source.bytes)
  (keysBelow : storage.layout.keyBase+KvRegions.bytes n≤w.base)
  (valuesBelow : storage.layout.valueBase+KvRegions.bytes n≤w.base)
  (aligned : w.base%16=0) (positive : 0<n)
  (growing : KvAllocation.capacity n<n+1)
  (room : w.base+CopiedAttentionEntryAllocation.bytes+
    (KvGrowthAllocation.bytes n+CopiedAttentionFreshAppendAllocation.bytes n)≤2^64)

abbrev growthRequest := CopiedAttentionAllocatedPositiveRead.growthRequest w queryDispatch keyDispatch angle
  storage storageShared keysBelow valuesBelow aligned positive growing room

def growth : AttentionGateCopyPositiveSources.Inputs
    (CopiedAttentionGrowthPreparation.prepared (growthRequest w queryDispatch keyDispatch angle storage storageShared
      keysBelow valuesBelow aligned positive growing room)).preparation :=
  CopiedAttentionAllocatedScalarSources.Growth.scalars
    (growthRequest w queryDispatch keyDispatch angle storage storageShared keysBelow valuesBelow aligned positive growing room)
    (currentZero w queryDispatch keyDispatch angle zero shared below) rfl
    (by change zero.base+2≤w.base+CopiedAttentionEntryAllocation.bytes; omega)

theorem growth_base : (CopiedAttentionAllocatedScalarSources.Growth.scalars
    (growthRequest w queryDispatch keyDispatch angle storage storageShared keysBelow valuesBelow aligned positive growing room)
    (currentZero w queryDispatch keyDispatch angle zero shared below) rfl
    (by change zero.base+2≤w.base+CopiedAttentionEntryAllocation.bytes; omega)).key.base=zero.base := rfl
end Positive

namespace Reuse
variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  (s : AttentionGateCopyReadConstruction.Input layer cache input angle)
  (same : KvAllocation.capacity n=KvAllocation.capacity (n+1))

def inputs : AttentionGateCopyPositiveSources.Inputs (s:=s) (.existing same) := PUnit.unit

theorem inputs_unit : inputs s same=PUnit.unit := rfl
end Reuse

end Inference.Models.Qwen.CopiedAttentionScalarPrefix
