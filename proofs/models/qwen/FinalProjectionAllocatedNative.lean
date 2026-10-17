import models.qwen.FinalProjectionSamplerAllocation
import models.qwen.FinalProjectionParsedSource

namespace Inference.Models.Qwen.FinalProjectionAllocatedNative
open Contracts.Mlx Layers Kernels.Normalization
open FloatLib.Floats.Formats.BinaryInterchange

variable {norm : Blocks.Norm} {projection : AffineVerifyLinear.Projection 10 248320}
  {input : Fin 5120 → ArrayStorage.BF}
  {storage : FinalProjectionConstruction.Storage norm projection input}

-- The fresh destination is derived from the actual allocation workspace.
-- Pipeline limits, thread correspondence and primitive memories stay explicit.
def fresh (workspace : FinalProjectionAllocation.Workspace storage)
    (kernel : MlxRmsHostSelection.KernelLimit)
    (threads : norm.platform.groups*32=kernel.threads)
    (scratch inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat)
    (projectionBefore : Nat → Float32) :
    FinalProjectionParsedSource.Native storage workspace.allocation where
  kernel := kernel
  nativeThreads := threads
  donated := false
  ownership := MemoryRegions.disjoint_symm (workspace.normalization_safe workspace.sourceSafe)
  scratch := scratch
  inverseBefore := inverseBefore
  scratchBase := scratchBase
  inverseBase := inverseBase
  projectionBefore := projectionBefore

variable (workspace : FinalProjectionAllocation.Workspace storage)
  (kernel : MlxRmsHostSelection.KernelLimit)
  (threads : norm.platform.groups*32=kernel.threads)
  (scratch inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat)
  (projectionBefore : Nat → Float32)

theorem donated_false :
    (fresh workspace kernel threads scratch inverseBefore scratchBase inverseBase projectionBefore).donated=false := rfl

theorem ownership : MemoryRegions.Disjoint storage.source.base 10240
    (2*workspace.allocation.normBase) 10240 :=
  MemoryRegions.disjoint_symm (workspace.normalization_safe workspace.sourceSafe)

theorem checked (finite : projection.Finite (norm.forward input)) :
    FinalProjectionParsedSource.Certificate storage workspace.allocation
      (fresh workspace kernel threads scratch inverseBefore scratchBase inverseBase projectionBefore) :=
  FinalProjectionParsedSource.checked storage workspace.allocation _ finite

def samplerRequest (request : FinalProjectionSamplerAllocation.Request storage)
    (kernel : MlxRmsHostSelection.KernelLimit)
    (threads : norm.platform.groups*32=kernel.threads)
    (scratch inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat)
    (projectionBefore : Nat → Float32) :
    FinalProjectionParsedSource.Native storage (FinalProjectionSamplerAllocation.allocation request) :=
  fresh (FinalProjectionSamplerAllocation.workspace request) kernel threads scratch inverseBefore
    scratchBase inverseBase projectionBefore

theorem samplerRequest_donated_false (request : FinalProjectionSamplerAllocation.Request storage) :
    (samplerRequest request kernel threads scratch inverseBefore scratchBase inverseBase projectionBefore).donated=false := rfl

theorem samplerRequest_checked (request : FinalProjectionSamplerAllocation.Request storage)
    (finite : projection.Finite (norm.forward input)) :
    FinalProjectionParsedSource.Certificate storage (FinalProjectionSamplerAllocation.allocation request)
      (samplerRequest request kernel threads scratch inverseBefore scratchBase inverseBase projectionBefore) :=
  checked (FinalProjectionSamplerAllocation.workspace request) kernel threads scratch inverseBefore
    scratchBase inverseBase projectionBefore finite

end Inference.Models.Qwen.FinalProjectionAllocatedNative
