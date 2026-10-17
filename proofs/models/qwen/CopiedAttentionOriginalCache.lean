import models.qwen.CopiedAttentionOriginalBundle
import models.qwen.AttentionGateCopyReadConstruction
namespace Inference.Models.Qwen.CopiedAttentionOriginalCache
open Contracts.Mlx Layers Kernels Kernels.Attention State
set_option maxRecDepth 10000
variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  (source : ArrayStorage.BFBuffer input)
  (original : DecodeParameterMemory.AttentionStorage layer source.bytes)
  (normal : NormalizationMemory.Execution layer.inputNorm ⟨source,original.norm,original.normShared⟩)
  (safe : original.Protected (MemoryRegions.Disjoint (2*normal.normalized.base) 10240))
  {live : Nat → Nat → Prop} (regions : original.Protected live)
  (plan : CopiedAttentionProjectionConstruction.Plan layer.mixer.projections
    (NormalizationMemory.forwardBuffer normal) (CopiedAttentionOriginalBundle.normalized source original normal safe).projections live)
  (allocation : CopiedAttentionParameterConstruction.QueryAllocation
    (CopiedAttentionOriginalBundle.normalized source original normal safe).projections plan)
  (angle : RopeAngles.Inputs)
  (native : CopiedAttentionFrontConstruction.Native
    (CopiedAttentionOriginalBundle.normalized source original normal safe).projections plan allocation
    (CopiedAttentionOriginalBundle.normalized source original normal safe).mixer
    (CopiedAttentionOriginalBundle.current_regions source original normal safe regions).2.2.1 angle)
  {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache) (shared : storage.memory=source.bytes)
  (keysNormal : MemoryRegions.Disjoint (2*normal.normalized.base) 10240 storage.layout.keyBase (KvRegions.bytes n))
  (valuesNormal : MemoryRegions.Disjoint (2*normal.normalized.base) 10240 storage.layout.valueBase (KvRegions.bytes n))

def normalizedCache : KvRegions.Storage cache := storage.reframe (NormalizationMemory.forwardBuffer normal).bytes
  (fun offset bound => (CopiedAttentionOriginalBundle.normalization_frame source original normal keysNormal offset bound).trans (congrFun shared _).symm)
  (fun offset bound => (CopiedAttentionOriginalBundle.normalization_frame source original normal valuesNormal offset bound).trans (congrFun shared _).symm)

variable
  (keysSafe : AttentionGateCopyFront.Safe
    (CopiedAttentionOriginalBundle.front source original normal safe regions plan allocation angle native)
    storage.layout.keyBase (KvRegions.bytes n))
  (valuesSafe : AttentionGateCopyFront.Safe
    (CopiedAttentionOriginalBundle.front source original normal safe regions plan allocation angle native)
    storage.layout.valueBase (KvRegions.bytes n))

def readInput : AttentionGateCopyReadConstruction.Input layer.mixer cache (layer.inputNorm.forward input) angle where
  front := CopiedAttentionOriginalBundle.front source original normal safe regions plan allocation angle native
  storage := normalizedCache source original normal storage shared keysNormal valuesNormal
  shared := (congrArg ArrayStorage.BFBuffer.bytes
    (CopiedAttentionOriginalBundle.front_input source original normal safe regions plan allocation angle native)).symm
  keysSafe := keysSafe
  valuesSafe := valuesSafe

theorem input_front : (readInput source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe).front=
    CopiedAttentionOriginalBundle.front source original normal safe regions plan allocation angle native := rfl
end Inference.Models.Qwen.CopiedAttentionOriginalCache
