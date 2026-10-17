import kernels.quantization.AffineLoads
import contracts.mlx.CopyContiguous
import contracts.mlx.ArrayViews

namespace Inference.Kernels.Quantization.MlxQmvDevice
open Contracts.Mlx
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF

inductive Bits where
  | three
  | four

def Bits.width : Bits → Nat | .three => 3 | .four => 4

structure Geometry (bits : Bits) (buffers : AffineLoads.Buffers) (steps rows : Nat) : Prop where
  packedAligned : buffers.packedBase%4=0
  packedBounded : buffers.packedBase+rows*(steps*64*bits.width) ≤ 2^64
  scaleAligned : buffers.scaleBase%2=0
  biasAligned : buffers.biasBase%2=0
  scaleBounded : buffers.scaleBase+2*(rows*(steps*8)) ≤ 2^64
  biasBounded : buffers.biasBase+2*(rows*(steps*8)) ≤ 2^64

@[irreducible] def produced (bits : Bits) (p : AffineRow.Platform) {input : Fin (steps*512) → BF}
    (x : ArrayStorage.BFBuffer input) (buffers : AffineLoads.Buffers) (row : Fin rows) : BF :=
  match bits with
  | .three => AffineLoads.forward3 p x buffers row
  | .four => AffineLoads.forward4 p x buffers row

-- Each SIMD group owns four rows; lane zero writes them in order after
-- the reductions. The shared four-word scheduler captures these producers.
structure Execution (bits : Bits) (p : AffineRow.Platform) (input : Fin (steps*512) → BF)
    (buffers : AffineLoads.Buffers) (groups : Nat) where
  geometry : Geometry bits buffers steps (4*groups)
  inputStorage : ArrayStorage.BFBuffer input
  outputBounded : 2*(4*groups) ≤ 2^64
  stores : CopyContiguous.Trace 0 (blocks := groups) (fun row => ArrayStorage.bits (produced bits p inputStorage buffers row))

def Execution.fromStorage (bits : Bits) (p : AffineRow.Platform) (input : Fin (steps*512) → BF)
    (buffers : AffineLoads.Buffers) (groups : Nat) (geometry : Geometry bits buffers steps (4*groups))
    (inputStorage : ArrayStorage.BFBuffer input) (bounded : 2*(4*groups) ≤ 2^64) : Execution bits p input buffers groups :=
  ⟨geometry, inputStorage, bounded, CopyContiguous.Trace.canonical 0 _ (fun _ => 0) (by decide)⟩

variable {bits : Bits} {p : AffineRow.Platform} {input : Fin (steps*512) → BF} {buffers : AffineLoads.Buffers} {groups : Nat}

def Execution.buffer (execution : Execution bits p input buffers groups) :
    ArrayStorage.BFBuffer (produced bits p execution.inputStorage buffers (rows := 4*groups)) where
  bytes := execution.stores.memory
  base := 0
  aligned := by decide
  bounded := by simpa only [Nat.zero_add] using execution.outputBounded
  attached := execution.stores.read_correct

def Execution.output (execution : Execution bits p input buffers groups) : Fin (4*groups) → BF := execution.buffer.read
def Execution.outputBuffer (execution : Execution bits p input buffers groups) : ArrayStorage.BFBuffer execution.output :=
  ArrayViews.readback execution.buffer

theorem Execution.output_bytes (execution : Execution bits p input buffers groups) : execution.outputBuffer.bytes=execution.stores.memory := rfl

theorem Execution.output3 (execution : Execution .three p input buffers groups) (row : Fin (4*groups)) :
    execution.output row=AffineRow.output p (AffineRow.tiles3 p input (AffineLoads.weights3 buffers row)) := by
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct]
  unfold produced
  exact AffineLoads.forward3_input p input execution.inputStorage buffers row

theorem Execution.output4 (execution : Execution .four p input buffers groups) (row : Fin (4*groups)) :
    execution.output row=AffineRow.output p (AffineRow.tiles4 p input (AffineLoads.weights4 buffers row)) := by
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct]
  unfold produced
  exact AffineLoads.forward4_input p input execution.inputStorage buffers row

theorem store_owner (block : Fin blocks) (simd : Fin 2) (row : Fin 4) :
    (CopyContiguous.index (blocks := 2*blocks) ⟨block.val*2+simd.val, by have := block.isLt; have := simd.isLt; omega⟩ row).val=
      (MlxQmv.outputIndex block simd row).val := by
  dsimp [CopyContiguous.index, MlxQmv.outputIndex]
  omega

theorem selected (steps blocks limit : Nat) (hl : 1<limit) : MlxQmv.selectedFast (steps*512) (4*(2*blocks)) limit=true := by
  have equal : 4*(2*blocks)=blocks*8 := by omega
  rw [equal]
  exact MlxQmv.selected steps blocks limit hl

end Inference.Kernels.Quantization.MlxQmvDevice
