import models.qwen.AttentionParameterMemory
import models.qwen.AttentionQueryMemory
import models.qwen.DecodePreservation

namespace Inference.Models.Qwen.AttentionProjectionHandoff
open Contracts.Mlx
set_option maxRecDepth 10000

variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {phase : AttentionAffineMemory.Execution layer.projections input}

def parametersAfterCopy (copy : AttentionQueryMemory.Execution phase)
    (storage : AttentionParameterMemory.Storage layer phase.memory)
    (safe : AttentionParameterMemory.Protected storage (MemoryRegions.Disjoint (2*copy.destination) 12288)) :
    AttentionParameterMemory.Storage layer copy.copy.memory :=
  AttentionParameterMemory.reframe storage copy.copy.memory
    (AttentionParameterMemory.protected_mono storage (fun _ _ region => copy.other_region region) safe)

def residualAfterCopy (copy : AttentionQueryMemory.Execution phase)
    {original : Fin 5120 → ArrayStorage.BF} (residual : ArrayStorage.BFBuffer original)
    (shared : residual.bytes=phase.memory)
    (safe : MemoryRegions.Disjoint (2*copy.destination) 12288 residual.base 10240) :
    ArrayStorage.BFBuffer original :=
  ArrayFrame.bf residual copy.copy.memory
    (fun offset bound => (copy.other_region safe offset bound).trans (congrFun shared _).symm)

def cacheAfterCopy {n : Nat} (copy : AttentionQueryMemory.Execution phase)
    {cache : State.Kv.Cache ArrayStorage.BF n} (storage : State.KvRegions.Storage cache)
    (shared : storage.memory=phase.memory)
    (keysSafe : MemoryRegions.Disjoint (2*copy.destination) 12288 storage.layout.keyBase (State.KvRegions.bytes n))
    (valuesSafe : MemoryRegions.Disjoint (2*copy.destination) 12288 storage.layout.valueBase (State.KvRegions.bytes n)) :
    State.KvRegions.Storage cache :=
  storage.reframe copy.copy.memory
    (fun offset bound => (copy.other_region keysSafe offset bound).trans (congrFun shared _).symm)
    (fun offset bound => (copy.other_region valuesSafe offset bound).trans (congrFun shared _).symm)

def retainedCachesAfterCopy {n : Nat} (copy : AttentionQueryMemory.Execution phase)
    (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages n)
    (storage : DecodeFrame.Storage stages cache phase.memory)
    (safe : DecodePreservation.Protected (MemoryRegions.Disjoint (2*copy.destination) 12288)
      stages cache phase.memory storage) : DecodeFrame.Storage stages cache copy.copy.memory :=
  DecodePreservation.reframe _ phase.memory copy.copy.memory
    (fun _ _ region => copy.other_region region) stages cache storage safe

end Inference.Models.Qwen.AttentionProjectionHandoff
