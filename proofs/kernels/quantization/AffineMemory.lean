import kernels.quantization.MlxQmvDevice
import contracts.mlx.ArrayFrame

namespace Inference.Kernels.Quantization.AffineMemory
open Contracts.Mlx
set_option maxRecDepth 10000

-- Weight views share the same heap as activations. Reframing changes the
-- heap while retaining all physical addresses.
def reframe (buffers : AffineLoads.Buffers) (memory : ByteMemory.Bytes) : AffineLoads.Buffers :=
  ⟨memory, buffers.packedBase, memory, buffers.scaleBase, memory, buffers.biasBase⟩

structure Shared (buffers : AffineLoads.Buffers) (memory : ByteMemory.Bytes) : Prop where
  packed : buffers.packed=memory
  scales : buffers.scales=memory
  biases : buffers.biases=memory

structure Stable (bits : MlxQmvDevice.Bits) (buffers : AffineLoads.Buffers) (steps rows : Nat)
    (memory : ByteMemory.Bytes) : Prop where
  packed : ∀ offset < rows*(steps*64*bits.width), memory (buffers.packedBase+offset)=buffers.packed (buffers.packedBase+offset)
  scales : ∀ offset < 2*(rows*(steps*8)), memory (buffers.scaleBase+offset)=buffers.scales (buffers.scaleBase+offset)
  biases : ∀ offset < 2*(rows*(steps*8)), memory (buffers.biasBase+offset)=buffers.biases (buffers.biasBase+offset)

theorem reframe_geometry {bits : MlxQmvDevice.Bits} {buffers : AffineLoads.Buffers} {steps rows : Nat}
    (geometry : MlxQmvDevice.Geometry bits buffers steps rows) (memory : ByteMemory.Bytes) :
    MlxQmvDevice.Geometry bits (reframe buffers memory) steps rows :=
  ⟨geometry.packedAligned, geometry.packedBounded, geometry.scaleAligned, geometry.biasAligned,
    geometry.scaleBounded, geometry.biasBounded⟩

theorem scale_eq {bits : MlxQmvDevice.Bits} {buffers : AffineLoads.Buffers} {steps rows : Nat}
    {memory : ByteMemory.Bytes} (stable : Stable bits buffers steps rows memory) (row : Fin rows) (group : Fin (steps*8)) :
    AffineLoads.scale (reframe buffers memory) row group=AffineLoads.scale buffers row group := by
  unfold AffineLoads.scale
  congr 1
  exact ArrayFrame.half_congr _ _ _ _ _ stable.scales (by have := AffineLoads.group_bound row group; omega)

theorem bias_eq {bits : MlxQmvDevice.Bits} {buffers : AffineLoads.Buffers} {steps rows : Nat}
    {memory : ByteMemory.Bytes} (stable : Stable bits buffers steps rows memory) (row : Fin rows) (group : Fin (steps*8)) :
    AffineLoads.bias (reframe buffers memory) row group=AffineLoads.bias buffers row group := by
  unfold AffineLoads.bias
  congr 1
  exact ArrayFrame.half_congr _ _ _ _ _ stable.biases (by have := AffineLoads.group_bound row group; omega)

theorem weights3_eq {buffers : AffineLoads.Buffers} {steps rows : Nat} {memory : ByteMemory.Bytes}
    (stable : Stable .three buffers steps rows memory) (row : Fin rows) :
    AffineLoads.weights3 (steps := steps) (reframe buffers memory) row=AffineLoads.weights3 buffers row := by
  have packed : (AffineLoads.weights3 (steps := steps) (reframe buffers memory) row).bytes=(AffineLoads.weights3 buffers row).bytes := by
    funext step lane chunk byte
    exact stable.packed _ (AffineLayout.weight_bound 3 (Or.inl rfl) row step lane _ (AffineLayout.three_bit_byte chunk byte))
  have scales := funext (scale_eq stable row)
  have biases := funext (bias_eq stable row)
  have parameters : ((AffineLoads.weights3 (steps := steps) (reframe buffers memory) row).scale,
      (AffineLoads.weights3 (reframe buffers memory) row).bias)=
      ((AffineLoads.weights3 buffers row).scale, (AffineLoads.weights3 buffers row).bias) := Prod.ext scales biases
  exact congrArg₂ (fun bytes pair => (⟨bytes, pair.1, pair.2⟩ : AffineRow.Weights3 steps)) packed parameters

theorem weights4_eq {buffers : AffineLoads.Buffers} {steps rows : Nat} {memory : ByteMemory.Bytes}
    (stable : Stable .four buffers steps rows memory) (row : Fin rows) :
    AffineLoads.weights4 (steps := steps) (reframe buffers memory) row=AffineLoads.weights4 buffers row := by
  have packed : (AffineLoads.weights4 (steps := steps) (reframe buffers memory) row).words=(AffineLoads.weights4 buffers row).words := by
    funext step lane chunk
    apply ArrayFrame.half_congr _ _ _ _ _ stable.packed
    have last := AffineLayout.weight_bound 4 (Or.inr rfl) row step lane (chunk.val*2+1) (by have := chunk.isLt; omega)
    dsimp only [MlxQmvDevice.Bits.width, AffineLayout.weightOffset] at last ⊢
    omega
  have scales := funext (scale_eq stable row)
  have biases := funext (bias_eq stable row)
  have parameters : ((AffineLoads.weights4 (steps := steps) (reframe buffers memory) row).scale,
      (AffineLoads.weights4 (reframe buffers memory) row).bias)=
      ((AffineLoads.weights4 buffers row).scale, (AffineLoads.weights4 buffers row).bias) := Prod.ext scales biases
  exact congrArg₂ (fun words pair => (⟨words, pair.1, pair.2⟩ : AffineRow.Weights4 steps)) packed parameters

structure Separate (bits : MlxQmvDevice.Bits) (buffers : AffineLoads.Buffers) (steps rows base size : Nat) : Prop where
  packed : MemoryRegions.Disjoint base size buffers.packedBase (rows*(steps*64*bits.width))
  scales : MemoryRegions.Disjoint base size buffers.scaleBase (2*(rows*(steps*8)))
  biases : MemoryRegions.Disjoint base size buffers.biasBase (2*(rows*(steps*8)))

theorem stable_after {bits : MlxQmvDevice.Bits} {buffers : AffineLoads.Buffers} {steps rows base size : Nat}
    {before : ByteMemory.Bytes} (shared : Shared buffers before) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 base size stores) (separate : Separate bits buffers steps rows base size) :
    Stable bits buffers steps rows (HalfMemory.execute stores before) where
  packed offset bound := (MemoryRegions.execute16_other stores before inside separate.packed offset bound).trans
    (congrFun shared.packed (buffers.packedBase+offset)).symm
  scales offset bound := (MemoryRegions.execute16_other stores before inside separate.scales offset bound).trans
    (congrFun shared.scales (buffers.scaleBase+offset)).symm
  biases offset bound := (MemoryRegions.execute16_other stores before inside separate.biases offset bound).trans
    (congrFun shared.biases (buffers.biasBase+offset)).symm

theorem produced_eq {bits : MlxQmvDevice.Bits} {buffers : AffineLoads.Buffers} {steps rows : Nat}
    {input : Fin (steps*512) → ArrayStorage.BF} (p : AffineRow.Platform)
    (source : ArrayStorage.BFBuffer input) {memory : ByteMemory.Bytes}
    (inputStable : ∀ offset < 2*(steps*512), memory (source.base+offset)=source.bytes (source.base+offset))
    (stable : Stable bits buffers steps rows memory) (row : Fin rows) :
    MlxQmvDevice.produced bits p (ArrayFrame.bf source memory inputStable) (reframe buffers memory) row=
      MlxQmvDevice.produced bits p source buffers row := by
  cases bits with
  | three =>
    unfold MlxQmvDevice.produced
    rw [AffineLoads.forward3_input, AffineLoads.forward3_input, weights3_eq stable]
  | four =>
    unfold MlxQmvDevice.produced
    rw [AffineLoads.forward4_input, AffineLoads.forward4_input, weights4_eq stable]

end Inference.Kernels.Quantization.AffineMemory
