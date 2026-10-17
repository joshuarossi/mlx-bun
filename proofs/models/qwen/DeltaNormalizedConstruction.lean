import models.qwen.DeltaAffineConstruction
import models.qwen.DeltaNormalizedMemory

namespace Inference.Models.Qwen.DeltaNormalizedConstruction
open Contracts.Mlx Layers DeltaAffineConstruction
set_option maxRecDepth 10000

def Protected (w : Weights layer memory) (property : Nat → Nat → Prop) : Prop :=
  AffineMemoryFrames.Protected layer.qkv w.qkv property ∧
  AffineMemoryFrames.Protected layer.z w.z property ∧
  AffineMemoryFrames.Protected layer.a w.a property ∧
  AffineMemoryFrames.Protected layer.b w.b property

def afterWeights {layer : ResidualDelta.Layer} {input : Fin 5120 → ArrayStorage.BF}
    {source : BinaryMemory.Input input layer.inputNorm.weight}
    (normalization : NormalizationMemory.Execution layer.inputNorm source)
    (w : Weights layer.mixer source.lhs.bytes)
    (safe : Protected w (MemoryRegions.Disjoint (2*normalization.normalized.base) 10240)) :
    Weights layer.mixer (NormalizationMemory.forwardBuffer normalization).bytes := by
  have frame := fun base size (h : MemoryRegions.Disjoint (2*normalization.normalized.base) 10240 base size) =>
    normalization.other_region h
  have same : ∀ base size, MemoryRegions.Disjoint (2*normalization.normalized.base) 10240 base size →
      ∀ offset < size, (NormalizationMemory.forwardBuffer normalization).bytes (base+offset)=source.lhs.bytes (base+offset) := by
    intro base size h offset bound
    rw [NormalizationMemory.forward_bytes]
    exact frame base size h offset bound
  let stable0 := AffineMemoryFrames.stable layer.mixer.qkv w.qkv _ _ w.qkvShared
    (AffineMemoryFrames.protected_mono _ _ same safe.1)
  let stable1 := AffineMemoryFrames.stable layer.mixer.z w.z _ _ w.zShared
    (AffineMemoryFrames.protected_mono _ _ same safe.2.1)
  let stable2 := AffineMemoryFrames.stable layer.mixer.a w.a _ _ w.aShared
    (AffineMemoryFrames.protected_mono _ _ same safe.2.2.1)
  let stable3 := AffineMemoryFrames.stable layer.mixer.b w.b _ _ w.bShared
    (AffineMemoryFrames.protected_mono _ _ same safe.2.2.2)
  exact ⟨AffineMemoryFrames.reframe layer.mixer.qkv w.qkv _ stable0,
    AffineMemoryFrames.reframe layer.mixer.z w.z _ stable1,
    AffineMemoryFrames.reframe layer.mixer.a w.a _ stable2,
    AffineMemoryFrames.reframe layer.mixer.b w.b _ stable3,
    AffineMemoryFrames.reframe_shared layer.mixer.qkv w.qkv _ stable0,
    AffineMemoryFrames.reframe_shared layer.mixer.z w.z _ stable1,
    AffineMemoryFrames.reframe_shared layer.mixer.a w.a _ stable2,
    AffineMemoryFrames.reframe_shared layer.mixer.b w.b _ stable3⟩

def fromNormalization {layer : ResidualDelta.Layer} {input : Fin 5120 → ArrayStorage.BF}
    (source : BinaryMemory.Input input layer.inputNorm.weight)
    (normalization : NormalizationMemory.Execution layer.inputNorm source)
    (residualSeparate : MemoryRegions.Disjoint (2*normalization.normalized.base) 10240 source.lhs.base 10240)
    (w : Weights layer.mixer source.lhs.bytes)
    (safe : Protected w (MemoryRegions.Disjoint (2*normalization.normalized.base) 10240))
    (r : Regions)
    (allocation : Allocation r (NormalizationMemory.forwardBuffer normalization) (afterWeights normalization w safe))
    (residualLive : r.Live source.lhs.base 10240) : DeltaNormalizedMemory.Execution layer input := by
  let affine := DeltaAffineConstruction.fromStorage layer.mixer (layer.inputNorm.forward input)
    (NormalizationMemory.forwardBuffer normalization) (afterWeights normalization w safe) r allocation
  have linked : affine.source=NormalizationMemory.forwardBuffer normalization :=
    DeltaAffineConstruction.fromStorage_source _ _ _ _ _ _
  have bases := DeltaAffineConstruction.fromStorage_bases layer.mixer (layer.inputNorm.forward input)
    (NormalizationMemory.forwardBuffer normalization) (afterWeights normalization w safe) r allocation
  refine ⟨source,normalization,residualSeparate,affine,linked,?_⟩
  change MemoryRegions.Disjoint affine.qkv.base _ _ _ ∧ MemoryRegions.Disjoint affine.z.base _ _ _ ∧
    MemoryRegions.Disjoint affine.a.base _ _ _ ∧ MemoryRegions.Disjoint affine.b.base _ _ _
  rw [bases.1,bases.2.1,bases.2.2.1,bases.2.2.2]
  exact residualLive

def fromStorage {layer : ResidualDelta.Layer} {input : Fin 5120 → ArrayStorage.BF}
    (source : ArrayStorage.BFBuffer input) (normWeights : ArrayStorage.BFBuffer layer.inputNorm.weight)
    (shared : normWeights.bytes=source.bytes) (base : Nat) (bounded : 2*base+10240 ≤ 2^64)
    (residualSeparate : MemoryRegions.Disjoint (2*base) 10240 source.base 10240)
    (weightsSeparate : MemoryRegions.Disjoint (2*base) 10240 normWeights.base 10240)
    (w : Weights layer.mixer source.bytes)
    (safe : Protected w (MemoryRegions.Disjoint (2*base) 10240))
    (r : Regions)
    (allocation : let normalization := (NormalizationMemory.fromStorage layer.inputNorm source normWeights shared base bounded
        (Or.inr (MemoryRegions.disjoint_symm residualSeparate)) weightsSeparate)
      Allocation r (NormalizationMemory.forwardBuffer normalization) (afterWeights normalization w safe))
    (residualLive : r.Live source.base 10240) : DeltaNormalizedMemory.Execution layer input :=
  fromNormalization ⟨source,normWeights,shared⟩
    (NormalizationMemory.fromStorage layer.inputNorm source normWeights shared base bounded
      (Or.inr (MemoryRegions.disjoint_symm residualSeparate)) weightsSeparate)
    residualSeparate w safe r allocation residualLive

end Inference.Models.Qwen.DeltaNormalizedConstruction
