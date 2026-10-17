import state.KvConcatMemory
import kernels.copy.ScalarFullHostSelection

namespace Inference.Kernels.Copy.MlxKvZeroSource
open Contracts.Mlx State
open ScalarCopyQuadSemantics ScalarCopyQuadSourceRefinement
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange zeroTrace ScalarCopyQuadSemantics.run

variable {capacity : Nat} {layout : KvConcatMemory.Layout capacity}
  (growth : KvConcatMemory.Initialized layout)
  (scalar : ArrayStorage.BFBuffer zeroValues)
  (shared : scalar.bytes=growth.zeros.before)
  (allocation : Allocation scalar.base (2*layout.zeroBase))

-- Original zero-scalar bytes and fresh-buffer geometry are the inputs. The
-- completed zero slab is obtained by executing the parsed BF16 N=4 source.
def checked : Checked scalar (2*layout.zeroBase) allocation :=
  ScalarCopyQuadSourceRefinement.canonical scalar (2*layout.zeroBase) allocation

include shared in
theorem body_heap : (checked scalar allocation).bodyAfter=growth.zeros.memory := by
  have result := events_zero_eq allocation (checked scalar allocation).eventExecution
    (checked scalar allocation).eventCompleted (scalar_zero scalar) growth.zeros shared.symm
  exact (checked scalar allocation).agreement.same_heap.trans result

include shared in
theorem event_heap : (checked scalar allocation).eventAfter.memory=growth.zeros.memory :=
  events_zero_eq allocation (checked scalar allocation).eventExecution
    (checked scalar allocation).eventCompleted (scalar_zero scalar) growth.zeros shared.symm

theorem selected_host (pipeline : VectorCopyHostSelection.Pipeline) :
    ScalarFullHostSelection.dispatch .kv pipeline=
      ⟨65536,min pipeline.maxThreads 65536,262144,4,"sn_copybfloat16bfloat16",0,0⟩ :=
  ScalarFullHostSelection.kv_dispatch pipeline

end Inference.Kernels.Copy.MlxKvZeroSource
