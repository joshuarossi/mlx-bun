import models.qwen.AttentionTailConstruction

namespace Inference.Models.Qwen.AttentionTailAllocation
open Contracts.Mlx Kernels.Attention State Layers
set_option maxRecDepth 100000

def bytes : Nat := 34816

variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {projection : AffineVerifyLinear.Projection 12 5120}

structure Workspace (attention : SdpaShared.Execution input p contracted arch)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (weights : AffineDevice.Storage projection) where
  base : Nat
  aligned : base%4=0
  bounded : base+bytes≤2^64
  attentionSafe : MemoryRegions.Disjoint base bytes attention.base 12288
  gatesSafe : ∀ head, MemoryRegions.Disjoint base bytes (gates head).base 512
  keysSafe : MemoryRegions.Disjoint base bytes input.cache.layout.keyBase (KvRegions.bytes steps)
  valuesSafe : MemoryRegions.Disjoint base bytes input.cache.layout.valueBase (KvRegions.bytes steps)
  weightsSafe : AffineMemoryFrames.Protected projection weights
    (fun other size => SdpaShared.Safe attention other size ∧ MemoryRegions.Disjoint base bytes other size)

theorem subregion {workspace other size offset count : Nat}
    (safe : MemoryRegions.Disjoint workspace bytes other size) (inside : offset+count≤bytes) :
    MemoryRegions.Disjoint (workspace+offset) count other size := by
  unfold MemoryRegions.Disjoint at *
  omega

variable {attention : SdpaShared.Execution input p contracted arch}
  {gates : ∀ head, ArrayStorage.BFBuffer (gate head)} {weights : AffineDevice.Storage projection}
  {other size : Nat}

def Workspace.regions (w : Workspace attention gates weights) : AttentionTailConstruction.Regions :=
  ⟨w.base/2,(w.base+12288)/2,w.base+24576⟩

theorem Workspace.activation_safe (w : Workspace attention gates weights)
    (safe : MemoryRegions.Disjoint w.base bytes other size) :
    MemoryRegions.Disjoint (2*w.regions.activation) 12288 other size := by
  have aligned := w.aligned
  change MemoryRegions.Disjoint (2*(w.base/2)) 12288 other size
  rw [show 2*(w.base/2)=w.base by omega]
  simpa only [Nat.add_zero] using subregion (offset := 0) (count := 12288) safe (by decide +kernel)

theorem Workspace.product_safe (w : Workspace attention gates weights)
    (safe : MemoryRegions.Disjoint w.base bytes other size) :
    MemoryRegions.Disjoint (2*w.regions.product) 12288 other size := by
  have aligned := w.aligned
  change MemoryRegions.Disjoint (2*((w.base+12288)/2)) 12288 other size
  rw [show 2*((w.base+12288)/2)=w.base+12288 by omega]
  exact subregion safe (by decide +kernel : 12288+12288≤bytes)

theorem Workspace.projection_safe (w : Workspace attention gates weights)
    (safe : MemoryRegions.Disjoint w.base bytes other size) :
    MemoryRegions.Disjoint w.regions.projection 10240 other size :=
  subregion safe (by decide +kernel : 24576+10240≤bytes)

theorem Workspace.live (w : Workspace attention gates weights) (first : SdpaShared.Safe attention other size)
    (safe : MemoryRegions.Disjoint w.base bytes other size) : w.regions.Live attention other size :=
  ⟨first,w.activation_safe safe,w.product_safe safe,w.projection_safe safe⟩

theorem Workspace.allocation (w : Workspace attention gates weights) :
    AttentionTailConstruction.Allocation attention gates weights w.regions where
  activationBounded := by have := w.bounded; dsimp [bytes] at this; dsimp [Workspace.regions]; omega
  productBounded := by have := w.bounded; dsimp [bytes] at this; dsimp [Workspace.regions]; omega
  projectionAligned := by have := w.aligned; dsimp [Workspace.regions]; omega
  projectionBounded := by have := w.bounded; dsimp [bytes] at this; dsimp [Workspace.regions]; omega
  activationGates := fun head => w.activation_safe (w.gatesSafe head)
  activationAttention := w.activation_safe w.attentionSafe
  productAttention := Or.inr (by
    have aligned := attention.aligned
    have separate := MemoryRegions.disjoint_symm (w.product_safe w.attentionSafe)
    rw [show 2*(attention.base/2)=attention.base by omega]
    exact separate)
  productActivation := Or.inr (Or.inl (by have := w.aligned; dsimp [Workspace.regions]; omega))
  projectionProduct := Or.inr (by have := w.aligned; dsimp [Workspace.regions]; omega)
  weightsLive := AffineMemoryFrames.protected_mono projection weights (fun _ _ safe => w.live safe.1 safe.2) w.weightsSafe
  activationKeys := w.activation_safe w.keysSafe
  activationValues := w.activation_safe w.valuesSafe
  productKeys := w.product_safe w.keysSafe
  productValues := w.product_safe w.valuesSafe
  projectionKeys := w.projection_safe w.keysSafe
  projectionValues := w.projection_safe w.valuesSafe

variable (w : Workspace attention gates weights) (gatePlatform : OutputGate.Platform)
  (shared : ∀ head, (gates head).bytes=input.cache.memory)
  (gateSafe : ∀ head, SdpaShared.Safe attention (gates head).base 512)
  (weightShared : AffineMemory.Shared projection weights input.cache.memory)

def Workspace.execution : AttentionTailMemory.Execution attention gate gatePlatform projection :=
  AttentionTailConstruction.fromStorage attention gates shared gateSafe weights weightShared w.regions w.allocation

theorem Workspace.protect (first : SdpaShared.Safe attention other size)
    (safe : MemoryRegions.Disjoint w.base bytes other size) :
    AttentionTailMemory.Safe (w.execution gatePlatform shared gateSafe weightShared) other size :=
  AttentionTailConstruction.fromStorage_safe (gatePlatform := gatePlatform)
    attention gates shared gateSafe weights weightShared w.regions w.allocation (w.live first safe)

theorem Workspace.other_region (first : SdpaShared.Safe attention other size)
    (safe : MemoryRegions.Disjoint w.base bytes other size) (offset : Nat) (bound : offset<size) :
    (w.execution gatePlatform shared gateSafe weightShared).projected.affine.outputBuffer.bytes (other+offset)=input.cache.memory (other+offset) :=
  (w.execution gatePlatform shared gateSafe weightShared).other_region
    (w.protect gatePlatform shared gateSafe weightShared first safe) offset bound

theorem footprint : bytes=12288+12288+10240 := by decide +kernel

end Inference.Models.Qwen.AttentionTailAllocation
