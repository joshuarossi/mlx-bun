import models.qwen.CopiedAttentionProjectionAllocation
import models.qwen.AttentionGateCopyNormalizationMemory
namespace Inference.Models.Qwen.CopiedAttentionNormalizationAllocation
open Contracts.Mlx Layers Kernels
set_option maxRecDepth 10000
variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer input}
  (weights : AttentionAffineConstruction.Weights layer.projections source.bytes)
  (w : CopiedAttentionProjectionAllocation.Workspace source weights)
  (original : AttentionParameterMemory.Storage layer source.bytes)
  (protectedParameters : AttentionParameterMemory.Protected original
    (MemoryRegions.Disjoint w.base CopiedAttentionProjectionAllocation.bytes))

abbrev phase := CopiedAttentionProjectionConstruction.execution weights (CopiedAttentionProjectionAllocation.plan w)
abbrev copy := CopiedAttentionParameterConstruction.queryCopy weights
  (CopiedAttentionProjectionAllocation.plan w) (CopiedAttentionProjectionAllocation.queryAllocation w)
abbrev parameters := CopiedAttentionParameterConstruction.parameters weights
  (CopiedAttentionProjectionAllocation.plan w) (CopiedAttentionProjectionAllocation.queryAllocation w) original protectedParameters

theorem query_base : 2*(copy weights w).destination=w.base+40960 := by
  change 2*((w.base+40960)/2)=w.base+40960
  have := w.aligned
  omega

theorem key_base : (phase weights w).keyBuffer.base=w.base+36864 :=
  (AttentionAffineConstruction.forward_base _).trans
    (CopiedAttentionProjectionConstruction.key_base weights (CopiedAttentionProjectionAllocation.plan w))

theorem parameter_regions : AttentionParameterMemory.Protected (parameters weights w original protectedParameters)
    (MemoryRegions.Disjoint w.base CopiedAttentionProjectionAllocation.bytes) :=
  (CopiedAttentionParameterConstruction.parameters_protected weights _ _ original protectedParameters _).mpr protectedParameters

private theorem query_separate {base size : Nat}
    (separate : MemoryRegions.Disjoint w.base CopiedAttentionProjectionAllocation.bytes base size) :
    MemoryRegions.Disjoint (2*(copy weights w).destination) 12288 base size := by
  rw [query_base]
  exact CopiedAttentionProjectionAllocation.contained (by omega)
    (by unfold CopiedAttentionProjectionAllocation.bytes; omega) separate

private theorem key_separate {base size : Nat}
    (separate : MemoryRegions.Disjoint w.base CopiedAttentionProjectionAllocation.bytes base size) :
    MemoryRegions.Disjoint (phase weights w).keyBuffer.base 2048 base size := by
  rw [key_base]
  exact CopiedAttentionProjectionAllocation.contained (by omega)
    (by unfold CopiedAttentionProjectionAllocation.bytes; omega) separate

variable (queryDispatch : layer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.preparation.kNorm.platform.groups=2)

def query : AttentionGateCopyNormalizationMemory.QueryExecution (copy weights w) (parameters weights w original protectedParameters) :=
  RmsHeadsMemory.canonical _ _ _ _ queryDispatch
    ⟨by rw [query_base]; have := w.aligned; omega,
      by rw [query_base]; have := w.bounded; unfold CopiedAttentionProjectionAllocation.bytes at this; omega⟩
    (query_separate weights w (parameter_regions weights w original protectedParameters).1)

theorem keySafe : MemoryRegions.Disjoint (2*(copy weights w).destination) 12288 (phase weights w).keyBuffer.base 2048 := by
  rw [query_base,key_base]
  exact Or.inr (by omega)

theorem scaleSafe : MemoryRegions.Disjoint (2*(copy weights w).destination) 12288
    (parameters weights w original protectedParameters).keyScale.base 512 :=
  query_separate weights w (parameter_regions weights w original protectedParameters).2.1

private theorem key_input_base {phase : AttentionGateCopyKvMemory.Execution layer.projections input}
    (copy : AttentionGateCopyQueryMemory.Execution phase) (parameters : AttentionParameterMemory.Storage layer copy.copy.memory)
    (query : AttentionGateCopyNormalizationMemory.QueryExecution copy parameters)
    (keySafe : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.keyBuffer.base 2048)
    (scaleSafe : MemoryRegions.Disjoint (2*copy.destination) 12288 parameters.keyScale.base 512) :
    (AttentionGateCopyNormalizationMemory.keyInput copy parameters query keySafe scaleSafe).weight.base=parameters.keyScale.base := rfl

def normal : AttentionGateCopyNormalizationMemory.Execution (copy weights w) (parameters weights w original protectedParameters) where
  query := query weights w original protectedParameters queryDispatch
  keySafe := keySafe weights w
  scaleSafe := scaleSafe weights w original protectedParameters
  key := RmsHeadsMemory.canonical _ _ _ _ keyDispatch
    ⟨(phase weights w).keyBuffer.aligned,(phase weights w).keyBuffer.bounded⟩
    (by rw [key_input_base]; exact key_separate weights w (parameter_regions weights w original protectedParameters).2.1)

theorem safe {base size : Nat} (separate : MemoryRegions.Disjoint w.base CopiedAttentionProjectionAllocation.bytes base size) :
    AttentionGateCopyNormalizationMemory.Safe (normal weights w original protectedParameters queryDispatch keyDispatch) base size :=
  ⟨query_separate weights w separate,key_separate weights w separate⟩
end Inference.Models.Qwen.CopiedAttentionNormalizationAllocation
