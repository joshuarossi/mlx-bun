import host.load.run.full.cached.Forward
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
variable {C : Inference.Contracts.Mlx.M1Max.Contract}
/-- A finite source snapshot carries the token and all64cache tensors
computed by the fixed checkpoint recurrence. -/
def ForwardResult (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey) (table : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (time : Nat) (supported : time ≤ 262144) (sourceCaches : List Cache) (outputNode : Nat) : Prop :=
  let after := (firstContext M K env table leaves typed parameters).run promptToken time supported
  ∃ hs, (∃ r, evalR M K env (terminalGraph table) outputNode = some r ∧ itemUint32 r = some after.token.val) ∧
    ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs after.cache ∧
    CacheValues M K env (terminalGraph table) sourceCaches hs
end Host.Load.Run.Full.Cached
