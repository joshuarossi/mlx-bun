import models.qwen.AttentionTailConstruction
import layers.AffineStorageLineage

namespace Inference.Models.Qwen.AttentionTailStorageLineage
open Contracts.Mlx Kernels.Attention State Layers AttentionTailConstruction
set_option maxRecDepth 10000

variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {gatePlatform : OutputGate.Platform} {projection : AffineVerifyLinear.Projection 12 5120}
  (attention : SdpaShared.Execution input p contracted arch)
  (gates : ∀ head, ArrayStorage.BFBuffer (gate head))
  (shared : ∀ head, (gates head).bytes=input.cache.memory)
  (gateSafe : ∀ head, SdpaShared.Safe attention (gates head).base 512)
  (weights : AffineDevice.Storage projection) (weightShared : AffineMemory.Shared projection weights input.cache.memory)
  (r : Regions) (allocation : Allocation attention gates weights r)

theorem projection_weights_addresses :
    AffineStorageLineage.addresses projection
      (projectionWeights (gatePlatform:=gatePlatform) attention gates shared gateSafe weights weightShared r allocation)=
      AffineStorageLineage.addresses projection weights :=
  AffineStorageLineage.reframe_addresses projection weights _ _

theorem projected_addresses :
    AffineStorageLineage.addresses projection (AffineStorageLineage.launchWeights
      (projected (gatePlatform:=gatePlatform) attention gates shared gateSafe weights weightShared r allocation).affine)=
      AffineStorageLineage.addresses projection weights := by
  unfold projected AttentionOutputMemory.fromGate
  rw [AffineStorageLineage.fromStorage_addresses (steps:=12) (groups:=1280)]
  exact projection_weights_addresses attention gates shared gateSafe weights weightShared r allocation

theorem fromStorage_addresses :
    AffineStorageLineage.addresses projection (AffineStorageLineage.launchWeights
      (fromStorage (gatePlatform:=gatePlatform) attention gates shared gateSafe weights weightShared r allocation).projected.affine)=
      AffineStorageLineage.addresses projection weights :=
  projected_addresses attention gates shared gateSafe weights weightShared r allocation

end Inference.Models.Qwen.AttentionTailStorageLineage
