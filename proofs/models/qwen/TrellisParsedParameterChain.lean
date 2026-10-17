import models.qwen.TrellisParsedParameterStage
namespace Inference.Models.Qwen.TrellisParsedParameterChain
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention DecodeParameterConstruction
set_option maxRecDepth 10000

-- This follows the constructor's dependent cursor, current heap, and reframed
-- original parameter bundle. Only native primitives are supplied at each stage.
def Native : (stages : List Stage) → (cursor : Cursor all stages) → (cache : Caches stages n) →
    (input : Row BF) → (angle : RopeAngles.Inputs) → (source : ArrayStorage.BFBuffer input) →
    (storage : DecodeFrame.Storage stages cache source.bytes) → (parameters : DecodeParameterMemory.Storage all source.bytes) →
    ChainPlan stages cursor cache input angle source storage parameters → Type
  | [], _, _, _, _, _, _, _, _ => PUnit
  | kind::rest, cursor, cache, input, angle, source, storage, parameters, plan =>
    TrellisParsedParameterStage.Native kind cache.1 input angle
      (stage kind cache.1 input angle source storage.1 (remainingParameters cursor parameters).1 plan.1.first).execution ×
    Native rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle
      plan.1.step.first.buffer plan.1.step.nextStorage plan.1.nextParameters plan.2

def Parsed : (stages : List Stage) → (cursor : Cursor all stages) → (cache : Caches stages n) →
    (input : Row BF) → (angle : RopeAngles.Inputs) → (source : ArrayStorage.BFBuffer input) →
    (storage : DecodeFrame.Storage stages cache source.bytes) → (parameters : DecodeParameterMemory.Storage all source.bytes) →
    (plan : ChainPlan stages cursor cache input angle source storage parameters) →
    Native stages cursor cache input angle source storage parameters plan → Prop
  | [], _, _, _, _, _, _, _, _, _ => True
  | kind::rest, cursor, cache, input, angle, source, storage, parameters, plan, native =>
    TrellisParsedParameterStage.Parsed kind cache.1 input angle
      (stage kind cache.1 input angle source storage.1 (remainingParameters cursor parameters).1 plan.1.first).execution native.1 ∧
    Parsed rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle
      plan.1.step.first.buffer plan.1.step.nextStorage plan.1.nextParameters plan.2 native.2

theorem parsed : (stages : List Stage) → (cursor : Cursor all stages) → (cache : Caches stages n) →
    (input : Row BF) → (angle : RopeAngles.Inputs) → (source : ArrayStorage.BFBuffer input) →
    (storage : DecodeFrame.Storage stages cache source.bytes) → (parameters : DecodeParameterMemory.Storage all source.bytes) →
    (plan : ChainPlan stages cursor cache input angle source storage parameters) →
    (native : Native stages cursor cache input angle source storage parameters plan) →
    Parsed stages cursor cache input angle source storage parameters plan native
  | [], _, _, _, _, _, _, _, _, _ => True.intro
  | kind::rest, cursor, cache, input, angle, source, storage, parameters, plan, native =>
    ⟨TrellisParsedParameterStage.stage kind cache.1 input angle source storage.1
      (remainingParameters cursor parameters).1 plan.1.first native.1,
      parsed rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle
        plan.1.step.first.buffer plan.1.step.nextStorage plan.1.nextParameters plan.2 native.2⟩
end Inference.Models.Qwen.TrellisParsedParameterChain
