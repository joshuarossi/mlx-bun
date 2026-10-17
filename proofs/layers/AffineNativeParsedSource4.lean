import layers.AffineMemory
import kernels.quantization.MlxQmvFast4Memory
namespace Inference.Layers.AffineNativeParsedSource4
open Contracts.Mlx Kernels.Quantization AffineVerifyLinear
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {steps blocks : Nat} {p : Projection4 steps (4*(blocks*2))}
  {input : Fin (steps*512)→ArrayStorage.BF} (execution : AffineMemory.Execution4 p input)

theorem finite_tiles (finite : p.Finite input) (row : Fin (4*(blocks*2))) step lane :
    AffineTile.Finite4 p.platform.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 execution.weights.buffers row).words step lane)
      (AffineLoads.scale execution.weights.buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias execution.weights.buffers row (AffineRow.groupIndex step lane)) := by
  have domain := finite.tiles row step lane
  rw [←execution.weights.attached row] at domain
  exact domain

def value (row : Fin (4*(blocks*2))) : ArrayStorage.BF :=
  Model.ofBits (HalfMemory.load execution.kernel.stores.memory (execution.kernel.base+2*row.val))

def buffer : ArrayStorage.BFBuffer (p.forward input) :=
  AffineMemory.Execution.forwardBuffer (p:=.bits4 p) execution

structure Certificate (generation : Nat) (size : Char) (before : Nat→Float32) : Prop where
  selected : MlxQmvHostSource.selected generation size (steps*512) (blocks*8)=true
  launch : MlxQmvHostSource.launch (blocks*8)=⟨1,blocks,1,32,2,1⟩
  source : ∀ stores,MemoryRegions.Inside16 execution.kernel.base (2*(4*(blocks*2))) stores→
    MlxQmvFast4Memory.Certificate execution.kernel stores before
  readback : ∀ row,value execution row=p.forward input row

theorem checked (generation : Nat) (size : Char) (before : Nat→Float32)
    (hsteps : steps≤15) (limit : blocks≤31040) (finite : p.Finite input) :
    Certificate execution generation size before := by
  obtain ⟨selected,launch,_,source⟩ := MlxQmvFast4Memory.selected generation size execution.kernel
    limit hsteps before (finite_tiles execution finite)
  refine ⟨selected,launch,source,?_⟩
  intro row
  have completed := source [] (by intro store member; cases member)
  unfold value
  rw [completed.readback row,execution.weights.attached row]
  rfl

theorem buffer_read (generation : Nat) (size : Char) (before : Nat→Float32)
    (source : Certificate execution generation size before) (row : Fin (4*(blocks*2))) :
    (buffer execution).read row=value execution row := by
  rw [ArrayStorage.BFBuffer.read_correct,source.readback]

theorem readback_error (generation : Nat) (size : Char) (before : Nat→Float32)
    (source : Certificate execution generation size before) (target error : Fin (steps*512)→ℝ)
    (inputBound : ∀ i,|Model.toReal (input i)-target i|≤error i)
    (finite : p.Finite input) (row : Fin (4*(blocks*2))) :
    |Model.toReal (value execution row)-p.target target row|≤p.budget input target error row := by
  rw [source.readback row]
  exact p.forward_error input target error inputBound finite row

theorem readback_finite (generation : Nat) (size : Char) (before : Nat→Float32)
    (source : Certificate execution generation size before) (finite : p.Finite input) (row : Fin (4*(blocks*2))) :
    Model.isFinite (value execution row)=true := by
  rw [source.readback row]
  exact p.forward_finite input finite row
end Inference.Layers.AffineNativeParsedSource4
