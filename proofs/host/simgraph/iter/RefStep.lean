import host.simgraph.iter.InvL
import host.simgraph.prompt.PromptStep
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # Template steps at a reference

`template_step` and `d1_template_step` (Step.lean, PromptStep.lean) take the decode step of the
reached context `(GlueM1Max.context …).run token` (`GlueM1Max.contextStep`). Here the same from
any decode step `before → after` of reached states (`template_step_of`, `d1_template_step_of`),
and `template_cached_forwardR`, `template_cached_forward` at a reference `R` whose decode steps
hold from time `L` on (`RefDecodes`, the property the prefill's reference supplies; the
existing reference has it from time 0: `refPrompt1_decodes`). These discharge `CaseFwdL` from
a template certificate as `template_cached_forward` discharges `CaseFwd`. -/

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- **The graph side of a decode step `before → after`** (`template_step`). -/
theorem template_step_of (p : TokenInference.Pipeline) (w : PipelineWeights) (hl : PipelineLoaded M K p w)
    (time : Nat) (before : TokenAutoregressive.State p time) (after : TokenAutoregressive.State p (time + 1))
    (ids : Value) (hids : TokenBuffer ids before.token.val) (hs : List Handles)
    (hh : ChainHolds p.graph.stages hs before.cache)
    (hstep : ∃ hs', stepTrace M K w time before.token.val hs = some (after.token.val, hs') ∧
      ChainHolds p.graph.stages hs' after.cache)
    (c : Nat) (caps : CapsFor c (stageWeights w) hs)
    (T : Template w) (branch : kvSig (some T.c₀) T.n₀ = kvSig (some c) time)
    (weights : List Char → List Char → Option Value) (G : Nat → Option (RNode Int InKey)) (σ cl : Nat → Nat)
    (emb : Embeds σ cl (mapG (SDim.eval time) T.Gs) G)
    (hin : InputsHeld M K (stepEnvWithIds weights w ids hs) G (stepGraphOf w hs time).1 (T.cert.map σ)) :
    ∃ hs', (∃ r, evalR M K (stepEnvWithIds weights w ids hs) G
        (σ (certAt T.cert (templateOf w T.hs₀ T.n₀).2.1)) = some r ∧ itemUint32 r = some after.token.val) ∧
      ChainHolds p.graph.stages hs' after.cache ∧
      CapsFor (kvCap (some c) time) (stageWeights w) hs' ∧
      (templateOf w T.hs₀ T.n₀).2.2.length = hs'.length ∧
      (∀ h ∈ hs', (handleVals h).isSome) ∧
      ∀ q ∈ cacheFacts (templateOf w T.hs₀ T.n₀).2.2 hs',
        evalR M K (stepEnvWithIds weights w ids hs) G (σ (certAt T.cert q.1)) = some q.2 := by
  obtain ⟨hs', e, h'⟩ := hstep
  have hsh := shapes_of_holds M K _ _ _ _ (stages_loaded M K p w hl) hh
  have hembed := bufferEmbed_eq M w.embedWords w.embedScales w.embedBiases ids _ hids
    hl.embedding.words.1 hl.embedding.words.2.1 hl.embedding.scales.2.1 hl.embedding.biases.2.1
  have hm := template_matches w T hs c time caps branch G σ cl emb
  obtain ⟨ht, hc⟩ := ffi_step_ids M K weights w time _ ids hembed hs hs' _ hl.finalNorm.2.1 hsh e G _ hm hin
  obtain ⟨⟨_, hlt, _, _⟩, hlen, hsome, hcf⟩ :=
    stepGraph_eval_ids M K weights w time _ ids hembed hs hs' _ hl.finalNorm.2.1 hsh e
  have hinst := template_instance w T hs c time caps branch
  have h2 : (templateOf w T.hs₀ T.n₀).2 = (stepGraphOf w hs time).2 := congrArg Prod.snd hinst
  have hE : (stepGraphOf w hs time).1.length ≤ T.cert.length := by
    rw [← congrArg Prod.fst hinst, List.length_map]; exact T.length
  refine ⟨hs', ?_, h', capsFor_step M K w time _ hs hs' _ c caps e, by rw [h2]; exact hlen, hsome, ?_⟩
  · obtain ⟨r, hr, hi⟩ := ht
    refine ⟨r, ?_, hi⟩
    rw [h2, ← certAt_map σ T.cert _ (by omega)]
    exact hr
  · intro q hq
    rw [h2] at hq
    rw [← certAt_map σ T.cert _ (by have := (hcf q hq).1; omega)]
    exact hc q hq

/-- **The graph side of a D1 step `before → after` at a symbolic position**
(`d1_template_step`), for a D1 prompt template (`PDim` dimensions). -/
theorem d1_template_step_of (w : PipelineWeights) (p : TokenInference.Pipeline) (hl : PipelineLoaded M K p w)
    (time : Nat) (before : TokenAutoregressive.State p time) (after : TokenAutoregressive.State p (time + 1))
    (ids : Value) (hids : TokenBuffer ids before.token.val) (hs : List Handles)
    (hh : ChainHolds p.graph.stages hs before.cache)
    (hstep : ∃ hs', stepTrace M K w time before.token.val hs = some (after.token.val, hs') ∧
      ChainHolds p.graph.stages hs' after.cache)
    (c : Nat) (caps : CapsFor c (stageWeights w) hs)
    (pos pos1 : PDim) (T : PromptTemplate (d1Of w pos pos1)) (ν : Nat → Int)
    (hpos : pos.eval ν = time) (hpos1 : pos1.eval ν = time + 1)
    (hsig : List.Forall₂ (SigRelR (d1Of w pos pos1).ops.sig T.o₀ T.n₀ time 1) T.ss₀ (chainLayout (stageWeights w) hs))
    (weights : List Char → List Char → Option Value) (G : Nat → Option (RNode Int InKey)) (σ cl : Nat → Nat)
    (emb : Embeds σ cl (mapG (PDim.eval ν) T.Gs) G)
    (hin : InputsHeld M K (stepEnvWithIds weights w ids hs) G (stepGraphOf w hs time).1 (T.cert.map σ)) :
    ∃ hs', (∃ r, evalR M K (stepEnvWithIds weights w ids hs) G
        (σ (certAt T.cert (familyGraph (d1Of w pos pos1).ops id T.o₀ T.n₀ T.ss₀).2.1)) = some r ∧
        itemUint32 r = some after.token.val) ∧
      ChainHolds p.graph.stages hs' after.cache ∧
      CapsFor (kvCap (some c) time) (stageWeights w) hs' ∧
      (familyGraph (d1Of w pos pos1).ops id T.o₀ T.n₀ T.ss₀).2.2.length = hs'.length ∧
      (∀ h ∈ hs', (handleVals h).isSome) ∧
      ∀ q ∈ cacheFacts (familyGraph (d1Of w pos pos1).ops id T.o₀ T.n₀ T.ss₀).2.2 hs',
        evalR M K (stepEnvWithIds weights w ids hs) G (σ (certAt T.cert q.1)) = some q.2 := by
  obtain ⟨hs', e, h'⟩ := hstep
  have hsh := shapes_of_holds M K _ _ _ _ (stages_loaded M K p w hl) hh
  have hembed := bufferEmbed_eq M w.embedWords w.embedScales w.embedBiases ids _ hids
    hl.embedding.words.1 hl.embedding.words.2.1 hl.embedding.scales.2.1 hl.embedding.biases.2.1
  have hinst := prompt_template_instance T ν time 1 _ hsig
  rw [d1_familyGraph w hs pos pos1 ν time 1 hpos hpos1] at hinst
  have hm := prompt_template_matches T ν time 1 _ hsig G σ cl emb
  rw [d1_familyGraph w hs pos pos1 ν time 1 hpos hpos1] at hm
  obtain ⟨ht, hc⟩ := ffi_step_ids M K weights w time _ ids hembed hs hs' _ hl.finalNorm.2.1 hsh e G _ hm hin
  obtain ⟨⟨_, hlt, _, _⟩, hlen, hsome, hcf⟩ :=
    stepGraph_eval_ids M K weights w time _ ids hembed hs hs' _ hl.finalNorm.2.1 hsh e
  have h2 : (familyGraph (d1Of w pos pos1).ops id T.o₀ T.n₀ T.ss₀).2 = (stepGraphOf w hs time).2 :=
    congrArg Prod.snd hinst
  have hE : (stepGraphOf w hs time).1.length ≤ T.cert.length := by
    rw [← congrArg Prod.fst hinst, List.length_map]; exact T.length
  refine ⟨hs', ?_, h', capsFor_step M K w time _ hs hs' _ c caps e, by rw [h2]; exact hlen, hsome, ?_⟩
  · obtain ⟨r, hr, hi⟩ := ht
    refine ⟨r, ?_, hi⟩
    rw [h2, ← certAt_map σ T.cert _ (by omega)]
    exact hr
  · intro q hq
    rw [h2] at hq
    rw [← certAt_map σ T.cert _ (by have := (hcf q hq).1; omega)]
    exact hc q hq

variable (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)

/-- **The reference decodes from time `L` on**: from handles holding its cache at a time
`≥ L`, one MLX decode step returns its next token and handles holding its next cache. -/
def RefDecodes (R : RefRun M K env leaves typed) (L : Nat) : Prop :=
  ∀ tab time (h : time + 1 ≤ 262144), L ≤ time → ∀ hs,
    ChainHolds (firstPipeline M K env tab leaves typed).graph.stages hs (R tab time (by omega)).cache →
    ∃ hs', stepTrace M K (weights (firstValues M K env tab)) time (R tab time (by omega)).token.val hs =
        some ((R tab (time + 1) h).token.val, hs') ∧
      ChainHolds (firstPipeline M K env tab leaves typed).graph.stages hs' (R tab (time + 1) h).cache

/-- **The existing reference decodes from time 0.** -/
theorem refPrompt1_decodes (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed)) :
    RefDecodes M K env leaves typed (refPrompt1 M K env leaves typed parameters) 0 :=
  fun tab time h _ hs hh => GlueM1Max.contextStep M K (firstPipeline M K env tab leaves typed)
    (weights (firstValues M K env tab)) (firstPipeline_loaded M K env tab leaves typed)
    (hpOf M K env leaves typed parameters tab) promptToken time h hs hh

/-- **A cached forward at a reference** (`template_cached_forward`): at a time `≥ L` where `R`
decodes. -/
theorem template_cached_forwardR (table : List F64) (R : RefRun M K env leaves typed) (L : Nat)
    (hR : RefDecodes M K env leaves typed R L)
    (time : Nat) (supported : time + 1 ≤ 262144) (hL : L ≤ time)
    (native : Host.Mlx.Ffi.St) (l : Loaded) (token : Tensor) (previousNode outputNode : Nat)
    (hs : List Handles) (nextCache : List Cache) (c : Nat)
    (T : Template (weights (firstValues M K env table))) (σ cl : Nat → Nat)
    (hmodel : l.model = parameterChoice.model)
    (parameterValues : ∀ t ∈ parameterTensors parameterChoice,
      evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) t.node =
        some (firstValues M K env table t))
    (chain : ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs (R table time (by omega)).cache)
    (caps : CapsFor c (stageWeights (weights (firstValues M K env table))) hs)
    (branch : kvSig (some T.c₀) T.n₀ = kvSig (some c) time)
    (caches : CacheValues M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native)
      l.cache hs)
    (feedback : ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native token.node =
      some ⟨.reshape [1,1], [previousNode]⟩)
    (earlier : previousNode < token.node)
    (previous : ∃ r, evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native)
        previousNode = some r ∧ itemUint32 r = some (R table time (by omega)).token.val)
    (carried : Embeds σ cl (mapG (SDim.eval time) T.Gs)
      (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native))
    (inputs : inputCarriersMatch (stepGraphOf (weights (firstValues M K env table)) hs time).1 (T.cert.map σ)
      (inputNode l token) = true)
    (outputs : nextCache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      (templateOf (weights (firstValues M K env table)) T.hs₀ T.n₀).2.2.map
        (fun (a, b) => (some (σ (certAt T.cert a)), some (σ (certAt T.cert b)))))
    (tokenOutput : σ (certAt T.cert (templateOf (weights (firstValues M K env table)) T.hs₀ T.n₀).2.1) = outputNode) :
    ∃ next, (∃ r, evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native)
        outputNode = some r ∧ itemUint32 r = some (R table (time + 1) supported).token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages next (R table (time + 1) supported).cache ∧
      CacheValues M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native)
        nextCache next ∧
      CapsFor (kvCap (some c) time) (stageWeights (weights (firstValues M K env table))) next := by
  let value := firstValues M K env table
  let p := firstPipeline M K env table leaves typed
  let G := ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native
  obtain ⟨r, hr, hi⟩ := previous
  have bound : (R table time (by omega)).token.val < 2 ^ 31 := by
    have small := (R table time (by omega)).token.isLt
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
    template_step_of M K p (weights value) (firstPipeline_loaded M K env table leaves typed) time
      (R table time (by omega)) (R table (time + 1) supported) ids buffer hs chain
      (hR table time supported hL hs chain) c caps T branch env.weights G σ cl carried hin
  have out := cacheValues_of_facts M K decodeEnv G nextCache _ next (fun a => σ (certAt T.cert a)) outputs hlen
    hsome hev
  refine ⟨next, ⟨r', ?_, htoken⟩, hchain, out.congr M K decodeEnv G env G (fun i => (stable i).symm), hcaps⟩
  rw [← tokenOutput]
  exact (stable _).trans hr'

end Host.Mlx.SimGraph.Iter
