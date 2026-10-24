import host.simgraph.iter.RefStep
import host.simgraph.ref.Decode
import host.simgraph.ref.Route
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Ref
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Kernels Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (RefRun RefDecodes refPrompt1 hpOf)
open TokenAutoregressive (State)

/-! # The model-level reference of a prompt (`refPromptModel π`)

The route's reference is machine-level (`host.simgraph.mach.Ref`: the prefill's values, then the decode
trace). This is its model-level statement, where the prefill's caches are within the model's ranges: the
prefill's steps along `nextStep` (`prefillState` of `routeStep`) from the empty caches and the loaded
surfaces, then the final step and the decode from the reached state at time `L - 1` — the prompt's last token
and the model cache the prefill's handles hold (`preState`) — by the reached context's steps (`refFrom`).
`host.simgraph.mach.Refine` proves the two agree wherever this one is defined.

* `PrefillHolds π`: the prefill's handles hold a reached state at time `L - 1` (a model cache within the
  decode chain's ranges, with its error certificate) at every table — the multi-row analogue of
  `Context.run_invariant`. It cannot be proved from `L = 3` on under the trust boundary (the prefill's MMA
  kernels, `C.simdMma`, and the Neural Engine, `NE.eval`, have no accuracy contract); `prefillHolds_one` and
  `host.simgraph.mach.Refine.prefillHolds_two` prove it at one and two tokens.
* `refPromptModel π h : RefRun`; `refPromptModel_start`: at `L - 1` its token is the prompt's last and its
  cache is held by the prefill's handles; `refPromptModel_decodes`: `RefDecodes (refPromptModel π h) (L - 1)`
  (the final step too), `refPromptModel_decodesL`: from `L` (what `template_cached_forwardR` takes).
* `refPromptModel_tokens`: the token sequence against the model's definitions.
* `refPromptModel_one`: at the one-token prompt `promptToken` every token and cache is the existing
  reference's (`refPrompt1`). -/

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (NE : NeuralEngine)
  (IP : InPlace) (net : AneNet) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
  (typed : TypedCheckpoint env.weights)
  (parameters : TokenSequenceRanges.Parameters (firstPipeline P.toMlxContract K.toKernelContract env [] leaves typed))
  (π : List Nat)

/-- **The prompt's prefill** at table `tab`: the route's steps from the empty caches and the loaded surfaces;
the state at offset `L - 1`. -/
noncomputable def prefillAt (tab : List F64) : Option RSt :=
  prefillState (routeStep P K NE IP net env.weights (weights (firstValues P.toMlxContract K.toKernelContract env tab)) π)
    π.length ⟨initialHandles, net.surfaces, []⟩

/-- **The prefill's range premise**: at every table the prefill's handles hold the cache of a reached state at
time `L - 1`. -/
def PrefillHolds : Prop :=
  ∀ tab, ∃ st : State (firstPipeline P.toMlxContract K.toKernelContract env tab leaves typed) (π.length - 1),
    ∃ s, prefillAt P K NE IP net env π tab = some s ∧
      ChainHolds (firstPipeline P.toMlxContract K.toKernelContract env tab leaves typed).graph.stages s.hs st.cache

/-- The prompt's last token. -/
def lastToken (π : List Nat) : Fin 248320 := ⟨π.getD (π.length - 1) 0 % 248320, Nat.mod_lt _ (by decide)⟩

variable {P K NE IP net env leaves typed π}

/-- **The reached state after the prefill**: the prompt's last token and the cache the prefill's handles hold. -/
noncomputable def preState (h : PrefillHolds P K NE IP net env leaves typed π) (tab : List F64) :
    State (firstPipeline P.toMlxContract K.toKernelContract env tab leaves typed) (π.length - 1) :=
  { Classical.choose (h tab) with token := lastToken π }

variable (P K NE IP net env leaves typed π)

/-- **The reference of the prompt `π`**: at each table, the reached state after the prefill at `L - 1`, then the
reached context's steps (the decode of the existing reference's context before `L - 1`, where nothing reads it). -/
noncomputable def refPromptModel (h : PrefillHolds P K NE IP net env leaves typed π) :
    RefRun P.toMlxContract K.toKernelContract env leaves typed :=
  fun tab time hb =>
    refFrom P.toMlxContract K.toKernelContract (firstPipeline P.toMlxContract K.toKernelContract env tab leaves typed)
      (weights (firstValues P.toMlxContract K.toKernelContract env tab))
      (firstPipeline_loaded P.toMlxContract K.toKernelContract env tab leaves typed)
      (hpOf P.toMlxContract K.toKernelContract env leaves typed parameters tab) (preState h tab)
      (fun t ht => refPrompt1 P.toMlxContract K.toKernelContract env leaves typed parameters tab t ht) time hb

variable {P K NE IP net env leaves typed parameters π}

/-- **At `L - 1`**: the prompt's last token, a cache the prefill's handles hold. -/
theorem refPromptModel_start (h : PrefillHolds P K NE IP net env leaves typed π) (tab : List F64)
    (hb : π.length - 1 ≤ 262144) :
    refPromptModel P K NE IP net env leaves typed parameters π h tab (π.length - 1) hb = preState h tab ∧
      (preState h tab).token = lastToken π ∧
      ∃ s, prefillAt P K NE IP net env π tab = some s ∧
        ChainHolds (firstPipeline P.toMlxContract K.toKernelContract env tab leaves typed).graph.stages s.hs
          (preState h tab).cache :=
  ⟨refFrom_start _ _ hb, rfl, Classical.choose_spec (h tab)⟩

/-- **The reference decodes from `L - 1` on** (the final step included). -/
theorem refPromptModel_decodes (h : PrefillHolds P K NE IP net env leaves typed π) :
    RefDecodes P.toMlxContract K.toKernelContract env leaves typed (refPromptModel P K NE IP net env leaves typed parameters π h)
      (π.length - 1) :=
  fun _ _ hs' hL hs hh => refFrom_step _ _ hL hs' hs hh

/-- **The reference decodes from `L` on.** -/
theorem refPromptModel_decodesL (h : PrefillHolds P K NE IP net env leaves typed π) :
    RefDecodes P.toMlxContract K.toKernelContract env leaves typed (refPromptModel P K NE IP net env leaves typed parameters π h)
      π.length :=
  fun _ _ hs' hL hs hh => refFrom_step _ _ (by omega) hs' hs hh

/-- **The token sequence of the prompt's reference, against the model's definitions.** At every table, with
`p` the loaded pipeline: the prefill's handles hold the reference's cache at `L - 1`, where its token is the
prompt's last; from there each next token is `GreedySampling.sample` of the pipeline's logits
(`TokenInference.Pipeline.run`) at the reference's cache and token with the route's RoPE inputs of the time,
and each next cache the pipeline's next cache. With a prompt of tokens below `2^31` the last token is
`π[L - 1]` (`lastToken_eq`). So the reference's token at `L + j` (the `j + 1`-th the route emits) is the
sampled token of the model's logits after prefilling `π` and decoding `j` tokens. -/
theorem refPromptModel_tokens (h : PrefillHolds P K NE IP net env leaves typed π) (tab : List F64) :
    let p := firstPipeline P.toMlxContract K.toKernelContract env tab leaves typed
    let R := refPromptModel P K NE IP net env leaves typed parameters π h tab
    (∀ hb : π.length - 1 ≤ 262144, (R (π.length - 1) hb).token = lastToken π ∧
      ∃ s, prefillAt P K NE IP net env π tab = some s ∧ ChainHolds p.graph.stages s.hs (R (π.length - 1) hb).cache) ∧
    ∀ time (hb : time + 1 ≤ 262144), π.length - 1 ≤ time →
      (R (time + 1) hb).token.val =
          Sampling.GreedySampling.sample K.sampling
            (p.run (R time (by omega)).cache (R time (by omega)).token (RopeInputConstruction.inputs time)).1 ∧
        (R (time + 1) hb).cache =
          (p.run (R time (by omega)).cache (R time (by omega)).token (RopeInputConstruction.inputs time)).2 := by
  dsimp only
  refine ⟨fun hb => ?_, fun time hb hL => refFrom_model _ _ hL hb⟩
  obtain ⟨e, ht, hc⟩ := refPromptModel_start (parameters := parameters) h tab hb
  refine ⟨by rw [e, ht], ?_⟩
  rw [e]; exact hc

theorem lastToken_eq {π : List Nat} (h1 : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320) :
    (lastToken π).val = π[π.length - 1]'(by omega) := by
  have hm : π[π.length - 1]'(by omega) ∈ π := List.getElem_mem _
  simp only [lastToken, List.getD_eq_getElem _ _ (show π.length - 1 < π.length by omega)]
  exact Nat.mod_eq_of_lt (hlt _ hm)

/-! ## The one-token prompt -/

theorem holds_initial_unique : ∀ (stages : List DecodeStage.Stage) (c : DecodeChain.Caches stages 0),
    ChainHolds stages (handlesFor stages) c → c = InitialState.caches stages
  | [], c, _ => rfl
  | .delta _ :: ss, ⟨c1, c2⟩, ⟨⟨h1, h2⟩, h3⟩ => by
    have e := holds_initial_unique ss c2 h3
    obtain ⟨hist, rec⟩ := c1
    change hist = _ at h1
    change rec = _ at h2
    subst h1 h2 e
    rfl
  | .attention _ :: ss, ⟨c1, c2⟩, ⟨_, h3⟩ => by
    have e := holds_initial_unique ss c2 h3
    subst e
    obtain ⟨ks, vs⟩ := c1
    have hk : ks = fun _ t _ => Fin.elim0 t := funext fun _ => funext fun t => Fin.elim0 t
    have hv : vs = fun _ t _ => Fin.elim0 t := funext fun _ => funext fun t => Fin.elim0 t
    subst hk hv
    rfl

variable (P K NE IP net env leaves typed)

/-- **At the one-token prompt the premise holds**: the prefill is empty, the empty caches hold the initial state. -/
theorem prefillHolds_one : PrefillHolds P K NE IP net env leaves typed [promptToken.val] :=
  fun _ => ⟨TokenAutoregressive.initial _ promptToken, ⟨initialHandles, net.surfaces, []⟩, rfl,
    initialChainHolds _⟩

variable {P K NE IP net env leaves typed}

/-- **At the one-token prompt the reference is the existing one**: every token and cache of `refPromptModel` is
`refPrompt1`'s. -/
theorem refPromptModel_one (h : PrefillHolds P K NE IP net env leaves typed [promptToken.val]) (tab : List F64) :
    ∀ time (hb : time ≤ 262144),
      (refPromptModel P K NE IP net env leaves typed parameters [promptToken.val] h tab time hb).token =
          (refPrompt1 P.toMlxContract K.toKernelContract env leaves typed parameters tab time hb).token ∧
        (refPromptModel P K NE IP net env leaves typed parameters [promptToken.val] h tab time hb).cache =
          (refPrompt1 P.toMlxContract K.toKernelContract env leaves typed parameters tab time hb).cache
  | 0, hb => by
    obtain ⟨e, ht, s, hs, hc⟩ := refPromptModel_start (parameters := parameters) h tab (by decide)
    change refPromptModel P K NE IP net env leaves typed parameters [promptToken.val] h tab 0 hb = _ at e
    rw [e]
    have hs0 : s = ⟨initialHandles, net.surfaces, []⟩ := by
      have : prefillAt P K NE IP net env [promptToken.val] tab = some ⟨initialHandles, net.surfaces, []⟩ := rfl
      rw [this] at hs; cases hs; rfl
    subst hs0
    refine ⟨by rw [ht]; rfl, ?_⟩
    have hu := holds_initial_unique _ _ (by rw [graph_initial_handles]; exact hc)
    exact hu
  | t + 1, hb => by
    obtain ⟨ih1, ih2⟩ := refPromptModel_one h tab t (by omega)
    have hs : refPromptModel P K NE IP net env leaves typed parameters [promptToken.val] h tab (t + 1) hb =
        advanceC P.toMlxContract K.toKernelContract _ _ (firstPipeline_loaded P.toMlxContract K.toKernelContract env tab leaves typed)
          (hpOf P.toMlxContract K.toKernelContract env leaves typed parameters tab)
          (refPromptModel P K NE IP net env leaves typed parameters [promptToken.val] h tab t (by omega)) hb :=
      refFrom_succ _ _ (Nat.zero_le t) hb
    rw [hs]
    obtain ⟨et, ec⟩ := advanceC_data P.toMlxContract K.toKernelContract _ _
      (firstPipeline_loaded P.toMlxContract K.toKernelContract env tab leaves typed)
      (hpOf P.toMlxContract K.toKernelContract env leaves typed parameters tab)
      (refPromptModel P K NE IP net env leaves typed parameters [promptToken.val] h tab t (by omega)) hb
    obtain ⟨et1, ec1⟩ := advanceC_data P.toMlxContract K.toKernelContract _ _
      (firstPipeline_loaded P.toMlxContract K.toKernelContract env tab leaves typed)
      (hpOf P.toMlxContract K.toKernelContract env leaves typed parameters tab)
      (refPrompt1 P.toMlxContract K.toKernelContract env leaves typed parameters tab t (by omega)) hb
    have e1 : refPrompt1 P.toMlxContract K.toKernelContract env leaves typed parameters tab (t + 1) hb =
        advanceC P.toMlxContract K.toKernelContract _ _ (firstPipeline_loaded P.toMlxContract K.toKernelContract env tab leaves typed)
          (hpOf P.toMlxContract K.toKernelContract env leaves typed parameters tab)
          (refPrompt1 P.toMlxContract K.toKernelContract env leaves typed parameters tab t (by omega)) hb := rfl
    rw [e1]
    refine ⟨Fin.ext ?_, ?_⟩
    · rw [et, et1, ih1, ih2]
    · rw [ec, ec1, ih1, ih2]

end Host.Mlx.SimGraph.Ref
