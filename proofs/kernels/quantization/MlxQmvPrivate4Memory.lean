import kernels.quantization.MlxQmvDot4TileMemory
import kernels.quantization.MlxQmvInput4Source
import kernels.quantization.AffineDot4PreparedMemory

namespace Inference.Kernels.Quantization.MlxQmvPrivate4Memory
open Contracts.Mlx
set_option maxRecDepth 10000

-- One native load_vector call constructs sixteen thread-private cells. The
-- same cells and returned sum feed qdot; output stores may already have run.
theorem during_output (p : AffineRow.Platform) (input : Fin (steps*512)→ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (projection : MlxQmvMemory.Execution .four p input buffers groups)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 projection.base (2*(4*groups)) stores)
    (row : Fin (4*groups)) (step : Fin steps) (lane : Fin 32) (before : Nat→Float32)
    (finite : AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    ∃ cells sum,
      MlxQmvInput4Source.execute p.tile.divide (HalfMemory.execute stores projection.source.bytes)
        (projection.source.base+2*(step.val*512+lane.val*16)) before=some (sum,cells) ∧
      MlxQmvDot4FunctionSource.Execution p.tile.contracted p.tile.tailContracted
        (MlxQmvDot4TileMemory.view (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
          row step lane cells 0)
        (BFloat16.widen (AffineLoads.scale (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
          row (AffineRow.groupIndex step lane))) sum
        (BFloat16.widen (AffineLoads.bias (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
          row (AffineRow.groupIndex step lane)))
        (AffineRow.tiles4 p input (AffineLoads.weights4 buffers row) step lane) := by
  let source := AffineDot4PreparedMemory.inputSlice (projection.duringInput stores inside) step lane
  obtain ⟨cells,run,prepared⟩ := MlxQmvInput4Source.execution p.tile source before
  refine ⟨cells,AffineInput.summed (AffineRow.slice input step lane) AffineInput.groups4,run,?_⟩
  apply MlxQmvDot4TileMemory.during_output p input buffers projection stores inside row step lane cells 0 _ finite
  intro i j
  simpa only [MlxQmvDot4Source.input,MlxQmvDot4TileMemory.view,Nat.zero_add] using prepared i j

end Inference.Kernels.Quantization.MlxQmvPrivate4Memory
