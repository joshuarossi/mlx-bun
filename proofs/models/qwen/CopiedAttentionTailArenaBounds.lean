import models.qwen.CopiedAttentionTailArena
namespace Inference.Models.Qwen.CopiedAttentionTailArenaBounds
open Contracts.Mlx Kernels.Attention State Layers
open ResidualDeltaHighWater (Before Frontier)
set_option maxRecDepth 10000
set_option maxHeartbeats 800000

variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {arch : Char}
  {projection : AffineVerifyLinear.Projection 12 5120}
  (frontier : Frontier) (capacity : (CopiedAttentionTailArena.next frontier arch steps).cursor≤2^64)
  (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (weights : AffineDevice.Storage projection)
  (live : CopiedAttentionTailArena.Live input gates weights frontier)
  (platform : SdpaVector.Platform) (contracted : Bool) (gatePlatform : OutputGate.Platform)
  (shared : ∀ head, (gates head).bytes=input.cache.memory)
  (weightShared : AffineMemory.Shared projection weights input.cache.memory)

private theorem affine_base {steps groups : Nat} {p : AffineVerifyLinear.Projection steps (4*groups)}
    {values : Fin (steps*512) → ArrayStorage.BF} (e : AffineMemory.Execution p values) :
    e.outputBuffer.base=e.base := by cases p <;> rfl

theorem output_base :
    (CopiedAttentionTailArena.execution frontier capacity gates weights live platform contracted gatePlatform shared weightShared).buffer.base=
      frontier.cursor+SdpaWorkspace.bytes (SdpaDispatched.blockCount arch steps)+24576 := by
  change (CopiedAttentionTailArena.execution frontier capacity gates weights live platform contracted gatePlatform shared weightShared).projected.affine.outputBuffer.base=_
  rw [affine_base]
  exact AttentionTailConstruction.projected_base _ _ _ _ _ _ _ _

theorem output_bound : Before (CopiedAttentionTailArena.next frontier arch steps).cursor
    (CopiedAttentionTailArena.execution frontier capacity gates weights live platform contracted gatePlatform shared weightShared).buffer.base 10240 := by
  rw [output_base]
  dsimp [Before,CopiedAttentionTailArena.next,CopiedAttentionTailArena.bytes,AttentionTailAllocation.bytes]
  omega

theorem cache_bounds :
    Before (CopiedAttentionTailArena.next frontier arch steps).cursor
      (CopiedAttentionTailArena.execution frontier capacity gates weights live platform contracted gatePlatform shared weightShared).afterCache.layout.keyBase (KvRegions.bytes steps) ∧
    Before (CopiedAttentionTailArena.next frontier arch steps).cursor
      (CopiedAttentionTailArena.execution frontier capacity gates weights live platform contracted gatePlatform shared weightShared).afterCache.layout.valueBase (KvRegions.bytes steps) := by
  rw [AttentionTailMemory.Execution.cache_layout]
  have keys := live.keys
  have values := live.values
  dsimp [Before,CopiedAttentionTailArena.next] at *
  constructor <;> omega

end Inference.Models.Qwen.CopiedAttentionTailArenaBounds
