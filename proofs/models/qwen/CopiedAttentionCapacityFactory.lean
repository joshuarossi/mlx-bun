import models.qwen.CopiedAttentionOriginalCapacityStage
namespace Inference.Models.Qwen.CopiedAttentionCapacityFactory
open Contracts.Mlx Layers Kernels Kernels.Attention State
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
attribute [local irreducible] CopiedAttentionOriginalBundle.front CopiedAttentionOriginalBundle.normalized
  CopiedAttentionOriginalCache.readInput CopiedAttentionOriginalCapacityStage.prepared
structure Plan (layer : ResidualAttention.Layer) {n : Nat} (cache : Kv.Cache Kv.BF n)
    (input : Fin 5120 → ArrayStorage.BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (storage : KvRegions.Storage cache) (shared : storage.memory=source.bytes)
    (original : DecodeParameterMemory.AttentionStorage layer source.bytes) where
  normal : NormalizationMemory.Execution layer.inputNorm ⟨source,original.norm,original.normShared⟩
  safe : original.Protected (MemoryRegions.Disjoint (2*normal.normalized.base) 10240)
  live : Nat → Nat → Prop
  regions : original.Protected live
  projections : CopiedAttentionProjectionConstruction.Plan (input:=layer.inputNorm.forward input) layer.mixer.projections
    (NormalizationMemory.forwardBuffer normal) (CopiedAttentionOriginalBundle.normalized (layer:=layer) source original normal safe).projections live
  queryCopy : CopiedAttentionParameterConstruction.QueryAllocation (layer:=layer.mixer)
    (CopiedAttentionOriginalBundle.normalized (layer:=layer) source original normal safe).projections projections
  native : CopiedAttentionFrontConstruction.Native (layer:=layer.mixer)
    (CopiedAttentionOriginalBundle.normalized (layer:=layer) source original normal safe).projections projections queryCopy
    (CopiedAttentionOriginalBundle.normalized (layer:=layer) source original normal safe).mixer
    (CopiedAttentionOriginalBundle.current_regions (layer:=layer) source original normal safe regions).2.2.1 angle
  keysNormal : MemoryRegions.Disjoint (2*normal.normalized.base) 10240 storage.layout.keyBase (KvRegions.bytes n)
  valuesNormal : MemoryRegions.Disjoint (2*normal.normalized.base) 10240 storage.layout.valueBase (KvRegions.bytes n)
  keysSafe : AttentionGateCopyFront.Safe
    (CopiedAttentionOriginalBundle.front (layer:=layer) source original normal safe regions projections queryCopy angle native)
    storage.layout.keyBase (KvRegions.bytes n)
  valuesSafe : AttentionGateCopyFront.Safe
    (CopiedAttentionOriginalBundle.front (layer:=layer) source original normal safe regions projections queryCopy angle native)
    storage.layout.valueBase (KvRegions.bytes n)
  preparation : AttentionGateCopyFreshRead.Prepared
    (CopiedAttentionOriginalCache.readInput source original normal safe regions projections queryCopy angle native
      storage shared keysNormal valuesNormal keysSafe valuesSafe)
  read : AttentionGateCopyFreshRead.Read preparation
  attention : AttentionGateCopyCapacityTrellisSuffix.Attention (layer:=layer.mixer) read
  tail : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward input) angle).gate layer.mixer.gate layer.mixer.output
  geometry : CopiedAttentionOriginalCapacityStage.Regions (layer:=layer) source original normal read attention tail
  suffix : AttentionSuffixAllocation.Plan tail
    (CopiedAttentionOriginalCapacityStage.prepared (layer:=layer) source original normal safe regions projections queryCopy angle native storage shared keysNormal valuesNormal keysSafe valuesSafe preparation read attention tail geometry)

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
  {storage : KvRegions.Storage cache} {shared : storage.memory=source.bytes}
  {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  (plan : Plan layer cache input angle source storage shared original)
def stage : AttentionGateCopyCapacityResidualStage.Plan layer cache input angle :=
  CopiedAttentionOriginalCapacityStage.stage source original plan.normal plan.safe plan.regions plan.projections plan.queryCopy angle
    plan.native storage shared plan.keysNormal plan.valuesNormal plan.keysSafe plan.valuesSafe plan.preparation plan.read plan.attention plan.tail plan.geometry plan.suffix

theorem input_source : (stage plan).input.lhs=source := rfl
theorem normalization_weights : (stage plan).input.rhs=original.norm := rfl
theorem suffix_weights : (stage plan).original.parameters=original.suffix.trellis := rfl
end Inference.Models.Qwen.CopiedAttentionCapacityFactory
