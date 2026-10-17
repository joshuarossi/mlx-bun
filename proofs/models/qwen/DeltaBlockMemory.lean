import models.qwen.DeltaConvolutionMemory
import models.qwen.DeltaResidualMemory

namespace Inference.Models.Qwen.DeltaBlockMemory
open Contracts.Mlx Kernels Kernels.Delta DecodeStage DecodeChain
set_option maxRecDepth 10000

variable {history : State.ConvolutionStorage.History} {next : Fin 10240 → ArrayStorage.BF}
  {convWeights : Fin 10240 → Fin 4 → ArrayStorage.BF} {convInput : ConvolutionMemory.Input history next convWeights}
  {contracted : Bool} {convolution : ConvolutionMemory.Execution convInput contracted}
  {qScale kScale : Fin 128 → ArrayStorage.BF} {headPlatform : SiluRmsHeads.Platform} {width eps : Float32}
  {aLog a dtBias b : GateDevice.Heads} {gatePlatform : Inputs.Platform}
  {preparation : DeltaConvolutionMemory.Execution convolution qScale kScale headPlatform width eps aLog a dtBias b gatePlatform}

def residualBeforeRecurrence (preparation : DeltaConvolutionMemory.Execution convolution qScale kScale headPlatform width eps aLog a dtBias b gatePlatform)
    {x : Fin 5120 → ArrayStorage.BF} (source : ArrayStorage.BFBuffer x)
    (shared : source.bytes=convInput.window.joined.old.bytes) (safe : DeltaConvolutionMemory.Safe preparation source.base 10240) :
    ArrayStorage.BFBuffer x :=
  ArrayFrame.bf source preparation.prepared.gates.betaBuffer.bytes
    (fun offset bound => (preparation.other_region safe offset bound).trans (congrFun shared _).symm)

-- This composition begins with the already projected QKV and gate inputs.
-- Input normalization and those affine projections still have to be joined.
structure Execution (preparation : DeltaConvolutionMemory.Execution convolution qScale kScale headPlatform width eps aLog a dtBias b gatePlatform)
    (initial : GatedDevice.State) (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction)
    (gate : GatedRmsNormDevice.Rows) (normWeights : Fin 128 → ArrayStorage.BF)
    (normalization : GatedRmsNorm.Platform) (projection : Layers.AffineVerifyLinear.Projection 12 5120)
    (block : ResidualBlocks.Mlp) (x : Fin 5120 → ArrayStorage.BF) where
  state : GatedDevice.Storage initial
  stateShared : state.bytes=convInput.window.joined.old.bytes
  stateSafe : DeltaConvolutionMemory.Safe preparation state.base 3145728
  historySafe : DeltaPreparedMemory.Safe preparation.prepared convolution.afterHistory.base 61440
  source : ArrayStorage.BFBuffer x
  sourceShared : source.bytes=convInput.window.joined.old.bytes
  sourceSafe : DeltaConvolutionMemory.Safe preparation source.base 10240
  recurrence : GatedShared.Execution reduce flags initial preparation.prepared.values
  linked : recurrence.input=preparation.recurrenceInput state stateShared stateSafe
  tailInput : DeltaTailMemory.Input recurrence gate normWeights
  tail : DeltaTailMemory.Execution tailInput normalization width eps projection
  suffix : DeltaResidualMemory.Execution tail block x (Convolution.tail history (fun _ => next) 1)
  residualLinked : suffix.source=residualBeforeRecurrence preparation source sourceShared sourceSafe
  historyLinked : suffix.historyBuffer=preparation.historyAfter historySafe

variable {initial : GatedDevice.State} {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}
  {gate : GatedRmsNormDevice.Rows} {normWeights : Fin 128 → ArrayStorage.BF} {normalization : GatedRmsNorm.Platform}
  {projection : Layers.AffineVerifyLinear.Projection 12 5120} {block : ResidualBlocks.Mlp} {x : Fin 5120 → ArrayStorage.BF}

def Execution.output (execution : Execution preparation initial reduce flags gate normWeights normalization projection block x) :
    Fin 5120 → ArrayStorage.BF := execution.suffix.output

def Execution.outputBuffer (execution : Execution preparation initial reduce flags gate normWeights normalization projection block x) :
    ArrayStorage.BFBuffer execution.output := execution.suffix.outputBuffer

def Execution.afterCache (execution : Execution preparation initial reduce flags gate normWeights normalization projection block x) :
    DeltaRegions.Storage ⟨Convolution.tail history (fun _ => next) 1, execution.recurrence.state⟩ := execution.suffix.afterCache

theorem Execution.cache_output_shared (execution : Execution preparation initial reduce flags gate normWeights normalization projection block x) :
    execution.afterCache.memory=execution.outputBuffer.bytes := rfl

theorem Execution.input_memory (execution : Execution preparation initial reduce flags gate normWeights normalization projection block x) :
    execution.recurrence.input.state.bytes=preparation.prepared.gates.betaBuffer.bytes :=
  congrArg (fun input : GatedShared.Input initial preparation.prepared.values => input.state.bytes) execution.linked

theorem Execution.state_eq (execution : Execution preparation initial reduce flags gate normWeights normalization projection block x) :
    execution.afterCache.buffers.recurrent.read=GatedDevice.producedState reduce flags initial preparation.prepared.values.inputs :=
  execution.suffix.recurrent_eq

theorem Execution.output_eq (execution : Execution preparation initial reduce flags gate normWeights normalization projection block x) :
    execution.output=block.forward x (projection.forward (GatedInputs.flatten (fun head =>
      GatedRmsNorm.value normalization (GatedDevice.producedOutput reduce flags initial preparation.prepared.values.inputs head)
        (gate head) normWeights width eps))) := execution.suffix.output_eq

def Safe (execution : Execution preparation initial reduce flags gate normWeights normalization projection block x) (base size : Nat) : Prop :=
  DeltaConvolutionMemory.Safe preparation base size ∧ DeltaResidualMemory.Safe execution.suffix base size

theorem Execution.other_region (execution : Execution preparation initial reduce flags gate normWeights normalization projection block x)
    {base size : Nat} (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=convInput.window.joined.old.bytes (base+offset) :=
  (execution.suffix.other_region safe.2 offset bound).trans
    ((congrFun execution.input_memory _).trans (preparation.other_region safe.1 offset bound))

def Execution.retainedCaches {n : Nat} (execution : Execution preparation initial reduce flags gate normWeights normalization projection block x)
    (stages : List Stage) (cache : Caches stages n) (storage : DecodeFrame.Storage stages cache convInput.window.joined.old.bytes)
    (safe : DecodePreservation.Protected (Safe execution) stages cache convInput.window.joined.old.bytes storage) :
    DecodeFrame.Storage stages cache execution.outputBuffer.bytes :=
  DecodePreservation.reframe (Safe execution) convInput.window.joined.old.bytes execution.outputBuffer.bytes
    (fun _ _ region => execution.other_region region) stages cache storage safe

end Inference.Models.Qwen.DeltaBlockMemory
