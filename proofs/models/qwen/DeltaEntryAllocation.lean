import models.qwen.DecodeParameterConstruction

namespace Inference.Models.Qwen.DeltaEntryAllocation
open Contracts.Mlx Layers
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

structure Arena where
  base : Nat
  aligned : base%4=0
  bounded : base+43200 ≤ 2^64

def Arena.regions (arena : Arena) : DeltaAffineConstruction.Regions :=
  ⟨arena.base+10240,arena.base+30720,arena.base+43008,arena.base+43104⟩

theorem Arena.half (arena : Arena) : 2*(arena.base/2)=arena.base := by have := arena.aligned; omega

theorem Arena.normSeparate (arena : Arena) {base size : Nat} (safe : MemoryRegions.Disjoint arena.base 43200 base size) :
    MemoryRegions.Disjoint (2*(arena.base/2)) 10240 base size := by
  rw [arena.half]
  unfold MemoryRegions.Disjoint at *
  omega

theorem Arena.live (arena : Arena) {base size : Nat} (safe : MemoryRegions.Disjoint arena.base 43200 base size) :
    arena.regions.Live base size := by
  simp only [DeltaAffineConstruction.Regions.Live, Arena.regions, MemoryRegions.Disjoint] at *
  omega

theorem afterWeights_regions {layer : ResidualDelta.Layer} {input : Fin 5120 → ArrayStorage.BF}
    {source : BinaryMemory.Input input layer.inputNorm.weight}
    (normalization : NormalizationMemory.Execution layer.inputNorm source)
    (weights : DeltaAffineConstruction.Weights layer.mixer source.lhs.bytes)
    (safe : DeltaNormalizedConstruction.Protected weights (MemoryRegions.Disjoint (2*normalization.normalized.base) 10240))
    (property : Nat → Nat → Prop) :
    DeltaNormalizedConstruction.Protected (DeltaNormalizedConstruction.afterWeights normalization weights safe) property ↔
      DeltaNormalizedConstruction.Protected weights property := by
  unfold DeltaNormalizedConstruction.Protected DeltaNormalizedConstruction.afterWeights
  simp only [AffineMemoryFrames.reframe_protected]

theorem Arena.affineAllocation (arena : Arena) (source : ArrayStorage.BFBuffer input)
    (weights : DeltaAffineConstruction.Weights layer source.bytes) (sourceBase : source.base=arena.base)
    (safe : DeltaNormalizedConstruction.Protected weights (MemoryRegions.Disjoint arena.base 43200)) :
    DeltaAffineConstruction.Allocation arena.regions source weights where
  qkvAligned := by have := arena.aligned; dsimp [Arena.regions]; omega
  zAligned := by have := arena.aligned; dsimp [Arena.regions]; omega
  aAligned := by have := arena.aligned; dsimp [Arena.regions]; omega
  bAligned := by have := arena.aligned; dsimp [Arena.regions]; omega
  qkvBounded := by have := arena.bounded; dsimp [Arena.regions]; omega
  zBounded := by have := arena.bounded; dsimp [Arena.regions]; omega
  aBounded := by have := arena.bounded; dsimp [Arena.regions]; omega
  bBounded := by have := arena.bounded; dsimp [Arena.regions]; omega
  inputLive := by rw [sourceBase]; simp only [DeltaAffineConstruction.Regions.Live, Arena.regions, MemoryRegions.Disjoint]; omega
  qkvLive := AffineMemoryFrames.protected_mono _ _ (fun _ _ h => arena.live h) safe.1
  zLive := AffineMemoryFrames.protected_mono _ _ (fun _ _ h => arena.live h) safe.2.1
  aLive := AffineMemoryFrames.protected_mono _ _ (fun _ _ h => arena.live h) safe.2.2.1
  bLive := AffineMemoryFrames.protected_mono _ _ (fun _ _ h => arena.live h) safe.2.2.2
  zQkv := by simp only [Arena.regions, MemoryRegions.Disjoint]; omega
  aQkv := by simp only [Arena.regions, MemoryRegions.Disjoint]; omega
  bQkv := by simp only [Arena.regions, MemoryRegions.Disjoint]; omega
  aZ := by simp only [Arena.regions, MemoryRegions.Disjoint]; omega
  bZ := by simp only [Arena.regions, MemoryRegions.Disjoint]; omega
  bA := by simp only [Arena.regions, MemoryRegions.Disjoint]; omega

variable {layer : ResidualDelta.Layer} {input : Fin 5120 → ArrayStorage.BF}

def fromStorage (source : ArrayStorage.BFBuffer input) (parameters : DecodeParameterMemory.DeltaStorage layer source.bytes)
    (arena : Arena) (sourceSafe : MemoryRegions.Disjoint arena.base 43200 source.base 10240)
    (parametersSafe : parameters.Protected (MemoryRegions.Disjoint arena.base 43200)) :
    DecodeParameterConstruction.DeltaEntry layer input source parameters := by
  have normSafe := arena.normSeparate parametersSafe.1
  have residualSafe := arena.normSeparate sourceSafe
  have affineSafe : DeltaNormalizedConstruction.Protected parameters.projections (MemoryRegions.Disjoint (2*(arena.base/2)) 10240) :=
    ⟨AffineMemoryFrames.protected_mono _ _ (fun _ _ h => arena.normSeparate h) parametersSafe.2.1.1,
      AffineMemoryFrames.protected_mono _ _ (fun _ _ h => arena.normSeparate h) parametersSafe.2.1.2.1,
      AffineMemoryFrames.protected_mono _ _ (fun _ _ h => arena.normSeparate h) parametersSafe.2.1.2.2.1,
      AffineMemoryFrames.protected_mono _ _ (fun _ _ h => arena.normSeparate h) parametersSafe.2.1.2.2.2⟩
  have bounded : 2*(arena.base/2)+10240 ≤ 2^64 := by rw [arena.half]; have := arena.bounded; omega
  let normalization := NormalizationMemory.fromStorage layer.inputNorm source parameters.norm parameters.normShared (arena.base/2)
    bounded (Or.inr (MemoryRegions.disjoint_symm residualSafe)) normSafe
  have normBase : 2*normalization.normalized.base=arena.base := arena.half
  have forwardBase : (NormalizationMemory.forwardBuffer normalization).base=arena.base :=
    (NormalizationMemory.forward_base normalization).trans normBase
  have weightsSafe : DeltaNormalizedConstruction.Protected
      (DeltaNormalizedConstruction.afterWeights normalization parameters.projections affineSafe)
      (MemoryRegions.Disjoint arena.base 43200) :=
    (afterWeights_regions normalization parameters.projections affineSafe _).mpr parametersSafe.2.1
  let data : ResidualDeltaConstruction.InputData layer input := {
    source := source, normWeights := parameters.norm, shared := parameters.normShared
    normalizationBase := arena.base/2, normalizationBounded := bounded
    residualSeparate := residualSafe, normSeparate := normSafe
    affineWeights := parameters.projections, affineSafe := affineSafe
    affineRegions := arena.regions
    affineAllocation := arena.affineAllocation _ _ forwardBase weightsSafe
    residualLive := arena.live sourceSafe }
  exact ⟨data,rfl,rfl,HEq.rfl⟩


-- One outside-region contract protects every write in the fixed entry arena.
theorem normalized_safe (data : ResidualDeltaConstruction.InputData layer input)
    (normSafe : MemoryRegions.Disjoint (2*data.normalizationBase) 10240 base size)
    (affineSafe : data.affineRegions.Live base size) :
    DeltaNormalizedMemory.Safe (ResidualDeltaConstruction.normalized data) base size := by
  refine ⟨normSafe,?_⟩
  have bases := DeltaAffineConstruction.fromStorage_bases layer.mixer (layer.inputNorm.forward input)
    (NormalizationMemory.forwardBuffer (NormalizationMemory.fromStorage layer.inputNorm data.source data.normWeights data.shared
      data.normalizationBase data.normalizationBounded (Or.inr (MemoryRegions.disjoint_symm data.residualSeparate)) data.normSeparate))
    _ data.affineRegions data.affineAllocation
  change MemoryRegions.Disjoint _ 20480 base size ∧ MemoryRegions.Disjoint _ 12288 base size ∧
    MemoryRegions.Disjoint _ 96 base size ∧ MemoryRegions.Disjoint _ 96 base size
  change (ResidualDeltaConstruction.normalized data).affine.qkv.base=data.affineRegions.qkv ∧
    (ResidualDeltaConstruction.normalized data).affine.z.base=data.affineRegions.z ∧
    (ResidualDeltaConstruction.normalized data).affine.a.base=data.affineRegions.a ∧
    (ResidualDeltaConstruction.normalized data).affine.b.base=data.affineRegions.b at bases
  rw [bases.1,bases.2.1,bases.2.2.1,bases.2.2.2]
  exact affineSafe

theorem safe (source : ArrayStorage.BFBuffer input) (parameters : DecodeParameterMemory.DeltaStorage layer source.bytes)
    (arena : Arena) (sourceSafe : MemoryRegions.Disjoint arena.base 43200 source.base 10240)
    (parametersSafe : parameters.Protected (MemoryRegions.Disjoint arena.base 43200))
    {base size : Nat} (separate : MemoryRegions.Disjoint arena.base 43200 base size) :
    DeltaNormalizedMemory.Safe (ResidualDeltaConstruction.normalized (fromStorage source parameters arena sourceSafe parametersSafe).data) base size :=
  normalized_safe _ (arena.normSeparate separate) (arena.live separate)


theorem mixer_transport (weights : DeltaParameterMemory.Storage layer.mixer before) {after : ByteMemory.Bytes}
    (same : after=before) (property : Nat → Nat → Prop) :
    DeltaParameterMemory.Protected (DecodeParameterConstruction.transport (DeltaParameterMemory.Storage layer.mixer) same weights) property ↔
      DeltaParameterMemory.Protected weights property := by cases same; rfl

theorem suffix_transport (weights : ResidualDeltaConstruction.MlpWeights layer.suffix before) {after : ByteMemory.Bytes}
    (same : after=before) (property : Nat → Nat → Prop) :
    (DecodeParameterConstruction.transport (ResidualDeltaConstruction.MlpWeights layer.suffix) same weights).Protected property ↔
      weights.Protected property := by cases same; rfl

-- Cache protection is another outside-arena contract, on the original cache.
theorem frames (source : ArrayStorage.BFBuffer input) (parameters : DecodeParameterMemory.DeltaStorage layer source.bytes)
    (arena : Arena) (sourceSafe : MemoryRegions.Disjoint arena.base 43200 source.base 10240)
    (parametersSafe : parameters.Protected (MemoryRegions.Disjoint arena.base 43200))
    (storage : DecodeFrame.StageBuffer (n := n) (.delta layer) cache source.bytes)
    (historySafe : MemoryRegions.Disjoint arena.base 43200 storage.storage.buffers.history.base 61440)
    (stateSafe : MemoryRegions.Disjoint arena.base 43200 storage.storage.buffers.recurrent.base 3145728) :
    DecodeParameterConstruction.DeltaFrames (fromStorage source parameters arena sourceSafe parametersSafe) storage := by
  let entry := fromStorage source parameters arena sourceSafe parametersSafe
  have implies := fun base size (h : MemoryRegions.Disjoint arena.base 43200 base size) =>
    safe source parameters arena sourceSafe parametersSafe h
  refine ⟨implies _ _ historySafe,implies _ _ stateSafe,?_,?_⟩
  · exact (mixer_transport parameters.mixer entry.heap _).mpr
      (DeltaParameterMemory.protected_mono parameters.mixer implies parametersSafe.2.2.1)
  · exact (suffix_transport parameters.suffix entry.heap _).mpr
      (DecodeParameterMemory.suffix_mono parameters.suffix implies parametersSafe.2.2.2)

theorem other_region (source : ArrayStorage.BFBuffer input) (parameters : DecodeParameterMemory.DeltaStorage layer source.bytes)
    (arena : Arena) (sourceSafe : MemoryRegions.Disjoint arena.base 43200 source.base 10240)
    (parametersSafe : parameters.Protected (MemoryRegions.Disjoint arena.base 43200))
    {base size : Nat} (separate : MemoryRegions.Disjoint arena.base 43200 base size) (offset : Nat) (bound : offset<size) :
    (ResidualDeltaConstruction.normalized (fromStorage source parameters arena sourceSafe parametersSafe).data).affine.memory (base+offset)=
      source.bytes (base+offset) :=
  ((ResidualDeltaConstruction.normalized _).other_region (safe source parameters arena sourceSafe parametersSafe separate) offset bound).trans
    (congrFun (fromStorage source parameters arena sourceSafe parametersSafe).heap _)

end Inference.Models.Qwen.DeltaEntryAllocation
