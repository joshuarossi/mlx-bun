import models.qwen.CopiedAttentionDecodeStage
import models.qwen.TrellisParsedStageSources
import models.qwen.TrellisParsedNative
import models.qwen.DeltaParsedConstructedStage
import models.qwen.AttentionGateCopyInputNormalization
namespace Inference.Models.Qwen.CopiedAttentionStageParsed
open Contracts.Mlx Kernels.Normalization Layers DecodeStage DecodeChain Kernels.Attention
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyReadConstruction.ReadPlan.input AttentionGateCopyResidualStage.block
  AttentionGateCopyResidualStage.original

structure AttentionNative {n : Nat} {layer : ResidualAttention.Layer} {cache : State.Kv.Cache State.Kv.BF n}
    {input : Row BF} {angle : RopeAngles.Inputs}
    (plan : AttentionGateCopyResidualStage.Plan layer cache input angle) where
  trellis : TrellisParsedNative.Input (AttentionGateCopyResidualStage.block plan).suffix
  before : Nat → Float32
  kernel : MlxRmsHostSelection.KernelLimit
  nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads
  scratch : M1Max.WordMemory
  inverseBefore : M1Max.WordMemory
  base : Nat
  inverseBase : Nat
  finite : layer.Finite input angle cache
  gateLink : plan.tail.gates=plan.read.gates
  supported : n+1≤262144

structure DeltaNative (execution : CopiedAttentionDecodeStage.Delta layer cache input) where
  selected : DeltaParsedConstructedStage.Native execution.1 execution.2
  finite : layer.Finite cache (fun _ => input) 0

-- Each source statement certificate is constructed from the retained execution
-- and model ranges. Only primitive/native inputs occur in this interface.
def Native : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    CopiedAttentionDecodeStage.Execution kind cache input angle → Type
  | .delta _, _, _, _, execution => DeltaNative execution
  | .attention _, _, _, _, execution => AttentionNative execution.val

def Parsed : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (execution : CopiedAttentionDecodeStage.Execution kind cache input angle) → Native kind cache input angle execution → Prop
  | .delta _, _, _, _, execution, native => DeltaParsedConstructedStage.Certificate execution.1 execution.2 native.selected
  | .attention layer, _, _, _, execution, native =>
      AttentionGateCopyInputNormalization.Certificate (layer:=layer) execution.val.normal native.kernel native.scratch native.inverseBefore native.base native.inverseBase ∧
      AttentionGateCopyParsedPipeline.Certificate execution.val.read execution.val.attention execution.val.tail native.before ∧
      TrellisParsedNative.Parsed (AttentionGateCopyResidualStage.block execution.val).suffix native.trellis

theorem checked (kind : Stage) (cache : Cache kind n) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : CopiedAttentionDecodeStage.Execution kind cache input angle)
    (native : Native kind cache input angle execution) : Parsed kind cache input angle execution native := by
  cases kind with
  | delta layer => exact DeltaParsedConstructedStage.checked execution.1 execution.2 native.selected native.finite
  | attention layer =>
    have outputFinite : layer.mixer.output.Finite
        (OutputGateMemory.values layer.mixer.gate execution.val.attention.output
          (layer.mixer.heads (layer.inputNorm.forward input) angle).gate) := by
      have same : execution.val.attention.output=layer.mixer.read (layer.inputNorm.forward input) angle cache := by
        funext head i
        exact execution.val.attention.output_eq head i
      rw [same]
      exact native.finite.mixer.output
    refine ⟨AttentionGateCopyInputNormalization.checked (layer:=layer) execution.val.normal native.kernel native.nativeThreads
      native.scratch native.inverseBefore native.base native.inverseBase,?_⟩
    exact ⟨AttentionGateCopyParsedPipeline.checked execution.val.read execution.val.attention execution.val.tail native.before
      native.finite.mixer.projections.q native.finite.mixer.projections.k native.finite.mixer.projections.v
      native.gateLink native.supported native.finite.mixer.readRange outputFinite,
      AttentionGateCopyResidualStage.parsed execution.val native.trellis⟩
end Inference.Models.Qwen.CopiedAttentionStageParsed
