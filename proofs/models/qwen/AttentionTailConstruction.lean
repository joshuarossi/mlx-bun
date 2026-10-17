import models.qwen.AttentionResidualMemory
import models.qwen.ResidualMlpConstruction
import layers.AffineMemoryFrames

namespace Inference.Models.Qwen.AttentionTailConstruction
open Contracts.Mlx Kernels.Attention State Layers
set_option maxRecDepth 10000
attribute [local irreducible] SdpaOutput.programs Copy2DMemory.programs

variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {gatePlatform : OutputGate.Platform} {projection : AffineVerifyLinear.Projection 12 5120}

structure Regions where
  activation : Nat
  product : Nat
  projection : Nat

def Regions.Live (r : Regions) (attention : SdpaShared.Execution input p contracted arch) (base size : Nat) : Prop :=
  SdpaShared.Safe attention base size ∧ MemoryRegions.Disjoint (2*r.activation) 12288 base size ∧
  MemoryRegions.Disjoint (2*r.product) 12288 base size ∧ MemoryRegions.Disjoint r.projection 10240 base size

structure Allocation (attention : SdpaShared.Execution input p contracted arch)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head))
    (weights : AffineDevice.Storage projection) (r : Regions) : Prop where
  activationBounded : 2*r.activation+12288 ≤ 2^64
  productBounded : 2*r.product+12288 ≤ 2^64
  projectionAligned : r.projection%2=0
  projectionBounded : r.projection+10240 ≤ 2^64
  activationGates : ∀ head, MemoryRegions.Disjoint (2*r.activation) 12288 (gates head).base 512
  activationAttention : MemoryRegions.Disjoint (2*r.activation) 12288 attention.base 12288
  productAttention : attention.base/2=r.product ∨ MemoryRegions.Disjoint (2*(attention.base/2)) 12288 (2*r.product) 12288
  productActivation : r.activation=r.product ∨ MemoryRegions.Disjoint (2*r.activation) 12288 (2*r.product) 12288
  projectionProduct : MemoryRegions.Disjoint r.projection 10240 (2*r.product) 12288
  weightsLive : AffineMemoryFrames.Protected projection weights (r.Live attention)
  activationKeys : MemoryRegions.Disjoint (2*r.activation) 12288 input.cache.layout.keyBase (KvRegions.bytes steps)
  activationValues : MemoryRegions.Disjoint (2*r.activation) 12288 input.cache.layout.valueBase (KvRegions.bytes steps)
  productKeys : MemoryRegions.Disjoint (2*r.product) 12288 input.cache.layout.keyBase (KvRegions.bytes steps)
  productValues : MemoryRegions.Disjoint (2*r.product) 12288 input.cache.layout.valueBase (KvRegions.bytes steps)
  projectionKeys : MemoryRegions.Disjoint r.projection 10240 input.cache.layout.keyBase (KvRegions.bytes steps)
  projectionValues : MemoryRegions.Disjoint r.projection 10240 input.cache.layout.valueBase (KvRegions.bytes steps)

variable (attention : SdpaShared.Execution input p contracted arch)
  (gates : ∀ head, ArrayStorage.BFBuffer (gate head))
  (shared : ∀ head, (gates head).bytes=input.cache.memory)
  (gateSafe : ∀ head, SdpaShared.Safe attention (gates head).base 512)
  (weights : AffineDevice.Storage projection) (weightShared : AffineMemory.Shared projection weights input.cache.memory)
  (r : Regions) (allocation : Allocation attention gates weights r)

def gating : OutputGateMemory.Execution (AttentionTailMemory.gateInput attention gates shared gateSafe) gatePlatform :=
  OutputGateMemory.fromBuffers _ gatePlatform (attention.base/2) r.activation r.product
    (AttentionTailMemory.gateInput_layout attention gates shared gateSafe)
    allocation.activationBounded allocation.productBounded allocation.activationGates
    (by
      intro head
      have headBound := head.isLt
      have aligned := attention.aligned
      have separate := allocation.activationAttention
      rw [AttentionTailMemory.gateInput_layout]
      unfold MemoryRegions.Disjoint at separate ⊢
      omega)
    allocation.productAttention allocation.productActivation

theorem gating_bases :
    (gating (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).activation.base=r.activation ∧
    (gating (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).base=r.product := ⟨rfl,rfl⟩

attribute [local irreducible] gating

-- Reframe the exact original packed/scales/bias storage through SDPA and
-- sigmoid/product writes before constructing the output projection launch.
theorem gating_frame {base size : Nat} (safe : r.Live attention base size) (offset : Nat) (bound : offset<size) :
    (gating (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).buffer.bytes (base+offset)=
      input.cache.memory (base+offset) :=
  ((gating (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).other_region
    (by rw [(gating_bases (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).1]; exact safe.2.1)
    (by rw [(gating_bases (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).2]; exact safe.2.2.1)
    offset bound).trans (attention.other_region safe.1 offset bound)

def projectionWeights : AffineDevice.Storage projection := by
  have same : ∀ base size, r.Live attention base size → ∀ offset < size,
      (gating (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).buffer.bytes (base+offset)=
        input.cache.memory (base+offset) := by
    intro base size safe offset bound
    exact gating_frame (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation safe offset bound
  exact AffineMemoryFrames.reframe projection weights _
    (AffineMemoryFrames.stable projection weights input.cache.memory _ weightShared
      (AffineMemoryFrames.protected_mono projection weights same allocation.weightsLive))

theorem projectionWeights_shared : AffineMemory.Shared projection
    (projectionWeights (gatePlatform := gatePlatform) attention gates shared gateSafe weights weightShared r allocation)
    (gating (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).buffer.bytes :=
  AffineMemoryFrames.reframe_shared projection weights _ _

theorem separate (weights : AffineDevice.Storage projection)
    (safe : AffineMemoryFrames.Protected projection weights (MemoryRegions.Disjoint base size)) :
    AffineMemory.Separate projection weights base size := by
  cases projection <;> exact ⟨safe.1,safe.2.1,safe.2.2⟩

def projected : AttentionOutputMemory.Execution
    (gating (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation) projection :=
  AttentionOutputMemory.fromGate _ projection
    (projectionWeights (gatePlatform := gatePlatform) attention gates shared gateSafe weights weightShared r allocation)
    (projectionWeights_shared (gatePlatform := gatePlatform) attention gates shared gateSafe weights weightShared r allocation)
    r.projection allocation.projectionAligned allocation.projectionBounded
    (by change MemoryRegions.Disjoint r.projection 10240 (2*(gating (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).base) 12288; rw [(gating_bases (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).2]; exact allocation.projectionProduct)
    (by
      apply separate
      apply (AffineMemoryFrames.reframe_protected projection weights _ _ _).mpr
      exact AffineMemoryFrames.protected_mono projection weights (fun _ _ h => h.2.2.2) allocation.weightsLive)

theorem projected_base :
    (projected (gatePlatform := gatePlatform) attention gates shared gateSafe weights weightShared r allocation).affine.base=r.projection := by
  unfold projected AttentionOutputMemory.fromGate
  cases projection <;> rfl

def fromStorage : AttentionTailMemory.Execution attention gate gatePlatform projection where
  gates := gates
  gatesShared := shared
  gatesSafe := gateSafe
  gating := gating (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation
  projected := projected (gatePlatform := gatePlatform) attention gates shared gateSafe weights weightShared r allocation
  gateSeparate := by
    constructor
    · rw [(gating_bases (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).1,attention.cache_layout]
      exact allocation.activationKeys
    · rw [(gating_bases (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).1,attention.cache_layout]
      exact allocation.activationValues
    · rw [(gating_bases (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).2,attention.cache_layout]
      exact allocation.productKeys
    · rw [(gating_bases (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).2,attention.cache_layout]
      exact allocation.productValues
  projectionKeys := by
    rw [projected_base,attention.cache_layout]
    exact allocation.projectionKeys
  projectionValues := by
    rw [projected_base,attention.cache_layout]
    exact allocation.projectionValues

theorem fromStorage_safe {base size : Nat} (safe : r.Live attention base size) :
    AttentionTailMemory.Safe (fromStorage (gatePlatform := gatePlatform) attention gates shared gateSafe weights weightShared r allocation) base size := by
  change SdpaShared.Safe attention base size ∧
    MemoryRegions.Disjoint (2*(gating (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).activation.base) 12288 base size ∧
    MemoryRegions.Disjoint (2*(gating (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).base) 12288 base size ∧
    MemoryRegions.Disjoint (projected (gatePlatform := gatePlatform) attention gates shared gateSafe weights weightShared r allocation).affine.base 10240 base size
  rw [(gating_bases (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).1,
    (gating_bases (gatePlatform := gatePlatform) attention gates shared gateSafe weights r allocation).2,projected_base]
  exact safe

variable {attention gates shared gateSafe weights weightShared r allocation}
  {block : ResidualBlocks.Mlp} {x : Fin 5120 → ArrayStorage.BF}
  {tail : AttentionTailMemory.Execution attention gate gatePlatform projection}

def normAfterTail (tail : AttentionTailMemory.Execution attention gate gatePlatform projection)
    (weights : ArrayStorage.BFBuffer block.norm.weight) (shared : weights.bytes=input.cache.memory)
    (safe : AttentionTailMemory.Safe tail weights.base 10240) : ArrayStorage.BFBuffer block.norm.weight :=
  ArrayFrame.bf weights tail.buffer.bytes
    (fun offset bound => (tail.other_region safe offset bound).trans (congrFun shared _).symm)

def mlpAfterTail (tail : AttentionTailMemory.Execution attention gate gatePlatform projection)
    (parameters : TrellisWeightsMemory.Weights block.mlp input.cache.memory)
    (safe : parameters.Protected (AttentionTailMemory.Safe tail)) : TrellisWeightsMemory.Weights block.mlp tail.buffer.bytes :=
  parameters.reframe tail.buffer.bytes (parameters.protected_mono (fun _ _ region => tail.other_region region) safe)

variable (tail : AttentionTailMemory.Execution attention gate gatePlatform projection)
  (source : ArrayStorage.BFBuffer x) (sourceShared : source.bytes=input.cache.memory)
  (sourceSafe : AttentionTailMemory.Safe tail source.base 10240)
  (normWeights : ArrayStorage.BFBuffer block.norm.weight) (normShared : normWeights.bytes=input.cache.memory)
  (normSafe : AttentionTailMemory.Safe tail normWeights.base 10240)
  (parameters : TrellisWeightsMemory.Weights block.mlp input.cache.memory)
  (parameterSafe : parameters.Protected (AttentionTailMemory.Safe tail))

abbrev SuffixAllocation := ResidualMlpConstruction.Allocation
  (AttentionResidualMemory.residualInput tail source sourceShared sourceSafe)
  (normAfterTail tail normWeights normShared normSafe) rfl (mlpAfterTail tail parameters parameterSafe)

def suffix (allocation : SuffixAllocation tail source sourceShared sourceSafe normWeights normShared normSafe parameters parameterSafe) :
    ResidualMlpMemory.Execution block (AttentionResidualMemory.residualInput tail source sourceShared sourceSafe) :=
  ResidualMlpConstruction.fromStorage _ (normAfterTail tail normWeights normShared normSafe) rfl
    (mlpAfterTail tail parameters parameterSafe) allocation

def residualFromStorage
    (allocation : SuffixAllocation tail source sourceShared sourceSafe normWeights normShared normSafe parameters parameterSafe)
    (keysSafe : ResidualMlpConstruction.RegionsSafe allocation tail.afterCache.layout.keyBase (KvRegions.bytes steps))
    (valuesSafe : ResidualMlpConstruction.RegionsSafe allocation tail.afterCache.layout.valueBase (KvRegions.bytes steps)) :
    AttentionResidualMemory.Execution tail block x :=
  AttentionResidualMemory.fromSuffix tail block source sourceShared sourceSafe
    (suffix tail source sourceShared sourceSafe normWeights normShared normSafe parameters parameterSafe allocation)
    (ResidualMlpConstruction.fromStorage_safe _ _ _ _ allocation keysSafe)
    (ResidualMlpConstruction.fromStorage_safe _ _ _ _ allocation valuesSafe)

end Inference.Models.Qwen.AttentionTailConstruction
