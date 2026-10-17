import models.qwen.DeltaTailMemory
import models.qwen.DeltaConvolutionMemory
import layers.AffineMemoryFrames

namespace Inference.Models.Qwen.DeltaTailConstruction
open Contracts.Mlx Layers Kernels Kernels.Delta
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000

structure RecurrenceAllocation (input : GatedShared.Input initial values) where
  stateBase : Nat
  outputBase : Nat
  stateAligned : stateBase%4=0
  outputAligned : outputBase%2=0
  stateBounded : stateBase+3145728 ≤ 2^64
  outputBounded : outputBase+12288 ≤ 2^64
  separate : MemoryRegions.Disjoint stateBase 3145728 outputBase 12288
  safe : input.Protected (fun base size => MemoryRegions.Disjoint stateBase 3145728 base size ∧
    MemoryRegions.Disjoint outputBase 12288 base size)

def recurrence (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction)
    (input : GatedShared.Input initial values) (allocation : RecurrenceAllocation input) :
    GatedShared.Execution reduce flags initial values :=
  GatedShared.canonical reduce flags input allocation.stateBase allocation.outputBase allocation.stateAligned allocation.outputAligned
    allocation.stateBounded allocation.outputBounded allocation.separate allocation.safe

variable {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}
  {initial : GatedDevice.State} {values : GatedInputs.Values}
  {recurrence : GatedShared.Execution reduce flags initial values}
  {gate : GatedRmsNormDevice.Rows} {weights : Fin 128 → ArrayStorage.BF}
  {projection : AffineVerifyLinear.Projection 12 5120}

structure Allocation (input : DeltaTailMemory.Input recurrence gate weights)
    (projectionWeights : AffineDevice.Storage projection) where
  normalizationBase : Nat
  projectionBase : Nat
  normalizationAligned : normalizationBase%2=0
  projectionAligned : projectionBase%2=0
  normalizationBounded : normalizationBase+12288 ≤ 2^64
  projectionBounded : projectionBase+10240 ≤ 2^64
  normalizationInput : MemoryRegions.Disjoint normalizationBase 12288 recurrence.stores.trace.outputBase 12288
  normalizationGate : MemoryRegions.Disjoint normalizationBase 12288 input.gate.base 12288
  normalizationWeight : MemoryRegions.Disjoint normalizationBase 12288 input.weight.base 256
  normalizationState : MemoryRegions.Disjoint normalizationBase 12288 recurrence.stores.trace.stateBase 3145728
  projectionInput : MemoryRegions.Disjoint projectionBase 10240 normalizationBase 12288
  projectionState : MemoryRegions.Disjoint projectionBase 10240 recurrence.stores.trace.stateBase 3145728
  weightsProtected : AffineMemoryFrames.Protected projection projectionWeights (fun base size =>
    MemoryRegions.Disjoint recurrence.stores.trace.stateBase 3145728 base size ∧
    MemoryRegions.Disjoint recurrence.stores.trace.outputBase 12288 base size ∧
    MemoryRegions.Disjoint normalizationBase 12288 base size ∧
    MemoryRegions.Disjoint projectionBase 10240 base size)

def normalization (input : DeltaTailMemory.Input recurrence gate weights)
    (p : GatedRmsNorm.Platform) (width eps : Float32) (projectionWeights : AffineDevice.Storage projection)
    (allocation : Allocation input projectionWeights) : GatedRmsNormMemory.Execution input.normalization p width eps :=
  GatedRmsNormMemory.canonical input.normalization p width eps allocation.normalizationBase allocation.normalizationAligned
    allocation.normalizationBounded allocation.normalizationInput allocation.normalizationGate allocation.normalizationWeight

-- Reframe the original packed/scales/bias triple across both actual write phases.
def projectionAfter (input : DeltaTailMemory.Input recurrence gate weights)
    (p : GatedRmsNorm.Platform) (width eps : Float32) (projectionWeights : AffineDevice.Storage projection)
    (shared : AffineMemory.Shared projection projectionWeights recurrence.input.state.bytes)
    (allocation : Allocation input projectionWeights) : AffineDevice.Storage projection :=
  AffineMemoryFrames.reframe projection projectionWeights
    (normalization input p width eps projectionWeights allocation).outputBuffer.bytes
    (AffineMemoryFrames.stable projection projectionWeights _ _ shared
      (AffineMemoryFrames.protected_mono projection projectionWeights (fun _base _size h offset bound =>
        ((normalization input p width eps projectionWeights allocation).other_region h.2.2.1 offset bound).trans
          (recurrence.other_region h.1 h.2.1 offset bound)) allocation.weightsProtected))

theorem projectionAfter_shared (input : DeltaTailMemory.Input recurrence gate weights)
    (p : GatedRmsNorm.Platform) (width eps : Float32) (projectionWeights : AffineDevice.Storage projection)
    (shared : AffineMemory.Shared projection projectionWeights recurrence.input.state.bytes)
    (allocation : Allocation input projectionWeights) :
    AffineMemory.Shared projection (projectionAfter input p width eps projectionWeights shared allocation)
      (normalization input p width eps projectionWeights allocation).outputBuffer.bytes :=
  AffineMemoryFrames.reframe_shared projection projectionWeights _ _

theorem separate (p : AffineVerifyLinear.Projection steps rows) (w : AffineDevice.Storage p)
    (h : AffineMemoryFrames.Protected p w (MemoryRegions.Disjoint base size)) :
    AffineMemory.Separate p w base size := by cases p <;> exact ⟨h.1,h.2.1,h.2.2⟩

def fromRecurrence (input : DeltaTailMemory.Input recurrence gate weights)
    (p : GatedRmsNorm.Platform) (width eps : Float32) (projectionWeights : AffineDevice.Storage projection)
    (shared : AffineMemory.Shared projection projectionWeights recurrence.input.state.bytes)
    (allocation : Allocation input projectionWeights) : DeltaTailMemory.Execution input p width eps projection := by
  let norm := normalization input p width eps projectionWeights allocation
  let afterWeights := projectionAfter input p width eps projectionWeights shared allocation
  have weightsSeparate : AffineMemory.Separate projection afterWeights allocation.projectionBase 10240 := by
    apply separate
    apply (AffineMemoryFrames.reframe_protected projection projectionWeights norm.outputBuffer.bytes _ _).mpr
    exact AffineMemoryFrames.protected_mono projection projectionWeights (fun _ _ h => h.2.2.2) allocation.weightsProtected
  exact DeltaTailMemory.fromNormalization input p width eps projection norm afterWeights
    (projectionAfter_shared input p width eps projectionWeights shared allocation)
    allocation.projectionBase allocation.projectionAligned allocation.projectionBounded allocation.projectionInput
    weightsSeparate allocation.normalizationState allocation.projectionState

-- Source buffers and allocation certificates suffice: all three execution
-- records are canonical constructions from the prepared shared heap.
def fromPreparation
    {history : State.ConvolutionStorage.History} {next : Fin 10240 → ArrayStorage.BF}
    {convWeights : Fin 10240 → Fin 4 → ArrayStorage.BF}
    {convInput : ConvolutionMemory.Input history next convWeights} {contracted : Bool}
    {convolution : ConvolutionMemory.Execution convInput contracted}
    {qScale kScale : Fin 128 → ArrayStorage.BF} {headPlatform : SiluRmsHeads.Platform}
    {headWidth headEps : Float32} {aLog a dtBias b : GateDevice.Heads} {gatePlatform : Inputs.Platform}
    (preparation : DeltaConvolutionMemory.Execution convolution qScale kScale headPlatform headWidth headEps aLog a dtBias b gatePlatform)
    (state : GatedDevice.Storage initial) (stateShared : state.bytes=convInput.window.joined.old.bytes)
    (stateSafe : DeltaConvolutionMemory.Safe preparation state.base 3145728)
    (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction)
    (recurrenceAllocation : RecurrenceAllocation (preparation.recurrenceInput state stateShared stateSafe))
    (tailInput : DeltaTailMemory.Input
      (DeltaTailConstruction.recurrence reduce flags (preparation.recurrenceInput state stateShared stateSafe) recurrenceAllocation) gate weights)
    (p : GatedRmsNorm.Platform) (width eps : Float32) (projectionWeights : AffineDevice.Storage projection)
    (projectionShared : AffineMemory.Shared projection projectionWeights preparation.prepared.gates.betaBuffer.bytes)
    (allocation : Allocation tailInput projectionWeights) :=
  fromRecurrence tailInput p width eps projectionWeights projectionShared allocation

-- Every predicate of the original packed/scales/bias addresses survives
-- reframing, including subsequent allocations and parameter-load regions.
theorem projectionAfter_regions (input : DeltaTailMemory.Input recurrence gate weights)
    (p : GatedRmsNorm.Platform) (width eps : Float32) (projectionWeights : AffineDevice.Storage projection)
    (shared : AffineMemory.Shared projection projectionWeights recurrence.input.state.bytes)
    (allocation : Allocation input projectionWeights) (property : Nat → Nat → Prop) :
    AffineMemoryFrames.Protected projection (projectionAfter input p width eps projectionWeights shared allocation) property ↔
      AffineMemoryFrames.Protected projection projectionWeights property :=
  AffineMemoryFrames.reframe_protected projection projectionWeights _ _ property

def cacheAfter (input : DeltaTailMemory.Input recurrence gate weights)
    (p : GatedRmsNorm.Platform) (width eps : Float32) (projectionWeights : AffineDevice.Storage projection)
    (shared : AffineMemory.Shared projection projectionWeights recurrence.input.state.bytes)
    (allocation : Allocation input projectionWeights)
    {history : State.ConvolutionStorage.History} (historyBuffer : State.ConvolutionStorage.Storage history)
    (historyShared : historyBuffer.bytes=recurrence.input.state.bytes)
    (historySafe : DeltaTailMemory.Safe (fromRecurrence input p width eps projectionWeights shared allocation) historyBuffer.base 61440)
    (historyState : MemoryRegions.Disjoint historyBuffer.base 61440 recurrence.stores.trace.stateBase 3145728) :
    DeltaRegions.Storage ⟨history, recurrence.state⟩ :=
  (fromRecurrence input p width eps projectionWeights shared allocation).afterCache historyBuffer historyShared historySafe historyState

end Inference.Models.Qwen.DeltaTailConstruction
