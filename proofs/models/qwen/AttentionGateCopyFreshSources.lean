import models.qwen.AttentionGateCopyFreshRowSources
import models.qwen.KvCapacityPreservationSourceMemory
namespace Inference.Models.Qwen.AttentionGateCopyFreshSources
open Contracts.Mlx State Kernels.Copy Kernels.Attention
open KvCapacityPreservationSourceMemory
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory
variable {layer : Attention.Layer} {cache : Kv.Cache Kv.BF n} {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache values angle}
  {p : AttentionGateCopyFreshRead.Prepared s} (read : AttentionGateCopyFreshRead.Read p)

theorem key_preservation (supported : n+1≤262144) :
    Preservation (KvAllocation.capacity (n+1)) p.preparation.storage.layout.keyBase read.kv.keys.preservation.destination
      p.preparation.storage.memory read.kv.keys.preservation.memory :=
  preparation read.kv.keys.preservation p.preparation.storage.layout.keyAligned
    (by simpa only [KvSliceCapacityPreparation.region_bytes] using read.kv.storage.layout.keyBound)
    (selected_index_bound supported)

theorem value_preservation (supported : n+1≤262144) :
    Preservation (KvAllocation.capacity (n+1)) p.preparation.storage.layout.valueBase read.kv.values.preservation.destination
      read.kv.keys.memory read.kv.values.preservation.memory :=
  preparation read.kv.values.preservation p.preparation.storage.layout.valueAligned
    (by simpa only [KvSliceCapacityPreparation.region_bytes] using read.kv.storage.layout.valueBound)
    (selected_index_bound supported)

-- Ownership/donation metadata and the native full-copy descriptor remain
-- attachment boundaries. Given those choices, every fresh branch below runs
-- the actual parsed vector body on its current heap before the GG2 row body.
structure Certificate (supported : n+1≤262144) : Prop where
  vectorParser : VectorCopySyntax.parseBody VectorCopySyntax.sourceBody=some VectorCopySyntax.body
  keyPreservation : Preservation (KvAllocation.capacity (n+1)) p.preparation.storage.layout.keyBase
    read.kv.keys.preservation.destination p.preparation.storage.memory read.kv.keys.preservation.memory
  valuePreservation : Preservation (KvAllocation.capacity (n+1)) p.preparation.storage.layout.valueBase
    read.kv.values.preservation.destination read.kv.keys.memory read.kv.values.preservation.memory
  rows : AttentionGateCopyFreshRowSources.Certificate read supported
  keyRowBefore : read.kv.keys.appended.copy.before=read.kv.keys.preservation.memory
  valueRowBefore : read.kv.values.appended.copy.before=read.kv.values.preservation.memory
  finalHeap : read.input.cache.memory=read.kv.values.appended.copy.memory

theorem checked (supported : n+1≤262144) : Certificate read supported :=
  ⟨VectorCopySyntax.parsed_body,key_preservation read supported,value_preservation read supported,
    AttentionGateCopyFreshRowSources.checked read supported,read.key_row_starts,read.value_row_starts,read.final_heap⟩

theorem key_read (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    HalfMemory.load read.input.cache.memory
      (read.input.cache.layout.keyBase+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=
      KvBytes.bits ((layer.cacheAfter values angle cache).keys head time i) := read.kv.key_read head time i

theorem value_read (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    HalfMemory.load read.input.cache.memory
      (read.input.cache.layout.valueBase+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=
      KvBytes.bits ((layer.cacheAfter values angle cache).values head time i) := read.kv.value_read head time i
end Inference.Models.Qwen.AttentionGateCopyFreshSources
