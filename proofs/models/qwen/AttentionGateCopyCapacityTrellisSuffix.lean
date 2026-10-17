import models.qwen.AttentionSuffixAllocation
import models.qwen.TrellisParsedNative
import models.qwen.AttentionSuffixParsedNative
import models.qwen.TrellisWeightsFrameRegions
import models.qwen.AttentionGateCopyCapacityTrellisFrames
import models.qwen.AttentionSuffixParsedConstruction
namespace Inference.Models.Qwen.AttentionGateCopyCapacityTrellisSuffix
open Contracts.Mlx Kernels.Attention Kernels.Trellis State Layers
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyFreshRead.Read.input AttentionGateCopyFreshRead.Read.kv
 AttentionSuffixParsedConstruction.existing
abbrev Attention {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
    {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {s : AttentionGateCopyReadConstruction.Input layer cache values angle}
    {preparation : AttentionGateCopyFreshRead.Prepared s} (read : AttentionGateCopyFreshRead.Read preparation) :=
  SdpaShared.Execution read.input layer.attention layer.mergeContracted layer.architectureSuffix

variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache values angle}
    {preparation : AttentionGateCopyFreshRead.Prepared s}
  (read : AttentionGateCopyFreshRead.Read preparation) (attention : Attention read)
  (tail : AttentionTailMemory.Execution attention (layer.heads values angle).gate layer.gate layer.output)
  {x : Fin 5120 → ArrayStorage.BF} {block : ResidualBlocks.Mlp}

-- Original residual, norm and Trellis checkpoint allocations are framed through
-- all prefix copies and cache writes before the ordinary tail constructor.
structure Input where
  residual : ArrayStorage.BFBuffer x
  residualShared : residual.bytes=s.front.phase.q.source.bytes
  residualPrefix : AttentionGateCopyCapacityTrellisFrames.Safe read residual.base 10240
  residualTail : AttentionTailMemory.Safe tail residual.base 10240
  norm : ArrayStorage.BFBuffer block.norm.weight
  normShared : norm.bytes=s.front.phase.q.source.bytes
  normPrefix : AttentionGateCopyCapacityTrellisFrames.Safe read norm.base 10240
  normTail : AttentionTailMemory.Safe tail norm.base 10240
  parameters : TrellisWeightsMemory.Weights block.mlp s.front.phase.q.source.bytes
  parametersPrefix : parameters.Protected (AttentionGateCopyCapacityTrellisFrames.Safe read)
  parametersTail : parameters.Protected (AttentionTailMemory.Safe tail)

variable (original : Input read attention tail (x:=x) (block:=block))
def residual := AttentionGateCopyCapacityTrellisFrames.buffer read original.residual original.residualShared original.residualPrefix
def norm := AttentionGateCopyCapacityTrellisFrames.buffer read original.norm original.normShared original.normPrefix
def parameters := AttentionGateCopyCapacityTrellisFrames.weights read original.parameters original.parametersPrefix

theorem residual_shared : (residual read attention tail original).bytes=read.input.cache.memory :=
  AttentionGateCopyCapacityTrellisFrames.buffer_bytes read original.residual original.residualShared original.residualPrefix
theorem norm_shared : (norm read attention tail original).bytes=read.input.cache.memory :=
  AttentionGateCopyCapacityTrellisFrames.buffer_bytes read original.norm original.normShared original.normPrefix

theorem parameters_tail : (parameters read attention tail original).Protected (AttentionTailMemory.Safe tail) :=
  (TrellisWeightsFrameRegions.regions original.parameters read.input.cache.memory
    (original.parameters.protected_mono (fun _ _ region => AttentionGateCopyCapacityTrellisFrames.frame read region) original.parametersPrefix)
    (AttentionTailMemory.Safe tail)).mpr original.parametersTail

def prepared : AttentionSuffixAllocation.Input tail (x:=x) (block:=block) where
  source := residual read attention tail original
  shared := residual_shared read attention tail original
  safe := original.residualTail
  norm := norm read attention tail original
  normShared := norm_shared read attention tail original
  normSafe := original.normTail
  parameters := parameters read attention tail original
  parametersSafe := parameters_tail read attention tail original

abbrev Plan := AttentionSuffixAllocation.Plan tail (prepared read attention tail original)

def execution (plan : Plan read attention tail original) :=
  AttentionSuffixAllocation.execution tail (prepared read attention tail original) plan

theorem parsed (plan : Plan read attention tail original)
    (native : TrellisParsedNative.Input (execution read attention tail original plan).suffix) :
    TrellisParsedNative.Parsed (execution read attention tail original plan).suffix native :=
  AttentionSuffixAllocation.parsed tail (prepared read attention tail original) plan native
end Inference.Models.Qwen.AttentionGateCopyCapacityTrellisSuffix
