import models.qwen.FinalProjectionConstruction
import layers.AffineParsedSource
import kernels.normalization.MlxRmsReductionSource

namespace Inference.Models.Qwen.FinalProjectionParsedSource
open Contracts.Mlx Layers Kernels.Normalization
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {norm : Blocks.Norm} {projection : AffineVerifyLinear.Projection 10 248320}
  {input : Fin 5120 → ArrayStorage.BF}
  (storage : FinalProjectionConstruction.Storage norm projection input)
  (allocation : FinalProjectionConstruction.Allocation storage)

-- Host donation is linked to the actual construction's destination region.
-- The corresponding native descriptor/refcount and pipeline maximum remain
-- explicit attachment inputs, as do compiler and arithmetic primitives.
structure Native where
  kernel : MlxRmsHostSelection.KernelLimit
  nativeThreads : norm.platform.groups*32=kernel.threads
  donated : Bool
  ownership : if donated then storage.source.base/2=allocation.normBase
    else MemoryRegions.Disjoint storage.source.base 10240 (2*allocation.normBase) 10240
  scratch : M1Max.WordMemory
  inverseBefore : M1Max.WordMemory
  scratchBase : Nat
  inverseBase : Nat
  projectionBefore : Nat → Float32

def after (native : Native storage allocation) :=
  MlxRmsReductionSource.final (FinalProjectionConstruction.normInput storage) norm.platform Blocks.width Blocks.eps
    native.scratch native.inverseBefore native.scratchBase native.inverseBase

structure Certificate (native : Native storage allocation) : Prop where
  host : MlxRmsHostSelection.select (MlxRmsHostSelection.singleToken native.donated) native.kernel=some
    ⟨5120,1,true,1,native.kernel.threads,native.kernel.threads,if native.donated then .donated else .fresh⟩
  first : ∀ thread, MlxRmsReductionFirstPass.executeThread (FinalProjectionConstruction.normInput storage)
    norm.platform.contracted (norm.platform.groups*32) (by have := norm.platform.groupsPositive; omega) thread=
      some (MlxRmsReductionFirstPass.locals (FinalProjectionConstruction.normInput storage)
        norm.platform.contracted (norm.platform.groups*32) thread)
  reduction : MlxRmsReductionSource.executeSource (FinalProjectionConstruction.normInput storage) norm.platform Blocks.width Blocks.eps
    native.scratch native.inverseBefore native.scratchBase native.inverseBase=some (after storage allocation native)
  output : MlxRmsLoopMemory.Runs (FinalProjectionConstruction.normInput storage)
    (FinalProjectionConstruction.normalization storage allocation).normalized native.kernel.threads native.kernel.positive
    (after storage allocation native).inverse native.inverseBase
    (MlxRmsLoopMemory.programs native.kernel.threads).flatten storage.source.bytes
    (FinalProjectionConstruction.normalization storage allocation).normalized.trace.memory
  projection : AffineParsedSource.Certificate (steps:=10) (blocks:=3880)
    (FinalProjectionConstruction.output storage allocation) native.projectionBefore

theorem checked (native : Native storage allocation) (finite : projection.Finite (norm.forward input)) :
    Certificate storage allocation native := by
  refine ⟨MlxRmsHostSelection.single_launch native.donated native.kernel,?_,?_,?_,?_⟩
  · exact MlxRmsReductionFirstPass.checked_locals (FinalProjectionConstruction.normInput storage) norm.platform.contracted
      (norm.platform.groups*32) (by have := norm.platform.groupsPositive; omega)
  · exact MlxRmsReductionSource.source_execution (FinalProjectionConstruction.normInput storage) norm.platform Blocks.width Blocks.eps
      native.scratch native.inverseBefore native.scratchBase native.inverseBase
  · exact MlxRmsLoopMemory.output_stores (FinalProjectionConstruction.normInput storage)
      (FinalProjectionConstruction.normalization storage allocation).normalized native.kernel.threads native.kernel.positive
      _ native.inverseBase (MlxRmsReductionSource.existing_factor (FinalProjectionConstruction.normInput storage)
        (FinalProjectionConstruction.normalization storage allocation) native.scratch native.inverseBefore native.scratchBase native.inverseBase)
  · exact AffineParsedSource.checked (steps:=10) (blocks:=3880)
      (FinalProjectionConstruction.output storage allocation) native.projectionBefore (by decide) (by decide) finite

theorem current_input :
    (FinalProjectionConstruction.output storage allocation).source=FinalProjectionConstruction.normalized storage allocation :=
  FinalProjectionConstruction.output_source storage allocation

theorem source_and_readback (native : Native storage allocation) (finite : projection.Finite (norm.forward input)) :
    Certificate storage allocation native ∧ ∀ row,
      (FinalProjectionConstruction.output storage allocation).outputBuffer.read row=projection.forward (norm.forward input) row := by
  refine ⟨checked storage allocation native finite,fun row => ?_⟩
  rw [ArrayStorage.BFBuffer.read_correct,FinalProjectionConstruction.output_eq]

end Inference.Models.Qwen.FinalProjectionParsedSource
