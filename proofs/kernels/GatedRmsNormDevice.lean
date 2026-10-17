import kernels.GatedRmsNorm
import kernels.delta.GatedInputs
import contracts.mlx.CopyContiguous

namespace Inference.Kernels.GatedRmsNormDevice
open Contracts.Mlx Delta.GatedInputs
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := ArrayStorage.BF
abbrev Rows := Fin 48 → Fin 128 → BF

structure Storage (x gate : Rows) (weights : Fin 128 → BF) where
  input : ArrayStorage.BFBuffer (flatten x)
  gate : ArrayStorage.BFBuffer (flatten gate)
  weight : ArrayStorage.BFBuffer weights

def Storage.canonical (x gate : Rows) (weights : Fin 128 → BF) : Storage x gate weights :=
  ⟨ArrayStorage.BFBuffer.canonical _ (by decide), ArrayStorage.BFBuffer.canonical _ (by decide),
    ArrayStorage.BFBuffer.canonical _ (by decide)⟩

-- Width 128 selects 32 threads: the multi-SIMD scratch branch is absent.
-- Each lane performs the ordered four-square accumulation, then writes
-- its four gated outputs in order. CopyContiguous supplies the same
-- four-word store scheduling theorem; the stored values are this kernel's
-- computed results, not a copy from another array.
@[irreducible] def produced (p : GatedRmsNorm.Platform) (width eps : Float32) (storage : Storage x gate weights)
    (head : Fin 48) (i : Fin 128) : BF :=
  GatedRmsNorm.tail p (BFloat16.widen (storage.gate.read (index head i)))
    (BFloat16.widen (GatedRmsNorm.sourceNormalized p (fun j => storage.input.read (index head j))
      storage.weight.read width eps i))

theorem produced_eq (p : GatedRmsNorm.Platform) (width eps : Float32) (storage : Storage x gate weights) :
    produced p width eps storage=fun head => GatedRmsNorm.value p (x head) (gate head) weights width eps := by
  funext head i
  have weightRead : storage.weight.read=weights := funext storage.weight.read_correct
  unfold produced GatedRmsNorm.value
  simp only [ArrayStorage.BFBuffer.read_correct, flatten_index, weightRead, GatedRmsNorm.normalized_execution]

structure Execution (p : GatedRmsNorm.Platform) (width eps : Float32) (x gate : Rows) (weights : Fin 128 → BF) where
  storage : Storage x gate weights
  stores : CopyContiguous.Trace 0 (blocks := 1536) (fun i => ArrayStorage.bits (flatten (produced p width eps storage) i))

def Execution.fromStorage (p : GatedRmsNorm.Platform) (width eps : Float32) (x gate : Rows) (weights : Fin 128 → BF)
    (storage : Storage x gate weights) : Execution p width eps x gate weights :=
  ⟨storage, CopyContiguous.Trace.canonical 0 _ (fun _ => 0) (by decide)⟩

variable {p : GatedRmsNorm.Platform} {width eps : Float32} {x gate : Rows} {weights : Fin 128 → BF}

def Execution.outputBuffer (execution : Execution p width eps x gate weights) :
    ArrayStorage.BFBuffer (flatten (produced p width eps execution.storage)) where
  bytes := execution.stores.memory
  base := 0
  aligned := by decide
  bounded := by decide
  attached := execution.stores.read_correct

def Execution.output (execution : Execution p width eps x gate weights) (head : Fin 48) (i : Fin 128) : BF :=
  execution.outputBuffer.read (index head i)

theorem Execution.output_eq (execution : Execution p width eps x gate weights) :
    execution.output=fun head => GatedRmsNorm.value p (x head) (gate head) weights width eps := by
  funext head i
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct, flatten_index, produced_eq]

def Execution.readbackBuffer (execution : Execution p width eps x gate weights) :
    ArrayStorage.BFBuffer (flatten execution.output) where
  bytes := execution.stores.memory
  base := 0
  aligned := by decide
  bounded := by decide
  attached := by
    intro i
    change HalfMemory.load execution.stores.memory (0+2*i.val)=
      HalfMemory.load execution.stores.memory (0+2*(i.val/128*128+i.val%128))
    congr 1
    omega

theorem Execution.readback_bytes (execution : Execution p width eps x gate weights) :
    execution.readbackBuffer.bytes=execution.stores.memory := rfl

theorem store_index (head : Fin 48) (lane : Fin 32) (i : Fin 4) :
    (CopyContiguous.index (blocks := 1536) ⟨head.val*32+lane.val, by have := head.isLt; have := lane.isLt; omega⟩ i).val=
      (index head ⟨lane.val*4+i.val, by have := lane.isLt; have := i.isLt; omega⟩).val := by
  dsimp [CopyContiguous.index, index]
  omega

theorem launch : min 1024 (((128+127)/128)*32)=32 ∧ 48*32=1536 ∧ 32*4=128 := by decide

end Inference.Kernels.GatedRmsNormDevice
