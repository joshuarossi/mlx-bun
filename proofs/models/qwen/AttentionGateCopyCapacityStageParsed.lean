import models.qwen.AttentionGateCopyCapacityStageCache
import models.qwen.AttentionGateCopyCapacityParsedPipeline
import models.qwen.AttentionGateCopyInputNormalization
namespace Inference.Models.Qwen.AttentionGateCopyCapacityStageParsed
open Contracts.Mlx Kernels.Normalization Kernels.Attention State Layers
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyFreshRead.Read.input
  AttentionGateCopyCapacityResidualStage.block AttentionGateCopyCapacityResidualStage.original

structure Native {n : Nat} {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF n}
    {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    (plan : AttentionGateCopyCapacityResidualStage.Plan layer cache input angle) where
  trellis : TrellisParsedNative.Input (AttentionGateCopyCapacityResidualStage.block plan).suffix
  before : Nat → Float32
  kernel : MlxRmsHostSelection.KernelLimit
  nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads
  scratch : M1Max.WordMemory
  inverseBefore : M1Max.WordMemory
  base : Nat
  inverseBase : Nat
  finite : layer.Finite input angle cache
  gateLink : plan.tail.gates=plan.read.gate
  supported : n+1≤262144
  growth : AttentionGateCopyPositiveSources.Inputs plan.preparation.preparation

variable {n : Nat} {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF n}
  {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  (plan : AttentionGateCopyCapacityResidualStage.Plan layer cache input angle) (native : Native plan)

structure Certificate : Prop where
  normalization : AttentionGateCopyInputNormalization.Certificate (layer:=layer) plan.normal native.kernel
    native.scratch native.inverseBefore native.base native.inverseBase
  attention : AttentionGateCopyCapacityParsedPipeline.Certificate plan.read plan.attention plan.tail native.before native.growth native.supported
  suffix : TrellisParsedNative.Parsed (AttentionGateCopyCapacityResidualStage.block plan).suffix native.trellis

theorem checked : Certificate plan native := by
  have outputFinite : layer.mixer.output.Finite
      (OutputGateMemory.values layer.mixer.gate plan.attention.output
        (layer.mixer.heads (layer.inputNorm.forward input) angle).gate) := by
    have same : plan.attention.output=layer.mixer.read (layer.inputNorm.forward input) angle cache := by
      funext head i
      exact plan.attention.output_eq head i
    rw [same]
    exact native.finite.mixer.output
  exact ⟨AttentionGateCopyInputNormalization.checked (layer:=layer) plan.normal native.kernel native.nativeThreads
      native.scratch native.inverseBefore native.base native.inverseBase,
    AttentionGateCopyCapacityParsedPipeline.checked plan.read plan.attention plan.tail native.before native.growth
      native.finite.mixer.projections.q native.finite.mixer.projections.k native.finite.mixer.projections.v
      native.gateLink native.supported native.finite.mixer.readRange outputFinite,
    AttentionGateCopyCapacityResidualStage.parsed plan native.trellis⟩
end Inference.Models.Qwen.AttentionGateCopyCapacityStageParsed
