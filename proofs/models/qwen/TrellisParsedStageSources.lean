import models.qwen.TrellisParsedStageConstruction
import models.qwen.DeltaSuffixParsedConstruction
import models.qwen.AttentionPlanParsedConstruction
namespace Inference.Models.Qwen.TrellisParsedStageSources
open Contracts.Mlx Kernels.Trellis Layers WrittenLayers
set_option maxRecDepth 10000
attribute [local irreducible] ResidualAttentionStorageConstruction.CopyAllocation.plan
  ResidualAttentionStorageConstruction.PrefixAllocation.plan ResidualAttentionStorageConstruction.CacheAllocation.input
  ResidualAttentionStorageConstruction.TailGeometry.plan ResidualAttentionStorageConstruction.SuffixGeometry.plan
  ResidualAttentionConstruction.tail ResidualAttentionConstruction.DispatchPlan.attention
  AttentionHeads.Projections.forward Blocks.Norm.forward AttentionHeads.Norm.forward ResidualMlpConstruction.RegionsSafe
abbrev BF := ArrayStorage.BF

def deltaImplementation {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → BF}
    (source : ResidualDeltaStorageConstruction.Source layer cache input) (plan : ResidualDeltaStorageConstruction.Plan source) :=
  (DeltaSuffixParsedConstruction.existing (block:=layer.suffix)
    (ResidualDeltaStorageConstruction.tailExecution source plan.preparation plan.frames plan.recurrent plan.tail.allocation)
    (ResidualDeltaStorageConstruction.residualBefore source plan.preparation plan.frames)
    (ResidualDeltaStorageConstruction.suffixSourceShared source plan.preparation plan.frames plan.recurrent) plan.tail.residualSafe
    (ResidualDeltaStorageConstruction.historyBefore source plan.preparation plan.frames)
    (ResidualDeltaStorageConstruction.historyShared source plan) plan.tail.historySafe plan.tail.historyState
    (ResidualDeltaStorageConstruction.suffixParameters source plan.preparation plan.frames plan.recurrent plan.tail)
    plan.suffix).suffix

theorem delta_implementation {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → BF}
    (source : ResidualDeltaStorageConstruction.Source layer cache input) (plan : ResidualDeltaStorageConstruction.Plan source) :
    deltaImplementation source plan=TrellisParsedStageConstruction.deltaSuffix source plan := rfl

def delta {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → BF}
    (source : ResidualDeltaStorageConstruction.Source layer cache input) (plan : ResidualDeltaStorageConstruction.Plan source)
    (precise : Float32 → Float32) (absolute : BF → BF)
    (exponential : TrellisMlpParsedGateTail.Exponential layer.suffix.mlp.activation precise absolute)
    (inputBounded : ∀ group, ((deltaImplementation source plan).mlp.device.staging group).inputBase+10240≤2^64)
    (vector : DownFoldVectorMemory.VectorLoad) : ResidualMlpParsedTrellis.Source (deltaImplementation source plan) :=
  DeltaSuffixParsedConstruction.attach (block:=layer.suffix)
    (ResidualDeltaStorageConstruction.tailExecution source plan.preparation plan.frames plan.recurrent plan.tail.allocation)
    (ResidualDeltaStorageConstruction.residualBefore source plan.preparation plan.frames)
    (ResidualDeltaStorageConstruction.suffixSourceShared source plan.preparation plan.frames plan.recurrent) plan.tail.residualSafe
    (ResidualDeltaStorageConstruction.historyBefore source plan.preparation plan.frames)
    (ResidualDeltaStorageConstruction.historyShared source plan) plan.tail.historySafe plan.tail.historyState
    (ResidualDeltaStorageConstruction.suffixParameters source plan.preparation plan.frames plan.recurrent plan.tail)
    plan.suffix precise absolute exponential inputBounded vector

def attention {layer : ResidualAttention.Layer} {cache : State.Kv.Cache State.Kv.BF n}
    {input : Fin 5120 → BF} {angle : Kernels.Attention.RopeAngles.Inputs}
    {source : ResidualAttentionStorageConstruction.Source layer cache input}
    (plan : ResidualAttentionStorageConstruction.Plan source angle)
    (precise : Float32 → Float32) (absolute : BF → BF)
    (exponential : TrellisMlpParsedGateTail.Exponential layer.suffix.mlp.activation precise absolute)
    (inputBounded : ∀ group, ((TrellisParsedStageConstruction.attentionSuffix plan).mlp.device.staging group).inputBase+10240≤2^64)
    (vector : DownFoldVectorMemory.VectorLoad) : ResidualMlpParsedTrellis.Source (TrellisParsedStageConstruction.attentionSuffix plan) :=
  AttentionPlanParsedConstruction.attach plan.body.tailPlan.finish.1.plan plan.body.tailPlan.finish.2.val
    plan.body.tailPlan.finish.2.property.1 plan.body.tailPlan.finish.2.property.2
    precise absolute exponential inputBounded vector

end Inference.Models.Qwen.TrellisParsedStageSources
