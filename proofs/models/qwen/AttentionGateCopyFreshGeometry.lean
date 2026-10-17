import models.qwen.AttentionGateCopyFreshRead
import kernels.attention.MlxSdpaTwoPassQueryGeometry
namespace Inference.Models.Qwen.AttentionGateCopyFreshRead
open Contracts.Mlx State Kernels.Attention
set_option maxRecDepth 10000
variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache values angle}
  {p : Prepared s} (read : Read p)

theorem Read.two_pass_current_capture {blocks : Nat} {platform : SdpaVector.Platform}
    (first : SdpaTwoPassShared.Execution read.input platform blocks) (head : Fin 24)
    (block : Fin blocks) (lane : Fin 32) (item : Fin 8) :
    MlxSdpaTwoPassQueryGeometry.registers first.inputAfter.cache.memory s.front.rope.query.destination blocks head block lane item=
      ArrayStorage.bits ((layer.heads values angle).query head (SdpaScore.index lane item)) := by
  have layout : ∀ head, (first.inputAfter.query head).base=s.front.rope.query.destination+2*(head.val*256) := by
    intro head
    exact read.query_layout head
  exact MlxSdpaTwoPassQueryGeometry.captured first.inputAfter s.front.rope.query.destination blocks layout head block lane item
end Inference.Models.Qwen.AttentionGateCopyFreshRead
