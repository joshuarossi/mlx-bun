import models.qwen.AttentionNormalizedConstruction
import models.qwen.AttentionRopeNormalizedMemory
import models.qwen.AttentionBlockMemory

namespace Inference.Models.Qwen.ResidualAttentionMemory
open Contracts.Mlx Kernels Kernels.Attention State
set_option maxRecDepth 10000
attribute [local irreducible] RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor
  Copy2DMemory.programs CopyExecution.Trace.memory RopeRowsMemory.programs MultiOutputWrites.programs
  ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

variable {layer : ResidualAttention.Layer} {original : Fin 5120 → ArrayStorage.BF}

def copiedParameters (entry : AttentionNormalizedMemory.Execution layer original)
    (copy : AttentionQueryMemory.Execution entry.affine)
    (parameters : AttentionParameterMemory.Storage layer.mixer entry.source.lhs.bytes)
    (entrySafe : AttentionParameterMemory.Protected parameters (AttentionNormalizedMemory.Safe entry))
    (copySafe : AttentionParameterMemory.Protected (entry.parametersAfter parameters entrySafe)
      (MemoryRegions.Disjoint (2*copy.destination) 12288)) :
    AttentionParameterMemory.Storage layer.mixer copy.copy.memory :=
  AttentionProjectionHandoff.parametersAfterCopy copy (entry.parametersAfter parameters entrySafe) copySafe

attribute [local irreducible] copiedParameters

structure Prefix (layer : ResidualAttention.Layer) (original : Fin 5120 → ArrayStorage.BF) (angle : RopeAngles.Inputs) where
  entry : AttentionNormalizedMemory.Execution layer original
  copy : AttentionQueryMemory.Execution entry.affine
  parameters : AttentionParameterMemory.Storage layer.mixer entry.source.lhs.bytes
  entryParameters : AttentionParameterMemory.Protected parameters (AttentionNormalizedMemory.Safe entry)
  copyParameters : AttentionParameterMemory.Protected (entry.parametersAfter parameters entryParameters)
    (MemoryRegions.Disjoint (2*copy.destination) 12288)
  normal : AttentionNormalizationDispatchMemory.Execution copy (copiedParameters entry copy parameters entryParameters copyParameters)
  rope : AttentionRopeNormalizedMemory.Execution normal angle
  gateNormal : ∀ head, AttentionNormalizationDispatchMemory.Safe normal (copy.gate head).base 512
  gateRope : ∀ head, AttentionRopeNormalizedMemory.Safe rope (normal.gate head (gateNormal head)).base 512
  valueCopy : MemoryRegions.Disjoint (2*copy.destination) 12288 entry.affine.valueBuffer.base 2048
  valueNormal : AttentionNormalizationDispatchMemory.Safe normal entry.affine.valueBuffer.base 2048
  valueRope : AttentionRopeNormalizedMemory.Safe rope (normal.valueBuffer valueCopy valueNormal).base 2048

variable {angle : RopeAngles.Inputs}

def Prefix.memory (front : Prefix layer original angle) : ByteMemory.Bytes := front.rope.memory

def Prefix.query (front : Prefix layer original angle) (head : Fin 24) :
    ArrayStorage.BFBuffer ((layer.mixer.heads (layer.inputNorm.forward original) angle).query head) := front.rope.queryBuffer head

def Prefix.key (front : Prefix layer original angle) (head : Fin 4) :
    ArrayStorage.BFBuffer ((layer.mixer.heads (layer.inputNorm.forward original) angle).key head) := front.rope.keyBuffer head

def Prefix.gate (front : Prefix layer original angle) (head : Fin 24) :
    ArrayStorage.BFBuffer ((layer.mixer.heads (layer.inputNorm.forward original) angle).gate head) :=
  front.rope.gate head (front.gateNormal head) (front.gateRope head)

def Prefix.valueBuffer (front : Prefix layer original angle) :
    ArrayStorage.BFBuffer (layer.mixer.projections.v.forward (layer.inputNorm.forward original)) :=
  front.rope.valueBuffer front.valueCopy front.valueNormal front.valueRope

def Prefix.value (front : Prefix layer original angle) (head : Fin 4) :
    ArrayStorage.BFBuffer ((layer.mixer.heads (layer.inputNorm.forward original) angle).value head) :=
  ArrayViews.slice front.valueBuffer (head.val*256) 256 (by have := head.isLt; omega)

theorem Prefix.shared (front : Prefix layer original angle) :
    (∀ head, (front.query head).bytes=front.memory) ∧
    (∀ head, (front.key head).bytes=front.memory) ∧
    (∀ head, (front.gate head).bytes=front.memory) ∧
    (∀ head, (front.value head).bytes=front.memory) :=
  ⟨fun _ => rfl, fun _ => rfl, fun _ => rfl, fun _ => rfl⟩

def Prefix.read (front : Prefix layer original angle) : AttentionHeads.Heads ArrayStorage.BF :=
  ⟨fun head => (front.query head).read, fun head => (front.key head).read,
    fun head => (front.value head).read, fun head => (front.gate head).read⟩

theorem Prefix.read_eq (front : Prefix layer original angle) :
    front.read=layer.mixer.heads (layer.inputNorm.forward original) angle := by
  unfold Prefix.read
  congr 1 <;> funext head i <;> exact ArrayStorage.BFBuffer.read_correct _ i

-- Actual contiguous K/V storage is exposed to KV append without re-encoding.
def Prefix.keySource (front : Prefix layer original angle) :
    KvCopy.Source (layer.mixer.heads (layer.inputNorm.forward original) angle).key where
  bytes := front.memory
  base := front.rope.key.destination
  rowStride := 256
  columnStride := 1
  aligned := front.rope.key.output.aligned
  attached := by
    intro head i
    have attached := front.rope.key.output.attached head i
    have address : front.rope.key.destination+2*(i.val*1+head.val*256)=
        front.rope.key.destination+512*head.val+2*i.val := by omega
    rw [address]
    exact attached

def Prefix.valueSource (front : Prefix layer original angle) :
    KvCopy.Source (layer.mixer.heads (layer.inputNorm.forward original) angle).value where
  bytes := front.memory
  base := front.valueBuffer.base
  rowStride := 256
  columnStride := 1
  aligned := front.valueBuffer.aligned
  attached := by
    intro head i
    have attached := (front.value head).attached i
    have address : front.valueBuffer.base+2*(i.val*1+head.val*256)=
        (front.value head).base+2*i.val := by
      dsimp only [Prefix.value, ArrayViews.slice]
      omega
    rw [address]
    exact attached

def Prefix.Safe (front : Prefix layer original angle) (base size : Nat) : Prop :=
  AttentionNormalizedMemory.Safe front.entry base size ∧
  MemoryRegions.Disjoint (2*front.copy.destination) 12288 base size ∧
  AttentionNormalizationDispatchMemory.Safe front.normal base size ∧ AttentionRopeNormalizedMemory.Safe front.rope base size

theorem Prefix.other_region (front : Prefix layer original angle) {base size : Nat}
    (safe : front.Safe base size) (offset : Nat) (bound : offset<size) :
    front.memory (base+offset)=front.entry.source.lhs.bytes (base+offset) :=
  (front.rope.other_region safe.2.2.2 offset bound).trans
    ((front.normal.other_region safe.2.2.1 offset bound).trans
      ((front.copy.other_region safe.2.1 offset bound).trans (front.entry.other_region safe.1 offset bound)))

def Prefix.residual (front : Prefix layer original angle)
    (safe : front.Safe front.entry.source.lhs.base 10240) : ArrayStorage.BFBuffer original :=
  ArrayFrame.bf front.entry.source.lhs front.memory (front.other_region safe)

def Prefix.oldCache {n : Nat} {cache : Kv.Cache Kv.BF n} (front : Prefix layer original angle)
    (old : KvRegions.Storage cache) (shared : old.memory=front.entry.source.lhs.bytes)
    (keys : front.Safe old.layout.keyBase (KvRegions.bytes n))
    (values : front.Safe old.layout.valueBase (KvRegions.bytes n)) : KvRegions.Storage cache :=
  old.reframe front.memory
    (fun offset bound => (front.other_region keys offset bound).trans (congrFun shared _).symm)
    (fun offset bound => (front.other_region values offset bound).trans (congrFun shared _).symm)

theorem Prefix.oldCache_memory {n : Nat} {cache : Kv.Cache Kv.BF n} (front : Prefix layer original angle)
    (old : KvRegions.Storage cache) (shared : old.memory=front.entry.source.lhs.bytes)
    (keys : front.Safe old.layout.keyBase (KvRegions.bytes n))
    (values : front.Safe old.layout.valueBase (KvRegions.bytes n)) :
    (front.oldCache old shared keys values).memory=front.memory := rfl

attribute [local irreducible] Prefix.keySource Prefix.valueSource Prefix.oldCache Prefix.query Prefix.gate Prefix.residual

structure Execution (layer : ResidualAttention.Layer) {n : Nat} (cache : Kv.Cache Kv.BF n)
    (original : Fin 5120 → ArrayStorage.BF) (angle : RopeAngles.Inputs) where
  front : Prefix layer original angle
  storage : KvRegions.Storage cache
  shared : storage.memory=front.entry.source.lhs.bytes
  storageKeys : front.Safe storage.layout.keyBase (KvRegions.bytes n)
  storageValues : front.Safe storage.layout.valueBase (KvRegions.bytes n)
  residualSafe : front.Safe front.entry.source.lhs.base 10240
  block : AttentionBlockMemory.Execution layer (layer.inputNorm.forward original) original angle
    (front.oldCache storage shared storageKeys storageValues)
  queriesLinked : block.queries=front.query
  gatesLinked : block.gates=front.gate
  keyLinked : block.append.key=front.keySource
  valueLinked : block.append.value=front.valueSource
  residualLinked : block.residual=front.residual residualSafe

variable {n : Nat} {cache : Kv.Cache Kv.BF n} (execution : Execution layer cache original angle)

def Execution.source : ArrayStorage.BFBuffer original := execution.front.entry.source.lhs

def Execution.output : Fin 5120 → ArrayStorage.BF := execution.block.output

def Execution.outputBuffer : ArrayStorage.BFBuffer execution.output := execution.block.outputBuffer

def Execution.afterCache : KvRegions.Storage (layer.cacheAfter original angle cache) := execution.block.afterCache

theorem Execution.output_eq : execution.output=layer.forward original angle cache := execution.block.forward_eq rfl

def Execution.forwardBuffer : ArrayStorage.BFBuffer (layer.forward original angle cache) :=
  ArrayViews.reindex execution.output_eq execution.outputBuffer

theorem Execution.cache_output_shared : execution.afterCache.memory=execution.outputBuffer.bytes := rfl

def Safe (execution : Execution layer cache original angle) (base size : Nat) : Prop :=
  execution.front.Safe base size ∧ AttentionBlockMemory.Safe execution.block base size

theorem Execution.other_region {base size : Nat} (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=execution.front.entry.source.lhs.bytes (base+offset) := by
  have block := execution.block.other_region safe.2 offset bound
  have front := execution.front.other_region safe.1 offset bound
  have heap := execution.front.oldCache_memory execution.storage execution.shared execution.storageKeys execution.storageValues
  exact block.trans ((congrFun heap _).trans front)

def Execution.parametersAfter (parameters : AttentionParameterMemory.Storage layer.mixer execution.front.entry.source.lhs.bytes)
    (safe : AttentionParameterMemory.Protected parameters (Safe execution)) :
    AttentionParameterMemory.Storage layer.mixer execution.outputBuffer.bytes :=
  AttentionParameterMemory.reframe parameters execution.outputBuffer.bytes
    (AttentionParameterMemory.protected_mono parameters (fun _ _ region => execution.other_region region) safe)

def Execution.retainedCaches {tokens : Nat} (stages : List DecodeStage.Stage) (retained : DecodeChain.Caches stages tokens)
    (storage : DecodeFrame.Storage stages retained execution.front.entry.source.lhs.bytes)
    (safe : DecodePreservation.Protected (Safe execution) stages retained execution.front.entry.source.lhs.bytes storage) :
    DecodeFrame.Storage stages retained execution.outputBuffer.bytes :=
  DecodePreservation.reframe (Safe execution) execution.front.entry.source.lhs.bytes execution.outputBuffer.bytes
    (fun _ _ region => execution.other_region region) stages retained storage safe

end Inference.Models.Qwen.ResidualAttentionMemory
