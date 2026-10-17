import kernels.quantization.AffineDot3FunctionSource
import kernels.quantization.MlxQmvMemory

namespace Inference.Kernels.Quantization.AffineDot3TileMemory
open Contracts.Mlx
set_option maxRecDepth 10000

def view (buffers : AffineLoads.Buffers) (row : Fin rows) (step : Fin steps) (lane : Fin 32)
    (scaled : Nat → Float32) (scaledBase : Nat) : AffineDot3Source.Memory where
  packed := buffers.packed
  packedBase := buffers.packedBase+AffineLayout.weightOffset 3 row.val steps step.val lane.val 0
  scaled := scaled
  scaledBase := scaledBase

theorem bytes (buffers : AffineLoads.Buffers) (row : Fin rows) (step : Fin steps) (lane : Fin 32)
    (scaled : Nat → Float32) (scaledBase : Nat) :
    AffineDot3FunctionSource.weights (view buffers row step lane scaled scaledBase)=
      (AffineLoads.weights3 buffers row).bytes step lane := by
  funext chunk byte
  change buffers.packed (buffers.packedBase + AffineLayout.weightOffset 3 row.val steps step.val lane.val 0 + 3*chunk.val + byte.val) =
    buffers.packed (buffers.packedBase + AffineLayout.weightOffset 3 row.val steps step.val lane.val (chunk.val*3+byte.val))
  apply congrArg buffers.packed
  simp only [AffineLayout.weightOffset]
  ring

theorem packed_bounds (buffers : AffineLoads.Buffers) (geometry : MlxQmvDevice.Geometry .three buffers steps rows)
    (row : Fin rows) (step : Fin steps) (lane : Fin 32) (scaled : Nat → Float32) (scaledBase : Nat) :
    (view buffers row step lane scaled scaledBase).packedBase+6≤2^64 := by
  have last := AffineLoads.packed3_bounds buffers.packedBase geometry.packedBounded row step lane 1 2
  dsimp only [view,AffineLayout.weightOffset] at last ⊢
  omega

theorem execution (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (geometry : MlxQmvDevice.Geometry .three buffers steps rows)
    (row : Fin rows) (step : Fin steps) (lane : Fin 32) (scaled : Nat → Float32) (scaledBase : Nat)
    (scaledRoom : scaledBase+16≤2^64)
    (prepared : ∀ chunk offset, AffineDot3FunctionSource.inputs (view buffers row step lane scaled scaledBase) chunk offset=
      AffineTile.prepared3 p.tile (AffineRow.slice input step lane) chunk offset)
    (finite : AffineTile.Finite3 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights3 buffers row).bytes step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    AffineDot3FunctionSource.Execution p.tile.contracted p.tile.tailContracted
      (view buffers row step lane scaled scaledBase)
      (BFloat16.widen (AffineLoads.scale buffers row (AffineRow.groupIndex step lane)))
      (AffineInput.summed (AffineRow.slice input step lane) AffineInput.groups3)
      (BFloat16.widen (AffineLoads.bias buffers row (AffineRow.groupIndex step lane)))
      (AffineRow.tiles3 p input (AffineLoads.weights3 buffers row) step lane) := by
  have bound := packed_bounds buffers geometry row step lane scaled scaledBase
  have same := bytes buffers row step lane scaled scaledBase
  have finiteView := finite
  rw [←same] at finiteView
  have run := AffineDot3FunctionSource.tile_execution p.tile (AffineRow.slice input step lane)
    (view buffers row step lane scaled scaledBase)
    (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
    (AffineLoads.bias buffers row (AffineRow.groupIndex step lane)) bound scaledRoom prepared finiteView
  simpa only [same,AffineRow.tiles3,AffineLoads.weights3] using run

-- The selected qdot reads the actual heap after arbitrary output stores,
-- while all six packed bytes and both scalar parameters remain original.
theorem during_output (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (projection : MlxQmvMemory.Execution .three p input buffers groups)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 projection.base (2*(4*groups)) stores)
    (row : Fin (4*groups)) (step : Fin steps) (lane : Fin 32) (scaled : Nat → Float32) (scaledBase : Nat)
    (scaledRoom : scaledBase+16≤2^64)
    (prepared : ∀ chunk offset,
      AffineDot3FunctionSource.inputs (view (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
        row step lane scaled scaledBase) chunk offset=
      AffineTile.prepared3 p.tile (AffineRow.slice input step lane) chunk offset)
    (finite : AffineTile.Finite3 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights3 buffers row).bytes step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    AffineDot3FunctionSource.Execution p.tile.contracted p.tile.tailContracted
      (view (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes)) row step lane scaled scaledBase)
      (BFloat16.widen (AffineLoads.scale
        (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes)) row (AffineRow.groupIndex step lane)))
      (AffineInput.summed (AffineRow.slice input step lane) AffineInput.groups3)
      (BFloat16.widen (AffineLoads.bias
        (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes)) row (AffineRow.groupIndex step lane)))
      (AffineRow.tiles3 p input (AffineLoads.weights3 buffers row) step lane) := by
  have stable := projection.duringWeights stores inside
  have weightEq := AffineMemory.weights3_eq stable row
  have scaleEq := AffineMemory.scale_eq stable row (AffineRow.groupIndex step lane)
  have biasEq := AffineMemory.bias_eq stable row (AffineRow.groupIndex step lane)
  have currentFinite := finite
  rw [←weightEq,←scaleEq,←biasEq] at currentFinite
  have run := execution p input _ (AffineMemory.reframe_geometry projection.geometry _) row step lane
    scaled scaledBase scaledRoom prepared currentFinite
  simpa only [weightEq] using run

end Inference.Kernels.Quantization.AffineDot3TileMemory
