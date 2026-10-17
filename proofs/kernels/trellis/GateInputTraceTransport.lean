import kernels.trellis.GateInputSource
namespace Inference.Kernels.Trellis.GateInputTraceTransport
open Contracts.Mlx Contracts.Mlx.M1Max
set_option maxRecDepth 10000

-- Attach the parsed producer to the existing native schedule/current heap.
-- Address-space placement/range is explicit; no new workspace is allocated.
def fromTrace {input : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer input}
    {tableBase : Nat} (trace : GateUpSource.Trace tableBase source)
    (tableAligned : tableBase%4=0) (tableBounded : tableBase+16384≤2^64)
    (inputBounded : trace.inputBase+10240≤2^64) : GateInputSource.Execution source tableBase trace.inputBase where
  sourceAligned := trace.sourceAligned
  tableAligned := tableAligned
  tableBounded := tableBounded
  inputAligned := trace.aligned
  inputBounded := inputBounded
  separate := trace.separate
  before := trace.before
  schedule := trace.schedule
  remaining := trace.remaining
  execution := by simpa only [GateInputSource.programs_eq] using trace.execution
  barrier := trace.barrier

theorem memory_same {input : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer input}
    {tableBase : Nat} (trace : GateUpSource.Trace tableBase source)
    (tableAligned : tableBase%4=0) (tableBounded : tableBase+16384≤2^64)
    (inputBounded : trace.inputBase+10240≤2^64) :
    (fromTrace trace tableAligned tableBounded inputBounded).memory=ByteMemory.execute trace.schedule trace.before := rfl

theorem staged_memory_same {input : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer input}
    {tableBase : Nat} (trace : GateUpSource.Trace tableBase source)
    (tableAligned : tableBase%4=0) (tableBounded : tableBase+16384≤2^64)
    (inputBounded : trace.inputBase+10240≤2^64) :
    (fromTrace trace tableAligned tableBounded inputBounded).memory=ByteMemory.encode trace.staged.memory := by
  change ByteMemory.execute trace.schedule trace.before=ByteMemory.encode (ByteMemory.view (ByteMemory.execute trace.schedule trace.before))
  exact (ByteMemory.encode_view _).symm

end Inference.Kernels.Trellis.GateInputTraceTransport
