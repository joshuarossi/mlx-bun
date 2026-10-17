import layers.AffineMemory
import kernels.quantization.AffineOuter3Lifecycle

namespace Inference.Layers.AffineParsedSource3
open Contracts.Mlx Kernels.Quantization AffineVerifyLinear
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {steps blocks : Nat} {p : Projection3 steps (4*(blocks*16))}
  {input : Fin (steps*512) → ArrayStorage.BF}
  (execution : AffineMemory.Execution3 p input)

-- The layer's carried parameter attachment discharges the source theorem's
-- tile domain; callers do not supply a second set of decoded weights.
theorem finite_tiles (finite : p.Finite input) (row : Fin (4*(blocks*16))) step lane :
    AffineTile.Finite3 p.platform.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights3 execution.weights.buffers row).bytes step lane)
      (AffineLoads.scale execution.weights.buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias execution.weights.buffers row (AffineRow.groupIndex step lane)) := by
  have domain := finite.tiles row step lane
  rw [←execution.weights.attached row] at domain
  exact domain

def value (row : Fin (4*(blocks*16))) : ArrayStorage.BF :=
  Model.ofBits (HalfMemory.load execution.kernel.stores.memory (execution.kernel.base+2*row.val))

theorem value_eq (limit : blocks≤3880) (row : Fin (4*(blocks*16))) :
    value execution row=p.forward input row := by
  have output := AffineOutput3Source.checked_output execution.kernel (by omega)
  unfold value
  rw [output.readback row,execution.weights.attached row]
  rfl

structure Certificate (before : Nat → Float32) : Prop where
  eligible : AffineRowHostSelection.eligible (AffineRowHostSelection.metadata steps blocks 3)=true
  launch : AffineRowHostSelection.launch (AffineRowHostSelection.metadata steps blocks 3)=
    ⟨steps*512,blocks*64,3,32,blocks*16,1,32,16,1,4,16⟩
  preload : ∃ schedule after,
    AffinePreload3Source.SourceTrace p.platform.tile
      (AffineDot4PreloadedMemory.chunkBuffer execution.kernel.source) schedule after ∧
    (∀ word, steps*32*17≤word → MemoryCells.execute schedule before word=before word) ∧
    ∀ stores : List HalfMemory.Store,
      MemoryRegions.Inside16 execution.kernel.base (2*(4*(blocks*16))) stores →
      AffineOuter3Source.Certificate (schedule:=schedule) p.platform input execution.weights.buffers
        execution.kernel stores before
  readback : ∀ row, value execution row=p.forward input row

theorem checked (before : Nat → Float32) (hsteps : steps≤15) (limit : blocks≤3880)
    (finite : p.Finite input) : Certificate execution before := by
  obtain ⟨eligible,launch,preload⟩ := AffineOuter3Lifecycle.selected p.platform input
    execution.weights.buffers execution.kernel before hsteps limit (finite_tiles execution finite)
  exact ⟨eligible,launch,preload,value_eq execution limit⟩

-- The numerical bound now applies to the value read from the completed
-- parsed-source output heap, retaining the original layer's real target.
theorem readback_error (before : Nat → Float32) (source : Certificate execution before)
    (target error : Fin (steps*512) → ℝ)
    (inputBound : ∀ i, |Model.toReal (input i)-target i|≤error i)
    (finite : p.Finite input) (row : Fin (4*(blocks*16))) :
    |Model.toReal (value execution row)-p.target target row|≤p.budget input target error row := by
  rw [source.readback row]
  exact p.forward_error input target error inputBound finite row

theorem readback_finite (before : Nat → Float32) (source : Certificate execution before)
    (finite : p.Finite input) (row : Fin (4*(blocks*16))) :
    Model.isFinite (value execution row)=true := by
  rw [source.readback row]
  exact p.forward_finite input finite row

end Inference.Layers.AffineParsedSource3
