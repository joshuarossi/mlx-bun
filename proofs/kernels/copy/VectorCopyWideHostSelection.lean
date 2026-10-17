import kernels.copy.VectorCopyHostSelection
import kernels.copy.VectorCopyWideSourceRefinement

namespace Inference.Kernels.Copy.VectorCopyWideHostSelection
open Contracts.Mlx VectorCopyHostSelection

-- Reuse the frozen reviewed host translation and pinned byte guards. These
-- conditions concern native original descriptors; their extraction and the
-- pipeline/compiler attachment are explicit external links.
structure Slab (blocks : Nat) (values : Fin (4*blocks) → ArrayStorage.BF) where
  buffer : ArrayStorage.BFBuffer values
  logicalSize : Nat
  dataSize : Nat
  contiguous : Bool
  logicalSize_eq : logicalSize=4*blocks
  dataSize_eq : dataSize=4*blocks
  contiguous_eq : contiguous=true

variable {blocks : Nat} {values : Fin (4*blocks) → ArrayStorage.BF}
  (slab : Slab blocks values)

theorem selectsVector (wide : 65536≤4*blocks) :
    slab.contiguous=true ∧ slab.logicalSize=slab.dataSize ∧ slab.dataSize≠1 := by
  rw [slab.logicalSize_eq,slab.dataSize_eq]
  exact ⟨slab.contiguous_eq,rfl,by omega⟩

theorem work (wide : 65536≤4*blocks) : workPerThread 2 slab.dataSize=4 := by
  rw [slab.dataSize_eq]
  simp [workPerThread,show ¬4*blocks<65536 by omega]

theorem grid (wide : 65536≤4*blocks) : ceilDiv slab.dataSize (workPerThread 2 slab.dataSize)=blocks := by
  rw [work slab wide,slab.dataSize_eq]
  unfold ceilDiv
  omega

theorem kernel (wide : 65536≤4*blocks) (small : 4*blocks<2^32) :
    kernelName slab.dataSize 2="vn_copybfloat16bfloat16" := by
  unfold kernelName
  rw [slab.dataSize_eq]
  have bound : ¬4*blocks>4294967295 := by omega
  simp only [bound,↓reduceIte]
  have works := work slab wide
  rw [slab.dataSize_eq] at works
  rw [works]
  rfl

theorem dispatch_exact (pipeline : Pipeline) (wide : 65536≤4*blocks) (small : 4*blocks<2^32) :
    dispatch pipeline slab.dataSize 0 0=
      ⟨blocks,min pipeline.maxThreads blocks,4*blocks,0,0,"vn_copybfloat16bfloat16"⟩ := by
  unfold dispatch
  rw [grid slab wide,kernel slab wide small,slab.dataSize_eq]

theorem no_tail (thread : Fin blocks) : thread.val*4+4≤4*blocks := by
  have := thread.isLt
  omega

theorem cache_size (capacity : Nat) (minimum : 256≤capacity) (supported : capacity≤262144) :
    65536≤4*(capacity*256) ∧ 4*(capacity*256)<2^32 := by omega

end Inference.Kernels.Copy.VectorCopyWideHostSelection
