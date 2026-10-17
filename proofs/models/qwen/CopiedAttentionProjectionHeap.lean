import models.qwen.AttentionGateCopyFrames
import models.qwen.AttentionAffineConstruction
import kernels.attention.MlxAttentionGateCopyMemory
namespace Inference.Models.Qwen.CopiedAttentionProjectionHeap
open Contracts.Mlx Layers Kernels.Attention
set_option maxRecDepth 10000

-- The protected predicate includes the real copy allocation as well as Q/K/V
-- destinations. Each heap remembers the one original activation/weight heap.
structure Heap (source : ArrayStorage.BFBuffer input) (live : Nat → Nat → Prop) where
  current : ArrayStorage.BFBuffer input
  base : current.base=source.base
  frame : ∀ base size, live base size → ∀ offset<size, current.bytes (base+offset)=source.bytes (base+offset)

variable {input : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer input} {live : Nat → Nat → Prop}
def initial (source : ArrayStorage.BFBuffer input) (live : Nat → Nat → Prop) : Heap source live :=
  ⟨source,rfl,fun _ _ _ _ _ => rfl⟩

variable (heap : Heap source live)
def weights (projection : AffineVerifyLinear.Projection steps rows) (original : AffineDevice.Storage projection)
    (shared : AffineMemory.Shared projection original source.bytes)
    (safe : AffineMemoryFrames.Protected projection original live) : AffineDevice.Storage projection :=
  AffineMemoryFrames.reframe projection original heap.current.bytes
    (AffineMemoryFrames.stable projection original source.bytes heap.current.bytes shared
      (AffineMemoryFrames.protected_mono projection original heap.frame safe))

theorem weights_shared (projection : AffineVerifyLinear.Projection steps rows) (original : AffineDevice.Storage projection)
    (shared : AffineMemory.Shared projection original source.bytes)
    (safe : AffineMemoryFrames.Protected projection original live) :
    AffineMemory.Shared projection (weights heap projection original shared safe) heap.current.bytes :=
  AffineMemoryFrames.reframe_shared projection original heap.current.bytes _

def afterAffine {groups : Nat} {projection : AffineVerifyLinear.Projection 10 (4*groups)}
    (execution : AffineMemory.Execution projection input) (linked : execution.source=heap.current)
    (safe : ∀ base size, live base size → MemoryRegions.Disjoint execution.base (2*(4*groups)) base size) : Heap source live where
  current := AffineMemoryFrames.sourceAfter execution
  base := (congrArg ArrayStorage.BFBuffer.base linked).trans heap.base
  frame base size region offset bound :=
    (execution.other_region (safe base size region) offset bound).trans
      ((congrArg (fun buffer => buffer.bytes (base+offset)) linked).trans (heap.frame base size region offset bound))

def afterCopy {queryGate : Fin 12288 → ArrayStorage.BF}
    (copy : MlxAttentionGateCopyMemory.Execution queryGate) (shared : copy.source.bytes=heap.current.bytes)
    (inputSafe : MemoryRegions.Disjoint copy.base 12288 heap.current.base 10240)
    (safe : ∀ base size, live base size → MemoryRegions.Disjoint copy.base 12288 base size) : Heap source live where
  current := AttentionGateCopyFrames.sourceAfter copy heap.current shared.symm inputSafe
  base := heap.base
  frame base size region offset bound :=
    (MlxAttentionGateCopyMemory.other_region copy (safe base size region) offset bound).trans
      ((congrFun shared _).trans (heap.frame base size region offset bound))
end Inference.Models.Qwen.CopiedAttentionProjectionHeap
