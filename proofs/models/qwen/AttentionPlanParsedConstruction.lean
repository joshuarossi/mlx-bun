import models.qwen.AttentionSuffixParsedConstruction
import models.qwen.ResidualAttentionConstruction
namespace Inference.Models.Qwen.AttentionPlanParsedConstruction
open Contracts.Mlx Kernels Kernels.Attention Kernels.Trellis State Layers ResidualAttentionConstruction
set_option maxRecDepth 10000
attribute [local irreducible] SdpaOutput.programs SdpaTwoPassBytes.programs Copy2DMemory.programs
  RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor
  ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany
  ResidualAttentionConstruction.tail ResidualAttentionConstruction.DispatchPlan.attention

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {original : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : ResidualAttentionConstruction.Input layer cache original angle}
  {r : ReadPlan s} {d : DispatchPlan r} {t : TailPlan r d} {a : TailAllocation t}

theorem residual_shared (r : ReadPlan s) : r.residual.bytes=r.input.cache.memory := rfl

theorem norm_shared (f : SuffixPlan t a) : f.normBeforeTail.bytes=r.input.cache.memory := rfl

def attach (f : SuffixPlan t a) (allocation : SuffixAllocation f)
    (keys : ResidualMlpConstruction.RegionsSafe allocation (tail t a).afterCache.layout.keyBase (KvRegions.bytes (n+1)))
    (values : ResidualMlpConstruction.RegionsSafe allocation (tail t a).afterCache.layout.valueBase (KvRegions.bytes (n+1)))
    (precise : Float32 → Float32) (absolute : ArrayStorage.BF → ArrayStorage.BF)
    (exponential : TrellisMlpParsedGateTail.Exponential layer.suffix.mlp.activation precise absolute)
    (inputBounded : ∀ group, (((suffix f allocation keys values).suffix).mlp.device.staging group).inputBase+10240≤2^64)
    (vector : DownFoldVectorMemory.VectorLoad) : ResidualMlpParsedTrellis.Source (suffix f allocation keys values).suffix :=
  AttentionSuffixParsedConstruction.attach (block:=layer.suffix) (tail t a) r.residual (residual_shared r) f.residualTail
    f.normBeforeTail (norm_shared f) f.normTail f.parametersBeforeTail f.parametersTailSafe allocation
    precise absolute exponential inputBounded vector

end Inference.Models.Qwen.AttentionPlanParsedConstruction
