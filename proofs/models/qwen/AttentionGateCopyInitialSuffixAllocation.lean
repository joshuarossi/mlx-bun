import models.qwen.AttentionGateCopyInitialTrellisSuffix
import models.qwen.AttentionSuffixAllocation
namespace Inference.Models.Qwen.AttentionGateCopyInitialSuffixAllocation
open Contracts.Mlx Kernels.Attention State Layers
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyInitialRead.Read.input AttentionGateCopyInitialRead.Read.kv
variable {layer : Attention.Layer} {cache : Kv.Cache Kv.BF 0}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {front : AttentionGateCopyFront.Execution layer values angle}
  (read : AttentionGateCopyInitialRead.Read front cache)
  (attention : AttentionGateCopyInitialTrellisSuffix.Attention read)
  (tail : AttentionTailMemory.Execution attention (layer.heads values angle).gate layer.gate layer.output)
  {x : Fin 5120 → ArrayStorage.BF} {block : ResidualBlocks.Mlp}
  (original : AttentionGateCopyInitialTrellisSuffix.Input read attention tail (x:=x) (block:=block))

def prepared : AttentionSuffixAllocation.Input tail (x:=x) (block:=block) where
  source := AttentionGateCopyInitialTrellisSuffix.residual read attention tail original
  shared := AttentionGateCopyInitialTrellisSuffix.residual_shared read attention tail original
  safe := original.residualTail
  norm := AttentionGateCopyInitialTrellisSuffix.norm read attention tail original
  normShared := AttentionGateCopyInitialTrellisSuffix.norm_shared read attention tail original
  normSafe := original.normTail
  parameters := AttentionGateCopyInitialTrellisSuffix.parameters read attention tail original
  parametersSafe := AttentionGateCopyInitialTrellisSuffix.parameters_tail read attention tail original
theorem current_heap : (prepared read attention tail original).source.bytes=read.input.cache.memory :=
  (prepared read attention tail original).shared
end Inference.Models.Qwen.AttentionGateCopyInitialSuffixAllocation
