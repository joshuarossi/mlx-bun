import models.qwen.Blocks
import kernels.RmsNormDevice

namespace Inference.Models.Qwen.NormalizationDevice
open Contracts.Mlx Kernels
abbrev BF := ArrayStorage.BF

abbrev Execution (norm : Blocks.Norm) (input : Fin 5120 → BF) :=
  RmsNormDevice.Execution norm.platform input norm.weight Blocks.width Blocks.eps

def fromStorage (norm : Blocks.Norm) (input : Fin 5120 → BF) (source : ArrayStorage.BFBuffer input)
    (weights : ArrayStorage.BFBuffer norm.weight) : Execution norm input :=
  RmsNormDevice.Execution.fromStorage norm.platform input norm.weight Blocks.width Blocks.eps source weights (by decide)

theorem output_eq (norm : Blocks.Norm) (input : Fin 5120 → BF) (execution : Execution norm input) :
    execution.output=norm.forward input := execution.output_eq norm.scratch norm.base

def forwardBuffer (norm : Blocks.Norm) (input : Fin 5120 → BF) (execution : Execution norm input) :
    ArrayStorage.BFBuffer (norm.forward input) := execution.forwardBuffer norm.scratch norm.base

theorem forward_bytes (norm : Blocks.Norm) (input : Fin 5120 → BF) (execution : Execution norm input) :
    (forwardBuffer norm input execution).bytes=execution.stores.memory := execution.forward_bytes norm.scratch norm.base

theorem forward_base (norm : Blocks.Norm) (input : Fin 5120 → BF) (execution : Execution norm input) :
    (forwardBuffer norm input execution).base=0 := ArrayViews.reindex_base _ _

end Inference.Models.Qwen.NormalizationDevice
