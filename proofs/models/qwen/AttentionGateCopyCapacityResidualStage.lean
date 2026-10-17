import models.qwen.AttentionGateCopyCapacityTrellisEntry
namespace Inference.Models.Qwen.AttentionGateCopyCapacityResidualStage
open Contracts.Mlx Kernels.Attention Kernels.Trellis State Layers
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
attribute [local irreducible] AttentionGateCopyFreshRead.Read.input
  AttentionGateCopyCapacityTrellisEntry.suffixInput AttentionSuffixParsedConstruction.existing
  AttentionGateCopyFreshRead.Read.kv

structure Plan (layer : ResidualAttention.Layer) {n : Nat} (cache : Kv.Cache Kv.BF n)
    (x : Fin 5120 → ArrayStorage.BF) (angle : RopeAngles.Inputs) where
  input : BinaryMemory.Input x layer.inputNorm.weight
  normal : NormalizationMemory.Execution layer.inputNorm input
  front : AttentionGateCopyReadConstruction.Input layer.mixer cache (layer.inputNorm.forward x) angle
  linked : front.front.phase.q.source=NormalizationMemory.forwardBuffer normal
  preparation : AttentionGateCopyFreshRead.Prepared front
  read : AttentionGateCopyFreshRead.Read preparation
  attention : AttentionGateCopyCapacityTrellisSuffix.Attention read
  tail : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward x) angle).gate layer.mixer.gate layer.mixer.output
  original : AttentionGateCopyCapacityTrellisEntry.Input (layer:=layer) normal read attention tail
  suffix : AttentionSuffixAllocation.Plan tail
    (AttentionGateCopyCapacityTrellisSuffix.prepared read attention tail
      (AttentionGateCopyCapacityTrellisEntry.suffixInput (layer:=layer) normal linked read attention tail original))

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {x : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs} (plan : Plan layer cache x angle)

def original := AttentionGateCopyCapacityTrellisEntry.suffixInput (layer:=layer) plan.normal plan.linked plan.read plan.attention plan.tail plan.original

def prepared := AttentionGateCopyCapacityTrellisSuffix.prepared plan.read plan.attention plan.tail (original plan)

def block : AttentionResidualMemory.Execution plan.tail layer.suffix x :=
  AttentionSuffixAllocation.execution plan.tail (prepared plan) plan.suffix

def output := (block plan).output
def outputBuffer := (block plan).outputBuffer

theorem output_eq : output plan=layer.forward x angle cache := (block plan).output_eq

def forwardBuffer : ArrayStorage.BFBuffer (layer.forward x angle cache) := ArrayViews.reindex (output_eq plan) (outputBuffer plan)
def afterCache : KvRegions.Storage (layer.cacheAfter x angle cache) := (block plan).afterCache

theorem after_shared : (afterCache plan).memory=(forwardBuffer plan).bytes :=
  (block plan).cache_output_shared.trans (ArrayViews.reindex_bytes (output_eq plan) (outputBuffer plan)).symm

def Safe (base size : Nat) : Prop :=
  AttentionGateCopyCapacityTrellisEntry.Safe (layer:=layer) plan.normal base size ∧
  AttentionGateCopyCapacityTrellisFrames.Safe plan.read base size ∧ AttentionResidualMemory.Safe (block plan) base size

theorem frame {base size : Nat} (safe : Safe plan base size) (offset : Nat) (bound : offset<size) :
    (outputBuffer plan).bytes (base+offset)=plan.input.lhs.bytes (base+offset) :=
  ((block plan).other_region safe.2.2 offset bound).trans
    ((AttentionGateCopyCapacityTrellisFrames.frame plan.read safe.2.1 offset bound).trans
      ((congrFun (AttentionGateCopyCapacityTrellisEntry.shared (layer:=layer) plan.normal plan.linked).symm _).trans
        (plan.normal.other_region safe.1 offset bound)))

-- The copied prefix and parsed MLP are witnesses on this stage's exact heaps.
theorem parsed (native : TrellisParsedNative.Input (block plan).suffix) :
    TrellisParsedNative.Parsed (block plan).suffix native :=
  AttentionSuffixAllocation.parsed plan.tail (prepared plan) plan.suffix native
end Inference.Models.Qwen.AttentionGateCopyCapacityResidualStage
