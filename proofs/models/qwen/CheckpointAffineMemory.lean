import models.qwen.CheckpointAffine
import kernels.quantization.AffineLoads
import kernels.quantization.MlxQmvDevice
import contracts.mlx.TensorMemory
import layers.AffineDevice

namespace Inference.Models.Qwen.CheckpointAffineMemory
open Contracts.Mlx Kernels.Quantization Layers.AffineVerifyLinear
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def buffers (weights : Fin (rows*(steps*64*bits)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8)
    (weightBase scaleBase biasBase : Nat) : AffineLoads.Buffers :=
  ⟨TensorMemory.place weights weightBase (fun _ => 0), weightBase,
    TensorMemory.place scales scaleBase (fun _ => 0), scaleBase,
    TensorMemory.place biases biasBase (fun _ => 0), biasBase⟩

theorem scale_eq (weights : Fin (rows*(steps*64*bits)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (row : Fin rows) (group : Fin (steps*8)) :
    AffineLoads.scale (buffers weights scales biases wb sb bb) row group=CheckpointRanges.matrix scales row group := by
  exact congrArg (fun word : BitVec 16 => (Model.ofBits word : ArrayStorage.BF))
    (TensorMemory.load16 scales sb (fun _ => 0) (CheckpointRanges.flatIndex row group))

theorem bias_eq (weights : Fin (rows*(steps*64*bits)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (row : Fin rows) (group : Fin (steps*8)) :
    AffineLoads.bias (buffers weights scales biases wb sb bb) row group=CheckpointRanges.matrix biases row group := by
  exact congrArg (fun word : BitVec 16 => (Model.ofBits word : ArrayStorage.BF))
    (TensorMemory.load16 biases bb (fun _ => 0) (CheckpointRanges.flatIndex row group))

theorem packed3_eq (weights : Fin (rows*(steps*64*3)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (row : Fin rows) (step : Fin steps) (lane : Fin 32) (chunk : Fin 2) (byte : Fin 3) :
    (AffineLoads.weights3 (buffers weights scales biases wb sb bb) row).bytes step lane chunk byte=
      CheckpointAffine.weightByte 3 (Or.inl rfl) weights row step lane (chunk.val*3+byte.val) (AffineLayout.three_bit_byte chunk byte) := by
  exact TensorMemory.placed_byte weights wb (fun _ => 0) ⟨_, AffineLayout.weight_bound 3 (Or.inl rfl) row step lane _ (AffineLayout.three_bit_byte chunk byte)⟩

private theorem little_word (low high : BitVec 8) : high ++ low=TensorWords.littleEndian16 low high := by
  apply BitVec.eq_of_toNat_eq
  rw [AffineLayout.little_endian_word, TensorWords.littleEndian16_value]

theorem packed4_eq (weights : Fin (rows*(steps*64*4)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (row : Fin rows) (step : Fin steps) (lane : Fin 32) (chunk : Fin 4) :
    (AffineLoads.weights4 (buffers weights scales biases wb sb bb) row).words step lane chunk=
      ((CheckpointAffine.projection4 platform weights scales biases).weights row).words step lane chunk := by
  let offset := AffineLayout.weightOffset 4 row.val steps step.val lane.val (chunk.val*2)
  have lo : offset<rows*(steps*64*4) := AffineLayout.weight_bound 4 (Or.inr rfl) row step lane _ (by have := chunk.isLt; omega)
  have hi : offset+1<rows*(steps*64*4) := by
    have h := AffineLayout.weight_bound 4 (Or.inr rfl) row step lane (chunk.val*2+1) (by have := chunk.isLt; omega)
    simpa only [offset, AffineLayout.weightOffset, Nat.add_assoc] using h
  change HalfMemory.load (TensorMemory.place weights wb (fun _ => 0)) (wb+offset)=_
  unfold HalfMemory.load
  simp only [Nat.add_zero, Nat.add_assoc]
  rw [TensorMemory.placed_byte weights wb _ ⟨offset+1, hi⟩, TensorMemory.placed_byte weights wb _ ⟨offset, lo⟩, little_word]
  unfold CheckpointAffine.projection4 CheckpointAffine.weightByte
  congr 2

theorem weights3_eq (platform : AffineRow.Platform) (weights : Fin (rows*(steps*64*3)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) (wb sb bb : Nat) (row : Fin rows) :
    AffineLoads.weights3 (buffers weights scales biases wb sb bb) row=(CheckpointAffine.projection3 platform weights scales biases).weights row := by
  unfold AffineLoads.weights3 CheckpointAffine.projection3
  congr 1
  · funext step lane chunk byte
    exact packed3_eq weights scales biases wb sb bb row step lane chunk byte
  · funext group
    exact scale_eq weights scales biases wb sb bb row group
  · funext group
    exact bias_eq weights scales biases wb sb bb row group

theorem weights4_eq (platform : AffineRow.Platform) (weights : Fin (rows*(steps*64*4)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) (wb sb bb : Nat) (row : Fin rows) :
    AffineLoads.weights4 (buffers weights scales biases wb sb bb) row=(CheckpointAffine.projection4 platform weights scales biases).weights row := by
  unfold AffineLoads.weights4 CheckpointAffine.projection4
  congr 1
  · funext step lane chunk
    exact packed4_eq (platform := platform) weights scales biases wb sb bb row step lane chunk
  · funext group
    exact scale_eq weights scales biases wb sb bb row group
  · funext group
    exact bias_eq weights scales biases wb sb bb row group

theorem forward3_eq (platform : AffineRow.Platform) (weights : Fin (rows*(steps*64*3)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (input : Fin (steps*512) → ArrayStorage.BF) (x : ArrayStorage.BFBuffer input) (row : Fin rows) :
    AffineLoads.forward3 platform x (buffers weights scales biases wb sb bb) row=
      (CheckpointAffine.projection3 platform weights scales biases).forward input row := by
  rw [AffineLoads.forward3_input, weights3_eq platform]
  rfl

theorem forward4_eq (platform : AffineRow.Platform) (weights : Fin (rows*(steps*64*4)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (input : Fin (steps*512) → ArrayStorage.BF) (x : ArrayStorage.BFBuffer input) (row : Fin rows) :
    AffineLoads.forward4 platform x (buffers weights scales biases wb sb bb) row=
      (CheckpointAffine.projection4 platform weights scales biases).forward input row := by
  rw [AffineLoads.forward4_input, weights4_eq platform]
  rfl

theorem device3_eq (platform : AffineRow.Platform) (weights : Fin ((4*groups)*(steps*64*3)) → BitVec 8)
    (scales biases : Fin (2*((4*groups)*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (input : Fin (steps*512) → ArrayStorage.BF)
    (execution : MlxQmvDevice.Execution .three platform input (buffers weights scales biases wb sb bb) groups)
    (row : Fin (4*groups)) : execution.output row=(CheckpointAffine.projection3 platform weights scales biases).forward input row := by
  rw [execution.output3, weights3_eq platform]
  rfl

theorem device4_eq (platform : AffineRow.Platform) (weights : Fin ((4*groups)*(steps*64*4)) → BitVec 8)
    (scales biases : Fin (2*((4*groups)*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (input : Fin (steps*512) → ArrayStorage.BF)
    (execution : MlxQmvDevice.Execution .four platform input (buffers weights scales biases wb sb bb) groups)
    (row : Fin (4*groups)) : execution.output row=(CheckpointAffine.projection4 platform weights scales biases).forward input row := by
  rw [execution.output4, weights4_eq platform]
  rfl

theorem device3_error (platform : AffineRow.Platform) (weights : Fin ((4*groups)*(steps*64*3)) → BitVec 8)
    (scales biases : Fin (2*((4*groups)*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (input : Fin (steps*512) → ArrayStorage.BF)
    (execution : MlxQmvDevice.Execution .three platform input (buffers weights scales biases wb sb bb) groups)
    (target error : Fin (steps*512) → ℝ) (hi : ∀ i, |Model.toReal (input i)-target i| ≤ error i)
    (hf : (CheckpointAffine.projection3 platform weights scales biases).Finite input) (row : Fin (4*groups)) :
    |Model.toReal (execution.output row)-(CheckpointAffine.projection3 platform weights scales biases).target target row| ≤
      (CheckpointAffine.projection3 platform weights scales biases).budget input target error row := by
  rw [device3_eq]
  exact Projection3.forward_error _ input target error hi hf row

theorem device4_error (platform : AffineRow.Platform) (weights : Fin ((4*groups)*(steps*64*4)) → BitVec 8)
    (scales biases : Fin (2*((4*groups)*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (input : Fin (steps*512) → ArrayStorage.BF)
    (execution : MlxQmvDevice.Execution .four platform input (buffers weights scales biases wb sb bb) groups)
    (target error : Fin (steps*512) → ℝ) (hi : ∀ i, |Model.toReal (input i)-target i| ≤ error i)
    (hf : (CheckpointAffine.projection4 platform weights scales biases).Finite input) (row : Fin (4*groups)) :
    |Model.toReal (execution.output row)-(CheckpointAffine.projection4 platform weights scales biases).target target row| ≤
      (CheckpointAffine.projection4 platform weights scales biases).budget input target error row := by
  rw [device4_eq]
  exact Projection4.forward_error _ input target error hi hf row

def storage3 (platform : AffineRow.Platform) (weights : Fin (rows*(steps*64*3)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (geometry : MlxQmvDevice.Geometry .three (buffers weights scales biases wb sb bb) steps rows) :
    Layers.AffineDevice.Storage3 (CheckpointAffine.projection3 platform weights scales biases) :=
  ⟨buffers weights scales biases wb sb bb, geometry, weights3_eq platform weights scales biases wb sb bb⟩

def storage4 (platform : AffineRow.Platform) (weights : Fin (rows*(steps*64*4)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (geometry : MlxQmvDevice.Geometry .four (buffers weights scales biases wb sb bb) steps rows) :
    Layers.AffineDevice.Storage4 (CheckpointAffine.projection4 platform weights scales biases) :=
  ⟨buffers weights scales biases wb sb bb, geometry, weights4_eq platform weights scales biases wb sb bb⟩

theorem storage3_bytes (platform : AffineRow.Platform) (weights : Fin (rows*(steps*64*3)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (geometry : MlxQmvDevice.Geometry .three (buffers weights scales biases wb sb bb) steps rows) :
    (storage3 platform weights scales biases wb sb bb geometry).buffers=buffers weights scales biases wb sb bb := rfl

theorem storage4_bytes (platform : AffineRow.Platform) (weights : Fin (rows*(steps*64*4)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) (wb sb bb : Nat)
    (geometry : MlxQmvDevice.Geometry .four (buffers weights scales biases wb sb bb) steps rows) :
    (storage4 platform weights scales biases wb sb bb geometry).buffers=buffers weights scales biases wb sb bb := rfl

end Inference.Models.Qwen.CheckpointAffineMemory
