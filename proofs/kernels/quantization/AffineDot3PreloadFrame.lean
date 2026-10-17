import kernels.quantization.AffineDot3TileMemory
import kernels.quantization.AffinePreload3Source
import kernels.quantization.AffineDot4PreloadedMemory
namespace Inference.Kernels.Quantization.AffineDot3PreloadFrame
open Contracts.Mlx AffineDot4PreloadedMemory
set_option maxRecDepth 10000

theorem completed (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (projection : MlxQmvMemory.Execution .three p input buffers groups)
    (hsteps : steps≤15) {schedule after}
    (trace : AffinePreload3Source.SourceTrace p.tile (chunkBuffer projection.source) schedule after)
    (before : Nat → Float32)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 projection.base (2*(4*groups)) stores)
    (row : Fin (4*groups)) (step : Fin steps) (lane : Fin 32)
    (finite : AffineTile.Finite3 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights3 buffers row).bytes step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    AffineDot3FunctionSource.Execution p.tile.contracted p.tile.tailContracted
      (AffineDot3TileMemory.view (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
        row step lane (MemoryCells.execute schedule before) ((AffineLayout.chunkIndex step lane).val*16))
      (BFloat16.widen (AffineLoads.scale (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
        row (AffineRow.groupIndex step lane)))
      (MemoryCells.execute schedule before (steps*32*16+(AffineLayout.chunkIndex step lane).val))
      (BFloat16.widen (AffineLoads.bias (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
        row (AffineRow.groupIndex step lane)))
      (AffineRow.tiles3 p input (AffineLoads.weights3 buffers row) step lane) := by
  let current := AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes)
  obtain ⟨sum,cells⟩ := AffinePreload3Source.completed_scratch p.tile (chunkBuffer projection.source)
    hsteps trace.execution trace.completed before (AffineLayout.chunkIndex step lane)
  rw [chunk_slice] at sum cells
  have prepared : ∀ i j, AffineDot3FunctionSource.inputs
      (AffineDot3TileMemory.view current row step lane (MemoryCells.execute schedule before)
        ((AffineLayout.chunkIndex step lane).val*16)) i j=
      AffineTile.prepared3 p.tile (AffineRow.slice input step lane) i j := by
    intro i j
    simpa only [AffineDot3FunctionSource.inputs,AffineDot3Source.input,AffineDot3LoopSource.slice,
      AffineDot3TileMemory.view,AffinePreload3Source.scratch] using cells i j
  have room : (AffineLayout.chunkIndex step lane).val*16+16≤2^64 := by
    have := (AffineLayout.chunkIndex step lane).isLt
    omega
  have run := AffineDot3TileMemory.during_output p input buffers projection stores inside row step lane
    (MemoryCells.execute schedule before) ((AffineLayout.chunkIndex step lane).val*16) room prepared finite
  rw [←sum] at run
  exact run

theorem canonical (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (projection : MlxQmvMemory.Execution .three p input buffers groups)
    (hsteps : steps≤15) (before : Nat → Float32) :
    ∃ schedule after,
      AffinePreload3Source.SourceTrace p.tile (chunkBuffer projection.source) schedule after ∧
      (∀ word, steps*32*17≤word → MemoryCells.execute schedule before word=before word) ∧
      ∀ (stores : List HalfMemory.Store), MemoryRegions.Inside16 projection.base (2*(4*groups)) stores →
        ∀ (row : Fin (4*groups)) (step : Fin steps) (lane : Fin 32),
          AffineTile.Finite3 p.tile (AffineRow.slice input step lane)
            ((AffineLoads.weights3 buffers row).bytes step lane)
            (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
            (AffineLoads.bias buffers row (AffineRow.groupIndex step lane)) →
          AffineDot3FunctionSource.Execution p.tile.contracted p.tile.tailContracted
            (AffineDot3TileMemory.view (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
              row step lane (MemoryCells.execute schedule before) ((AffineLayout.chunkIndex step lane).val*16))
            (BFloat16.widen (AffineLoads.scale (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
              row (AffineRow.groupIndex step lane)))
            (MemoryCells.execute schedule before (steps*32*16+(AffineLayout.chunkIndex step lane).val))
            (BFloat16.widen (AffineLoads.bias (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
              row (AffineRow.groupIndex step lane)))
            (AffineRow.tiles3 p input (AffineLoads.weights3 buffers row) step lane) := by
  obtain ⟨schedule,after,trace,_⟩ := AffinePreload3Source.canonical_source_scratch p.tile (chunkBuffer projection.source) hsteps before
  refine ⟨schedule,after,trace,?_,?_⟩
  · exact AffinePreload3Source.outside_frame p.tile _ trace.execution before
  · intro stores inside row step lane finite
    exact completed p input buffers projection hsteps trace before stores inside row step lane finite
end Inference.Kernels.Quantization.AffineDot3PreloadFrame
