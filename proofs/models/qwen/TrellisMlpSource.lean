import kernels.trellis.GateUpSource
import models.qwen.TrellisMlpDevice
import models.qwen.Blocks
import contracts.mlx.ArrayViews

namespace Inference.Models.Qwen.TrellisMlpSource
open Contracts.Mlx Kernels.Trellis Layers WrittenLayers
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

theorem words_eq (input : Fin 5120 → BF) : ArrayStorage.bfWords input=Blocks.packed input := rfl

-- Every producer threadgroup stages its input from the same preceding
-- activation buffer. Its completed staging trace feeds the existing kernel.
structure Execution (mlp : GateDown) (input : Fin 5120 → BF) where
  source : ArrayStorage.BFBuffer input
  staging : Nat → GateUpSource.Trace mlp.gatePlatform.base source
  kernel : TrellisMlpDevice.Execution mlp (ArrayStorage.bfWords input)
  staged : kernel.gate=fun group => (staging group).staged

@[irreducible] def Execution.fromStorage (mlp : GateDown) (input : Fin 5120 → BF)
    (source : ArrayStorage.BFBuffer input) (aligned : source.base%16=0) : Execution mlp input :=
  let staging := fun _ : Nat => GateUpSource.Trace.canonical mlp.gatePlatform.base source aligned
  let gate := fun group => (staging group).staged
  let middle := GateUpOutput.Trace.canonical (TrellisMlpDevice.activation mlp (ArrayStorage.bfWords input) gate)
    (fun _ => 0) 0 (by decide) (by decide)
  let down := DownDevice.Trace.canonical mlp.downPlatform.load (fun ty => FloatMemory.encode (mlp.downPlatform.before ty))
    mlp.downPlatform.base mlp.down.words mlp.down.width mlp.down.scale middle.read (fun _ => 0) 0 (by decide) (by decide)
  let kernel : TrellisMlpDevice.Execution mlp (ArrayStorage.bfWords input) :=
    ⟨gate, middle, down, DownOutput.Trace.canonical (DownOutput.foldValues down mlp.downPlatform.reduce)
      (fun _ => 0) 0 (by decide) (by decide)⟩
  ⟨source, staging, kernel, rfl⟩

theorem Execution.fromStorage_source (mlp : GateDown) (input : Fin 5120 → BF)
    (source : ArrayStorage.BFBuffer input) (aligned : source.base%16=0) :
    (Execution.fromStorage mlp input source aligned).source=source := by
  unfold Execution.fromStorage
  rfl

variable {mlp : GateDown} {input : Fin 5120 → BF}

def Execution.output (execution : Execution mlp input) : Fin 5120 → BF :=
  TrellisMlpDevice.forward mlp (ArrayStorage.bfWords input) execution.kernel

def Execution.outputBuffer (execution : Execution mlp input) : ArrayStorage.BFBuffer execution.output where
  bytes := execution.kernel.output.memory
  base := execution.kernel.output.base
  aligned := execution.kernel.output.aligned
  bounded := execution.kernel.output.bounded
  attached := fun _ => rfl

theorem Execution.output_eq (execution : Execution mlp input) :
    execution.output=mlp.forward (Blocks.packed input) := by
  funext i
  exact TrellisMlpDevice.forward_eq mlp (ArrayStorage.bfWords input) execution.kernel i

theorem Execution.output_bytes (execution : Execution mlp input) :
    execution.outputBuffer.bytes=execution.kernel.output.memory := rfl

theorem Execution.input_copied (execution : Execution mlp input) (group chunk offset : Nat)
    (hc : chunk<640) (ho : offset<16) :
    ByteMemory.execute (execution.kernel.gate group).schedule (execution.kernel.gate group).before
      ((execution.kernel.gate group).inputBase+16*chunk+offset)=
      execution.source.bytes (execution.source.base+16*GateUpCodebook.stagedChunk chunk+offset) := by
  rw [execution.staged]
  exact (execution.staging group).byte_copied chunk offset hc ho

def Execution.forwardBuffer (execution : Execution mlp input) : ArrayStorage.BFBuffer (mlp.forward (Blocks.packed input)) :=
  ArrayViews.reindex execution.output_eq execution.outputBuffer

theorem Execution.forward_bytes (execution : Execution mlp input) :
    execution.forwardBuffer.bytes=execution.kernel.output.memory := ArrayViews.reindex_bytes _ _

end Inference.Models.Qwen.TrellisMlpSource
