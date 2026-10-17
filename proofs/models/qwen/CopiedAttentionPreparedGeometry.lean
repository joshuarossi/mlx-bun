import models.qwen.CopiedAttentionOriginalInitialStage
import models.qwen.CopiedAttentionOriginalCapacityStage

namespace Inference.Models.Qwen.CopiedAttentionPreparedGeometry
open Contracts.Mlx Layers Kernels Kernels.Attention State
set_option maxRecDepth 10000
attribute [local irreducible] CopiedAttentionOriginalBundle.front CopiedAttentionOriginalBundle.normalized
  AttentionGateCopyInitialRead.Read.input AttentionGateCopyFreshRead.Read.input

namespace Initial
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

abbrev front := CopiedAttentionOriginalBundle.front source original normal safe regions plan allocation angle native
variable {cache : Kv.Cache Kv.BF 0}
  (read : AttentionGateCopyInitialRead.Read (front source original normal safe regions plan allocation angle native) cache)
  (attention : AttentionGateCopyInitialTrellisSuffix.Attention read)
  (tail : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward input) angle).gate layer.mixer.gate layer.mixer.output)


variable (geometry : CopiedAttentionOriginalInitialStage.Regions source original normal read attention tail)

theorem source_base : (CopiedAttentionOriginalInitialStage.prepared source original normal safe regions plan allocation angle native read attention tail geometry).source.base=source.base := rfl

theorem norm_base : (CopiedAttentionOriginalInitialStage.prepared source original normal safe regions plan allocation angle native read attention tail geometry).norm.base=original.suffix.norm.base := rfl

theorem parameters_regions (property : Nat → Nat → Prop) :
    (CopiedAttentionOriginalInitialStage.prepared source original normal safe regions plan allocation angle native read attention tail geometry).parameters.Protected property ↔ original.suffix.trellis.Protected property := Iff.rfl
end Initial

namespace Capacity
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

abbrev front := CopiedAttentionOriginalBundle.front source original normal safe regions plan allocation angle native
variable {n : Nat} {cache : Kv.Cache Kv.BF n}
  (storage : KvRegions.Storage cache) (shared : storage.memory=source.bytes)
  (keysNormal : MemoryRegions.Disjoint (2*normal.normalized.base) 10240 storage.layout.keyBase (KvRegions.bytes n))
  (valuesNormal : MemoryRegions.Disjoint (2*normal.normalized.base) 10240 storage.layout.valueBase (KvRegions.bytes n))
  (keysSafe : AttentionGateCopyFront.Safe (front source original normal safe regions plan allocation angle native) storage.layout.keyBase (KvRegions.bytes n))
  (valuesSafe : AttentionGateCopyFront.Safe (front source original normal safe regions plan allocation angle native) storage.layout.valueBase (KvRegions.bytes n))
abbrev upstream := CopiedAttentionOriginalCache.readInput source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe
variable
  (preparation : AttentionGateCopyFreshRead.Prepared (upstream source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe))
  (read : AttentionGateCopyFreshRead.Read preparation)
  (attention : AttentionGateCopyCapacityTrellisSuffix.Attention read)
  (tail : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward input) angle).gate layer.mixer.gate layer.mixer.output)


variable (geometry : CopiedAttentionOriginalCapacityStage.Regions source original normal read attention tail)

theorem source_base : (CopiedAttentionOriginalCapacityStage.prepared source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe preparation read attention tail geometry).source.base=source.base := rfl

theorem norm_base : (CopiedAttentionOriginalCapacityStage.prepared source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe preparation read attention tail geometry).norm.base=original.suffix.norm.base := rfl

theorem parameters_regions (property : Nat → Nat → Prop) :
    (CopiedAttentionOriginalCapacityStage.prepared source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe preparation read attention tail geometry).parameters.Protected property ↔ original.suffix.trellis.Protected property := Iff.rfl
end Capacity

end Inference.Models.Qwen.CopiedAttentionPreparedGeometry
