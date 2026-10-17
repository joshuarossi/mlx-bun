import kernels.attention.MlxAttentionGateReshapeHost
import kernels.normalization.MlxRmsHeadHostSelection

namespace Inference.Kernels.Attention.MlxAttentionQueryCopyHost
open Contracts.Mlx Normalization.MlxRmsHostSelection
set_option maxRecDepth 10000

-- The Q half-view has the original interleaved head stride. Its contiguous
-- flag cannot bypass the explicit previous-stride/extent source guard.
def metadata (contiguous donatable : Bool) (dataSize : Nat) : Metadata :=
  ⟨256,dataSize,4,contiguous,1,512,24,donatable,1,1⟩

theorem copy_required (contiguous donatable : Bool) (dataSize : Nat) :
    noCopy (metadata contiguous donatable dataSize)=false ∧
      allocation (metadata contiguous donatable dataSize)=.contiguousCopy := by
  cases contiguous <;> cases donatable <;> simp [metadata,noCopy,allocation]

-- Once the source-bound copy completes, its constructed contiguous rows
-- select the existing unlooped 256-wide kernel, with donation of that copy.
theorem copied_launch (kernel : KernelLimit) (capacity : 64≤kernel.threads) :
    select (Normalization.MlxRmsHeadHostSelection.metadata 24 256 true) kernel=
      some ⟨256,24,false,1,64,1536,.donated⟩ :=
  Normalization.MlxRmsHeadHostSelection.selected_query kernel capacity

theorem collapsed : Copy.KvRowDispatchGeometry.collapse MlxAttentionGateReshapeHost.gateAxes (2^31-1)=
    [⟨24,512,256⟩,⟨256,1,1⟩] := MlxAttentionGateReshapeHost.collapsed

theorem copy_grid : Copy.KvRowDispatchGeometry.grid [⟨24,512,256⟩,⟨256,1,1⟩]=⟨256,24,1⟩ :=
  MlxAttentionGateReshapeHost.selected_grid

end Inference.Kernels.Attention.MlxAttentionQueryCopyHost
