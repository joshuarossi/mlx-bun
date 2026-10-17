import models.qwen.ResidualMlpAllocation
import kernels.binary.BinaryVvSourceRefinement

namespace Inference.Models.Qwen.ResidualMlpParsedAdd
open Contracts.Mlx Kernels.Binary
set_option maxRecDepth 10000

variable {x update : Fin 5120 → ArrayStorage.BF} {block : ResidualBlocks.Mlp}
  (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
  (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
  (allocation : ResidualMlpConstruction.Allocation input weights shared parameters)

def execution := ResidualMlpConstruction.fromStorage input weights shared parameters allocation

def operands :=
  let e := execution input weights shared parameters allocation
  ResidualMlpMemory.additionInput e.normalization e.mlp e.linked e.residualSafe

theorem left_base : (operands input weights shared parameters allocation).lhs.base=2*allocation.norm.residualBase := rfl

theorem right_base : (operands input weights shared parameters allocation).rhs.base=allocation.mlp.output :=
  (ResidualMlpConstruction.fromStorage_bases input weights shared parameters allocation).2.2.2.2.1

theorem addition_base : 2*(execution input weights shared parameters allocation).addition.base=2*allocation.finalBase :=
  congrArg (2*·) (ResidualMlpConstruction.fromStorage_bases input weights shared parameters allocation).2.2.2.2.2

theorem left_fresh : MemoryRegions.Disjoint (2*allocation.finalBase) 10240
    (operands input weights shared parameters allocation).lhs.base 10240 := by
  rw [left_base]
  exact MemoryRegions.disjoint_symm allocation.finalResidual

theorem right_fresh : MemoryRegions.Disjoint (2*allocation.finalBase) 10240
    (operands input weights shared parameters allocation).rhs.base 10240 := by
  rw [right_base]
  exact MemoryRegions.disjoint_symm allocation.finalOutput

theorem parsedAllocation : BinaryVvInterleaving.Allocation
    (operands input weights shared parameters allocation).lhs.base
    (operands input weights shared parameters allocation).rhs.base (2*allocation.finalBase) :=
  BinaryVvSourceRefinement.allocationFromBuffers (operands input weights shared parameters allocation)
    (2*allocation.finalBase) (by omega) allocation.finalBounded
    (left_fresh input weights shared parameters allocation) (right_fresh input weights shared parameters allocation)

def parsed := BinaryVvSourceRefinement.checked (operands input weights shared parameters allocation)
  (parsedAllocation input weights shared parameters allocation)

attribute [local irreducible] execution parsed

private theorem execution_heap {left right : Fin 5120 → ArrayStorage.BF}
    {source : BinaryMemory.Input left right} {layer : ResidualBlocks.Mlp}
    (e : ResidualMlpMemory.Execution layer source) : e.outputBuffer.bytes=e.addition.trace.memory := rfl

-- Both source-body execution and its separate-load/store schedule produce
-- the exact existing residual-layer heap, with the original operand buffers.
-- The fused residual/normalization operation preceding the MLP is separate.
theorem parsed_heap :
    (parsed input weights shared parameters allocation).bodyAfter=(execution input weights shared parameters allocation).outputBuffer.bytes ∧
    (parsed input weights shared parameters allocation).eventAfter.memory=(execution input weights shared parameters allocation).outputBuffer.bytes := by
  unfold parsed
  have actual := BinaryVvSourceRefinement.checked_eq_existing (operands input weights shared parameters allocation)
    (parsedAllocation input weights shared parameters allocation) (execution input weights shared parameters allocation).addition
    (addition_base input weights shared parameters allocation)
  exact ⟨actual.1.trans (execution_heap (execution input weights shared parameters allocation)).symm,
    actual.2.trans (execution_heap (execution input weights shared parameters allocation)).symm⟩

theorem parsed_frame {base size : Nat} (safe : ResidualMlpConstruction.RegionsSafe allocation base size)
    (offset : Nat) (bound : offset<size) :
    (parsed input weights shared parameters allocation).eventAfter.memory (base+offset)=input.lhs.bytes (base+offset) := by
  have kept : ResidualMlpMemory.Safe (execution input weights shared parameters allocation) base size := by
    unfold execution
    exact ResidualMlpConstruction.fromStorage_safe input weights shared parameters allocation safe
  exact (congrFun (parsed_heap input weights shared parameters allocation).2 _).trans
    ((execution input weights shared parameters allocation).other_region kept offset bound)

end Inference.Models.Qwen.ResidualMlpParsedAdd
