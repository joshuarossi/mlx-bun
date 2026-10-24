import host.simgraph.mach.Step
import host.simgraph.ref.Prompt
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Mach
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Ref (prefillAt RSt AneNet)

/-! # The machine-level reference of a prompt (`refPrompt π`)

The route's computation started from the prompt `π` of `L` tokens, at the machine level throughout: the
prefill's steps along `nextStep` (`prefillAt`: the forward families' value instances — the MMA kernels at
their kernel-contract values — the D1 drains' trace, the Neural Engine buckets' calls on the threaded
surfaces), from the empty caches and the loaded surfaces, to the handles at offset `L - 1`; then the D1
forward's trace (`stepTrace`: the decode step's graph evaluated, its token the normalized argmax of the lm
head's logits) from the prompt's last token, for the final step and every decode step. No model cache and no
range certificate enter: nothing bounds what the MMA kernels and the Neural Engine leave.

* `machFrom`, `refPrompt π : MRef`; `refPrompt_start`: at `L - 1` the prompt's last token and the prefill's
  handles; `refPrompt_succ`, `refPrompt_decodes` (`MRefDecodes … (L - 1)`): each next state is the trace's
  step.
* `refPrompt_tokens`: **the token sequence at the machine level** — from `L - 1` on, the token at `t + 1` is
  the sampled token of the logits of step `t`'s D1 family graph evaluated at the step's inputs (its output
  node: the normalized argmax of the lm head's logits), and the caches at `t + 1` are that graph's cache
  nodes' values. The family graph is the one the route builds (`d1_familyGraph`), so the decode loop's graph
  obligations are `ForwardAtM` at this reference (`template_cached_forwardM`, `d1_template_stepM`). -/

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- The decode trace's steps from the state `s0` at time `t0`: the state at `t0 + k`. -/
noncomputable def machFrom (w : PipelineWeights) (t0 : Nat) (s0 : Nat × List Handles) : Nat → Option (Nat × List Handles)
  | 0 => some s0
  | k + 1 => (machFrom w t0 s0 k).bind fun s => stepTrace M K w (t0 + k) s.1 s.2

section
variable (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine) (IP : InPlace) (net : AneNet)
  (env : FfiEval.Env InKey) (π : List Nat)

/-- **The machine-level reference of the prompt `π`**: at every table, from `L - 1` on, the prompt's last token
and the prefill's handles, then the D1 trace's steps. -/
noncomputable def refPrompt : MRef := fun tab t =>
  if π.length - 1 ≤ t then
    (prefillAt P KR NE IP net env π tab).bind fun s =>
      machFrom P.toMlxContract KR.toKernelContract (weights (firstValues P.toMlxContract KR.toKernelContract env tab))
        (π.length - 1) (π.getD (π.length - 1) 0, s.hs) (t - (π.length - 1))
  else none

/-- **At `L - 1`**: the prompt's last token and the prefill's handles. -/
theorem refPrompt_start (tab : List F64) :
    refPrompt P KR NE IP net env π tab (π.length - 1) =
      (prefillAt P KR NE IP net env π tab).map fun s => (π.getD (π.length - 1) 0, s.hs) := by
  unfold refPrompt
  rw [ite_eq_left le_rfl, Nat.sub_self]
  cases prefillAt P KR NE IP net env π tab <;> rfl

/-- **Each next state is the D1 trace's step** (from `L - 1` on). -/
theorem refPrompt_succ (tab : List F64) (t : Nat) (ht : π.length - 1 ≤ t) :
    refPrompt P KR NE IP net env π tab (t + 1) = (refPrompt P KR NE IP net env π tab t).bind fun s =>
      stepTrace P.toMlxContract KR.toKernelContract (weights (firstValues P.toMlxContract KR.toKernelContract env tab))
        t s.1 s.2 := by
  unfold refPrompt
  rw [ite_eq_left (by omega), ite_eq_left ht, show t + 1 - (π.length - 1) = (t - (π.length - 1)) + 1 by omega,
    Option.bind_assoc]
  congr 1; funext s
  show (machFrom _ _ _ _ _ (t - (π.length - 1))).bind _ = _
  congr 1; funext s'
  rw [show π.length - 1 + (t - (π.length - 1)) = t by omega]

/-- **The reference decodes from `L - 1` on.** -/
theorem refPrompt_decodes :
    MRefDecodes P.toMlxContract KR.toKernelContract (fun tab => weights (firstValues P.toMlxContract KR.toKernelContract env tab))
      (refPrompt P KR NE IP net env π) (π.length - 1) :=
  fun tab t ht => refPrompt_succ P KR NE IP net env π tab t ht

/-- **The token sequence of the prompt's reference at the machine level.** At every table, at `L - 1` the
prompt's last token and the prefill's handles; from there, whenever the reference is defined at `t` and `t + 1`
(handles of the route's shapes, a token below `2^31`): step `t`'s D1 family graph (`stepGraphOf`, the
graph the route builds, `d1_familyGraph`) evaluated at the step's inputs — the token's ids, the loaded weights,
the handles — has at its output node (the normalized argmax of the lm head's logits) the token at `t + 1`, and
at its cache nodes the handles at `t + 1`. -/
theorem refPrompt_tokens (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) (tab : List F64) :
    refPrompt P KR NE IP net env π tab (π.length - 1) =
        (prefillAt P KR NE IP net env π tab).map (fun s => (π.getD (π.length - 1) 0, s.hs)) ∧
      ∀ t, π.length - 1 ≤ t → ∀ tok tok' hs hs', refPrompt P KR NE IP net env π tab t = some (tok, hs) →
        refPrompt P KR NE IP net env π tab (t + 1) = some (tok', hs') → tok < 2 ^ 31 →
        ShapesOk (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) hs →
        (∃ r, evalR P.toMlxContract KR.toKernelContract
            (stepEnvWithIds env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) (tokenIds tok) hs)
            (listGraph (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs t).1)
            (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs t).2.1 = some r ∧
          itemUint32 r = some tok') ∧
        ∀ q ∈ cacheFacts (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs t).2.2 hs',
          evalR P.toMlxContract KR.toKernelContract
            (stepEnvWithIds env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) (tokenIds tok) hs)
            (listGraph (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs t).1) q.1 =
            some q.2 := by
  refine ⟨refPrompt_start P KR NE IP net env π tab, fun t ht tok tok' hs hs' h0 h1 hb hsh => ?_⟩
  have hl := firstPipeline_loaded P.toMlxContract KR.toKernelContract env tab leaves typed
  have e : stepTrace P.toMlxContract KR.toKernelContract (weights (firstValues P.toMlxContract KR.toKernelContract env tab))
      t tok hs = some (tok', hs') := by
    rw [refPrompt_succ P KR NE IP net env π tab t ht, h0] at h1
    exact h1
  have hembed := bufferEmbed_eq P.toMlxContract _ _ _ (tokenIds tok) tok ⟨.inl rfl, rfl, rfl, hb⟩
    hl.embedding.words.1 hl.embedding.words.2.1 hl.embedding.scales.2.1 hl.embedding.biases.2.1
  obtain ⟨⟨r, _, hr, hi⟩, _, _, hc⟩ := stepGraph_eval_ids P.toMlxContract KR.toKernelContract env.weights _ t tok
    (tokenIds tok) hembed hs hs' tok' hl.finalNorm.2.1 hsh e
  exact ⟨⟨r, hr, hi⟩, fun q hq => (hc q hq).2⟩

end

end Host.Mlx.SimGraph.Mach
