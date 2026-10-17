import models.qwen.AttentionGateCopyCapacityResidualStage
namespace Inference.Models.Qwen.AttentionGateCopyCapacityStageCache
open Contracts.Mlx Kernels.Attention State Layers
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyFreshRead.Read.input
  AttentionGateCopyCapacityResidualStage.block AttentionGateCopyCapacityResidualStage.forwardBuffer
variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {x : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  (plan : AttentionGateCopyCapacityResidualStage.Plan layer cache x angle)

-- Cache allocations at entry retain their exact addresses and payloads through
-- input normalization. The frame can be read backwards to recover their
-- attachment to the original input heap; no new cache values are supplied.
structure Safe : Prop where
  keys : AttentionGateCopyCapacityTrellisEntry.Safe (layer:=layer) plan.normal plan.front.storage.layout.keyBase (KvRegions.bytes n)
  values : AttentionGateCopyCapacityTrellisEntry.Safe (layer:=layer) plan.normal plan.front.storage.layout.valueBase (KvRegions.bytes n)

variable (safe : Safe plan)
def before : KvRegions.Storage cache :=
  plan.front.storage.reframe plan.input.lhs.bytes
    (fun offset bound => (plan.normal.other_region safe.keys offset bound).symm.trans
      ((congrFun (AttentionGateCopyCapacityTrellisEntry.shared (layer:=layer) plan.normal plan.linked) _).trans
        (congrFun plan.front.shared _).symm))
    (fun offset bound => (plan.normal.other_region safe.values offset bound).symm.trans
      ((congrFun (AttentionGateCopyCapacityTrellisEntry.shared (layer:=layer) plan.normal plan.linked) _).trans
        (congrFun plan.front.shared _).symm))

theorem before_memory : (before plan safe).memory=plan.input.lhs.bytes := rfl
theorem before_layout : (before plan safe).layout=plan.front.storage.layout := rfl

theorem forward_frame {base size : Nat} (preserved : AttentionGateCopyCapacityResidualStage.Safe plan base size)
    (offset : Nat) (bound : offset<size) :
    (AttentionGateCopyCapacityResidualStage.forwardBuffer plan).bytes (base+offset)=plan.input.lhs.bytes (base+offset) := by
  rw [AttentionGateCopyCapacityResidualStage.forwardBuffer]
  have same := ArrayViews.reindex_bytes (AttentionGateCopyCapacityResidualStage.output_eq plan)
    (AttentionGateCopyCapacityResidualStage.outputBuffer plan)
  exact (congrFun same _).trans (AttentionGateCopyCapacityResidualStage.frame plan preserved offset bound)
end Inference.Models.Qwen.AttentionGateCopyCapacityStageCache
