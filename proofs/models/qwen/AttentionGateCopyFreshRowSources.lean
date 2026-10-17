import models.qwen.AttentionGateCopyFreshRead
import models.qwen.KvCapacityKernelMemory
namespace Inference.Models.Qwen.AttentionGateCopyFreshRowSources
open Contracts.Mlx State Kernels.Copy Kernels.Attention
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory
variable {layer : Attention.Layer} {cache : Kv.Cache Kv.BF n} {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache values angle}
  {p : AttentionGateCopyFreshRead.Prepared s} (read : AttentionGateCopyFreshRead.Read p)

theorem key_small : 3*read.kv.keys.source.rowStride+255*read.kv.keys.source.columnStride<2^31 := by
  change 3*256+255*1<2^31
  decide

theorem value_small : 3*read.kv.values.source.rowStride+255*read.kv.values.source.columnStride<2^31 := by
  change 3*256+255*1<2^31
  decide

theorem key_bound : read.kv.keys.source.base+KvAppendMemory.sourceBytes read.kv.keys.source≤2^64 := by
  change s.front.rope.key.destination+2048≤2^64
  exact s.front.rope.key.output.bounded

theorem value_bound : read.kv.values.source.base+KvAppendMemory.sourceBytes read.kv.values.source≤2^64 := by
  change s.front.valueBuffer.base+2048≤2^64
  exact s.front.valueBuffer.bounded

def keyChecked (supported : n+1≤262144) :=
  KvCapacityKernelMemory.checked read.kv.keys (key_small read) (key_bound read) supported

def valueChecked (supported : n+1≤262144) :=
  KvCapacityKernelMemory.checked read.kv.values (value_small read) (value_bound read) supported

structure Certificate (supported : n+1≤262144) : Prop where
  parser : GeneralCopy2DSyntax.parseBody GeneralCopy2DSyntax.sourceBody=some GeneralCopy2DSyntax.body
  keyCurrent : GeneralCopy2DInterleaving.Executes
    (KvCopy.layout read.kv.keys.appended.source read.kv.keys.appended.base read.kv.keys.appended.capacity n)
    (GeneralCopy2DInterleaving.initial read.kv.keys.preservation.memory)
    (keyChecked read supported).events (keyChecked read supported).eventAfter
  keyHeap : (keyChecked read supported).bodyAfter=read.kv.keys.memory ∧
    (keyChecked read supported).eventAfter.memory=read.kv.keys.memory
  valueCurrent : GeneralCopy2DInterleaving.Executes
    (KvCopy.layout read.kv.values.appended.source read.kv.values.appended.base read.kv.values.appended.capacity n)
    (GeneralCopy2DInterleaving.initial read.kv.values.preservation.memory)
    (valueChecked read supported).events (valueChecked read supported).eventAfter
  finalHeap : (valueChecked read supported).bodyAfter=read.input.cache.memory ∧
    (valueChecked read supported).eventAfter.memory=read.input.cache.memory

theorem checked (supported : n+1≤262144) : Certificate read supported :=
  ⟨GeneralCopy2DSyntax.parsed_body,
    KvCapacityKernelMemory.starts read.kv.keys (key_small read) (key_bound read) supported,
    KvCapacityKernelMemory.heaps read.kv.keys (key_small read) (key_bound read) supported,
    KvCapacityKernelMemory.starts read.kv.values (value_small read) (value_bound read) supported,
    KvCapacityKernelMemory.heaps read.kv.values (value_small read) (value_bound read) supported⟩
end Inference.Models.Qwen.AttentionGateCopyFreshRowSources
