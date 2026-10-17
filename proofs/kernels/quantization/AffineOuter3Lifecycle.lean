import kernels.quantization.AffineOuter3Source
import kernels.quantization.AffineRowHostSelection
namespace Inference.Kernels.Quantization.AffineOuter3Lifecycle
open Contracts.Mlx
open AffineOuter3Source (checked)
set_option maxRecDepth 10000
variable (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF) (buffers : AffineLoads.Buffers)
  (projection : MlxQmvMemory.Execution .three p input buffers groups) (before : Nat → Float32)

-- The existential preload is outside the quantification over output-store
-- prefixes. All later calls and reductions use this same initial scratch bank.
theorem canonical (limit : groups≤62080) (hsteps : steps≤15) (launch : groups%16=0)
    (finite : ∀ (row : Fin (4*groups)) step lane, AffineTile.Finite3 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights3 buffers row).bytes step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    ∃ schedule after,
      AffinePreload3Source.SourceTrace p.tile (AffineDot4PreloadedMemory.chunkBuffer projection.source) schedule after ∧
      (∀ word, steps*32*17≤word → MemoryCells.execute schedule before word=before word) ∧
      ∀ (stores : List HalfMemory.Store), MemoryRegions.Inside16 projection.base (2*(4*groups)) stores →
        AffineOuter3Source.Certificate (schedule:=schedule) p input buffers projection stores before := by
  obtain ⟨schedule,after,initial,frame,_⟩ := AffineDot3PreloadFrame.canonical p input buffers projection hsteps before
  exact ⟨schedule,after,initial,frame,fun stores inside => checked p input buffers projection stores inside initial before limit hsteps launch finite⟩

-- This is the selected custom three-bit wrapper, with all sixteen SIMD groups
-- live. The host translation keeps descriptor/native installation explicit.
theorem selected (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF) (buffers : AffineLoads.Buffers)
    (projection : MlxQmvMemory.Execution .three p input buffers (blocks*16))
    (before : Nat → Float32) (hsteps : steps≤15) (rowsBound : blocks≤3880)
    (finite : ∀ (row : Fin (4*(blocks*16))) step lane, AffineTile.Finite3 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights3 buffers row).bytes step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    AffineRowHostSelection.eligible (AffineRowHostSelection.metadata steps blocks 3)=true ∧
    AffineRowHostSelection.launch (AffineRowHostSelection.metadata steps blocks 3)=
      ⟨steps*512,blocks*64,3,32,blocks*16,1,32,16,1,4,16⟩ ∧
    ∃ schedule after,
      AffinePreload3Source.SourceTrace p.tile (AffineDot4PreloadedMemory.chunkBuffer projection.source) schedule after ∧
      (∀ word, steps*32*17≤word → MemoryCells.execute schedule before word=before word) ∧
      ∀ (stores : List HalfMemory.Store), MemoryRegions.Inside16 projection.base (2*(4*(blocks*16))) stores →
        AffineOuter3Source.Certificate (schedule:=schedule) p input buffers projection stores before :=
  ⟨AffineRowHostSelection.selected steps blocks hsteps 3 (Or.inl rfl),AffineRowHostSelection.selected_launch steps blocks 3,
    canonical p input buffers projection before (by omega) hsteps (by omega) finite⟩
end Inference.Kernels.Quantization.AffineOuter3Lifecycle
