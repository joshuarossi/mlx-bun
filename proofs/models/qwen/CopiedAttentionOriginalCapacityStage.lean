import models.qwen.CopiedAttentionOriginalCache
import models.qwen.AttentionGateCopyCapacityResidualStage
namespace Inference.Models.Qwen.CopiedAttentionOriginalCapacityStage
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

structure Regions {angle : RopeAngles.Inputs} {n : Nat} {cache : Kv.Cache Kv.BF n} (source : ArrayStorage.BFBuffer input)
    (original : DecodeParameterMemory.AttentionStorage layer source.bytes)
    (normal : NormalizationMemory.Execution layer.inputNorm ⟨source,original.norm,original.normShared⟩)
    {upstream : AttentionGateCopyReadConstruction.Input layer.mixer cache (layer.inputNorm.forward input) angle}
    {preparation : AttentionGateCopyFreshRead.Prepared upstream}
    (read : AttentionGateCopyFreshRead.Read preparation)
    (attention : AttentionGateCopyCapacityTrellisSuffix.Attention read)
    (tail : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward input) angle).gate layer.mixer.gate layer.mixer.output) : Prop where
  residualNormal : AttentionGateCopyCapacityTrellisEntry.Safe normal source.base 10240
  residualPrefix : AttentionGateCopyCapacityTrellisFrames.Safe read source.base 10240
  residualTail : AttentionTailMemory.Safe tail source.base 10240
  suffixPrefix : original.suffix.Protected (AttentionGateCopyCapacityTrellisFrames.Safe read)
  suffixTail : original.suffix.Protected (AttentionTailMemory.Safe tail)

variable (geometry : Regions source original normal read attention tail)
def entry : AttentionGateCopyCapacityTrellisEntry.Input normal read attention tail where
  residualNormal := geometry.residualNormal
  residualPrefix := geometry.residualPrefix
  residualTail := geometry.residualTail
  norm := original.suffix.norm
  normShared := original.suffix.normShared
  normNormal := safe.2.2.2.1
  normPrefix := geometry.suffixPrefix.1
  normTail := geometry.suffixTail.1
  parameters := original.suffix.trellis
  parametersNormal := safe.2.2.2.2
  parametersPrefix := geometry.suffixPrefix.2
  parametersTail := geometry.suffixTail.2

theorem entry_norm : (entry source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe preparation read attention tail geometry).norm=original.suffix.norm := rfl

theorem entry_parameters : (entry source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe preparation read attention tail geometry).parameters=original.suffix.trellis := rfl

def prepared := AttentionGateCopyCapacityTrellisSuffix.prepared read attention tail
  (AttentionGateCopyCapacityTrellisEntry.suffixInput (layer:=layer) normal
    (CopiedAttentionOriginalBundle.front_input source original normal safe regions plan allocation angle native)
    read attention tail (entry source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe preparation read attention tail geometry))

variable (suffix : AttentionSuffixAllocation.Plan tail
  (prepared source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe preparation read attention tail geometry))
def stage : AttentionGateCopyCapacityResidualStage.Plan layer cache input angle where
  input := ⟨source,original.norm,original.normShared⟩
  normal := normal
  front := upstream source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe
  preparation := preparation
  linked := CopiedAttentionOriginalBundle.front_input source original normal safe regions plan allocation angle native
  read := read
  attention := attention
  tail := tail
  original := entry source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe preparation read attention tail geometry
  suffix := suffix

theorem stage_input :
    (stage source original normal safe regions plan allocation angle native storage shared keysNormal valuesNormal keysSafe valuesSafe preparation read attention tail geometry suffix).input.lhs=source := rfl
end Inference.Models.Qwen.CopiedAttentionOriginalCapacityStage
