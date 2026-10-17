import models.qwen.NormalizationMemory
import models.qwen.TrellisMlpMemory
import models.qwen.ResidualBlocks

namespace Inference.Models.Qwen.ResidualMlpMemory
open Contracts.Mlx Kernels DecodeStage DecodeChain
set_option maxRecDepth 10000

variable {x update : Fin 5120 → ArrayStorage.BF} {input : BinaryMemory.Input x update} {norm : Blocks.Norm}
  {residual : ResidualRmsMemory.Residual input norm.weight} {parameters : WrittenLayers.GateDown}

def savedResidual (normalization : NormalizationMemory.ResidualExecution norm residual)
    (mlp : TrellisMlpMemory.Execution parameters normalization.output)
    (linked : mlp.source=normalization.outputBuffer)
    (safe : TrellisMlpMemory.Safe mlp normalization.residualBuffer.base 10240) :
    ArrayStorage.BFBuffer (ResidualBlocks.residual x update) :=
  ArrayFrame.bf normalization.residualBuffer mlp.outputBuffer.bytes (by
    intro offset bound
    have shared := (congrArg ArrayStorage.BFBuffer.bytes linked).trans normalization.residual_shared.symm
    exact (mlp.other_region safe offset bound).trans (congrFun shared (normalization.residualBuffer.base+offset)))

def additionInput (normalization : NormalizationMemory.ResidualExecution norm residual)
    (mlp : TrellisMlpMemory.Execution parameters normalization.output)
    (linked : mlp.source=normalization.outputBuffer)
    (safe : TrellisMlpMemory.Safe mlp normalization.residualBuffer.base 10240) :
    BinaryMemory.Input (ResidualBlocks.residual x update) mlp.output :=
  ⟨savedResidual normalization mlp linked safe, mlp.outputBuffer, rfl⟩

structure Execution (block : ResidualBlocks.Mlp) (input : BinaryMemory.Input x update) where
  residual : ResidualRmsMemory.Residual input block.norm.weight
  normalization : NormalizationMemory.ResidualExecution block.norm residual
  mlp : TrellisMlpMemory.Execution block.mlp normalization.output
  linked : mlp.source=normalization.outputBuffer
  residualSafe : TrellisMlpMemory.Safe mlp normalization.residualBuffer.base 10240
  addition : BinaryMemory.Execution (additionInput normalization mlp linked residualSafe) BFloat16Arithmetic.add

variable {block : ResidualBlocks.Mlp}

def fromMlp (block : ResidualBlocks.Mlp) (input : BinaryMemory.Input x update)
    (residual : ResidualRmsMemory.Residual input block.norm.weight)
    (normalization : NormalizationMemory.ResidualExecution block.norm residual)
    (mlp : TrellisMlpMemory.Execution block.mlp normalization.output)
    (linked : mlp.source=normalization.outputBuffer)
    (residualSafe : TrellisMlpMemory.Safe mlp normalization.residualBuffer.base 10240)
    (base : Nat) (bounded : 2*base+10240 ≤ 2^64)
    (leftSafe : (additionInput normalization mlp linked residualSafe).lhs.base/2=base ∨
      MemoryRegions.Disjoint (additionInput normalization mlp linked residualSafe).lhs.base 10240 (2*base) 10240)
    (rightSafe : mlp.outputBuffer.base/2=base ∨ MemoryRegions.Disjoint mlp.outputBuffer.base 10240 (2*base) 10240) :
    Execution block input :=
  ⟨residual, normalization, mlp, linked, residualSafe,
    BinaryMemory.fromBuffers (additionInput normalization mlp linked residualSafe) BFloat16Arithmetic.add base bounded leftSafe rightSafe⟩

def Execution.output (execution : Execution block input) : Fin 5120 → ArrayStorage.BF := execution.addition.buffer.read

def Execution.outputBuffer (execution : Execution block input) : ArrayStorage.BFBuffer execution.output :=
  ArrayViews.readback execution.addition.buffer

theorem Execution.normalized_eq (execution : Execution block input) : execution.normalization.output=block.normalized x update :=
  execution.normalization.output_eq block.norm.scratch block.norm.base

theorem Execution.mlp_eq (execution : Execution block input) : execution.mlp.output=block.branch x update :=
  execution.mlp.output_eq.trans (congrArg (fun values => block.mlp.forward (Blocks.packed values)) execution.normalized_eq)

theorem Execution.output_eq (execution : Execution block input) : execution.output=block.forward x update := by
  have stored : execution.output=ElementwiseAdd.forward (ResidualBlocks.residual x update) execution.mlp.output :=
    funext execution.addition.buffer.read_correct
  exact stored.trans (congrArg (ElementwiseAdd.forward (ResidualBlocks.residual x update)) execution.mlp_eq)

def Safe (execution : Execution block input) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint (2*execution.residual.addition.base) 10240 base size ∧
    MemoryRegions.Disjoint (2*execution.normalization.normalized.base) 10240 base size ∧
    TrellisMlpMemory.Safe execution.mlp base size ∧
    MemoryRegions.Disjoint (2*execution.addition.base) 10240 base size

theorem Execution.other_region (execution : Execution block input) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=input.lhs.bytes (base+offset) := by
  have normalization := execution.normalization.other_region safe.1 safe.2.1 offset bound
  have middle := execution.mlp.other_region safe.2.2.1 offset bound
  rw [execution.linked] at middle
  exact (execution.addition.other_region safe.2.2.2 offset bound).trans (middle.trans normalization)

def Execution.retainedCaches {n : Nat} (execution : Execution block input) (stages : List Stage) (cache : Caches stages n)
    (storage : DecodeFrame.Storage stages cache input.lhs.bytes)
    (safe : DecodePreservation.Protected (Safe execution) stages cache input.lhs.bytes storage) :
    DecodeFrame.Storage stages cache execution.outputBuffer.bytes :=
  DecodePreservation.reframe (Safe execution) input.lhs.bytes execution.outputBuffer.bytes
    (fun _ _ region => execution.other_region region) stages cache storage safe

theorem Execution.mlp_input_bytes (execution : Execution block input) :
    execution.mlp.source.bytes=execution.normalization.outputBuffer.bytes := congrArg ArrayStorage.BFBuffer.bytes execution.linked

theorem Execution.addition_input_bytes (execution : Execution block input) :
    (additionInput execution.normalization execution.mlp execution.linked execution.residualSafe).lhs.bytes=
      execution.mlp.outputBuffer.bytes := rfl

end Inference.Models.Qwen.ResidualMlpMemory
