import models.qwen.AttentionEntryAllocation

namespace Inference.Models.Qwen.AttentionPrefixAllocation
open Contracts.Mlx Layers Kernels Kernels.Attention State
open ResidualAttentionConstruction
set_option maxRecDepth 10000
attribute [local irreducible] AttentionHeads.Projections.forward Blocks.Norm.forward AttentionHeads.Norm.forward
  RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor
  ResidualAttentionMemory.copiedParameters AttentionNormalizationMemory.queryInput AttentionNormalizationDispatchMemory.keyInput
  Copy2DMemory.programs CopyExecution.Trace.memory RopeRowsMemory.programs MultiOutputWrites.programs
  ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

theorem contained_disjoint {base first firstSize other size : Nat}
    (lower : base≤first) (upper : first+firstSize≤base+79872)
    (separate : MemoryRegions.Disjoint base 79872 other size) : MemoryRegions.Disjoint first firstSize other size := by
  unfold MemoryRegions.Disjoint at *
  omega

theorem query_scale_base {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    {entry : AttentionNormalizedMemory.Execution layer input} (c : CopyPlan entry) :
    c.parametersAfter.queryScale.base=c.parameters.queryScale.base := by
  unfold CopyPlan.parametersAfter ResidualAttentionMemory.copiedParameters AttentionProjectionHandoff.parametersAfterCopy
    AttentionNormalizedMemory.Execution.parametersAfter AttentionParameterMemory.reframe ArrayFrame.bf
  rfl

theorem key_scale_base {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    {entry : AttentionNormalizedMemory.Execution layer input} (c : CopyPlan entry) :
    c.parametersAfter.keyScale.base=c.parameters.keyScale.base := by
  unfold CopyPlan.parametersAfter ResidualAttentionMemory.copiedParameters AttentionProjectionHandoff.parametersAfterCopy
    AttentionNormalizedMemory.Execution.parametersAfter AttentionParameterMemory.reframe ArrayFrame.bf
  rfl

theorem key_input_scale_base {attention : Attention.Layer} {x : Fin 5120 → ArrayStorage.BF}
    {phase : AttentionAffineMemory.Execution attention.projections x}
    (copy : AttentionQueryMemory.Execution phase)
    (parameters : AttentionParameterMemory.Storage attention copy.copy.memory)
    (query : AttentionNormalizationDispatchMemory.QueryExecution copy parameters)
    (copyKey : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.keyBuffer.base 2048)
    (keySafe : MemoryRegions.Disjoint query.base 12288 phase.keyBuffer.base 2048)
    (scaleSafe : MemoryRegions.Disjoint query.base 12288 parameters.keyScale.base 512) :
    (AttentionNormalizationDispatchMemory.keyInput copy parameters query copyKey keySafe scaleSafe).weight.base=parameters.keyScale.base := by
  unfold AttentionNormalizationDispatchMemory.keyInput
  rfl

-- All subsequent RMS and RoPE outputs use fresh, disjoint allocations.
-- Native ownership and refcount selection are not inferred by this plan.
structure Arena {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
    {input : Fin 5120 → ArrayStorage.BF} (s : ResidualAttentionStorageConstruction.Source layer cache input) where
  base : Nat
  aligned : base%4=0
  bounded : base+79872≤2^64
  sourceSeparate : MemoryRegions.Disjoint base 79872 s.source.base 10240
  parametersSeparate : s.parameters.Protected (MemoryRegions.Disjoint base 79872)
  queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2
  keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {input : Fin 5120 → ArrayStorage.BF} {s : ResidualAttentionStorageConstruction.Source layer cache input}

def Arena.entryWorkspace (a : Arena s) : AttentionEntryAllocation.Workspace s.source s.parameters where
  base := a.base
  aligned := a.aligned
  bounded := by have := a.bounded; omega
  sourceSeparate := contained_disjoint (by omega) (by omega) a.sourceSeparate
  parametersSeparate := s.parameters.protected_mono
    (fun _ _ h => contained_disjoint (by omega) (by omega) h) a.parametersSeparate

def Arena.entryPlan (a : Arena s) := AttentionEntryAllocation.Workspace.strongPlan s a.entryWorkspace

theorem Arena.entry_eq (a : Arena s) : a.entryPlan.entry=a.entryWorkspace.entry :=
  AttentionEntryAllocation.Workspace.strong_entry_eq s a.entryWorkspace

theorem Arena.entry_workspace_base (a : Arena s) : a.entryWorkspace.base=a.base := rfl

theorem Arena.entry_safe (a : Arena s) {base size : Nat}
    (separate : MemoryRegions.Disjoint a.base 79872 base size) : AttentionNormalizedMemory.Safe a.entryPlan.entry base size := by
  rw [a.entry_eq]
  apply a.entryWorkspace.safe
  change MemoryRegions.Disjoint a.base 38912 base size
  exact contained_disjoint (by omega) (by omega) separate

theorem Arena.parameter_regions (a : Arena s) (property : Nat → Nat → Prop) :
    AttentionParameterMemory.Protected a.entryPlan.parameters.mixer property ↔ AttentionParameterMemory.Protected s.parameters.mixer property := Iff.rfl

theorem Arena.parameter_bases (a : Arena s) :
    a.entryPlan.parameters.mixer.queryScale.base=s.parameters.mixer.queryScale.base ∧
    a.entryPlan.parameters.mixer.keyScale.base=s.parameters.mixer.keyScale.base := ⟨rfl,rfl⟩

attribute [local irreducible] Arena.entryPlan

def Arena.copyAllocation (a : Arena s) : ResidualAttentionStorageConstruction.CopyAllocation a.entryPlan where
  destination := (a.base+38912)/2
  bounded := by have := a.aligned; have := a.bounded; omega
  separate := by
    rw [a.entry_eq,a.entryWorkspace.buffer_bases.1,a.entry_workspace_base]
    exact Or.inr (by have := a.aligned; change a.base+10240+24576≤2*((a.base+38912)/2); omega)
  entrySafe := (a.parameter_regions _).mpr (AttentionParameterMemory.protected_mono _ (fun _ _ h => a.entry_safe h) a.parametersSeparate.2.2.1)
  copySafe := by
    apply (AttentionParameterMemory.reframe_protected _ _ _ _).mpr
    exact (a.parameter_regions _).mpr (AttentionParameterMemory.protected_mono _
      (fun _ _ h => contained_disjoint (by have := a.aligned; omega) (by have := a.aligned; omega) h) a.parametersSeparate.2.2.1)

theorem Arena.copy_destination (a : Arena s) : 2*a.copyAllocation.plan.copy.destination=a.base+38912 := by
  change 2*((a.base+38912)/2)=a.base+38912
  have := a.aligned
  omega

theorem Arena.copy_parameters_bases (a : Arena s) :
    a.copyAllocation.plan.parametersAfter.queryScale.base=s.parameters.mixer.queryScale.base ∧
    a.copyAllocation.plan.parametersAfter.keyScale.base=s.parameters.mixer.keyScale.base := by
  rw [query_scale_base,key_scale_base]
  change a.entryPlan.parameters.mixer.queryScale.base=_ ∧ a.entryPlan.parameters.mixer.keyScale.base=_
  exact a.parameter_bases

theorem Arena.copy_plan_destination (a : Arena s) : 2*a.copyAllocation.plan.destination=a.base+38912 := by
  change 2*((a.base+38912)/2)=a.base+38912
  have := a.aligned
  omega

attribute [local irreducible] Arena.copyAllocation

def Arena.queryPlan (a : Arena s) : RmsQueryPlan a.copyAllocation.plan where
  dispatch := a.queryDispatch
  keyDispatch := a.keyDispatch
  allocation := .fresh (a.base+51200) ⟨by have := a.aligned; omega,by have := a.bounded; omega⟩
    (by rw [a.copy_destination]; exact Or.inr (by omega))
    (by simp only [AttentionNormalizationDispatchMemory.queryInput,AttentionNormalizationMemory.queryInput]
        change MemoryRegions.Disjoint (a.base+51200) 12288 a.copyAllocation.plan.parametersAfter.queryScale.base 512
        rw [a.copy_parameters_bases.1]
        exact contained_disjoint (by omega) (by omega) a.parametersSeparate.2.2.1.1)

theorem Arena.query_base (a : Arena s) : a.queryPlan.execution.base=a.base+51200 := rfl

attribute [local irreducible] Arena.queryPlan

theorem Arena.copy_key_safe (a : Arena s) :
    MemoryRegions.Disjoint (2*a.copyAllocation.plan.destination) 12288 a.entryPlan.entry.affine.keyBuffer.base 2048 := by
  rw [a.copy_plan_destination,a.entry_eq,a.entryWorkspace.buffer_bases.2.1,a.entry_workspace_base]
  exact Or.inr (by omega)

theorem Arena.query_key_safe (a : Arena s) :
    MemoryRegions.Disjoint a.queryPlan.execution.base 12288 a.entryPlan.entry.affine.keyBuffer.base 2048 := by
  rw [a.query_base,a.entry_eq,a.entryWorkspace.buffer_bases.2.1,a.entry_workspace_base]
  exact Or.inr (by omega)

theorem Arena.query_scale_safe (a : Arena s) :
    MemoryRegions.Disjoint a.queryPlan.execution.base 12288 a.copyAllocation.plan.parametersAfter.keyScale.base 512 := by
  rw [a.query_base,a.copy_parameters_bases.2]
  exact contained_disjoint (by omega) (by omega) a.parametersSeparate.2.2.1.2.1

def Arena.keyPlan (a : Arena s) : RmsKeyPlan a.queryPlan where
  copyKey := a.copy_key_safe
  keySafe := a.query_key_safe
  scaleSafe := a.query_scale_safe
  allocation := .fresh (a.base+63488) ⟨by have := a.aligned; omega,by have := a.bounded; omega⟩
    (by rw [a.entry_eq,a.entryWorkspace.buffer_bases.2.1,a.entry_workspace_base]; exact Or.inr (by omega))
    (by
        have equal := key_input_scale_base a.copyAllocation.plan.copy a.copyAllocation.plan.parametersAfter
          a.queryPlan.execution a.copy_key_safe a.query_key_safe a.query_scale_safe
        have safe : MemoryRegions.Disjoint (a.base+63488) 2048 a.copyAllocation.plan.parametersAfter.keyScale.base 512 := by
          rw [a.copy_parameters_bases.2]
          exact contained_disjoint (by omega) (by omega) a.parametersSeparate.2.2.1.2.1
        exact Eq.mpr (congrArg (fun b => MemoryRegions.Disjoint (a.base+63488) 2048 b 512) equal) safe
      )
  outputSafe := by
    have safe : MemoryRegions.Disjoint (a.base+63488) 2048 a.queryPlan.execution.base 12288 := by
      rw [a.query_base]; exact Or.inr (by omega)
    exact safe

theorem Arena.key_allocation_base (a : Arena s) : a.keyPlan.allocation.base=a.base+63488 := rfl

attribute [local irreducible] Arena.keyPlan

def Arena.rmsPlan (a : Arena s) : RmsPlan a.copyAllocation.plan := ⟨a.queryPlan,a.keyPlan⟩

theorem Arena.normal_bases (a : Arena s) : a.rmsPlan.normal.queryBase=a.base+51200 ∧ a.rmsPlan.normal.keyBase=a.base+63488 := by
  refine ⟨a.query_base,?_⟩
  change (RmsHeadsDispatchMemory.canonical _ _ _ _ a.queryPlan.keyDispatch a.keyPlan.allocation).base=_
  rw [RmsHeadsDispatchMemory.canonical_base,a.key_allocation_base]

attribute [local irreducible] Arena.rmsPlan

def Arena.queryCopy (a : Arena s) : RopeRowsCopyMemory.Copy (AttentionRopeNormalizedMemory.queryInput a.rmsPlan.normal) :=
  RopeRowsCopyMemory.Copy.canonical _ (a.base+65536) (by have := a.aligned; omega) (by have := a.bounded; omega)
    (by change MemoryRegions.Disjoint a.rmsPlan.normal.queryBase 12288 (a.base+65536) 12288
        rw [a.normal_bases.1]; exact Or.inl (by omega))

def Arena.ropePlan (a : Arena s) (angle : RopeAngles.Inputs) : RopePlan a.rmsPlan angle where
  queryPreparation := .copy a.queryCopy
  keySafe := by
    change MemoryRegions.Disjoint (a.base+65536) 12288 a.rmsPlan.normal.keyBase 2048
    rw [a.normal_bases.2]
    exact Or.inr (by omega)
  keyPreparation := .copy (RopeRowsCopyMemory.Copy.canonical _ (a.base+77824)
    (by have := a.aligned; omega) (by have := a.bounded; omega)
    (by change MemoryRegions.Disjoint a.rmsPlan.normal.keyBase 2048 (a.base+77824) 2048
        rw [a.normal_bases.2]; exact Or.inl (by omega)))
  outputSafe := Or.inr (by change a.base+65536+12288≤a.base+77824; omega)

theorem Arena.rope_bases (a : Arena s) (angle : RopeAngles.Inputs) :
    (a.ropePlan angle).rope.query.destination=a.base+65536 ∧
    (a.ropePlan angle).rope.key.destination=a.base+77824 := ⟨rfl,rfl⟩

theorem Arena.gate_base (a : Arena s) (head : Fin 24) :
    (a.copyAllocation.plan.copy.gate head).base=a.base+10240+2*(head.val*512+256) := by
  change a.entryPlan.entry.affine.queryGateBuffer.base+2*(head.val*512+256)=_
  rw [a.entry_eq,a.entryWorkspace.buffer_bases.1,a.entry_workspace_base]

theorem Arena.gate_normal (a : Arena s) (head : Fin 24) :
    AttentionNormalizationDispatchMemory.Safe a.rmsPlan.normal (a.copyAllocation.plan.copy.gate head).base 512 := by
  unfold AttentionNormalizationDispatchMemory.Safe
  rw [a.normal_bases.1,a.normal_bases.2,a.gate_base]
  have := head.isLt
  exact ⟨Or.inr (by omega),Or.inr (by omega)⟩

def Arena.prefixAllocation (a : Arena s) (angle : RopeAngles.Inputs) :
    ResidualAttentionStorageConstruction.PrefixAllocation a.copyAllocation angle where
  rms := a.rmsPlan
  rotation := a.ropePlan angle
  gateNormal := a.gate_normal
  gateRope := by
    intro head
    change MemoryRegions.Disjoint (a.ropePlan angle).rope.query.destination 12288 (a.copyAllocation.plan.copy.gate head).base 512 ∧
      MemoryRegions.Disjoint (a.ropePlan angle).rope.key.destination 2048 (a.copyAllocation.plan.copy.gate head).base 512
    rw [(a.rope_bases angle).1,(a.rope_bases angle).2,a.gate_base]
    have := head.isLt
    exact ⟨Or.inr (by omega),Or.inr (by omega)⟩
  valueCopy := by
    change MemoryRegions.Disjoint (2*a.copyAllocation.plan.destination) 12288 a.entryPlan.entry.affine.valueBuffer.base 2048
    rw [a.copy_plan_destination,a.entry_eq,a.entryWorkspace.buffer_bases.2.2,a.entry_workspace_base]; exact Or.inr (by omega)
  valueNormal := by
    unfold AttentionNormalizationDispatchMemory.Safe
    rw [a.normal_bases.1,a.normal_bases.2,a.entry_eq,a.entryWorkspace.buffer_bases.2.2,a.entry_workspace_base]
    exact ⟨Or.inr (by omega),Or.inr (by omega)⟩
  valueRope := by
    change MemoryRegions.Disjoint (a.ropePlan angle).rope.query.destination 12288 a.entryPlan.entry.affine.valueBuffer.base 2048 ∧
      MemoryRegions.Disjoint (a.ropePlan angle).rope.key.destination 2048 a.entryPlan.entry.affine.valueBuffer.base 2048
    rw [(a.rope_bases angle).1,(a.rope_bases angle).2,a.entry_eq,a.entryWorkspace.buffer_bases.2.2,a.entry_workspace_base]
    exact ⟨Or.inr (by omega),Or.inr (by omega)⟩

def Arena.front (a : Arena s) (angle : RopeAngles.Inputs) := (a.prefixAllocation angle).front

theorem Arena.safe (a : Arena s) (angle : RopeAngles.Inputs) {base size : Nat}
    (separate : MemoryRegions.Disjoint a.base 79872 base size) : (a.front angle).Safe base size := by
  change AttentionNormalizedMemory.Safe a.entryPlan.entry base size ∧
    MemoryRegions.Disjoint (2*a.copyAllocation.plan.copy.destination) 12288 base size ∧
    AttentionNormalizationDispatchMemory.Safe a.rmsPlan.normal base size ∧ AttentionRopeNormalizedMemory.Safe (a.ropePlan angle).rope base size
  refine ⟨a.entry_safe separate,?_,⟨?_,?_⟩,⟨?_,?_⟩⟩
  · rw [a.copy_destination]; exact contained_disjoint (by omega) (by omega) separate
  · rw [a.normal_bases.1]; exact contained_disjoint (by omega) (by omega) separate
  · rw [a.normal_bases.2]; exact contained_disjoint (by omega) (by omega) separate
  · rw [(a.rope_bases angle).1]; exact contained_disjoint (by omega) (by omega) separate
  · rw [(a.rope_bases angle).2]; exact contained_disjoint (by omega) (by omega) separate

theorem Arena.other_region (a : Arena s) (angle : RopeAngles.Inputs) {base size : Nat}
    (separate : MemoryRegions.Disjoint a.base 79872 base size) (offset : Nat) (bound : offset<size) :
    (a.front angle).memory (base+offset)=s.source.bytes (base+offset) :=
  (a.front angle).other_region (a.safe angle separate) offset bound

theorem Arena.physical_bases (a : Arena s) (angle : RopeAngles.Inputs) :
    (∀ head, ((a.front angle).query head).base=a.base+65536+512*head.val) ∧
    (∀ head, ((a.front angle).key head).base=a.base+77824+512*head.val) ∧
    (∀ head, ((a.front angle).gate head).base=a.base+10240+2*(head.val*512+256)) ∧
    (a.front angle).valueBuffer.base=a.base+36864 := by
  refine ⟨?_,?_,?_,?_⟩
  · intro head
    change (a.ropePlan angle).rope.query.destination+512*head.val=_
    rw [(a.rope_bases angle).1]
  · intro head
    change (a.ropePlan angle).rope.key.destination+512*head.val=_
    rw [(a.rope_bases angle).2]
  · exact a.gate_base
  · change a.entryPlan.entry.affine.valueBuffer.base=_
    rw [a.entry_eq,a.entryWorkspace.buffer_bases.2.2,a.entry_workspace_base]

def Arena.parametersAfter (a : Arena s) (angle : RopeAngles.Inputs) :
    DecodeParameterMemory.AttentionStorage layer (a.front angle).memory :=
  s.parameters.reframe _ (s.parameters.protected_mono (fun _ _ region => a.other_region angle region) a.parametersSeparate)

theorem Arena.cacheAllocation (a : Arena s) (angle : RopeAngles.Inputs)
    (keys : MemoryRegions.Disjoint a.base 79872 s.storage.layout.keyBase (KvRegions.bytes n))
    (values : MemoryRegions.Disjoint a.base 79872 s.storage.layout.valueBase (KvRegions.bytes n)) :
    ResidualAttentionStorageConstruction.CacheAllocation (a.prefixAllocation angle) :=
  ⟨a.safe angle keys,a.safe angle values,a.safe angle a.sourceSeparate⟩

theorem Arena.read_eq (a : Arena s) (angle : RopeAngles.Inputs) :
    (a.front angle).read=layer.mixer.heads (layer.inputNorm.forward input) angle := (a.front angle).read_eq

end Inference.Models.Qwen.AttentionPrefixAllocation
