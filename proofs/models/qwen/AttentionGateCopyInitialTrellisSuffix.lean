import models.qwen.TrellisParsedNative
import models.qwen.AttentionSuffixParsedNative
import models.qwen.TrellisWeightsFrameRegions
import models.qwen.AttentionGateCopyInitialTrellisFrames
import models.qwen.AttentionSuffixParsedConstruction
namespace Inference.Models.Qwen.AttentionGateCopyInitialTrellisSuffix
open Contracts.Mlx Kernels.Attention Kernels.Trellis State Layers
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyInitialRead.Read.input AttentionGateCopyInitialRead.Read.kv
  AttentionGateCopyInitialRead.fromFront AttentionSuffixParsedConstruction.existing
abbrev Attention {layer : Attention.Layer} {cache : Kv.Cache Kv.BF 0}
    {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {front : AttentionGateCopyFront.Execution layer values angle} (read : AttentionGateCopyInitialRead.Read front cache) :=
  SdpaShared.Execution read.input layer.attention layer.mergeContracted layer.architectureSuffix

variable {layer : Attention.Layer} {cache : Kv.Cache Kv.BF 0}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {front : AttentionGateCopyFront.Execution layer values angle}
  (read : AttentionGateCopyInitialRead.Read front cache) (attention : Attention read)
  (tail : AttentionTailMemory.Execution attention (layer.heads values angle).gate layer.gate layer.output)
  {x : Fin 5120 → ArrayStorage.BF} {block : ResidualBlocks.Mlp}

-- Original residual, norm and Trellis checkpoint allocations are framed through
-- all prefix copies and cache writes before the ordinary tail constructor.
structure Input where
  residual : ArrayStorage.BFBuffer x
  residualShared : residual.bytes=front.phase.q.source.bytes
  residualPrefix : AttentionGateCopyInitialTrellisFrames.Safe read residual.base 10240
  residualTail : AttentionTailMemory.Safe tail residual.base 10240
  norm : ArrayStorage.BFBuffer block.norm.weight
  normShared : norm.bytes=front.phase.q.source.bytes
  normPrefix : AttentionGateCopyInitialTrellisFrames.Safe read norm.base 10240
  normTail : AttentionTailMemory.Safe tail norm.base 10240
  parameters : TrellisWeightsMemory.Weights block.mlp front.phase.q.source.bytes
  parametersPrefix : parameters.Protected (AttentionGateCopyInitialTrellisFrames.Safe read)
  parametersTail : parameters.Protected (AttentionTailMemory.Safe tail)

variable (original : Input read attention tail (x:=x) (block:=block))
def residual := AttentionGateCopyInitialTrellisFrames.buffer read original.residual original.residualShared original.residualPrefix
def norm := AttentionGateCopyInitialTrellisFrames.buffer read original.norm original.normShared original.normPrefix
def parameters := AttentionGateCopyInitialTrellisFrames.weights read original.parameters original.parametersPrefix

theorem residual_shared : (residual read attention tail original).bytes=read.input.cache.memory :=
  AttentionGateCopyInitialTrellisFrames.buffer_bytes read original.residual original.residualShared original.residualPrefix
theorem norm_shared : (norm read attention tail original).bytes=read.input.cache.memory :=
  AttentionGateCopyInitialTrellisFrames.buffer_bytes read original.norm original.normShared original.normPrefix

theorem parameters_tail : (parameters read attention tail original).Protected (AttentionTailMemory.Safe tail) :=
  (TrellisWeightsFrameRegions.regions original.parameters read.input.cache.memory
    (original.parameters.protected_mono (fun _ _ region => AttentionGateCopyInitialTrellisFrames.frame read region) original.parametersPrefix)
    (AttentionTailMemory.Safe tail)).mpr original.parametersTail

abbrev Allocation := AttentionTailConstruction.SuffixAllocation (steps:=1) (query:=(layer.heads values angle).query) (cache:=layer.cacheAfter values angle cache)
    (input:=read.input) (p:=layer.attention) (contracted:=layer.mergeContracted) (arch:=layer.architectureSuffix)
    (attention:=attention) (gate:=(layer.heads values angle).gate) (gatePlatform:=layer.gate) (projection:=layer.output) (x:=x) (block:=block) tail (residual read attention tail original) (residual_shared read attention tail original) original.residualTail
  (norm read attention tail original) (norm_shared read attention tail original) original.normTail (parameters read attention tail original) (parameters_tail read attention tail original)

variable (allocation : Allocation read attention tail original)
abbrev existing := AttentionSuffixParsedConstruction.existing (steps:=1) (query:=(layer.heads values angle).query) (cache:=layer.cacheAfter values angle cache)
    (input:=read.input) (p:=layer.attention) (contracted:=layer.mergeContracted) (arch:=layer.architectureSuffix)
    (attention:=attention) (gate:=(layer.heads values angle).gate) (gatePlatform:=layer.gate) (projection:=layer.output) (x:=x) (block:=block) tail
  (residual read attention tail original) (residual_shared read attention tail original) original.residualTail
  (norm read attention tail original) (norm_shared read attention tail original) original.normTail (parameters read attention tail original) (parameters_tail read attention tail original) allocation

theorem parsed (native : TrellisParsedNative.Input (existing read attention tail original allocation)) :
    TrellisParsedNative.Parsed (existing read attention tail original allocation) native :=
  AttentionSuffixParsedNative.checked (steps:=1) (query:=(layer.heads values angle).query) (cache:=layer.cacheAfter values angle cache)
    (input:=read.input) (p:=layer.attention) (contracted:=layer.mergeContracted) (arch:=layer.architectureSuffix)
    (attention:=attention) (gate:=(layer.heads values angle).gate) (gatePlatform:=layer.gate) (projection:=layer.output) (x:=x) (block:=block) tail
    (residual read attention tail original) (residual_shared read attention tail original) original.residualTail
    (norm read attention tail original) (norm_shared read attention tail original) original.normTail
    (parameters read attention tail original) (parameters_tail read attention tail original) allocation native

end Inference.Models.Qwen.AttentionGateCopyInitialTrellisSuffix
