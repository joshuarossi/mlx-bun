import models.qwen.CopiedAttentionInitialFactory
import models.qwen.AttentionTailConstruction
namespace Inference.Models.Qwen.CopiedAttentionInitialTailFactory
open Contracts.Mlx Layers Kernels.Attention State
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] AttentionGateCopyInitialRead.Read.input
variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  (source : ArrayStorage.BFBuffer input) (original : DecodeParameterMemory.AttentionStorage layer source.bytes)
  (normal : NormalizationMemory.Execution layer.inputNorm ⟨source,original.norm,original.normShared⟩)
  {front : AttentionGateCopyFront.Execution layer.mixer (layer.inputNorm.forward input) angle}
  (linked : front.phase.q.source=NormalizationMemory.forwardBuffer normal)
  {cache : Kv.Cache Kv.BF 0} (read : AttentionGateCopyInitialRead.Read front cache)
  (attention : AttentionGateCopyInitialTrellisSuffix.Attention read)

def PrefixSafe (base size : Nat) : Prop :=
  MemoryRegions.Disjoint (2*normal.normalized.base) 10240 base size ∧ AttentionGateCopyInitialTrellisFrames.Safe read base size

include linked in
theorem frame (safe : PrefixSafe source original normal read base size) (offset : Nat) (bound : offset<size) :
    read.input.cache.memory (base+offset)=source.bytes (base+offset) :=
  (AttentionGateCopyInitialTrellisFrames.frame read safe.2 offset bound).trans
    ((congrFun (congrArg ArrayStorage.BFBuffer.bytes linked) _).trans
      (CopiedAttentionOriginalBundle.normalization_frame source original normal safe.1 offset bound))

def weights (safe : AffineMemoryFrames.Protected layer.mixer.output original.mixer.projection (PrefixSafe source original normal read)) :
    AffineDevice.Storage layer.mixer.output :=
  AffineMemoryFrames.reframe layer.mixer.output original.mixer.projection read.input.cache.memory
    (AffineMemoryFrames.stable _ _ source.bytes _ original.mixer.projectionShared
      (AffineMemoryFrames.protected_mono _ _ (fun _ _ region => frame source original normal linked read region) safe))

theorem weights_shared (safe : AffineMemoryFrames.Protected layer.mixer.output original.mixer.projection (PrefixSafe source original normal read)) :
    AffineMemory.Shared layer.mixer.output (weights source original normal linked read safe) read.input.cache.memory :=
  AffineMemoryFrames.reframe_shared _ _ _ _

variable (safe : AffineMemoryFrames.Protected layer.mixer.output original.mixer.projection (PrefixSafe source original normal read))
  (gateSafe : ∀ head, SdpaShared.Safe attention (read.gate head).base 512)
  (regions : AttentionTailConstruction.Regions)
  (allocation : AttentionTailConstruction.Allocation attention read.gate (weights source original normal linked read safe) regions)

def execution : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward input) angle).gate layer.mixer.gate layer.mixer.output :=
  AttentionTailConstruction.fromStorage attention read.gate read.gates_shared gateSafe
    (weights source original normal linked read safe) (weights_shared source original normal linked read safe) regions allocation

theorem gates : (execution source original normal linked read attention safe gateSafe regions allocation).gates=read.gate := rfl

-- An indexed constructor image: no equality to a requested tail/result is
-- supplied. Its only constructor builds the tail from geometry and originals.
inductive Built : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward input) angle).gate layer.mixer.gate layer.mixer.output → Prop where
  | construct (safe : AffineMemoryFrames.Protected layer.mixer.output original.mixer.projection (PrefixSafe source original normal read))
      (gateSafe : ∀ head, SdpaShared.Safe attention (read.gate head).base 512)
      (regions : AttentionTailConstruction.Regions)
      (allocation : AttentionTailConstruction.Allocation attention read.gate (weights source original normal linked read safe) regions) :
      Built (execution source original normal linked read attention safe gateSafe regions allocation)

def InitialBuilt (plan : CopiedAttentionInitialFactory.Plan layer cache input angle source original) : Prop :=
  Built source original plan.normal
    (CopiedAttentionOriginalBundle.front_input source original plan.normal plan.safe plan.regions plan.projections plan.queryCopy angle plan.native)
    plan.read plan.attention plan.tail
end Inference.Models.Qwen.CopiedAttentionInitialTailFactory
