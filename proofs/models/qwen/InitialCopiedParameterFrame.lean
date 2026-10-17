import models.qwen.InitialCopiedParameterConstruction
import models.qwen.DecodeParameterCombine
namespace Inference.Models.Qwen.InitialCopiedParameterFrame
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
open DecodeParameterConstruction (Cursor)
open InitialCopiedParameterConstruction
set_option maxRecDepth 10000

private theorem affine_true (p : AffineVerifyLinear.Projection steps rows) (w : AffineDevice.Storage p) :
    AffineMemoryFrames.Protected p w (fun _ _ => True) := by cases p <;> exact ⟨True.intro,True.intro,True.intro⟩
private theorem stage_true (kind : Stage) (w : DecodeParameterMemory.StageStorage kind memory) :
    DecodeParameterMemory.StageProtected kind w (fun _ _ => True) := by
  cases kind <;> simp [DecodeParameterMemory.StageProtected,DecodeParameterMemory.DeltaStorage.Protected,
    DecodeParameterMemory.AttentionStorage.Protected,DeltaNormalizedConstruction.Protected,
    AttentionNormalizedConstruction.Protected,DeltaParameterMemory.Protected,AttentionParameterMemory.Protected,
    ResidualDeltaConstruction.MlpWeights.Protected,TrellisWeightsMemory.Weights.Protected,affine_true]
private theorem all_true : (stages : List Stage) → (w : DecodeParameterMemory.Storage stages memory) →
    DecodeParameterMemory.Protected stages w (fun _ _ => True)
  | [], _ => True.intro
  | kind::rest, w => ⟨stage_true kind w.1,all_true rest w.2⟩

theorem protected_chain : (stages : List Stage) → (cursor : Cursor all stages) → (cache : Caches stages 0) →
    (input : Row BF) → (angle : RopeAngles.Inputs) → (source : ArrayStorage.BFBuffer input) →
    (storage : DecodeFrame.Storage stages cache source.bytes) → (parameters : DecodeParameterMemory.Storage all source.bytes) →
    (plan : ChainPlan stages cursor cache input angle source storage parameters) →
    DecodeParameterMemory.Protected all parameters
      (InitialCopiedDecodeChain.Safe stages cache input angle source storage (chain stages cursor cache input angle source storage parameters plan))
  | [], _, _, _, _, _, _, parameters, _ =>
    all_true all parameters
  | kind::rest, cursor, cache, input, angle, source, storage, parameters, plan => by
    have later := protected_chain rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle
      plan.1.step.first.buffer plan.1.step.nextStorage plan.1.nextParameters plan.2
    have originalLater := (DecodeParameterMemory.reframe_protected all parameters _ plan.1.parameterFrame _).mp later
    exact DecodeParameterCombine.all (fun _ _ first second => ⟨first,second⟩) all parameters plan.1.parametersSafe originalLater


theorem parameter_bytes (stages : List Stage) (cursor : Cursor all stages) (cache : Caches stages 0)
    (input : Row BF) (angle : RopeAngles.Inputs) (source : ArrayStorage.BFBuffer input)
    (storage : DecodeFrame.Storage stages cache source.bytes) (parameters : DecodeParameterMemory.Storage all source.bytes)
    (plan : ChainPlan stages cursor cache input angle source storage parameters) :
    DecodeParameterMemory.Protected all parameters (fun base size => ∀ offset<size,
      (outputBuffer stages cursor cache input angle source storage parameters plan).bytes (base+offset)=source.bytes (base+offset)) :=
  DecodeParameterMemory.protected_mono all parameters
    (fun base size safe => InitialCopiedDecodeChain.other_region stages cache input angle source storage
      (chain stages cursor cache input angle source storage parameters plan) base size safe)
    (protected_chain stages cursor cache input angle source storage parameters plan)

-- Additional readonly spans (embedding or final normalization/head) can be
-- threaded through the same actual steps without extending the frozen plan.
def RegionPath : (stages : List Stage) → (cursor : Cursor all stages) → (cache : Caches stages 0) →
    (input : Row BF) → (angle : RopeAngles.Inputs) → (source : ArrayStorage.BFBuffer input) →
    (storage : DecodeFrame.Storage stages cache source.bytes) → (parameters : DecodeParameterMemory.Storage all source.bytes) →
    ChainPlan stages cursor cache input angle source storage parameters → (Nat → Nat → Prop) → Prop
  | [], _, _, _, _, _, _, _, _, _ => True
  | kind::rest, cursor, cache, input, angle, _, _, _, plan, property =>
    (∀ base size, property base size → plan.1.step.first.Safe base size) ∧
      RegionPath rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer
        plan.1.step.nextStorage plan.1.nextParameters plan.2 property

theorem path_safe : (stages : List Stage) → (cursor : Cursor all stages) → (cache : Caches stages 0) →
    (input : Row BF) → (angle : RopeAngles.Inputs) → (source : ArrayStorage.BFBuffer input) →
    (storage : DecodeFrame.Storage stages cache source.bytes) → (parameters : DecodeParameterMemory.Storage all source.bytes) →
    (plan : ChainPlan stages cursor cache input angle source storage parameters) → (property : Nat → Nat → Prop) →
    RegionPath stages cursor cache input angle source storage parameters plan property → ∀ base size, property base size →
      InitialCopiedDecodeChain.Safe stages cache input angle source storage (chain stages cursor cache input angle source storage parameters plan) base size
  | [], _, _, _, _, _, _, _, _, _, _, _, _, _ => True.intro
  | kind::rest, cursor, cache, input, angle, _, _, _, plan, property, path, base, size, region =>
    ⟨path.1 base size region,path_safe rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle
      plan.1.step.first.buffer plan.1.step.nextStorage plan.1.nextParameters plan.2 property path.2 base size region⟩
end Inference.Models.Qwen.InitialCopiedParameterFrame
