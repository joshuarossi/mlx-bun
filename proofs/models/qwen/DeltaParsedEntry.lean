import models.qwen.DeltaParsedProjections
import models.qwen.ResidualDeltaStorageConstruction
import kernels.normalization.MlxRmsReductionSource
namespace Inference.Models.Qwen.DeltaParsedEntry
open Contracts.Mlx Kernels Kernels.Normalization Layers
set_option maxRecDepth 10000
variable {layer : ResidualDelta.Layer} {input : Fin 5120→ArrayStorage.BF}

def after (entry : DeltaNormalizedMemory.Execution layer input) (before inverseBefore : M1Max.WordMemory)
    (base inverseBase : Nat) :=
  MlxRmsReductionSource.final entry.source layer.inputNorm.platform Blocks.width Blocks.eps before inverseBefore base inverseBase

-- The original residual remains live: this prefix specializes the fresh,
-- non-donatable metadata branch. Native reference-count/descriptor attachment
-- is explicit; the constructor separately proves physical non-overlap.
structure Normalization (entry : DeltaNormalizedMemory.Execution layer input)
    (kernel : MlxRmsHostSelection.KernelLimit)
    (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) : Prop where
  nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads
  host : MlxRmsHostSelection.select (MlxRmsHostSelection.singleToken false) kernel=some
    ⟨5120,1,true,1,kernel.threads,kernel.threads,.fresh⟩
  first : ∀ thread, MlxRmsReductionFirstPass.executeThread entry.source layer.inputNorm.platform.contracted
    (layer.inputNorm.platform.groups*32) (by have := layer.inputNorm.platform.groupsPositive; omega) thread=
      some (MlxRmsReductionFirstPass.locals entry.source layer.inputNorm.platform.contracted
        (layer.inputNorm.platform.groups*32) thread)
  reduction : MlxRmsReductionSource.executeSource entry.source layer.inputNorm.platform Blocks.width Blocks.eps
    before inverseBefore base inverseBase=some (after entry before inverseBefore base inverseBase)
  output : MlxRmsLoopMemory.Runs entry.source entry.normalization.normalized kernel.threads kernel.positive
    (after entry before inverseBefore base inverseBase).inverse inverseBase
    (MlxRmsLoopMemory.programs kernel.threads).flatten entry.source.lhs.bytes entry.normalization.normalized.trace.memory

theorem normalization (entry : DeltaNormalizedMemory.Execution layer input)
    (kernel : MlxRmsHostSelection.KernelLimit)
    (nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads)
    (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    Normalization entry kernel before inverseBefore base inverseBase := by
  refine ⟨nativeThreads,MlxRmsHostSelection.single_launch false kernel,?_,?_,?_⟩
  · exact MlxRmsReductionFirstPass.checked_locals entry.source layer.inputNorm.platform.contracted
      (layer.inputNorm.platform.groups*32) (by have := layer.inputNorm.platform.groupsPositive; omega)
  · exact MlxRmsReductionSource.source_execution entry.source layer.inputNorm.platform Blocks.width Blocks.eps
      before inverseBefore base inverseBase
  · exact MlxRmsLoopMemory.output_stores entry.source entry.normalization.normalized kernel.threads kernel.positive
      _ inverseBase (MlxRmsReductionSource.existing_factor entry.source entry.normalization before inverseBefore base inverseBase)

structure Certificate (entry : DeltaNormalizedMemory.Execution layer input)
    (a b : AffineVerifyLinear.Projection4 10 48) (ha : layer.mixer.a=.bits4 a) (hb : layer.mixer.b=.bits4 b)
    (kernel : MlxRmsHostSelection.KernelLimit)
    (scratch inverseBefore : M1Max.WordMemory) (base inverseBase generation : Nat) (size : Char) (before : Nat→Float32) : Prop where
  normalization : Normalization entry kernel scratch inverseBefore base inverseBase
  projections : DeltaParsedProjections.Certificate entry.affine a b ha hb generation size before

theorem checked (entry : DeltaNormalizedMemory.Execution layer input)
    (a b : AffineVerifyLinear.Projection4 10 48) (ha : layer.mixer.a=.bits4 a) (hb : layer.mixer.b=.bits4 b)
    (kernel : MlxRmsHostSelection.KernelLimit)
    (nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads)
    (scratch inverseBefore : M1Max.WordMemory) (base inverseBase generation : Nat) (size : Char) (before : Nat→Float32)
    (qkvFinite : layer.mixer.qkv.Finite (layer.inputNorm.forward input))
    (zFinite : layer.mixer.z.Finite (layer.inputNorm.forward input))
    (aFinite : a.Finite (layer.inputNorm.forward input)) (bFinite : b.Finite (layer.inputNorm.forward input)) :
    Certificate entry a b ha hb kernel scratch inverseBefore base inverseBase generation size before :=
  ⟨normalization entry kernel nativeThreads scratch inverseBefore base inverseBase,
    DeltaParsedProjections.checked entry.affine a b ha hb generation size before qkvFinite zFinite aFinite bFinite⟩

theorem normalized_heap (entry : DeltaNormalizedMemory.Execution layer input) :
    entry.affine.source.bytes=entry.normalization.normalized.trace.memory := entry.affine_input_bytes

theorem normalized_read (entry : DeltaNormalizedMemory.Execution layer input) (col : Fin 5120) :
    entry.affine.source.read col=layer.inputNorm.forward input col := entry.affine.source.read_correct col

theorem norm_current_weights (entry : DeltaNormalizedMemory.Execution layer input) (col : Fin 5120) :
    HalfMemory.load entry.source.lhs.bytes (entry.source.rhs.base+2*col.val)=ArrayStorage.bits (layer.inputNorm.weight col) := by
  rw [←entry.source.shared]
  exact entry.source.rhs.attached col
end Inference.Models.Qwen.DeltaParsedEntry
