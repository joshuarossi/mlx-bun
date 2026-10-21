import host.load.run.full.CachedStep
import host.mlx.ReadbackValues
import host.simgraph.Step
namespace Host.Mlx.SimGraph
open Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option maxRecDepth 1000000

/-! # A cached forward at any iteration

`template_cached_forward` is `terminal_cached_forward`'s step for an
arbitrary decode iteration: any time below the context bound, any native
state `native` (the iteration's), the expected graph replaced by a checked
`Template` that `native`'s graph carries under a node map `σ`. The
previous iteration supplies the chain facts (`ChainHolds`, `CacheValues`
in `native`'s graph, uniform capacity `c`) and the token feedback node;
the conclusion supplies them for the next iteration, at capacity
`kvCap (some c) time`. -/

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)

theorem template_cached_forward (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (time : Nat) (supported : time + 1 ≤ 262144)
    (native : Host.Mlx.Ffi.St) (l : Loaded) (token : Tensor) (previousNode outputNode : Nat)
    (hs : List Handles) (nextCache : List Cache) (c : Nat)
    (T : Template (weights (firstValues M K env table))) (σ cl : Nat → Nat)
    (hmodel : l.model = parameterChoice.model)
    (parameterValues : ∀ t ∈ parameterTensors parameterChoice,
      evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) t.node =
        some (firstValues M K env table t))
    (chain : ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs
      ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).cache)
    (caps : CapsFor c (stageWeights (weights (firstValues M K env table))) hs)
    (branch : kvSig (some T.c₀) T.n₀ = kvSig (some c) time)
    (caches : CacheValues M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) l.cache hs)
    (feedback : ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native token.node =
      some ⟨.reshape [1,1], [previousNode]⟩)
    (earlier : previousNode < token.node)
    (previous : ∃ r, evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) previousNode =
        some r ∧
      itemUint32 r = some ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).token.val)
    (carried : Embeds σ cl (mapG (SDim.eval time) T.Gs)
      (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native))
    (inputs : inputCarriersMatch (stepGraphOf (weights (firstValues M K env table)) hs time).1 (T.cert.map σ)
      (inputNode l token) = true)
    (outputs : nextCache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      (templateOf (weights (firstValues M K env table)) T.hs₀ T.n₀).2.2.map
        (fun (a, b) => (some (σ (certAt T.cert a)), some (σ (certAt T.cert b)))))
    (tokenOutput : σ (certAt T.cert (templateOf (weights (firstValues M K env table)) T.hs₀ T.n₀).2.1) = outputNode) :
    let after := (firstContext M K env table leaves typed parameters).run promptToken (time + 1) supported
    ∃ next, (∃ r, evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) outputNode =
        some r ∧ itemUint32 r = some after.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages next after.cache ∧
      CacheValues M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) nextCache next ∧
      CapsFor (kvCap (some c) time) (stageWeights (weights (firstValues M K env table))) next := by
  let value := firstValues M K env table
  let p := firstPipeline M K env table leaves typed
  let G := ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native
  obtain ⟨r, hr, hi⟩ := previous
  have bound : ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).token.val <
      2 ^ 31 := by
    have small := ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).token.isLt
    omega
  obtain ⟨ids, hids, buffer⟩ := eval_feedback_reshape M K env G token.node previousNode _ r feedback earlier hr hi bound
  let decodeEnv := stepEnvWithIds env.weights (weights value) ids hs
  have stable (i : Nat) : evalR M K env G i = evalR M K decodeEnv G i :=
    evalFfi_inputs M K env decodeEnv rfl _ _ native i
  have hp : ∀ t, t ∈ parameterTensors l → evalR M K decodeEnv G t.node = some (value t) := by
    intro t ht
    have ht' : t ∈ parameterTensors parameterChoice := by
      simpa only [parameterTensors, hmodel] using ht
    exact (stable t.node).symm.trans (parameterValues t ht')
  have hin := cached_input_values M K value p (firstPipeline_loaded M K env table leaves typed)
    l token ids hs _ chain env.weights G _ _ hmodel hp
    (caches.congr M K env G decodeEnv G stable) ((stable token.node).symm.trans hids) inputs
  obtain ⟨next, ⟨r', hr', htoken⟩, hchain, hcaps, hlen, hsome, hev⟩ :=
    template_step M K p (weights value) (firstPipeline_loaded M K env table leaves typed)
      parameters promptToken time supported ids buffer hs chain c caps T branch env.weights G σ cl carried hin
  have out := cacheValues_of_facts M K decodeEnv G nextCache _ next (fun a => σ (certAt T.cert a)) outputs hlen
    hsome hev
  refine ⟨next, ⟨r', ?_, htoken⟩, hchain, out.congr M K decodeEnv G env G (fun i => (stable i).symm), hcaps⟩
  rw [← tokenOutput]
  exact (stable _).trans hr'

end Host.Mlx.SimGraph
