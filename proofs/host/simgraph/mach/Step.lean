import host.simgraph.iter.RefStep
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Mach
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The decode loop's graph side at the machine level

The prefill's MMA kernels (`C.simdMma`) and the Neural Engine's `NE.eval` have no accuracy contract, so no
range analysis bounds the caches a prompt leaves: the reference after a prompt is the machine's, not the
model's. Its decode step is the D1 forward's trace `stepTrace` (the decode step's graph `stepGraphOf`
evaluated, `stepGraph_eval_ids`: the token is the normalized argmax of the lm head's logits, the caches the
graph's cache nodes), from whatever handles the prefill left — no model cache (`ChainHolds`), no range
certificate (`TokenSequenceRanges.Parameters`).

* `MRef`, `MRefDecodes`: a reference of tokens and cache handles at every table and time, and its decode
  from `L` on (each next state is `stepTrace` of the current one).
* `ForwardAtM`: `ForwardAtR` at the machine level — the output node holds the reference's token, the cache
  tensors its handles' values (`CacheValues`); `ForwardAtM.grow`.
* `template_stepM`, `d1_template_stepM`: `template_step_of`, `d1_template_step_of` from a trace step, its
  handles' shapes (`ShapesOk`) and the embedding's (`bufferEmbed`), with no model premise.
* `cached_input_valuesM`, `template_cached_forwardM`: `cached_input_values`,
  `template_cached_forwardR` with the cache kinds (`CacheCompatible`) in place of the model cache: the graph
  step a loop case's `CaseFwd` obligation needs at the machine reference.
* `compat_of_caps`, `shapesOk_of_caps`: populated caches at a uniform capacity have their kinds and shapes. -/

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-! ## Kinds and shapes from capacities -/

theorem compat_of_caps {c : Nat} {ws : List StageWeights} {hs : List Handles} (h : CapsFor c ws hs) :
    List.Forall₂ CacheCompatible ws hs := by
  induction h with
  | nil => exact .nil
  | @cons w x ws hs hc _ ih =>
    refine .cons ?_ ih
    cases w <;> cases x
    · trivial
    · exact hc.elim
    · exact hc.elim
    · trivial

/-- The weights' own shapes (`StageShapes` without the caches). -/
def WeightShapes : List StageWeights → Prop
  | [] => True
  | .delta w :: ws => w.inputNorm.shape = [5120] ∧ WeightShapes ws
  | .attention w :: ws => (w.inputNorm.shape = [5120] ∧ w.qNorm.shape = [256] ∧ w.kNorm.shape = [256]) ∧ WeightShapes ws

theorem weightShapes_of : ∀ (ws : List StageWeights) (hs : List Handles), List.Forall₂ CacheCompatible ws hs →
    ShapesOk ws hs → WeightShapes ws
  | [], [], _, _ => trivial
  | .delta _ :: ws, .delta _ _ :: hs, .cons _ hc, ⟨h1, h2⟩ => ⟨h1, weightShapes_of ws hs hc h2⟩
  | .attention _ :: ws, .attention _ _ :: hs, .cons _ hc, ⟨⟨a, b, c, _, _⟩, h2⟩ => ⟨⟨a, b, c⟩, weightShapes_of ws hs hc h2⟩
  | .delta _ :: _, .attention _ _ :: _, .cons hx _, _ => hx.elim
  | .attention _ :: _, .delta _ _ :: _, .cons hx _, _ => hx.elim

/-- **Populated caches at one capacity have their shapes.** -/
theorem shapesOk_of_caps {c : Nat} : ∀ (ws : List StageWeights) (hs : List Handles), WeightShapes ws →
    CapsFor c ws hs → ShapesOk ws hs
  | [], [], _, _ => trivial
  | .delta _ :: ws, .delta _ _ :: hs, ⟨h1, h2⟩, .cons _ hc => ⟨h1, shapesOk_of_caps ws hs h2 hc⟩
  | .attention _ :: ws, .attention kb vb :: hs, ⟨⟨a, b, c', ⟩, h2⟩, .cons hx hc => by
    cases kb with
    | none => exact hx.elim
    | some kv =>
      cases vb with
      | none => exact hx.elim
      | some vv =>
        obtain ⟨hk, hv⟩ := hx
        refine ⟨⟨a, b, c', fun v e => ?_, fun v e => ?_⟩, shapesOk_of_caps ws hs h2 hc⟩
        · cases e; rw [hk]; rfl
        · cases e; rw [hv]; rfl
  | .delta _ :: _, .attention _ _ :: _, _, .cons hx _ => hx.elim
  | .attention _ :: _, .delta _ _ :: _, _, .cons hx _ => hx.elim

/-! ## The machine reference -/

/-- **A machine-level reference**: at every table and time, the token and the cache handles (`none` where it
is not defined). -/
abbrev MRef := (tab : List F64) → Nat → Option (Nat × List Handles)

/-- **The reference decodes from `L` on**: each next state is the decode trace's step of the current one. -/
def MRefDecodes (w : List F64 → PipelineWeights) (R : MRef) (L : Nat) : Prop :=
  ∀ tab time, L ≤ time → R tab (time + 1) = (R tab time).bind fun s => stepTrace M K (w tab) time s.1 s.2

variable (env : FfiEval.Env InKey)

/-- **A forward's graph at the machine reference** (`ForwardAtR` without the model): the reference is defined
at `time`, the output node holds its token and the cache tensors `cs` its handles' values. -/
def ForwardAtM (R : MRef) (tab : List F64) (time : Nat) (cs : List Cache) (out : Nat)
    (G : Nat → Option (RNode Int InKey)) : Prop :=
  ∃ tok hs, R tab time = some (tok, hs) ∧ (∃ r, evalR M K env G out = some r ∧ itemUint32 r = some tok) ∧
    CacheValues M K env G cs hs

theorem ForwardAtM.grow {R : MRef} {tab : List F64} {time : Nat} {cs : List Cache} {out : Nat} (N : Nums Int)
    (Ks : KernelSources) (s s' : Ffi.St) (h : ForwardAtM M K env R tab time cs out (ffiGraph N Ks s))
    (hg : Grows Ks s s') (hout : out < s.nnext) (hlt : Iter.CachesBelow cs s.nnext) :
    ForwardAtM M K env R tab time cs out (ffiGraph N Ks s') := by
  obtain ⟨tok, hs, hR, ⟨r, hr, ht⟩, hc⟩ := h
  exact ⟨tok, hs, hR, ⟨r, evalR_grows M K env N Ks s s' hg out hout r hr, ht⟩,
    cacheValues_grows M K env N Ks s s' hg cs hs hlt hc⟩

/-! ## The graph side of a trace step -/

/-- **The graph side of a decode step at the machine level** (`template_step_of` without the model): a graph
carrying the decode template holds the trace's next token at the output carrier and its next caches at the
cache carriers; the capacities step as the trace's. -/
theorem template_stepM (w : PipelineWeights) (time token : Nat) (hs hs' : List Handles) (t : Nat) (ids : Value)
    (hembed : bufferEmbed M w.embedWords w.embedScales w.embedBiases ids =
      embedTrace M w.embedWords w.embedScales w.embedBiases token)
    (hfn : w.finalNorm.shape = [5120]) (hsh : ShapesOk (stageWeights w) hs)
    (e : stepTrace M K w time token hs = some (t, hs'))
    (c : Nat) (caps : CapsFor c (stageWeights w) hs)
    (T : Template w) (branch : kvSig (some T.c₀) T.n₀ = kvSig (some c) time)
    (weights : List Char → List Char → Option Value) (G : Nat → Option (RNode Int InKey)) (σ cl : Nat → Nat)
    (emb : Embeds σ cl (mapG (SDim.eval time) T.Gs) G)
    (hin : InputsHeld M K (stepEnvWithIds weights w ids hs) G (stepGraphOf w hs time).1 (T.cert.map σ)) :
    (∃ r, evalR M K (stepEnvWithIds weights w ids hs) G
        (σ (certAt T.cert (templateOf w T.hs₀ T.n₀).2.1)) = some r ∧ itemUint32 r = some t) ∧
      CapsFor (kvCap (some c) time) (stageWeights w) hs' ∧
      (templateOf w T.hs₀ T.n₀).2.2.length = hs'.length ∧
      (∀ h ∈ hs', (handleVals h).isSome) ∧
      ∀ q ∈ cacheFacts (templateOf w T.hs₀ T.n₀).2.2 hs',
        evalR M K (stepEnvWithIds weights w ids hs) G (σ (certAt T.cert q.1)) = some q.2 := by
  have hm := template_matches w T hs c time caps branch G σ cl emb
  obtain ⟨ht, hc⟩ := ffi_step_ids M K weights w time _ ids hembed hs hs' _ hfn hsh e G _ hm hin
  obtain ⟨⟨_, hlt, _, _⟩, hlen, hsome, hcf⟩ := stepGraph_eval_ids M K weights w time _ ids hembed hs hs' _ hfn hsh e
  have hinst := template_instance w T hs c time caps branch
  have h2 : (templateOf w T.hs₀ T.n₀).2 = (stepGraphOf w hs time).2 := congrArg Prod.snd hinst
  have hE : (stepGraphOf w hs time).1.length ≤ T.cert.length := by
    rw [← congrArg Prod.fst hinst, List.length_map]; exact T.length
  refine ⟨?_, capsFor_step M K w time _ hs hs' _ c caps e, by rw [h2]; exact hlen, hsome, ?_⟩
  · obtain ⟨r, hr, hi⟩ := ht
    refine ⟨r, ?_, hi⟩
    rw [h2, ← certAt_map σ T.cert _ (by omega)]
    exact hr
  · intro q hq
    rw [h2] at hq
    rw [← certAt_map σ T.cert _ (by have := (hcf q hq).1; omega)]
    exact hc q hq

/-- **The graph side of a D1 step at a symbolic position, at the machine level** (`d1_template_step_of`
without the model; e.g. the final prompt row at `L - 1`). -/
theorem d1_template_stepM (w : PipelineWeights) (time token : Nat) (hs hs' : List Handles) (t : Nat) (ids : Value)
    (hembed : bufferEmbed M w.embedWords w.embedScales w.embedBiases ids =
      embedTrace M w.embedWords w.embedScales w.embedBiases token)
    (hfn : w.finalNorm.shape = [5120]) (hsh : ShapesOk (stageWeights w) hs)
    (e : stepTrace M K w time token hs = some (t, hs'))
    (pos pos1 : PDim) (T : PromptTemplate (d1Of w pos pos1)) (ν : Nat → Int)
    (hpos : pos.eval ν = time) (hpos1 : pos1.eval ν = time + 1)
    (hsig : List.Forall₂ (SigRelR (d1Of w pos pos1).ops.sig T.o₀ T.n₀ time 1) T.ss₀ (chainLayout (stageWeights w) hs))
    (weights : List Char → List Char → Option Value) (G : Nat → Option (RNode Int InKey)) (σ cl : Nat → Nat)
    (emb : Embeds σ cl (mapG (PDim.eval ν) T.Gs) G)
    (hin : InputsHeld M K (stepEnvWithIds weights w ids hs) G (stepGraphOf w hs time).1 (T.cert.map σ)) :
    (∃ r, evalR M K (stepEnvWithIds weights w ids hs) G
        (σ (certAt T.cert (familyGraph (d1Of w pos pos1).ops id T.o₀ T.n₀ T.ss₀).2.1)) = some r ∧
        itemUint32 r = some t) ∧
      (familyGraph (d1Of w pos pos1).ops id T.o₀ T.n₀ T.ss₀).2.2.length = hs'.length ∧
      (∀ h ∈ hs', (handleVals h).isSome) ∧
      ∀ q ∈ cacheFacts (familyGraph (d1Of w pos pos1).ops id T.o₀ T.n₀ T.ss₀).2.2 hs',
        evalR M K (stepEnvWithIds weights w ids hs) G (σ (certAt T.cert q.1)) = some q.2 := by
  have hinst := prompt_template_instance T ν time 1 _ hsig
  rw [d1_familyGraph w hs pos pos1 ν time 1 hpos hpos1] at hinst
  have hm := prompt_template_matches T ν time 1 _ hsig G σ cl emb
  rw [d1_familyGraph w hs pos pos1 ν time 1 hpos hpos1] at hm
  obtain ⟨ht, hc⟩ := ffi_step_ids M K weights w time _ ids hembed hs hs' _ hfn hsh e G _ hm hin
  obtain ⟨⟨_, hlt, _, _⟩, hlen, hsome, hcf⟩ := stepGraph_eval_ids M K weights w time _ ids hembed hs hs' _ hfn hsh e
  have h2 : (familyGraph (d1Of w pos pos1).ops id T.o₀ T.n₀ T.ss₀).2 = (stepGraphOf w hs time).2 :=
    congrArg Prod.snd hinst
  have hE : (stepGraphOf w hs time).1.length ≤ T.cert.length := by
    rw [← congrArg Prod.fst hinst, List.length_map]; exact T.length
  refine ⟨?_, by rw [h2]; exact hlen, hsome, ?_⟩
  · obtain ⟨r, hr, hi⟩ := ht
    refine ⟨r, ?_, hi⟩
    rw [h2, ← certAt_map σ T.cert _ (by omega)]
    exact hr
  · intro q hq
    rw [h2] at hq
    rw [← certAt_map σ T.cert _ (by have := (hcf q hq).1; omega)]
    exact hc q hq

/-! ## A cached forward at the machine reference -/

/-- `cached_input_values` with the cache kinds in place of the model cache. -/
theorem cached_input_valuesM (value : TensorValues) (p : TokenInference.Pipeline)
    (hl : PipelineLoaded M K p (weights value)) (l : Loaded) (token : Tensor) (ids : Value)
    (hs : List Handles) (compat : List.Forall₂ CacheCompatible (stageWeights (weights value)) hs)
    (weightsEnv : List Char → List Char → Option Value) (G : Nat → Option (RNode Int InKey))
    (E : List (RNode Int InKey)) (cert : List Nat)
    (hmodel : l.model = parameterChoice.model)
    (hp : ∀ t, t ∈ parameterTensors l →
      evalR M K (stepEnvWithIds weightsEnv (weights value) ids hs) G t.node = some (value t))
    (hc : CacheValues M K (stepEnvWithIds weightsEnv (weights value) ids hs) G l.cache hs)
    (ht : evalR M K (stepEnvWithIds weightsEnv (weights value) ids hs) G token.node = some ids)
    (hm : inputCarriersMatch E cert (inputNode l token) = true) :
    InputsHeld M K (stepEnvWithIds weightsEnv (weights value) ids hs) G E cert := by
  apply inputsHeld_cached M K l token value _ G E cert hs hp
  · intro key hk hnc
    have parameters : parameterInput l key = parameterInput parameterChoice key := by
      cases key <;> simp only [parameterInput, hmodel]
    rw [parameters]
    have loaded := stages_loaded M K p (weights value) hl
    have initial := cacheCompatible_of_holds M K _ _ initialHandles _ loaded (initialChainHolds p)
    exact (stepInputsWithIds_parameter_eq _ ids hs initialHandles compat initial key hnc).trans
      (initial_input_values value ids key hk)
  · exact hc
  · intro q i
    exact stepInputsWithIds_cache_value _ ids hs compat (hc.populated M K _ _) q i
  · exact ht
  · exact hm

variable (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)

include leaves typed in
/-- **A cached forward at the machine reference** (`template_cached_forwardR` without the model): from a native
state whose graph holds the loaded parameters, the reference's handles at the cache tensors, the token fed back
from the previous output (which holds the reference's token), and the decode template carried at the step, the
output node holds the trace's next token and the next cache tensors its next handles. -/
theorem template_cached_forwardM (table : List F64) (time : Nat)
    (native : Host.Mlx.Ffi.St) (l : Loaded) (token : Tensor) (previousNode outputNode : Nat)
    (tok tok' : Nat) (hs hs' : List Handles) (nextCache : List Cache) (c : Nat)
    (step : stepTrace M K (weights (firstValues M K env table)) time tok hs = some (tok', hs'))
    (bounded : tok < 2 ^ 31)
    (compat : List.Forall₂ CacheCompatible (stageWeights (weights (firstValues M K env table))) hs)
    (shapes : ShapesOk (stageWeights (weights (firstValues M K env table))) hs)
    (T : Template (weights (firstValues M K env table))) (σ cl : Nat → Nat)
    (hmodel : l.model = parameterChoice.model)
    (parameterValues : ∀ t ∈ parameterTensors parameterChoice,
      evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) t.node =
        some (firstValues M K env table t))
    (caps : CapsFor c (stageWeights (weights (firstValues M K env table))) hs)
    (branch : kvSig (some T.c₀) T.n₀ = kvSig (some c) time)
    (caches : CacheValues M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native)
      l.cache hs)
    (feedback : ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native token.node =
      some ⟨.reshape [1,1], [previousNode]⟩)
    (earlier : previousNode < token.node)
    (previous : ∃ r, evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native)
        previousNode = some r ∧ itemUint32 r = some tok)
    (carried : Embeds σ cl (mapG (SDim.eval time) T.Gs)
      (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native))
    (inputs : inputCarriersMatch (stepGraphOf (weights (firstValues M K env table)) hs time).1 (T.cert.map σ)
      (inputNode l token) = true)
    (outputs : nextCache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      (templateOf (weights (firstValues M K env table)) T.hs₀ T.n₀).2.2.map
        (fun (a, b) => (some (σ (certAt T.cert a)), some (σ (certAt T.cert b)))))
    (tokenOutput : σ (certAt T.cert (templateOf (weights (firstValues M K env table)) T.hs₀ T.n₀).2.1) = outputNode) :
    (∃ r, evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native)
        outputNode = some r ∧ itemUint32 r = some tok') ∧
      CacheValues M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native)
        nextCache hs' ∧
      CapsFor (kvCap (some c) time) (stageWeights (weights (firstValues M K env table))) hs' := by
  let value := firstValues M K env table
  let p := firstPipeline M K env table leaves typed
  have hl := firstPipeline_loaded M K env table leaves typed
  let G := ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native
  obtain ⟨r, hr, hi⟩ := previous
  obtain ⟨ids, hids, buffer⟩ := eval_feedback_reshape M K env G token.node previousNode _ r feedback earlier hr hi bounded
  let decodeEnv := stepEnvWithIds env.weights (weights value) ids hs
  have stable (i : Nat) : evalR M K env G i = evalR M K decodeEnv G i :=
    evalFfi_inputs M K env decodeEnv rfl _ _ native i
  have hp : ∀ t, t ∈ parameterTensors l → evalR M K decodeEnv G t.node = some (value t) := by
    intro t ht
    have ht' : t ∈ parameterTensors parameterChoice := by
      simpa only [parameterTensors, hmodel] using ht
    exact (stable t.node).symm.trans (parameterValues t ht')
  have hin := cached_input_valuesM M K value p hl l token ids hs compat env.weights G _ _ hmodel hp
    (caches.congr M K env G decodeEnv G stable) ((stable token.node).symm.trans hids) inputs
  have hembed := bufferEmbed_eq M (weights value).embedWords (weights value).embedScales (weights value).embedBiases
    ids _ buffer hl.embedding.words.1 hl.embedding.words.2.1 hl.embedding.scales.2.1 hl.embedding.biases.2.1
  obtain ⟨⟨r', hr', htoken⟩, hcaps, hlen, hsome, hev⟩ :=
    template_stepM M K (weights value) time tok hs hs' tok' ids hembed hl.finalNorm.2.1 shapes step c caps T branch
      env.weights G σ cl carried hin
  have out := cacheValues_of_facts M K decodeEnv G nextCache _ hs' (fun a => σ (certAt T.cert a)) outputs hlen
    hsome hev
  refine ⟨⟨r', ?_, htoken⟩, out.congr M K decodeEnv G env G (fun i => (stable i).symm), hcaps⟩
  rw [← tokenOutput]
  exact (stable _).trans hr'

end Host.Mlx.SimGraph.Mach
