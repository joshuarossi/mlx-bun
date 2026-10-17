import kernels.delta.GatedShared
import kernels.GatedRmsNormMemory
import layers.AffineMemory
import models.qwen.DeltaRegions

namespace Inference.Models.Qwen.DeltaTailMemory
open Contracts.Mlx Kernels Kernels.Delta
set_option maxRecDepth 10000

variable {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}
  {initial : GatedDevice.State} {values : GatedInputs.Values}
  {recurrence : GatedShared.Execution reduce flags initial values}
  {gate : GatedRmsNormDevice.Rows} {weights : Fin 128 → ArrayStorage.BF}

structure Input (recurrence : GatedShared.Execution reduce flags initial values)
    (gate : GatedRmsNormDevice.Rows) (weights : Fin 128 → ArrayStorage.BF) where
  gate : ArrayStorage.BFBuffer (GatedInputs.flatten gate)
  weight : ArrayStorage.BFBuffer weights
  gateShared : gate.bytes=recurrence.input.state.bytes
  weightShared : weight.bytes=recurrence.input.state.bytes
  stateGate : MemoryRegions.Disjoint recurrence.stores.trace.stateBase 3145728 gate.base 12288
  outputGate : MemoryRegions.Disjoint recurrence.stores.trace.outputBase 12288 gate.base 12288
  stateWeight : MemoryRegions.Disjoint recurrence.stores.trace.stateBase 3145728 weight.base 256
  outputWeight : MemoryRegions.Disjoint recurrence.stores.trace.outputBase 12288 weight.base 256

def Input.normalization (input : Input recurrence gate weights) : GatedRmsNormMemory.Input recurrence.output gate weights where
  storage := {
    input := recurrence.buffer
    gate := ArrayFrame.bf input.gate recurrence.stores.memory (by
      intro offset bound
      exact (recurrence.other_region input.stateGate input.outputGate offset bound).trans
        (congrFun input.gateShared _).symm)
    weight := ArrayFrame.bf input.weight recurrence.stores.memory (by
      intro offset bound
      exact (recurrence.other_region input.stateWeight input.outputWeight offset bound).trans
        (congrFun input.weightShared _).symm) }
  gateShared := rfl
  weightShared := rfl

structure Execution (input : Input recurrence gate weights) (p : GatedRmsNorm.Platform) (width eps : Float32)
    (projection : Layers.AffineVerifyLinear.Projection 12 5120) where
  normalization : GatedRmsNormMemory.Execution input.normalization p width eps
  affine : Layers.AffineMemory.Execution (groups := 1280) projection (GatedInputs.flatten normalization.output)
  linked : affine.source=normalization.outputBuffer
  normalizationState : MemoryRegions.Disjoint normalization.base 12288 recurrence.stores.trace.stateBase 3145728
  projectionState : MemoryRegions.Disjoint affine.base 10240 recurrence.stores.trace.stateBase 3145728

variable {input : Input recurrence gate weights} {p : GatedRmsNorm.Platform} {width eps : Float32}
  {projection : Layers.AffineVerifyLinear.Projection 12 5120}

def fromNormalization (input : Input recurrence gate weights) (p : GatedRmsNorm.Platform) (width eps : Float32)
    (projection : Layers.AffineVerifyLinear.Projection 12 5120)
    (normalization : GatedRmsNormMemory.Execution input.normalization p width eps)
    (projectionWeights : Layers.AffineDevice.Storage projection)
    (shared : Layers.AffineMemory.Shared projection projectionWeights normalization.outputBuffer.bytes)
    (base : Nat) (aligned : base%2=0) (bounded : base+10240 ≤ 2^64)
    (inputSeparate : MemoryRegions.Disjoint base 10240 normalization.outputBuffer.base 12288)
    (weightsSeparate : Layers.AffineMemory.Separate projection projectionWeights base 10240)
    (normalizationState : MemoryRegions.Disjoint normalization.base 12288 recurrence.stores.trace.stateBase 3145728)
    (projectionState : MemoryRegions.Disjoint base 10240 recurrence.stores.trace.stateBase 3145728) :
    Execution input p width eps projection := by
  let affine := Layers.AffineMemory.fromStorage (groups := 1280) projection _ projectionWeights normalization.outputBuffer
    shared base aligned bounded inputSeparate weightsSeparate
  have linked := Layers.AffineMemory.source_fromStorage (steps := 12) (groups := 1280) (p := projection)
    projectionWeights normalization.outputBuffer shared base aligned bounded inputSeparate weightsSeparate
  refine ⟨normalization, affine, linked, normalizationState, ?_⟩
  cases projection <;> exact projectionState

def Execution.output (execution : Execution input p width eps projection) : Fin 5120 → ArrayStorage.BF := execution.affine.output

def Execution.buffer (execution : Execution input p width eps projection) : ArrayStorage.BFBuffer execution.output :=
  execution.affine.outputBuffer

theorem Execution.output_eq (execution : Execution input p width eps projection) :
    execution.output=projection.forward (GatedInputs.flatten (fun head =>
      GatedRmsNorm.value p (GatedDevice.producedOutput reduce flags initial values.inputs head) (gate head) weights width eps)) := by
  have normalized : execution.normalization.output=(fun head =>
      GatedRmsNorm.value p (GatedDevice.producedOutput reduce flags initial values.inputs head) (gate head) weights width eps) :=
    execution.normalization.output_eq.trans (congrArg
      (fun rows : GatedRmsNormDevice.Rows => fun head => GatedRmsNorm.value p (rows head) (gate head) weights width eps)
      recurrence.output_eq)
  have projected : execution.output=projection.forward (GatedInputs.flatten execution.normalization.output) :=
    execution.affine.output_eq
  exact projected.trans (congrArg (fun rows : GatedRmsNormDevice.Rows => projection.forward (GatedInputs.flatten rows)) normalized)

def Safe (execution : Execution input p width eps projection) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint recurrence.stores.trace.stateBase 3145728 base size ∧
  MemoryRegions.Disjoint recurrence.stores.trace.outputBase 12288 base size ∧
  MemoryRegions.Disjoint execution.normalization.base 12288 base size ∧
  MemoryRegions.Disjoint execution.affine.base 10240 base size

theorem Execution.other_region (execution : Execution input p width eps projection) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.buffer.bytes (base+offset)=recurrence.input.state.bytes (base+offset) := by
  have projected := execution.affine.other_region safe.2.2.2 offset bound
  rw [execution.linked] at projected
  exact projected.trans ((execution.normalization.other_region safe.2.2.1 offset bound).trans
    (recurrence.other_region safe.1 safe.2.1 offset bound))

def Execution.afterState (execution : Execution input p width eps projection) : GatedDevice.Storage recurrence.state :=
  GatedShared.stateFrame recurrence.after execution.buffer.bytes (by
    intro offset bound
    have projected := execution.affine.other_region execution.projectionState offset bound
    rw [execution.linked] at projected
    exact projected.trans (execution.normalization.other_region execution.normalizationState offset bound))

theorem Execution.state_output_shared (execution : Execution input p width eps projection) :
    execution.afterState.bytes=execution.buffer.bytes := rfl

theorem Execution.state_eq (execution : Execution input p width eps projection) :
    execution.afterState.read=GatedDevice.producedState reduce flags initial values.inputs :=
  execution.afterState.read_eq.trans recurrence.state_eq

-- The updated convolution history already exists at the recurrence entry.
-- Retain it alongside the new recurrent state in the final projection heap.
def Execution.afterCache (execution : Execution input p width eps projection)
    {history : State.ConvolutionStorage.History}
    (historyBuffer : State.ConvolutionStorage.Storage history)
    (shared : historyBuffer.bytes=recurrence.input.state.bytes)
    (safe : Safe execution historyBuffer.base 61440)
    (separate : MemoryRegions.Disjoint historyBuffer.base 61440 recurrence.stores.trace.stateBase 3145728) :
    DeltaRegions.Storage ⟨history, recurrence.state⟩ where
  buffers := {
    history := ArrayFrame.bf historyBuffer execution.buffer.bytes (by
      intro offset bound
      exact (execution.other_region safe offset bound).trans (congrFun shared _).symm)
    recurrent := execution.afterState }
  shared := rfl
  separate := separate

theorem Execution.cache_output_shared (execution : Execution input p width eps projection)
    {history : State.ConvolutionStorage.History}
    (historyBuffer : State.ConvolutionStorage.Storage history)
    (shared : historyBuffer.bytes=recurrence.input.state.bytes)
    (safe : Safe execution historyBuffer.base 61440)
    (separate : MemoryRegions.Disjoint historyBuffer.base 61440 recurrence.stores.trace.stateBase 3145728) :
    (execution.afterCache historyBuffer shared safe separate).memory=execution.buffer.bytes := rfl

end Inference.Models.Qwen.DeltaTailMemory
