import state.KvRegions
namespace Inference.Models.Qwen.EmptyKvAttachment
open Contracts.Mlx State

-- Empty caches have no active tensor cells. These zero-extent logical views
-- do not assert an allocation or a native pointer for a nonexistent old cache.
def layout : KvRegions.Layout 0 where
  keyBase := 0
  valueBase := 0
  keyAligned := by decide
  valueAligned := by decide
  keyBound := by decide +kernel
  valueBound := by decide +kernel
  separate := Or.inl (by decide +kernel)

def storage (cache : Kv.Cache Kv.BF 0) (memory : ByteMemory.Bytes) : KvRegions.Storage cache where
  layout := layout
  memory := memory
  keys := by intro _ time; exact Fin.elim0 time
  values := by intro _ time; exact Fin.elim0 time
end Inference.Models.Qwen.EmptyKvAttachment
