import models.qwen.AttentionNormalizationMemory
import kernels.RmsHeadsDispatchMemory

namespace Inference.Models.Qwen.AttentionNormalizationDispatchMemory
open Contracts.Mlx Kernels
set_option maxRecDepth 10000
attribute [local irreducible] RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor
  Copy2DMemory.programs MultiOutputWrites.programs ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {phase : AttentionAffineMemory.Execution layer.projections input}

abbrev queryInput := @AttentionNormalizationMemory.queryInput

abbrev QueryExecution (copy : AttentionQueryMemory.Execution phase)
    (parameters : AttentionParameterMemory.Storage layer copy.copy.memory) :=
  RmsHeadsDispatchMemory.Execution (queryInput copy parameters) layer.preparation.qNorm.platform AttentionHeads.width Blocks.eps

def keyInput (copy : AttentionQueryMemory.Execution phase)
    (parameters : AttentionParameterMemory.Storage layer copy.copy.memory) (query : QueryExecution copy parameters)
    (copyKey : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.keyBuffer.base 2048)
    (keySafe : MemoryRegions.Disjoint query.base 12288 phase.keyBuffer.base 2048)
    (scaleSafe : MemoryRegions.Disjoint query.base 12288 parameters.keyScale.base 512) :
    RmsHeadsMemory.Input (layer.projections.forward input).key layer.preparation.kNorm.weight phase.keyBuffer.base where
  source := ⟨query.memory, (fun head => ArrayViews.slice
      (ArrayFrame.bf (copy.keyBuffer copyKey) query.memory (query.other_region keySafe))
      (head.val*256) 256 (by have := head.isLt; omega)), fun _ => rfl, by
        intro head
        dsimp [ArrayViews.slice, ArrayFrame.bf, AttentionQueryMemory.Execution.keyBuffer, RmsHeadReads.layout]
        omega⟩
  weight := ArrayFrame.bf parameters.keyScale query.memory
    (fun offset bound => (query.other_region scaleSafe offset bound).trans (congrFun parameters.keyShared _).symm)
  shared := rfl

structure Execution (copy : AttentionQueryMemory.Execution phase)
    (parameters : AttentionParameterMemory.Storage layer copy.copy.memory) where
  query : QueryExecution copy parameters
  copyKey : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.keyBuffer.base 2048
  keySafe : MemoryRegions.Disjoint query.base 12288 phase.keyBuffer.base 2048
  scaleSafe : MemoryRegions.Disjoint query.base 12288 parameters.keyScale.base 512
  key : RmsHeadsDispatchMemory.Execution (keyInput copy parameters query copyKey keySafe scaleSafe)
    layer.preparation.kNorm.platform AttentionHeads.width Blocks.eps
  outputSafe : MemoryRegions.Disjoint key.base 2048 query.base 12288

variable {copy : AttentionQueryMemory.Execution phase}
  {parameters : AttentionParameterMemory.Storage layer copy.copy.memory}

def Execution.memory (execution : Execution copy parameters) : ByteMemory.Bytes := execution.key.memory

def Execution.queryBase (execution : Execution copy parameters) : Nat := execution.query.base

def Execution.keyBase (execution : Execution copy parameters) : Nat := execution.key.base

def Safe (execution : Execution copy parameters) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint execution.queryBase 12288 base size ∧ MemoryRegions.Disjoint execution.keyBase 2048 base size

theorem Execution.other_region (execution : Execution copy parameters) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.memory (base+offset)=copy.copy.memory (base+offset) :=
  (execution.key.other_region safe.2 offset bound).trans (execution.query.other_region safe.1 offset bound)

def Execution.queryBefore (execution : Execution copy parameters) (head : Fin 24) :
    ArrayStorage.BFBuffer (layer.preparation.qNorm.forward ((layer.projections.forward input).query head)) :=
  execution.query.forwardBuffer head layer.preparation.qNorm.scratch layer.preparation.qNorm.base

theorem Execution.queryBefore_base (execution : Execution copy parameters) (head : Fin 24) :
    (execution.queryBefore head).base=execution.queryBase+head.val*512 := execution.query.forward_base head _ _

theorem Execution.queryBefore_bytes (execution : Execution copy parameters) (head : Fin 24) :
    (execution.queryBefore head).bytes=execution.query.memory := execution.query.forward_bytes head _ _

attribute [local irreducible] Execution.queryBefore

def Execution.queryBuffer (execution : Execution copy parameters) (head : Fin 24) :
    ArrayStorage.BFBuffer (layer.preparation.qNorm.forward ((layer.projections.forward input).query head)) :=
  ArrayFrame.bf (execution.queryBefore head) execution.memory (by
    intro offset bound
    have separate : MemoryRegions.Disjoint execution.keyBase 2048 (execution.queryBefore head).base 512 := by
      have h := head.isLt
      have safe := execution.outputSafe
      rw [execution.queryBefore_base]
      unfold Execution.queryBase Execution.keyBase MemoryRegions.Disjoint at *
      omega
    exact (execution.key.other_region separate offset bound).trans (congrFun (execution.queryBefore_bytes head) _).symm)

def Execution.keyBuffer (execution : Execution copy parameters) (head : Fin 4) :
    ArrayStorage.BFBuffer (layer.preparation.kNorm.forward ((layer.projections.forward input).key head)) :=
  execution.key.forwardBuffer head layer.preparation.kNorm.scratch layer.preparation.kNorm.base

theorem Execution.query_base (execution : Execution copy parameters) (head : Fin 24) :
    (execution.queryBuffer head).base=execution.queryBase+head.val*512 := execution.queryBefore_base head

theorem Execution.key_base (execution : Execution copy parameters) (head : Fin 4) :
    (execution.keyBuffer head).base=execution.keyBase+head.val*512 := execution.key.forward_base head _ _

theorem Execution.shared (execution : Execution copy parameters) :
    (∀ head, (execution.queryBuffer head).bytes=execution.memory) ∧
    (∀ head, (execution.keyBuffer head).bytes=execution.memory) :=
  ⟨fun _ => rfl, fun head => execution.key.forward_bytes head _ _⟩

def Execution.gate (execution : Execution copy parameters) (head : Fin 24)
    (safe : Safe execution (copy.gate head).base 512) : ArrayStorage.BFBuffer ((layer.projections.forward input).gate head) :=
  ArrayFrame.bf (copy.gate head) execution.memory (execution.other_region safe)

def Execution.valueBuffer (execution : Execution copy parameters)
    (copySafe : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.valueBuffer.base 2048)
    (safe : Safe execution phase.valueBuffer.base 2048) : ArrayStorage.BFBuffer (layer.projections.v.forward input) :=
  ArrayFrame.bf (copy.valueBuffer copySafe) execution.memory (execution.other_region safe)

def Execution.parametersAfter (execution : Execution copy parameters)
    (safe : AttentionParameterMemory.Protected parameters (Safe execution)) : AttentionParameterMemory.Storage layer execution.memory :=
  AttentionParameterMemory.reframe parameters execution.memory
    (AttentionParameterMemory.protected_mono parameters (fun _ _ region => execution.other_region region) safe)

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

def queryCanonical (copy : AttentionQueryMemory.Execution phase)
    (parameters : AttentionParameterMemory.Storage layer copy.copy.memory)
    (dispatch : layer.preparation.qNorm.platform.groups=2)
    (allocation : RmsHeadsDispatchMemory.Allocation (queryInput copy parameters)) : QueryExecution copy parameters :=
  RmsHeadsDispatchMemory.canonical _ _ _ _ dispatch allocation

def canonical (copy : AttentionQueryMemory.Execution phase)
    (parameters : AttentionParameterMemory.Storage layer copy.copy.memory)
    (queryDispatch : layer.preparation.qNorm.platform.groups=2) (keyDispatch : layer.preparation.kNorm.platform.groups=2)
    (queryAllocation : RmsHeadsDispatchMemory.Allocation (queryInput copy parameters))
    (copyKey : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.keyBuffer.base 2048)
    (keySafe : MemoryRegions.Disjoint (queryCanonical copy parameters queryDispatch queryAllocation).base 12288 phase.keyBuffer.base 2048)
    (scaleSafe : MemoryRegions.Disjoint (queryCanonical copy parameters queryDispatch queryAllocation).base 12288 parameters.keyScale.base 512)
    (keyAllocation : RmsHeadsDispatchMemory.Allocation (keyInput copy parameters
      (queryCanonical copy parameters queryDispatch queryAllocation) copyKey keySafe scaleSafe))
    (outputSafe : MemoryRegions.Disjoint keyAllocation.base 2048
      (queryCanonical copy parameters queryDispatch queryAllocation).base 12288) : Execution copy parameters where
  query := queryCanonical copy parameters queryDispatch queryAllocation
  copyKey := copyKey
  keySafe := keySafe
  scaleSafe := scaleSafe
  key := RmsHeadsDispatchMemory.canonical _ _ _ _ keyDispatch keyAllocation
  outputSafe := by rw [RmsHeadsDispatchMemory.canonical_base]; exact outputSafe

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

end Inference.Models.Qwen.AttentionNormalizationDispatchMemory
