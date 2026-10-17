import models.qwen.DeltaTailMemory
import models.qwen.ResidualMlpMemory

namespace Inference.Models.Qwen.DeltaResidualMemory
open Contracts.Mlx Kernels Kernels.Delta DecodeStage DecodeChain
set_option maxRecDepth 10000

variable {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}
  {initial : GatedDevice.State} {values : GatedInputs.Values}
  {recurrence : GatedShared.Execution reduce flags initial values}
  {gate : GatedRmsNormDevice.Rows} {weights : Fin 128 → ArrayStorage.BF}
  {input : DeltaTailMemory.Input recurrence gate weights}
  {p : GatedRmsNorm.Platform} {width eps : Float32}
  {projection : Layers.AffineVerifyLinear.Projection 12 5120}
  {x : Fin 5120 → ArrayStorage.BF}

def residualInput (tail : DeltaTailMemory.Execution input p width eps projection)
    (source : ArrayStorage.BFBuffer x) (shared : source.bytes=recurrence.input.state.bytes)
    (safe : DeltaTailMemory.Safe tail source.base 10240) : BinaryMemory.Input x tail.output :=
  ⟨ArrayFrame.bf source tail.buffer.bytes (by
    intro offset bound
    exact (tail.other_region safe offset bound).trans (congrFun shared _).symm), tail.buffer, rfl⟩

structure Execution (tail : DeltaTailMemory.Execution input p width eps projection)
    (block : ResidualBlocks.Mlp) (x : Fin 5120 → ArrayStorage.BF) (history : State.ConvolutionStorage.History) where
  source : ArrayStorage.BFBuffer x
  shared : source.bytes=recurrence.input.state.bytes
  sourceSafe : DeltaTailMemory.Safe tail source.base 10240
  historyBuffer : State.ConvolutionStorage.Storage history
  historyShared : historyBuffer.bytes=recurrence.input.state.bytes
  historySafe : DeltaTailMemory.Safe tail historyBuffer.base 61440
  historyStateSeparate : MemoryRegions.Disjoint historyBuffer.base 61440 recurrence.stores.trace.stateBase 3145728
  suffix : ResidualMlpMemory.Execution block (residualInput tail source shared sourceSafe)
  suffixHistory : ResidualMlpMemory.Safe suffix historyBuffer.base 61440
  suffixState : ResidualMlpMemory.Safe suffix recurrence.stores.trace.stateBase 3145728

variable {tail : DeltaTailMemory.Execution input p width eps projection} {block : ResidualBlocks.Mlp}
  {history : State.ConvolutionStorage.History}

def Execution.output (execution : Execution tail block x history) : Fin 5120 → ArrayStorage.BF := execution.suffix.output

def Execution.outputBuffer (execution : Execution tail block x history) : ArrayStorage.BFBuffer execution.output :=
  execution.suffix.outputBuffer

def Execution.afterCache (execution : Execution tail block x history) : DeltaRegions.Storage ⟨history, recurrence.state⟩ :=
  (tail.afterCache execution.historyBuffer execution.historyShared execution.historySafe execution.historyStateSeparate).reframe
    execution.outputBuffer.bytes (execution.suffix.other_region execution.suffixHistory)
      (execution.suffix.other_region execution.suffixState)

theorem Execution.cache_output_shared (execution : Execution tail block x history) :
    execution.afterCache.memory=execution.outputBuffer.bytes := rfl

theorem Execution.recurrent_eq (execution : Execution tail block x history) :
    execution.afterCache.buffers.recurrent.read=GatedDevice.producedState reduce flags initial values.inputs :=
  execution.afterCache.buffers.recurrent.read_eq.trans recurrence.state_eq

theorem Execution.output_eq (execution : Execution tail block x history) :
    execution.output=block.forward x (projection.forward (GatedInputs.flatten (fun head =>
      GatedRmsNorm.value p (GatedDevice.producedOutput reduce flags initial values.inputs head) (gate head) weights width eps))) :=
  execution.suffix.output_eq.trans (congrArg (block.forward x) tail.output_eq)

def Safe (execution : Execution tail block x history) (base size : Nat) : Prop :=
  DeltaTailMemory.Safe tail base size ∧ ResidualMlpMemory.Safe execution.suffix base size

theorem Execution.other_region (execution : Execution tail block x history) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=recurrence.input.state.bytes (base+offset) :=
  (execution.suffix.other_region safe.2 offset bound).trans (tail.other_region safe.1 offset bound)

def Execution.retainedCaches {n : Nat} (execution : Execution tail block x history) (stages : List Stage) (cache : Caches stages n)
    (storage : DecodeFrame.Storage stages cache recurrence.input.state.bytes)
    (safe : DecodePreservation.Protected (Safe execution) stages cache recurrence.input.state.bytes storage) :
    DecodeFrame.Storage stages cache execution.outputBuffer.bytes :=
  DecodePreservation.reframe (Safe execution) recurrence.input.state.bytes execution.outputBuffer.bytes
    (fun _ _ region => execution.other_region region) stages cache storage safe

end Inference.Models.Qwen.DeltaResidualMemory
