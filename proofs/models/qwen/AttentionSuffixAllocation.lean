import models.qwen.AttentionSuffixParsedNative
namespace Inference.Models.Qwen.AttentionSuffixAllocation
open Contracts.Mlx Kernels.Attention State Layers
set_option maxRecDepth 10000
variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {attention : SdpaShared.Execution input p contracted arch} {gatePlatform : OutputGate.Platform}
  {projection : AffineVerifyLinear.Projection 12 5120} {x : Fin 5120 → ArrayStorage.BF} {block : ResidualBlocks.Mlp}
  (tail : AttentionTailMemory.Execution attention gate gatePlatform projection)

structure Input where
  source : ArrayStorage.BFBuffer x
  shared : source.bytes=input.cache.memory
  safe : AttentionTailMemory.Safe tail source.base 10240
  norm : ArrayStorage.BFBuffer block.norm.weight
  normShared : norm.bytes=input.cache.memory
  normSafe : AttentionTailMemory.Safe tail norm.base 10240
  parameters : TrellisWeightsMemory.Weights block.mlp input.cache.memory
  parametersSafe : parameters.Protected (AttentionTailMemory.Safe tail)

variable (prepared : Input tail (x:=x) (block:=block))
def existing (allocation : AttentionTailConstruction.SuffixAllocation tail prepared.source prepared.shared prepared.safe
    prepared.norm prepared.normShared prepared.normSafe prepared.parameters prepared.parametersSafe) :=
  AttentionSuffixParsedConstruction.existing tail prepared.source prepared.shared prepared.safe
    prepared.norm prepared.normShared prepared.normSafe prepared.parameters prepared.parametersSafe allocation

structure Plan where
  allocation : AttentionTailConstruction.SuffixAllocation tail prepared.source prepared.shared prepared.safe
    prepared.norm prepared.normShared prepared.normSafe prepared.parameters prepared.parametersSafe
  keys : ResidualMlpMemory.Safe (existing tail prepared allocation) tail.afterCache.layout.keyBase (KvRegions.bytes steps)
  values : ResidualMlpMemory.Safe (existing tail prepared allocation) tail.afterCache.layout.valueBase (KvRegions.bytes steps)

variable (plan : Plan tail prepared)
def execution : AttentionResidualMemory.Execution tail block x :=
  AttentionResidualMemory.fromSuffix tail block prepared.source prepared.shared prepared.safe
    (existing tail prepared plan.allocation) plan.keys plan.values

theorem parsed (native : TrellisParsedNative.Input (execution tail prepared plan).suffix) :
    TrellisParsedNative.Parsed (execution tail prepared plan).suffix native :=
  AttentionSuffixParsedNative.checked tail prepared.source prepared.shared prepared.safe prepared.norm prepared.normShared
    prepared.normSafe prepared.parameters prepared.parametersSafe plan.allocation native
end Inference.Models.Qwen.AttentionSuffixAllocation
