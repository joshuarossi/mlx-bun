import kernels.quantization.AffineOuter3Call
import kernels.quantization.AffineOutput3Source
import kernels.quantization.AffineOuter4Source
namespace Inference.Kernels.Quantization.AffineOuter3Source
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open AffineOuter4Source (sourceLoop source_loop)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] sourceLoop AffineRow.tiles3 AffineRow.laneValue AffineOutput3Source.originalRegisters

variable (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF) (buffers : AffineLoads.Buffers)
  (projection : MlxQmvMemory.Execution .three p input buffers groups)
  (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 projection.base (2*(4*groups)) stores)
  {schedule after}
  (trace : AffinePreload3Source.SourceTrace p.tile (AffineDot4PreloadedMemory.chunkBuffer projection.source) schedule after)
  (before : Nat → Float32)

-- The callback carries its checked source execution, rather than taking a
-- desired return value as a premise. The constructor below supplies both.
def CallsExecute (group : Fin groups) (lane : Fin 32) (call : Fin steps → Fin 4 → Option Float32) : Prop :=
  ∀ step row, ∃ value, call step row=some value ∧
    AffineOuter3Call.SourceCall p.tile (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
      (MemoryCells.execute schedule before) group row step lane value

include inside trace in
theorem source_registers (limit : groups≤62080) (hsteps : steps≤15)
    (finite : ∀ (row : Fin (4*groups)) step lane, AffineTile.Finite3 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights3 buffers row).bytes step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) (group : Fin groups) (lane : Fin 32) :
    ∃ call, CallsExecute (schedule:=schedule) p input buffers projection stores before group lane call ∧
      sourceLoop call=some (fun row => AffineOutput3Source.originalRegisters (p:=p) (input:=input) (buffers:=buffers)
        (CopyContiguous.index group row) lane) := by
  let tile := fun step row => AffineRow.tiles3 p input (AffineLoads.weights3 buffers (CopyContiguous.index group row)) step lane
  let call := fun step row => some (tile step row)
  refine ⟨call,?_,?_⟩
  · intro step row
    exact ⟨tile step row,rfl,AffineOuter3Call.source_call p input buffers projection stores inside trace before
      limit hsteps group row step lane (finite (CopyContiguous.index group row) step lane)⟩
  · have run := source_loop call tile (fun _ _ => rfl)
    have target : (fun row => AffineRow.laneValue (fun step (_ : Fin 32) => tile step row) 0)=
        (fun row => AffineOutput3Source.originalRegisters (p:=p) (input:=input) (buffers:=buffers) (CopyContiguous.index group row) lane) := by
      funext row
      simp only [tile,AffineOutput3Source.originalRegisters,AffineRow.laneValue]
    exact run.trans (congrArg some target)

structure Certificate : Prop where
  completeGroups : groups%16=0
  registers : ∀ group lane, ∃ call, CallsExecute (schedule:=schedule) p input buffers projection stores before group lane call ∧
    sourceLoop call=some (fun row => AffineOutput3Source.originalRegisters (p:=p) (input:=input) (buffers:=buffers)
      (CopyContiguous.index group row) lane)
  signedK : ∀ step : Fin steps, step.val*512+512≤2^31
  output : AffineOutput3Source.Certificate projection

include inside trace in
theorem checked (limit : groups≤62080) (hsteps : steps≤15) (launch : groups%16=0)
    (finite : ∀ (row : Fin (4*groups)) step lane, AffineTile.Finite3 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights3 buffers row).bytes step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    Certificate (schedule:=schedule) p input buffers projection stores before :=
  ⟨launch,source_registers p input buffers projection stores inside trace before limit hsteps finite,
    fun step => by have := step.isLt; omega,AffineOutput3Source.checked_output projection limit⟩
end Inference.Kernels.Quantization.AffineOuter3Source
