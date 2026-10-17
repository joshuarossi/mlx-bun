import models.qwen.ResidualMlpParsedConstruction
import models.qwen.TrellisParsedNative
import models.qwen.AttentionTailConstruction
import models.qwen.AttentionSuffixParsedConstruction
namespace Inference.Models.Qwen.AttentionSuffixParsedNative
open Contracts.Mlx Kernels.Attention Kernels.Trellis State Layers
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF
variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {attention : SdpaShared.Execution input p contracted arch} {gatePlatform : OutputGate.Platform}
  {projection : AffineVerifyLinear.Projection 12 5120} {x : Fin 5120 → BF} {block : ResidualBlocks.Mlp}
  (tail : AttentionTailMemory.Execution attention gate gatePlatform projection)
  (source : ArrayStorage.BFBuffer x) (sourceShared : source.bytes=input.cache.memory)
  (sourceSafe : AttentionTailMemory.Safe tail source.base 10240)
  (normWeights : ArrayStorage.BFBuffer block.norm.weight) (normShared : normWeights.bytes=input.cache.memory)
  (normSafe : AttentionTailMemory.Safe tail normWeights.base 10240)
  (parameters : TrellisWeightsMemory.Weights block.mlp input.cache.memory)
  (parameterSafe : parameters.Protected (AttentionTailMemory.Safe tail))
  (allocation : AttentionTailConstruction.SuffixAllocation tail source sourceShared sourceSafe normWeights normShared normSafe parameters parameterSafe)

variable (native : TrellisParsedNative.Input
  (AttentionSuffixParsedConstruction.existing tail source sourceShared sourceSafe normWeights normShared normSafe parameters parameterSafe allocation))

theorem checked : TrellisParsedNative.Parsed
    (AttentionSuffixParsedConstruction.existing tail source sourceShared sourceSafe normWeights normShared normSafe parameters parameterSafe allocation) native :=
  TrellisParsedNative.parsed _ native
    (AttentionSuffixParsedConstruction.attach tail source sourceShared sourceSafe normWeights normShared normSafe parameters parameterSafe allocation
      native.precise native.absolute native.exponential native.inputBounded native.vector) rfl rfl rfl
end Inference.Models.Qwen.AttentionSuffixParsedNative
