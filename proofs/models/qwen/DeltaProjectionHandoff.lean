import models.qwen.DeltaParameterMemory
import models.qwen.DeltaConvolutionMemory

namespace Inference.Models.Qwen.DeltaProjectionHandoff
open Contracts.Mlx Kernels.Delta
set_option maxRecDepth 10000

variable {layer : DeltaNet.Layer} {input : Fin 5120 → ArrayStorage.BF} {cache : DeltaNet.Cache}

def afterCache (phase : DeltaAffineMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (shared : storage.memory=phase.source.bytes)
    (historySafe : DeltaAffineMemory.Safe phase storage.buffers.history.base 61440)
    (stateSafe : DeltaAffineMemory.Safe phase storage.buffers.recurrent.base 3145728) : DeltaRegions.Storage cache :=
  storage.reframe phase.memory
    (fun offset bound => (phase.other_region historySafe offset bound).trans (congrFun shared _).symm)
    (fun offset bound => (phase.other_region stateSafe offset bound).trans (congrFun shared _).symm)

-- The QKV output and retained history enter the actual concatenation.
-- Choosing destinations and proving separation is an allocation obligation.
def joinHistory (phase : DeltaAffineMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (shared : storage.memory=phase.memory) (destination : Nat) (bounded : 2*destination+81920 ≤ 2^64)
    (historySeparate : MemoryRegions.Disjoint (2*destination) 81920 storage.buffers.history.base 61440)
    (sourceSeparate : MemoryRegions.Disjoint (2*destination) 81920 phase.qkvBuffer.base 20480) :
    State.ConvolutionMemory.Join cache.history (layer.qkv.forward input) :=
  State.ConvolutionMemory.Join.fromBuffers storage.buffers.history phase.qkvBuffer shared.symm
    destination bounded historySeparate sourceSeparate

def convolutionInput (phase : DeltaAffineMemory.Execution layer input) (parameters : DeltaParameterMemory.Storage layer phase.memory)
    (window : State.ConvolutionMemory.Execution cache.history (layer.qkv.forward input))
    (shared : window.joined.old.bytes=phase.memory)
    (joinWeight : MemoryRegions.Disjoint (2*window.joined.destination) 81920 parameters.convolution.base 81920)
    (tailWeight : MemoryRegions.Disjoint (2*window.destination) 61440 parameters.convolution.base 81920) :
    ConvolutionMemory.Input cache.history (layer.qkv.forward input) layer.convolutionWeight :=
  ⟨window, parameters.convolution, parameters.convolutionShared.trans shared.symm, joinWeight, tailWeight⟩

def convolution (phase : DeltaAffineMemory.Execution layer input) (parameters : DeltaParameterMemory.Storage layer phase.memory)
    (window : State.ConvolutionMemory.Execution cache.history (layer.qkv.forward input))
    (shared : window.joined.old.bytes=phase.memory)
    (joinWeight : MemoryRegions.Disjoint (2*window.joined.destination) 81920 parameters.convolution.base 81920)
    (tailWeight : MemoryRegions.Disjoint (2*window.destination) 61440 parameters.convolution.base 81920)
    (base : Nat) (aligned : base%2=0) (bounded : base+20480 ≤ 2^64)
    (sourceSeparate : MemoryRegions.Disjoint base 20480 window.window.base 81920)
    (weightSeparate : MemoryRegions.Disjoint base 20480 parameters.convolution.base 81920)
    (historySeparate : MemoryRegions.Disjoint base 20480 window.after.base 61440) :
    ConvolutionMemory.Execution (convolutionInput phase parameters window shared joinWeight tailWeight) layer.recurrence.convolutionContracted :=
  ConvolutionMemory.canonical _ layer.recurrence.convolutionContracted base aligned bounded sourceSeparate weightSeparate historySeparate

variable {phase : DeltaAffineMemory.Execution layer input} {parameters : DeltaParameterMemory.Storage layer phase.memory}
  {window : State.ConvolutionMemory.Execution cache.history (layer.qkv.forward input)}
  {shared : window.joined.old.bytes=phase.memory}
  {joinWeight : MemoryRegions.Disjoint (2*window.joined.destination) 81920 parameters.convolution.base 81920}
  {tailWeight : MemoryRegions.Disjoint (2*window.destination) 61440 parameters.convolution.base 81920}

def headScales (convolved : ConvolutionMemory.Execution (convolutionInput phase parameters window shared joinWeight tailWeight)
    layer.recurrence.convolutionContracted)
    (querySafe : ConvolutionMemory.Safe convolved parameters.queryScale.base 256)
    (keySafe : ConvolutionMemory.Safe convolved parameters.keyScale.base 256) :
    DeltaConvolutionMemory.Scales convolved layer.headParams.qScale layer.headParams.kScale :=
  ⟨parameters.queryScale, parameters.keyScale, parameters.queryShared.trans shared.symm,
    parameters.keyShared.trans shared.symm, querySafe, keySafe⟩

def gatesAfterConvolution (convolved : ConvolutionMemory.Execution (convolutionInput phase parameters window shared joinWeight tailWeight)
    layer.recurrence.convolutionContracted)
    (safe : (DeltaParameterMemory.gateInput phase parameters).Protected (fun base => ConvolutionMemory.Safe convolved base 96)) :
    GateMemory.Input layer.aLog (layer.a.forward input) layer.dtBias (layer.b.forward input) :=
  DeltaConvolutionMemory.gatesAfterConvolution convolved (DeltaParameterMemory.gateInput phase parameters)
    (parameters.logarithmShared.trans shared.symm) safe

theorem convolution_output (convolved : ConvolutionMemory.Execution (convolutionInput phase parameters window shared joinWeight tailWeight)
    layer.recurrence.convolutionContracted) (channel : Fin 10240) :
    convolved.output channel=Convolution.value layer.recurrence.convolutionContracted
      (fun tap => Convolution.streamWindow cache.history (layer.qkv.forward input) tap channel) (layer.convolutionWeight channel) :=
  convolved.output_eq channel

end Inference.Models.Qwen.DeltaProjectionHandoff
