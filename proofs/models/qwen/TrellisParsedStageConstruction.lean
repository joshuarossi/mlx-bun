import models.qwen.ResidualMlpParsedConstruction
import models.qwen.DecodeParameterConstruction
namespace Inference.Models.Qwen.TrellisParsedStageConstruction
open Contracts.Mlx Kernels.Trellis Layers
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF

def deltaSuffix {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → BF}
    (source : ResidualDeltaStorageConstruction.Source layer cache input)
    (plan : ResidualDeltaStorageConstruction.Plan source) :=
  (ResidualDeltaStorageConstruction.suffixExecution source plan).suffix

theorem delta_suffix {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → BF}
    (source : ResidualDeltaStorageConstruction.Source layer cache input)
    (plan : ResidualDeltaStorageConstruction.Plan source) :
    (ResidualDeltaStorageConstruction.fromStorage source plan).block.suffix.suffix=deltaSuffix source plan := rfl

def attentionSuffix {layer : ResidualAttention.Layer} {cache : State.Kv.Cache State.Kv.BF n}
    {input : Fin 5120 → BF} {angle : Kernels.Attention.RopeAngles.Inputs}
    {source : ResidualAttentionStorageConstruction.Source layer cache input}
    (plan : ResidualAttentionStorageConstruction.Plan source angle) :=
  (ResidualAttentionConstruction.suffix plan.body.tailPlan.finish.1.plan plan.body.tailPlan.finish.2.val
    plan.body.tailPlan.finish.2.property.1 plan.body.tailPlan.finish.2.property.2).suffix

theorem attention_suffix {layer : ResidualAttention.Layer} {cache : State.Kv.Cache State.Kv.BF n}
    {input : Fin 5120 → BF} {angle : Kernels.Attention.RopeAngles.Inputs}
    {source : ResidualAttentionStorageConstruction.Source layer cache input}
    (plan : ResidualAttentionStorageConstruction.Plan source angle) :
    (ResidualAttentionStorageConstruction.fromStorage plan).block.suffix.suffix=attentionSuffix plan := rfl

end Inference.Models.Qwen.TrellisParsedStageConstruction
