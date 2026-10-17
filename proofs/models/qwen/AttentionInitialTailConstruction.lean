import models.qwen.AttentionInitialResultMemory
import models.qwen.AttentionTailWorkspaceConstruction

namespace Inference.Models.Qwen.AttentionInitialTailConstruction
open Contracts.Mlx State Kernels.Attention Layers
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

variable {layer : ResidualAttention.Layer} {original : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {cache : Kv.Cache Kv.BF 0} {front : ResidualAttentionMemory.Prefix layer original angle}
    (read : AttentionInitialKvMemory.Read front cache)
    (residualPrefix : front.Safe front.entry.source.lhs.base 10240)
    (residualKv : read.kv.Safe front.entry.source.lhs.base 10240)
    (parameters : DecodeParameterMemory.AttentionStorage layer read.input.cache.memory)

abbrev extent := AttentionTailWorkspaceConstruction.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix 1)

def residualBuffer := read.buffer (front.residual residualPrefix) rfl residualKv

structure Workspace where
  base : Nat
  aligned : base%16=0
  bounded : base+extent (layer:=layer)≤2^64
  queries : ∀ head, MemoryRegions.Disjoint base (extent (layer:=layer)) (read.input.query head).base 512
  gates : ∀ head, MemoryRegions.Disjoint base (extent (layer:=layer)) (read.gate head).base 512
  residual : MemoryRegions.Disjoint base (extent (layer:=layer)) (residualBuffer read residualPrefix residualKv).base 10240
  keys : MemoryRegions.Disjoint base (extent (layer:=layer)) read.input.cache.layout.keyBase (KvRegions.bytes 1)
  values : MemoryRegions.Disjoint base (extent (layer:=layer)) read.input.cache.layout.valueBase (KvRegions.bytes 1)
  parameters : parameters.Protected (MemoryRegions.Disjoint base (extent (layer:=layer)))

variable {read residualPrefix residualKv parameters}
variable (w : Workspace read residualPrefix residualKv parameters)
variable {base size : Nat}

def Workspace.sdpa : SdpaWorkspace.Workspace read.input layer.mixer.architectureSuffix where
  base := w.base
  aligned := by have := w.aligned; omega
  bounded := by
    change w.base+SdpaWorkspace.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix 1)≤2^64
    have := w.bounded
    dsimp [extent,AttentionTailWorkspaceConstruction.bytes] at this
    omega
  keysSafe := by simpa only [Nat.add_zero] using AttentionTailWorkspaceConstruction.subregion (offset:=0) w.keys (by dsimp [AttentionTailWorkspaceConstruction.bytes]; omega)
  valuesSafe := by simpa only [Nat.add_zero] using AttentionTailWorkspaceConstruction.subregion (offset:=0) w.values (by dsimp [AttentionTailWorkspaceConstruction.bytes]; omega)
  queriesSafe := fun head => by simpa only [Nat.add_zero] using AttentionTailWorkspaceConstruction.subregion (offset:=0) (w.queries head) (by dsimp [AttentionTailWorkspaceConstruction.bytes]; omega)

def Workspace.attention := w.sdpa.execution layer.mixer.attention layer.mixer.mergeContracted

theorem Workspace.sdpa_safe (safe : MemoryRegions.Disjoint w.base (extent (layer:=layer)) base size) :
    SdpaShared.Safe w.attention base size :=
  w.sdpa.protect _ _ (by simpa only [Workspace.sdpa,Nat.add_zero] using AttentionTailWorkspaceConstruction.subregion (offset:=0) safe (by dsimp [AttentionTailWorkspaceConstruction.bytes]; omega))

def Workspace.tailBase := w.base+SdpaWorkspace.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix 1)
def Workspace.suffixBase := w.tailBase+34816

theorem Workspace.tail_safe (safe : MemoryRegions.Disjoint w.base (extent (layer:=layer)) base size) :
    MemoryRegions.Disjoint w.tailBase 34816 base size :=
  AttentionTailWorkspaceConstruction.subregion safe (by dsimp [AttentionTailWorkspaceConstruction.bytes]; omega)

theorem Workspace.suffix_safe (safe : MemoryRegions.Disjoint w.base (extent (layer:=layer)) base size) :
    MemoryRegions.Disjoint w.suffixBase 731136 base size := by
  simpa only [Workspace.suffixBase,Workspace.tailBase,Nat.add_assoc] using
    AttentionTailWorkspaceConstruction.subregion (offset:=SdpaWorkspace.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix 1)+34816) (count:=731136) safe (by dsimp [AttentionTailWorkspaceConstruction.bytes]; omega)

def Workspace.tailWorkspace : AttentionTailAllocation.Workspace w.attention read.gate parameters.mixer.projection where
  base := w.tailBase
  aligned := by have := w.aligned; dsimp [Workspace.tailBase,SdpaWorkspace.bytes]; omega
  bounded := AttentionTailWorkspaceConstruction.tail_bound w.bounded
  attentionSafe := by
    rw [Workspace.attention,w.sdpa.output_base]
    exact Or.inr (by dsimp [Workspace.sdpa,Workspace.tailBase,SdpaWorkspace.bytes]; omega)
  gatesSafe := fun head => w.tail_safe (w.gates head)
  keysSafe := w.tail_safe w.keys
  valuesSafe := w.tail_safe w.values
  weightsSafe := AffineMemoryFrames.protected_mono _ _ (fun _ _ region => ⟨w.sdpa_safe region,w.tail_safe region⟩) w.parameters.2.2.1.2.2

def Workspace.tail := w.tailWorkspace.execution layer.mixer.gate (fun head => read.gates_shared head)
  (fun head => w.sdpa_safe (w.gates head)) parameters.mixer.projectionShared

theorem Workspace.tail_protect (safe : MemoryRegions.Disjoint w.base (extent (layer:=layer)) base size) :
    AttentionTailMemory.Safe w.tail base size :=
  w.tailWorkspace.protect _ _ _ _ (w.sdpa_safe safe) (w.tail_safe safe)

def Workspace.suffixInput := AttentionResidualMemory.residualInput w.tail (residualBuffer read residualPrefix residualKv) rfl (w.tail_protect w.residual)
def Workspace.norm := AttentionTailConstruction.normAfterTail w.tail parameters.suffix.norm parameters.suffix.normShared (w.tail_protect w.parameters.2.2.2.1)
def Workspace.trellis := AttentionTailConstruction.mlpAfterTail w.tail parameters.suffix.trellis
  (parameters.suffix.trellis.protected_mono (fun _ _ region => w.tail_protect region) w.parameters.2.2.2.2)

theorem Workspace.tail_base : w.tail.buffer.base=w.tailBase+24576 := by
  change w.tail.projected.affine.outputBuffer.base=_
  rw [AttentionTailWorkspaceConstruction.affine_output_base]
  exact AttentionTailConstruction.projected_base w.attention read.gate (fun head => read.gates_shared head)
    (fun head => w.sdpa_safe (w.gates head)) parameters.mixer.projection parameters.mixer.projectionShared
    w.tailWorkspace.regions w.tailWorkspace.allocation

def Workspace.mlpWorkspace : ResidualMlpAllocation.Workspace w.suffixInput w.norm w.trellis where
  base := w.suffixBase
  aligned := by have := w.aligned; dsimp [Workspace.suffixBase,Workspace.tailBase,SdpaWorkspace.bytes]; omega
  bounded := AttentionTailWorkspaceConstruction.suffix_bound w.bounded
  leftSafe := w.suffix_safe w.residual
  rightSafe := by change MemoryRegions.Disjoint w.suffixBase 731136 w.tail.buffer.base 10240; rw [w.tail_base]; exact Or.inr (by dsimp [Workspace.suffixBase]; omega)
  normSafe := w.suffix_safe w.parameters.2.2.2.1
  parametersSafe := by
    change parameters.suffix.trellis.Protected _
    exact parameters.suffix.trellis.protected_mono (fun _ _ region => w.suffix_safe region) w.parameters.2.2.2.2

def Workspace.suffix := w.mlpWorkspace.execution rfl

def Workspace.residualExecution : AttentionResidualMemory.Execution w.tail layer.suffix original :=
  AttentionResidualMemory.fromSuffix w.tail layer.suffix (residualBuffer read residualPrefix residualKv) rfl
    (w.tail_protect w.residual) w.suffix
    (w.mlpWorkspace.protect rfl (w.suffix_safe (by rw [w.tail.cache_layout]; exact w.keys)))
    (w.mlpWorkspace.protect rfl (w.suffix_safe (by rw [w.tail.cache_layout]; exact w.values)))

def Workspace.result : AttentionInitialResultMemory.Execution read where
  residualPrefix := residualPrefix
  residualKv := residualKv
  attention := w.attention
  tail := w.tail
  gatesLinked := rfl
  suffix := w.residualExecution
  sourceLinked := rfl

theorem Workspace.protect (safe : MemoryRegions.Disjoint w.base (extent (layer:=layer)) base size) :
    AttentionResidualMemory.Safe w.residualExecution base size :=
  ⟨w.tail_protect safe,w.mlpWorkspace.protect rfl (w.suffix_safe safe)⟩

theorem Workspace.other_region (safe : MemoryRegions.Disjoint w.base (extent (layer:=layer)) base size)
    (offset : Nat) (bound : offset<size) :
    w.result.outputBuffer.bytes (base+offset)=read.input.cache.memory (base+offset) :=
  w.residualExecution.other_region (w.protect safe) offset bound

theorem Workspace.output_eq : w.result.output=layer.forward original angle cache := w.residualExecution.output_eq

theorem Workspace.output_base : w.result.outputBuffer.base=w.suffixBase+720896 :=
  w.mlpWorkspace.output_base rfl

def Workspace.parametersAfter : DecodeParameterMemory.AttentionStorage layer w.result.outputBuffer.bytes :=
  parameters.reframe _ (parameters.protected_mono (fun _ _ region => w.other_region region) w.parameters)

end Inference.Models.Qwen.AttentionInitialTailConstruction
