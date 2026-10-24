import host.simgraph.mach.Ref
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Mach
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Ref (prefillAt RSt AneNet PrefillHolds refPromptModel refPromptModel_start
  refPromptModel_decodes lastToken lastToken_eq d1Sem gpuTail prefill_short)
open Host.Mlx.SimGraph.Iter (hpOf)
open TokenAutoregressive (State)

/-! # The model-level reference refines the machine-level one

Where the prefill's caches are within the model's ranges (`PrefillHolds π`), the machine-level reference
(`refPrompt`) is the model-level one (`refPromptModel`): at every time from `L - 1` on, the same token, and
handles holding the model's cache (`refPrompt_refines`). The premise holds at one token (`prefillHolds_one`)
and at two (`prefillHolds_two`: the first row runs as a one-row D1 drain, the decode trace, which the
model's step covers from the empty caches; no MMA kernel and no Neural Engine run). From three tokens on the
prefill runs the MMA kernels, whose arithmetic has no accuracy contract. Nothing depends on this module. -/

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (NE : NeuralEngine)
  (IP : InPlace) (net : AneNet) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
  (typed : TypedCheckpoint env.weights)
  (parameters : TokenSequenceRanges.Parameters (firstPipeline P.toMlxContract K.toKernelContract env [] leaves typed))

/-- **The model-level reference refines the machine-level one**: with the prefill's caches within the model's
ranges and the prompt's tokens in the vocabulary, from `L - 1` on the machine reference has the model's token
and handles holding the model's cache. -/
theorem refPrompt_refines {π : List Nat} (h : PrefillHolds P K NE IP net env leaves typed π)
    (hlt : ∀ t ∈ π, t < 248320) (h1 : 1 ≤ π.length) (tab : List F64) :
    ∀ k (hb : π.length - 1 + k ≤ 262144), ∃ hs,
      refPrompt P K NE IP net env π tab (π.length - 1 + k) =
          some ((refPromptModel P K NE IP net env leaves typed parameters π h tab (π.length - 1 + k) hb).token.val, hs) ∧
        ChainHolds (firstPipeline P.toMlxContract K.toKernelContract env tab leaves typed).graph.stages hs
          (refPromptModel P K NE IP net env leaves typed parameters π h tab (π.length - 1 + k) hb).cache
  | 0, hb => by
    obtain ⟨e, ht, s, hs, hc⟩ := refPromptModel_start (parameters := parameters) h tab hb
    change ∃ hs, refPrompt P K NE IP net env π tab (π.length - 1) =
        some ((refPromptModel P K NE IP net env leaves typed parameters π h tab (π.length - 1) hb).token.val, hs) ∧
      ChainHolds _ hs (refPromptModel P K NE IP net env leaves typed parameters π h tab (π.length - 1) hb).cache
    rw [e]
    refine ⟨s.hs, ?_, hc⟩
    rw [refPrompt_start, hs, ht, lastToken_eq h1 hlt,
      List.getD_eq_getElem _ _ (show π.length - 1 < π.length by omega)]
    rfl
  | k + 1, hb => by
    obtain ⟨hs, hR, hh⟩ := refPrompt_refines h hlt h1 tab k (by omega)
    obtain ⟨hs', e, hh'⟩ := refPromptModel_decodes (parameters := parameters) h tab (π.length - 1 + k) hb
      (by omega) hs hh
    refine ⟨hs', ?_, hh'⟩
    change refPrompt P K NE IP net env π tab (π.length - 1 + k + 1) =
      some ((refPromptModel P K NE IP net env leaves typed parameters π h tab (π.length - 1 + k + 1) hb).token.val, hs')
    rw [refPrompt_succ P K NE IP net env π tab _ (by omega), hR]
    exact e

/-- A one-row D1 drain is the decode trace's caches. -/
theorem d1Sem_of_stepTrace (w : PipelineWeights) (π : List Nat) (o tok : Nat) (hs hs' : List Handles) (t : Nat)
    (htok : π.getD o 0 = tok) (e : stepTrace P.toMlxContract K.toKernelContract w o tok hs = some (t, hs')) :
    d1Sem P K w π o hs = some hs' := by
  unfold stepTrace at e
  obtain ⟨x, e1, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨r2, e2, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨y, hs2⟩ := r2
  dsimp only at e
  obtain ⟨hn, _, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨logits, _, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨l, _, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨l6, _, e⟩ := Option.bind_eq_some_iff.mp e
  split at e
  · obtain ⟨t7, _, e⟩ := Option.bind_eq_some_iff.mp e
    have hr : (t7, hs2) = (t, hs') := Option.some.inj e
    cases hr
    unfold d1Sem
    rw [htok, e1]
    simp [e2]
  · cases e

include parameters in
/-- **At two tokens the premise holds**: the prefill is one D1 drain of the first token from the empty caches,
whose handles hold the model's state after it. -/
theorem prefillHolds_two (a b : Nat) (ha : a < 248320) : PrefillHolds P K NE IP net env leaves typed [a, b] := by
  intro tab
  let ctx := firstContext P.toMlxContract K.toKernelContract env tab leaves typed
    (hpOf P.toMlxContract K.toKernelContract env leaves typed parameters tab)
  obtain ⟨hs', e, hh⟩ := GlueM1Max.contextStep P.toMlxContract K.toKernelContract
    (firstPipeline P.toMlxContract K.toKernelContract env tab leaves typed)
    (weights (firstValues P.toMlxContract K.toKernelContract env tab))
    (firstPipeline_loaded P.toMlxContract K.toKernelContract env tab leaves typed)
    (hpOf P.toMlxContract K.toKernelContract env leaves typed parameters tab) ⟨a, ha⟩ 0 (by decide) initialHandles
    (initialChainHolds _)
  refine ⟨ctx.run ⟨a, ha⟩ 1 (by decide), ⟨hs', net.surfaces, []⟩, ?_, hh⟩
  unfold prefillAt
  rw [prefill_short (L := [a, b].length) P K NE IP net env.weights _ [a, b] (by simp) (by simp)]
  have hd := d1Sem_of_stepTrace P K (weights (firstValues P.toMlxContract K.toKernelContract env tab)) [a, b] 0 a
    initialHandles hs' _ rfl e
  simp only [gpuTail, List.length_cons, List.length_nil, show 0 + 1 + 1 - 1 = 1 from rfl, Nat.one_ne_zero,
    ↓reduceIte, hd, Option.map_some]

end Host.Mlx.SimGraph.Mach
