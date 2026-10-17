import kernels.quantization.MlxQmv
import contracts.mlx.ArrayStorage

namespace Inference.Kernels.Quantization.AffineLoads
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := ArrayStorage.BF

-- Group-size-64, row-contiguous affine storage. Packed bytes are loaded
-- without floating conversion; scale and bias pointers read BF16 words.
structure Buffers where
  packed : ByteMemory.Bytes
  packedBase : Nat
  scales : HalfMemory.Bytes
  scaleBase : Nat
  biases : HalfMemory.Bytes
  biasBase : Nat

def groupIndex (row : Fin rows) (group : Fin (steps*8)) : Nat := row.val*(steps*8)+group.val

def scale (buffers : Buffers) (row : Fin rows) (group : Fin (steps*8)) : BF :=
  Model.ofBits (HalfMemory.load buffers.scales (buffers.scaleBase+2*groupIndex row group))
def bias (buffers : Buffers) (row : Fin rows) (group : Fin (steps*8)) : BF :=
  Model.ofBits (HalfMemory.load buffers.biases (buffers.biasBase+2*groupIndex row group))

def weights3 (buffers : Buffers) (row : Fin rows) : AffineRow.Weights3 steps where
  bytes step lane chunk byte := buffers.packed (buffers.packedBase+
    AffineLayout.weightOffset 3 row.val steps step.val lane.val (chunk.val*3+byte.val))
  scale := scale buffers row
  bias := bias buffers row

def weights4 (buffers : Buffers) (row : Fin rows) : AffineRow.Weights4 steps where
  words step lane chunk := HalfMemory.load buffers.packed (buffers.packedBase+
    AffineLayout.weightOffset 4 row.val steps step.val lane.val (chunk.val*2))
  scale := scale buffers row
  bias := bias buffers row

theorem group_bound (row : Fin rows) (group : Fin (steps*8)) : groupIndex row group<rows*(steps*8) := by
  have := row.isLt
  have := group.isLt
  unfold groupIndex
  nlinarith

theorem group_address (base : Nat) (aligned : base%2=0) (bounded : base+2*(rows*(steps*8)) ≤ 2^64)
    (row : Fin rows) (group : Fin (steps*8)) :
    (base+2*groupIndex row group)%2=0 ∧ base+2*groupIndex row group+2 ≤ 2^64 := by
  have := group_bound row group
  omega

theorem packed3_bounds (base : Nat) (bounded : base+rows*(steps*64*3) ≤ 2^64)
    (row : Fin rows) (step : Fin steps) (lane : Fin 32) (chunk : Fin 2) (byte : Fin 3) :
    base+AffineLayout.weightOffset 3 row.val steps step.val lane.val (chunk.val*3+byte.val)<2^64 := by
  have := AffineLayout.weight_bound 3 (Or.inl rfl) row step lane _ (AffineLayout.three_bit_byte chunk byte)
  omega

theorem packed4_bounds (base : Nat) (aligned : base%2=0) (bounded : base+rows*(steps*64*4) ≤ 2^64)
    (row : Fin rows) (step : Fin steps) (lane : Fin 32) (chunk : Fin 4) :
    (base+AffineLayout.weightOffset 4 row.val steps step.val lane.val (chunk.val*2))%2=0 ∧
    base+AffineLayout.weightOffset 4 row.val steps step.val lane.val (chunk.val*2)+2 ≤ 2^64 := by
  have last := AffineLayout.weight_bound 4 (Or.inr rfl) row step lane (chunk.val*2+1) (by have := chunk.isLt; omega)
  constructor
  · simp [AffineLayout.weightOffset, Nat.add_mod, Nat.mul_mod, aligned]
  · dsimp [AffineLayout.weightOffset] at last ⊢
    omega

def forward3 {input : Fin (steps*512) → BF} (p : AffineRow.Platform) (x : ArrayStorage.BFBuffer input) (buffers : Buffers) (row : Fin rows) : BF :=
  AffineRow.output p (MlxQmv.tiles3 (steps := steps) p x.read (weights3 buffers row))
def forward4 {input : Fin (steps*512) → BF} (p : AffineRow.Platform) (x : ArrayStorage.BFBuffer input) (buffers : Buffers) (row : Fin rows) : BF :=
  AffineRow.output p (MlxQmv.tiles4 (steps := steps) p x.read (weights4 buffers row))

theorem forward3_input (p : AffineRow.Platform) (input : Fin (steps*512) → BF) (x : ArrayStorage.BFBuffer input)
    (buffers : Buffers) (row : Fin rows) : forward3 p x buffers row=AffineRow.output p (AffineRow.tiles3 p input (weights3 buffers row)) := by
  have read : x.read=input := funext x.read_correct
  unfold forward3
  rw [read, MlxQmv.tiles3_eq]

theorem forward4_input (p : AffineRow.Platform) (input : Fin (steps*512) → BF) (x : ArrayStorage.BFBuffer input)
    (buffers : Buffers) (row : Fin rows) : forward4 p x buffers row=AffineRow.output p (AffineRow.tiles4 p input (weights4 buffers row)) := by
  have read : x.read=input := funext x.read_correct
  unfold forward4
  rw [read, MlxQmv.tiles4_eq]

end Inference.Kernels.Quantization.AffineLoads
