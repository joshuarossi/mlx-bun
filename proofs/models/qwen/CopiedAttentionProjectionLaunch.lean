import models.qwen.CopiedAttentionProjectionHeap
namespace Inference.Models.Qwen.CopiedAttentionProjectionLaunch
open Contracts.Mlx Layers
set_option maxRecDepth 10000
variable {groups : Nat} {input : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer input} {live : Nat → Nat → Prop}
  (heap : CopiedAttentionProjectionHeap.Heap source live)
  (projection : AffineVerifyLinear.Projection 10 (4*groups)) (original : AffineDevice.Storage projection)
  (shared : AffineMemory.Shared projection original source.bytes)
  (safe : AffineMemoryFrames.Protected projection original live)

structure Allocation where
  base : Nat
  aligned : base%2=0
  bounded : base+2*(4*groups)≤2^64
  input : MemoryRegions.Disjoint base (2*(4*groups)) source.base 10240
  weights : AffineMemory.Separate projection original base (2*(4*groups))

variable (allocation : Allocation projection original (source:=source))
theorem input_separate : MemoryRegions.Disjoint allocation.base (2*(4*groups)) heap.current.base 10240 := by
  rw [heap.base]
  exact allocation.input

theorem weights_separate : AffineMemory.Separate projection (CopiedAttentionProjectionHeap.weights heap projection original shared safe)
    allocation.base (2*(4*groups)) :=
by
  cases projection <;> exact ⟨allocation.weights.packed,allocation.weights.scales,allocation.weights.biases⟩

def execution : AffineMemory.Execution projection input :=
  AffineMemory.fromStorage projection input (CopiedAttentionProjectionHeap.weights heap projection original shared safe)
    heap.current (CopiedAttentionProjectionHeap.weights_shared heap projection original shared safe)
    allocation.base allocation.aligned allocation.bounded (input_separate heap projection original allocation)
    (weights_separate heap projection original shared safe allocation)

theorem source_current : (execution heap projection original shared safe allocation).source=heap.current :=
  AffineMemory.source_fromStorage _ _ _ _ _ _ _ _

theorem base : (execution heap projection original shared safe allocation).base=allocation.base :=
  AttentionAffineConstruction.base_fromStorage _ _ _ _ _ _ _ _ _ _
end Inference.Models.Qwen.CopiedAttentionProjectionLaunch
