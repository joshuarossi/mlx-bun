import models.qwen.AttentionGateCopyResidualStage
import kernels.normalization.MlxRmsReductionSource
namespace Inference.Models.Qwen.AttentionGateCopyInputNormalization
open Contracts.Mlx Kernels Kernels.Normalization Layers
set_option maxRecDepth 10000
variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {source : BinaryMemory.Input input layer.inputNorm.weight}
  (normal : NormalizationMemory.Execution layer.inputNorm source)

def after (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :=
  MlxRmsReductionSource.final source layer.inputNorm.platform Blocks.width Blocks.eps before inverseBefore base inverseBase

structure Certificate (kernel : MlxRmsHostSelection.KernelLimit)
    (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) : Prop where
  nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads
  host : MlxRmsHostSelection.select (MlxRmsHostSelection.singleToken false) kernel=some
    ⟨5120,1,true,1,kernel.threads,kernel.threads,.fresh⟩
  first : ∀ thread, MlxRmsReductionFirstPass.executeThread source layer.inputNorm.platform.contracted
    (layer.inputNorm.platform.groups*32) (by have := layer.inputNorm.platform.groupsPositive; omega) thread=
      some (MlxRmsReductionFirstPass.locals source layer.inputNorm.platform.contracted
        (layer.inputNorm.platform.groups*32) thread)
  reduction : MlxRmsReductionSource.executeSource source layer.inputNorm.platform Blocks.width Blocks.eps
    before inverseBefore base inverseBase=some (after (layer:=layer) (source:=source) before inverseBefore base inverseBase)
  output : MlxRmsLoopMemory.Runs source normal.normalized kernel.threads kernel.positive
    (after (layer:=layer) (source:=source) before inverseBefore base inverseBase).inverse inverseBase
    (MlxRmsLoopMemory.programs kernel.threads).flatten source.lhs.bytes normal.normalized.trace.memory

theorem checked (kernel : MlxRmsHostSelection.KernelLimit)
    (nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads)
    (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    Certificate (layer:=layer) normal kernel before inverseBefore base inverseBase := by
  refine ⟨nativeThreads,MlxRmsHostSelection.single_launch false kernel,?_,?_,?_⟩
  · exact MlxRmsReductionFirstPass.checked_locals source layer.inputNorm.platform.contracted
      (layer.inputNorm.platform.groups*32) (by have := layer.inputNorm.platform.groupsPositive; omega)
  · exact MlxRmsReductionSource.source_execution source layer.inputNorm.platform Blocks.width Blocks.eps
      before inverseBefore base inverseBase
  · exact MlxRmsLoopMemory.output_stores source normal.normalized kernel.threads kernel.positive
      _ inverseBase (MlxRmsReductionSource.existing_factor source normal before inverseBefore base inverseBase)
end Inference.Models.Qwen.AttentionGateCopyInputNormalization
