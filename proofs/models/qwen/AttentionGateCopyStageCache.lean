import models.qwen.AttentionGateCopyResidualStage
namespace Inference.Models.Qwen.AttentionGateCopyStageCache
open Contracts.Mlx Kernels.Attention State Layers
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyReadConstruction.ReadPlan.input
  AttentionGateCopyResidualStage.block AttentionGateCopyResidualStage.forwardBuffer
variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {x : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  (plan : AttentionGateCopyResidualStage.Plan layer cache x angle)

-- Cache allocations at entry retain their exact addresses and payloads through
-- input normalization. The frame can be read backwards to recover their
-- attachment to the original input heap; no new cache values are supplied.
structure Safe : Prop where
  keys : AttentionGateCopyTrellisEntry.Safe (layer:=layer) plan.normal plan.front.storage.layout.keyBase (KvRegions.bytes n)
  values : AttentionGateCopyTrellisEntry.Safe (layer:=layer) plan.normal plan.front.storage.layout.valueBase (KvRegions.bytes n)

variable (safe : Safe plan)
def before : KvRegions.Storage cache :=
  plan.front.storage.reframe plan.input.lhs.bytes
    (fun offset bound => (plan.normal.other_region safe.keys offset bound).symm.trans
      ((congrFun (AttentionGateCopyTrellisEntry.shared (layer:=layer) plan.normal plan.linked) _).trans
        (congrFun plan.front.shared _).symm))
    (fun offset bound => (plan.normal.other_region safe.values offset bound).symm.trans
      ((congrFun (AttentionGateCopyTrellisEntry.shared (layer:=layer) plan.normal plan.linked) _).trans
        (congrFun plan.front.shared _).symm))

theorem before_memory : (before plan safe).memory=plan.input.lhs.bytes := rfl
theorem before_layout : (before plan safe).layout=plan.front.storage.layout := rfl

theorem forward_frame {base size : Nat} (preserved : AttentionGateCopyResidualStage.Safe plan base size)
    (offset : Nat) (bound : offset<size) :
    (AttentionGateCopyResidualStage.forwardBuffer plan).bytes (base+offset)=plan.input.lhs.bytes (base+offset) := by
  rw [AttentionGateCopyResidualStage.forwardBuffer]
  have same := ArrayViews.reindex_bytes (AttentionGateCopyResidualStage.output_eq plan)
    (AttentionGateCopyResidualStage.outputBuffer plan)
  exact (congrFun same _).trans (AttentionGateCopyResidualStage.frame plan preserved offset bound)
end Inference.Models.Qwen.AttentionGateCopyStageCache
