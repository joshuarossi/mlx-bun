import models.qwen.AttentionAffineConstruction
import models.qwen.AttentionNormalizedMemory

namespace Inference.Models.Qwen.AttentionNormalizedConstruction
open Contracts.Mlx Layers AttentionAffineConstruction
set_option maxRecDepth 10000

def Protected (w : Weights layer memory) (property : Nat → Nat → Prop) : Prop :=
  AffineMemoryFrames.Protected layer.q w.q property ∧
  AffineMemoryFrames.Protected layer.k w.k property ∧
  AffineMemoryFrames.Protected layer.v w.v property

def afterWeights {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    {source : BinaryMemory.Input input layer.inputNorm.weight}
    (normalization : NormalizationMemory.Execution layer.inputNorm source)
    (w : Weights layer.mixer.projections source.lhs.bytes)
    (safe : Protected w (MemoryRegions.Disjoint (2*normalization.normalized.base) 10240)) :
    Weights layer.mixer.projections (NormalizationMemory.forwardBuffer normalization).bytes := by
  have frame := fun base size (h : MemoryRegions.Disjoint (2*normalization.normalized.base) 10240 base size) =>
    normalization.other_region h
  have same : ∀ base size, MemoryRegions.Disjoint (2*normalization.normalized.base) 10240 base size →
      ∀ offset < size, (NormalizationMemory.forwardBuffer normalization).bytes (base+offset)=source.lhs.bytes (base+offset) := by
    intro base size h offset bound
    rw [NormalizationMemory.forward_bytes]
    exact frame base size h offset bound
  let stable0 := AffineMemoryFrames.stable layer.mixer.projections.q w.q _ _ w.qShared
    (AffineMemoryFrames.protected_mono _ _ same safe.1)
  let stable1 := AffineMemoryFrames.stable layer.mixer.projections.k w.k _ _ w.kShared
    (AffineMemoryFrames.protected_mono _ _ same safe.2.1)
  let stable2 := AffineMemoryFrames.stable layer.mixer.projections.v w.v _ _ w.vShared
    (AffineMemoryFrames.protected_mono _ _ same safe.2.2)
  exact ⟨AffineMemoryFrames.reframe layer.mixer.projections.q w.q _ stable0,
    AffineMemoryFrames.reframe layer.mixer.projections.k w.k _ stable1,
    AffineMemoryFrames.reframe layer.mixer.projections.v w.v _ stable2,
    AffineMemoryFrames.reframe_shared layer.mixer.projections.q w.q _ stable0,
    AffineMemoryFrames.reframe_shared layer.mixer.projections.k w.k _ stable1,
    AffineMemoryFrames.reframe_shared layer.mixer.projections.v w.v _ stable2⟩

def fromNormalization {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    (source : BinaryMemory.Input input layer.inputNorm.weight)
    (normalization : NormalizationMemory.Execution layer.inputNorm source)
    (residualSeparate : MemoryRegions.Disjoint (2*normalization.normalized.base) 10240 source.lhs.base 10240)
    (w : Weights layer.mixer.projections source.lhs.bytes)
    (safe : Protected w (MemoryRegions.Disjoint (2*normalization.normalized.base) 10240))
    (r : Regions)
    (allocation : Allocation r (NormalizationMemory.forwardBuffer normalization) (afterWeights normalization w safe))
    (residualLive : r.Live source.lhs.base 10240) : AttentionNormalizedMemory.Execution layer input := by
  let affine := AttentionAffineConstruction.fromStorage layer.mixer.projections (layer.inputNorm.forward input)
    (NormalizationMemory.forwardBuffer normalization) (afterWeights normalization w safe) r allocation
  have linked : affine.source=NormalizationMemory.forwardBuffer normalization :=
    AttentionAffineConstruction.fromStorage_source _ _ _ _ _ _
  have bases := AttentionAffineConstruction.fromStorage_bases layer.mixer.projections (layer.inputNorm.forward input)
    (NormalizationMemory.forwardBuffer normalization) (afterWeights normalization w safe) r allocation
  refine ⟨source,normalization,residualSeparate,affine,linked,?_⟩
  change MemoryRegions.Disjoint affine.q.base _ _ _ ∧ MemoryRegions.Disjoint affine.k.base _ _ _ ∧
    MemoryRegions.Disjoint affine.v.base _ _ _
  rw [bases.1,bases.2.1,bases.2.2]
  exact residualLive

def fromStorage {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    (source : ArrayStorage.BFBuffer input) (normWeights : ArrayStorage.BFBuffer layer.inputNorm.weight)
    (shared : normWeights.bytes=source.bytes) (base : Nat) (bounded : 2*base+10240 ≤ 2^64)
    (residualSeparate : MemoryRegions.Disjoint (2*base) 10240 source.base 10240)
    (weightsSeparate : MemoryRegions.Disjoint (2*base) 10240 normWeights.base 10240)
    (w : Weights layer.mixer.projections source.bytes)
    (safe : Protected w (MemoryRegions.Disjoint (2*base) 10240))
    (r : Regions)
    (allocation : let normalization := (NormalizationMemory.fromStorage layer.inputNorm source normWeights shared base bounded
        (Or.inr (MemoryRegions.disjoint_symm residualSeparate)) weightsSeparate)
      Allocation r (NormalizationMemory.forwardBuffer normalization) (afterWeights normalization w safe))
    (residualLive : r.Live source.base 10240) : AttentionNormalizedMemory.Execution layer input :=
  fromNormalization ⟨source,normWeights,shared⟩
    (NormalizationMemory.fromStorage layer.inputNorm source normWeights shared base bounded
      (Or.inr (MemoryRegions.disjoint_symm residualSeparate)) weightsSeparate)
    residualSeparate w safe r allocation residualLive

end Inference.Models.Qwen.AttentionNormalizedConstruction
