import models.qwen.DeltaTailAllocation
import models.qwen.ResidualMlpAllocation

namespace Inference.Models.Qwen.ResidualDeltaWorkspaceConstruction
open Contracts.Mlx Layers Kernels Kernels.Delta
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000
attribute [local irreducible] ResidualDeltaConstruction.preparation ResidualDeltaStorageConstruction.preparation

structure SuffixArena where
  base : Nat
  aligned : base%16=0
  bounded : base+731136≤2^64

variable {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → ArrayStorage.BF}
  (source : ResidualDeltaStorageConstruction.Source layer cache input)
  (preparation : ResidualDeltaStorageConstruction.PreparationPlan source)
  (frames : ResidualDeltaStorageConstruction.PreparationFrames source preparation)
  (tailArena : DeltaTailAllocation.Arena) (tailFresh : DeltaTailAllocation.Fresh source preparation frames tailArena)

def recurrent := DeltaTailAllocation.recurrencePlan source preparation frames tailArena tailFresh

def tail := DeltaTailAllocation.tailPlan source preparation frames tailArena tailFresh

def parameters := ResidualDeltaStorageConstruction.suffixParameters source preparation frames
  (recurrent source preparation frames tailArena tailFresh) (tail source preparation frames tailArena tailFresh)

def suffixInput := DeltaResidualMemory.residualInput (DeltaTailAllocation.execution source preparation frames tailArena tailFresh)
  (ResidualDeltaStorageConstruction.residualBefore source preparation frames)
  (ResidualDeltaStorageConstruction.suffixSourceShared source preparation frames (recurrent source preparation frames tailArena tailFresh))
  (tail source preparation frames tailArena tailFresh).residualSafe

theorem suffix_regions_generic (recurrence : ResidualDeltaStorageConstruction.RecurrencePlan source preparation frames)
    (t : ResidualDeltaStorageConstruction.TailPlan source preparation frames recurrence) (property : Nat → Nat → Prop) :
    let p := ResidualDeltaStorageConstruction.suffixParameters source preparation frames recurrence t
    property p.normAfter.base 10240 ∧ p.trellisAfter.Protected property ↔ source.suffix.Protected property := Iff.rfl

structure SuffixFresh (source : ResidualDeltaStorageConstruction.Source layer cache input)
    (preparation : ResidualDeltaStorageConstruction.PreparationPlan source)
    (frames : ResidualDeltaStorageConstruction.PreparationFrames source preparation)
    (tailArena : DeltaTailAllocation.Arena) (arena : SuffixArena) : Prop where
  residual : MemoryRegions.Disjoint arena.base 731136 source.entry.savedResidual.base 10240
  tail : MemoryRegions.Disjoint arena.base 731136 tailArena.base 3180544
  suffix : source.suffix.Protected (MemoryRegions.Disjoint arena.base 731136)
  history : MemoryRegions.Disjoint arena.base 731136 (ResidualDeltaStorageConstruction.historyBefore source preparation frames).base 61440

variable (arena : SuffixArena) (fresh : SuffixFresh source preparation frames tailArena arena)

theorem outputBuffer_base_generic {steps groups : Nat} {projection : AffineVerifyLinear.Projection steps (4*groups)}
    {values : Fin (steps*512) → ArrayStorage.BF} (e : AffineMemory.Execution projection values) :
    e.outputBuffer.base=e.base := by cases projection <;> rfl

include tailFresh fresh in
theorem right_safe : MemoryRegions.Disjoint arena.base 731136
    (suffixInput source preparation frames tailArena tailFresh).rhs.base 10240 := by
  change MemoryRegions.Disjoint arena.base 731136
    (DeltaTailAllocation.execution source preparation frames tailArena tailFresh).affine.outputBuffer.base 10240
  rw [outputBuffer_base_generic (DeltaTailAllocation.execution source preparation frames tailArena tailFresh).affine,
    (DeltaTailAllocation.bases source preparation frames tailArena tailFresh).2]
  exact MemoryRegions.disjoint_symm (tailArena.separate (offset := 3170304) (length := 10240) (by decide) (MemoryRegions.disjoint_symm fresh.tail))

def suffixWorkspace : ResidualMlpAllocation.Workspace (suffixInput source preparation frames tailArena tailFresh)
    (parameters source preparation frames tailArena tailFresh).normAfter
    (parameters source preparation frames tailArena tailFresh).trellisAfter where
  base := arena.base
  aligned := arena.aligned
  bounded := arena.bounded
  leftSafe := fresh.residual
  rightSafe := right_safe source preparation frames tailArena tailFresh arena fresh
  normSafe := ((suffix_regions_generic source preparation frames
    (recurrent source preparation frames tailArena tailFresh) (tail source preparation frames tailArena tailFresh) _).mpr fresh.suffix).1
  parametersSafe := ((suffix_regions_generic source preparation frames
    (recurrent source preparation frames tailArena tailFresh) (tail source preparation frames tailArena tailFresh) _).mpr fresh.suffix).2

def suffixPlan : ResidualDeltaStorageConstruction.SuffixPlan source preparation frames
    (recurrent source preparation frames tailArena tailFresh) (tail source preparation frames tailArena tailFresh) where
  allocation := (suffixWorkspace source preparation frames tailArena tailFresh arena fresh).allocation rfl
  historySafe := (suffixWorkspace source preparation frames tailArena tailFresh arena fresh).six_regions fresh.history
  stateSafe := (suffixWorkspace source preparation frames tailArena tailFresh arena fresh).six_regions
    (MemoryRegions.disjoint_symm (tailArena.recurrenceSeparate (MemoryRegions.disjoint_symm fresh.tail)).1)

def plan : ResidualDeltaStorageConstruction.Plan source :=
  ⟨preparation,frames,recurrent source preparation frames tailArena tailFresh,tail source preparation frames tailArena tailFresh,
    suffixPlan source preparation frames tailArena tailFresh arena fresh⟩

def execution := ResidualDeltaStorageConstruction.fromStorage source
  (plan source preparation frames tailArena tailFresh arena fresh)


theorem suffixWorkspace_base : (suffixWorkspace source preparation frames tailArena tailFresh arena fresh).base=arena.base := rfl

theorem suffixWorkspace_safe {base size : Nat} (safe : MemoryRegions.Disjoint arena.base 731136 base size) :
    MemoryRegions.Disjoint (suffixWorkspace source preparation frames tailArena tailFresh arena fresh).base ResidualMlpAllocation.bytes base size := safe

attribute [local irreducible] suffixWorkspace

theorem output_base : (execution source preparation frames tailArena tailFresh arena fresh).outputBuffer.base=arena.base+720896 :=
  ((suffixWorkspace source preparation frames tailArena tailFresh arena fresh).output_base rfl).trans
    (congrArg (fun base => base+720896) (suffixWorkspace_base source preparation frames tailArena tailFresh arena fresh))

theorem execution_safe {base size : Nat}
    (entrySafe : DeltaNormalizedMemory.Safe source.entry base size)
    (preparationSafe : DeltaConvolutionMemory.Safe (ResidualDeltaStorageConstruction.preparation source preparation) base size)
    (tailSafe : MemoryRegions.Disjoint tailArena.base 3180544 base size)
    (suffixSafe : MemoryRegions.Disjoint arena.base 731136 base size) :
    ResidualDeltaMemory.Safe (execution source preparation frames tailArena tailFresh arena fresh) base size :=
  ⟨entrySafe,preparationSafe,DeltaTailAllocation.safe source preparation frames tailArena tailFresh tailSafe,
    (suffixWorkspace source preparation frames tailArena tailFresh arena fresh).protect rfl
      (suffixWorkspace_safe source preparation frames tailArena tailFresh arena fresh suffixSafe)⟩


section Raw
variable (origin : ArrayStorage.BFBuffer input)
  (storage : DecodeFrame.StageBuffer (n := n) (.delta layer) cache origin.bytes)
  (checkpoint : DecodeParameterMemory.DeltaStorage layer origin.bytes)

structure EntryWorkspace where
  arena : DeltaEntryAllocation.Arena
  sourceFresh : MemoryRegions.Disjoint arena.base 43200 origin.base 10240
  parametersFresh : checkpoint.Protected (MemoryRegions.Disjoint arena.base 43200)
  historyFresh : MemoryRegions.Disjoint arena.base 43200 storage.storage.buffers.history.base 61440
  stateFresh : MemoryRegions.Disjoint arena.base 43200 storage.storage.buffers.recurrent.base 3145728

variable {origin storage checkpoint}

def EntryWorkspace.entry (w : EntryWorkspace origin storage checkpoint) :=
  DeltaEntryAllocation.fromStorage origin checkpoint w.arena w.sourceFresh w.parametersFresh

theorem EntryWorkspace.entryFrames (w : EntryWorkspace origin storage checkpoint) : DecodeParameterConstruction.DeltaFrames w.entry storage :=
  DeltaEntryAllocation.frames origin checkpoint w.arena w.sourceFresh w.parametersFresh storage w.historyFresh w.stateFresh

def EntryWorkspace.strongSource (w : EntryWorkspace origin storage checkpoint) :=
  DecodeParameterConstruction.deltaSource w.entry storage w.entryFrames


structure Workspace (origin : ArrayStorage.BFBuffer input)
    (storage : DecodeFrame.StageBuffer (n := n) (.delta layer) cache origin.bytes)
    (checkpoint : DecodeParameterMemory.DeltaStorage layer origin.bytes) where
  entry : EntryWorkspace origin storage checkpoint
  preparationArena : DeltaPreparationAllocation.Arena
  preparationFresh : DeltaPreparationAllocation.Fresh entry.strongSource preparationArena
  tailArena : DeltaTailAllocation.Arena
  tailFresh : DeltaTailAllocation.Fresh entry.strongSource
    (DeltaPreparationAllocation.plan entry.strongSource preparationArena preparationFresh)
    (DeltaPreparationAllocation.frames entry.strongSource preparationArena preparationFresh) tailArena
  suffixArena : SuffixArena
  suffixFresh : SuffixFresh entry.strongSource
    (DeltaPreparationAllocation.plan entry.strongSource preparationArena preparationFresh)
    (DeltaPreparationAllocation.frames entry.strongSource preparationArena preparationFresh) tailArena suffixArena

variable (w : Workspace origin storage checkpoint)

def Workspace.plan : ResidualDeltaStorageConstruction.Plan w.entry.strongSource :=
  ResidualDeltaWorkspaceConstruction.plan w.entry.strongSource (DeltaPreparationAllocation.plan w.entry.strongSource w.preparationArena w.preparationFresh)
    (DeltaPreparationAllocation.frames w.entry.strongSource w.preparationArena w.preparationFresh)
    w.tailArena w.tailFresh w.suffixArena w.suffixFresh

def Workspace.fromStorage : ResidualDeltaMemory.Execution layer cache input :=
  ResidualDeltaStorageConstruction.fromStorage w.entry.strongSource w.plan


theorem Workspace.source_linked : w.fromStorage.entry.source.lhs=origin :=
  (ResidualDeltaStorageConstruction.source_linked w.entry.strongSource w.plan).trans w.entry.entry.sourceLinked

theorem Workspace.cache_linked : w.fromStorage.storage=storage.storage :=
  ResidualDeltaStorageConstruction.cache_linked w.entry.strongSource w.plan

theorem Workspace.parameters_linked : HEq w.fromStorage.parameters checkpoint.mixer :=
  HEq.trans (heq_of_eq (ResidualDeltaStorageConstruction.parameters_linked w.entry.strongSource w.plan)) w.entry.entry.mixer_lineage

theorem Workspace.norm_linked : w.fromStorage.entry.source.rhs=checkpoint.norm :=
  w.entry.entry.normLinked

theorem Workspace.projections_linked : HEq w.entry.entry.data.affineWeights checkpoint.projections :=
  w.entry.entry.projectionsLinked

theorem Workspace.suffix_linked : HEq w.entry.strongSource.suffix checkpoint.suffix := w.entry.entry.suffix_lineage

theorem Workspace.output_base : w.fromStorage.outputBuffer.base=w.suffixArena.base+720896 :=
  ResidualDeltaWorkspaceConstruction.output_base w.entry.strongSource
    (DeltaPreparationAllocation.plan w.entry.strongSource w.preparationArena w.preparationFresh)
    (DeltaPreparationAllocation.frames w.entry.strongSource w.preparationArena w.preparationFresh)
    w.tailArena w.tailFresh w.suffixArena w.suffixFresh

theorem Workspace.output_eq : w.fromStorage.output=layer.forward cache (fun _ => input) 0 :=
  w.fromStorage.output_eq

theorem Workspace.cache_eq : w.fromStorage.readCache=layer.cacheAfter cache (fun _ => input) 1 :=
  w.fromStorage.read_cache_eq

-- A region outside the union of all four arenas survives the complete layer.
def Workspace.Safe (base size : Nat) : Prop :=
  MemoryRegions.Disjoint w.entry.arena.base 43200 base size ∧
  MemoryRegions.Disjoint w.preparationArena.base 184608 base size ∧
  MemoryRegions.Disjoint w.tailArena.base 3180544 base size ∧
  MemoryRegions.Disjoint w.suffixArena.base 731136 base size


theorem Workspace.safe {base size : Nat} (safe : w.Safe base size) : ResidualDeltaMemory.Safe w.fromStorage base size :=
  execution_safe w.entry.strongSource (DeltaPreparationAllocation.plan w.entry.strongSource w.preparationArena w.preparationFresh)
    (DeltaPreparationAllocation.frames w.entry.strongSource w.preparationArena w.preparationFresh)
    w.tailArena w.tailFresh w.suffixArena w.suffixFresh
    (DeltaEntryAllocation.safe origin checkpoint w.entry.arena w.entry.sourceFresh w.entry.parametersFresh safe.1)
    (DeltaPreparationAllocation.safe w.entry.strongSource w.preparationArena w.preparationFresh safe.2.1) safe.2.2.1 safe.2.2.2

theorem Workspace.other_region {base size : Nat} (safe : w.Safe base size) (offset : Nat) (bound : offset<size) :
    w.fromStorage.outputBuffer.bytes (base+offset)=origin.bytes (base+offset) :=
  (w.fromStorage.other_region (w.safe safe) offset bound).trans (congrFun (congrArg (fun buffer => buffer.bytes) w.source_linked) _)


def Workspace.deltaPlan : DecodeParameterConstruction.DeltaPlan layer cache input origin storage checkpoint :=
  ⟨w.entry.entry,w.entry.entryFrames,w.plan⟩

def Workspace.trace (angle : Kernels.Attention.RopeAngles.Inputs) :
    DecodeMemoryStage.Trace (.delta layer) cache input angle origin storage :=
  ⟨w.fromStorage,w.source_linked,w.cache_linked⟩

def Workspace.parametersAfter (safe : checkpoint.Protected w.Safe) :
    DecodeParameterMemory.DeltaStorage layer w.fromStorage.outputBuffer.bytes :=
  checkpoint.reframe _ (checkpoint.protected_mono (fun _ _ region => w.other_region region) safe)

theorem Workspace.parametersAfter_regions (safe : checkpoint.Protected w.Safe) (property : Nat → Nat → Prop) :
    (w.parametersAfter safe).Protected property ↔ checkpoint.Protected property :=
  checkpoint.reframe_protected _ _ property

def Workspace.retainedCaches {count : Nat} (stages : List DecodeStage.Stage) (caches : DecodeChain.Caches stages count)
    (stored : DecodeFrame.Storage stages caches origin.bytes)
    (safe : DecodePreservation.Protected w.Safe stages caches origin.bytes stored) :
    DecodeFrame.Storage stages caches w.fromStorage.outputBuffer.bytes :=
  DecodePreservation.reframe w.Safe origin.bytes w.fromStorage.outputBuffer.bytes
    (fun _ _ region => w.other_region region) stages caches stored safe

end Raw

end Inference.Models.Qwen.ResidualDeltaWorkspaceConstruction
