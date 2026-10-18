import host.load.run.full.cached.Layout
import host.load.run.full.cached.FinalGraph
import host.load.run.full.cached.Step
import host.mlx.ReadbackValues
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Load.Program Host.Load.CachedShapes Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)

/-- One finite cached-forward certificate consumes the preceding computed
cache and device token. Capacity is derived from its producing graph; source
parameters are reconstructed from the unchanged checkpoint leaves. -/
theorem terminal_cached_forward (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (time : Nat) (supported : time + 1 ≤ 262144)
    (before : Loaded) (nextCache : List Cache) (token : Tensor) (previousNode outputNode : Nat)
    (hs : List Handles) (E : List (RNode Int InKey)) (expectedToken : Nat)
    (expectedCaches : List (Nat × Nat)) (cert : List Nat)
    (hmodel : before.model = parameterChoice.model)
    (classes : List.Forall₂ CacheClassMatches (stageWeights (weights (firstValues M K env table))) before.cache)
    (shapes : checkCaches (terminalGraph table) .bfloat16 [1,4,256,256] 6 before.cache = true)
    (feedback : terminalGraph table token.node = some ⟨.reshape [1,1], [previousNode]⟩)
    (earlier : previousNode < token.node)
    (original : stepGraph Expected2.stages Expected2.head time = (E, expectedToken, expectedCaches))
    (matched : Matches (terminalGraph table) E cert = true)
    (inputs : inputCarriersMatch E cert (inputNode before token) = true)
    (outputs : nextCache.map (fun c => (c.first.map Tensor.node,c.second.map Tensor.node)) =
      expectedCaches.map (fun (a,b) => (some (certAt cert a),some (certAt cert b))))
    (tokenOutput : certAt cert expectedToken = outputNode)
    (chain : ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs
      ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).cache)
    (caches : CacheValues M K env (terminalGraph table) before.cache hs)
    (previous : ∃ r, evalR M K env (terminalGraph table) previousNode = some r ∧
      itemUint32 r = some ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).token.val) :
    let after := (firstContext M K env table leaves typed parameters).run promptToken (time+1) supported
    ∃ next, (∃ r, evalR M K env (terminalGraph table) outputNode = some r ∧ itemUint32 r = some after.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages next after.cache ∧
      CacheValues M K env (terminalGraph table) nextCache next := by
  let p := firstPipeline M K env table leaves typed
  let w := weights (firstValues M K env table)
  have compatible := cacheCompatible_of_holds M K p.graph.stages (stageWeights w) hs _
    (stages_loaded M K p w (firstPipeline_loaded M K env table leaves typed)) chain
  have shapeValues := caches_sound M K env (terminalGraph table) .bfloat16 [1,4,256,256] 6 before.cache shapes
  have hg := populated_step_graph M K env (terminalGraph table)
    (contents M K env (firstFfiGraph table)) before.cache hs caches compatible classes
    (fun c hc hop t ht v hv => (shapeValues c hc hop t ht v hv).2) time
  change stepGraphOf w hs time = _ at hg
  rw [original] at hg
  obtain ⟨r, hr, hi⟩ := previous
  have bound : ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).token.val < 2^31 := by
    have small := ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).token.isLt
    omega
  obtain ⟨ids, hids, buffer⟩ := eval_feedback_reshape M K env (terminalGraph table)
    token.node previousNode _ r feedback earlier hr hi bound
  have hm : Matches (terminalGraph table) (stepGraphOf w hs time).1 cert = true := by rw [hg]; exact matched
  have hin : inputCarriersMatch (stepGraphOf w hs time).1 cert (inputNode before token) = true := by rw [hg]; exact inputs
  have hout : nextCache.map (fun c => (c.first.map Tensor.node,c.second.map Tensor.node)) =
      (stepGraphOf w hs time).2.2.map (fun (a,b) => (some (certAt cert a),some (certAt cert b))) := by rw [hg]; exact outputs
  obtain ⟨next, ht, hh, hc⟩ := cached_decode_from_values M K env table leaves typed parameters time supported
    P.s3573.ffi.mlx before token ids hs nextCache cert hmodel
    (terminal_parameter_value M K env table leaves) chain caches buffer hids hm hin hout
  refine ⟨next, ?_, hh, hc⟩
  rw [hg, tokenOutput] at ht
  exact ht
end Host.Load.Run.Full.Cached
