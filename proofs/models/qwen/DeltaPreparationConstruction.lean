import models.qwen.DeltaProjectionHandoff

namespace Inference.Models.Qwen.DeltaPreparationConstruction
open Contracts.Mlx Layers Kernels.Delta
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000


variable {layer : DeltaNet.Layer} {input : Fin 5120 → ArrayStorage.BF} {cache : DeltaNet.Cache}

structure ConvolutionAllocation (phase : DeltaAffineMemory.Execution layer input)
    (storage : DeltaRegions.Storage cache) (parameters : DeltaParameterMemory.Storage layer phase.memory) where
  joinBase : Nat
  tailBase : Nat
  outputBase : Nat
  joinBounded : 2*joinBase+81920 ≤ 2^64
  tailBounded : 2*tailBase+61440 ≤ 2^64
  outputAligned : outputBase%2=0
  outputBounded : outputBase+20480 ≤ 2^64
  historySeparate : MemoryRegions.Disjoint (2*joinBase) 81920 storage.buffers.history.base 61440
  sourceSeparate : MemoryRegions.Disjoint (2*joinBase) 81920 phase.qkvBuffer.base 20480
  tailSeparate : MemoryRegions.Disjoint (2*tailBase) 61440 (2*joinBase) 81920
  joinWeight : MemoryRegions.Disjoint (2*joinBase) 81920 parameters.convolution.base 81920
  tailWeight : MemoryRegions.Disjoint (2*tailBase) 61440 parameters.convolution.base 81920
  outputSource : MemoryRegions.Disjoint outputBase 20480 (2*joinBase) 81920
  outputWeight : MemoryRegions.Disjoint outputBase 20480 parameters.convolution.base 81920
  outputHistory : MemoryRegions.Disjoint outputBase 20480 (2*tailBase) 61440

variable (phase : DeltaAffineMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
  (parameters : DeltaParameterMemory.Storage layer phase.memory) (shared : storage.memory=phase.memory)
  (allocation : ConvolutionAllocation phase storage parameters)

def window : State.ConvolutionMemory.Execution cache.history (layer.qkv.forward input) :=
  State.ConvolutionMemory.Execution.fromJoin
    (DeltaProjectionHandoff.joinHistory phase storage shared allocation.joinBase allocation.joinBounded
      allocation.historySeparate allocation.sourceSeparate)
    allocation.tailBase allocation.tailBounded allocation.tailSeparate

def convolved :=
  DeltaProjectionHandoff.convolution phase parameters (window phase storage parameters shared allocation) shared
    allocation.joinWeight allocation.tailWeight allocation.outputBase allocation.outputAligned allocation.outputBounded
    allocation.outputSource allocation.outputWeight allocation.outputHistory

-- The remaining contracts contain addresses and non-overlap facts only.
-- All head, decay and sigmoid dispatch traces below are canonical constructions.
structure HeadAllocation {projected : Fin 10240 → ArrayStorage.BF} {qScale kScale : Fin 128 → ArrayStorage.BF}
    (source : DeltaHeadsMemory.Input projected qScale kScale) where
  geometry : DeltaHeadsMemory.Geometry
  sourceSeparate : ∀ i, MemoryRegions.Disjoint (geometry.base i) (DeltaHeadsMemory.size i) source.storage.input.base 20480
  querySeparate : ∀ i, MemoryRegions.Disjoint (geometry.base i) (DeltaHeadsMemory.size i) source.storage.qScale.base 256
  keySeparate : ∀ i, MemoryRegions.Disjoint (geometry.base i) (DeltaHeadsMemory.size i) source.storage.kScale.base 256

def heads {projected : Fin 10240 → ArrayStorage.BF} {qScale kScale : Fin 128 → ArrayStorage.BF}
    (source : DeltaHeadsMemory.Input projected qScale kScale) (p : SiluRmsHeads.Platform) (width eps : Float32)
    (allocation : HeadAllocation source) : DeltaHeadsMemory.Execution source p width eps :=
  DeltaHeadsMemory.canonical source p width eps allocation.geometry allocation.sourceSeparate allocation.querySeparate allocation.keySeparate

variable {projected : Fin 10240 → ArrayStorage.BF} {qScale kScale : Fin 128 → ArrayStorage.BF}
  {headInput : DeltaHeadsMemory.Input projected qScale kScale} {headPlatform : SiluRmsHeads.Platform}
  {width eps : Float32} {aLog a dtBias b : GateDevice.Heads}

structure GateAllocation (heads : DeltaHeadsMemory.Execution headInput headPlatform width eps)
    (source : GateMemory.Input aLog a dtBias b) where
  headSafe : DeltaPreparedMemory.HeadSafe heads source
  decayBase : Nat
  betaBase : Nat
  decayAligned : decayBase%4=0
  decayBounded : decayBase+192 ≤ 2^64
  betaBounded : 2*betaBase+96 ≤ 2^64
  decaySafe : source.Protected (fun base => MemoryRegions.Disjoint decayBase 192 base 96)
  betaSource : source.storage.projectionB.base/2=betaBase ∨
    MemoryRegions.Disjoint source.storage.projectionB.base 96 (2*betaBase) 96
  betaDecay : MemoryRegions.Disjoint (2*betaBase) 96 decayBase 192
  querySafe : MemoryRegions.Disjoint decayBase 192 heads.queryBuffer.base 4096 ∧
    MemoryRegions.Disjoint (2*betaBase) 96 heads.queryBuffer.base 4096
  keySafe : MemoryRegions.Disjoint decayBase 192 heads.keyBuffer.base 4096 ∧
    MemoryRegions.Disjoint (2*betaBase) 96 heads.keyBuffer.base 4096
  valueSafe : MemoryRegions.Disjoint decayBase 192 heads.valueBuffer.base 12288 ∧
    MemoryRegions.Disjoint (2*betaBase) 96 heads.valueBuffer.base 12288

def prepared (heads : DeltaHeadsMemory.Execution headInput headPlatform width eps)
    (source : GateMemory.Input aLog a dtBias b)
    (shared : source.storage.logarithm.bytes=headInput.storage.input.bytes)
    (p : Inputs.Platform) (allocation : GateAllocation heads source) :
    DeltaPreparedMemory.Execution heads aLog a dtBias b p := by
  let gateSource := DeltaPreparedMemory.gatesAfterHeads heads source shared allocation.headSafe
  let decay := GateMemory.decayCanonical gateSource p allocation.decayBase allocation.decayAligned
    allocation.decayBounded allocation.decaySafe
  let gates := GateMemory.fromDecay decay allocation.betaBase allocation.betaBounded allocation.betaSource allocation.betaDecay
  exact ⟨source,shared,allocation.headSafe,decay,gates,allocation.querySafe,allocation.keySafe,allocation.valueSafe⟩

def scales (phase : DeltaAffineMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer phase.memory) (shared : storage.memory=phase.memory)
    (allocation : ConvolutionAllocation phase storage parameters)
    (querySafe : ConvolutionMemory.Safe (convolved phase storage parameters shared allocation) parameters.queryScale.base 256)
    (keySafe : ConvolutionMemory.Safe (convolved phase storage parameters shared allocation) parameters.keyScale.base 256) :
    DeltaConvolutionMemory.Scales (convolved phase storage parameters shared allocation) layer.headParams.qScale layer.headParams.kScale :=
  DeltaProjectionHandoff.headScales (phase := phase) (parameters := parameters)
    (window := window phase storage parameters shared allocation) (shared := shared)
    (joinWeight := allocation.joinWeight) (tailWeight := allocation.tailWeight)
    (convolved phase storage parameters shared allocation) querySafe keySafe

def gateSource (phase : DeltaAffineMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer phase.memory) (shared : storage.memory=phase.memory)
    (allocation : ConvolutionAllocation phase storage parameters)
    (safe : (DeltaParameterMemory.gateInput phase parameters).Protected
      (fun base => ConvolutionMemory.Safe (convolved phase storage parameters shared allocation) base 96)) :
    GateMemory.Input layer.aLog (layer.a.forward input) layer.dtBias (layer.b.forward input) :=
  DeltaProjectionHandoff.gatesAfterConvolution (phase := phase) (parameters := parameters)
    (window := window phase storage parameters shared allocation) (shared := shared)
    (joinWeight := allocation.joinWeight) (tailWeight := allocation.tailWeight)
    (convolved phase storage parameters shared allocation) safe

attribute [local irreducible] heads convolved

structure PreparationAllocation (phase : DeltaAffineMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer phase.memory) (shared : storage.memory=phase.memory)
    (allocation : ConvolutionAllocation phase storage parameters) where
  querySafe : ConvolutionMemory.Safe (convolved phase storage parameters shared allocation) parameters.queryScale.base 256
  keySafe : ConvolutionMemory.Safe (convolved phase storage parameters shared allocation) parameters.keyScale.base 256
  gateSafe : (DeltaParameterMemory.gateInput phase parameters).Protected
    (fun base => ConvolutionMemory.Safe (convolved phase storage parameters shared allocation) base 96)
  headAllocation : HeadAllocation
    (scales phase storage parameters shared allocation querySafe keySafe).headInput
  gateAllocation : GateAllocation
    (heads (scales phase storage parameters shared allocation querySafe keySafe).headInput
      layer.recurrence.heads layer.headParams.width layer.headParams.eps headAllocation)
    (gateSource phase storage parameters shared allocation gateSafe)

def fromStorage (phase : DeltaAffineMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer phase.memory) (shared : storage.memory=phase.memory)
    (allocation : ConvolutionAllocation phase storage parameters)
    (preparation : PreparationAllocation phase storage parameters shared allocation) :
    DeltaConvolutionMemory.Execution
      (input := DeltaProjectionHandoff.convolutionInput phase parameters
        (window phase storage parameters shared allocation) shared allocation.joinWeight allocation.tailWeight)
      (convolved phase storage parameters shared allocation)
      layer.headParams.qScale layer.headParams.kScale layer.recurrence.heads layer.headParams.width layer.headParams.eps
      layer.aLog (layer.a.forward input) layer.dtBias (layer.b.forward input) layer.recurrence.gates := by
  let convolution := convolved phase storage parameters shared allocation
  let scales := scales phase storage parameters shared allocation preparation.querySafe preparation.keySafe
  let headExecution := heads scales.headInput layer.recurrence.heads layer.headParams.width layer.headParams.eps preparation.headAllocation
  let source := gateSource phase storage parameters shared allocation preparation.gateSafe
  let result := prepared (headInput := scales.headInput) (headPlatform := layer.recurrence.heads)
    (width := layer.headParams.width) (eps := layer.headParams.eps)
    headExecution source rfl layer.recurrence.gates preparation.gateAllocation
  exact ⟨scales,headExecution,DeltaParameterMemory.gateInput phase parameters,
    parameters.logarithmShared.trans shared.symm,preparation.gateSafe,result,rfl⟩

def cacheAfter (phase : DeltaAffineMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer phase.memory) (shared : storage.memory=phase.memory)
    (allocation : ConvolutionAllocation phase storage parameters)
    (preparation : PreparationAllocation phase storage parameters shared allocation)
    (stateSafe : DeltaConvolutionMemory.Safe (fromStorage phase storage parameters shared allocation preparation)
      storage.buffers.recurrent.base 3145728)
    (historySafe : DeltaPreparedMemory.Safe (fromStorage phase storage parameters shared allocation preparation).prepared
      (convolved phase storage parameters shared allocation).afterHistory.base 61440) :
    DeltaRegions.Storage ⟨Convolution.tail cache.history (fun _ => layer.qkv.forward input) 1, cache.recurrent⟩ :=
  (fromStorage phase storage parameters shared allocation preparation).inputCache
    storage.buffers.recurrent storage.shared stateSafe historySafe

end Inference.Models.Qwen.DeltaPreparationConstruction
