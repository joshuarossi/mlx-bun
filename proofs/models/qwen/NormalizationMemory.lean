import models.qwen.Blocks
import models.qwen.DecodePreservation
import kernels.RmsNormMemory
import kernels.ResidualRmsMemory

namespace Inference.Models.Qwen.NormalizationMemory
open Contracts.Mlx Kernels DecodeStage DecodeChain
set_option maxRecDepth 10000

variable {x : Fin 5120 → ArrayStorage.BF} {norm : Blocks.Norm}

abbrev Execution (norm : Blocks.Norm) (input : BinaryMemory.Input x norm.weight) :=
  RmsNormMemory.Execution input norm.platform Blocks.width Blocks.eps

def fromStorage (norm : Blocks.Norm) (source : ArrayStorage.BFBuffer x) (weights : ArrayStorage.BFBuffer norm.weight)
    (shared : weights.bytes=source.bytes) (base : Nat) (bounded : 2*base+10240 ≤ 2^64)
    (sourceSafe : source.base/2=base ∨ MemoryRegions.Disjoint source.base 10240 (2*base) 10240)
    (weightsSeparate : MemoryRegions.Disjoint (2*base) 10240 weights.base 10240) :
    Execution norm (⟨source, weights, shared⟩ : BinaryMemory.Input x norm.weight) :=
  RmsNormMemory.canonical _ norm.platform Blocks.width Blocks.eps base bounded sourceSafe weightsSeparate

variable {input : BinaryMemory.Input x norm.weight}

theorem output_eq (execution : Execution norm input) : execution.output=norm.forward x :=
  execution.output_eq norm.scratch norm.base

def forwardBuffer (execution : Execution norm input) : ArrayStorage.BFBuffer (norm.forward x) :=
  ArrayViews.reindex (output_eq execution) execution.outputBuffer

theorem forward_bytes (execution : Execution norm input) :
    (forwardBuffer execution).bytes=execution.outputBuffer.bytes := ArrayViews.reindex_bytes _ _

theorem forward_base (execution : Execution norm input) :
    (forwardBuffer execution).base=2*execution.normalized.base := ArrayViews.reindex_base _ _

def retainedCaches {n : Nat} (execution : Execution norm input) (stages : List Stage) (cache : Caches stages n)
    (storage : DecodeFrame.Storage stages cache input.lhs.bytes)
    (safe : DecodePreservation.Protected
      (fun base size => MemoryRegions.Disjoint (2*execution.normalized.base) 10240 base size) stages cache input.lhs.bytes storage) :
    DecodeFrame.Storage stages cache execution.outputBuffer.bytes :=
  DecodePreservation.reframe _ input.lhs.bytes execution.outputBuffer.bytes
    (fun _ _ separate => execution.other_region separate) stages cache storage safe

def savedInput (execution : Execution norm input)
    (separate : MemoryRegions.Disjoint (2*execution.normalized.base) 10240 input.lhs.base 10240) : ArrayStorage.BFBuffer x :=
  ArrayFrame.bf input.lhs execution.outputBuffer.bytes (execution.other_region separate)

variable {update : Fin 5120 → ArrayStorage.BF} {residualInput : BinaryMemory.Input x update}
  {residual : ResidualRmsMemory.Residual residualInput norm.weight}

abbrev ResidualExecution (norm : Blocks.Norm) (residual : ResidualRmsMemory.Residual residualInput norm.weight) :=
  ResidualRmsMemory.Execution residual norm.platform Blocks.width Blocks.eps

def residualForwardBuffer (execution : ResidualExecution norm residual) :
    ArrayStorage.BFBuffer (norm.forward (fun i => ResidualRmsNorm.residual (x i) (update i))) :=
  ArrayViews.reindex (execution.output_eq norm.scratch norm.base) execution.outputBuffer

def residualCaches {n : Nat} (execution : ResidualExecution norm residual) (stages : List Stage) (cache : Caches stages n)
    (storage : DecodeFrame.Storage stages cache residualInput.lhs.bytes)
    (safe : DecodePreservation.Protected (fun base size =>
      MemoryRegions.Disjoint (2*residual.addition.base) 10240 base size ∧
      MemoryRegions.Disjoint (2*execution.normalized.base) 10240 base size) stages cache residualInput.lhs.bytes storage) :
    DecodeFrame.Storage stages cache execution.outputBuffer.bytes :=
  DecodePreservation.reframe _ residualInput.lhs.bytes execution.outputBuffer.bytes
    (fun _ _ separate => execution.other_region separate.1 separate.2) stages cache storage safe

end Inference.Models.Qwen.NormalizationMemory
