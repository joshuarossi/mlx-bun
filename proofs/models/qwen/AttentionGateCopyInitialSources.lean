import models.qwen.AttentionGateCopyInitialRead

namespace Inference.Models.Qwen.AttentionGateCopyInitialSources
open Contracts.Mlx State Kernels.Attention Kernels.Copy
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

variable {layer : Attention.Layer} {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {cache : Kv.Cache Kv.BF 0} {front : AttentionGateCopyFront.Execution layer values angle}
  (read : AttentionGateCopyInitialRead.Read front cache)

theorem key_small : 3*read.kv.keySource.rowStride+255*read.kv.keySource.columnStride<2^31 := by
  change 3*256+255*1<2^31
  decide

theorem value_small : 3*read.kv.valueSource.rowStride+255*read.kv.valueSource.columnStride<2^31 := by
  change 3*256+255*1<2^31
  decide

def keyChecked := KvInitialKernelMemory.keyChecked read.kv (key_small read)

def valueChecked := KvInitialKernelMemory.valueChecked read.kv (value_small read)

structure Certificate (sources : InitialKvSourceMemory.Sources read.kv.zeros) : Prop where
  parser : GeneralCopy2DSyntax.parseBody GeneralCopy2DSyntax.sourceBody=some GeneralCopy2DSyntax.body
  keyZeroBody : sources.keyChecked.bodyAfter=read.kv.zeros.keys.memory
  keyZeroEvents : sources.keyChecked.eventAfter.memory=read.kv.zeros.keys.memory
  valueZeroBody : sources.valueChecked.bodyAfter=read.kv.zeros.memory
  valueZeroEvents : sources.valueChecked.eventAfter.memory=read.kv.zeros.memory
  zeroLinked : sources.valueAfter.bytes=sources.keyChecked.eventAfter.memory
  keyPreservation : KvInitialDispatchMemory.Preservation read.kv.layout.keyBase
    (KvInitialDispatchMemory.keySlice read.kv).preservation.destination read.kv.zeros.memory
    (KvInitialDispatchMemory.keySlice read.kv).preservation.memory
  valuePreservation : KvInitialDispatchMemory.Preservation read.kv.layout.valueBase
    (KvInitialDispatchMemory.valueSlice read.kv).preservation.destination
    (KvInitialDispatchMemory.keySlice read.kv).memory (KvInitialDispatchMemory.valueSlice read.kv).preservation.memory
  keyCurrent : GeneralCopy2DInterleaving.Executes
    (KvCopy.layout (KvInitialKernelMemory.keyAppend read.kv).source (KvInitialKernelMemory.keyAppend read.kv).base
      (KvInitialKernelMemory.keyAppend read.kv).capacity 0)
    (GeneralCopy2DInterleaving.initial (KvInitialDispatchMemory.keySlice read.kv).preservation.memory)
    (keyChecked read).events (keyChecked read).eventAfter
  keyHeap : (keyChecked read).bodyAfter=(KvInitialDispatchMemory.keySlice read.kv).memory ∧
    (keyChecked read).eventAfter.memory=(KvInitialDispatchMemory.keySlice read.kv).memory
  valueCurrent : GeneralCopy2DInterleaving.Executes
    (KvCopy.layout (KvInitialKernelMemory.valueAppend read.kv).source (KvInitialKernelMemory.valueAppend read.kv).base
      (KvInitialKernelMemory.valueAppend read.kv).capacity 0)
    (GeneralCopy2DInterleaving.initial (KvInitialDispatchMemory.valueSlice read.kv).preservation.memory)
    (valueChecked read).events (valueChecked read).eventAfter
  finalHeap : (valueChecked read).bodyAfter=read.input.cache.memory ∧
    (valueChecked read).eventAfter.memory=read.input.cache.memory

theorem checked (sources : InitialKvSourceMemory.Sources read.kv.zeros) : Certificate read sources :=
  ⟨GeneralCopy2DSyntax.parsed_body,sources.key_body_heap,sources.key_events_heap,
    sources.value_body_heap,sources.value_events_heap,sources.value_starts_key_heap,
    KvInitialDispatchMemory.key_preservation read.kv,KvInitialDispatchMemory.value_preservation read.kv,
    KvInitialKernelMemory.key_starts read.kv (key_small read),KvInitialKernelMemory.key_heaps read.kv (key_small read),
    KvInitialKernelMemory.value_starts read.kv (value_small read),KvInitialKernelMemory.value_heaps read.kv (value_small read)⟩

end Inference.Models.Qwen.AttentionGateCopyInitialSources
