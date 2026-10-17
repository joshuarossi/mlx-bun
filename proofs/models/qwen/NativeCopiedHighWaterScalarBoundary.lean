import models.qwen.InitialCopiedTokenScalarBoundary
import models.qwen.CapacityCopiedTokenScalarBoundary

namespace Inference.Models.Qwen.NativeCopiedHighWaterScalarBoundary
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Copy Kernels.Sampling
open ResidualDeltaHighWater (Frontier)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenConstruction.step

variable {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p n}
  {original : TokenParameterMemory.Storage p before.index.bytes} {frontier : Frontier}
  (r : NativeCopiedHighWater.Request original frontier) (angle : RopeAngles.Inputs)

def BoundaryInputs : Type := by
  cases n with
  | zero => exact InitialCopiedTokenScalarBoundary.BoundaryInputs r angle
  | succ n => exact CapacityCopiedTokenScalarBoundary.BoundaryInputs r angle

variable (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
  (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

def inputs (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
    (shared : zero.bytes=before.index.bytes) (below : zero.base+2≤frontier.cursor)
    (boundary : BoundaryInputs r angle) : NativeCopiedConstructedInputs.BoundaryInputs
      (NativeCopiedTokenConstruction.step (NativeCopiedHighWater.plan r angle sampling lseLocal tileLocal finishLocal)).execution := by
  cases n with
  | zero => exact InitialCopiedTokenScalarBoundary.inputs r angle sampling lseLocal tileLocal finishLocal zero shared below boundary
  | succ n => exact CapacityCopiedTokenScalarBoundary.inputs r angle sampling lseLocal tileLocal finishLocal zero shared below boundary

-- The actual same-heap input record is produced, including every gate link
-- and scalar-source attachment, rather than supplied independently.
def fullInputs (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
    (shared : zero.bytes=before.index.bytes) (below : zero.base+2≤frontier.cursor)
    (boundary : BoundaryInputs r angle) : NativeCopiedTokenRoute.Inputs
      (NativeCopiedTokenConstruction.step (NativeCopiedHighWater.plan r angle sampling lseLocal tileLocal finishLocal)).execution :=
  NativeCopiedConstructedInputs.inputs (cache:=before.logical.cache)
    (NativeCopiedHighWater.plan r angle sampling lseLocal tileLocal finishLocal)
    (inputs r angle sampling lseLocal tileLocal finishLocal zero shared below boundary)

theorem initial_selected {before0 : TokenAutoregressiveMemory.State p 0}
    {original0 : TokenParameterMemory.Storage p before0.index.bytes} {frontier0 : Frontier}
    (request0 : InitialCopiedTokenHighWater.Request original0 frontier0)
    (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
    (shared : zero.bytes=before0.index.bytes) (below : zero.base+2≤frontier0.cursor)
    (boundary : InitialCopiedTokenScalarBoundary.BoundaryInputs request0 angle) :
    inputs (n:=0) (before:=before0) (original:=original0) (frontier:=frontier0) request0 angle sampling lseLocal tileLocal finishLocal zero shared below boundary=
      InitialCopiedTokenScalarBoundary.inputs request0 angle sampling lseLocal tileLocal finishLocal zero shared below boundary := rfl

end Inference.Models.Qwen.NativeCopiedHighWaterScalarBoundary
