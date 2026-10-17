import models.qwen.ResidualDeltaConstruction

namespace Inference.Models.Qwen.ResidualDeltaStorageConstruction
open Contracts.Mlx Layers Kernels Kernels.Delta
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000
attribute [local irreducible] ResidualDeltaConstruction.normalized


-- These are the only parameter buffers supplied by the caller. Every later
-- view is a frame of these original initial-heap allocations.
structure Source (layer : ResidualDelta.Layer) (cache : DeltaNet.Cache) (input : Fin 5120 → ArrayStorage.BF) where
  data : ResidualDeltaConstruction.InputData layer input
  cacheStorage : DeltaRegions.Storage cache
  parameters : DeltaParameterMemory.Storage layer.mixer (ResidualDeltaConstruction.normalized data).source.lhs.bytes
  suffix : ResidualDeltaConstruction.MlpWeights layer.suffix (ResidualDeltaConstruction.normalized data).source.lhs.bytes
  entryFrames : ResidualDeltaConstruction.EntryFrames (ResidualDeltaConstruction.normalized data) cacheStorage parameters
  suffixSafe : suffix.Protected (DeltaNormalizedMemory.Safe (ResidualDeltaConstruction.normalized data))

variable {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → ArrayStorage.BF}

def Source.entry (source : Source layer cache input) := ResidualDeltaConstruction.normalized source.data

def Source.cacheAfterEntry (source : Source layer cache input) :=
  ResidualDeltaConstruction.entryCache source.entry source.cacheStorage source.parameters source.entryFrames

def Source.parametersAfterEntry (source : Source layer cache input) :=
  ResidualDeltaConstruction.entryParameters source.entry source.cacheStorage source.parameters source.entryFrames

def Source.suffixAfterEntry (source : Source layer cache input) := source.suffix.afterEntry source.entry source.suffixSafe

structure PreparationPlan (source : Source layer cache input) where
  convolution : ResidualDeltaConstruction.ConvAllocation source.entry source.cacheStorage source.parameters source.entryFrames
  prepared : ResidualDeltaConstruction.PrepAllocation source.entry source.cacheStorage source.parameters source.entryFrames convolution

def preparation (source : Source layer cache input) (plan : PreparationPlan source) :=
  ResidualDeltaConstruction.preparation source.entry source.cacheStorage source.parameters source.entryFrames plan.convolution plan.prepared

attribute [local irreducible] preparation

structure PreparationFrames (source : Source layer cache input) (plan : PreparationPlan source) : Prop where
  historySafe : DeltaPreparedMemory.Safe (preparation source plan).prepared (2*plan.convolution.tailBase) 61440
  stateSafe : DeltaConvolutionMemory.Safe (preparation source plan) source.cacheAfterEntry.buffers.recurrent.base 3145728
  residualSafe : DeltaConvolutionMemory.Safe (preparation source plan) source.entry.savedResidual.base 10240
  gateSafe : DeltaConvolutionMemory.Safe (preparation source plan) source.entry.affine.gateBuffer.base 12288
  normSafe : DeltaConvolutionMemory.Safe (preparation source plan) source.parametersAfterEntry.normalization.base 256
  projectionSafe : AffineMemoryFrames.Protected layer.mixer.out source.parametersAfterEntry.projection
    (DeltaConvolutionMemory.Safe (preparation source plan))
  suffixSafe : source.suffixAfterEntry.Protected (DeltaConvolutionMemory.Safe (preparation source plan))

def recurrenceInput (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan) :
    GatedShared.Input cache.recurrent (preparation source plan).prepared.values :=
  (preparation source plan).recurrenceInput source.cacheAfterEntry.buffers.recurrent rfl frames.stateSafe

attribute [local irreducible] recurrenceInput

structure RecurrencePlan (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan) where
  allocation : DeltaTailConstruction.RecurrenceAllocation (recurrenceInput source plan frames)
  stateGate : MemoryRegions.Disjoint allocation.stateBase 3145728 source.entry.affine.gateBuffer.base 12288
  outputGate : MemoryRegions.Disjoint allocation.outputBase 12288 source.entry.affine.gateBuffer.base 12288
  stateNorm : MemoryRegions.Disjoint allocation.stateBase 3145728 source.parametersAfterEntry.normalization.base 256
  outputNorm : MemoryRegions.Disjoint allocation.outputBase 12288 source.parametersAfterEntry.normalization.base 256

def recurrent (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan)
    (allocation : RecurrencePlan source plan frames) :=
  DeltaTailConstruction.recurrence layer.mixer.recurrence.reduce layer.mixer.recurrence.flags
    (recurrenceInput source plan frames) allocation.allocation

def tailInput (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan)
    (allocation : RecurrencePlan source plan frames) :
    DeltaTailMemory.Input (recurrent source plan frames allocation)
      (DeltaNet.zHead layer.mixer (fun _ => layer.inputNorm.forward input) 0) layer.mixer.normWeight := by
  with_unfolding_all exact (ResidualDeltaConstruction.tailInputBeforeRecurrence (preparation source plan)
    source.cacheAfterEntry.buffers.recurrent rfl frames.stateSafe layer.mixer.recurrence.reduce layer.mixer.recurrence.flags
    allocation.allocation source.entry.affine.gateBuffer rfl frames.gateSafe
    source.parametersAfterEntry.normalization source.parametersAfterEntry.normalizationShared frames.normSafe
    allocation.stateGate allocation.outputGate allocation.stateNorm allocation.outputNorm)

def projectionWeights (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan) :=
  ResidualDeltaConstruction.projectionBeforeRecurrence (preparation source plan) source.parametersAfterEntry.projection
    source.parametersAfterEntry.projectionShared frames.projectionSafe

theorem projectionShared (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan) :
    AffineMemory.Shared layer.mixer.out (projectionWeights source plan frames) (preparation source plan).prepared.gates.betaBuffer.bytes :=
  AffineMemoryFrames.reframe_shared layer.mixer.out source.parametersAfterEntry.projection _ _

def suffixWeights (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan) :=
  source.suffixAfterEntry.afterPreparation (preparation source plan) frames.suffixSafe



theorem recurrent_memory (source : Source layer cache input) (plan : PreparationPlan source)
    (frames : PreparationFrames source plan) (allocation : RecurrencePlan source plan frames) :
    (recurrent source plan frames allocation).input.state.bytes=(preparation source plan).prepared.gates.betaBuffer.bytes := by
  calc
    _ = (recurrenceInput source plan frames).state.bytes := rfl
    _ = _ := by unfold recurrenceInput; rfl

theorem projectionSharedAtRecurrence (source : Source layer cache input) (plan : PreparationPlan source)
    (frames : PreparationFrames source plan) (allocation : RecurrencePlan source plan frames) :
    AffineMemory.Shared layer.mixer.out (projectionWeights source plan frames) (recurrent source plan frames allocation).input.state.bytes :=
  Eq.mpr (congrArg (fun bytes => AffineMemory.Shared layer.mixer.out (projectionWeights source plan frames) bytes)
    (recurrent_memory source plan frames allocation)) (projectionShared source plan frames)

def tailData (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan)
    (recurrentPlan : RecurrencePlan source plan frames)
    (allocation : DeltaTailConstruction.Allocation (tailInput source plan frames recurrentPlan) (projectionWeights source plan frames)) :
    ResidualDeltaConstruction.TailData (recurrent source plan frames recurrentPlan)
      (DeltaNet.zHead layer.mixer (fun _ => layer.inputNorm.forward input) 0) layer.mixer.normWeight layer.mixer.gated
      layer.mixer.headParams.width layer.mixer.headParams.eps layer.mixer.out :=
  ⟨tailInput source plan frames recurrentPlan,projectionWeights source plan frames,
    projectionSharedAtRecurrence source plan frames recurrentPlan,allocation⟩

attribute [local irreducible] ResidualDeltaConstruction.TailData.execution

def tailExecution (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan)
    (recurrentPlan : RecurrencePlan source plan frames)
    (allocation : DeltaTailConstruction.Allocation (tailInput source plan frames recurrentPlan) (projectionWeights source plan frames)) :=
  (tailData source plan frames recurrentPlan allocation).execution

attribute [local irreducible] tailExecution

def residualBefore (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan) :=
  DeltaBlockMemory.residualBeforeRecurrence (preparation source plan) source.entry.savedResidual rfl frames.residualSafe

def historyBefore (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan) :=
  (preparation source plan).historyAfter frames.historySafe

attribute [local irreducible] tailInput projectionWeights suffixWeights

structure TailPlan (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan)
    (recurrentPlan : RecurrencePlan source plan frames) where
  allocation : DeltaTailConstruction.Allocation (tailInput source plan frames recurrentPlan) (projectionWeights source plan frames)
  residualSafe : DeltaTailMemory.Safe (tailExecution source plan frames recurrentPlan allocation) source.entry.savedResidual.base 10240
  historySafe : DeltaTailMemory.Safe (tailExecution source plan frames recurrentPlan allocation) (historyBefore source plan frames).base 61440
  historyState : MemoryRegions.Disjoint (historyBefore source plan frames).base 61440 recurrentPlan.allocation.stateBase 3145728
  suffixSafe : (suffixWeights source plan frames).Protected (DeltaTailMemory.Safe (tailExecution source plan frames recurrentPlan allocation))

def suffixParameters (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan)
    (recurrentPlan : RecurrencePlan source plan frames) (tail : TailPlan source plan frames recurrentPlan) :
    ResidualDeltaConstruction.SuffixParameters (block := layer.suffix) (tailExecution source plan frames recurrentPlan tail.allocation) := by
  let w := suffixWeights source plan frames
  have memory := recurrent_memory source plan frames recurrentPlan
  let stored := w.trellis.reframe (recurrent source plan frames recurrentPlan).input.state.bytes
    (w.trellis.protected_mono (fun _ _ _ _ _ => congrFun memory _) tail.suffixSafe.2)
  refine ⟨w.norm,w.normShared.trans memory.symm,tail.suffixSafe.1,stored,?_⟩
  change w.trellis.Protected (DeltaTailMemory.Safe (tailExecution source plan frames recurrentPlan tail.allocation))
  exact tail.suffixSafe.2

theorem suffixSourceShared (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan)
    (allocation : RecurrencePlan source plan frames) :
    (residualBefore source plan frames).bytes=(recurrent source plan frames allocation).input.state.bytes :=
  (show (residualBefore source plan frames).bytes=(preparation source plan).prepared.gates.betaBuffer.bytes from rfl).trans
    (recurrent_memory source plan frames allocation).symm

abbrev SuffixPlan (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan)
    (recurrentPlan : RecurrencePlan source plan frames) (tail : TailPlan source plan frames recurrentPlan) :=
  ResidualDeltaConstruction.SuffixAllocation (tailExecution source plan frames recurrentPlan tail.allocation)
    (residualBefore source plan frames) (suffixSourceShared source plan frames recurrentPlan) tail.residualSafe (historyBefore source plan frames)
    (suffixParameters source plan frames recurrentPlan tail)

structure Plan (source : Source layer cache input) where
  preparation : PreparationPlan source
  frames : PreparationFrames source preparation
  recurrent : RecurrencePlan source preparation frames
  tail : TailPlan source preparation frames recurrent
  suffix : SuffixPlan source preparation frames recurrent tail

theorem tailInput_bases (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan)
    (allocation : RecurrencePlan source plan frames) :
    (tailInput source plan frames allocation).gate.base=source.entry.affine.gateBuffer.base ∧
    (tailInput source plan frames allocation).weight.base=source.parametersAfterEntry.normalization.base := by
  unfold tailInput
  exact ⟨rfl,rfl⟩

attribute [local semireducible] recurrenceInput tailExecution preparation
attribute [local irreducible] ResidualDeltaConstruction.preparation

theorem historyShared (source : Source layer cache input) (plan : Plan source) :
    (historyBefore source plan.preparation plan.frames).bytes=(recurrent source plan.preparation plan.frames plan.recurrent).input.state.bytes :=
  (show (historyBefore source plan.preparation plan.frames).bytes=(preparation source plan.preparation).prepared.gates.betaBuffer.bytes from rfl).trans
    (recurrent_memory source plan.preparation plan.frames plan.recurrent).symm

def suffixExecution (source : Source layer cache input) (plan : Plan source) :=
  ResidualDeltaConstruction.suffix (tailExecution source plan.preparation plan.frames plan.recurrent plan.tail.allocation)
    (residualBefore source plan.preparation plan.frames) (suffixSourceShared source plan.preparation plan.frames plan.recurrent)
    plan.tail.residualSafe (historyBefore source plan.preparation plan.frames) (historyShared source plan) plan.tail.historySafe
    plan.tail.historyState (suffixParameters source plan.preparation plan.frames plan.recurrent plan.tail) plan.suffix

def block (source : Source layer cache input) (plan : Plan source) :
    DeltaBlockMemory.Execution (preparation source plan.preparation) cache.recurrent layer.mixer.recurrence.reduce layer.mixer.recurrence.flags
      (DeltaNet.zHead layer.mixer (fun _ => layer.inputNorm.forward input) 0) layer.mixer.normWeight layer.mixer.gated layer.mixer.out layer.suffix input := by
  refine ⟨source.cacheAfterEntry.buffers.recurrent,rfl,plan.frames.stateSafe,plan.frames.historySafe,
    source.entry.savedResidual,rfl,plan.frames.residualSafe,recurrent source plan.preparation plan.frames plan.recurrent,?_,
    tailInput source plan.preparation plan.frames plan.recurrent,
    tailExecution source plan.preparation plan.frames plan.recurrent plan.tail.allocation,suffixExecution source plan,rfl,rfl⟩
  unfold recurrent recurrenceInput
  rfl

def fromStorage (source : Source layer cache input) (plan : Plan source) : ResidualDeltaMemory.Execution layer cache input := by
  let convWindow := DeltaPreparationConstruction.window source.entry.affine source.cacheAfterEntry source.parametersAfterEntry rfl plan.preparation.convolution
  let window := DeltaProjectionHandoff.convolutionInput source.entry.affine source.parametersAfterEntry convWindow rfl
    plan.preparation.convolution.joinWeight plan.preparation.convolution.tailWeight
  let convolved := DeltaPreparationConstruction.convolved source.entry.affine source.cacheAfterEntry source.parametersAfterEntry rfl plan.preparation.convolution
  refine ⟨source.entry,source.cacheStorage,source.entryFrames.shared,source.entryFrames.historySafe,source.entryFrames.stateSafe,
    source.parameters,source.entryFrames.parameterSafe,window,rfl,rfl,rfl,convolved,preparation source plan.preparation,?_,?_,?_,
    block source plan,rfl,rfl,plan.frames.gateSafe,plan.frames.normSafe,?_,?_⟩
  · unfold preparation ResidualDeltaConstruction.preparation DeltaPreparationConstruction.fromStorage DeltaPreparationConstruction.scales
    rfl
  · unfold preparation ResidualDeltaConstruction.preparation DeltaPreparationConstruction.fromStorage DeltaPreparationConstruction.scales
    rfl
  · unfold preparation ResidualDeltaConstruction.preparation DeltaPreparationConstruction.fromStorage
    rfl
  · exact (tailInput_bases source plan.preparation plan.frames plan.recurrent).1
  · exact (tailInput_bases source plan.preparation plan.frames plan.recurrent).2


theorem Source.initialHeap (source : Source layer cache input) : source.entry.source.lhs.bytes=source.data.source.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes (ResidualDeltaConstruction.normalized_source source.data)

theorem source_linked (source : Source layer cache input) (plan : Plan source) :
    (fromStorage source plan).entry.source.lhs=source.data.source :=
  ResidualDeltaConstruction.normalized_source source.data

theorem cache_linked (source : Source layer cache input) (plan : Plan source) :
    (fromStorage source plan).storage=source.cacheStorage := rfl

theorem parameters_linked (source : Source layer cache input) (plan : Plan source) :
    (fromStorage source plan).parameters=source.parameters := rfl

theorem gate_norm_bases (source : Source layer cache input) (plan : Plan source) :
    (fromStorage source plan).block.tailInput.gate.base=source.entry.affine.gateBuffer.base ∧
    (fromStorage source plan).block.tailInput.weight.base=source.parametersAfterEntry.normalization.base :=
  tailInput_bases source plan.preparation plan.frames plan.recurrent

theorem suffix_original_regions (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan)
    (property : Nat → Nat → Prop) :
    (suffixWeights source plan frames).Protected property ↔ source.suffix.Protected property := by
  unfold suffixWeights Source.suffixAfterEntry ResidualDeltaConstruction.MlpWeights.afterEntry ResidualDeltaConstruction.MlpWeights.afterPreparation
  rfl

theorem projection_original_regions (source : Source layer cache input) (plan : PreparationPlan source) (frames : PreparationFrames source plan)
    (property : Nat → Nat → Prop) :
    AffineMemoryFrames.Protected layer.mixer.out (projectionWeights source plan frames) property ↔
      AffineMemoryFrames.Protected layer.mixer.out source.parameters.projection property := by
  unfold projectionWeights ResidualDeltaConstruction.projectionBeforeRecurrence
  rw [AffineMemoryFrames.reframe_protected]
  unfold Source.parametersAfterEntry ResidualDeltaConstruction.entryParameters DeltaNormalizedMemory.Execution.parametersAfter DeltaParameterMemory.reframe
  exact AffineMemoryFrames.reframe_protected layer.mixer.out source.parameters.projection _ _ property

theorem output_eq (source : Source layer cache input) (plan : Plan source) :
    (fromStorage source plan).output=layer.forward cache (fun _ => input) 0 := (fromStorage source plan).output_eq

theorem cache_eq (source : Source layer cache input) (plan : Plan source) :
    (fromStorage source plan).readCache=layer.cacheAfter cache (fun _ => input) 1 := (fromStorage source plan).read_cache_eq

end Inference.Models.Qwen.ResidualDeltaStorageConstruction
