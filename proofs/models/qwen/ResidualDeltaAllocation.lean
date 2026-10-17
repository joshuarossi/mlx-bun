import models.qwen.ResidualDeltaWorkspaceConstruction

namespace Inference.Models.Qwen.ResidualDeltaAllocation
open Contracts.Mlx Layers Kernels Kernels.Delta
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000
attribute [local irreducible] ResidualDeltaConstruction.preparation ResidualDeltaStorageConstruction.preparation

-- Entry 0, preparation 43200, recurrent tail 227808, residual MLP 3408352.
def bytes : Nat := 4139488

structure Workspace (origin : ArrayStorage.BFBuffer input)
    (storage : DecodeFrame.StageBuffer (n := n) (.delta layer) cache origin.bytes)
    (checkpoint : DecodeParameterMemory.DeltaStorage layer origin.bytes) where
  base : Nat
  aligned : base%16=0
  bounded : base+bytes≤2^64
  sourceFresh : MemoryRegions.Disjoint base bytes origin.base 10240
  parametersFresh : checkpoint.Protected (MemoryRegions.Disjoint base bytes)
  historyFresh : MemoryRegions.Disjoint base bytes storage.storage.buffers.history.base 61440
  stateFresh : MemoryRegions.Disjoint base bytes storage.storage.buffers.recurrent.base 3145728

variable {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → ArrayStorage.BF}
  {origin : ArrayStorage.BFBuffer input} {storage : DecodeFrame.StageBuffer (n := n) (.delta layer) cache origin.bytes}
  {checkpoint : DecodeParameterMemory.DeltaStorage layer origin.bytes} (w : Workspace origin storage checkpoint)

theorem Workspace.subregion {offset length base size : Nat} (inside : offset+length≤bytes)
    (safe : MemoryRegions.Disjoint w.base bytes base size) :
    MemoryRegions.Disjoint (w.base+offset) length base size := by unfold MemoryRegions.Disjoint at *; dsimp [bytes] at *; omega

def Workspace.entryArena : DeltaEntryAllocation.Arena where
  base := w.base
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; dsimp [bytes] at this; omega

def Workspace.preparationArena : DeltaPreparationAllocation.Arena where
  base := w.base+43200
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; dsimp [bytes] at this; omega

def Workspace.tailArena : DeltaTailAllocation.Arena where
  base := w.base+227808
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; dsimp [bytes] at this; omega

def Workspace.suffixArena : ResidualDeltaWorkspaceConstruction.SuffixArena where
  base := w.base+3408352
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; dsimp [bytes] at this; omega

def Workspace.entryWorkspace : ResidualDeltaWorkspaceConstruction.EntryWorkspace origin storage checkpoint where
  arena := w.entryArena
  sourceFresh := w.subregion (offset := 0) (length := 43200) (by decide) w.sourceFresh
  parametersFresh := checkpoint.protected_mono (fun _ _ h => w.subregion (offset := 0) (length := 43200) (by decide) h) w.parametersFresh
  historyFresh := w.subregion (offset := 0) (length := 43200) (by decide) w.historyFresh
  stateFresh := w.subregion (offset := 0) (length := 43200) (by decide) w.stateFresh

theorem affine_buffers_bases (phase : DeltaAffineMemory.Execution mixer values) :
    phase.qkvBuffer.base=phase.qkv.base ∧ phase.aBuffer.base=phase.a.base ∧
      phase.bBuffer.base=phase.b.base ∧ phase.gateBuffer.base=phase.z.base :=
  ⟨DeltaAffineConstruction.forward_base phase.qkv,DeltaAffineConstruction.forward_base phase.a,
    DeltaAffineConstruction.forward_base phase.b,DeltaAffineConstruction.forward_base phase.z⟩

theorem normalized_bases (data : ResidualDeltaConstruction.InputData layer input) :
    (ResidualDeltaConstruction.normalized data).affine.qkvBuffer.base=data.affineRegions.qkv ∧
    (ResidualDeltaConstruction.normalized data).affine.aBuffer.base=data.affineRegions.a ∧
    (ResidualDeltaConstruction.normalized data).affine.bBuffer.base=data.affineRegions.b ∧
    (ResidualDeltaConstruction.normalized data).affine.gateBuffer.base=data.affineRegions.z := by
  have bases := DeltaAffineConstruction.fromStorage_bases layer.mixer (layer.inputNorm.forward input)
    (NormalizationMemory.forwardBuffer (NormalizationMemory.fromStorage layer.inputNorm data.source data.normWeights data.shared
      data.normalizationBase data.normalizationBounded (Or.inr (MemoryRegions.disjoint_symm data.residualSeparate)) data.normSeparate))
    _ data.affineRegions data.affineAllocation
  change (ResidualDeltaConstruction.normalized data).affine.qkv.base=data.affineRegions.qkv ∧
    (ResidualDeltaConstruction.normalized data).affine.z.base=data.affineRegions.z ∧
    (ResidualDeltaConstruction.normalized data).affine.a.base=data.affineRegions.a ∧
    (ResidualDeltaConstruction.normalized data).affine.b.base=data.affineRegions.b at bases
  have buffers := affine_buffers_bases (ResidualDeltaConstruction.normalized data).affine
  exact ⟨buffers.1.trans bases.1,buffers.2.1.trans bases.2.2.1,
    buffers.2.2.1.trans bases.2.2.2,buffers.2.2.2.trans bases.2.1⟩

theorem Workspace.entry_layout :
    w.entryWorkspace.strongSource.entry.affine.qkvBuffer.base=w.base+10240 ∧
    w.entryWorkspace.strongSource.entry.affine.aBuffer.base=w.base+43008 ∧
    w.entryWorkspace.strongSource.entry.affine.bBuffer.base=w.base+43104 ∧
    w.entryWorkspace.strongSource.entry.affine.gateBuffer.base=w.base+30720 :=
  normalized_bases w.entryWorkspace.entry.data

theorem Workspace.residual_base : w.entryWorkspace.strongSource.entry.savedResidual.base=origin.base :=
  congrArg (fun buffer => buffer.base) w.entryWorkspace.entry.sourceLinked

theorem Workspace.mixer_regions (property : Nat → Nat → Prop) :
    DeltaParameterMemory.Protected w.entryWorkspace.strongSource.parameters property ↔ DeltaParameterMemory.Protected checkpoint.mixer property :=
  DeltaEntryAllocation.mixer_transport checkpoint.mixer w.entryWorkspace.entry.heap property

theorem Workspace.suffix_regions (property : Nat → Nat → Prop) :
    w.entryWorkspace.strongSource.suffix.Protected property ↔ checkpoint.suffix.Protected property :=
  DeltaEntryAllocation.suffix_transport checkpoint.suffix w.entryWorkspace.entry.heap property


theorem Workspace.preparationFresh : DeltaPreparationAllocation.Fresh w.entryWorkspace.strongSource w.preparationArena where
  history := w.subregion (offset := 43200) (length := 184608) (by decide) w.historyFresh
  state := w.subregion (offset := 43200) (length := 184608) (by decide) w.stateFresh
  qkv := by rw [w.entry_layout.1]; change MemoryRegions.Disjoint (w.base+43200) 184608 (w.base+10240) 20480; unfold MemoryRegions.Disjoint; omega
  a := by rw [w.entry_layout.2.1]; change MemoryRegions.Disjoint (w.base+43200) 184608 (w.base+43008) 96; unfold MemoryRegions.Disjoint; omega
  b := by rw [w.entry_layout.2.2.1]; change MemoryRegions.Disjoint (w.base+43200) 184608 (w.base+43104) 96; unfold MemoryRegions.Disjoint; omega
  z := by rw [w.entry_layout.2.2.2]; change MemoryRegions.Disjoint (w.base+43200) 184608 (w.base+30720) 12288; unfold MemoryRegions.Disjoint; omega
  residual := by rw [w.residual_base]; exact w.subregion (offset := 43200) (length := 184608) (by decide) w.sourceFresh
  parameters := (w.mixer_regions _).mpr (DeltaParameterMemory.protected_mono checkpoint.mixer
    (fun _ _ h => w.subregion (offset := 43200) (length := 184608) (by decide) h) w.parametersFresh.2.2.1)
  suffix := (w.suffix_regions _).mpr (DecodeParameterMemory.suffix_mono checkpoint.suffix
    (fun _ _ h => w.subregion (offset := 43200) (length := 184608) (by decide) h) w.parametersFresh.2.2.2)

theorem Workspace.tailFresh : DeltaTailAllocation.Fresh w.entryWorkspace.strongSource
    (DeltaPreparationAllocation.plan w.entryWorkspace.strongSource w.preparationArena w.preparationFresh)
    (DeltaPreparationAllocation.frames w.entryWorkspace.strongSource w.preparationArena w.preparationFresh) w.tailArena := by
  apply DeltaTailAllocation.fromPreparationArena w.entryWorkspace.strongSource w.preparationArena w.preparationFresh w.tailArena
  · change MemoryRegions.Disjoint (w.base+227808) 3180544 (w.base+43200) 184608
    unfold MemoryRegions.Disjoint; omega
  · exact w.subregion (offset := 227808) (length := 3180544) (by decide) w.stateFresh
  · rw [w.entry_layout.2.2.2]
    change MemoryRegions.Disjoint (w.base+227808) 3180544 (w.base+30720) 12288
    unfold MemoryRegions.Disjoint; omega
  · exact (w.mixer_regions _).mpr (DeltaParameterMemory.protected_mono checkpoint.mixer
      (fun _ _ h => w.subregion (offset := 227808) (length := 3180544) (by decide) h) w.parametersFresh.2.2.1)
  · exact (w.suffix_regions _).mpr (DecodeParameterMemory.suffix_mono checkpoint.suffix
      (fun _ _ h => w.subregion (offset := 227808) (length := 3180544) (by decide) h) w.parametersFresh.2.2.2)
  · rw [w.residual_base]
    exact w.subregion (offset := 227808) (length := 3180544) (by decide) w.sourceFresh

theorem history_base_generic (source : ResidualDeltaStorageConstruction.Source layer cache input)
    (preparation : ResidualDeltaStorageConstruction.PreparationPlan source)
    (frames : ResidualDeltaStorageConstruction.PreparationFrames source preparation) :
    (ResidualDeltaStorageConstruction.historyBefore source preparation frames).base=2*preparation.convolution.tailBase := rfl

theorem Workspace.suffixFresh : ResidualDeltaWorkspaceConstruction.SuffixFresh w.entryWorkspace.strongSource
    (DeltaPreparationAllocation.plan w.entryWorkspace.strongSource w.preparationArena w.preparationFresh)
    (DeltaPreparationAllocation.frames w.entryWorkspace.strongSource w.preparationArena w.preparationFresh) w.tailArena w.suffixArena where
  residual := by rw [w.residual_base]; exact w.subregion (offset := 3408352) (length := 731136) (by decide) w.sourceFresh
  tail := by change MemoryRegions.Disjoint (w.base+3408352) 731136 (w.base+227808) 3180544; unfold MemoryRegions.Disjoint; omega
  suffix := (w.suffix_regions _).mpr (DecodeParameterMemory.suffix_mono checkpoint.suffix
    (fun _ _ h => w.subregion (offset := 3408352) (length := 731136) (by decide) h) w.parametersFresh.2.2.2)
  history := by
    rw [history_base_generic]
    change MemoryRegions.Disjoint (w.base+3408352) 731136 (2*((w.preparationArena.base+81920)/2)) 61440
    rw [w.preparationArena.half (offset := 81920) (by decide)]
    change MemoryRegions.Disjoint (w.base+3408352) 731136 ((w.base+43200)+81920) 61440
    unfold MemoryRegions.Disjoint; omega

def Workspace.workspace : ResidualDeltaWorkspaceConstruction.Workspace origin storage checkpoint where
  entry := w.entryWorkspace
  preparationArena := w.preparationArena
  preparationFresh := w.preparationFresh
  tailArena := w.tailArena
  tailFresh := w.tailFresh
  suffixArena := w.suffixArena
  suffixFresh := w.suffixFresh


def Workspace.deltaPlan := w.workspace.deltaPlan

def Workspace.fromStorage : ResidualDeltaMemory.Execution layer cache input := w.workspace.fromStorage

def Workspace.trace (angle : Kernels.Attention.RopeAngles.Inputs) := w.workspace.trace angle

theorem Workspace.source_linked : w.fromStorage.entry.source.lhs=origin := w.workspace.source_linked

theorem Workspace.cache_linked : w.fromStorage.storage=storage.storage := w.workspace.cache_linked

theorem Workspace.parameters_linked : HEq w.fromStorage.parameters checkpoint.mixer := w.workspace.parameters_linked

theorem Workspace.norm_linked : w.fromStorage.entry.source.rhs=checkpoint.norm := w.workspace.norm_linked

theorem Workspace.projections_linked : HEq w.workspace.entry.entry.data.affineWeights checkpoint.projections := w.workspace.projections_linked

theorem Workspace.suffix_linked : HEq w.workspace.entry.strongSource.suffix checkpoint.suffix := w.workspace.suffix_linked

theorem Workspace.output_eq : w.fromStorage.output=layer.forward cache (fun _ => input) 0 := w.workspace.output_eq

theorem Workspace.cache_eq : w.fromStorage.readCache=layer.cacheAfter cache (fun _ => input) 1 := w.workspace.cache_eq

theorem Workspace.output_base : w.fromStorage.outputBuffer.base=w.base+4129248 := by
  have base := w.workspace.output_base
  change w.fromStorage.outputBuffer.base=(w.base+3408352)+720896 at base
  exact base.trans (by omega)

theorem Workspace.unionSafe {base size : Nat} (safe : MemoryRegions.Disjoint w.base bytes base size) : w.workspace.Safe base size :=
  ⟨w.subregion (offset := 0) (length := 43200) (by decide) safe,
    w.subregion (offset := 43200) (length := 184608) (by decide) safe,
    w.subregion (offset := 227808) (length := 3180544) (by decide) safe,
    w.subregion (offset := 3408352) (length := 731136) (by decide) safe⟩

theorem Workspace.safe {base size : Nat} (safe : MemoryRegions.Disjoint w.base bytes base size) :
    ResidualDeltaMemory.Safe w.fromStorage base size := w.workspace.safe (w.unionSafe safe)

theorem Workspace.stage_safe (angle : Kernels.Attention.RopeAngles.Inputs) {base size : Nat}
    (safe : MemoryRegions.Disjoint w.base bytes base size) :
    (DecodeParameterConstruction.stage (.delta layer) cache input angle origin storage checkpoint w.deltaPlan).Safe base size :=
  w.safe safe

theorem Workspace.other_region {base size : Nat} (safe : MemoryRegions.Disjoint w.base bytes base size)
    (offset : Nat) (bound : offset<size) : w.fromStorage.outputBuffer.bytes (base+offset)=origin.bytes (base+offset) :=
  w.workspace.other_region (w.unionSafe safe) offset bound

def Workspace.parametersAfter : DecodeParameterMemory.DeltaStorage layer w.fromStorage.outputBuffer.bytes :=
  w.workspace.parametersAfter (checkpoint.protected_mono (fun _ _ h => w.unionSafe h) w.parametersFresh)

theorem Workspace.parametersAfter_regions (property : Nat → Nat → Prop) :
    w.parametersAfter.Protected property ↔ checkpoint.Protected property :=
  w.workspace.parametersAfter_regions _ property

def Workspace.retainedCaches {count : Nat} (stages : List DecodeStage.Stage) (caches : DecodeChain.Caches stages count)
    (stored : DecodeFrame.Storage stages caches origin.bytes)
    (safe : DecodePreservation.Protected (MemoryRegions.Disjoint w.base bytes) stages caches origin.bytes stored) :
    DecodeFrame.Storage stages caches w.fromStorage.outputBuffer.bytes :=
  DecodePreservation.reframe (MemoryRegions.Disjoint w.base bytes) origin.bytes w.fromStorage.outputBuffer.bytes
    (fun _ _ region => w.other_region region) stages caches stored safe

theorem footprint : bytes=43200+184608+3180544+731136 := by decide

end Inference.Models.Qwen.ResidualDeltaAllocation
