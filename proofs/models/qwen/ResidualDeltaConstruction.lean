import models.qwen.ResidualDeltaMemory
import models.qwen.DeltaNormalizedConstruction
import models.qwen.DeltaPreparationConstruction
import models.qwen.DeltaTailConstruction
import models.qwen.ResidualMlpConstruction

namespace Inference.Models.Qwen.ResidualDeltaConstruction
open Contracts.Mlx Kernels Kernels.Delta Layers
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000

variable {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}
  {initial : GatedDevice.State} {values : GatedInputs.Values}
  {recurrence : GatedShared.Execution reduce flags initial values}
  {gate : GatedRmsNormDevice.Rows} {weights : Fin 128 → ArrayStorage.BF}
  {tailInput : DeltaTailMemory.Input recurrence gate weights}
  {p : GatedRmsNorm.Platform} {width eps : Float32} {projection : AffineVerifyLinear.Projection 12 5120}
  {x : Fin 5120 → ArrayStorage.BF} {block : ResidualBlocks.Mlp}

structure SuffixParameters (tail : DeltaTailMemory.Execution tailInput p width eps projection) where
  norm : ArrayStorage.BFBuffer block.norm.weight
  normShared : norm.bytes=recurrence.input.state.bytes
  normSafe : DeltaTailMemory.Safe tail norm.base 10240
  trellis : TrellisWeightsMemory.Weights block.mlp recurrence.input.state.bytes
  trellisSafe : trellis.Protected (DeltaTailMemory.Safe tail)

def SuffixParameters.normAfter (parameters : SuffixParameters (block := block) tail) : ArrayStorage.BFBuffer block.norm.weight :=
  ArrayFrame.bf parameters.norm tail.buffer.bytes (fun offset bound =>
    (tail.other_region parameters.normSafe offset bound).trans (congrFun parameters.normShared _).symm)

def SuffixParameters.trellisAfter (parameters : SuffixParameters (block := block) tail) :
    TrellisWeightsMemory.Weights block.mlp tail.buffer.bytes :=
  parameters.trellis.reframe _ (parameters.trellis.protected_mono
    (fun _ _ safe => tail.other_region safe) parameters.trellisSafe)

structure SuffixAllocation (tail : DeltaTailMemory.Execution tailInput p width eps projection)
    (source : ArrayStorage.BFBuffer x) (shared : source.bytes=recurrence.input.state.bytes)
    (sourceSafe : DeltaTailMemory.Safe tail source.base 10240)
    {history : State.ConvolutionStorage.History} (historyBuffer : State.ConvolutionStorage.Storage history)
    (parameters : SuffixParameters (block := block) tail) where
  allocation : ResidualMlpConstruction.Allocation (DeltaResidualMemory.residualInput tail source shared sourceSafe)
    parameters.normAfter rfl parameters.trellisAfter
  historySafe : ResidualMlpConstruction.RegionsSafe allocation historyBuffer.base 61440
  stateSafe : ResidualMlpConstruction.RegionsSafe allocation recurrence.stores.trace.stateBase 3145728

def suffix (tail : DeltaTailMemory.Execution tailInput p width eps projection)
    (source : ArrayStorage.BFBuffer x) (shared : source.bytes=recurrence.input.state.bytes)
    (sourceSafe : DeltaTailMemory.Safe tail source.base 10240)
    {history : State.ConvolutionStorage.History} (historyBuffer : State.ConvolutionStorage.Storage history)
    (historyShared : historyBuffer.bytes=recurrence.input.state.bytes)
    (historySafe : DeltaTailMemory.Safe tail historyBuffer.base 61440)
    (historyState : MemoryRegions.Disjoint historyBuffer.base 61440 recurrence.stores.trace.stateBase 3145728)
    (parameters : SuffixParameters (block := block) tail)
    (allocation : SuffixAllocation tail source shared sourceSafe historyBuffer parameters) :
    DeltaResidualMemory.Execution tail block x history := by
  let input := DeltaResidualMemory.residualInput tail source shared sourceSafe
  let mlp := ResidualMlpConstruction.fromStorage input parameters.normAfter rfl parameters.trellisAfter allocation.allocation
  exact ⟨source,shared,sourceSafe,historyBuffer,historyShared,historySafe,historyState,mlp,
    ResidualMlpConstruction.fromStorage_safe _ _ _ _ _ allocation.historySafe,
    ResidualMlpConstruction.fromStorage_safe _ _ _ _ _ allocation.stateSafe⟩


structure TailData (recurrence : GatedShared.Execution reduce flags initial values)
    (gate : GatedRmsNormDevice.Rows) (weights : Fin 128 → ArrayStorage.BF)
    (p : GatedRmsNorm.Platform) (width eps : Float32) (projection : AffineVerifyLinear.Projection 12 5120) where
  input : DeltaTailMemory.Input recurrence gate weights
  projectionWeights : AffineDevice.Storage projection
  shared : AffineMemory.Shared projection projectionWeights recurrence.input.state.bytes
  allocation : DeltaTailConstruction.Allocation input projectionWeights

def TailData.execution (data : TailData recurrence gate weights p width eps projection) :
    DeltaTailMemory.Execution data.input p width eps projection :=
  DeltaTailConstruction.fromRecurrence data.input p width eps data.projectionWeights data.shared data.allocation

attribute [local irreducible] TailData.execution

section Block
variable {history : State.ConvolutionStorage.History} {next : Fin 10240 → ArrayStorage.BF}
  {convWeights : Fin 10240 → Fin 4 → ArrayStorage.BF} {convInput : ConvolutionMemory.Input history next convWeights}
  {contracted : Bool} {convolution : ConvolutionMemory.Execution convInput contracted}
  {qScale kScale : Fin 128 → ArrayStorage.BF} {headPlatform : SiluRmsHeads.Platform} {headWidth headEps : Float32}
  {aLog a dtBias b : GateDevice.Heads} {gatePlatform : Inputs.Platform}

structure BlockPlan
    (preparation : DeltaConvolutionMemory.Execution convolution qScale kScale headPlatform headWidth headEps aLog a dtBias b gatePlatform)
    (initial : GatedDevice.State) (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction)
    (gate : GatedRmsNormDevice.Rows) (weights : Fin 128 → ArrayStorage.BF)
    (p : GatedRmsNorm.Platform) (projection : AffineVerifyLinear.Projection 12 5120)
    (block : ResidualBlocks.Mlp) (x : Fin 5120 → ArrayStorage.BF)
    (state : GatedDevice.Storage initial) (stateShared : state.bytes=convInput.window.joined.old.bytes)
    (stateSafe : DeltaConvolutionMemory.Safe preparation state.base 3145728)
    (source : ArrayStorage.BFBuffer x) (sourceShared : source.bytes=convInput.window.joined.old.bytes)
    (sourceSafe : DeltaConvolutionMemory.Safe preparation source.base 10240) where
  historySafe : DeltaPreparedMemory.Safe preparation.prepared convolution.afterHistory.base 61440
  recurrenceAllocation : DeltaTailConstruction.RecurrenceAllocation (preparation.recurrenceInput state stateShared stateSafe)
  tailData : TailData (DeltaTailConstruction.recurrence reduce flags
    (preparation.recurrenceInput state stateShared stateSafe) recurrenceAllocation) gate weights p headWidth headEps projection
  residualTailSafe : DeltaTailMemory.Safe tailData.execution source.base 10240
  historyTailSafe : DeltaTailMemory.Safe tailData.execution convolution.afterHistory.base 61440
  historyState : MemoryRegions.Disjoint convolution.afterHistory.base 61440 recurrenceAllocation.stateBase 3145728
  suffixParameters : SuffixParameters (block := block) tailData.execution
  suffixAllocation : SuffixAllocation tailData.execution
    (DeltaBlockMemory.residualBeforeRecurrence preparation source sourceShared sourceSafe) rfl residualTailSafe
    (preparation.historyAfter historySafe) suffixParameters

def fromPreparation
    (preparation : DeltaConvolutionMemory.Execution convolution qScale kScale headPlatform headWidth headEps aLog a dtBias b gatePlatform)
    (state : GatedDevice.Storage initial) (stateShared : state.bytes=convInput.window.joined.old.bytes)
    (stateSafe : DeltaConvolutionMemory.Safe preparation state.base 3145728)
    (source : ArrayStorage.BFBuffer x) (sourceShared : source.bytes=convInput.window.joined.old.bytes)
    (sourceSafe : DeltaConvolutionMemory.Safe preparation source.base 10240)
    (plan : BlockPlan preparation initial reduce flags gate weights p projection block x state stateShared stateSafe source sourceShared sourceSafe) :
    DeltaBlockMemory.Execution preparation initial reduce flags gate weights p projection block x := by
  let recurrent := DeltaTailConstruction.recurrence reduce flags
    (preparation.recurrenceInput state stateShared stateSafe) plan.recurrenceAllocation
  let tail := plan.tailData.execution
  let residual := DeltaBlockMemory.residualBeforeRecurrence preparation source sourceShared sourceSafe
  let nextHistory := preparation.historyAfter plan.historySafe
  let suffix := suffix tail residual rfl plan.residualTailSafe nextHistory rfl plan.historyTailSafe
    plan.historyState plan.suffixParameters plan.suffixAllocation
  exact ⟨state,stateShared,stateSafe,plan.historySafe,source,sourceShared,sourceSafe,
    recurrent,rfl,plan.tailData.input,tail,suffix,rfl,rfl⟩
end Block


section Entry
variable {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → ArrayStorage.BF}

structure EntryFrames (entry : DeltaNormalizedMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer.mixer entry.source.lhs.bytes) : Prop where
  shared : storage.memory=entry.source.lhs.bytes
  historySafe : DeltaNormalizedMemory.Safe entry storage.buffers.history.base 61440
  stateSafe : DeltaNormalizedMemory.Safe entry storage.buffers.recurrent.base 3145728
  parameterSafe : DeltaParameterMemory.Protected parameters (DeltaNormalizedMemory.Safe entry)

def entryCache (entry : DeltaNormalizedMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer.mixer entry.source.lhs.bytes) (frames : EntryFrames entry storage parameters) :=
  entry.afterCache storage frames.shared frames.historySafe frames.stateSafe

def entryParameters (entry : DeltaNormalizedMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer.mixer entry.source.lhs.bytes) (frames : EntryFrames entry storage parameters) :=
  entry.parametersAfter parameters frames.parameterSafe

abbrev ConvAllocation (entry : DeltaNormalizedMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer.mixer entry.source.lhs.bytes) (frames : EntryFrames entry storage parameters) :=
  DeltaPreparationConstruction.ConvolutionAllocation entry.affine (entryCache entry storage parameters frames)
    (entryParameters entry storage parameters frames)

abbrev PrepAllocation (entry : DeltaNormalizedMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer.mixer entry.source.lhs.bytes) (frames : EntryFrames entry storage parameters)
    (allocation : ConvAllocation entry storage parameters frames) :=
  DeltaPreparationConstruction.PreparationAllocation entry.affine (entryCache entry storage parameters frames)
    (entryParameters entry storage parameters frames) rfl allocation

def preparation (entry : DeltaNormalizedMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer.mixer entry.source.lhs.bytes) (frames : EntryFrames entry storage parameters)
    (allocation : ConvAllocation entry storage parameters frames) (prepared : PrepAllocation entry storage parameters frames allocation) :=
  DeltaPreparationConstruction.fromStorage entry.affine (entryCache entry storage parameters frames)
    (entryParameters entry storage parameters frames) rfl allocation prepared

attribute [local irreducible] preparation

structure EntryPlan (entry : DeltaNormalizedMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer.mixer entry.source.lhs.bytes) (frames : EntryFrames entry storage parameters) where
  convolution : ConvAllocation entry storage parameters frames
  prepared : PrepAllocation entry storage parameters frames convolution
  stateSafe : DeltaConvolutionMemory.Safe (preparation entry storage parameters frames convolution prepared)
    (entryCache entry storage parameters frames).buffers.recurrent.base 3145728
  residualSafe : DeltaConvolutionMemory.Safe (preparation entry storage parameters frames convolution prepared) entry.savedResidual.base 10240
  blockPlan : BlockPlan (preparation entry storage parameters frames convolution prepared)
    cache.recurrent layer.mixer.recurrence.reduce layer.mixer.recurrence.flags
    (DeltaNet.zHead layer.mixer (fun _ => layer.inputNorm.forward input) 0) layer.mixer.normWeight layer.mixer.gated layer.mixer.out layer.suffix input
    (entryCache entry storage parameters frames).buffers.recurrent rfl stateSafe entry.savedResidual rfl residualSafe
  gateSafe : DeltaConvolutionMemory.Safe (preparation entry storage parameters frames convolution prepared) entry.affine.gateBuffer.base 12288
  normSafe : DeltaConvolutionMemory.Safe (preparation entry storage parameters frames convolution prepared)
    (entryParameters entry storage parameters frames).normalization.base 256
  gateBase : blockPlan.tailData.input.gate.base=entry.affine.gateBuffer.base
  normBase : blockPlan.tailData.input.weight.base=(entryParameters entry storage parameters frames).normalization.base

def fromEntry (entry : DeltaNormalizedMemory.Execution layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer.mixer entry.source.lhs.bytes) (frames : EntryFrames entry storage parameters)
    (plan : EntryPlan entry storage parameters frames) : ResidualDeltaMemory.Execution layer cache input := by
  let cache := entryCache entry storage parameters frames
  let params := entryParameters entry storage parameters frames
  let convWindow := DeltaPreparationConstruction.window entry.affine cache params rfl plan.convolution
  let window := DeltaProjectionHandoff.convolutionInput entry.affine params convWindow rfl plan.convolution.joinWeight plan.convolution.tailWeight
  let convolution := DeltaPreparationConstruction.convolved entry.affine cache params rfl plan.convolution
  let prep := preparation entry storage parameters frames plan.convolution plan.prepared
  let block := fromPreparation prep cache.buffers.recurrent rfl plan.stateSafe entry.savedResidual rfl plan.residualSafe plan.blockPlan
  exact ⟨entry,storage,frames.shared,frames.historySafe,frames.stateSafe,parameters,frames.parameterSafe,
    window,rfl,rfl,rfl,convolution,prep,
    (by unfold prep preparation DeltaPreparationConstruction.fromStorage DeltaPreparationConstruction.scales; rfl),
    (by unfold prep preparation DeltaPreparationConstruction.fromStorage DeltaPreparationConstruction.scales; rfl),
    (by unfold prep preparation DeltaPreparationConstruction.fromStorage; rfl),block,rfl,rfl,plan.gateSafe,plan.normSafe,plan.gateBase,plan.normBase⟩
end Entry


structure InputData (layer : ResidualDelta.Layer) (input : Fin 5120 → ArrayStorage.BF) where
  source : ArrayStorage.BFBuffer input
  normWeights : ArrayStorage.BFBuffer layer.inputNorm.weight
  shared : normWeights.bytes=source.bytes
  normalizationBase : Nat
  normalizationBounded : 2*normalizationBase+10240 ≤ 2^64
  residualSeparate : MemoryRegions.Disjoint (2*normalizationBase) 10240 source.base 10240
  normSeparate : MemoryRegions.Disjoint (2*normalizationBase) 10240 normWeights.base 10240
  affineWeights : DeltaAffineConstruction.Weights layer.mixer source.bytes
  affineSafe : DeltaNormalizedConstruction.Protected affineWeights (MemoryRegions.Disjoint (2*normalizationBase) 10240)
  affineRegions : DeltaAffineConstruction.Regions
  affineAllocation : let normalization := (NormalizationMemory.fromStorage layer.inputNorm source normWeights shared normalizationBase
      normalizationBounded (Or.inr (MemoryRegions.disjoint_symm residualSeparate)) normSeparate)
    DeltaAffineConstruction.Allocation affineRegions (NormalizationMemory.forwardBuffer normalization)
      (DeltaNormalizedConstruction.afterWeights normalization affineWeights affineSafe)
  residualLive : affineRegions.Live source.base 10240

def normalized (data : InputData layer input) : DeltaNormalizedMemory.Execution layer input :=
  DeltaNormalizedConstruction.fromStorage data.source data.normWeights data.shared data.normalizationBase data.normalizationBounded
    data.residualSeparate data.normSeparate data.affineWeights data.affineSafe data.affineRegions data.affineAllocation data.residualLive

theorem normalized_source (data : InputData layer input) : (normalized data).source.lhs=data.source := rfl

def fromStorage (data : InputData layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer.mixer (normalized data).source.lhs.bytes)
    (frames : EntryFrames (normalized data) storage parameters)
    (plan : EntryPlan (normalized data) storage parameters frames) : ResidualDeltaMemory.Execution layer cache input :=
  fromEntry (normalized data) storage parameters frames plan


-- This optional raw parameter bundle lets callers carry the same suffix
-- payloads from the initial heap rather than attach replacement buffers.
structure MlpWeights (block : ResidualBlocks.Mlp) (memory : ByteMemory.Bytes) where
  norm : ArrayStorage.BFBuffer block.norm.weight
  normShared : norm.bytes=memory
  trellis : TrellisWeightsMemory.Weights block.mlp memory

def MlpWeights.Protected (parameters : MlpWeights block memory) (property : Nat → Nat → Prop) : Prop :=
  property parameters.norm.base 10240 ∧ parameters.trellis.Protected property

def MlpWeights.reframe (parameters : MlpWeights block memory) (after : ByteMemory.Bytes)
    (same : parameters.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) : MlpWeights block after :=
  ⟨ArrayFrame.bf parameters.norm after (fun offset bound => (same.1 offset bound).trans (congrFun parameters.normShared _).symm),
    rfl,parameters.trellis.reframe after same.2⟩

def MlpWeights.afterEntry {layer : ResidualDelta.Layer} (entry : DeltaNormalizedMemory.Execution layer input)
    (parameters : MlpWeights block entry.source.lhs.bytes)
    (safe : parameters.Protected (DeltaNormalizedMemory.Safe entry)) : MlpWeights block entry.affine.memory :=
  parameters.reframe _ ⟨entry.other_region safe.1,
    parameters.trellis.protected_mono (fun _ _ h => entry.other_region h) safe.2⟩

section FramePreparation
variable {history : State.ConvolutionStorage.History} {next : Fin 10240 → ArrayStorage.BF}
  {convWeights : Fin 10240 → Fin 4 → ArrayStorage.BF} {convInput : ConvolutionMemory.Input history next convWeights}
  {contracted : Bool} {convolution : ConvolutionMemory.Execution convInput contracted}
  {qScale kScale : Fin 128 → ArrayStorage.BF} {headPlatform : SiluRmsHeads.Platform} {headWidth headEps : Float32}
  {aLog a dtBias b : GateDevice.Heads} {gatePlatform : Inputs.Platform}

variable (preparation : DeltaConvolutionMemory.Execution convolution qScale kScale headPlatform headWidth headEps aLog a dtBias b gatePlatform)

def MlpWeights.afterPreparation (parameters : MlpWeights block convInput.window.joined.old.bytes)
    (safe : parameters.Protected (DeltaConvolutionMemory.Safe preparation)) :
    MlpWeights block preparation.prepared.gates.betaBuffer.bytes :=
  parameters.reframe _ ⟨preparation.other_region safe.1,
    parameters.trellis.protected_mono (fun _ _ h => preparation.other_region h) safe.2⟩

def projectionBeforeRecurrence (projectionWeights : AffineDevice.Storage projection)
    (shared : AffineMemory.Shared projection projectionWeights convInput.window.joined.old.bytes)
    (safe : AffineMemoryFrames.Protected projection projectionWeights (DeltaConvolutionMemory.Safe preparation)) :
    AffineDevice.Storage projection :=
  AffineMemoryFrames.reframe projection projectionWeights preparation.prepared.gates.betaBuffer.bytes
    (AffineMemoryFrames.stable projection projectionWeights _ _ shared
      (AffineMemoryFrames.protected_mono projection projectionWeights (fun _ _ h => preparation.other_region h) safe))

def tailInputBeforeRecurrence
    (state : GatedDevice.Storage initial) (stateShared : state.bytes=convInput.window.joined.old.bytes)
    (stateSafe : DeltaConvolutionMemory.Safe preparation state.base 3145728)
    (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction)
    (allocation : DeltaTailConstruction.RecurrenceAllocation (preparation.recurrenceInput state stateShared stateSafe))
    (gateBuffer : ArrayStorage.BFBuffer (GatedInputs.flatten gate)) (gateShared : gateBuffer.bytes=convInput.window.joined.old.bytes)
    (gateSafe : DeltaConvolutionMemory.Safe preparation gateBuffer.base 12288)
    (norm : ArrayStorage.BFBuffer weights) (normShared : norm.bytes=convInput.window.joined.old.bytes)
    (normSafe : DeltaConvolutionMemory.Safe preparation norm.base 256)
    (stateGate : MemoryRegions.Disjoint allocation.stateBase 3145728 gateBuffer.base 12288)
    (outputGate : MemoryRegions.Disjoint allocation.outputBase 12288 gateBuffer.base 12288)
    (stateNorm : MemoryRegions.Disjoint allocation.stateBase 3145728 norm.base 256)
    (outputNorm : MemoryRegions.Disjoint allocation.outputBase 12288 norm.base 256) :
    DeltaTailMemory.Input (DeltaTailConstruction.recurrence reduce flags
      (preparation.recurrenceInput state stateShared stateSafe) allocation) gate weights :=
  ⟨ArrayFrame.bf gateBuffer preparation.prepared.gates.betaBuffer.bytes
    (fun offset bound => (preparation.other_region gateSafe offset bound).trans (congrFun gateShared _).symm),
    ArrayFrame.bf norm preparation.prepared.gates.betaBuffer.bytes
    (fun offset bound => (preparation.other_region normSafe offset bound).trans (congrFun normShared _).symm),
    rfl,rfl,stateGate,outputGate,stateNorm,outputNorm⟩
end FramePreparation

def MlpWeights.suffixParameters (parameters : MlpWeights block recurrence.input.state.bytes)
    (tail : DeltaTailMemory.Execution tailInput p width eps projection)
    (safe : parameters.Protected (DeltaTailMemory.Safe tail)) : SuffixParameters (block := block) tail :=
  ⟨parameters.norm,parameters.normShared,safe.1,parameters.trellis,safe.2⟩


theorem output_eq (data : InputData layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer.mixer (normalized data).source.lhs.bytes)
    (frames : EntryFrames (normalized data) storage parameters)
    (plan : EntryPlan (normalized data) storage parameters frames) :
    (fromStorage data storage parameters frames plan).output=layer.forward cache (fun _ => input) 0 :=
  (fromStorage data storage parameters frames plan).output_eq

theorem cache_eq (data : InputData layer input) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer.mixer (normalized data).source.lhs.bytes)
    (frames : EntryFrames (normalized data) storage parameters)
    (plan : EntryPlan (normalized data) storage parameters frames) :
    (fromStorage data storage parameters frames plan).readCache=layer.cacheAfter cache (fun _ => input) 1 :=
  (fromStorage data storage parameters frames plan).read_cache_eq

end Inference.Models.Qwen.ResidualDeltaConstruction
