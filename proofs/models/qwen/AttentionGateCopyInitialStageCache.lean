import models.qwen.AttentionGateCopyInitialResidualStage
import models.qwen.EmptyKvAttachment
namespace Inference.Models.Qwen.AttentionGateCopyInitialStageCache
open Contracts.Mlx Kernels.Attention State Layers
set_option maxRecDepth 10000
variable {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF 0}
  {x : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  (plan : AttentionGateCopyInitialResidualStage.Plan layer cache x angle)

def before : KvRegions.Storage cache := EmptyKvAttachment.storage cache plan.input.lhs.bytes

theorem before_memory : (before plan).memory=plan.input.lhs.bytes := rfl

theorem forward_frame {base size : Nat} (preserved : AttentionGateCopyInitialResidualStage.Safe plan base size)
    (offset : Nat) (bound : offset<size) :
    (AttentionGateCopyInitialResidualStage.forwardBuffer plan).bytes (base+offset)=plan.input.lhs.bytes (base+offset) := by
  rw [AttentionGateCopyInitialResidualStage.forwardBuffer]
  exact (congrFun (ArrayViews.reindex_bytes (AttentionGateCopyInitialResidualStage.output_eq plan)
    (AttentionGateCopyInitialResidualStage.outputBuffer plan)) _).trans
      (AttentionGateCopyInitialResidualStage.frame plan preserved offset bound)
end Inference.Models.Qwen.AttentionGateCopyInitialStageCache
