import models.qwen.CapacityAttentionDecodeStage
import models.qwen.AttentionGateCopyCapacityStageParsed
import models.qwen.DeltaParsedConstructedStage
namespace Inference.Models.Qwen.CapacityAttentionStageParsed
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
set_option maxRecDepth 10000
variable {n : Nat}
abbrev AttentionNative {n : Nat} {layer : ResidualAttention.Layer} {cache : State.Kv.Cache State.Kv.BF n}
    {input : Row BF} {angle : RopeAngles.Inputs}
    (plan : AttentionGateCopyCapacityResidualStage.Plan layer cache input angle) :=
  AttentionGateCopyCapacityStageParsed.Native plan

structure DeltaNative (execution : CapacityAttentionDecodeStage.Delta layer cache input) where
  selected : DeltaParsedConstructedStage.Native execution.1 execution.2
  finite : layer.Finite cache (fun _ => input) 0

def Native : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    CapacityAttentionDecodeStage.Execution kind cache input angle → Type
  | .delta _, _, _, _, execution => DeltaNative execution
  | .attention _, _, _, _, execution => AttentionNative execution.val

def Parsed : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (execution : CapacityAttentionDecodeStage.Execution kind cache input angle) → Native kind cache input angle execution → Prop
  | .delta _, _, _, _, execution, native => DeltaParsedConstructedStage.Certificate execution.1 execution.2 native.selected
  | .attention _, _, _, _, execution, native => AttentionGateCopyCapacityStageParsed.Certificate execution.val native

theorem checked (kind : Stage) (cache : Cache kind n) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : CapacityAttentionDecodeStage.Execution kind cache input angle)
    (native : Native kind cache input angle execution) : Parsed kind cache input angle execution native := by
  cases kind with
  | delta _ => exact DeltaParsedConstructedStage.checked execution.1 execution.2 native.selected native.finite
  | attention _ => exact AttentionGateCopyCapacityStageParsed.checked execution.val native
end Inference.Models.Qwen.CapacityAttentionStageParsed
