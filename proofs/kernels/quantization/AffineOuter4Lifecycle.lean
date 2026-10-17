import kernels.quantization.AffineOuter4Source
import kernels.quantization.AffineDot4PreloadFrame
import kernels.quantization.AffineRowHostSelection
namespace Inference.Kernels.Quantization.AffineOuter4Lifecycle
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] AffineOuter4Syntax.parseCall AffineOuter4Call.sourceCall
  AffineOuter4Call.functionCall AffineOuter4Source.sourceLoop AffineRow.tiles4 AffineRow.laneValue
  AffineOutputSource.originalRegisters

variable (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF) (buffers : AffineLoads.Buffers)
  (projection : MlxQmvMemory.Execution .four p input buffers groups)
  {schedule after}
  (trace : AffinePreload4Source.SourceTrace p.tile (AffineDot4PreloadedMemory.chunkBuffer projection.source) schedule after)
  (before : Nat → Float32)
  (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 projection.base (2*(4*groups)) stores)

include trace inside in
theorem source_call (limit : groups≤62080) (hsteps : steps≤15)
    (group : Fin groups) (offset : Fin 4) (step : Fin steps) (lane : Fin 32)
    (finite : AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers (CopyContiguous.index group offset)).words step lane)
      (AffineLoads.scale buffers (CopyContiguous.index group offset) (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers (CopyContiguous.index group offset) (AffineRow.groupIndex step lane))) :
    AffineOuter4Source.calls (schedule:=schedule) p input buffers projection stores before group lane step offset=
      some (AffineRow.tiles4 p input (AffineLoads.weights4 buffers (CopyContiguous.index group offset)) step lane) := by
  unfold AffineOuter4Source.calls AffineOuter4Call.sourceCall
  rw [AffineOuter4Syntax.parsed_call,AffineOuter4Call.frame_source limit]
  apply AffineOuter4Call.function_call
  exact AffineDot4PreloadFrame.completed p input buffers projection hsteps trace before stores inside
    (CopyContiguous.index group offset) step lane finite

include trace inside in
theorem source_registers (limit : groups≤62080) (hsteps : steps≤15)
    (finite : ∀ (row : Fin (4*groups)) step lane, AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane)))
    (group : Fin groups) (lane : Fin 32) :
    AffineOuter4Source.sourceLoop (AffineOuter4Source.calls (schedule:=schedule) p input buffers projection stores before group lane)=some
      (fun row => AffineOutputSource.originalRegisters (p:=p) (input:=input) (buffers:=buffers)
        (CopyContiguous.index group row) lane) := by
  have each (step : Fin steps) (row : Fin 4) := source_call p input buffers projection trace before stores inside limit hsteps
    group row step lane (finite (CopyContiguous.index group row) step lane)
  have run := AffineOuter4Source.source_loop
    (AffineOuter4Source.calls (schedule:=schedule) p input buffers projection stores before group lane)
    (fun step row => AffineRow.tiles4 p input (AffineLoads.weights4 buffers (CopyContiguous.index group row)) step lane) each
  have target : (fun row => AffineRow.laneValue
      (fun step (_ : Fin 32) => AffineRow.tiles4 p input (AffineLoads.weights4 buffers (CopyContiguous.index group row)) step lane) 0)=
      (fun row => AffineOutputSource.originalRegisters (p:=p) (input:=input) (buffers:=buffers) (CopyContiguous.index group row) lane) := by
    funext row
    simp only [AffineOutputSource.originalRegisters,AffineRow.laneValue]
  exact run.trans (congrArg some target)

include trace inside in
theorem checked (limit : groups≤62080) (hsteps : steps≤15) (launch : groups%16=0)
    (finite : ∀ (row : Fin (4*groups)) step lane, AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    AffineOuter4Source.Certificate (schedule:=schedule) p input buffers projection stores before :=
  ⟨launch,source_registers p input buffers projection trace before stores inside limit hsteps finite,
    fun step => by have := step.isLt; omega,AffineOutputSource.checked_output projection limit⟩

-- The existential preload is outside the quantification over output-store
-- prefixes. All later calls and reductions use this same initial scratch bank.
theorem canonical (limit : groups≤62080) (hsteps : steps≤15) (launch : groups%16=0)
    (finite : ∀ (row : Fin (4*groups)) step lane, AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    ∃ schedule after,
      AffinePreload4Source.SourceTrace p.tile (AffineDot4PreloadedMemory.chunkBuffer projection.source) schedule after ∧
      (∀ word, steps*32*17≤word → MemoryCells.execute schedule before word=before word) ∧
      ∀ (stores : List HalfMemory.Store), MemoryRegions.Inside16 projection.base (2*(4*groups)) stores →
        AffineOuter4Source.Certificate (schedule:=schedule) p input buffers projection stores before := by
  obtain ⟨schedule,after,initial,frame,_⟩ := AffineDot4PreloadFrame.canonical p input buffers projection hsteps before
  exact ⟨schedule,after,initial,frame,fun stores inside => checked p input buffers projection initial before stores inside limit hsteps launch finite⟩

-- This is the selected custom four-bit wrapper, with all sixteen SIMD groups
-- live. The host translation keeps descriptor/native installation explicit.
theorem selected (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF) (buffers : AffineLoads.Buffers)
    (projection : MlxQmvMemory.Execution .four p input buffers (blocks*16))
    (before : Nat → Float32) (hsteps : steps≤15) (rowsBound : blocks≤3880)
    (finite : ∀ (row : Fin (4*(blocks*16))) step lane, AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    AffineRowHostSelection.eligible (AffineRowHostSelection.metadata steps blocks 4)=true ∧
    AffineRowHostSelection.launch (AffineRowHostSelection.metadata steps blocks 4)=
      ⟨steps*512,blocks*64,4,32,blocks*16,1,32,16,1,4,16⟩ ∧
    ∃ schedule after,
      AffinePreload4Source.SourceTrace p.tile (AffineDot4PreloadedMemory.chunkBuffer projection.source) schedule after ∧
      (∀ word, steps*32*17≤word → MemoryCells.execute schedule before word=before word) ∧
      ∀ (stores : List HalfMemory.Store), MemoryRegions.Inside16 projection.base (2*(4*(blocks*16))) stores →
        AffineOuter4Source.Certificate (schedule:=schedule) p input buffers projection stores before :=
  ⟨AffineRowHostSelection.selected steps blocks hsteps 4 (Or.inr rfl),AffineRowHostSelection.selected_launch steps blocks 4,
    canonical p input buffers projection before (by omega) hsteps (by omega) finite⟩
end Inference.Kernels.Quantization.AffineOuter4Lifecycle
