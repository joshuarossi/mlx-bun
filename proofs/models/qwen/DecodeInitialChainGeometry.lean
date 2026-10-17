import models.qwen.DecodeInitialMemoryChain
import models.qwen.DecodeCacheGeometry
import models.qwen.ResidualDeltaHighWater

namespace Inference.Models.Qwen.DecodeInitialChainGeometry
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
open ResidualDeltaHighWater (Before)
set_option maxRecDepth 10000

def After (cursor base _size : Nat) : Prop := cursor≤base

section Chain
variable {kind : Stage} {rest : List Stage}
  (cache : Caches (kind::rest) 0) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (kind::rest) cache source.bytes)
  (trace : DecodeInitialMemoryChain.Trace (kind::rest) cache input angle source storage)
  (safe : DecodeInitialMemoryChain.CacheSafe (kind::rest) cache input angle source storage trace)

theorem after_regions :
    DecodeCacheGeometry.regions (kind::rest) (DecodeChain.run (kind::rest) cache input angle).2 _
      (DecodeInitialMemoryChain.after (kind::rest) cache input angle source storage trace safe)=
    DecodeCacheGeometry.stageRegions kind (cacheAfter kind cache.1 input angle) trace.1.first.cacheAfter.storage ++
      DecodeCacheGeometry.regions rest (DecodeChain.run rest cache.2 (forward kind cache.1 input angle) angle).2 _
        (DecodeInitialMemoryChain.after rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 safe.2) := by
  simp only [DecodeCacheGeometry.regions,DecodeInitialMemoryChain.after,DecodeChain.run,
    DecodeCacheGeometry.stage_reframe_regions,DecodeInitialMemoryChain.outputBuffer]


theorem after_lower (cursor : Nat)
    (head : DecodePreservation.StageProtected (After cursor) kind (cacheAfter kind cache.1 input angle) trace.1.first.cacheAfter.storage)
    (tail : DecodePreservation.Protected (After cursor) rest (DecodeChain.run rest cache.2 (forward kind cache.1 input angle) angle).2 _
      (DecodeInitialMemoryChain.after rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 safe.2)) :
    DecodePreservation.Protected (After cursor) (kind::rest) (DecodeChain.run (kind::rest) cache input angle).2 _
      (DecodeInitialMemoryChain.after (kind::rest) cache input angle source storage trace safe) := by
  apply (DecodeCacheGeometry.protected_iff _ _ _ _ _).mpr
  rw [after_regions]
  intro region member
  rcases List.mem_append.mp member with first|second
  · exact (DecodeCacheGeometry.stage_protected_iff _ _ _ _).mp head region first
  · exact (DecodeCacheGeometry.protected_iff _ _ _ _ _).mp tail region second

theorem after_pairwise (cursor : Nat)
    (head : DecodePreservation.StageProtected (Before cursor) kind (cacheAfter kind cache.1 input angle) trace.1.first.cacheAfter.storage)
    (tail : DecodePreservation.Protected (After cursor) rest (DecodeChain.run rest cache.2 (forward kind cache.1 input angle) angle).2 _
      (DecodeInitialMemoryChain.after rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 safe.2))
    (tailPairwise : DecodeCacheGeometry.Pairwise rest (DecodeChain.run rest cache.2 (forward kind cache.1 input angle) angle).2 _
      (DecodeInitialMemoryChain.after rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 safe.2)) :
    DecodeCacheGeometry.Pairwise (kind::rest) (DecodeChain.run (kind::rest) cache input angle).2 _
      (DecodeInitialMemoryChain.after (kind::rest) cache input angle source storage trace safe) := by
  unfold DecodeCacheGeometry.Pairwise
  rw [after_regions]
  apply List.pairwise_append.mpr
  refine ⟨DecodeCacheGeometry.stage_pairwise _ _ _,tailPairwise,?_⟩
  intro first firstMember second secondMember
  have upper := (DecodeCacheGeometry.stage_protected_iff _ _ _ _).mp head first firstMember
  have lower := (DecodeCacheGeometry.protected_iff _ _ _ _ _).mp tail second secondMember
  exact Or.inl (upper.trans lower)

end Chain


end Inference.Models.Qwen.DecodeInitialChainGeometry
