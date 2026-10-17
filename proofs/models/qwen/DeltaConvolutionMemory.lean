import kernels.delta.ConvolutionMemory
import models.qwen.DeltaPreparedMemory

namespace Inference.Models.Qwen.DeltaConvolutionMemory
open Contracts.Mlx Kernels.Delta
set_option maxRecDepth 10000

variable {history : State.ConvolutionStorage.History} {next : Fin 10240 → ArrayStorage.BF}
  {weights : Fin 10240 → Fin 4 → ArrayStorage.BF} {input : ConvolutionMemory.Input history next weights}
  {contracted : Bool} {convolution : ConvolutionMemory.Execution input contracted}
  {qScale kScale : Fin 128 → ArrayStorage.BF}
  {headPlatform : SiluRmsHeads.Platform} {width eps : Float32}
  {aLog a dtBias b : GateDevice.Heads} {gatePlatform : Inputs.Platform}

structure Scales (convolution : ConvolutionMemory.Execution input contracted) (qScale kScale : Fin 128 → ArrayStorage.BF) where
  query : ArrayStorage.BFBuffer qScale
  key : ArrayStorage.BFBuffer kScale
  queryShared : query.bytes=input.window.joined.old.bytes
  keyShared : key.bytes=input.window.joined.old.bytes
  querySafe : ConvolutionMemory.Safe convolution query.base 256
  keySafe : ConvolutionMemory.Safe convolution key.base 256

def Scales.headInput (scales : Scales convolution qScale kScale) : Layers.DeltaHeadsMemory.Input convolution.output qScale kScale where
  storage := {
    input := convolution.outputBuffer
    qScale := ArrayFrame.bf scales.query convolution.outputBuffer.bytes
      (fun offset bound => (convolution.other_region scales.querySafe offset bound).trans (congrFun scales.queryShared _).symm)
    kScale := ArrayFrame.bf scales.key convolution.outputBuffer.bytes
      (fun offset bound => (convolution.other_region scales.keySafe offset bound).trans (congrFun scales.keyShared _).symm) }
  queryShared := rfl
  keyShared := rfl

def gatesAfterConvolution (convolution : ConvolutionMemory.Execution input contracted)
    (source : GateMemory.Input aLog a dtBias b) (shared : source.storage.logarithm.bytes=input.window.joined.old.bytes)
    (safe : source.Protected (fun base => ConvolutionMemory.Safe convolution base 96)) : GateMemory.Input aLog a dtBias b :=
  source.reframe convolution.outputBuffer.bytes
    ⟨fun offset bound => (convolution.other_region safe.1 offset bound).trans (congrFun shared _).symm,
      fun offset bound => (convolution.other_region safe.2.1 offset bound).trans (congrFun shared _).symm,
      fun offset bound => (convolution.other_region safe.2.2.1 offset bound).trans (congrFun shared _).symm,
      fun offset bound => (convolution.other_region safe.2.2.2 offset bound).trans (congrFun shared _).symm⟩

structure Execution (convolution : ConvolutionMemory.Execution input contracted)
    (qScale kScale : Fin 128 → ArrayStorage.BF) (headPlatform : SiluRmsHeads.Platform) (width eps : Float32)
    (aLog a dtBias b : GateDevice.Heads) (gatePlatform : Inputs.Platform) where
  scales : Scales convolution qScale kScale
  heads : Layers.DeltaHeadsMemory.Execution scales.headInput headPlatform width eps
  gateSource : GateMemory.Input aLog a dtBias b
  gateShared : gateSource.storage.logarithm.bytes=input.window.joined.old.bytes
  gateSafe : gateSource.Protected (fun base => ConvolutionMemory.Safe convolution base 96)
  prepared : DeltaPreparedMemory.Execution heads aLog a dtBias b gatePlatform
  linked : prepared.source=gatesAfterConvolution convolution gateSource gateShared gateSafe

def Safe (execution : Execution convolution qScale kScale headPlatform width eps aLog a dtBias b gatePlatform) (base size : Nat) : Prop :=
  ConvolutionMemory.Safe convolution base size ∧ DeltaPreparedMemory.Safe execution.prepared base size

theorem Execution.other_region (execution : Execution convolution qScale kScale headPlatform width eps aLog a dtBias b gatePlatform)
    {base size : Nat} (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.prepared.gates.betaBuffer.bytes (base+offset)=input.window.joined.old.bytes (base+offset) :=
  (execution.prepared.other_region safe.2 offset bound).trans (convolution.other_region safe.1 offset bound)

def Execution.recurrenceInput (execution : Execution convolution qScale kScale headPlatform width eps aLog a dtBias b gatePlatform)
    {initial : GatedDevice.State} (state : GatedDevice.Storage initial)
    (shared : state.bytes=input.window.joined.old.bytes) (safe : Safe execution state.base 3145728) :
    GatedShared.Input initial execution.prepared.values where
  state := GatedShared.stateFrame state execution.prepared.gates.betaBuffer.bytes
    (fun offset bound => (execution.other_region safe offset bound).trans (congrFun shared _).symm)
  operands := execution.prepared.operands
  keyShared := rfl
  queryShared := rfl
  valueShared := rfl
  decayShared := rfl
  betaShared := rfl

def Execution.historyAfter (execution : Execution convolution qScale kScale headPlatform width eps aLog a dtBias b gatePlatform)
    (safe : DeltaPreparedMemory.Safe execution.prepared convolution.afterHistory.base 61440) :
    State.ConvolutionStorage.Storage (Convolution.tail history (fun _ => next) 1) :=
  ArrayFrame.bf convolution.afterHistory execution.prepared.gates.betaBuffer.bytes (execution.prepared.other_region safe)

def Execution.inputCache (execution : Execution convolution qScale kScale headPlatform width eps aLog a dtBias b gatePlatform)
    {initial : GatedDevice.State} (state : GatedDevice.Storage initial)
    (shared : state.bytes=input.window.joined.old.bytes) (stateSafe : Safe execution state.base 3145728)
    (historySafe : DeltaPreparedMemory.Safe execution.prepared convolution.afterHistory.base 61440) :
    DeltaRegions.Storage ⟨Convolution.tail history (fun _ => next) 1, initial⟩ where
  buffers := {
    history := execution.historyAfter historySafe
    recurrent := (execution.recurrenceInput state shared stateSafe).state }
  shared := rfl
  separate := stateSafe.1.2.1

theorem Execution.heads_eq (execution : Execution convolution qScale kScale headPlatform width eps aLog a dtBias b gatePlatform) :
    execution.heads.output=Layers.DeltaHeads.forward (rows := 1) headPlatform
      (fun _ channel => Convolution.value contracted (fun tap => Convolution.streamWindow history next tap channel) (weights channel))
      qScale kScale width eps := by
  have convolved := funext convolution.output_eq
  exact execution.heads.output_eq.trans
    (congrArg (fun source => Layers.DeltaHeads.forward (rows := 1) headPlatform (fun _ => source) qScale kScale width eps) convolved)

end Inference.Models.Qwen.DeltaConvolutionMemory
