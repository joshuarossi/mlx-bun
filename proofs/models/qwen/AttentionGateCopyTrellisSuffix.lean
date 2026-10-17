import models.qwen.TrellisParsedNative
import models.qwen.AttentionGateCopyTrellisFrames
import models.qwen.AttentionGateCopyParsedPipeline
import models.qwen.AttentionSuffixParsedConstruction
namespace Inference.Models.Qwen.AttentionGateCopyTrellisSuffix
open Contracts.Mlx Kernels.Attention Kernels.Trellis State Layers
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyReadConstruction.ReadPlan.input
variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache values angle}
  (read : AttentionGateCopyReadConstruction.ReadPlan s)
  (attention : AttentionGateCopyParsedDispatch.Attention read)
  (tail : AttentionTailMemory.Execution attention (layer.heads values angle).gate layer.gate layer.output)
  {x : Fin 5120 → ArrayStorage.BF} {block : ResidualBlocks.Mlp}

-- Original residual, norm and Trellis checkpoint allocations are framed through
-- all prefix copies and cache writes before the ordinary tail constructor.
structure Input where
  residual : ArrayStorage.BFBuffer x
  residualShared : residual.bytes=s.front.phase.q.source.bytes
  residualPrefix : AttentionGateCopyTrellisFrames.Safe read residual.base 10240
  residualTail : AttentionTailMemory.Safe tail residual.base 10240
  norm : ArrayStorage.BFBuffer block.norm.weight
  normShared : norm.bytes=s.front.phase.q.source.bytes
  normPrefix : AttentionGateCopyTrellisFrames.Safe read norm.base 10240
  normTail : AttentionTailMemory.Safe tail norm.base 10240
  parameters : TrellisWeightsMemory.Weights block.mlp s.front.phase.q.source.bytes
  parametersPrefix : parameters.Protected (AttentionGateCopyTrellisFrames.Safe read)
  parametersTail : (AttentionGateCopyTrellisFrames.weights read parameters parametersPrefix).Protected (AttentionTailMemory.Safe tail)

variable (original : Input read attention tail (x:=x) (block:=block))
def residual := AttentionGateCopyTrellisFrames.buffer read original.residual original.residualShared original.residualPrefix
def norm := AttentionGateCopyTrellisFrames.buffer read original.norm original.normShared original.normPrefix
def parameters := AttentionGateCopyTrellisFrames.weights read original.parameters original.parametersPrefix

theorem residual_shared : (residual read attention tail original).bytes=read.input.cache.memory :=
  AttentionGateCopyTrellisFrames.buffer_bytes read original.residual original.residualShared original.residualPrefix
theorem norm_shared : (norm read attention tail original).bytes=read.input.cache.memory :=
  AttentionGateCopyTrellisFrames.buffer_bytes read original.norm original.normShared original.normPrefix

abbrev Allocation := AttentionTailConstruction.SuffixAllocation tail (residual read attention tail original) (residual_shared read attention tail original) original.residualTail
  (norm read attention tail original) (norm_shared read attention tail original) original.normTail (parameters read attention tail original) original.parametersTail

variable (allocation : Allocation read attention tail original)
def existing := AttentionSuffixParsedConstruction.existing tail
  (residual read attention tail original) (residual_shared read attention tail original) original.residualTail
  (norm read attention tail original) (norm_shared read attention tail original) original.normTail (parameters read attention tail original) original.parametersTail allocation

def attach (native : TrellisParsedNative.Input (existing read attention tail original allocation)) :
    ResidualMlpParsedTrellis.Source (existing read attention tail original allocation) :=
  AttentionSuffixParsedConstruction.attach tail (residual read attention tail original) (residual_shared read attention tail original) original.residualTail
    (norm read attention tail original) (norm_shared read attention tail original) original.normTail (parameters read attention tail original) original.parametersTail allocation
    native.precise native.absolute native.exponential native.inputBounded native.vector

theorem parsed (native : TrellisParsedNative.Input (existing read attention tail original allocation)) :
    TrellisParsedNative.Parsed (existing read attention tail original allocation) native :=
  TrellisParsedNative.parsed _ native (attach read attention tail original allocation native) rfl rfl rfl

-- This joins, without dropping any front/copy event, the upstream parsed source
-- certificate to the suffix on its exact produced attention-tail heap.
theorem with_prefix (native : TrellisParsedNative.Input (existing read attention tail original allocation))
    (before : Nat → Float32) (upstream : AttentionGateCopyParsedPipeline.Certificate read attention tail before) :
    AttentionGateCopyParsedPipeline.Certificate read attention tail before ∧
    TrellisParsedNative.Parsed (existing read attention tail original allocation) native :=
  ⟨upstream,parsed read attention tail original allocation native⟩
theorem checked (native : TrellisParsedNative.Input (existing read attention tail original allocation))
    (before : Nat → Float32) (queryFinite : layer.projections.q.Finite values)
    (keyFinite : layer.projections.k.Finite values) (valueFinite : layer.projections.v.Finite values)
    (gateLink : tail.gates=read.gates) (supported : n+1≤262144)
    (finite : ∀ head, SdpaDispatched.Finite layer.attention layer.mergeContracted layer.architectureSuffix
      ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head)))
    (outputFinite : layer.output.Finite
      (OutputGateMemory.values layer.gate attention.output (layer.heads values angle).gate)) :
    AttentionGateCopyParsedPipeline.Certificate read attention tail before ∧
    TrellisParsedNative.Parsed (existing read attention tail original allocation) native :=
  with_prefix read attention tail original allocation native before
    (AttentionGateCopyParsedPipeline.checked read attention tail before queryFinite keyFinite valueFinite
      gateLink supported finite outputFinite)
end Inference.Models.Qwen.AttentionGateCopyTrellisSuffix
