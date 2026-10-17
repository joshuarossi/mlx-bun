import kernels.quantization.AffineDot4PreloadedMemory

namespace Inference.Kernels.Quantization.AffineDot4PreloadFrame
open Contracts.Mlx AffineDot4PreloadedMemory
set_option maxRecDepth 10000

-- The preload finishes on the initial heap. Its result remains the same
-- scratch bank while arbitrary later output stores interleave with weight
-- reads. The schedule is chosen before (not separately for) those prefixes.
theorem completed (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (projection : MlxQmvMemory.Execution .four p input buffers groups)
    (hsteps : steps≤15) {schedule after}
    (trace : AffinePreload4Source.SourceTrace p.tile (chunkBuffer projection.source) schedule after)
    (before : Nat → Float32)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 projection.base (2*(4*groups)) stores)
    (row : Fin (4*groups)) (step : Fin steps) (lane : Fin 32)
    (finite : AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    AffineDot4FunctionSource.Execution p.tile.contracted p.tile.tailContracted
      (AffineDot4TileMemory.view (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
        row step lane (MemoryCells.execute schedule before) ((AffineLayout.chunkIndex step lane).val*16))
      (BFloat16.widen (AffineLoads.scale (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
        row (AffineRow.groupIndex step lane)))
      (MemoryCells.execute schedule before (steps*32*16+(AffineLayout.chunkIndex step lane).val))
      (BFloat16.widen (AffineLoads.bias (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
        row (AffineRow.groupIndex step lane)))
      (AffineRow.tiles4 p input (AffineLoads.weights4 buffers row) step lane) := by
  let current := AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes)
  obtain ⟨sum,cells⟩ := AffinePreload4Source.completed_scratch p.tile
    (chunkBuffer projection.source) hsteps trace.execution trace.completed before (AffineLayout.chunkIndex step lane)
  rw [chunk_slice] at sum cells
  have prepared : ∀ i j, AffineDot4Source.input
      (AffineDot4TileMemory.view current row step lane (MemoryCells.execute schedule before)
        ((AffineLayout.chunkIndex step lane).val*16)) i j=
      AffineTile.prepared4 p.tile (AffineRow.slice input step lane) i j := by
    intro i j
    exact cells current.packed
      (current.packedBase+AffineLayout.weightOffset 4 row.val steps step.val lane.val 0) i j
  have run := AffineDot4TileMemory.during_output p input buffers projection stores inside row step lane
    (MemoryCells.execute schedule before) ((AffineLayout.chunkIndex step lane).val*16) prepared finite
  rw [←sum] at run
  exact run

theorem canonical (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (projection : MlxQmvMemory.Execution .four p input buffers groups)
    (hsteps : steps≤15) (before : Nat → Float32) :
    ∃ schedule after,
      AffinePreload4Source.SourceTrace p.tile (chunkBuffer projection.source) schedule after ∧
      (∀ word, steps*32*17≤word → MemoryCells.execute schedule before word=before word) ∧
      ∀ (stores : List HalfMemory.Store), MemoryRegions.Inside16 projection.base (2*(4*groups)) stores →
        ∀ (row : Fin (4*groups)) (step : Fin steps) (lane : Fin 32),
          AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
            ((AffineLoads.weights4 buffers row).words step lane)
            (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
            (AffineLoads.bias buffers row (AffineRow.groupIndex step lane)) →
          AffineDot4FunctionSource.Execution p.tile.contracted p.tile.tailContracted
            (AffineDot4TileMemory.view (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
              row step lane (MemoryCells.execute schedule before) ((AffineLayout.chunkIndex step lane).val*16))
            (BFloat16.widen (AffineLoads.scale (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
              row (AffineRow.groupIndex step lane)))
            (MemoryCells.execute schedule before (steps*32*16+(AffineLayout.chunkIndex step lane).val))
            (BFloat16.widen (AffineLoads.bias (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
              row (AffineRow.groupIndex step lane)))
            (AffineRow.tiles4 p input (AffineLoads.weights4 buffers row) step lane) := by
  obtain ⟨schedule,after,trace,_⟩ := AffinePreload4Source.canonical_source_scratch p.tile
    (chunkBuffer projection.source) hsteps before
  refine ⟨schedule,after,trace,?_,?_⟩
  · exact AffinePreload4Source.outside_frame p.tile _ trace.execution before
  · intro stores inside row step lane finite
    exact completed p input buffers projection hsteps trace before stores inside row step lane finite

end Inference.Kernels.Quantization.AffineDot4PreloadFrame
