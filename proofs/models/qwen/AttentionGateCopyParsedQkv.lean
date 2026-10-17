import models.qwen.AttentionGateCopyKvMemory
import layers.AffineParsedSource

namespace Inference.Models.Qwen.AttentionGateCopyParsedQkv
open Contracts.Mlx Kernels.Attention Layers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

variable {p : AttentionHeads.Projections} {input : Fin 5120 → ArrayStorage.BF}
  (execution : AttentionGateCopyKvMemory.Execution p input)

structure Certificate (before : Nat → Float32) : Prop where
  query : AffineParsedSource.Certificate (steps:=10) (blocks:=192) execution.q before
  key : AffineParsedSource.Certificate (steps:=10) (blocks:=16) execution.k before
  value : AffineParsedSource.Certificate (steps:=10) (blocks:=16) execution.v before
  copy : ∃ programs,
    MlxAttentionGateCopyMemory.sourcePrograms (execution.gateCopy.source.base+512) execution.gateCopy.base=some programs ∧
    ThreadgroupWrites.Executes programs execution.gateCopy.trace.schedule execution.gateCopy.trace.remaining ∧
    ThreadgroupWrites.AtBarrier execution.gateCopy.trace.remaining ∧
    CopyExecution.execute execution.gateCopy.trace.schedule execution.q.forwardBuffer.bytes=execution.gateCopy.trace.memory
  keyHeap : execution.k.source.bytes=execution.gateCopy.trace.memory
  valueHeap : execution.v.source.bytes=execution.k.outputBuffer.bytes
  finalHeap : execution.memory=HalfMemory.execute execution.v.stores
    (HalfMemory.execute execution.k.stores
      (CopyExecution.execute execution.gateCopy.trace.schedule execution.q.forwardBuffer.bytes))

theorem checked (before : Nat → Float32) (queryFinite : p.q.Finite input)
    (keyFinite : p.k.Finite input) (valueFinite : p.v.Finite input) : Certificate execution before := by
  obtain ⟨programs,accepted,schedule,barrier,heap⟩ := MlxAttentionGateCopyMemory.checked execution.gateCopy
  have linked := congrArg ArrayStorage.BFBuffer.bytes execution.gateCopySource
  rw [linked] at heap
  exact ⟨AffineParsedSource.checked (steps:=10) (blocks:=192) execution.q before (by decide) (by decide) queryFinite,
    AffineParsedSource.checked (steps:=10) (blocks:=16) execution.k before (by decide) (by decide) keyFinite,
    AffineParsedSource.checked (steps:=10) (blocks:=16) execution.v before (by decide) (by decide) valueFinite,
    ⟨programs,accepted,schedule,barrier,heap⟩,execution.keyInputMemory,execution.value_input_memory,execution.memory_eq⟩

theorem query_readback (before : Nat → Float32) (source : Certificate execution before) (row : Fin 12288) :
    AffineParsedSource.value (steps:=10) (blocks:=192) execution.q row=execution.q.outputBuffer.read row :=
  AffineParsedSource.same_buffer (steps:=10) (blocks:=192) execution.q before source.query row

theorem key_readback (before : Nat → Float32) (source : Certificate execution before) (row : Fin 1024) :
    AffineParsedSource.value (steps:=10) (blocks:=16) execution.k row=execution.k.outputBuffer.read row :=
  AffineParsedSource.same_buffer (steps:=10) (blocks:=16) execution.k before source.key row

theorem value_readback (before : Nat → Float32) (source : Certificate execution before) (row : Fin 1024) :
    AffineParsedSource.value (steps:=10) (blocks:=16) execution.v row=execution.v.outputBuffer.read row :=
  AffineParsedSource.same_buffer (steps:=10) (blocks:=16) execution.v before source.value row

end Inference.Models.Qwen.AttentionGateCopyParsedQkv
