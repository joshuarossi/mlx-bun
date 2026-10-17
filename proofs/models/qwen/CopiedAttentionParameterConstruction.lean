import models.qwen.CopiedAttentionProjectionConstruction
import models.qwen.AttentionParameterMemory
import models.qwen.AttentionGateCopyPreservation
namespace Inference.Models.Qwen.CopiedAttentionParameterConstruction
open Contracts.Mlx Layers
set_option maxRecDepth 10000
variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer input} {live : Nat → Nat → Prop}
  (weights : AttentionAffineConstruction.Weights layer.projections source.bytes)
  (plan : CopiedAttentionProjectionConstruction.Plan layer.projections source weights live)

abbrev phase := CopiedAttentionProjectionConstruction.execution weights plan

theorem phase_source : (phase weights plan).q.source=source :=
  CopiedAttentionProjectionConstruction.query_source weights plan

theorem phase_safe {base size : Nat} (region : live base size) :
    AttentionGateCopyPreservation.PhaseSafe (phase weights plan) base size := by
  change MemoryRegions.Disjoint (CopiedAttentionProjectionConstruction.query weights plan).base 24576 base size ∧
    MemoryRegions.Disjoint (CopiedAttentionProjectionConstruction.copy weights plan).base 12288 base size ∧
    MemoryRegions.Disjoint (CopiedAttentionProjectionConstruction.key weights plan).base 2048 base size ∧
    MemoryRegions.Disjoint (CopiedAttentionProjectionConstruction.value weights plan).base 2048 base size
  rw [CopiedAttentionProjectionConstruction.query_base,CopiedAttentionProjectionConstruction.copy_base,
    CopiedAttentionProjectionConstruction.key_base,CopiedAttentionProjectionConstruction.value_base]
  exact ⟨plan.qSafe _ _ region,plan.copySafe _ _ region,plan.kSafe _ _ region,plan.vSafe _ _ region⟩

theorem phase_frame {base size : Nat} (region : live base size) (offset : Nat) (bound : offset<size) :
    (phase weights plan).memory (base+offset)=source.bytes (base+offset) := by
  have frame := AttentionGateCopyPreservation.phase_frame (phase_safe weights plan region) offset bound
  rw [phase_source] at frame
  exact frame

structure QueryAllocation (weights : AttentionAffineConstruction.Weights layer.projections source.bytes)
    (plan : CopiedAttentionProjectionConstruction.Plan layer.projections source weights live) where
  destination : Nat
  bounded : 2*destination+12288≤2^64
  query : MemoryRegions.Disjoint (2*destination) 12288 (phase weights plan).queryGateBuffer.base 24576
  gate : MemoryRegions.Disjoint (2*destination) 12288 (phase weights plan).gateCopy.base 12288
  safe : ∀ base size, live base size → MemoryRegions.Disjoint (2*destination) 12288 base size

variable (allocation : QueryAllocation weights plan)
def queryCopy : AttentionGateCopyQueryMemory.Execution (phase weights plan) :=
  AttentionGateCopyQueryMemory.canonical (phase weights plan) allocation.destination allocation.bounded allocation.query allocation.gate

theorem query_frame {base size : Nat} (region : live base size) (offset : Nat) (bound : offset<size) :
    (queryCopy weights plan allocation).copy.memory (base+offset)=source.bytes (base+offset) :=
  ((queryCopy weights plan allocation).other_region (allocation.safe _ _ region) offset bound).trans
    (phase_frame weights plan region offset bound)

theorem reframe_bases {memory : ByteMemory.Bytes} (storage : AttentionParameterMemory.Storage layer memory)
    (after : ByteMemory.Bytes)
    (same : AttentionParameterMemory.Protected storage (fun base size => ∀ offset<size, after (base+offset)=memory (base+offset))) :
    (AttentionParameterMemory.reframe storage after same).queryScale.base=storage.queryScale.base ∧
      (AttentionParameterMemory.reframe storage after same).keyScale.base=storage.keyScale.base := ⟨rfl,rfl⟩

variable (original : AttentionParameterMemory.Storage layer source.bytes)
  (protectedParameters : AttentionParameterMemory.Protected original live)
def parameters : AttentionParameterMemory.Storage layer (queryCopy weights plan allocation).copy.memory :=
  AttentionParameterMemory.reframe original _
    (AttentionParameterMemory.protected_mono original (fun _ _ region => query_frame weights plan allocation region) protectedParameters)

theorem parameters_protected (property : Nat → Nat → Prop) :
    AttentionParameterMemory.Protected (parameters weights plan allocation original protectedParameters) property ↔
      AttentionParameterMemory.Protected original property :=
  AttentionParameterMemory.reframe_protected original _ _ property

theorem query_scale_base : (parameters weights plan allocation original protectedParameters).queryScale.base=original.queryScale.base := (reframe_bases original _ _).1
theorem key_scale_base : (parameters weights plan allocation original protectedParameters).keyScale.base=original.keyScale.base := (reframe_bases original _ _).2
end Inference.Models.Qwen.CopiedAttentionParameterConstruction
