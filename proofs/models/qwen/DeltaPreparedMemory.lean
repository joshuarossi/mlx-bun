import layers.DeltaHeadsMemory
import kernels.delta.GateMemory
import kernels.delta.GatedShared
import models.qwen.DeltaRegions

namespace Inference.Models.Qwen.DeltaPreparedMemory
open Contracts.Mlx Kernels.Delta
set_option maxRecDepth 10000

variable {projected : Fin 10240 → ArrayStorage.BF} {qScale kScale : Fin 128 → ArrayStorage.BF}
  {headInput : Layers.DeltaHeadsMemory.Input projected qScale kScale}
  {headPlatform : SiluRmsHeads.Platform} {width eps : Float32}
  {heads : Layers.DeltaHeadsMemory.Execution headInput headPlatform width eps}
  {aLog a dtBias b : GateDevice.Heads} {gatePlatform : Inputs.Platform}

def HeadSafe (heads : Layers.DeltaHeadsMemory.Execution headInput headPlatform width eps)
    (source : GateMemory.Input aLog a dtBias b) : Prop :=
  source.Protected (fun base => ∀ i, MemoryRegions.Disjoint (heads.geometry.base i) (Layers.DeltaHeadsMemory.size i) base 96)

def gatesAfterHeads (heads : Layers.DeltaHeadsMemory.Execution headInput headPlatform width eps)
    (source : GateMemory.Input aLog a dtBias b) (shared : source.storage.logarithm.bytes=headInput.storage.input.bytes)
    (safe : HeadSafe heads source) : GateMemory.Input aLog a dtBias b :=
  source.reframe heads.trace.memory
    ⟨fun offset bound => (heads.other_region safe.1 offset bound).trans (congrFun shared _).symm,
      fun offset bound => (heads.other_region safe.2.1 offset bound).trans (congrFun shared _).symm,
      fun offset bound => (heads.other_region safe.2.2.1 offset bound).trans (congrFun shared _).symm,
      fun offset bound => (heads.other_region safe.2.2.2 offset bound).trans (congrFun shared _).symm⟩

structure Execution (heads : Layers.DeltaHeadsMemory.Execution headInput headPlatform width eps)
    (aLog a dtBias b : GateDevice.Heads) (gatePlatform : Inputs.Platform) where
  source : GateMemory.Input aLog a dtBias b
  shared : source.storage.logarithm.bytes=headInput.storage.input.bytes
  headSafe : HeadSafe heads source
  decay : GateMemory.DecayExecution (gatesAfterHeads heads source shared headSafe) gatePlatform
  gates : GateMemory.Execution decay
  querySafe : MemoryRegions.Disjoint decay.base 192 heads.queryBuffer.base 4096 ∧
    MemoryRegions.Disjoint (2*gates.beta.base) 96 heads.queryBuffer.base 4096
  keySafe : MemoryRegions.Disjoint decay.base 192 heads.keyBuffer.base 4096 ∧
    MemoryRegions.Disjoint (2*gates.beta.base) 96 heads.keyBuffer.base 4096
  valueSafe : MemoryRegions.Disjoint decay.base 192 heads.valueBuffer.base 12288 ∧
    MemoryRegions.Disjoint (2*gates.beta.base) 96 heads.valueBuffer.base 12288

def Execution.values (execution : Execution heads aLog a dtBias b gatePlatform) : GatedInputs.Values where
  key := (Layers.DeltaHeadsDevice.produced headPlatform width eps headInput.storage).k 0
  query := (Layers.DeltaHeadsDevice.produced headPlatform width eps headInput.storage).q 0
  value := (Layers.DeltaHeadsDevice.produced headPlatform width eps headInput.storage).v 0
  decay := GateDevice.producedDecay gatePlatform (gatesAfterHeads heads execution.source execution.shared execution.headSafe).storage
  beta := fun head => Kernels.Trellis.GateUpSplitTail.sigmoidValue gatePlatform.expAbs (b head)

def Execution.operands (execution : Execution heads aLog a dtBias b gatePlatform) : GatedInputs.Storage execution.values where
  key := ArrayFrame.bf heads.keyBuffer execution.gates.betaBuffer.bytes
    (execution.gates.other_region execution.keySafe.1 execution.keySafe.2)
  query := ArrayFrame.bf heads.queryBuffer execution.gates.betaBuffer.bytes
    (execution.gates.other_region execution.querySafe.1 execution.querySafe.2)
  value := ArrayFrame.bf heads.valueBuffer execution.gates.betaBuffer.bytes
    (execution.gates.other_region execution.valueSafe.1 execution.valueSafe.2)
  decay := execution.gates.decayBuffer
  beta := execution.gates.betaBuffer

def Safe (execution : Execution heads aLog a dtBias b gatePlatform) (base size : Nat) : Prop :=
  (∀ i, MemoryRegions.Disjoint (heads.geometry.base i) (Layers.DeltaHeadsMemory.size i) base size) ∧
  MemoryRegions.Disjoint execution.decay.base 192 base size ∧
  MemoryRegions.Disjoint (2*execution.gates.beta.base) 96 base size

theorem Execution.other_region (execution : Execution heads aLog a dtBias b gatePlatform) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.gates.betaBuffer.bytes (base+offset)=headInput.storage.input.bytes (base+offset) :=
  (execution.gates.other_region safe.2.1 safe.2.2 offset bound).trans (heads.other_region safe.1 offset bound)

-- Recurrence receives the actual Q/K/V, FP32 decay and BF16 beta arrays
-- from these dispatches together with the preserved old recurrent state.
def Execution.recurrenceInput (execution : Execution heads aLog a dtBias b gatePlatform)
    {initial : GatedDevice.State} (state : GatedDevice.Storage initial)
    (shared : state.bytes=headInput.storage.input.bytes) (safe : Safe execution state.base 3145728) :
    GatedShared.Input initial execution.values where
  state := GatedShared.stateFrame state execution.gates.betaBuffer.bytes
    (fun offset bound => (execution.other_region safe offset bound).trans (congrFun shared _).symm)
  operands := execution.operands
  keyShared := rfl
  queryShared := rfl
  valueShared := rfl
  decayShared := rfl
  betaShared := rfl

theorem Execution.input_memory (execution : Execution heads aLog a dtBias b gatePlatform)
    {initial : GatedDevice.State} (state : GatedDevice.Storage initial)
    (shared : state.bytes=headInput.storage.input.bytes) (safe : Safe execution state.base 3145728) :
    (execution.recurrenceInput state shared safe).state.bytes=execution.gates.betaBuffer.bytes := rfl

theorem Execution.query_eq (execution : Execution heads aLog a dtBias b gatePlatform) :
    execution.values.query=(Layers.DeltaHeads.forward (rows := 1) headPlatform (fun _ => projected) qScale kScale width eps).q 0 :=
  congrArg (fun result : Layers.DeltaHeads.Output 1 ArrayStorage.BF => result.q 0)
    (Layers.DeltaHeadsDevice.produced_eq headPlatform width eps headInput.storage)

theorem Execution.key_eq (execution : Execution heads aLog a dtBias b gatePlatform) :
    execution.values.key=(Layers.DeltaHeads.forward (rows := 1) headPlatform (fun _ => projected) qScale kScale width eps).k 0 :=
  congrArg (fun result : Layers.DeltaHeads.Output 1 ArrayStorage.BF => result.k 0)
    (Layers.DeltaHeadsDevice.produced_eq headPlatform width eps headInput.storage)

theorem Execution.value_eq (execution : Execution heads aLog a dtBias b gatePlatform) :
    execution.values.value=(Layers.DeltaHeads.forward (rows := 1) headPlatform (fun _ => projected) qScale kScale width eps).v 0 :=
  congrArg (fun result : Layers.DeltaHeads.Output 1 ArrayStorage.BF => result.v 0)
    (Layers.DeltaHeadsDevice.produced_eq headPlatform width eps headInput.storage)

theorem Execution.decay_eq (execution : Execution heads aLog a dtBias b gatePlatform) (head : Fin 48) :
    execution.values.decay head=Decay.value gatePlatform.decay (BFloat16.widen (aLog head)) (a head) (dtBias head) :=
  GateDevice.produced_decay gatePlatform _ head

def Execution.retainedCache (execution : Execution heads aLog a dtBias b gatePlatform) {cache : DeltaNet.Cache}
    (storage : DeltaRegions.Storage cache) (shared : storage.memory=headInput.storage.input.bytes)
    (historySafe : Safe execution storage.buffers.history.base 61440)
    (stateSafe : Safe execution storage.buffers.recurrent.base 3145728) : DeltaRegions.Storage cache :=
  storage.reframe execution.gates.betaBuffer.bytes
    (fun offset bound => (execution.other_region historySafe offset bound).trans (congrFun shared _).symm)
    (fun offset bound => (execution.other_region stateSafe offset bound).trans (congrFun shared _).symm)

end Inference.Models.Qwen.DeltaPreparedMemory
