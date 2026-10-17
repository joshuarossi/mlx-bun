import models.qwen.TrellisMlpSource
import models.qwen.ResidualBlocks
import kernels.ResidualRmsNormDevice
import contracts.mlx.ElementwiseAddDevice

namespace Inference.Models.Qwen.ResidualMlpDevice
open Contracts.Mlx Kernels
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

-- The residual store feeds normalization, normalization feeds Trellis, and
-- the saved residual plus the actual down-projection output feed the add.
structure Execution (b : ResidualBlocks.Mlp) (input update : Fin 5120 → BF) where
  normalization : ResidualRmsNormDevice.Execution b.norm.platform input update b.norm.weight Blocks.width Blocks.eps
  mlp : TrellisMlpSource.Execution b.mlp normalization.output
  mlpInput : mlp.source=normalization.outputBuffer
  addition : ElementwiseAddDevice.Execution normalization.residual mlp.output
  additionLeft : addition.lhs=normalization.residualBuffer
  additionRight : addition.rhs=mlp.outputBuffer

def Execution.fromNormalization (b : ResidualBlocks.Mlp) (input update : Fin 5120 → BF)
    (normalization : ResidualRmsNormDevice.Execution b.norm.platform input update b.norm.weight Blocks.width Blocks.eps) :
    Execution b input update :=
  let mlp := TrellisMlpSource.Execution.fromStorage b.mlp normalization.output normalization.outputBuffer (by change 0%16=0; decide)
  ⟨normalization, mlp, TrellisMlpSource.Execution.fromStorage_source _ _ _ _,
    ElementwiseAddDevice.Execution.fromStorage _ _ normalization.residualBuffer mlp.outputBuffer (by decide), rfl, rfl⟩

def Execution.fromStorage (b : ResidualBlocks.Mlp) (input update : Fin 5120 → BF)
    (source : ArrayStorage.BFBuffer input) (change : ArrayStorage.BFBuffer update)
    (weights : ArrayStorage.BFBuffer b.norm.weight) : Execution b input update :=
  Execution.fromNormalization b input update
    (ResidualRmsNormDevice.Execution.fromStorage b.norm.platform input update b.norm.weight Blocks.width Blocks.eps
      source change weights (by decide))

variable {b : ResidualBlocks.Mlp} {input update : Fin 5120 → BF}

def Execution.output (execution : Execution b input update) : Fin 5120 → BF := execution.addition.output
def Execution.outputBuffer (execution : Execution b input update) : ArrayStorage.BFBuffer execution.output := execution.addition.outputBuffer

theorem Execution.normalized_eq (execution : Execution b input update) : execution.normalization.output=b.normalized input update :=
  execution.normalization.output_eq b.norm.scratch b.norm.base

theorem Execution.mlp_eq (execution : Execution b input update) : execution.mlp.output=b.branch input update := by
  rw [execution.mlp.output_eq, execution.normalized_eq]
  rfl

theorem Execution.output_eq (execution : Execution b input update) : execution.output=b.forward input update := by
  unfold Execution.output
  rw [execution.addition.output_eq, execution.normalization.residual_eq, execution.mlp_eq]
  rfl

theorem Execution.mlp_input_bytes (execution : Execution b input update) :
    execution.mlp.source.bytes=execution.normalization.normalization.stores.memory :=
  congrArg ArrayStorage.BFBuffer.bytes execution.mlpInput

theorem Execution.addition_left_bytes (execution : Execution b input update) :
    execution.addition.lhs.bytes=execution.normalization.residualStores.memory :=
  congrArg ArrayStorage.BFBuffer.bytes execution.additionLeft

theorem Execution.addition_right_bytes (execution : Execution b input update) :
    execution.addition.rhs.bytes=execution.mlp.kernel.output.memory :=
  congrArg ArrayStorage.BFBuffer.bytes execution.additionRight

theorem Execution.output_bytes (execution : Execution b input update) :
    execution.outputBuffer.bytes=execution.addition.stores.memory := rfl

def Execution.forwardBuffer (execution : Execution b input update) : ArrayStorage.BFBuffer (b.forward input update) :=
  ArrayViews.reindex execution.output_eq execution.outputBuffer

theorem Execution.forward_bytes (execution : Execution b input update) :
    execution.forwardBuffer.bytes=execution.addition.stores.memory := ArrayViews.reindex_bytes _ _

end Inference.Models.Qwen.ResidualMlpDevice
