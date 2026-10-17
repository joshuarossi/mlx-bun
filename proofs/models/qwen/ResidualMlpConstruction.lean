import models.qwen.ResidualMlpMemory
import models.qwen.TrellisParameterExecution
open Inference Inference.Contracts.Mlx Inference.Models.Qwen Inference.Kernels.Trellis
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000
namespace Inference.Models.Qwen.ResidualMlpConstruction
structure MlpAllocation where
  middle : Nat
  partialBase : Nat
  output : Nat
  middleAligned : middle%2=0
  partialAligned : partialBase%16=0
  outputAligned : output%2=0
  middleBounded : middle+34816 ≤ 2^64
  partialBounded : partialBase+655360 ≤ 2^64
  outputBounded : output+10240 ≤ 2^64
  middleSeparate : MemoryRegions.Disjoint partialBase 655360 middle 34816
  partialSeparate : MemoryRegions.Disjoint output 10240 partialBase 655360

def mlp (parameters : WrittenLayers.GateDown) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (allocation : MlpAllocation) (sourceAligned : source.base%16=0)
    (inputSeparate : MemoryRegions.Disjoint allocation.middle 34816 source.base 10240) :=
  TrellisMlpMemory.canonical parameters input source sourceAligned allocation.middle allocation.partialBase allocation.output
    allocation.middleAligned allocation.partialAligned allocation.outputAligned allocation.middleBounded allocation.partialBounded
    allocation.outputBounded inputSeparate allocation.middleSeparate allocation.partialSeparate

theorem mlp_source (parameters : WrittenLayers.GateDown) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (allocation : MlpAllocation) (sourceAligned : source.base%16=0)
    (inputSeparate : MemoryRegions.Disjoint allocation.middle 34816 source.base 10240) :
    (mlp parameters input source allocation sourceAligned inputSeparate).source=source := by
  unfold mlp TrellisMlpMemory.canonical
  rfl

theorem mlp_safe (parameters : WrittenLayers.GateDown) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (allocation : MlpAllocation) (sourceAligned : source.base%16=0)
    (inputSeparate : MemoryRegions.Disjoint allocation.middle 34816 source.base 10240) :
    TrellisMlpMemory.Safe (mlp parameters input source allocation sourceAligned inputSeparate) base size ↔
      MemoryRegions.Disjoint allocation.middle 34816 base size ∧ MemoryRegions.Disjoint allocation.partialBase 655360 base size ∧
      MemoryRegions.Disjoint allocation.output 10240 base size := by
  unfold mlp TrellisMlpMemory.canonical
  rfl

variable {x update : Fin 5120 → ArrayStorage.BF} {block : ResidualBlocks.Mlp}

structure NormalizationAllocation (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight) where
  residualBase : Nat
  normalizedBase : Nat
  residualBounded : 2*residualBase+10240 ≤ 2^64
  normalizedBounded : 2*normalizedBase+10240 ≤ 2^64
  leftSeparate : MemoryRegions.Disjoint input.lhs.base 10240 (2*residualBase) 10240
  rightSeparate : MemoryRegions.Disjoint input.rhs.base 10240 (2*residualBase) 10240
  residualWeight : MemoryRegions.Disjoint (2*residualBase) 10240 weights.base 10240
  normalizedResidual : MemoryRegions.Disjoint (2*normalizedBase) 10240 (2*residualBase) 10240
  normalizedWeight : MemoryRegions.Disjoint (2*normalizedBase) 10240 weights.base 10240

def residual (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (allocation : NormalizationAllocation input weights) :
    Kernels.ResidualRmsMemory.Residual input block.norm.weight :=
  ⟨BinaryMemory.fromBuffers input Kernels.ResidualRmsNorm.residual allocation.residualBase allocation.residualBounded
    (Or.inr allocation.leftSeparate) (Or.inr allocation.rightSeparate),weights,shared,allocation.residualWeight⟩

def normalization (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (allocation : NormalizationAllocation input weights) :
    NormalizationMemory.ResidualExecution block.norm (residual input weights shared allocation) :=
  Kernels.ResidualRmsMemory.canonical (residual input weights shared allocation) block.norm.platform Blocks.width Blocks.eps
    allocation.normalizedBase allocation.normalizedBounded allocation.normalizedResidual allocation.normalizedWeight

theorem normalization_base (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (allocation : NormalizationAllocation input weights) :
    (normalization input weights shared allocation).normalized.base=allocation.normalizedBase := by
  unfold normalization
  rfl

attribute [local irreducible] normalization

structure Allocation (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes) where
  norm : NormalizationAllocation input weights
  mlp : MlpAllocation
  sourceAligned : (2*norm.normalizedBase)%16=0
  inputSeparate : MemoryRegions.Disjoint mlp.middle 34816 (2*norm.normalizedBase) 10240
  finalBase : Nat
  finalBounded : 2*finalBase+10240 ≤ 2^64
  finalResidual : MemoryRegions.Disjoint (2*norm.residualBase) 10240 (2*finalBase) 10240
  finalOutput : MemoryRegions.Disjoint mlp.output 10240 (2*finalBase) 10240
  savedResidual : MemoryRegions.Disjoint mlp.middle 34816 (2*norm.residualBase) 10240 ∧
    MemoryRegions.Disjoint mlp.partialBase 655360 (2*norm.residualBase) 10240 ∧
    MemoryRegions.Disjoint mlp.output 10240 (2*norm.residualBase) 10240
  parametersSafe : parameters.Protected (fun base size =>
    MemoryRegions.Disjoint (2*norm.residualBase) 10240 base size ∧
    MemoryRegions.Disjoint (2*norm.normalizedBase) 10240 base size ∧
    MemoryRegions.Disjoint mlp.middle 34816 base size ∧ MemoryRegions.Disjoint mlp.partialBase 655360 base size ∧
    MemoryRegions.Disjoint mlp.output 10240 base size ∧ MemoryRegions.Disjoint (2*finalBase) 10240 base size)
  normSafe : MemoryRegions.Disjoint mlp.middle 34816 weights.base 10240 ∧
    MemoryRegions.Disjoint mlp.partialBase 655360 weights.base 10240 ∧
    MemoryRegions.Disjoint mlp.output 10240 weights.base 10240 ∧
    MemoryRegions.Disjoint (2*finalBase) 10240 weights.base 10240

def parametersAfterNormalization (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) :
    TrellisWeightsMemory.Weights block.mlp (normalization input weights shared allocation.norm).outputBuffer.bytes :=
  parameters.reframe _ (parameters.protected_mono
    (fun _ _ h => (normalization input weights shared allocation.norm).other_region h.1 (by rw [normalization_base]; exact h.2.1)) allocation.parametersSafe)

def kernel (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) :
    TrellisMlpMemory.Execution block.mlp (normalization input weights shared allocation.norm).output :=
  mlp block.mlp _ (normalization input weights shared allocation.norm).outputBuffer allocation.mlp (by unfold normalization; exact allocation.sourceAligned)
    (by unfold normalization; exact allocation.inputSeparate)

theorem kernel_source (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) :
    (kernel input weights shared parameters allocation).source=(normalization input weights shared allocation.norm).outputBuffer :=
  mlp_source _ _ _ _ _ _

theorem kernel_safe (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) :
    TrellisMlpMemory.Safe (kernel input weights shared parameters allocation) base size ↔
      MemoryRegions.Disjoint allocation.mlp.middle 34816 base size ∧
      MemoryRegions.Disjoint allocation.mlp.partialBase 655360 base size ∧
      MemoryRegions.Disjoint allocation.mlp.output 10240 base size := mlp_safe _ _ _ _ _ _

def fromStorage (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) : ResidualMlpMemory.Execution block input := by
  let norm := normalization input weights shared allocation.norm
  let middle := kernel input weights shared parameters allocation
  have linked : middle.source=norm.outputBuffer := kernel_source _ _ _ _ _
  have safe : TrellisMlpMemory.Safe middle norm.residualBuffer.base 10240 :=
    (kernel_safe input weights shared parameters allocation).mpr allocation.savedResidual
  have outputBase : middle.outputBuffer.base=allocation.mlp.output := by
    unfold middle kernel mlp TrellisMlpMemory.canonical
    rfl
  apply ResidualMlpMemory.fromMlp block input (residual input weights shared allocation.norm) norm middle linked safe
    allocation.finalBase allocation.finalBounded
  · exact Or.inr allocation.finalResidual
  · rw [outputBase]
    exact Or.inr allocation.finalOutput


def parameterExecution (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) :
    TrellisParameterExecution.Execution block.mlp (normalization input weights shared allocation.norm).output := by
  let k := kernel input weights shared parameters allocation
  have sourceBytes := congrArg ArrayStorage.BFBuffer.bytes (kernel_source input weights shared parameters allocation)
  let stored := parameters.reframe k.source.bytes (parameters.protected_mono
    (fun _ _ h offset bound => (congrFun sourceBytes _).trans
      ((normalization input weights shared allocation.norm).other_region h.1
        (by rw [normalization_base]; exact h.2.1) offset bound)) allocation.parametersSafe)
  refine ⟨k,stored,?_⟩
  change parameters.Protected (TrellisMlpMemory.Safe k)
  exact parameters.protected_mono (fun _ _ h => (kernel_safe input weights shared parameters allocation).mpr
    ⟨h.2.2.1,h.2.2.2.1,h.2.2.2.2.1⟩) allocation.parametersSafe

def RegionsSafe (allocation : Allocation input weights shared parameters) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint (2*allocation.norm.residualBase) 10240 base size ∧
  MemoryRegions.Disjoint (2*allocation.norm.normalizedBase) 10240 base size ∧
  MemoryRegions.Disjoint allocation.mlp.middle 34816 base size ∧
  MemoryRegions.Disjoint allocation.mlp.partialBase 655360 base size ∧
  MemoryRegions.Disjoint allocation.mlp.output 10240 base size ∧
  MemoryRegions.Disjoint (2*allocation.finalBase) 10240 base size

theorem fromStorage_safe (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) (safe : RegionsSafe allocation base size) :
    ResidualMlpMemory.Safe (fromStorage input weights shared parameters allocation) base size := by
  refine ⟨safe.1,?_,(kernel_safe input weights shared parameters allocation).mpr
    ⟨safe.2.2.1,safe.2.2.2.1,safe.2.2.2.2.1⟩,safe.2.2.2.2.2⟩
  change MemoryRegions.Disjoint (2*(normalization input weights shared allocation.norm).normalized.base) 10240 base size
  rw [normalization_base]
  exact safe.2.1

def parametersAfter (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) :
    TrellisWeightsMemory.Weights block.mlp (fromStorage input weights shared parameters allocation).outputBuffer.bytes :=
  parameters.reframe _ (parameters.protected_mono (fun _ _ safe =>
    (fromStorage input weights shared parameters allocation).other_region
      (fromStorage_safe input weights shared parameters allocation safe)) allocation.parametersSafe)

def normAfter (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) :
    ArrayStorage.BFBuffer block.norm.weight :=
  ArrayFrame.bf weights (fromStorage input weights shared parameters allocation).outputBuffer.bytes (by
    intro offset bound
    have safe : RegionsSafe allocation weights.base 10240 :=
      ⟨allocation.norm.residualWeight,allocation.norm.normalizedWeight,allocation.normSafe⟩
    exact ((fromStorage input weights shared parameters allocation).other_region
      (fromStorage_safe input weights shared parameters allocation safe) offset bound).trans (congrFun shared _).symm)

theorem output_eq (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) :
    (fromStorage input weights shared parameters allocation).output=block.forward x update :=
  (fromStorage input weights shared parameters allocation).output_eq


theorem fromStorage_bases (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) :
    let e := fromStorage input weights shared parameters allocation
    e.residual.addition.base=allocation.norm.residualBase ∧
    e.normalization.normalized.base=allocation.norm.normalizedBase ∧
    e.mlp.device.kernel.middle.base=allocation.mlp.middle ∧
    e.mlp.device.kernel.down.partialBase=allocation.mlp.partialBase ∧
    e.mlp.outputBuffer.base=allocation.mlp.output ∧ e.addition.base=allocation.finalBase := by
  refine ⟨rfl,normalization_base _ _ _ _,?_,?_,?_,rfl⟩
  · change (kernel input weights shared parameters allocation).device.kernel.middle.base=_
    unfold kernel mlp TrellisMlpMemory.canonical
    rfl
  · change (kernel input weights shared parameters allocation).device.kernel.down.partialBase=_
    unfold kernel mlp TrellisMlpMemory.canonical
    rfl
  · change (kernel input weights shared parameters allocation).outputBuffer.base=_
    unfold kernel mlp TrellisMlpMemory.canonical
    rfl

theorem parameterExecution_kernel (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) :
    (parameterExecution input weights shared parameters allocation).kernel=
      (fromStorage input weights shared parameters allocation).mlp := rfl

theorem parametersAfter_values (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) :
    (parametersAfter input weights shared parameters allocation).readMlp=block.mlp :=
  (parametersAfter input weights shared parameters allocation).readMlp_eq

def retainedCaches {n : Nat} (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
    (allocation : Allocation input weights shared parameters) (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages n)
    (storage : DecodeFrame.Storage stages cache input.lhs.bytes)
    (safe : DecodePreservation.Protected (RegionsSafe allocation) stages cache input.lhs.bytes storage) :
    DecodeFrame.Storage stages cache (fromStorage input weights shared parameters allocation).outputBuffer.bytes :=
  DecodePreservation.reframe (RegionsSafe allocation) input.lhs.bytes _
    (fun _ _ region => (fromStorage input weights shared parameters allocation).other_region
      (fromStorage_safe input weights shared parameters allocation region)) stages cache storage safe

end Inference.Models.Qwen.ResidualMlpConstruction
