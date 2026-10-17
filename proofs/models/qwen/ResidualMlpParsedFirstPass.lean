import models.qwen.ResidualMlpParsedAdd
import kernels.normalization.ResidualRmsTailSource
import kernels.normalization.ResidualRmsLoopMemory

namespace Inference.Models.Qwen.ResidualMlpParsedFirstPass
open Contracts.Mlx Kernels.Normalization
open ResidualMlpParsedAdd (execution)
set_option maxRecDepth 10000

variable {x update : Fin 5120 → ArrayStorage.BF} {block : ResidualBlocks.Mlp}
  (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
  (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
  (allocation : ResidualMlpConstruction.Allocation input weights shared parameters)

-- Freshness follows from the existing layer allocation. Callers provide no
-- extra parsed-execution result, accumulator vector or residual-output buffer.
theorem sourceAllocation : ResidualRmsCellMemory.Allocation input.lhs.base input.rhs.base (2*allocation.norm.residualBase) :=
  ⟨by omega,allocation.norm.residualBounded,
    MemoryRegions.disjoint_symm allocation.norm.leftSeparate,
    MemoryRegions.disjoint_symm allocation.norm.rightSeparate⟩

def firstPass := ResidualRmsFirstPassMemory.complete input (2*allocation.norm.residualBase) block.norm.platform.contracted

theorem residual_base :
    2*(execution input weights shared parameters allocation).residual.addition.base=2*allocation.norm.residualBase :=
  congrArg (2*·) (ResidualMlpConstruction.fromStorage_bases input weights shared parameters allocation).1

attribute [local irreducible] execution firstPass

theorem parsed_execution :
    ResidualRmsFirstPassMemory.Launch block.norm.platform.contracted input.lhs.base input.rhs.base
      (2*allocation.norm.residualBase) (List.finRange 1024) (ResidualRmsFirstPassMemory.initial input)
      (firstPass input weights shared parameters allocation) := by
  unfold firstPass
  exact ResidualRmsFirstPassMemory.complete_execution input

theorem parsed_heap :
    (firstPass input weights shared parameters allocation).memory=
      (execution input weights shared parameters allocation).residual.addition.trace.memory := by
  unfold firstPass
  exact ResidualRmsFirstPassMemory.refines_existing input (sourceAllocation input weights shared parameters allocation)
    (execution input weights shared parameters allocation).residual.addition
    (residual_base input weights shared parameters allocation)

theorem parsed_accumulators (thread : Fin 1024) :
    (firstPass input weights shared parameters allocation).accumulators thread=
      NormalizationReduction.threadSum block.norm.platform.contracted
        (execution input weights shared parameters allocation).residual.sourceValues thread := by
  rw [Kernels.ResidualRmsMemory.Residual.sourceValues_eq]
  unfold firstPass
  exact ResidualRmsFirstPassMemory.complete_accumulators input
    (sourceAllocation input weights shared parameters allocation) thread

theorem parsed_frame {base size : Nat}
    (safe : MemoryRegions.Disjoint (2*allocation.norm.residualBase) 10240 base size)
    (offset : Nat) (bound : offset<size) :
    (firstPass input weights shared parameters allocation).memory (base+offset)=input.lhs.bytes (base+offset) := by
  unfold firstPass ResidualRmsFirstPassMemory.complete
  exact ResidualRmsFirstPassMemory.frame _ _ safe offset bound

def weightsAfter : ArrayStorage.BFBuffer block.norm.weight :=
  ArrayFrame.bf weights (firstPass input weights shared parameters allocation).memory (by
    intro offset bound
    exact (parsed_frame input weights shared parameters allocation allocation.norm.residualWeight offset bound).trans
      (congrFun shared _).symm)

def parametersAfter : TrellisWeightsMemory.Weights block.mlp (firstPass input weights shared parameters allocation).memory :=
  parameters.reframe _ (parameters.protected_mono (fun _ _ safe =>
    parsed_frame input weights shared parameters allocation safe.1) allocation.parametersSafe)

theorem parameter_bytes : parameters.Protected (fun base size => ∀ offset < size,
    (firstPass input weights shared parameters allocation).memory (base+offset)=input.lhs.bytes (base+offset)) :=
  parameters.protected_mono (fun _ _ safe => parsed_frame input weights shared parameters allocation safe.1)
    allocation.parametersSafe

theorem parameters_values : (parametersAfter input weights shared parameters allocation).readMlp=block.mlp :=
  (parametersAfter input weights shared parameters allocation).readMlp_eq

-- These two source boundaries now join the same constructed layer execution.
-- Trellis arithmetic/reductions, native scheduling and compiler correspondence
-- still have their separate obligations.
theorem source_boundaries :
    (firstPass input weights shared parameters allocation).memory=
      (execution input weights shared parameters allocation).residual.addition.trace.memory ∧
    (ResidualMlpParsedAdd.parsed input weights shared parameters allocation).eventAfter.memory=
      (execution input weights shared parameters allocation).outputBuffer.bytes :=
  ⟨parsed_heap input weights shared parameters allocation,
    (ResidualMlpParsedAdd.parsed_heap input weights shared parameters allocation).2⟩


-- The parsed reduction tail consumes this layer's constructed first pass.
-- Its inverse is the same factor read by the existing normalization stage;
-- no caller supplies the accumulator vector, inverse or parsed result.
theorem parsed_tail_inverse (groups : block.norm.platform.groups=32)
    (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    ∃ after, ResidualRmsTailSource.executeSource ResidualRmsTailSyntax.sourceBody block.norm.platform
      Blocks.width Blocks.eps (firstPass input weights shared parameters allocation)
      before inverseBefore base inverseBase=some after ∧ after.phase=7 ∧
      after.inverse inverseBase=(execution input weights shared parameters allocation).normalization.factor := by
  unfold firstPass
  obtain ⟨after,source,phase,inverse⟩ := ResidualRmsTailSource.checked_inverse input
    (sourceAllocation input weights shared parameters allocation) block.norm.platform groups Blocks.width Blocks.eps
    before inverseBefore base inverseBase
  exact ⟨after,source,phase,inverse.trans
    ((execution input weights shared parameters allocation).normalization.factor_eq before base).symm⟩


-- The parsed tail's inverse feeds parsed output cells on the parsed loop
-- programs. Their stores produce the complete existing normalized heap.
theorem parsed_output_stores (groups : block.norm.platform.groups=32)
    (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    ∃ after, ResidualRmsTailSource.executeSource ResidualRmsTailSyntax.sourceBody block.norm.platform
      Blocks.width Blocks.eps (firstPass input weights shared parameters allocation)
      before inverseBefore base inverseBase=some after ∧ after.phase=7 ∧
      ResidualRmsOutputMemory.Runs
        (execution input weights shared parameters allocation).residual.normalizationInput.lhs.base
        (execution input weights shared parameters allocation).residual.normalizationInput.rhs.base
        (2*(execution input weights shared parameters allocation).normalization.normalized.base)
        after.inverse inverseBase
        ResidualRmsLoopMemory.programs.flatten
        (firstPass input weights shared parameters allocation).memory
        (execution input weights shared parameters allocation).normalization.normalized.trace.memory := by
  obtain ⟨after,source,phase,factor⟩ := parsed_tail_inverse input weights shared parameters allocation groups
    before inverseBefore base inverseBase
  have stores := ResidualRmsLoopMemory.output_stores
    (execution input weights shared parameters allocation).residual.normalizationInput
    (execution input weights shared parameters allocation).normalization.normalized after.inverse inverseBase factor
  change ResidualRmsOutputMemory.Runs _ _ _ _ _ _
    (execution input weights shared parameters allocation).residual.addition.trace.memory _ at stores
  rw [←parsed_heap input weights shared parameters allocation] at stores
  exact ⟨after,source,phase,stores⟩


-- Both nested source loops determine every first-pass thread's cells in the
-- exact accumulation order used by the existing first-pass memory proof.
theorem parsed_loop_execution :
    ResidualRmsLoopMemory.FirstPass block.norm.platform.contracted input.lhs.base input.rhs.base
      (2*allocation.norm.residualBase) (List.finRange 1024) (ResidualRmsFirstPassMemory.initial input)
      (firstPass input weights shared parameters allocation) := by
  unfold firstPass ResidualRmsFirstPassMemory.complete
  exact ResidualRmsLoopMemory.firstPass _ _ _ _ _ _

end Inference.Models.Qwen.ResidualMlpParsedFirstPass
