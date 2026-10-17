import models.qwen.ResidualMlpParsedConstruction
import models.qwen.AttentionTailConstruction
namespace Inference.Models.Qwen.AttentionSuffixParsedConstruction
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

def existing := AttentionTailConstruction.suffix tail source sourceShared sourceSafe normWeights normShared normSafe parameters parameterSafe allocation

def attach (precise : Float32 → Float32) (absolute : BF → BF)
    (exponential : TrellisMlpParsedGateTail.Exponential block.mlp.activation precise absolute)
    (inputBounded : ∀ group, ((existing tail source sourceShared sourceSafe normWeights normShared normSafe parameters parameterSafe allocation).mlp.device.staging group).inputBase+10240≤2^64)
    (vector : DownFoldVectorMemory.VectorLoad) :
    ResidualMlpParsedTrellis.Source (existing tail source sourceShared sourceSafe normWeights normShared normSafe parameters parameterSafe allocation) :=
  ResidualMlpParsedConstruction.source (block:=block) (AttentionResidualMemory.residualInput tail source sourceShared sourceSafe)
    (AttentionTailConstruction.normAfterTail tail normWeights normShared normSafe) rfl
    (AttentionTailConstruction.mlpAfterTail tail parameters parameterSafe) allocation precise absolute exponential inputBounded vector

end Inference.Models.Qwen.AttentionSuffixParsedConstruction
