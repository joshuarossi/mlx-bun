import models.qwen.CopiedAttentionProjectionAllocation
import models.qwen.CopiedAttentionOriginalBundle
namespace Inference.Models.Qwen.CopiedAttentionEntryAllocation
open Contracts.Mlx Layers
set_option maxRecDepth 10000

def bytes : Nat := 63488

theorem contained {base first firstSize other size : Nat}
    (lower : base≤first) (upper : first+firstSize≤base+bytes)
    (separate : MemoryRegions.Disjoint base bytes other size) : MemoryRegions.Disjoint first firstSize other size := by
  unfold MemoryRegions.Disjoint at *
  omega

structure Workspace {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    (source : ArrayStorage.BFBuffer input) (parameters : DecodeParameterMemory.AttentionStorage layer source.bytes) where
  base : Nat
  aligned : base%2=0
  bounded : base+bytes≤2^64
  sourceSeparate : MemoryRegions.Disjoint base bytes source.base 10240
  parametersSeparate : parameters.Protected (MemoryRegions.Disjoint base bytes)

variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer input} {parameters : DecodeParameterMemory.AttentionStorage layer source.bytes}
  (w : Workspace source parameters)

theorem half_base : 2*(w.base/2)=w.base := by have := w.aligned; omega

def normal : NormalizationMemory.Execution layer.inputNorm ⟨source,parameters.norm,parameters.normShared⟩ :=
  NormalizationMemory.fromStorage layer.inputNorm source parameters.norm parameters.normShared (w.base/2)
    (by rw [half_base]; have := w.bounded; unfold bytes at this; omega)
    (Or.inr (MemoryRegions.disjoint_symm (by
      rw [half_base]; exact contained (by omega) (by unfold bytes; omega) w.sourceSeparate)))
    (by rw [half_base]; exact contained (by omega) (by unfold bytes; omega) w.parametersSeparate.1)

theorem normal_base : (NormalizationMemory.forwardBuffer (normal w)).base=w.base :=
  (NormalizationMemory.forward_base (normal w)).trans (half_base w)

theorem normal_safe : parameters.Protected (MemoryRegions.Disjoint (2*(normal w).normalized.base) 10240) := by
  change parameters.Protected (MemoryRegions.Disjoint (2*(w.base/2)) 10240)
  rw [half_base]
  exact parameters.protected_mono (fun _ _ separate => contained (by omega) (by unfold bytes; omega) separate) w.parametersSeparate

def normalized := CopiedAttentionOriginalBundle.normalized source parameters (normal w) (normal_safe w)

theorem projection_regions : (normalized w).Protected
    (MemoryRegions.Disjoint (w.base+10240) CopiedAttentionProjectionAllocation.bytes) :=
  (CopiedAttentionOriginalBundle.normalized_protected source parameters (normal w) (normal_safe w) _).mpr
    (parameters.protected_mono (fun _ _ separate => contained (by omega)
      (by unfold bytes CopiedAttentionProjectionAllocation.bytes; omega) separate) w.parametersSeparate)

def projectionWorkspace : CopiedAttentionProjectionAllocation.Workspace
    (NormalizationMemory.forwardBuffer (normal w)) (normalized w).projections where
  base := w.base+10240
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; unfold bytes CopiedAttentionProjectionAllocation.bytes at *; omega
  inputSeparate := by rw [normal_base]; exact Or.inr (by omega)
  weightsSeparate := (projection_regions w).2.1

def projections := CopiedAttentionProjectionAllocation.plan (projectionWorkspace w)
def queryCopy := CopiedAttentionProjectionAllocation.queryAllocation (layer:=layer.mixer) (projectionWorkspace w)

theorem source_safe : MemoryRegions.Disjoint (2*(normal w).normalized.base) 10240 source.base 10240 := by
  change MemoryRegions.Disjoint (2*(w.base/2)) 10240 source.base 10240
  rw [half_base]
  exact contained (by omega) (by unfold bytes; omega) w.sourceSeparate

theorem projection_separate {base size : Nat} (separate : MemoryRegions.Disjoint w.base bytes base size) :
    MemoryRegions.Disjoint (projectionWorkspace w).base CopiedAttentionProjectionAllocation.bytes base size :=
  contained (by change w.base≤w.base+10240; omega)
    (by change w.base+10240+53248≤w.base+63488; omega) separate

def memory : ByteMemory.Bytes :=
  (CopiedAttentionParameterConstruction.queryCopy (normalized w).projections (projections w) (queryCopy w)).copy.memory

theorem other_region {base size : Nat} (separate : MemoryRegions.Disjoint w.base bytes base size)
    (offset : Nat) (bound : offset<size) : memory w (base+offset)=source.bytes (base+offset) :=
  (CopiedAttentionProjectionAllocation.other_region (projectionWorkspace w) (projection_separate w separate) offset bound).trans
    (CopiedAttentionOriginalBundle.normalization_frame source parameters (normal w)
      (by change MemoryRegions.Disjoint (2*(w.base/2)) 10240 base size; rw [half_base];
          exact contained (by omega) (by unfold bytes; omega) separate) offset bound)

def parametersAfter : DecodeParameterMemory.AttentionStorage layer (memory w) :=
  parameters.reframe _ (parameters.protected_mono (fun _ _ separate => other_region w separate) w.parametersSeparate)

theorem parameters_protected (property : Nat → Nat → Prop) :
    (parametersAfter w).Protected property ↔ parameters.Protected property :=
  parameters.reframe_protected _ _ property
end Inference.Models.Qwen.CopiedAttentionEntryAllocation
