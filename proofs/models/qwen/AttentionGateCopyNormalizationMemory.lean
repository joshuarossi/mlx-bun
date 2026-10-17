import models.qwen.AttentionProjectionHandoff
import models.qwen.AttentionGateCopyQueryMemory
import kernels.RmsHeadsMemory

namespace Inference.Models.Qwen.AttentionGateCopyNormalizationMemory
open Contracts.Mlx Kernels
set_option maxRecDepth 10000
attribute [local irreducible] RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor Copy2DMemory.programs MultiOutputWrites.programs ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {phase : AttentionGateCopyKvMemory.Execution layer.projections input}

def queryInput (copy : AttentionGateCopyQueryMemory.Execution phase)
    (parameters : AttentionParameterMemory.Storage layer copy.copy.memory) :
    RmsHeadsMemory.Input (layer.projections.forward input).query layer.preparation.qNorm.weight (2*copy.destination) where
  source := ⟨copy.copy.memory, copy.query, fun _ => rfl, by
    intro head
    dsimp [AttentionGateCopyQueryMemory.Execution.query, RmsHeadReads.layout]
    omega⟩
  weight := parameters.queryScale
  shared := parameters.queryShared

abbrev QueryExecution (copy : AttentionGateCopyQueryMemory.Execution phase)
    (parameters : AttentionParameterMemory.Storage layer copy.copy.memory) :=
  RmsHeadsMemory.Execution (queryInput copy parameters) layer.preparation.qNorm.platform AttentionHeads.width Blocks.eps

def parametersAfterQuery (copy : AttentionGateCopyQueryMemory.Execution phase)
    (parameters : AttentionParameterMemory.Storage layer copy.copy.memory)
    (query : QueryExecution copy parameters)
    (safe : AttentionParameterMemory.Protected parameters (MemoryRegions.Disjoint (2*copy.destination) 12288)) :
    AttentionParameterMemory.Storage layer query.stores.memory :=
  AttentionParameterMemory.reframe parameters query.stores.memory
    (AttentionParameterMemory.protected_mono parameters (fun _ _ separate => query.other_region separate) safe)

def keyInput (copy : AttentionGateCopyQueryMemory.Execution phase)
    (parameters : AttentionParameterMemory.Storage layer copy.copy.memory)
    (query : QueryExecution copy parameters)
    (keySafe : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.keyBuffer.base 2048)
    (scaleSafe : MemoryRegions.Disjoint (2*copy.destination) 12288 parameters.keyScale.base 512) :
    RmsHeadsMemory.Input (layer.projections.forward input).key layer.preparation.kNorm.weight phase.keyBuffer.base where
  source := ⟨query.stores.memory, (fun head => ArrayViews.slice
      (ArrayFrame.bf (copy.keyBuffer keySafe) query.stores.memory (query.other_region keySafe))
      (head.val*256) 256 (by have := head.isLt; omega)), fun _ => rfl, by
        intro head
        dsimp [ArrayViews.slice, ArrayFrame.bf, AttentionGateCopyQueryMemory.Execution.keyBuffer, RmsHeadReads.layout]
        omega⟩
  weight := ArrayFrame.bf parameters.keyScale query.stores.memory
    (fun offset bound => (query.other_region scaleSafe offset bound).trans (congrFun parameters.keyShared _).symm)
  shared := rfl

structure Execution (copy : AttentionGateCopyQueryMemory.Execution phase)
    (parameters : AttentionParameterMemory.Storage layer copy.copy.memory) where
  query : QueryExecution copy parameters
  keySafe : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.keyBuffer.base 2048
  scaleSafe : MemoryRegions.Disjoint (2*copy.destination) 12288 parameters.keyScale.base 512
  key : RmsHeadsMemory.Execution (keyInput copy parameters query keySafe scaleSafe)
    layer.preparation.kNorm.platform AttentionHeads.width Blocks.eps

variable {copy : AttentionGateCopyQueryMemory.Execution phase}
  {parameters : AttentionParameterMemory.Storage layer copy.copy.memory}

def Execution.memory (execution : Execution copy parameters) : ByteMemory.Bytes := execution.key.stores.memory

def Safe (_execution : Execution copy parameters) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint (2*copy.destination) 12288 base size ∧
  MemoryRegions.Disjoint phase.keyBuffer.base 2048 base size

theorem Execution.other_region (execution : Execution copy parameters) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.memory (base+offset)=copy.copy.memory (base+offset) :=
  (execution.key.other_region safe.2 offset bound).trans (execution.query.other_region safe.1 offset bound)

def Execution.queryBefore (execution : Execution copy parameters) (head : Fin 24) :
    ArrayStorage.BFBuffer (layer.preparation.qNorm.forward ((layer.projections.forward input).query head)) :=
  execution.query.forwardBuffer head layer.preparation.qNorm.scratch layer.preparation.qNorm.base

theorem Execution.queryBefore_base (execution : Execution copy parameters) (head : Fin 24) :
    (execution.queryBefore head).base=2*copy.destination+head.val*512 := by
  unfold Execution.queryBefore RmsHeadsMemory.Execution.forwardBuffer
  rw [ArrayViews.reindex_base]
  rfl

theorem Execution.queryBefore_bytes (execution : Execution copy parameters) (head : Fin 24) :
    (execution.queryBefore head).bytes=execution.query.stores.memory := by
  unfold Execution.queryBefore RmsHeadsMemory.Execution.forwardBuffer
  rw [ArrayViews.reindex_bytes]
  rfl

attribute [local irreducible] Execution.queryBefore

def Execution.queryBuffer (execution : Execution copy parameters) (head : Fin 24) :
    ArrayStorage.BFBuffer (layer.preparation.qNorm.forward ((layer.projections.forward input).query head)) :=
  ArrayFrame.bf (execution.queryBefore head) execution.memory (by
    intro offset bound
    have separate : MemoryRegions.Disjoint phase.keyBuffer.base 2048 (execution.queryBefore head).base 512 := by
      have := head.isLt
      have safe := execution.keySafe
      rw [execution.queryBefore_base]
      unfold MemoryRegions.Disjoint at safe ⊢
      omega
    exact (execution.key.other_region separate offset bound).trans
      (congrFun (execution.queryBefore_bytes head) _).symm)

def Execution.keyBuffer (execution : Execution copy parameters) (head : Fin 4) :
    ArrayStorage.BFBuffer (layer.preparation.kNorm.forward ((layer.projections.forward input).key head)) :=
  execution.key.forwardBuffer head layer.preparation.kNorm.scratch layer.preparation.kNorm.base

def Execution.gate (execution : Execution copy parameters) (head : Fin 24)
    (safe : Safe execution (copy.gate head).base 512) :
    ArrayStorage.BFBuffer ((layer.projections.forward input).gate head) :=
  ArrayFrame.bf (copy.gate head) execution.memory (execution.other_region safe)

def Execution.valueBuffer (execution : Execution copy parameters)
    (copySafe : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.valueBuffer.base 2048)
    (safe : Safe execution phase.valueBuffer.base 2048) : ArrayStorage.BFBuffer (layer.projections.v.forward input) :=
  ArrayFrame.bf (copy.valueBuffer copySafe) execution.memory (execution.other_region safe)

def Execution.parametersAfter (execution : Execution copy parameters)
    (safe : AttentionParameterMemory.Protected parameters (Safe execution)) :
    AttentionParameterMemory.Storage layer execution.memory :=
  AttentionParameterMemory.reframe parameters execution.memory
    (AttentionParameterMemory.protected_mono parameters (fun _ _ region => execution.other_region region) safe)

def canonical (copy : AttentionGateCopyQueryMemory.Execution phase)
    (parameters : AttentionParameterMemory.Storage layer copy.copy.memory)
    (queryDispatch : layer.preparation.qNorm.platform.groups=2)
    (keyDispatch : layer.preparation.kNorm.platform.groups=2)
    (queryWeight : MemoryRegions.Disjoint (2*copy.destination) 12288 parameters.queryScale.base 512)
    (keySafe : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.keyBuffer.base 2048)
    (scaleSafe : MemoryRegions.Disjoint (2*copy.destination) 12288 parameters.keyScale.base 512)
    (keyWeight : MemoryRegions.Disjoint phase.keyBuffer.base 2048 parameters.keyScale.base 512) : Execution copy parameters :=
  let query := RmsHeadsMemory.canonical (queryInput copy parameters) _ _ _ queryDispatch
    ⟨by omega, by have := copy.bounded; omega⟩ queryWeight
  ⟨query, keySafe, scaleSafe, RmsHeadsMemory.canonical (keyInput copy parameters query keySafe scaleSafe) _ _ _
    keyDispatch ⟨phase.keyBuffer.aligned, phase.keyBuffer.bounded⟩ keyWeight⟩

def Execution.retainedCaches {n : Nat} (execution : Execution copy parameters)
    (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages n)
    (storage : DecodeFrame.Storage stages cache copy.copy.memory)
    (safe : DecodePreservation.Protected (Safe execution) stages cache copy.copy.memory storage) :
    DecodeFrame.Storage stages cache execution.memory :=
  DecodePreservation.reframe (Safe execution) copy.copy.memory execution.memory
    (fun _ _ region => execution.other_region region) stages cache storage safe

def Execution.residualAfter {original : Fin 5120 → ArrayStorage.BF} (execution : Execution copy parameters)
    (residual : ArrayStorage.BFBuffer original) (shared : residual.bytes=copy.copy.memory)
    (safe : Safe execution residual.base 10240) : ArrayStorage.BFBuffer original :=
  ArrayFrame.bf residual execution.memory
    (fun offset bound => (execution.other_region safe offset bound).trans (congrFun shared _).symm)

def Execution.read (execution : Execution copy parameters)
    (gateSafe : ∀ head, Safe execution (copy.gate head).base 512)
    (copyValueSafe : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.valueBuffer.base 2048)
    (valueSafe : Safe execution phase.valueBuffer.base 2048) : AttentionHeads.Heads ArrayStorage.BF where
  query head := (execution.queryBuffer head).read
  key head := (execution.keyBuffer head).read
  value head := (ArrayViews.slice (execution.valueBuffer copyValueSafe valueSafe) (head.val*256) 256
    (by have := head.isLt; omega)).read
  gate head := (execution.gate head (gateSafe head)).read

theorem Execution.read_eq (execution : Execution copy parameters)
    (gateSafe : ∀ head, Safe execution (copy.gate head).base 512)
    (copyValueSafe : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.valueBuffer.base 2048)
    (valueSafe : Safe execution phase.valueBuffer.base 2048) :
    execution.read gateSafe copyValueSafe valueSafe=layer.preparation.normalized (layer.projections.forward input) := by
  unfold Execution.read AttentionHeads.Preparation.normalized
  congr 1 <;> funext head i <;> exact ArrayStorage.BFBuffer.read_correct _ i

theorem Execution.shared (execution : Execution copy parameters) :
    (∀ head, (execution.queryBuffer head).bytes=execution.memory) ∧
    (∀ head, (execution.keyBuffer head).bytes=execution.memory) := by
  refine ⟨fun _ => rfl, fun head => ?_⟩
  dsimp only [Execution.keyBuffer, RmsHeadsMemory.Execution.forwardBuffer]
  rw [ArrayViews.reindex_bytes]
  rfl

end Inference.Models.Qwen.AttentionGateCopyNormalizationMemory
