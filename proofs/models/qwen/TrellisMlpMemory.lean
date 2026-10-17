import models.qwen.TrellisMlpSource
import kernels.trellis.OutputRegions

namespace Inference.Models.Qwen.TrellisMlpMemory
open Contracts.Mlx Kernels.Trellis Layers WrittenLayers
set_option maxRecDepth 10000

structure Execution (mlp : GateDown) (input : Fin 5120 → ArrayStorage.BF) where
  device : TrellisMlpSource.Execution mlp input
  middleInitial : device.kernel.middle.before=device.source.bytes
  partialInitial : device.kernel.down.partialBefore=device.kernel.middle.memory
  outputInitial : device.kernel.output.before=device.kernel.down.memory
  inputSeparate : MemoryRegions.Disjoint device.kernel.middle.base 34816 device.source.base 10240
  middleSeparate : MemoryRegions.Disjoint device.kernel.down.partialBase 655360 device.kernel.middle.base 34816
  partialSeparate : MemoryRegions.Disjoint device.kernel.output.base 10240 device.kernel.down.partialBase 655360

def fromTraces (mlp : GateDown) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (staging : Nat → GateUpSource.Trace mlp.gatePlatform.base source)
    (middle : GateUpOutput.Trace (TrellisMlpDevice.activation mlp (ArrayStorage.bfWords input) (fun group => (staging group).staged)))
    (down : DownDevice.Trace mlp.downPlatform.load (fun ty => FloatMemory.encode (mlp.downPlatform.before ty))
      mlp.downPlatform.base mlp.down.words mlp.down.width mlp.down.scale middle.read)
    (output : DownOutput.Trace (DownOutput.foldValues down mlp.downPlatform.reduce))
    (middleInitial : middle.before=source.bytes) (partialInitial : down.partialBefore=middle.memory) (outputInitial : output.before=down.memory)
    (inputSeparate : MemoryRegions.Disjoint middle.base 34816 source.base 10240)
    (middleSeparate : MemoryRegions.Disjoint down.partialBase 655360 middle.base 34816)
    (partialSeparate : MemoryRegions.Disjoint output.base 10240 down.partialBase 655360) : Execution mlp input :=
  ⟨⟨source, staging, ⟨(fun group => (staging group).staged), middle, down, output⟩, rfl⟩,
    middleInitial, partialInitial, outputInitial, inputSeparate, middleSeparate, partialSeparate⟩

def fromDown (mlp : GateDown) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (staging : Nat → GateUpSource.Trace mlp.gatePlatform.base source)
    (middle : GateUpOutput.Trace (TrellisMlpDevice.activation mlp (ArrayStorage.bfWords input) (fun group => (staging group).staged)))
    (down : DownDevice.Trace mlp.downPlatform.load (fun ty => FloatMemory.encode (mlp.downPlatform.before ty))
      mlp.downPlatform.base mlp.down.words mlp.down.width mlp.down.scale middle.read)
    (middleInitial : middle.before=source.bytes) (partialInitial : down.partialBefore=middle.memory)
    (inputSeparate : MemoryRegions.Disjoint middle.base 34816 source.base 10240)
    (middleSeparate : MemoryRegions.Disjoint down.partialBase 655360 middle.base 34816)
    (outputBase : Nat) (outputAligned : outputBase%2=0) (outputBound : outputBase+10240 ≤ 2^64)
    (partialSeparate : MemoryRegions.Disjoint outputBase 10240 down.partialBase 655360) : Execution mlp input :=
  let output := DownOutput.Trace.canonical (DownOutput.foldValues down mlp.downPlatform.reduce) down.memory outputBase outputAligned outputBound
  fromTraces mlp input source staging middle down output middleInitial partialInitial rfl inputSeparate middleSeparate partialSeparate

def fromMiddle (mlp : GateDown) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (staging : Nat → GateUpSource.Trace mlp.gatePlatform.base source)
    (middle : GateUpOutput.Trace (TrellisMlpDevice.activation mlp (ArrayStorage.bfWords input) (fun group => (staging group).staged)))
    (middleInitial : middle.before=source.bytes) (inputSeparate : MemoryRegions.Disjoint middle.base 34816 source.base 10240)
    (partialBase outputBase : Nat) (partialAligned : partialBase%16=0) (outputAligned : outputBase%2=0)
    (partialBound : partialBase+655360 ≤ 2^64) (outputBound : outputBase+10240 ≤ 2^64)
    (middleSeparate : MemoryRegions.Disjoint partialBase 655360 middle.base 34816)
    (partialSeparate : MemoryRegions.Disjoint outputBase 10240 partialBase 655360) : Execution mlp input :=
  let down := DownDevice.Trace.canonical mlp.downPlatform.load (fun ty => FloatMemory.encode (mlp.downPlatform.before ty))
    mlp.downPlatform.base mlp.down.words mlp.down.width mlp.down.scale middle.read middle.memory partialBase partialAligned partialBound
  fromDown mlp input source staging middle down middleInitial rfl inputSeparate middleSeparate outputBase outputAligned outputBound partialSeparate

@[irreducible] def canonical (mlp : GateDown) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (sourceAligned : source.base%16=0)
    (middleBase partialBase outputBase : Nat)
    (middleAligned : middleBase%2=0) (partialAligned : partialBase%16=0) (outputAligned : outputBase%2=0)
    (middleBound : middleBase+34816 ≤ 2^64) (partialBound : partialBase+655360 ≤ 2^64) (outputBound : outputBase+10240 ≤ 2^64)
    (inputSeparate : MemoryRegions.Disjoint middleBase 34816 source.base 10240)
    (middleSeparate : MemoryRegions.Disjoint partialBase 655360 middleBase 34816)
    (partialSeparate : MemoryRegions.Disjoint outputBase 10240 partialBase 655360) : Execution mlp input :=
  let staging := fun _ : Nat => GateUpSource.Trace.canonical mlp.gatePlatform.base source sourceAligned
  let gate := fun group => (staging group).staged
  let middle := GateUpOutput.Trace.canonical (TrellisMlpDevice.activation mlp (ArrayStorage.bfWords input) gate)
    source.bytes middleBase middleAligned middleBound
  fromMiddle mlp input source staging middle rfl inputSeparate partialBase outputBase partialAligned outputAligned
    partialBound outputBound middleSeparate partialSeparate

variable {mlp : GateDown} {input : Fin 5120 → ArrayStorage.BF}

def Execution.source (execution : Execution mlp input) : ArrayStorage.BFBuffer input := execution.device.source
def Execution.output (execution : Execution mlp input) : Fin 5120 → ArrayStorage.BF := execution.device.output
def Execution.outputBuffer (execution : Execution mlp input) : ArrayStorage.BFBuffer execution.output := execution.device.outputBuffer

theorem Execution.output_eq (execution : Execution mlp input) : execution.output=mlp.forward (Blocks.packed input) :=
  execution.device.output_eq

-- Staging loads can interleave with writes from other producer groups.
-- All protected source bytes retain their values throughout that phase.
theorem Execution.input_stable (execution : Execution mlp input) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.device.kernel.middle.base 34816 stores) (offset : Nat) (bound : offset<10240) :
    HalfMemory.execute stores execution.source.bytes (execution.source.base+offset)=execution.source.bytes (execution.source.base+offset) :=
  MemoryRegions.execute16_other stores execution.source.bytes inside execution.inputSeparate offset bound

theorem Execution.staged_load (execution : Execution mlp input) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.device.kernel.middle.base 34816 stores)
    (chunk word : Nat) (chunkBound : chunk<640) (wordBound : word<4) :
    ByteMemory.load32 (HalfMemory.execute stores execution.source.bytes)
      (execution.source.base+16*GateUpCodebook.stagedChunk chunk+4*word)=
      ByteMemory.load32 execution.source.bytes (execution.source.base+16*GateUpCodebook.stagedChunk chunk+4*word) := by
  have bound := GateUpSource.source_bounds execution.source chunk word chunkBound wordBound
  have same := ArrayFrame.word_congr execution.source.bytes (HalfMemory.execute stores execution.source.bytes)
    execution.source.base 10240 (16*GateUpCodebook.stagedChunk chunk+4*word) (execution.input_stable stores inside) (by omega)
  simpa only [Nat.add_assoc] using same

theorem Execution.middle_load (execution : Execution mlp input) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 execution.device.kernel.down.partialBase 655360 stores)
    (row : Nat) (bound : row<17408) :
    HalfMemory.load (ByteMemory.execute stores execution.device.kernel.middle.memory) (execution.device.kernel.middle.base+2*row)=
      HalfMemory.load execution.device.kernel.middle.memory (execution.device.kernel.middle.base+2*row) :=
  ArrayFrame.half_congr _ _ _ _ _
    (MemoryRegions.execute32_other stores execution.device.kernel.middle.memory inside execution.middleSeparate) (by omega)

theorem Execution.partial_load (execution : Execution mlp input) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.device.kernel.output.base 10240 stores)
    (lane column : Nat) (laneBound : lane<32) (columnBound : column<5120) :
    FloatMemory.load (HalfMemory.execute stores execution.device.kernel.down.memory)
      (execution.device.kernel.down.partialBase+4*(lane*5120+column))=execution.device.kernel.down.read lane column := by
  unfold FloatMemory.load DownDevice.Trace.read
  congr 1
  exact ArrayFrame.word_congr _ _ _ _ _
    (MemoryRegions.execute16_other stores execution.device.kernel.down.memory inside execution.partialSeparate) (by omega)

def Safe (execution : Execution mlp input) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint execution.device.kernel.middle.base 34816 base size ∧
    MemoryRegions.Disjoint execution.device.kernel.down.partialBase 655360 base size ∧
    MemoryRegions.Disjoint execution.device.kernel.output.base 10240 base size

theorem Execution.other_region (execution : Execution mlp input) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=execution.source.bytes (base+offset) :=
  (OutputRegions.fold_frame execution.device.kernel.output safe.2.2 offset bound).trans
    ((congrFun execution.outputInitial (base+offset)).trans
      ((OutputRegions.down_frame execution.device.kernel.down safe.2.1 offset bound).trans
        ((congrFun execution.partialInitial (base+offset)).trans
          ((OutputRegions.gate_frame execution.device.kernel.middle safe.1 offset bound).trans
            (congrFun execution.middleInitial (base+offset))))))

theorem Execution.memory (execution : Execution mlp input) :
    execution.outputBuffer.bytes=HalfMemory.execute execution.device.kernel.output.schedule
      (FloatMemory.execute execution.device.kernel.down.schedule
        (HalfMemory.execute execution.device.kernel.middle.schedule execution.source.bytes)) := by
  change execution.device.kernel.output.memory=_
  unfold DownOutput.Trace.memory
  rw [execution.outputInitial]
  unfold DownDevice.Trace.memory
  rw [execution.partialInitial]
  unfold GateUpOutput.Trace.memory
  rw [execution.middleInitial]
  rfl

end Inference.Models.Qwen.TrellisMlpMemory
