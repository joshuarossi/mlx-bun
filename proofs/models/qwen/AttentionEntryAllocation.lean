import models.qwen.ResidualAttentionStorageConstruction

namespace Inference.Models.Qwen.AttentionEntryAllocation
open Contracts.Mlx Layers Kernels
set_option maxRecDepth 10000

def regions (base : Nat) : AttentionAffineConstruction.Regions := ⟨base+10240,base+34816,base+36864⟩

theorem contained_disjoint {base first firstSize other size : Nat}
    (lower : base≤first) (upper : first+firstSize≤base+38912)
    (separate : MemoryRegions.Disjoint base 38912 other size) : MemoryRegions.Disjoint first firstSize other size := by
  unfold MemoryRegions.Disjoint at *
  omega

theorem live {base other size : Nat} (separate : MemoryRegions.Disjoint base 38912 other size) :
    (regions base).Live other size := by
  change MemoryRegions.Disjoint (base+10240) 24576 other size ∧ MemoryRegions.Disjoint (base+34816) 2048 other size ∧ MemoryRegions.Disjoint (base+36864) 2048 other size
  exact ⟨contained_disjoint (by omega) (by omega) separate,
    contained_disjoint (by omega) (by omega) separate,contained_disjoint (by omega) (by omega) separate⟩

structure Workspace (source : ArrayStorage.BFBuffer input)
    (parameters : DecodeParameterMemory.AttentionStorage layer source.bytes) where
  base : Nat
  aligned : base%4=0
  bounded : base+38912≤2^64
  sourceSeparate : MemoryRegions.Disjoint base 38912 source.base 10240
  parametersSeparate : parameters.Protected (MemoryRegions.Disjoint base 38912)

variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer input} {parameters : DecodeParameterMemory.AttentionStorage layer source.bytes}

theorem Workspace.half_base (w : Workspace source parameters) : 2*(w.base/2)=w.base := by have := w.aligned; omega

theorem Workspace.normal_source (w : Workspace source parameters) :
    MemoryRegions.Disjoint (2*(w.base/2)) 10240 source.base 10240 := by
  rw [w.half_base]
  exact contained_disjoint (by omega) (by omega) w.sourceSeparate

theorem Workspace.normal_weight (w : Workspace source parameters) :
    MemoryRegions.Disjoint (2*(w.base/2)) 10240 parameters.norm.base 10240 := by
  rw [w.half_base]
  exact contained_disjoint (by omega) (by omega) w.parametersSeparate.1

theorem Workspace.projections_normal (w : Workspace source parameters) :
    AttentionNormalizedConstruction.Protected parameters.projections (MemoryRegions.Disjoint (2*(w.base/2)) 10240) := by
  apply And.intro
  · exact AffineMemoryFrames.protected_mono _ _ (fun _ _ h => by rw [w.half_base]; exact contained_disjoint (by omega) (by omega) h) w.parametersSeparate.2.1.1
  · exact ⟨AffineMemoryFrames.protected_mono _ _ (fun _ _ h => by rw [w.half_base]; exact contained_disjoint (by omega) (by omega) h) w.parametersSeparate.2.1.2.1,
      AffineMemoryFrames.protected_mono _ _ (fun _ _ h => by rw [w.half_base]; exact contained_disjoint (by omega) (by omega) h) w.parametersSeparate.2.1.2.2⟩

def Workspace.normal (w : Workspace source parameters) :=
  NormalizationMemory.fromStorage layer.inputNorm source parameters.norm parameters.normShared (w.base/2)
    (by rw [w.half_base]; have := w.bounded; omega) (Or.inr (MemoryRegions.disjoint_symm w.normal_source)) w.normal_weight

theorem Workspace.normal_base (w : Workspace source parameters) : (NormalizationMemory.forwardBuffer w.normal).base=w.base :=
  (NormalizationMemory.forward_base w.normal).trans w.half_base

theorem afterWeights_protected {source : BinaryMemory.Input input layer.inputNorm.weight}
    (normal : NormalizationMemory.Execution layer.inputNorm source)
    (weights : AttentionAffineConstruction.Weights layer.mixer.projections source.lhs.bytes)
    (safe : AttentionNormalizedConstruction.Protected weights (MemoryRegions.Disjoint (2*normal.normalized.base) 10240))
    (property : Nat → Nat → Prop) :
    AttentionNormalizedConstruction.Protected (AttentionNormalizedConstruction.afterWeights normal weights safe) property ↔
      AttentionNormalizedConstruction.Protected weights property := by
  unfold AttentionNormalizedConstruction.afterWeights AttentionNormalizedConstruction.Protected
  simp only [AffineMemoryFrames.reframe_protected]

theorem Workspace.affineAllocation (w : Workspace source parameters) :
    AttentionAffineConstruction.Allocation (regions w.base) (NormalizationMemory.forwardBuffer w.normal)
      (AttentionNormalizedConstruction.afterWeights w.normal parameters.projections w.projections_normal) where
  qAligned := by have := w.aligned; simp only [regions]; omega
  kAligned := by have := w.aligned; simp only [regions]; omega
  vAligned := by have := w.aligned; simp only [regions]; omega
  qBounded := by simp only [regions]; have := w.bounded; omega
  kBounded := by simp only [regions]; have := w.bounded; omega
  vBounded := by simp only [regions]; have := w.bounded; omega
  inputLive := by rw [w.normal_base]; exact ⟨Or.inr (by simp [regions]),Or.inr (by simp [regions]),Or.inr (by simp [regions])⟩
  qLive := ((afterWeights_protected w.normal parameters.projections w.projections_normal (regions w.base).Live).mpr
    ⟨AffineMemoryFrames.protected_mono _ _ (fun _ _ h => live h) w.parametersSeparate.2.1.1,
      AffineMemoryFrames.protected_mono _ _ (fun _ _ h => live h) w.parametersSeparate.2.1.2.1,
      AffineMemoryFrames.protected_mono _ _ (fun _ _ h => live h) w.parametersSeparate.2.1.2.2⟩).1
  kLive := ((afterWeights_protected w.normal parameters.projections w.projections_normal (regions w.base).Live).mpr
    ⟨AffineMemoryFrames.protected_mono _ _ (fun _ _ h => live h) w.parametersSeparate.2.1.1,
      AffineMemoryFrames.protected_mono _ _ (fun _ _ h => live h) w.parametersSeparate.2.1.2.1,
      AffineMemoryFrames.protected_mono _ _ (fun _ _ h => live h) w.parametersSeparate.2.1.2.2⟩).2.1
  vLive := ((afterWeights_protected w.normal parameters.projections w.projections_normal (regions w.base).Live).mpr
    ⟨AffineMemoryFrames.protected_mono _ _ (fun _ _ h => live h) w.parametersSeparate.2.1.1,
      AffineMemoryFrames.protected_mono _ _ (fun _ _ h => live h) w.parametersSeparate.2.1.2.1,
      AffineMemoryFrames.protected_mono _ _ (fun _ _ h => live h) w.parametersSeparate.2.1.2.2⟩).2.2
  kQ := Or.inr (by simp [regions])
  vQ := Or.inr (by simp [regions])
  vK := Or.inr (by simp [regions])

def Workspace.data (w : Workspace source parameters) : ResidualAttentionConstruction.EntryStorage layer input where
  source := source
  normWeights := parameters.norm
  shared := parameters.normShared
  base := w.base/2
  bounded := by rw [w.half_base]; have := w.bounded; omega
  residualSeparate := w.normal_source
  weightsSeparate := w.normal_weight
  weights := parameters.projections
  weightsSafe := w.projections_normal
  regions := regions w.base
  allocation := w.affineAllocation
  residualLive := live w.sourceSeparate

def Workspace.entry (w : Workspace source parameters) := w.data.entry

theorem Workspace.bases (w : Workspace source parameters) :
    w.entry.normalization.normalized.base=w.base/2 ∧
    w.entry.affine.q.base=w.base+10240 ∧ w.entry.affine.k.base=w.base+34816 ∧ w.entry.affine.v.base=w.base+36864 := by
  refine ⟨rfl,?_⟩
  exact AttentionAffineConstruction.fromStorage_bases layer.mixer.projections (layer.inputNorm.forward input)
    (NormalizationMemory.forwardBuffer w.normal)
    (AttentionNormalizedConstruction.afterWeights w.normal parameters.projections w.projections_normal)
    (regions w.base) w.affineAllocation

theorem Workspace.buffer_bases (w : Workspace source parameters) :
    w.entry.affine.queryGateBuffer.base=w.base+10240 ∧
    w.entry.affine.keyBuffer.base=w.base+34816 ∧ w.entry.affine.valueBuffer.base=w.base+36864 := by
  change w.entry.affine.q.forwardBuffer.base=w.base+10240 ∧
    w.entry.affine.k.forwardBuffer.base=w.base+34816 ∧ w.entry.affine.v.forwardBuffer.base=w.base+36864
  rw [AttentionAffineConstruction.forward_base,AttentionAffineConstruction.forward_base,AttentionAffineConstruction.forward_base]
  exact w.bases.2

theorem Workspace.safe (w : Workspace source parameters) {base size : Nat}
    (separate : MemoryRegions.Disjoint w.base 38912 base size) : AttentionNormalizedMemory.Safe w.entry base size := by
  change MemoryRegions.Disjoint (2*w.entry.normalization.normalized.base) 10240 base size ∧
    MemoryRegions.Disjoint w.entry.affine.q.base 24576 base size ∧
    MemoryRegions.Disjoint w.entry.affine.k.base 2048 base size ∧ MemoryRegions.Disjoint w.entry.affine.v.base 2048 base size
  rw [w.bases.1,w.half_base,w.bases.2.1,w.bases.2.2.1,w.bases.2.2.2]
  exact ⟨contained_disjoint (by omega) (by omega) separate,live separate⟩

theorem Workspace.source_eq (w : Workspace source parameters) : w.entry.source.lhs=source := rfl

theorem Workspace.other_region (w : Workspace source parameters) {base size : Nat}
    (separate : MemoryRegions.Disjoint w.base 38912 base size) (offset : Nat) (bound : offset<size) :
    w.entry.affine.memory (base+offset)=source.bytes (base+offset) := w.entry.other_region (w.safe separate) offset bound

def Workspace.parametersAfter (w : Workspace source parameters) :
    DecodeParameterMemory.AttentionStorage layer w.entry.affine.memory :=
  parameters.reframe _ (parameters.protected_mono (fun _ _ region => w.other_region region) w.parametersSeparate)

def Workspace.strongPlan {n : Nat} {cache : State.Kv.Cache State.Kv.BF n}
    (s : ResidualAttentionStorageConstruction.Source layer cache input) (w : Workspace s.source s.parameters) :
    ResidualAttentionStorageConstruction.EntryPlan s where
  base := w.data.base
  bounded := w.data.bounded
  residualSeparate := w.data.residualSeparate
  weightsSeparate := w.data.weightsSeparate
  weightsSafe := w.data.weightsSafe
  regions := w.data.regions
  allocation := w.data.allocation
  residualLive := w.data.residualLive

theorem Workspace.strong_entry_eq {n : Nat} {cache : State.Kv.Cache State.Kv.BF n}
    (s : ResidualAttentionStorageConstruction.Source layer cache input) (w : Workspace s.source s.parameters) :
    (Workspace.strongPlan s w).entry=w.entry := rfl

end Inference.Models.Qwen.AttentionEntryAllocation
