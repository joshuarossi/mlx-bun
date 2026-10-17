import kernels.copy.CpuScalarSourceSemantics
import models.qwen.InitialScalarConstruction
import kernels.copy.ScalarCopyQuadSourceRefinement
namespace Inference.Models.Qwen.CpuScalarParsedConstruction
open Contracts.Mlx Kernels.Copy CpuScalarSourceSyntax CpuScalarSourceSemantics
set_option maxRecDepth 10000

variable (workspace : InitialScalarConstruction.Workspace) (before : ByteMemory.Bytes)

theorem history_memory : workspace.afterHistory before=HalfMemory.store before workspace.base 0 := by
  change HalfMemory.store before (2*(workspace.base/2+0)) 0=HalfMemory.store before workspace.base 0
  congr 1
  have := workspace.aligned
  omega

theorem memory_stores : workspace.memory before=
    ByteMemory.store32 (HalfMemory.store before workspace.base 0) (workspace.base+4) 0 := by
  change ByteMemory.store32 (workspace.afterHistory before) (4*((workspace.base+4)/4+0)) 0=_
  rw [history_memory]
  congr 1
  have := workspace.aligned
  omega

-- This selected native construction path creates two scalar arrays. Their
-- individual CPU stores share this modeled fresh arena and execute in order.
-- Native allocation identity/coherence and parsed-C++/std::copy attachment
-- remain explicit host boundaries; equality below concerns the actual heap.
def executePair (backend : Backend) (host : Host) : Option ByteMemory.Bytes := do
  let halfHeap ←selectedExecute .bf16 backend host before workspace.base
  selectedExecute .fp32 backend host halfHeap (workspace.base+4)

private theorem some_bind {α β : Type} (value : α) (next : α → Option β) :
    (some value >>= next)=next value := rfl

theorem exact_heap (backend : Backend) (host : Host) :
    executePair workspace before backend host=some (workspace.memory before) := by
  simp only [executePair,execute_bf16,some_bind]
  exact (execute_fp32 host backend (HalfMemory.store before workspace.base 0) (workspace.base+4)).trans
    (congrArg some (memory_stores workspace before).symm)

-- Reuse the already constructed scalar buffers; do not attach an expected
-- zero value to arbitrary original bytes or create an independent zero heap.
def history : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues := workspace.history before

def recurrent : ArrayStorage.FloatBuffer InitialStorage.recurrentZero := workspace.recurrent before

theorem history_heap : (history workspace before).bytes=workspace.memory before := rfl

theorem recurrent_heap : (recurrent workspace before).bytes=workspace.memory before := rfl

theorem history_raw : HalfMemory.load (workspace.memory before) workspace.base=0 := workspace.history_raw before

theorem recurrent_raw : ByteMemory.load32 (workspace.memory before) (workspace.base+4)=0 := workspace.recurrent_raw before

theorem frame (separate : MemoryRegions.Disjoint workspace.base InitialScalarConstruction.bytes other size)
    (offset : Nat) (inside : offset<size) : workspace.memory before (other+offset)=before (other+offset) :=
  workspace.other_region before separate offset inside

end Inference.Models.Qwen.CpuScalarParsedConstruction
