import host.simgraph.Native
import host.simgraph.Layout
import host.mlx.FfiCache
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.GlueStep
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # One decode iteration from a checked template

`Template w`: the decode-step graph built once at a representative offset
`n₀` and handles `hs₀` of capacity `c₀`, with symbolic offset dimensions,
and a certificate `cert` carrying it in a symbolic template graph `Gs`
(checked once by the kernel, `MatchesD`).

* `template_instance`: at any offset `n` and handles of a capacity `c` in
  the template's KV branches, the template evaluated at `n` is
  `stepGraphOf w hs n`.
* `template_matches`: a graph carrying `Gs` evaluated at `n` under `σ`
  carries `stepGraphOf w hs n` at `cert.map σ`.
* `template_step`: the graph side of the induction step. From the reached
  context's caches at `time` (`ChainHolds`) with uniform capacity `c`, the
  iteration's graph `G` carrying the template, and its input carriers
  holding the step inputs, the token node's `item_uint32` is the
  recurrence's next token, the cache nodes hold handles holding the next
  cache, at capacity `kvCap (some c) time`. -/

/-- The template's expected graph at representative offset `n₀`, handles `hs₀`. -/
def templateOf (w : PipelineWeights) (hs₀ : List Handles) (n₀ : Nat) :
    List (RNode SDim InKey) × Nat × List (Nat × Nat) :=
  template SDim.lit n₀ .pos .pos1 (chainLayout (stageWeights w) hs₀) (linLayout .affineRow w.head)

/-- A decode-step template, checked once. -/
structure Template (w : PipelineWeights) where
  n₀ : Nat
  c₀ : Nat
  hs₀ : List Handles
  caps₀ : CapsFor c₀ (stageWeights w) hs₀
  Gs : Nat → Option (RNode SDim InKey)
  cert : List Nat
  checked : MatchesD Gs (templateOf w hs₀ n₀).1 cert = true
  length : (templateOf w hs₀ n₀).1.length ≤ cert.length

theorem template_instance (w : PipelineWeights) (T : Template w) (hs : List Handles) (c n : Nat)
    (caps : CapsFor c (stageWeights w) hs) (branch : kvSig (some T.c₀) T.n₀ = kvSig (some c) n) :
    ((templateOf w T.hs₀ T.n₀).1.map (mapN (SDim.eval n)), (templateOf w T.hs₀ T.n₀).2) = stepGraphOf w hs n :=
  template_eval SDim.lit T.n₀ .pos .pos1 _ _ (SDim.eval n) n _ (fun _ => rfl) rfl rfl
    (chainLayout_sig T.c₀ c T.n₀ n branch _ _ _ T.caps₀ caps)

theorem template_matches (w : PipelineWeights) (T : Template w) (hs : List Handles) (c n : Nat)
    (caps : CapsFor c (stageWeights w) hs) (branch : kvSig (some T.c₀) T.n₀ = kvSig (some c) n)
    (G : Nat → Option (RNode Int InKey)) (σ cl : Nat → Nat) (emb : Embeds σ cl (mapG (SDim.eval n) T.Gs) G) :
    Matches G (stepGraphOf w hs n).1 (T.cert.map σ) = true := by
  rw [← template_instance w T hs c n caps branch]
  exact matches_embed _ G emb _ _ (by rw [List.length_map]; exact T.length)
    (matchesD_map (SDim.eval n) T.Gs _ T.cert T.checked)

/-- The input-carrier premise from the template's own carrier check: the
iteration's input projection is the template's renamed by `σ`. -/
theorem template_inputs (w : PipelineWeights) (T : Template w) (hs : List Handles) (c n : Nat)
    (caps : CapsFor c (stageWeights w) hs) (branch : kvSig (some T.c₀) T.n₀ = kvSig (some c) n)
    (σ : Nat → Nat) (ins ins' : InKey → Option Nat)
    (checked : inputCarriersMatchD (templateOf w T.hs₀ T.n₀).1 T.cert ins = true)
    (renamed : ∀ key j, ins key = some j → ins' key = some (σ j)) :
    inputCarriersMatch (stepGraphOf w hs n).1 (T.cert.map σ) ins' = true := by
  rw [← template_instance w T hs c n caps branch]
  refine inputCarriers_embed _ T.cert (by rw [List.length_map]; exact T.length) ins ins' renamed ?_
  rw [inputCarriersMatch_map]
  exact checked

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- **The graph side of the induction step.** -/
theorem template_step (p : TokenInference.Pipeline) (w : PipelineWeights) (hl : PipelineLoaded M K p w)
    (parameters : TokenSequenceRanges.Parameters p) (token : Fin 248320) (time : Nat) (supported : time + 1 ≤ 262144)
    (ids : Value)
    (hids : TokenBuffer ids ((GlueM1Max.context M K p w hl parameters).run token time (by omega)).token.val)
    (hs : List Handles)
    (hh : ChainHolds p.graph.stages hs ((GlueM1Max.context M K p w hl parameters).run token time (by omega)).cache)
    (c : Nat) (caps : CapsFor c (stageWeights w) hs)
    (T : Template w) (branch : kvSig (some T.c₀) T.n₀ = kvSig (some c) time)
    (weights : List Char → List Char → Option Value) (G : Nat → Option (RNode Int InKey)) (σ cl : Nat → Nat)
    (emb : Embeds σ cl (mapG (SDim.eval time) T.Gs) G)
    (hin : InputsHeld M K (stepEnvWithIds weights w ids hs) G (stepGraphOf w hs time).1 (T.cert.map σ)) :
    ∃ hs', (∃ r, evalR M K (stepEnvWithIds weights w ids hs) G
        (σ (certAt T.cert (templateOf w T.hs₀ T.n₀).2.1)) = some r ∧
        itemUint32 r = some ((GlueM1Max.context M K p w hl parameters).run token (time + 1) supported).token.val) ∧
      ChainHolds p.graph.stages hs' ((GlueM1Max.context M K p w hl parameters).run token (time + 1) supported).cache ∧
      CapsFor (kvCap (some c) time) (stageWeights w) hs' ∧
      (templateOf w T.hs₀ T.n₀).2.2.length = hs'.length ∧
      (∀ h ∈ hs', (handleVals h).isSome) ∧
      ∀ q ∈ cacheFacts (templateOf w T.hs₀ T.n₀).2.2 hs',
        evalR M K (stepEnvWithIds weights w ids hs) G (σ (certAt T.cert q.1)) = some q.2 := by
  obtain ⟨hs', e, h'⟩ := GlueM1Max.contextStep M K p w hl parameters token time supported hs hh
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

end

end Host.Mlx.SimGraph
