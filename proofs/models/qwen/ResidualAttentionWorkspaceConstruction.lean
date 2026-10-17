import models.qwen.AttentionPrefixReadAllocation
import models.qwen.AttentionTailWorkspaceConstruction
import models.qwen.DecodeParameterConstruction

namespace Inference.Models.Qwen.ResidualAttentionWorkspaceConstruction
open Contracts.Mlx Layers Kernels Kernels.Attention State
open ResidualAttentionConstruction
set_option maxRecDepth 10000
attribute [local irreducible] AttentionHeads.Projections.forward Blocks.Norm.forward AttentionHeads.Norm.forward
  RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor
  Copy2DMemory.programs CopyExecution.Trace.memory RopeRowsMemory.programs MultiOutputWrites.programs
  ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

theorem affine_and (p : AffineVerifyLinear.Projection steps rows) (stored : AffineDevice.Storage p)
    {first second : Nat → Nat → Prop} (left : AffineMemoryFrames.Protected p stored first)
    (right : AffineMemoryFrames.Protected p stored second) :
    AffineMemoryFrames.Protected p stored (fun base size => first base size ∧ second base size) := by
  cases p <;> exact ⟨⟨left.1,right.1⟩,⟨left.2.1,right.2.1⟩,⟨left.2.2,right.2.2⟩⟩

theorem trellis_and (stored : TrellisWeightsMemory.Weights mlp memory)
    {first second : Nat → Nat → Prop} (left : stored.Protected first) (right : stored.Protected second) :
    stored.Protected (fun base size => first base size ∧ second base size) :=
  ⟨⟨left.1,right.1⟩,⟨left.2.1,right.2.1⟩,⟨left.2.2.1,right.2.2.1⟩,
    ⟨left.2.2.2.1,right.2.2.2.1⟩,⟨left.2.2.2.2.1,right.2.2.2.2.1⟩,⟨left.2.2.2.2.2,right.2.2.2.2.2⟩⟩

theorem parameters_and (stored : DecodeParameterMemory.AttentionStorage layer memory)
    {first second : Nat → Nat → Prop} (left : stored.Protected first) (right : stored.Protected second) :
    stored.Protected (fun base size => first base size ∧ second base size) :=
  ⟨⟨left.1,right.1⟩,
    ⟨affine_and _ _ left.2.1.1 right.2.1.1,affine_and _ _ left.2.1.2.1 right.2.1.2.1,
      affine_and _ _ left.2.1.2.2 right.2.1.2.2⟩,
    ⟨⟨left.2.2.1.1,right.2.2.1.1⟩,⟨left.2.2.1.2.1,right.2.2.1.2.1⟩,
      affine_and _ _ left.2.2.1.2.2 right.2.2.1.2.2⟩,
    ⟨⟨left.2.2.2.1,right.2.2.2.1⟩,trellis_and _ left.2.2.2.2 right.2.2.2.2⟩⟩

def bytes (blocks : Nat) : Nat := 79872+AttentionTailWorkspaceConstruction.bytes blocks

theorem subregion {workspace other size offset count blocks : Nat}
    (safe : MemoryRegions.Disjoint workspace (bytes blocks) other size) (inside : offset+count≤bytes blocks) :
    MemoryRegions.Disjoint (workspace+offset) count other size := by
  unfold MemoryRegions.Disjoint at *
  omega

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {input : Fin 5120 → ArrayStorage.BF}
  {s : ResidualAttentionStorageConstruction.Source layer cache input}

structure Workspace (s : ResidualAttentionStorageConstruction.Source layer cache input) where
  base : Nat
  aligned : base%16=0
  bounded : base+bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))≤2^64
  sourceSeparate : MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) s.source.base 10240
  parametersSeparate : s.parameters.Protected (MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))))
  keysSeparate : MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) s.storage.layout.keyBase (KvRegions.bytes n)
  valuesSeparate : MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) s.storage.layout.valueBase (KvRegions.bytes n)
  queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2
  keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2

def Workspace.prefixArena (w : Workspace s) : AttentionPrefixAllocation.Arena s where
  base := w.base
  aligned := by have := w.aligned; omega
  bounded := (Nat.le_add_right (w.base+79872) (AttentionTailWorkspaceConstruction.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1)))).trans
    (by simpa only [bytes,Nat.add_assoc] using w.bounded)
  sourceSeparate := by simpa only [Nat.add_zero] using subregion (offset := 0) w.sourceSeparate (Nat.le_add_right _ _)
  parametersSeparate := s.parameters.protected_mono (fun _ _ safe => by
    simpa only [Nat.add_zero] using subregion (offset := 0) safe (Nat.le_add_right _ _)) w.parametersSeparate
  queryDispatch := w.queryDispatch
  keyDispatch := w.keyDispatch

theorem Workspace.cachePlan (w : Workspace s) (angle : RopeAngles.Inputs) :
    ResidualAttentionStorageConstruction.CacheAllocation (w.prefixArena.prefixAllocation angle) :=
  w.prefixArena.cacheAllocation angle
    (by simpa only [Workspace.prefixArena,Nat.add_zero] using subregion (offset := 0) w.keysSeparate (Nat.le_add_right _ _))
    (by simpa only [Workspace.prefixArena,Nat.add_zero] using subregion (offset := 0) w.valuesSeparate (Nat.le_add_right _ _))

variable (w : Workspace s) (angle : RopeAngles.Inputs)

inductive CacheChoice where
  | existing (room : ¬KvAllocation.capacity n<n+1)
      (keyResidual : MemoryRegions.Disjoint s.storage.layout.keyBase (KvRegions.bytes n) s.source.base 10240)
      (valueResidual : MemoryRegions.Disjoint s.storage.layout.valueBase (KvRegions.bytes n) s.source.base 10240)
      (parameters : s.parameters.Protected (AttentionReadAllocation.ExistingSafe (w.cachePlan angle).input))
  | growth (workspace : KvGrowthAllocation.Workspace (w.cachePlan angle).input.oldAfter)
      (growing : KvAllocation.capacity n<n+1)
      (separate : MemoryRegions.Disjoint workspace.base (KvGrowthAllocation.bytes n) w.base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))))
      (residual : MemoryRegions.Disjoint workspace.base (KvGrowthAllocation.bytes n) s.source.base 10240)
      (parameters : s.parameters.Protected (MemoryRegions.Disjoint workspace.base (KvGrowthAllocation.bytes n)))

theorem prefix_keys : MemoryRegions.Disjoint w.prefixArena.base 79872 s.storage.layout.keyBase (KvRegions.bytes n) :=
  by simpa only [Workspace.prefixArena,Nat.add_zero] using subregion (offset := 0) w.keysSeparate (Nat.le_add_right _ _)
theorem prefix_values : MemoryRegions.Disjoint w.prefixArena.base 79872 s.storage.layout.valueBase (KvRegions.bytes n) :=
  by simpa only [Workspace.prefixArena,Nat.add_zero] using subregion (offset := 0) w.valuesSeparate (Nat.le_add_right _ _)

variable {w : Workspace s} {angle : RopeAngles.Inputs}

def CacheChoice.read (choice : CacheChoice w angle) : ReadPlan (w.cachePlan angle).input := match choice with
  | .existing room kr vr _ => AttentionPrefixReadAllocation.existingRead w.prefixArena angle (w.cachePlan angle) room
      (prefix_keys w) (prefix_values w) kr vr
  | .growth workspace growing separate residual _ => AttentionPrefixReadAllocation.growthRead w.prefixArena angle (w.cachePlan angle)
      workspace growing
      (MemoryRegions.disjoint_symm (by simpa only [Workspace.prefixArena,Nat.add_zero] using subregion (offset := 0) (MemoryRegions.disjoint_symm separate) (Nat.le_add_right _ _))) residual

def CacheChoice.Safe (choice : CacheChoice w angle) (base size : Nat) : Prop := match choice with
  | .existing _ _ _ _ => AttentionReadAllocation.ExistingSafe (w.cachePlan angle).input base size
  | .growth workspace _ _ _ _ => MemoryRegions.Disjoint workspace.base (KvGrowthAllocation.bytes n) base size


theorem CacheChoice.append_safe (choice : CacheChoice w angle) {base size : Nat}
    (safe : choice.Safe base size) : choice.read.allocation.append.Safe base size := by
  cases choice with
  | existing room kr vr parameters =>
    exact AttentionReadAllocation.existing_append_safe room
      (AttentionPrefixReadAllocation.existing_live w.prefixArena angle (w.cachePlan angle) (prefix_keys w) (prefix_values w) kr vr) safe
  | growth workspace growing separate residual parameters =>
    exact AttentionReadAllocation.growth_append_safe workspace growing
      (AttentionPrefixReadAllocation.live_of_arena w.prefixArena angle (w.cachePlan angle)
        (MemoryRegions.disjoint_symm (by simpa only [Workspace.prefixArena,Nat.add_zero] using subregion (offset := 0) (MemoryRegions.disjoint_symm separate) (Nat.le_add_right _ _))) residual) safe

theorem CacheChoice.read_safe (choice : CacheChoice w angle) {base size : Nat}
    (frontSafe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) base size)
    (cacheSafe : choice.Safe base size) : choice.read.Safe base size :=
  ⟨w.prefixArena.safe angle (by simpa only [Workspace.prefixArena,Nat.add_zero] using subregion (offset := 0) frontSafe (Nat.le_add_right _ _)),choice.append_safe cacheSafe⟩

theorem CacheChoice.parameter_safe (choice : CacheChoice w angle) : s.parameters.Protected choice.Safe := by
  cases choice with
  | existing _ _ _ parameters => exact parameters
  | growth _ _ _ _ parameters => exact parameters

theorem prefix_parameter_regions {source : ResidualAttentionStorageConstruction.Source layer cache input}
    {entry : ResidualAttentionStorageConstruction.EntryPlan source}
    {copied : ResidualAttentionStorageConstruction.CopyAllocation entry}
    (front : ResidualAttentionStorageConstruction.PrefixAllocation copied angle) (property : Nat → Nat → Prop) :
    front.parameters.Protected property ↔ entry.parameters.Protected property := by
  unfold ResidualAttentionStorageConstruction.PrefixAllocation.parameters ResidualAttentionStorageConstruction.PrefixAllocation.front
  rfl

theorem Workspace.parameter_regions (w : Workspace s) (angle : RopeAngles.Inputs) (property : Nat → Nat → Prop) :
    (w.prefixArena.prefixAllocation angle).parameters.Protected property ↔ s.parameters.Protected property :=
  (prefix_parameter_regions _ property).trans Iff.rfl

theorem CacheChoice.parameters_before (choice : CacheChoice w angle) :
    (w.prefixArena.prefixAllocation angle).parameters.Protected choice.read.Safe :=
  (w.parameter_regions angle _).mpr (s.parameters.protected_mono
    (fun _ _ pair => choice.read_safe pair.1 pair.2) (parameters_and _ w.parametersSeparate choice.parameter_safe))

section ReadBases
variable {body : Input layer cache input angle}

theorem query_base (read : ReadPlan body) (head : Fin 24) : (read.input.query head).base=(body.front.query head).base := by
  unfold ReadPlan.input AttentionBlockMemory.Append.input AttentionBlockMemory.Append.buffer
  rfl

theorem gate_base (read : ReadPlan body) (head : Fin 24) : (read.gates head).base=(body.front.gate head).base := by
  unfold ReadPlan.gates AttentionBlockMemory.Append.buffer
  rfl

theorem residual_base (read : ReadPlan body) : read.residual.base=body.front.entry.source.lhs.base := by
  unfold ReadPlan.residual AttentionBlockMemory.Append.buffer Input.savedResidual ResidualAttentionMemory.Prefix.residual
  rfl

theorem key_base (read : ReadPlan body) : read.input.cache.layout.keyBase=read.allocation.preparation.storage.layout.keyBase := rfl

theorem value_base (read : ReadPlan body) : read.input.cache.layout.valueBase=read.allocation.preparation.storage.layout.valueBase := rfl
end ReadBases

def Workspace.tailBase (w : Workspace s) : Nat := w.base+79872

theorem prefix_query_bound (base : Nat) (head : Fin 24) : base+65536+512*head.val+512≤base+79872 := by have := head.isLt; omega

theorem prefix_gate_bound (base : Nat) (head : Fin 24) : base+10240+2*(head.val*512+256)+512≤base+79872 := by have := head.isLt; omega

theorem CacheChoice.read_residual_base (choice : CacheChoice w angle) : choice.read.residual.base=s.source.base := by
  rw [residual_base]
  change (w.prefixArena.prefixAllocation angle).front.entry.source.lhs.base=s.source.base
  rw [ResidualAttentionStorageConstruction.PrefixAllocation.entry_eq,ResidualAttentionStorageConstruction.EntryPlan.source_eq]


theorem CacheChoice.tail_cache_safe (choice : CacheChoice w angle) :
    choice.Safe w.tailBase (AttentionTailWorkspaceConstruction.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) := by
  cases choice with
  | existing room kr vr parameters =>
    change MemoryRegions.Disjoint s.storage.layout.keyBase (KvRegions.bytes n) w.tailBase _ ∧
      MemoryRegions.Disjoint s.storage.layout.valueBase (KvRegions.bytes n) w.tailBase _
    exact ⟨MemoryRegions.disjoint_symm (subregion w.keysSeparate (Nat.le_refl _)),
      MemoryRegions.disjoint_symm (subregion w.valuesSeparate (Nat.le_refl _))⟩
  | growth workspace growing separate residual parameters =>
    exact MemoryRegions.disjoint_symm (subregion (MemoryRegions.disjoint_symm separate) (Nat.le_refl _))

def CacheChoice.tailArena (choice : CacheChoice w angle) : AttentionTailWorkspaceConstruction.Arena choice.read where
  base := w.tailBase
  aligned := by have := w.aligned; dsimp [Workspace.tailBase]; omega
  bounded := by simpa only [Workspace.tailBase,bytes,Nat.add_assoc] using w.bounded
  queries := by
    intro head
    rw [query_base]
    change MemoryRegions.Disjoint w.tailBase _ ((w.prefixArena.front angle).query head).base 512
    rw [(w.prefixArena.physical_bases angle).1 head]
    exact Or.inr (prefix_query_bound w.base head)
  gates := by
    intro head
    rw [gate_base]
    change MemoryRegions.Disjoint w.tailBase _ ((w.prefixArena.front angle).gate head).base 512
    rw [(w.prefixArena.physical_bases angle).2.2.1 head]
    exact Or.inr (prefix_gate_bound w.base head)
  residual := by rw [choice.read_residual_base]; exact subregion w.sourceSeparate (Nat.le_refl _)
  keys := by
    rw [key_base]
    exact MemoryRegions.disjoint_symm (choice.append_safe choice.tail_cache_safe).2.1
  values := by
    rw [value_base]
    exact MemoryRegions.disjoint_symm (choice.append_safe choice.tail_cache_safe).2.2
  parametersBefore := choice.parameters_before
  parametersOutside := (w.parameter_regions angle _).mpr
    (s.parameters.protected_mono (fun _ _ region => subregion region (Nat.le_refl _)) w.parametersSeparate)

def CacheChoice.fullPlan (choice : CacheChoice w angle) : ResidualAttentionStorageConstruction.Plan s angle := choice.tailArena.fullPlan

def CacheChoice.execution (choice : CacheChoice w angle) : ResidualAttentionMemory.Execution layer cache input angle :=
  ResidualAttentionStorageConstruction.fromStorage choice.fullPlan

theorem CacheChoice.source_eq (choice : CacheChoice w angle) : choice.execution.source=s.source :=
  ResidualAttentionStorageConstruction.source_linked choice.fullPlan

theorem CacheChoice.storage_eq (choice : CacheChoice w angle) : choice.execution.storage=s.storage :=
  ResidualAttentionStorageConstruction.cache_linked choice.fullPlan

theorem CacheChoice.output_eq (choice : CacheChoice w angle) : choice.execution.output=layer.forward input angle cache := choice.execution.output_eq

theorem CacheChoice.execution_safe (choice : CacheChoice w angle) {base size : Nat}
    (front : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) base size)
    (cacheSafe : choice.Safe base size) : ResidualAttentionMemory.Safe choice.execution base size :=
  ⟨(choice.read_safe front cacheSafe).1,(choice.read_safe front cacheSafe).2,
    choice.tailArena.residual_safe (subregion front (Nat.le_refl _))⟩

theorem CacheChoice.other_region (choice : CacheChoice w angle) {base size : Nat}
    (front : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) base size)
    (cacheSafe : choice.Safe base size) (offset : Nat) (bound : offset<size) :
    choice.execution.outputBuffer.bytes (base+offset)=s.source.bytes (base+offset) := by
  have frame := choice.execution.other_region (choice.execution_safe front cacheSafe) offset bound
  change choice.execution.outputBuffer.bytes (base+offset)=choice.execution.source.bytes (base+offset) at frame
  rw [choice.source_eq] at frame
  exact frame

def CacheChoice.parametersAfter (choice : CacheChoice w angle) : DecodeParameterMemory.AttentionStorage layer choice.execution.outputBuffer.bytes :=
  s.parameters.reframe _ (s.parameters.protected_mono (fun _ _ pair => choice.other_region pair.1 pair.2)
    (parameters_and _ w.parametersSeparate choice.parameter_safe))

-- This is exactly the original-stage-storage plan family used by the bound chain.
def boundPlan (layer : ResidualAttention.Layer) {n : Nat} (cache : Kv.Cache Kv.BF n) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer (.attention layer) cache source.bytes)
    (parameters : DecodeParameterMemory.AttentionStorage layer source.bytes)
    (w : Workspace (DecodeParameterConstruction.attentionSource layer cache input source storage parameters))
    (angle : RopeAngles.Inputs) (choice : CacheChoice w angle) :
    DecodeParameterConstruction.StagePlan (.attention layer) cache input angle source storage parameters := choice.fullPlan


theorem CacheChoice.parametersAfter_regions (choice : CacheChoice w angle) (property : Nat → Nat → Prop) :
    choice.parametersAfter.Protected property ↔ s.parameters.Protected property := s.parameters.reframe_protected _ _ property

theorem CacheChoice.parameter_bytes (choice : CacheChoice w angle) :
    s.parameters.Protected (fun base size => ∀ offset < size,
      choice.execution.outputBuffer.bytes (base+offset)=s.source.bytes (base+offset)) :=
  s.parameters.protected_mono (fun _ _ pair => choice.other_region pair.1 pair.2)
    (parameters_and _ w.parametersSeparate choice.parameter_safe)

theorem footprint (arch : Char) (steps : Nat) : bytes (SdpaDispatched.blockCount arch steps)≤13637632 := by
  have bound := SdpaWorkspace.default_footprint arch steps
  dsimp only [bytes,AttentionTailWorkspaceConstruction.bytes]
  omega

end Inference.Models.Qwen.ResidualAttentionWorkspaceConstruction
