import host.mlx.FfiEval

namespace Host.Mlx.FfiEval
open Inference.Contracts.Mlx Host.Mlx.GlueStep Host.Mlx.GlueLayers

/-- The actual single-token prompt buffer uses int32, whereas native argmax
feedback uses uint32. Both carry the same nonnegative vocabulary index. -/
def promptIds (token : Nat) : Value := ⟨.int32, [1, 1], fun _ => token⟩

theorem prompt_take (table : Value) (token : Nat) (h : token < 2^31) :
    takeAxis0 table (promptIds token) = takeAxis0 table (tokenIds token) := by
  have ht : token < 2147483648 := h
  simp [takeAxis0, promptIds, tokenIds, extent, ht, takeRows]
  rfl

/-- Vary only the actual token input representation; all parameter and cache
inputs retain the existing step environment. -/
def stepInputsWithIds (w : PipelineWeights) (ids : Value) (hs : List Handles) : InKey → Option Value
  | .tokenIds => some ids
  | key => stepInputs w 0 hs key

theorem stepInputsWithIds_feedback (w : PipelineWeights) (token : Nat) (hs : List Handles) :
    stepInputsWithIds w (tokenIds token) hs = stepInputs w token hs := by
  funext key
  cases key <;> rfl

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) {κ : Type} [DecidableEq κ] (env : Env κ)

theorem embedG_spec_ids (key : InKey → κ) (words scales biases : Value) (token : Nat) (ids : Value)
    (htake : ∀ table, takeAxis0 table ids = takeAxis0 table (tokenIds token))
    (hk : env.inputs (key .tokenIds) = some ids) (hw : env.inputs (key .embedWords) = some words)
    (hs : env.inputs (key .embedScales) = some scales) (hb : env.inputs (key .embedBiases) = some biases)
    (g : List (RNode Int κ)) (fs : List (Nat × Value)) (hfs : AllEv M K env g fs)
    (x : Value) (hx : embedTrace M words scales biases token = some x) :
    Spec (embedG (δ := Int) key) g (fun o g' => AllEv M K env g' ((o, x) :: fs)) := by
  unfold embedTrace at hx
  peel hx => rows e1
  peel hx => sc e2
  peel hx => bi e3
  have e1' := (htake words).trans e1
  have e2' := (htake scales).trans e2
  have e3' := (htake biases).trans e3
  unfold embedG
  refine spec_inp M K env hfs hk fun g1 i1 h1 => ?_
  refine spec_inp M K env h1 hw fun g2 i2 h2 => ?_
  refine spec_inp M K env h2 hs fun g3 i3 h3 => ?_
  refine spec_inp M K env h3 hb fun g4 i4 h4 => ?_
  refine spec_step M K env h4 (by simp [isExp]) (by simp) ((pe_take M K env _ _).trans e1') fun g5 i5 h5 => ?_
  refine spec_step M K env h5 (by simp [isExp]) (by simp) ((pe_take M K env _ _).trans e2') fun g6 i6 h6 => ?_
  refine spec_step M K env h6 (by simp [isExp]) (by simp) ((pe_take M K env _ _).trans e3') fun g7 i7 h7 => ?_
  exact spec_last M K env h7 (by simp [isExp]) (by simp) ((pe_dequant M K env _ _ _).trans hx)
    fun g' i h => h.mono M K env (by sub_tac)

theorem stepG_spec_ids (n : Nat) (w : PipelineWeights) (token : Nat) (ids : Value)
    (htake : ∀ table, takeAxis0 table ids = takeAxis0 table (tokenIds token)) (hs : List Handles) (key : InKey → κ)
    (hkey : ∀ k, env.inputs (key k) = stepInputsWithIds w ids hs k) (hfn : w.finalNorm.shape = [5120])
    (hsh : ShapesOk (stageWeights w) hs) (t : Nat) (hs' : List Handles)
    (h : stepTrace M K w n token hs = some (t, hs')) :
    Spec (stepG id n (n : Int) ((n : Int) + 1) key (chainLayout (stageWeights w) hs) (linLayout .affineRow w.head)) []
      (fun o g' => (∃ r, EvA M K env g' o.1 r ∧ itemUint32 r = some t) ∧ o.2.length = hs'.length ∧
        (∀ h ∈ hs', (handleVals h).isSome) ∧ AllEv M K env g' (cacheFacts o.2 hs')) := by
  unfold stepTrace at h
  peel h => x e1
  peel h => r2 e2
  obtain ⟨y, hs2⟩ := r2
  dsimp only at h
  peel h => hn e3
  peel h => logits e4
  peel h => l e5
  peel h => l6 e6
  split at h <;> [skip; exact absurd h (by simp)]
  rename_i r
  peel h => t7 e7
  have hr : (t7, hs2) = (t, hs') := Option.some.inj h
  cases hr
  simp only [KernelClosure.eval] at e6
  peel e6 => sv e61
  peel e6 => pair e62
  split at e6 <;> [skip; exact absurd e6 (by simp)]
  rename_i values indices
  peel e6 => out e63
  split at e6 <;> [skip; exact absurd e6 (by simp)]
  rename_i tok
  obtain ⟨r', e64, he⟩ := Option.map_eq_some_iff.mp e6
  have hrr : r' = r := by simpa using he
  subst hrr
  have hfs0 : AllEv M K env ([] : List (RNode Int κ)) [] := fun _ hp => by simp at hp
  unfold stepG
  refine spec_seq (embedG_spec_ids M K env key w.embedWords w.embedScales w.embedBiases token ids htake (hkey _) (hkey _)
    (hkey _) (hkey _) [] [] hfs0 x e1) fun i1 g1 h1 => ?_
  have hst : StagesIn env key 0 (stageWeights w) hs := fun i k => by
    rw [hkey]; simp only [stepInputsWithIds, stepInputs, Nat.zero_add]
  refine spec_seq (chainG_spec M K env n key (stageWeights w) hs 0 g1 _ h1 hst hsh i1 x (by simp) y hs' e2)
    fun ⟨i2, cs⟩ g2 ⟨hl, hsome, h2⟩ => ?_
  dsimp only
  refine spec_seq (normG_spec M K env (key .finalNorm) w.finalNorm (hkey _) M.hiddenNorm (normPlatform_hidden M _ hfn)
    g2 _ h2 i2 y (by simp) hn e3) fun i3 g3 h3 => ?_
  refine spec_seq (projectG_spec M K env .affineRow w.head (key ∘ .head) (fun l => hkey (.head l)) g3 _ h3 i3 hn
    (by simp) logits e4) fun i4 g4 h4 => ?_
  refine spec_step M K env h4 (by simp [isExp]) (by simp) ((pe_reshape M K env _ _).trans e5) fun g5 i5 h5 => ?_
  refine spec_step M K env h5 (by simp [isExp]) (by simp) ((pe_logsumexp M K env _).trans e61) fun g6 i6 h6 => ?_
  refine spec_step M K env h6 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .argmaxPartial) rfl e62 rfl) fun g7 i7 h7 => ?_
  refine spec_step M K env h7 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .argmaxPartial) rfl e62 rfl) fun g8 i8 h8 => ?_
  refine spec_step M K env h8 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .argmaxFinish) rfl e63 rfl) fun g9 i9 h9 => ?_
  refine spec_step M K env h9 (by simp [isExp]) (by simp) ((pe_reshape M K env _ _).trans e64) fun g10 i10 h10 => ?_
  refine spec_pure ⟨⟨r', h10 (i10, r') (by simp), e7⟩, hl, hsome, h10.mono M K env ?_⟩
  intro q hq
  simp only [List.mem_cons, List.mem_append] at hq ⊢
  tauto

end
section
open Inference Inference.Models.Qwen
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- Actual input dtype with unchanged checkpoint/cache inputs. -/
def stepEnvWithIds (weights : List Char → List Char → Option Value) (w : PipelineWeights) (ids : Value)
    (hs : List Handles) : Env InKey := ⟨weights, stepInputsWithIds w ids hs⟩

theorem stepGraph_eval_ids (weights : List Char → List Char → Option Value) (w : PipelineWeights) (n token : Nat) (ids : Value)
    (htake : ∀ table, takeAxis0 table ids = takeAxis0 table (tokenIds token))
    (hs hs' : List Handles) (t : Nat) (hfn : w.finalNorm.shape = [5120]) (hsh : ShapesOk (stageWeights w) hs)
    (h : stepTrace M K w n token hs = some (t, hs')) :
    (∃ r, (stepGraphOf w hs n).2.1 < (stepGraphOf w hs n).1.length ∧
      evalR M K (stepEnvWithIds weights w ids hs) (listGraph (stepGraphOf w hs n).1) (stepGraphOf w hs n).2.1 = some r ∧
      itemUint32 r = some t) ∧
    (stepGraphOf w hs n).2.2.length = hs'.length ∧ (∀ h ∈ hs', (handleVals h).isSome) ∧
    ∀ q ∈ cacheFacts (stepGraphOf w hs n).2.2 hs', q.1 < (stepGraphOf w hs n).1.length ∧
      evalR M K (stepEnvWithIds weights w ids hs) (listGraph (stepGraphOf w hs n).1) q.1 = some q.2 := by
  have := stepG_spec_ids M K (stepEnvWithIds weights w ids hs) n w token ids htake hs id (fun _ => rfl) hfn hsh t hs' h
  obtain ⟨⟨r, hr, ht⟩, hl, hsome, hc⟩ := this
  exact ⟨⟨r, hr.1, hr.2, ht⟩, hl, hsome, fun q hq => hc q hq⟩

/-- **The FFI graph computes the trace.** If the FFI state's graph `G`
carries the step's expected graph at `cert` (a decidable check) and the
carriers of its inputs hold the inputs, the FFI token node evaluates to the
trace's token and its cache nodes to the trace's caches. -/
theorem ffi_step_ids (weights : List Char → List Char → Option Value) (w : PipelineWeights) (n token : Nat) (ids : Value)
    (htake : ∀ table, takeAxis0 table ids = takeAxis0 table (tokenIds token))
    (hs hs' : List Handles) (t : Nat) (hfn : w.finalNorm.shape = [5120]) (hsh : ShapesOk (stageWeights w) hs)
    (h : stepTrace M K w n token hs = some (t, hs')) (G : Nat → Option (RNode Int InKey)) (cert : List Nat)
    (hm : Matches G (stepGraphOf w hs n).1 cert = true)
    (hin : InputsHeld M K (stepEnvWithIds weights w ids hs) G (stepGraphOf w hs n).1 cert) :
    (∃ r, evalR M K (stepEnvWithIds weights w ids hs) G (certAt cert (stepGraphOf w hs n).2.1) = some r ∧
      itemUint32 r = some t) ∧
    ∀ q ∈ cacheFacts (stepGraphOf w hs n).2.2 hs',
      evalR M K (stepEnvWithIds weights w ids hs) G (certAt cert q.1) = some q.2 := by
  obtain ⟨⟨r, hlt, hr, ht⟩, _, _, hc⟩ := stepGraph_eval_ids M K weights w n token ids htake hs hs' t hfn hsh h
  refine ⟨⟨r, ?_, ht⟩, fun q hq => ?_⟩
  · rw [matches_eval M K _ G _ cert hm hin _ hlt]; exact hr
  · obtain ⟨hql, hqv⟩ := hc q hq
    rw [matches_eval M K _ G _ cert hm hin _ hql]; exact hqv


theorem ffi_context_step_ids (p : TokenInference.Pipeline) (w : PipelineWeights) (hl : PipelineLoaded M K p w)
    (parameters : TokenSequenceRanges.Parameters p) (token : Fin 248320) (time : Nat) (supported : time + 1 ≤ 262144)
    (ids : Value)
    (htake : ∀ table, takeAxis0 table ids = takeAxis0 table (tokenIds
      ((GlueM1Max.context M K p w hl parameters).run token time (by omega)).token.val))
    (hs : List Handles)
    (hh : ChainHolds p.graph.stages hs ((GlueM1Max.context M K p w hl parameters).run token time (by omega)).cache)
    (weights : List Char → List Char → Option Value) (G : Nat → Option (RNode Int InKey)) (cert : List Nat)
    (hm : Matches G (stepGraphOf w hs time).1 cert = true)
    (hin : InputsHeld M K (stepEnvWithIds weights w ids hs)
      G (stepGraphOf w hs time).1 cert) :
    ∃ hs', (∃ r, evalR M K (stepEnvWithIds weights w ids hs)
        G (certAt cert (stepGraphOf w hs time).2.1) = some r ∧
        itemUint32 r = some ((GlueM1Max.context M K p w hl parameters).run token (time + 1) supported).token.val) ∧
      ChainHolds p.graph.stages hs' ((GlueM1Max.context M K p w hl parameters).run token (time + 1) supported).cache ∧
      ∀ q ∈ cacheFacts (stepGraphOf w hs time).2.2 hs',
        evalR M K (stepEnvWithIds weights w ids hs)
          G (certAt cert q.1) = some q.2 := by
  obtain ⟨hs', e, h'⟩ := GlueM1Max.contextStep M K p w hl parameters token time supported hs hh
  have hsh := shapes_of_holds M K _ _ _ _ (stages_loaded M K p w hl) hh
  obtain ⟨ht, hc⟩ := ffi_step_ids M K weights w time _ ids htake hs hs' _ hl.finalNorm.2.1 hsh e G cert hm hin
  exact ⟨hs', ht, h', hc⟩

end
end Host.Mlx.FfiEval
