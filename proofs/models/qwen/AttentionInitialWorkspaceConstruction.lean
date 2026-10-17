import models.qwen.AttentionInitialTailConstruction
import models.qwen.AttentionPrefixReadAllocation
import state.KvInitialAllocation

namespace Inference.Models.Qwen.AttentionInitialWorkspaceConstruction
open Contracts.Mlx State Kernels.Attention Layers
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

private theorem query_base {layer : ResidualAttention.Layer} {original : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {cache : Kv.Cache Kv.BF 0} {front : ResidualAttentionMemory.Prefix layer original angle}
    (read : AttentionInitialKvMemory.Read front cache) (head : Fin 24) : (read.input.query head).base=(front.query head).base := rfl

private theorem gate_base {layer : ResidualAttention.Layer} {original : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {cache : Kv.Cache Kv.BF 0} {front : ResidualAttentionMemory.Prefix layer original angle}
    (read : AttentionInitialKvMemory.Read front cache) (head : Fin 24) : (read.gate head).base=(front.gate head).base := rfl

private theorem residual_base {layer : ResidualAttention.Layer} {original : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {cache : Kv.Cache Kv.BF 0} {front : ResidualAttentionMemory.Prefix layer original angle}
    (read : AttentionInitialKvMemory.Read front cache) (first : front.Safe front.entry.source.lhs.base 10240)
    (second : read.kv.Safe front.entry.source.lhs.base 10240) :
    (AttentionInitialTailConstruction.residualBuffer read first second).base=front.entry.source.lhs.base := rfl

variable {layer : ResidualAttention.Layer} {original : Fin 5120 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF 0}
    (source : ResidualAttentionStorageConstruction.Source layer cache original)

def bytes : Nat := 79872+2097152+AttentionInitialTailConstruction.extent (layer:=layer)

structure Workspace where
  base : Nat
  aligned : base%16=0
  bounded : base+bytes (layer:=layer)≤2^64
  sourceBefore : source.source.base+10240≤base
  parametersBefore : source.parameters.Protected (fun address size => address+size≤base)
  queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2
  keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2

variable {source} (w : Workspace source)

def Workspace.prefix : AttentionPrefixAllocation.Arena source where
  base := w.base
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; dsimp [bytes] at this; omega
  sourceSeparate := Or.inr w.sourceBefore
  parametersSeparate := source.parameters.protected_mono (fun _ _ h => Or.inr h) w.parametersBefore
  queryDispatch := w.queryDispatch
  keyDispatch := w.keyDispatch

variable (angle : RopeAngles.Inputs)

def Workspace.front := w.prefix.front angle

theorem Workspace.query_bound (head : Fin 24) : ((w.front angle).query head).base+512≤w.base+79872 := by
  unfold Workspace.front
  rw [(w.prefix.physical_bases angle).1 head]
  have := head.isLt
  dsimp only [Workspace.prefix]
  omega

theorem Workspace.gate_bound (head : Fin 24) : ((w.front angle).gate head).base+512≤w.base+79872 := by
  unfold Workspace.front
  rw [(w.prefix.physical_bases angle).2.2.1 head]
  have := head.isLt
  dsimp only [Workspace.prefix]
  omega

theorem Workspace.key_bound : (w.front angle).keySource.base+KvAppendMemory.sourceBytes (w.front angle).keySource≤w.base+79872 := by
  unfold Workspace.front
  rw [AttentionPrefixReadAllocation.key_source_base]
  change w.base+77824+2048≤w.base+79872
  omega

theorem Workspace.value_bound : (w.front angle).valueSource.base+KvAppendMemory.sourceBytes (w.front angle).valueSource≤w.base+79872 := by
  change (w.front angle).valueBuffer.base+2048≤w.base+79872
  unfold Workspace.front
  rw [(w.prefix.physical_bases angle).2.2.2]
  dsimp only [Workspace.prefix]
  omega

def Workspace.kvWorkspace : KvInitialAllocation.Workspace (w.front angle).keySource (w.front angle).valueSource where
  cursor := w.base+79872
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; dsimp [bytes,KvInitialAllocation.reservedBytes] at this ⊢; omega
  keyBefore := w.key_bound angle
  valueBefore := w.value_bound angle

variable (keyCopied valueCopied : Bool)

def Workspace.read : AttentionInitialKvMemory.Read (w.front angle) cache where
  layout := KvInitialAllocation.layout (w.kvWorkspace angle)
  allocation := KvInitialAllocation.allocation (w.kvWorkspace angle) keyCopied valueCopied
  queries := fun head => KvInitialAllocation.safe (w.kvWorkspace angle) keyCopied valueCopied (w.query_bound angle head)
  gates := fun head => KvInitialAllocation.safe (w.kvWorkspace angle) keyCopied valueCopied (w.gate_bound angle head)

theorem Workspace.source_eq : (w.front angle).entry.source.lhs=source.source := by
  change (w.prefix.prefixAllocation angle).front.entry.source.lhs=source.source
  rw [(w.prefix.prefixAllocation angle).entry_eq]
  exact w.prefix.entryPlan.source_eq

theorem Workspace.residual_prefix : (w.front angle).Safe (w.front angle).entry.source.lhs.base 10240 := by
  rw [w.source_eq angle]
  exact w.prefix.safe angle w.prefix.sourceSeparate

theorem Workspace.residual_kv : (w.read angle keyCopied valueCopied).kv.Safe (w.front angle).entry.source.lhs.base 10240 := by
  apply KvInitialAllocation.safe
  rw [w.source_eq angle]
  exact w.sourceBefore.trans (Nat.le_add_right _ _)

def Workspace.prefixParameters := w.prefix.parametersAfter angle

theorem Workspace.prefix_parameter_bound : (w.prefixParameters angle).Protected (fun address size => address+size≤w.base) :=
  (source.parameters.reframe_protected _ (source.parameters.protected_mono (fun _ _ region => w.prefix.other_region angle region) w.prefix.parametersSeparate) _).mpr w.parametersBefore

def Workspace.parameters := (w.prefixParameters angle).reframe (w.read angle keyCopied valueCopied).input.cache.memory
  ((w.prefixParameters angle).protected_mono (fun _ _ bound => (w.read angle keyCopied valueCopied).other_region
    (KvInitialAllocation.safe (w.kvWorkspace angle) keyCopied valueCopied (bound.trans (Nat.le_add_right _ _))))
    (w.prefix_parameter_bound angle))

theorem Workspace.parameter_bound : (w.parameters angle keyCopied valueCopied).Protected (fun address size => address+size≤w.base) :=
  ((w.prefixParameters angle).reframe_protected _ ((w.prefixParameters angle).protected_mono (fun _ _ bound => (w.read angle keyCopied valueCopied).other_region (KvInitialAllocation.safe (w.kvWorkspace angle) keyCopied valueCopied (bound.trans (Nat.le_add_right _ _)))) (w.prefix_parameter_bound angle)) _).mpr (w.prefix_parameter_bound angle)

def Workspace.tailBase := w.base+79872+2097152

attribute [local irreducible] Workspace.parameters

def Workspace.tailWorkspace : AttentionInitialTailConstruction.Workspace
    (w.read angle keyCopied valueCopied) (w.residual_prefix angle) (w.residual_kv angle keyCopied valueCopied)
    (w.parameters angle keyCopied valueCopied) where
  base := w.tailBase
  aligned := by have := w.aligned; dsimp [Workspace.tailBase]; omega
  bounded := by simpa only [Workspace.tailBase,bytes,Nat.add_assoc] using w.bounded
  queries := fun head => Or.inr (by
    rw [query_base]
    exact (w.query_bound angle head).trans (Nat.le_add_right _ _))
  gates := fun head => Or.inr (by
    rw [gate_base]
    exact (w.gate_bound angle head).trans (Nat.le_add_right _ _))
  residual := Or.inr (by
    rw [residual_base]
    rw [w.source_eq angle]
    exact w.sourceBefore.trans (by dsimp [Workspace.tailBase]; omega))
  keys := Or.inr (KvInitialAllocation.output_bounded (w.kvWorkspace angle) keyCopied valueCopied).1
  values := Or.inr (KvInitialAllocation.output_bounded (w.kvWorkspace angle) keyCopied valueCopied).2
  parameters := (w.parameters angle keyCopied valueCopied).protected_mono
    (fun address size bound => Or.inr (bound.trans (show w.base≤w.tailBase from Nat.le_add_right _ _ |>.trans (Nat.le_add_right _ _))))
    (w.parameter_bound angle keyCopied valueCopied)

def Workspace.execution := (w.tailWorkspace angle keyCopied valueCopied).result

theorem Workspace.output_eq : (w.execution angle keyCopied valueCopied).output=layer.forward original angle cache :=
  (w.tailWorkspace angle keyCopied valueCopied).output_eq

theorem Workspace.other_region {base size : Nat} (bound : base+size≤w.base) (offset : Nat) (inside : offset<size) :
    (w.execution angle keyCopied valueCopied).outputBuffer.bytes (base+offset)=source.source.bytes (base+offset) :=
  ((w.tailWorkspace angle keyCopied valueCopied).other_region
    (Or.inr (bound.trans (show w.base≤w.tailBase from (Nat.le_add_right _ _).trans (Nat.le_add_right _ _)))) offset inside).trans
    (((w.read angle keyCopied valueCopied).other_region
      (KvInitialAllocation.safe (w.kvWorkspace angle) keyCopied valueCopied (bound.trans (Nat.le_add_right _ _))) offset inside).trans
      (w.prefix.other_region angle (Or.inr bound) offset inside))

def Workspace.parametersAfter : DecodeParameterMemory.AttentionStorage layer (w.execution angle keyCopied valueCopied).outputBuffer.bytes :=
  source.parameters.reframe _ (source.parameters.protected_mono
    (fun _ _ region => w.other_region angle keyCopied valueCopied region) w.parametersBefore)

theorem Workspace.parameters_regions (property : Nat → Nat → Prop) :
    (w.parametersAfter angle keyCopied valueCopied).Protected property ↔ source.parameters.Protected property :=
  source.parameters.reframe_protected _ _ property

private theorem result_layout {layer : ResidualAttention.Layer} {original : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {cache : Kv.Cache Kv.BF 0} {front : ResidualAttentionMemory.Prefix layer original angle}
    {read : AttentionInitialKvMemory.Read front cache} (execution : AttentionInitialResultMemory.Execution read) :
    execution.afterCache.layout=read.input.cache.layout := execution.tail.cache_layout

theorem Workspace.cache_bases :
    (w.execution angle keyCopied valueCopied).afterCache.layout.keyBase=
      w.base+79872+(if keyCopied then 1048576 else 0) ∧
    (w.execution angle keyCopied valueCopied).afterCache.layout.valueBase=
      w.base+79872+(if valueCopied then 1572864 else 524288) := by
  rw [result_layout]
  exact ⟨KvInitialAllocation.key_destination (w.kvWorkspace angle) keyCopied,
    KvInitialAllocation.value_destination (w.kvWorkspace angle) valueCopied⟩

theorem Workspace.cache_bound :
    (w.execution angle keyCopied valueCopied).afterCache.layout.keyBase+KvRegions.bytes 1≤w.tailBase ∧
    (w.execution angle keyCopied valueCopied).afterCache.layout.valueBase+KvRegions.bytes 1≤w.tailBase := by
  rw [result_layout]
  exact KvInitialAllocation.output_bounded (w.kvWorkspace angle) keyCopied valueCopied

theorem Workspace.cache_lower :
    w.base+79872≤(w.execution angle keyCopied valueCopied).afterCache.layout.keyBase ∧
    w.base+79872≤(w.execution angle keyCopied valueCopied).afterCache.layout.valueBase := by
  rw [(w.cache_bases angle keyCopied valueCopied).1,(w.cache_bases angle keyCopied valueCopied).2]
  exact ⟨Nat.le_add_right _ _,Nat.le_add_right _ _⟩

theorem Workspace.output_base :
    (w.execution angle keyCopied valueCopied).outputBuffer.base=
      w.tailBase+SdpaWorkspace.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix 1)+34816+720896 :=
  (w.tailWorkspace angle keyCopied valueCopied).output_base

theorem Workspace.output_bound :
    (w.execution angle keyCopied valueCopied).outputBuffer.base+10240≤w.base+bytes (layer:=layer) := by
  rw [w.output_base angle keyCopied valueCopied]
  dsimp [Workspace.tailBase,bytes,AttentionInitialTailConstruction.extent,AttentionTailWorkspaceConstruction.bytes]
  omega

end Inference.Models.Qwen.AttentionInitialWorkspaceConstruction
