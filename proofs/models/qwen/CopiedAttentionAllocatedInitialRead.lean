import models.qwen.CopiedAttentionAllocatedFront
import models.qwen.CopiedAttentionInitialReadAllocation
namespace Inference.Models.Qwen.CopiedAttentionAllocatedInitialRead
open Contracts.Mlx Layers State Kernels Kernels.Attention
set_option maxRecDepth 10000
variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer input}
  (weights : AttentionAffineConstruction.Weights layer.projections source.bytes)
  (w : CopiedAttentionProjectionAllocation.Workspace source weights)
  (original : AttentionParameterMemory.Storage layer source.bytes)
  (protectedParameters : AttentionParameterMemory.Protected original
    (MemoryRegions.Disjoint w.base CopiedAttentionProjectionAllocation.bytes))
  (queryDispatch : layer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.preparation.kNorm.platform.groups=2)
  (angle : RopeAngles.Inputs)
  (aligned : w.base%16=0)
  (room : w.base+CopiedAttentionProjectionAllocation.bytes+CopiedAttentionInitialReadAllocation.bytes≤2^64)

def request : CopiedAttentionInitialReadAllocation.Request
    (CopiedAttentionAllocatedFront.front weights w original protectedParameters queryDispatch keyDispatch angle) where
  cursor := w.base+CopiedAttentionProjectionAllocation.bytes
  aligned := by unfold CopiedAttentionProjectionAllocation.bytes; omega
  room := room
  keys := by
    rw [CopiedAttentionAllocatedFront.key_base,CopiedAttentionAllocatedFront.key_span]
    unfold CopiedAttentionProjectionAllocation.bytes
    omega
  values := by
    rw [CopiedAttentionAllocatedFront.value_base,CopiedAttentionAllocatedFront.value_span]
    unfold CopiedAttentionProjectionAllocation.bytes
    omega
  queries := by
    intro head
    rw [CopiedAttentionAllocatedFront.query_base]
    have := head.isLt
    unfold CopiedAttentionProjectionAllocation.bytes
    omega
  gates := by
    intro head
    rw [CopiedAttentionAllocatedFront.gate_base]
    have := head.isLt
    unfold CopiedAttentionProjectionAllocation.bytes
    omega

def read (cache : Kv.Cache Kv.BF 0) :=
  CopiedAttentionInitialReadAllocation.read
    (request weights w original protectedParameters queryDispatch keyDispatch angle aligned room) cache

theorem frame (cache : Kv.Cache Kv.BF 0) {base size : Nat} (below : base+size≤w.base)
    (offset : Nat) (bound : offset<size) :
    (read weights w original protectedParameters queryDispatch keyDispatch angle aligned room cache).input.cache.memory (base+offset)=
      (CopiedAttentionAllocatedFront.front weights w original protectedParameters queryDispatch keyDispatch angle).memory (base+offset) :=
  CopiedAttentionInitialReadAllocation.frame _ cache (by change base+size≤w.base+CopiedAttentionProjectionAllocation.bytes; omega) offset bound
end Inference.Models.Qwen.CopiedAttentionAllocatedInitialRead
