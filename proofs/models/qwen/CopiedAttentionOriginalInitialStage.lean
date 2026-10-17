import models.qwen.CopiedAttentionOriginalBundle
import models.qwen.AttentionGateCopyInitialResidualStage
namespace Inference.Models.Qwen.CopiedAttentionOriginalInitialStage
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
variable {cache : Kv.Cache Kv.BF 0}
  (read : AttentionGateCopyInitialRead.Read (front source original normal safe regions plan allocation angle native) cache)
  (attention : AttentionGateCopyInitialTrellisSuffix.Attention read)
  (tail : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward input) angle).gate layer.mixer.gate layer.mixer.output)

structure Regions {angle : RopeAngles.Inputs} {cache : Kv.Cache Kv.BF 0} (source : ArrayStorage.BFBuffer input)
    (original : DecodeParameterMemory.AttentionStorage layer source.bytes)
    (normal : NormalizationMemory.Execution layer.inputNorm ⟨source,original.norm,original.normShared⟩)
    {front : AttentionGateCopyFront.Execution layer.mixer (layer.inputNorm.forward input) angle}
    (read : AttentionGateCopyInitialRead.Read front cache)
    (attention : AttentionGateCopyInitialTrellisSuffix.Attention read)
    (tail : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward input) angle).gate layer.mixer.gate layer.mixer.output) : Prop where
  residualNormal : AttentionGateCopyInitialTrellisEntry.Safe normal source.base 10240
  residualPrefix : AttentionGateCopyInitialTrellisFrames.Safe read source.base 10240
  residualTail : AttentionTailMemory.Safe tail source.base 10240
  suffixPrefix : original.suffix.Protected (AttentionGateCopyInitialTrellisFrames.Safe read)
  suffixTail : original.suffix.Protected (AttentionTailMemory.Safe tail)

variable (geometry : Regions source original normal read attention tail)
def entry : AttentionGateCopyInitialTrellisEntry.Input normal read attention tail where
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

theorem entry_norm : (entry source original normal safe regions plan allocation angle native read attention tail geometry).norm=original.suffix.norm := rfl

theorem entry_parameters : (entry source original normal safe regions plan allocation angle native read attention tail geometry).parameters=original.suffix.trellis := rfl

def prepared := AttentionGateCopyInitialSuffixAllocation.prepared read attention tail
  (AttentionGateCopyInitialTrellisEntry.suffixInput (layer:=layer) normal
    (CopiedAttentionOriginalBundle.front_input source original normal safe regions plan allocation angle native)
    read attention tail (entry source original normal safe regions plan allocation angle native read attention tail geometry))

variable (suffix : AttentionSuffixAllocation.Plan tail
  (prepared source original normal safe regions plan allocation angle native read attention tail geometry))
def stage : AttentionGateCopyInitialResidualStage.Plan layer cache input angle where
  input := ⟨source,original.norm,original.normShared⟩
  normal := normal
  front := front source original normal safe regions plan allocation angle native
  linked := CopiedAttentionOriginalBundle.front_input source original normal safe regions plan allocation angle native
  read := read
  attention := attention
  tail := tail
  original := entry source original normal safe regions plan allocation angle native read attention tail geometry
  suffix := suffix

theorem stage_input :
    (stage source original normal safe regions plan allocation angle native read attention tail geometry suffix).input.lhs=source := rfl
end Inference.Models.Qwen.CopiedAttentionOriginalInitialStage
