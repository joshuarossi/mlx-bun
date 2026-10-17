import kernels.quantization.MlxQmvDot4FunctionSource
import kernels.quantization.MlxQmvMemory

namespace Inference.Kernels.Quantization.MlxQmvDot4TileMemory
open Contracts.Mlx
set_option maxRecDepth 10000

-- The view retains the live packed-byte image. Its four uint16 words are the
-- exact row/step/lane slice used by the original projection specification.
def view (buffers : AffineLoads.Buffers) (row : Fin rows) (step : Fin steps) (lane : Fin 32)
    (scaled : Nat → Float32) (scaledBase : Nat) : MlxQmvDot4Source.Memory where
  packed := buffers.packed
  packedBase := buffers.packedBase+AffineLayout.weightOffset 4 row.val steps step.val lane.val 0
  scaled := scaled
  scaledBase := scaledBase

theorem words (buffers : AffineLoads.Buffers) (row : Fin rows) (step : Fin steps) (lane : Fin 32)
    (scaled : Nat → Float32) (scaledBase : Nat) :
    MlxQmvDot4Source.word (view buffers row step lane scaled scaledBase)=
      (AffineLoads.weights4 buffers row).words step lane := by
  funext chunk
  unfold MlxQmvDot4Source.word view AffineLoads.weights4
  congr 1
  simp only [AffineLayout.weightOffset]
  omega

theorem packed_bounds (buffers : AffineLoads.Buffers) (geometry : MlxQmvDevice.Geometry .four buffers steps rows)
    (row : Fin rows) (step : Fin steps) (lane : Fin 32) (scaled : Nat → Float32) (scaledBase : Nat) :
    (view buffers row step lane scaled scaledBase).packedBase%2=0 ∧
      (view buffers row step lane scaled scaledBase).packedBase+8≤2^64 := by
  have aligned : buffers.packedBase%2=0 := by have := geometry.packedAligned; omega
  have first := AffineLoads.packed4_bounds buffers.packedBase aligned geometry.packedBounded row step lane 0
  have last := AffineLoads.packed4_bounds buffers.packedBase aligned geometry.packedBounded row step lane 3
  constructor
  · exact first.1
  · dsimp only [view,AffineLayout.weightOffset] at last ⊢
    omega

theorem execution (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (geometry : MlxQmvDevice.Geometry .four buffers steps rows)
    (row : Fin rows) (step : Fin steps) (lane : Fin 32) (scaled : Nat → Float32) (scaledBase : Nat)
    (prepared : ∀ chunk offset, MlxQmvDot4Source.input (view buffers row step lane scaled scaledBase) chunk offset=
      AffineTile.prepared4 p.tile (AffineRow.slice input step lane) chunk offset)
    (finite : AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    MlxQmvDot4FunctionSource.Execution p.tile.contracted p.tile.tailContracted
      (view buffers row step lane scaled scaledBase)
      (BFloat16.widen (AffineLoads.scale buffers row (AffineRow.groupIndex step lane)))
      (AffineInput.summed (AffineRow.slice input step lane) AffineInput.groups4)
      (BFloat16.widen (AffineLoads.bias buffers row (AffineRow.groupIndex step lane)))
      (AffineRow.tiles4 p input (AffineLoads.weights4 buffers row) step lane) := by
  have bound := packed_bounds buffers geometry row step lane scaled scaledBase
  have same := words buffers row step lane scaled scaledBase
  have finiteView := finite
  rw [←same] at finiteView
  have run := MlxQmvDot4FunctionSource.tile_execution p.tile (AffineRow.slice input step lane)
    (view buffers row step lane scaled scaledBase)
    (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
    (AffineLoads.bias buffers row (AffineRow.groupIndex step lane)) bound.1 bound.2 prepared finiteView
  simpa only [same,AffineRow.tiles4,AffineLoads.weights4] using run

-- Previously completed output stores cannot alter this call's original
-- weight words, scale or bias. The source executes against that current heap,
-- while its result still refers to the original carried parameter bundle.
theorem during_output (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (projection : MlxQmvMemory.Execution .four p input buffers groups)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 projection.base (2*(4*groups)) stores)
    (row : Fin (4*groups)) (step : Fin steps) (lane : Fin 32) (scaled : Nat → Float32) (scaledBase : Nat)
    (prepared : ∀ chunk offset,
      MlxQmvDot4Source.input (view (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
        row step lane scaled scaledBase) chunk offset=
      AffineTile.prepared4 p.tile (AffineRow.slice input step lane) chunk offset)
    (finite : AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    MlxQmvDot4FunctionSource.Execution p.tile.contracted p.tile.tailContracted
      (view (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes)) row step lane scaled scaledBase)
      (BFloat16.widen (AffineLoads.scale
        (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes)) row (AffineRow.groupIndex step lane)))
      (AffineInput.summed (AffineRow.slice input step lane) AffineInput.groups4)
      (BFloat16.widen (AffineLoads.bias
        (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes)) row (AffineRow.groupIndex step lane)))
      (AffineRow.tiles4 p input (AffineLoads.weights4 buffers row) step lane) := by
  have stable := projection.duringWeights stores inside
  have weightEq := AffineMemory.weights4_eq stable row
  have scaleEq := AffineMemory.scale_eq stable row (AffineRow.groupIndex step lane)
  have biasEq := AffineMemory.bias_eq stable row (AffineRow.groupIndex step lane)
  have currentFinite := finite
  rw [←weightEq,←scaleEq,←biasEq] at currentFinite
  have run := execution p input _ (AffineMemory.reframe_geometry projection.geometry _) row step lane scaled scaledBase prepared currentFinite
  simpa only [weightEq] using run

end Inference.Kernels.Quantization.MlxQmvDot4TileMemory
