import models.qwen.CopiedAttentionTailArena
import models.qwen.CopiedAttentionInitialTailFactory
import models.qwen.CopiedAttentionCapacityTailFactory
namespace Inference.Models.Qwen.CopiedAttentionTailArenaBuilt
open Contracts.Mlx Kernels.Attention State Layers
open ResidualDeltaHighWater (Before Frontier)
set_option maxRecDepth 10000
set_option maxHeartbeats 800000

namespace Initial
variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  (source : ArrayStorage.BFBuffer input) (original : DecodeParameterMemory.AttentionStorage layer source.bytes)
  (normal : NormalizationMemory.Execution layer.inputNorm ⟨source,original.norm,original.normShared⟩)
  {front : AttentionGateCopyFront.Execution layer.mixer (layer.inputNorm.forward input) angle}
  (linked : front.phase.q.source=NormalizationMemory.forwardBuffer normal)
  {cache : Kv.Cache Kv.BF 0} (read : AttentionGateCopyInitialRead.Read front cache)
  (safe : AffineMemoryFrames.Protected layer.mixer.output original.mixer.projection (CopiedAttentionInitialTailFactory.PrefixSafe source original normal read))
  (frontier : Frontier)
  (capacity : (CopiedAttentionTailArena.next frontier layer.mixer.architectureSuffix (1)).cursor≤2^64)
  (keys : Before frontier.cursor read.input.cache.layout.keyBase (KvRegions.bytes (1)))
  (values : Before frontier.cursor read.input.cache.layout.valueBase (KvRegions.bytes (1)))
  (queries : ∀ head, Before frontier.cursor (read.input.query head).base 512)
  (gates : ∀ head, Before frontier.cursor (read.gate head).base 512)
  (weights : AffineMemoryFrames.Protected layer.mixer.output original.mixer.projection (Before frontier.cursor))

include keys values queries gates weights in
theorem live : CopiedAttentionTailArena.Live read.input read.gate
    (CopiedAttentionInitialTailFactory.weights source original normal linked read safe) frontier where
  keys := keys
  values := values
  queries := queries
  gates := gates
  weights := (AffineMemoryFrames.reframe_protected _ _ _ _ _).mpr weights

def attention := CopiedAttentionTailArena.attention frontier capacity read.gate
  (CopiedAttentionInitialTailFactory.weights source original normal linked read safe)
  (live source original normal linked read safe frontier keys values queries gates weights) layer.mixer.attention layer.mixer.mergeContracted

def execution := CopiedAttentionTailArena.execution frontier capacity read.gate
  (CopiedAttentionInitialTailFactory.weights source original normal linked read safe)
  (live source original normal linked read safe frontier keys values queries gates weights) layer.mixer.attention layer.mixer.mergeContracted layer.mixer.gate
  read.gates_shared (CopiedAttentionInitialTailFactory.weights_shared source original normal linked read safe)

theorem built : CopiedAttentionInitialTailFactory.Built source original normal linked read
    (attention source original normal linked read safe frontier capacity keys values queries gates weights) (execution source original normal linked read safe frontier capacity keys values queries gates weights) :=
  CopiedAttentionInitialTailFactory.Built.construct safe
    (fun head => CopiedAttentionTailArena.attention_safe frontier capacity read.gate
      (CopiedAttentionInitialTailFactory.weights source original normal linked read safe)
      (live source original normal linked read safe frontier keys values queries gates weights) layer.mixer.attention layer.mixer.mergeContracted (gates head))
    (CopiedAttentionTailArena.tailWorkspace frontier capacity read.gate
      (CopiedAttentionInitialTailFactory.weights source original normal linked read safe)
      (live source original normal linked read safe frontier keys values queries gates weights) layer.mixer.attention layer.mixer.mergeContracted).regions
    (CopiedAttentionTailArena.tailWorkspace frontier capacity read.gate
      (CopiedAttentionInitialTailFactory.weights source original normal linked read safe)
      (live source original normal linked read safe frontier keys values queries gates weights) layer.mixer.attention layer.mixer.mergeContracted).allocation
end Initial

namespace Capacity
variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  (source : ArrayStorage.BFBuffer input) (original : DecodeParameterMemory.AttentionStorage layer source.bytes)
  (normal : NormalizationMemory.Execution layer.inputNorm ⟨source,original.norm,original.normShared⟩)
  {n : Nat} {cache : Kv.Cache Kv.BF n}
  {s : AttentionGateCopyReadConstruction.Input layer.mixer cache (layer.inputNorm.forward input) angle}
  (linked : s.front.phase.q.source=NormalizationMemory.forwardBuffer normal)
  {preparation : AttentionGateCopyFreshRead.Prepared s} (read : AttentionGateCopyFreshRead.Read preparation)
  (safe : AffineMemoryFrames.Protected layer.mixer.output original.mixer.projection (CopiedAttentionCapacityTailFactory.PrefixSafe source original normal read))
  (frontier : Frontier)
  (capacity : (CopiedAttentionTailArena.next frontier layer.mixer.architectureSuffix (n+1)).cursor≤2^64)
  (keys : Before frontier.cursor read.input.cache.layout.keyBase (KvRegions.bytes (n+1)))
  (values : Before frontier.cursor read.input.cache.layout.valueBase (KvRegions.bytes (n+1)))
  (queries : ∀ head, Before frontier.cursor (read.input.query head).base 512)
  (gates : ∀ head, Before frontier.cursor (read.gate head).base 512)
  (weights : AffineMemoryFrames.Protected layer.mixer.output original.mixer.projection (Before frontier.cursor))

include keys values queries gates weights in
theorem live : CopiedAttentionTailArena.Live read.input read.gate
    (CopiedAttentionCapacityTailFactory.weights source original normal linked read safe) frontier where
  keys := keys
  values := values
  queries := queries
  gates := gates
  weights := (AffineMemoryFrames.reframe_protected _ _ _ _ _).mpr weights

def attention := CopiedAttentionTailArena.attention frontier capacity read.gate
  (CopiedAttentionCapacityTailFactory.weights source original normal linked read safe)
  (live source original normal linked read safe frontier keys values queries gates weights) layer.mixer.attention layer.mixer.mergeContracted

def execution := CopiedAttentionTailArena.execution frontier capacity read.gate
  (CopiedAttentionCapacityTailFactory.weights source original normal linked read safe)
  (live source original normal linked read safe frontier keys values queries gates weights) layer.mixer.attention layer.mixer.mergeContracted layer.mixer.gate
  read.gates_shared (CopiedAttentionCapacityTailFactory.weights_shared source original normal linked read safe)

theorem built : CopiedAttentionCapacityTailFactory.Built source original normal linked read
    (attention source original normal linked read safe frontier capacity keys values queries gates weights) (execution source original normal linked read safe frontier capacity keys values queries gates weights) :=
  CopiedAttentionCapacityTailFactory.Built.construct safe
    (fun head => CopiedAttentionTailArena.attention_safe frontier capacity read.gate
      (CopiedAttentionCapacityTailFactory.weights source original normal linked read safe)
      (live source original normal linked read safe frontier keys values queries gates weights) layer.mixer.attention layer.mixer.mergeContracted (gates head))
    (CopiedAttentionTailArena.tailWorkspace frontier capacity read.gate
      (CopiedAttentionCapacityTailFactory.weights source original normal linked read safe)
      (live source original normal linked read safe frontier keys values queries gates weights) layer.mixer.attention layer.mixer.mergeContracted).regions
    (CopiedAttentionTailArena.tailWorkspace frontier capacity read.gate
      (CopiedAttentionCapacityTailFactory.weights source original normal linked read safe)
      (live source original normal linked read safe frontier keys values queries gates weights) layer.mixer.attention layer.mixer.mergeContracted).allocation
end Capacity
end Inference.Models.Qwen.CopiedAttentionTailArenaBuilt
