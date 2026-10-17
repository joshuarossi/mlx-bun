import kernels.quantization.AffineDot4TileMemory
import kernels.quantization.AffineScratch4Source

namespace Inference.Kernels.Quantization.AffineDot4PreparedMemory
open Contracts.Mlx
set_option maxRecDepth 10000

def inputSlice {input : Fin (steps*512) → ArrayStorage.BF} (source : ArrayStorage.BFBuffer input)
    (step : Fin steps) (lane : Fin 32) : ArrayStorage.BFBuffer (AffineRow.slice input step lane) :=
  ArrayViews.slice source (step.val*512+lane.val*16) 16
    (by have := step.isLt; have := lane.isLt; omega)

theorem slice_bytes {input : Fin (steps*512) → ArrayStorage.BF} (source : ArrayStorage.BFBuffer input)
    (step : Fin steps) (lane : Fin 32) : (inputSlice source step lane).bytes=source.bytes := rfl
theorem slice_base {input : Fin (steps*512) → ArrayStorage.BF} (source : ArrayStorage.BFBuffer input)
    (step : Fin steps) (lane : Fin 32) :
    (inputSlice source step lane).base=source.base+2*(step.val*512+lane.val*16) := rfl

-- Construct the actual per-call preparation from the current activation
-- slice, then execute qdot against the current packed/scale/bias heap. No
-- expected scratch cells or desired arithmetic result are input premises.
theorem during_output (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (projection : MlxQmvMemory.Execution .four p input buffers groups)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 projection.base (2*(4*groups)) stores)
    (row : Fin (4*groups)) (step : Fin steps) (lane : Fin 32)
    (privateBefore : Nat → Float32) (before : AffineScratch4Source.Scratch)
    (finite : AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    ∃ after : AffineScratch4Source.Scratch,
      AffineScratch4Source.publish p.tile (HalfMemory.execute stores projection.source.bytes)
        (projection.source.base+2*(step.val*512+lane.val*16)) (AffineLayout.chunkIndex step lane).val privateBefore before=some after ∧
      AffineDot4FunctionSource.Execution p.tile.contracted p.tile.tailContracted
        (AffineDot4TileMemory.view (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
          row step lane after.xs ((AffineLayout.chunkIndex step lane).val*16))
        (BFloat16.widen (AffineLoads.scale (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
          row (AffineRow.groupIndex step lane)))
        (after.ss (AffineLayout.chunkIndex step lane).val)
        (BFloat16.widen (AffineLoads.bias (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
          row (AffineRow.groupIndex step lane)))
        (AffineRow.tiles4 p input (AffineLoads.weights4 buffers row) step lane) := by
  let current := AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes)
  let source := inputSlice (projection.duringInput stores inside) step lane
  let chunk := (AffineLayout.chunkIndex step lane).val
  obtain ⟨after,publish,sum,cells⟩ := AffineScratch4Source.published p.tile source chunk privateBefore before
  refine ⟨after,?_,?_⟩
  · exact publish
  · have prepared : ∀ i j,
        AffineDot4Source.input (AffineDot4TileMemory.view current row step lane after.xs (chunk*16)) i j=
        AffineTile.prepared4 p.tile (AffineRow.slice input step lane) i j := by
      intro i j
      exact cells current.packed
        (current.packedBase+AffineLayout.weightOffset 4 row.val steps step.val lane.val 0) i j
    have run := AffineDot4TileMemory.during_output p input buffers projection stores inside
      row step lane after.xs (chunk*16) prepared finite
    rw [←sum] at run
    exact run

end Inference.Kernels.Quantization.AffineDot4PreparedMemory
