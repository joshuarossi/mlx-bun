import models.qwen.TrellisParsedParameterChain
import models.qwen.Qwen38TrellisM1Max
namespace Inference.Models.Qwen.Qwen38TrellisParsedLayers
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Qwen38TrellisM1Max
set_option maxRecDepth 10000
attribute [local irreducible] Graph.stages

variable (graph : Graph) (cache : graph.Cache n) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage graph.stages cache source.bytes)
  (parameters : DecodeParameterMemory.Storage graph.stages source.bytes)
  (plan : DecodeParameterConstruction.ChainPlan graph.stages .root cache input angle source storage parameters)

-- All 64 residual MLP attachments use this exact model's dependent layer chain.
-- Its 48 Delta and 16 attention allocations share the constructor's current
-- heaps and original checkpoint parameter bundle, including all reframings.
theorem parsed_layers
    (native : TrellisParsedParameterChain.Native graph.stages .root cache input angle source storage parameters plan) :
    TrellisParsedParameterChain.Parsed graph.stages .root cache input angle source storage parameters plan native ∧
    graph.stages.length=64 ∧ (graph.stages.filter isAttention).length=16 ∧
    (graph.stages.filter (fun stage => !isAttention stage)).length=48 :=
  ⟨TrellisParsedParameterChain.parsed graph.stages .root cache input angle source storage parameters plan native,
    graph.layer_count,graph.attention_count,graph.delta_count⟩

-- Reading the very same constructed heap retains the existing model equation;
-- no alternative trace or replacement stage output is introduced by parsing.
theorem read_hidden
    (safe : DecodeParameterConstruction.CacheRegions graph.stages .root cache input angle source storage parameters plan)
    (native : TrellisParsedParameterChain.Native graph.stages .root cache input angle source storage parameters plan) :
    TrellisParsedParameterChain.Parsed graph.stages .root cache input angle source storage parameters plan native ∧
    DecodeParameterConstruction.readResult graph.stages .root cache input angle source storage parameters plan safe=
      DecodeChain.run graph.stages cache input angle :=
  ⟨TrellisParsedParameterChain.parsed graph.stages .root cache input angle source storage parameters plan native,
    DecodeParameterConstruction.read_result_eq graph.stages .root cache input angle source storage parameters plan safe⟩
end Inference.Models.Qwen.Qwen38TrellisParsedLayers
