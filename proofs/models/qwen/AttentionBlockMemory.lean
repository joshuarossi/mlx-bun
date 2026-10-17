import models.qwen.AttentionResidualMemory
import models.qwen.ResidualAttention
import models.qwen.AttentionParameterMemory

namespace Inference.Models.Qwen.AttentionBlockMemory
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000
attribute [local irreducible] Copy2DMemory.programs CopyExecution.Trace.memory KvConcatMemory.programs CopyContiguous.programs

-- Both preparation branches start from the exact supplied old cache heap.
inductive Preparation {n : Nat} {cache : Kv.Cache Kv.BF n} (old : KvRegions.Storage cache) where
  | existing (same : KvAllocation.capacity n=KvAllocation.capacity (n+1))
  | growth (allocation : KvGrowthPairMemory.Allocation old)

variable {n : Nat} {cache : Kv.Cache Kv.BF n} {old : KvRegions.Storage cache}

def Preparation.storage (preparation : Preparation old) : KvPreparedMemory.Storage cache :=
  match preparation with
  | .existing same => KvPreparedMemory.Storage.fromExisting old same
  | .growth allocation => (KvGrowthPairMemory.fromStorage old allocation).prepared

def Preparation.Safe (preparation : Preparation old) (base size : Nat) : Prop :=
  match preparation with
  | .existing _ => True
  | .growth a =>
    MemoryRegions.Disjoint (2*a.keyLayout.zeroBase) 524288 base size ∧
    MemoryRegions.Disjoint (2*a.keyLayout.destination) (2*(4*(n+256)*256)) base size ∧
    MemoryRegions.Disjoint (2*a.valueLayout.zeroBase) 524288 base size ∧
    MemoryRegions.Disjoint (2*a.valueLayout.destination) (2*(4*(n+256)*256)) base size

theorem Preparation.other_region (preparation : Preparation old) {base size : Nat}
    (safe : preparation.Safe base size) (offset : Nat) (bound : offset<size) :
    preparation.storage.memory (base+offset)=old.memory (base+offset) := by
  cases preparation with
  | existing same => rfl
  | growth allocation =>
    exact (KvGrowthPairMemory.fromStorage old allocation).other_region
      safe.1 safe.2.1 safe.2.2.1 safe.2.2.2 offset bound

def Preparation.source {row : KvBytes.Row} (preparation : Preparation old) (source : KvCopy.Source row)
    (shared : source.bytes=old.memory) (safe : preparation.Safe source.base (KvAppendMemory.sourceBytes source)) :
    KvCopy.Source row :=
  KvAppendMemory.reframe source preparation.storage.memory
    (fun offset bound => (preparation.other_region safe offset bound).trans (congrFun shared _).symm)

structure Append (heads : AttentionHeads.Heads ArrayStorage.BF) (old : KvRegions.Storage cache) where
  preparation : Preparation old
  key : KvCopy.Source heads.key
  value : KvCopy.Source heads.value
  keyShared : key.bytes=old.memory
  valueShared : value.bytes=old.memory
  keyPrepared : preparation.Safe key.base (KvAppendMemory.sourceBytes key)
  valuePrepared : preparation.Safe value.base (KvAppendMemory.sourceBytes value)
  keySeparate : MemoryRegions.Disjoint preparation.storage.layout.keyBase (KvRegions.bytes (n+1)) key.base (KvAppendMemory.sourceBytes key)
  valueSeparate : MemoryRegions.Disjoint preparation.storage.layout.valueBase (KvRegions.bytes (n+1)) value.base (KvAppendMemory.sourceBytes value)
  valueKeySeparate : MemoryRegions.Disjoint preparation.storage.layout.keyBase (KvRegions.bytes (n+1)) value.base (KvAppendMemory.sourceBytes value)

variable {heads : AttentionHeads.Heads ArrayStorage.BF}

def Append.updated (append : Append heads old) : KvCacheMemory.Execution cache heads.key heads.value :=
  KvPreparedMemory.append append.preparation.storage
    (append.preparation.source append.key append.keyShared append.keyPrepared)
    (append.preparation.source append.value append.valueShared append.valuePrepared)
    rfl rfl append.keySeparate append.valueSeparate append.valueKeySeparate

theorem Append.initial (append : Append heads old) : append.updated.keys.copy.before=append.preparation.storage.memory := rfl

def Append.Safe (append : Append heads old) (base size : Nat) : Prop :=
  append.preparation.Safe base size ∧
  MemoryRegions.Disjoint append.preparation.storage.layout.keyBase (KvRegions.bytes (n+1)) base size ∧
  MemoryRegions.Disjoint append.preparation.storage.layout.valueBase (KvRegions.bytes (n+1)) base size

theorem Append.other_region (append : Append heads old) {base size : Nat}
    (safe : append.Safe base size) (offset : Nat) (bound : offset<size) :
    append.updated.after.memory (base+offset)=old.memory (base+offset) :=
  (SdpaMemory.append_frame append.updated safe.2.1 safe.2.2 offset bound).trans
    (append.preparation.other_region safe.1 offset bound)

def Append.buffer {width : Nat} {values : Fin width → ArrayStorage.BF} (append : Append heads old)
    (source : ArrayStorage.BFBuffer values) (shared : source.bytes=old.memory)
    (safe : append.Safe source.base (2*width)) : ArrayStorage.BFBuffer values :=
  ArrayFrame.bf source append.updated.after.memory
    (fun offset bound => (append.other_region safe offset bound).trans (congrFun shared _).symm)

def Append.input (append : Append heads old) (queries : ∀ head, ArrayStorage.BFBuffer (heads.query head))
    (shared : ∀ head, (queries head).bytes=old.memory)
    (safe : ∀ head, append.Safe (queries head).base 512) : SdpaMemory.Input heads.query (Kv.append cache heads.key heads.value) :=
  ⟨append.updated.after, fun head => append.buffer (queries head) (shared head) (safe head), fun _ => rfl⟩

attribute [local irreducible] Append.updated Append.input Append.buffer Attention.Layer.heads

variable {layer : ResidualAttention.Layer} {normalized original : Fin 5120 → ArrayStorage.BF}
  {angle : RopeAngles.Inputs}

-- The post-head boundary names the mathematical heads and their actual heap.
-- The tail and suffix are completed executions, with exact buffer links.
structure Execution (layer : ResidualAttention.Layer) (normalized original : Fin 5120 → ArrayStorage.BF)
    (angle : RopeAngles.Inputs) (old : KvRegions.Storage cache) where
  append : Append (layer.mixer.heads normalized angle) old
  queries : ∀ head, ArrayStorage.BFBuffer ((layer.mixer.heads normalized angle).query head)
  queriesShared : ∀ head, (queries head).bytes=old.memory
  queriesSafe : ∀ head, append.Safe (queries head).base 512
  gates : ∀ head, ArrayStorage.BFBuffer ((layer.mixer.heads normalized angle).gate head)
  gatesShared : ∀ head, (gates head).bytes=old.memory
  gatesSafe : ∀ head, append.Safe (gates head).base 512
  residual : ArrayStorage.BFBuffer original
  residualShared : residual.bytes=old.memory
  residualSafe : append.Safe residual.base 10240
  attention : SdpaShared.Execution (append.input queries queriesShared queriesSafe)
    layer.mixer.attention layer.mixer.mergeContracted layer.mixer.architectureSuffix
  tail : AttentionTailMemory.Execution attention (layer.mixer.heads normalized angle).gate layer.mixer.gate layer.mixer.output
  tailGates : tail.gates=(fun head => append.buffer (gates head) (gatesShared head) (gatesSafe head))
  suffix : AttentionResidualMemory.Execution tail layer.suffix original
  suffixSource : suffix.source=append.buffer residual residualShared residualSafe

variable (execution : Execution layer normalized original angle old)

def Execution.output : Fin 5120 → ArrayStorage.BF := execution.suffix.output

def Execution.outputBuffer : ArrayStorage.BFBuffer execution.output := execution.suffix.outputBuffer

def Execution.afterCache : KvRegions.Storage (layer.mixer.cacheAfter normalized angle cache) := execution.suffix.afterCache

theorem Execution.cache_output_shared : execution.afterCache.memory=execution.outputBuffer.bytes := rfl

theorem Execution.output_eq : execution.output=layer.suffix.forward original (layer.mixer.forward normalized angle cache) := by
  exact execution.suffix.output_eq

theorem Execution.forward_eq (normalized_eq : normalized=layer.inputNorm.forward original) :
    execution.output=layer.forward original angle cache :=
  execution.output_eq.trans (congrArg (fun row => layer.suffix.forward original (layer.mixer.forward row angle cache)) normalized_eq)

def Safe (execution : Execution layer normalized original angle old) (base size : Nat) : Prop :=
  execution.append.Safe base size ∧ AttentionResidualMemory.Safe execution.suffix base size

theorem Execution.other_region {base size : Nat} (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=old.memory (base+offset) :=
  (show execution.outputBuffer.bytes (base+offset)=execution.append.updated.after.memory (base+offset) from
    by simpa only [Append.input, Execution.outputBuffer] using execution.suffix.other_region safe.2 offset bound).trans
      (execution.append.other_region safe.1 offset bound)

def Execution.parametersAfter (parameters : AttentionParameterMemory.Storage layer.mixer old.memory)
    (safe : AttentionParameterMemory.Protected parameters (Safe execution)) :
    AttentionParameterMemory.Storage layer.mixer execution.outputBuffer.bytes :=
  AttentionParameterMemory.reframe parameters execution.outputBuffer.bytes
    (AttentionParameterMemory.protected_mono parameters (fun _ _ region => execution.other_region region) safe)

def Execution.retainedCaches {tokens : Nat} (stages : List DecodeStage.Stage) (retained : DecodeChain.Caches stages tokens)
    (storage : DecodeFrame.Storage stages retained old.memory)
    (safe : DecodePreservation.Protected (Safe execution) stages retained old.memory storage) :
    DecodeFrame.Storage stages retained execution.outputBuffer.bytes :=
  DecodePreservation.reframe (Safe execution) old.memory execution.outputBuffer.bytes
    (fun _ _ region => execution.other_region region) stages retained storage safe

end Inference.Models.Qwen.AttentionBlockMemory
