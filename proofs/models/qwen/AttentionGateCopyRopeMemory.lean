import models.qwen.AttentionGateCopyNormalizationMemory
import kernels.attention.RopeRowsDispatchMemory

namespace Inference.Models.Qwen.AttentionGateCopyRopeMemory
open Contracts.Mlx Kernels Kernels.Attention
set_option maxRecDepth 10000
set_option maxHeartbeats 200000
attribute [local irreducible] RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor
  Copy2DMemory.programs RopeRowsMemory.programs MultiOutputWrites.programs
  AttentionGateCopyNormalizationMemory.Execution.queryBefore
  AttentionHeads.Norm.forward AttentionHeads.Projections.forward

variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {phase : AttentionGateCopyKvMemory.Execution layer.projections input}
  {copy : AttentionGateCopyQueryMemory.Execution phase}
  {parameters : AttentionParameterMemory.Storage layer copy.copy.memory}


theorem key_base (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) (head : Fin 4) :
    (normal.keyBuffer head).base=phase.keyBuffer.base+head.val*512 := by
  unfold AttentionGateCopyNormalizationMemory.Execution.keyBuffer RmsHeadsMemory.Execution.forwardBuffer
  rw [ArrayViews.reindex_base]
  rfl

def queryInput (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) :
    RopeRowsMemory.Input (layer.preparation.normalized (layer.projections.forward input)).query (2*copy.destination) where
  memory := normal.memory
  aligned := by omega
  bounded := copy.bounded
  attached := by
    intro head i
    have prior := (normal.queryBefore head).attached i
    rw [normal.queryBefore_base head,normal.queryBefore_bytes head] at prior
    have separate : MemoryRegions.Disjoint phase.keyBuffer.base 2048 (2*copy.destination+head.val*512) 512 := by
      have hb := head.isLt
      have safe := normal.keySafe
      unfold MemoryRegions.Disjoint at safe ⊢
      omega
    have same := normal.key.other_region separate
    have result := ArrayFrame.half_congr normal.query.stores.memory normal.memory
      (2*copy.destination+head.val*512) 512 (2*i.val) same (by have := i.isLt; omega)
    rw [show 2*copy.destination+head.val*512+2*i.val=2*copy.destination+512*head.val+2*i.val by omega] at result prior
    exact result.trans prior

def keyNormalized (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) :
    RopeRowsMemory.Input (layer.preparation.normalized (layer.projections.forward input)).key phase.keyBuffer.base where
  memory := normal.memory
  aligned := phase.keyBuffer.aligned
  bounded := phase.keyBuffer.bounded
  attached := by
    intro head i
    have attached := (normal.keyBuffer head).attached i
    rw [key_base normal head,(normal.shared).2 head] at attached
    rw [show phase.keyBuffer.base+head.val*512+2*i.val=phase.keyBuffer.base+512*head.val+2*i.val by omega] at attached
    exact attached


abbrev QueryExecution (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) (angle : RopeAngles.Inputs) :=
  RopeRowsDispatchMemory.Execution layer.preparation.rotation (queryInput normal)
    (fun _ => RopeAngles.value layer.preparation.angles angle)

def keyInput (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) (angle : RopeAngles.Inputs) (query : QueryExecution normal angle)
    (safe : MemoryRegions.Disjoint query.destination 12288 phase.keyBuffer.base 2048) :
    RopeRowsMemory.Input (layer.preparation.normalized (layer.projections.forward input)).key phase.keyBuffer.base where
  memory := query.output.memory
  aligned := phase.keyBuffer.aligned
  bounded := phase.keyBuffer.bounded
  attached := by
    intro head i
    have bound := head.isLt
    have index := i.isLt
    have same : ∀ offset < 2048, query.output.memory (phase.keyBuffer.base+offset)=normal.memory (phase.keyBuffer.base+offset) := by
      intro offset inside
      apply query.frame
      rcases safe with h|h <;> omega
    rw [show phase.keyBuffer.base+512*head.val+2*i.val=phase.keyBuffer.base+(512*head.val+2*i.val) by omega]
    rw [ArrayFrame.half_congr normal.memory query.output.memory phase.keyBuffer.base 2048 _ same (by omega)]
    have attached := (keyNormalized normal).attached head i
    change HalfMemory.load normal.memory (phase.keyBuffer.base+512*head.val+2*i.val)=_ at attached
    rw [Nat.add_assoc] at attached
    exact attached

structure Execution (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) (angle : RopeAngles.Inputs) where
  query : QueryExecution normal angle
  keySafe : MemoryRegions.Disjoint query.destination 12288 phase.keyBuffer.base 2048
  key : RopeRowsDispatchMemory.Execution layer.preparation.rotation (keyInput normal angle query keySafe)
    (fun _ => RopeAngles.value layer.preparation.angles angle)
  outputSafe : MemoryRegions.Disjoint key.destination 2048 query.destination 12288

variable {normal : AttentionGateCopyNormalizationMemory.Execution copy parameters} {angle : RopeAngles.Inputs}

def Execution.memory (execution : Execution normal angle) : ByteMemory.Bytes := execution.key.output.memory

def Safe (execution : Execution normal angle) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint execution.query.destination 12288 base size ∧
  MemoryRegions.Disjoint execution.key.destination 2048 base size

theorem Execution.other_region (execution : Execution normal angle) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.memory (base+offset)=normal.memory (base+offset) := by
  apply (execution.key.frame _ ?_).trans (execution.query.frame _ ?_)
  · rcases safe.2 with h|h <;> omega
  · rcases safe.1 with h|h <;> omega

def Execution.queryBuffer (execution : Execution normal angle) (head : Fin 24) :
    ArrayStorage.BFBuffer ((layer.preparation.forward (layer.projections.forward input) angle).query head) :=
  ArrayFrame.bf (execution.query.output.buffer head) execution.memory (by
    intro offset bound
    have hb := head.isLt
    apply execution.key.frame
    change execution.query.destination+512*head.val+offset<execution.key.destination ∨
      execution.key.destination+2048≤execution.query.destination+512*head.val+offset
    rcases execution.outputSafe with h|h <;> omega)

def Execution.keyBuffer (execution : Execution normal angle) (head : Fin 4) :
    ArrayStorage.BFBuffer ((layer.preparation.forward (layer.projections.forward input) angle).key head) :=
  execution.key.output.buffer head

theorem Execution.shared (execution : Execution normal angle) :
    (∀ head, (execution.queryBuffer head).bytes=execution.memory) ∧
    (∀ head, (execution.keyBuffer head).bytes=execution.memory) := ⟨fun _ => rfl,fun _ => rfl⟩

def Execution.preserveBF {values : Fin n → ArrayStorage.BF} (execution : Execution normal angle)
    (buffer : ArrayStorage.BFBuffer values) (shared : buffer.bytes=normal.memory)
    (safe : Safe execution buffer.base (2*n)) : ArrayStorage.BFBuffer values :=
  ArrayFrame.bf buffer execution.memory (fun offset bound =>
    (execution.other_region safe offset bound).trans (congrFun shared _).symm)

def Execution.gate (execution : Execution normal angle) (head : Fin 24)
    (normalSafe : AttentionGateCopyNormalizationMemory.Safe normal (copy.gate head).base 512)
    (safe : Safe execution (normal.gate head normalSafe).base 512) :
    ArrayStorage.BFBuffer ((layer.projections.forward input).gate head) :=
  execution.preserveBF (normal.gate head normalSafe) rfl safe

def Execution.valueBuffer (execution : Execution normal angle)
    (copySafe : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.valueBuffer.base 2048)
    (normalSafe : AttentionGateCopyNormalizationMemory.Safe normal phase.valueBuffer.base 2048)
    (safe : Safe execution (normal.valueBuffer copySafe normalSafe).base 2048) :
    ArrayStorage.BFBuffer (layer.projections.v.forward input) :=
  execution.preserveBF (normal.valueBuffer copySafe normalSafe) rfl safe

def Execution.parametersAfter (execution : Execution normal angle)
    (storage : AttentionParameterMemory.Storage layer normal.memory)
    (safe : AttentionParameterMemory.Protected storage (Safe execution)) : AttentionParameterMemory.Storage layer execution.memory :=
  AttentionParameterMemory.reframe storage execution.memory
    (AttentionParameterMemory.protected_mono storage (fun _ _ region => execution.other_region region) safe)

def Execution.retainedCaches {n : Nat} (execution : Execution normal angle)
    (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages n)
    (storage : DecodeFrame.Storage stages cache normal.memory)
    (safe : DecodePreservation.Protected (Safe execution) stages cache normal.memory storage) :
    DecodeFrame.Storage stages cache execution.memory :=
  DecodePreservation.reframe (Safe execution) normal.memory execution.memory
    (fun _ _ region => execution.other_region region) stages cache storage safe

def queryCanonical (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) (angle : RopeAngles.Inputs)
    (preparation : RopeRowsDispatchMemory.Preparation (queryInput normal)) : QueryExecution normal angle :=
  RopeRowsDispatchMemory.Execution.fromPreparation layer.preparation.rotation (queryInput normal)
    (fun _ => RopeAngles.value layer.preparation.angles angle) preparation

def canonical (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) (angle : RopeAngles.Inputs)
    (queryPreparation : RopeRowsDispatchMemory.Preparation (queryInput normal))
    (keySafe : MemoryRegions.Disjoint queryPreparation.destination 12288 phase.keyBuffer.base 2048)
    (keyPreparation : RopeRowsDispatchMemory.Preparation (keyInput normal angle (queryCanonical normal angle queryPreparation) keySafe))
    (outputSafe : MemoryRegions.Disjoint keyPreparation.destination 2048 queryPreparation.destination 12288) : Execution normal angle :=
  let query := queryCanonical normal angle queryPreparation
  ⟨query,keySafe,RopeRowsDispatchMemory.Execution.fromPreparation layer.preparation.rotation
    (keyInput normal angle query keySafe) (fun _ => RopeAngles.value layer.preparation.angles angle) keyPreparation,outputSafe⟩

-- Both normalized allocations can be donated directly. No allocation or
-- copy instruction is inserted; rotations update those existing heaps.
def donation (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) (angle : RopeAngles.Inputs) : Execution normal angle :=
  canonical normal angle .donation normal.keySafe .donation (MemoryRegions.disjoint_symm normal.keySafe)

def Execution.read (execution : Execution normal angle)
    (normalGateSafe : ∀ head, AttentionGateCopyNormalizationMemory.Safe normal (copy.gate head).base 512)
    (gateSafe : ∀ head, Safe execution (normal.gate head (normalGateSafe head)).base 512)
    (copyValueSafe : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.valueBuffer.base 2048)
    (normalValueSafe : AttentionGateCopyNormalizationMemory.Safe normal phase.valueBuffer.base 2048)
    (valueSafe : Safe execution (normal.valueBuffer copyValueSafe normalValueSafe).base 2048) : AttentionHeads.Heads ArrayStorage.BF where
  query head := (execution.queryBuffer head).read
  key head := (execution.keyBuffer head).read
  value head := (ArrayViews.slice (execution.valueBuffer copyValueSafe normalValueSafe valueSafe) (head.val*256) 256
    (by have := head.isLt; omega)).read
  gate head := (execution.gate head (normalGateSafe head) (gateSafe head)).read

theorem Execution.read_eq (execution : Execution normal angle)
    (normalGateSafe : ∀ head, AttentionGateCopyNormalizationMemory.Safe normal (copy.gate head).base 512)
    (gateSafe : ∀ head, Safe execution (normal.gate head (normalGateSafe head)).base 512)
    (copyValueSafe : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.valueBuffer.base 2048)
    (normalValueSafe : AttentionGateCopyNormalizationMemory.Safe normal phase.valueBuffer.base 2048)
    (valueSafe : Safe execution (normal.valueBuffer copyValueSafe normalValueSafe).base 2048) :
    execution.read normalGateSafe gateSafe copyValueSafe normalValueSafe valueSafe=
      layer.preparation.forward (layer.projections.forward input) angle := by
  unfold Execution.read
  congr 1
  · funext head i; exact ArrayStorage.BFBuffer.read_correct _ i
  · funext head i; exact ArrayStorage.BFBuffer.read_correct _ i
  · funext head i
    rw [ArrayStorage.BFBuffer.read_correct]
    unfold AttentionHeads.Projections.forward
    rfl
  · funext head i; exact ArrayStorage.BFBuffer.read_correct _ i

end Inference.Models.Qwen.AttentionGateCopyRopeMemory
