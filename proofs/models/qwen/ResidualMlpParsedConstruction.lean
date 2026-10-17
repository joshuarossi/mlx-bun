import models.qwen.TrellisParsedParameterAttachment
import models.qwen.ResidualMlpConstruction
namespace Inference.Models.Qwen.ResidualMlpParsedConstruction
open Contracts.Mlx Contracts.Mlx.M1Max Kernels.Trellis WrittenLayers
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF
variable {x update : Fin 5120 → BF} {block : ResidualBlocks.Mlp}
  (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
  (shared : weights.bytes=input.lhs.bytes) (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes)
  (allocation : ResidualMlpConstruction.Allocation input weights shared parameters)

def existing := ResidualMlpConstruction.fromStorage input weights shared parameters allocation

def attachedWeights : TrellisWeightsMemory.Weights block.mlp
    (existing input weights shared parameters allocation).mlp.source.bytes :=
  (ResidualMlpConstruction.parameterExecution input weights shared parameters allocation).weights

theorem attachedSafe : (attachedWeights input weights shared parameters allocation).Protected
    (TrellisMlpMemory.Safe (existing input weights shared parameters allocation).mlp) :=
  (ResidualMlpConstruction.parameterExecution input weights shared parameters allocation).safe

-- Only native primitives and a shared-address range remain supplied. All
-- packed data, model equalities and current-heap links come from the plan.
def source (precise : Float32 → Float32) (absolute : BF → BF)
    (exponential : TrellisMlpParsedGateTail.Exponential block.mlp.activation precise absolute)
    (inputBounded : ∀ group, ((existing input weights shared parameters allocation).mlp.device.staging group).inputBase+10240≤2^64)
    (vector : DownFoldVectorMemory.VectorLoad) : ResidualMlpParsedTrellis.Source (existing input weights shared parameters allocation) :=
  TrellisParsedParameterAttachment.source _ (attachedWeights input weights shared parameters allocation)
    (attachedSafe input weights shared parameters allocation) precise absolute exponential inputBounded vector

theorem ready (precise : Float32 → Float32) (absolute : BF → BF)
    (exponential : TrellisMlpParsedGateTail.Exponential block.mlp.activation precise absolute)
    (inputBounded : ∀ group, ((existing input weights shared parameters allocation).mlp.device.staging group).inputBase+10240≤2^64)
    (vector : DownFoldVectorMemory.VectorLoad) :
    let e := existing input weights shared parameters allocation
    let s := source input weights shared parameters allocation precise absolute exponential inputBounded vector
    TrellisMlpParsedPipeline.Ready (ResidualMlpParsedTrellis.branch e s) (ResidualMlpParsedTrellis.gate e s) vector :=
  ResidualMlpParsedTrellis.ready _ _

end Inference.Models.Qwen.ResidualMlpParsedConstruction
