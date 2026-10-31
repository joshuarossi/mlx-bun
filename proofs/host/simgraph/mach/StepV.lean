import host.simgraph.mach.Step
import host.simgraph.EvalZ
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Mlx.SimGraph.Mach
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr)

/-! # The machine-level graph facts at the route's values

The reference (`refPrompt`) is defined with the route's kernels, so the caches a prefill leaves have values only
under them: `evalR` on the decode-resolved graph gives a node depending on a prefill kernel none. This layer states
the machine-level facts at a value function `ev`, instantiated by `routeVals` (`evalZ` on `ffiGraphR`).

* `CacheValuesV`, `ForwardAtV`, `ReadbackValuesV`: `CacheValues`, `ForwardAtM`, `ReadbackValues` at `ev`; at
  `evalR` they are the originals (`CacheValues.toV`).
* `ffiGraph_route`: the route resolution keeps the decode resolution's nodes.
* `template_stepV`, `template_cached_forwardV`: `template_stepM`, `template_cached_forwardM` at the route's values.
  The generated template's `Embeds` into the decode-resolved graph is unchanged: it carries the forward's own
  nodes (`matches_evalZ`), and the values of the forward's inputs are given at `ev`. -/

section
variable (ev : Nat → Option Value)

/-- `CacheValues` at the values `ev`. -/
def CacheValuesV (cs : List Cache) (hs : List Handles) : Prop :=
  List.Forall₂ (fun c h => ∃ ta tb a b,
    c.first = some ta ∧ c.second = some tb ∧ handleVals h = some (a, b) ∧
    ev ta.node = some a ∧ ev tb.node = some b) cs hs

/-- `ForwardAtM` at the values `ev`. -/
def ForwardAtV (R : MRef) (tab : List F64) (time : Nat) (cs : List Cache) (out : Nat) : Prop :=
  ∃ tok hs, R tab time = some (tok, hs) ∧ (∃ r, ev out = some r ∧ itemUint32 r = some tok) ∧ CacheValuesV ev cs hs

/-- `ReadbackValues` at the values `ev`. -/
def ReadbackValuesV (ν : NumV → Option F64) (items : PTrie NumV) : Prop :=
  ∀ node value, items.get node = some value →
    ∃ token, token < 2 ^ 31 ∧ (∃ r, ev node = some r ∧ itemUint32 r = some token) ∧ ν value = some (F64.ofNat token)

variable {ev}

theorem CacheValuesV.mono {ev' : Nat → Option Value} {cs : List Cache} {hs : List Handles}
    (h : CacheValuesV ev cs hs) (he : ∀ c ∈ cs, ∀ t, (c.first = some t ∨ c.second = some t) →
      ∀ v, ev t.node = some v → ev' t.node = some v) : CacheValuesV ev' cs hs := by
  induction h with
  | nil => exact .nil
  | @cons c h cs hs hc _ ih =>
    obtain ⟨ta, tb, a, b, ht, hu, hv, ha, hb⟩ := hc
    exact .cons ⟨ta, tb, a, b, ht, hu, hv, he c (List.mem_cons_self ..) ta (.inl ht) a ha,
      he c (List.mem_cons_self ..) tb (.inr hu) b hb⟩
      (ih fun x hx t ht' v hv' => he x (List.mem_cons_of_mem _ hx) t ht' v hv')

theorem CacheValuesV.populated {cs : List Cache} {hs : List Handles} (h : CacheValuesV ev cs hs) :
    ∀ x ∈ hs, (handleVals x).isSome := by
  induction h with
  | nil => simp
  | cons h _ ih =>
    obtain ⟨_, _, _, _, _, _, hv, _, _⟩ := h
    intro x hx
    rcases List.mem_cons.mp hx with rfl | hx
    · rw [hv]; rfl
    · exact ih x hx

/-- The input a cache relation gives at a stage's cache coordinate. -/
theorem CacheValuesV.inputs {cs : List Cache} {hs : List Handles} (h : CacheValuesV ev cs hs) (p i : Nat) :
    (cs[p]?).bind (fun c => (cacheTensor c i).bind fun t => ev t.node) =
      (hs[p]?).bind (fun h => cacheValue h i) := by
  induction h generalizing p with
  | nil => rfl
  | @cons c h cs hs hc hrest ih =>
    cases p with
    | succ p => exact ih p
    | zero =>
      obtain ⟨ta, tb, a, b, ht, hu, hv, ha, hb⟩ := hc
      cases i with
      | zero => simpa [cacheTensor, cacheValue, ht, hv] using ha
      | succ i =>
        cases i with
        | zero => simpa [cacheTensor, cacheValue, hu, hv] using hb
        | succ i => simp [cacheTensor, cacheValue]

/-- A checked output-carrier match and the expected graph's cache results give the next cache values. -/
theorem cacheValuesV_of_facts (cs : List Cache) (ps : List (Nat × Nat)) (hs : List Handles)
    (carrier : Nat → Nat)
    (hcar : cs.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      ps.map (fun (a, b) => (some (carrier a), some (carrier b))))
    (hlen : ps.length = hs.length) (hsome : ∀ h ∈ hs, (handleVals h).isSome)
    (hev : ∀ q ∈ cacheFacts ps hs, ev (carrier q.1) = some q.2) : CacheValuesV ev cs hs := by
  induction ps generalizing cs hs with
  | nil =>
    cases cs with
    | nil => cases hs <;> simp_all [CacheValuesV]
    | cons c cs => simp at hcar
  | cons p ps ih =>
    cases cs with
    | nil => simp at hcar
    | cons c cs =>
      cases hs with
      | nil => simp at hlen
      | cons h hs =>
        have hc := List.cons.inj hcar
        have hl : ps.length = hs.length := by simpa using hlen
        have populated := hsome h (List.mem_cons_self ..)
        cases ht : c.first with
        | none => simp [ht] at hc
        | some ta =>
          cases hu : c.second with
          | none => simp [hu] at hc
          | some tb =>
            have ha : ta.node = carrier p.1 := by simpa [ht] using congrArg Prod.fst hc.1
            have hb : tb.node = carrier p.2 := by simpa [hu] using congrArg Prod.snd hc.1
            cases hv : handleVals h with
            | none => simp [hv] at populated
            | some pair =>
              rcases pair with ⟨a, b⟩
              apply List.Forall₂.cons
              · refine ⟨ta, tb, a, b, ht, hu, hv, ?_, ?_⟩
                · rw [ha]
                  exact hev (p.1, a) (by simp [cacheFacts, hv])
                · rw [hb]
                  exact hev (p.2, b) (by simp [cacheFacts, hv])
              · exact ih cs hs hc.2 hl (fun x hx => hsome x (List.mem_cons_of_mem _ hx))
                  (fun q hq => hev q (by simp only [cacheFacts, hv]; exact List.mem_append_right _ hq))

end

theorem CacheValues.toV {C : M1Max.Contract} {M : MlxContract C} {K : KernelContract C} {env : FfiEval.Env InKey}
    {G : Nat → Option (RNode Int InKey)} {cs : List Cache} {hs : List Handles}
    (h : CacheValues M K env G cs hs) : CacheValuesV (evalR M K env G) cs hs := h

/-! ## The route resolution keeps the decode resolution's nodes -/

section
variable {κ : Type}

theorem resolvePrim_arange (N : Nums Int) (kn : Nat → Option (List Char)) (shape : List Ffi.Dim) (dtype : Nat) :
    ∀ (p : Ffi.Prim) (a b c) (q : RPrim Int κ), underReplay p = .arange a b c → resolvePrim N kn shape dtype p = some q →
      strip q = .unsupported
  | .arange _ _ _, _, _, _, q, _, h => by simp [resolvePrim] at h; subst h; rfl
  | .replayed c' p, a, b, c, q, hu, h => by
    have hu' : underReplay p = .arange a b c := hu
    obtain ⟨q', hq', rfl⟩ := Option.map_eq_some_iff.mp (show (resolvePrim N kn shape dtype p).map (RPrim.replayed c') = some q from h)
    exact resolvePrim_arange N kn shape dtype p a b c q' hu' hq'
  | .data _, _, _, _, _, hu, _ | .load _ _, _, _, _, _, hu, _ | .tracer _, _, _, _, _, hu, _ | .zeros, _, _, _, _, hu, _
  | .reshape _, _, _, _, _, hu, _ | .transpose _, _, _, _, _, hu, _ | .slice _ _ _, _, _, _, _, hu, _
  | .sliceUpdate _ _ _, _, _, _, _, hu, _ | .sliceDynamic _ _, _, _, _, _, hu, _ | .concat _, _, _, _, _, hu, _
  | .unary _, _, _, _, _, hu, _ | .binary _, _, _, _, _, hu, _ | .astype _, _, _, _, _, hu, _
  | .contiguous, _, _, _, _, hu, _ | .rmsNorm _, _, _, _, _, hu, _ | .rope _ _ _ _ _, _, _, _, _, hu, _
  | .sdpa _ _, _, _, _, _, hu, _ | .qmm _ _ _ _, _, _, _, _, hu, _ | .dequantize _ _ _ _, _, _, _, _, hu, _
  | .take _, _, _, _, _, hu, _ | .conv1d _ _ _ _, _, _, _, _, hu, _ | .logsumexp _ _, _, _, _, _, hu, _
  | .kernel _ _ _, _, _, _, _, hu, _ => by simp [underReplay] at hu

/-- **The route resolution keeps every decode-resolved node with an evaluable primitive.** -/
theorem ffiGraph_route (N : Nums Int) (S : KernelSources) (s : Ffi.St) (j : Nat) (nd : RNode Int κ)
    (h : ffiGraph N S s j = some nd) (hn : strip nd.prim ≠ .unsupported) : ffiGraphR N S s j = some nd := by
  apply ffiGraphP_route
  unfold ffiGraph at h
  unfold ffiGraphP
  obtain ⟨n, hget, hres⟩ := Option.bind_eq_some_iff.mp h
  rw [hget, Option.bind_some]
  obtain ⟨q, hq, rfl⟩ := Option.map_eq_some_iff.mp hres
  unfold resolveNodeP
  have hpe : resolvePrimP (κ := κ) N (kernelName? S s) n.shape n.dtype n.prim =
      resolvePrim N (kernelName? S s) n.shape n.dtype n.prim := by
    apply resolvePrimP_eq
    intro a b c hu
    exact hn (resolvePrim_arange N _ _ _ _ a b c q hu hq)
  rw [hpe, hq]
  rfl

end

/-! ## A forward at the route's values -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
  (env : FfiEval.Env InKey) (kind : Nat → Option Compiled) (Z : Nat → Option Value)

/-- The route graph of a native state at table `tab`. -/
noncomputable abbrev GrR (tab : List F64) (x : Ffi.St) : Nat → Option (RNode Int InKey) :=
  ffiGraphR (κ := InKey) (concrete (CSrv.val ⟨tab⟩)) SourceKernels.sources x

/-- **The route's values** of a native state's nodes at table `tab`, `Z` the recorded values. -/
noncomputable abbrev routeVal (tab : List F64) (x : Ffi.St) : Nat → Option Value :=
  evalZ P KR env kind Z (GrR tab x)

/-- A carried input's value at the route's values. -/
def HeldV (ev : Nat → Option Value) (E : List (RNode Int InKey)) (cert : List Nat) (envE : FfiEval.Env InKey) : Prop :=
  ∀ k e key v, E[k]? = some e → e.prim = .input key → envE.inputs key = some v → ev (certAt cert k) = some v

/-- `inputsHeld_cached` at values `ev`. -/
theorem heldV_cached (ev : Nat → Option Value) (l : Loaded) (token : Tensor) (value : TensorValues)
    (envE : FfiEval.Env InKey) (E : List (RNode Int InKey)) (cert : List Nat) (hs : List Handles)
    (hp : ∀ t, t ∈ parameterTensors l → ev t.node = some (value t))
    (hi : ∀ key, key ≠ .tokenIds → isCacheKey key = false → envE.inputs key = (parameterInput l key).map value)
    (hc : CacheValuesV ev l.cache hs)
    (hci : ∀ p i, envE.inputs (.stage p (.cache i)) = (hs[p]?).bind fun h => cacheValue h i)
    (ht : ∀ v, envE.inputs .tokenIds = some v → ev token.node = some v)
    (hm : inputCarriersMatch E cert (inputNode l token) = true) : HeldV ev E cert envE := by
  intro k e key v he hpk hv
  have hn := inputCarriersMatch_get E cert (inputNode l token) hm k e key he hpk
  generalize certAt cert k = n at hn ⊢
  by_cases hk : key = .tokenIds
  · subst key
    have hnode : token.node = n := Option.some.inj hn
    rw [← hnode]
    exact ht v hv
  · by_cases hcache : isCacheKey key = true
    · obtain ⟨p, i, rfl⟩ := (isCacheKey_iff key).mp hcache
      cases hstage : l.model.stages[p]? with
      | none => simp [inputNode, hstage] at hn
      | some stage =>
        rw [inputNode_cache l token p i stage hstage] at hn
        obtain ⟨t, htensor, rfl⟩ := Option.map_eq_some_iff.mp hn
        obtain ⟨c, hlookup, hselected⟩ := Option.bind_eq_some_iff.mp htensor
        rw [hci] at hv
        have := hc.inputs p i
        rw [hlookup, Option.bind_some, hselected, Option.bind_some] at this
        exact this.trans hv
    · have hfalse : isCacheKey key = false := Bool.eq_false_iff.mpr hcache
      have hparam := inputNode_parameter l token key n hk hfalse hn
      obtain ⟨t, htensor, rfl⟩ := Option.map_eq_some_iff.mp hparam
      rw [hi key hk hfalse, htensor] at hv
      exact (hp t (parameterInput_mem l key htensor)).trans hv

local notation "Mx" => P.toMlxContract
local notation "Kx" => KR.toKernelContract

/-- **`template_stepM` at the route's values**: a decode-resolved graph carrying the decode template, the route graph
holds the trace's next token at the output carrier and its next caches at the cache carriers. -/
theorem template_stepV (tab : List F64) (x : Ffi.St) (w : PipelineWeights) (time token : Nat) (hs hs' : List Handles)
    (t : Nat) (ids : Value)
    (hembed : bufferEmbed Mx w.embedWords w.embedScales w.embedBiases ids =
      embedTrace Mx w.embedWords w.embedScales w.embedBiases token)
    (hfn : w.finalNorm.shape = [5120]) (hsh : ShapesOk (stageWeights w) hs)
    (e : stepTrace Mx Kx w time token hs = some (t, hs'))
    (c : Nat) (caps : CapsFor c (stageWeights w) hs)
    (T : Template w) (branch : kvSig (some T.c₀) T.n₀ = kvSig (some c) time) (σ cl : Nat → Nat)
    (emb : Embeds σ cl (mapG (SDim.eval time) T.Gs) (Gr tab x))
    (hin : HeldV (routeVal P KR env kind Z tab x) (stepGraphOf w hs time).1 (T.cert.map σ)
      (stepEnvWithIds env.weights w ids hs)) :
    (∃ r, routeVal P KR env kind Z tab x (σ (certAt T.cert (templateOf w T.hs₀ T.n₀).2.1)) = some r ∧
        itemUint32 r = some t) ∧
      CapsFor (kvCap (some c) time) (stageWeights w) hs' ∧
      (templateOf w T.hs₀ T.n₀).2.2.length = hs'.length ∧
      (∀ h ∈ hs', (handleVals h).isSome) ∧
      ∀ q ∈ cacheFacts (templateOf w T.hs₀ T.n₀).2.2 hs',
        routeVal P KR env kind Z tab x (σ (certAt T.cert q.1)) = some q.2 := by
  have hm := template_matches w T hs c time caps branch _ σ cl emb
  have hcarry := matches_evalZ P KR env (stepEnvWithIds env.weights w ids hs) kind Z rfl
    (fun j nd hj hne => ffiGraph_route _ _ _ j nd hj hne) hm hin
  obtain ⟨⟨r, hlt, hr, ht⟩, hlen, hsome, hcf⟩ :=
    stepGraph_eval_ids Mx Kx env.weights w time token ids hembed hs hs' t hfn hsh e
  have hinst := template_instance w T hs c time caps branch
  have h2 : (templateOf w T.hs₀ T.n₀).2 = (stepGraphOf w hs time).2 := congrArg Prod.snd hinst
  have hE : (stepGraphOf w hs time).1.length ≤ T.cert.length := by
    rw [← congrArg Prod.fst hinst, List.length_map]; exact T.length
  refine ⟨?_, capsFor_step Mx Kx w time _ hs hs' _ c caps e, by rw [h2]; exact hlen, hsome, ?_⟩
  · refine ⟨r, ?_, ht⟩
    rw [h2, ← certAt_map σ T.cert _ (by omega)]
    exact hcarry _ hlt r hr
  · intro q hq
    rw [h2] at hq
    obtain ⟨hql, hqv⟩ := hcf q hq
    rw [← certAt_map σ T.cert _ (by omega)]
    exact hcarry _ hql _ hqv

/-- The token fed back by reshaping the previous output holds its singleton value at the route's values. -/
theorem feedback_routeVal (tab : List F64) (x : Ffi.St) (node input tok : Nat) (r : Value)
    (hn : Gr tab x node = some ⟨.reshape [1, 1], [input]⟩) (hi : input < node)
    (hv : routeVal P KR env kind Z tab x input = some r) (hr : itemUint32 r = some tok) (ht : tok < 2 ^ 31) :
    ∃ ids, routeVal P KR env kind Z tab x node = some ids ∧ TokenBuffer ids tok := by
  have hsize : r.size = 1 := by
    unfold itemUint32 at hr
    split at hr
    · next h => exact h.2
    · cases hr
  let ids : Value := { r with shape := [1, 1] }
  have hs : reshape r [1, 1] = some ids := by
    simp only [reshape, List.foldr_cons, List.foldr_nil, Nat.mul_one, hsize, ↓reduceIte]
    rfl
  refine ⟨ids, ?_, TokenBuffer.of_readback r ids tok hr hs ht⟩
  have hnR : GrR tab x node = some ⟨.reshape [1, 1], [input]⟩ := ffiGraph_route _ _ _ _ _ hn (by simp)
  have hp : primEval Mx Kx env (.reshape [1, 1]) [r] = some ids := by
    change reshapeDims r [1, 1] = some ids
    exact hs
  have hpR : primEvalR P KR env (κ := InKey) (.reshape [1, 1]) [r] = some ids :=
    primEvalR_of P KR env (by simp [primEvalP, hp, Option.orElse])
  have hcl : closureLeaves kind (GrR tab x) node = none := by
    unfold closureLeaves
    rw [hnR]
    rfl
  unfold routeVal
  rw [evalZ_eq, hnR]
  dsimp only
  rw [cgLeaves_none _ _ _ hnR rfl]
  dsimp only
  rw [hcl]
  dsimp only
  simp only [List.mapM_cons, List.mapM_nil, hi, ↓reduceDIte]
  have hv' : evalZ P KR env kind Z (GrR tab x) input = some r := hv
  simp [hv', hpR, Option.orElse]

variable (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)

include leaves typed in
/-- **`template_cached_forwardM` at the route's values.** The carried template and the feedback are read on the
decode-resolved graph, unchanged; the parameters, the caches and the previous output at the route's values. -/
theorem template_cached_forwardV (table : List F64) (time : Nat)
    (native : Host.Mlx.Ffi.St) (l : Loaded) (token : Tensor) (previousNode outputNode : Nat)
    (tok tok' : Nat) (hs hs' : List Handles) (nextCache : List Cache) (c : Nat)
    (step : stepTrace Mx Kx (weights (firstValues Mx Kx env table)) time tok hs = some (tok', hs'))
    (bounded : tok < 2 ^ 31)
    (compat : List.Forall₂ CacheCompatible (stageWeights (weights (firstValues Mx Kx env table))) hs)
    (shapes : ShapesOk (stageWeights (weights (firstValues Mx Kx env table))) hs)
    (T : Template (weights (firstValues Mx Kx env table))) (σ cl : Nat → Nat)
    (hmodel : l.model = parameterChoice.model)
    (parameterValues : ∀ t ∈ parameterTensors parameterChoice,
      routeVal P KR env kind Z table native t.node = some (firstValues Mx Kx env table t))
    (caps : CapsFor c (stageWeights (weights (firstValues Mx Kx env table))) hs)
    (branch : kvSig (some T.c₀) T.n₀ = kvSig (some c) time)
    (caches : CacheValuesV (routeVal P KR env kind Z table native) l.cache hs)
    (feedback : Gr table native token.node = some ⟨.reshape [1, 1], [previousNode]⟩)
    (earlier : previousNode < token.node)
    (previous : ∃ r, routeVal P KR env kind Z table native previousNode = some r ∧ itemUint32 r = some tok)
    (carried : Embeds σ cl (mapG (SDim.eval time) T.Gs) (Gr table native))
    (inputs : inputCarriersMatch (stepGraphOf (weights (firstValues Mx Kx env table)) hs time).1 (T.cert.map σ)
      (inputNode l token) = true)
    (outputs : nextCache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      (templateOf (weights (firstValues Mx Kx env table)) T.hs₀ T.n₀).2.2.map
        (fun (a, b) => (some (σ (certAt T.cert a)), some (σ (certAt T.cert b)))))
    (tokenOutput : σ (certAt T.cert (templateOf (weights (firstValues Mx Kx env table)) T.hs₀ T.n₀).2.1) = outputNode) :
    (∃ r, routeVal P KR env kind Z table native outputNode = some r ∧ itemUint32 r = some tok') ∧
      CacheValuesV (routeVal P KR env kind Z table native) nextCache hs' ∧
      CapsFor (kvCap (some c) time) (stageWeights (weights (firstValues Mx Kx env table))) hs' := by
  let value := firstValues Mx Kx env table
  let p := firstPipeline Mx Kx env table leaves typed
  have hl := firstPipeline_loaded Mx Kx env table leaves typed
  obtain ⟨r, hr, hi⟩ := previous
  obtain ⟨ids, hids, buffer⟩ := feedback_routeVal P KR env kind Z table native token.node previousNode tok r feedback
    earlier hr hi bounded
  have hp : ∀ t, t ∈ parameterTensors l → routeVal P KR env kind Z table native t.node = some (value t) := by
    intro t ht
    have ht' : t ∈ parameterTensors parameterChoice := by
      simpa only [parameterTensors, hmodel] using ht
    exact parameterValues t ht'
  have hin : HeldV (routeVal P KR env kind Z table native)
      (stepGraphOf (weights value) hs time).1 (T.cert.map σ) (stepEnvWithIds env.weights (weights value) ids hs) := by
    apply heldV_cached _ l token value _ _ _ hs hp
    · intro key hk hnc
      have parameters : parameterInput l key = parameterInput parameterChoice key := by
        cases key <;> simp only [parameterInput, hmodel]
      rw [parameters]
      have loaded := stages_loaded Mx Kx p (weights value) hl
      have initial := cacheCompatible_of_holds Mx Kx _ _ initialHandles _ loaded (initialChainHolds p)
      exact (stepInputsWithIds_parameter_eq _ ids hs initialHandles compat initial key hnc).trans
        (initial_input_values value ids key hk)
    · exact caches
    · intro q i
      exact stepInputsWithIds_cache_value _ ids hs compat caches.populated q i
    · intro v hv
      have : ids = v := by simpa [stepEnvWithIds, stepInputsWithIds] using hv
      rw [← this]
      exact hids
    · exact inputs
  have hembed := bufferEmbed_eq Mx (weights value).embedWords (weights value).embedScales (weights value).embedBiases
    ids _ buffer hl.embedding.words.1 hl.embedding.words.2.1 hl.embedding.scales.2.1 hl.embedding.biases.2.1
  obtain ⟨⟨r', hr', htoken⟩, hcaps, hlen, hsome, hev⟩ :=
    template_stepV P KR env kind Z table native (weights value) time tok hs hs' tok' ids hembed hl.finalNorm.2.1 shapes
      step c caps T branch σ cl carried hin
  have out := cacheValuesV_of_facts nextCache _ hs' (fun a => σ (certAt T.cert a)) outputs hlen hsome hev
  refine ⟨⟨r', ?_, htoken⟩, out, hcaps⟩
  rw [← tokenOutput]
  exact hr'

end

end Host.Mlx.SimGraph.Mach
