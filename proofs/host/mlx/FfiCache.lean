import host.mlx.FfiInput

namespace Host.Mlx.FfiEval
open Inference Inference.Contracts.Mlx Inference.Models.Qwen Host.Mlx.GlueStep

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- Preserve the produced cache cardinality and populated-buffer facts needed
to feed the next source call. These facts follow from the original step trace. -/
theorem ffi_context_step_ids_caches (p : TokenInference.Pipeline) (w : PipelineWeights)
    (hl : PipelineLoaded M K p w) (parameters : TokenSequenceRanges.Parameters p)
    (token : Fin 248320) (time : Nat) (supported : time + 1 ≤ 262144) (ids : Value)
    (hids : TokenBuffer ids ((GlueM1Max.context M K p w hl parameters).run token time (by omega)).token.val)
    (hs : List Handles)
    (hh : ChainHolds p.graph.stages hs ((GlueM1Max.context M K p w hl parameters).run token time (by omega)).cache)
    (weights : List Char → List Char → Option Value) (G : Nat → Option (RNode Int InKey)) (cert : List Nat)
    (hm : Matches G (stepGraphOf w hs time).1 cert = true)
    (hin : InputsHeld M K (stepEnvWithIds weights w ids hs) G (stepGraphOf w hs time).1 cert) :
    ∃ hs', (∃ r, evalR M K (stepEnvWithIds weights w ids hs)
        G (certAt cert (stepGraphOf w hs time).2.1) = some r ∧
        itemUint32 r = some ((GlueM1Max.context M K p w hl parameters).run token (time + 1) supported).token.val) ∧
      ChainHolds p.graph.stages hs' ((GlueM1Max.context M K p w hl parameters).run token (time + 1) supported).cache ∧
      (stepGraphOf w hs time).2.2.length = hs'.length ∧
      (∀ h ∈ hs', (handleVals h).isSome) ∧
      ∀ q ∈ cacheFacts (stepGraphOf w hs time).2.2 hs',
        evalR M K (stepEnvWithIds weights w ids hs) G (certAt cert q.1) = some q.2 := by
  obtain ⟨hs', e, h'⟩ := GlueM1Max.contextStep M K p w hl parameters token time supported hs hh
  have hsh := shapes_of_holds M K _ _ _ _ (stages_loaded M K p w hl) hh
  have hembed := bufferEmbed_eq M w.embedWords w.embedScales w.embedBiases ids _ hids
    hl.embedding.words.1 hl.embedding.words.2.1 hl.embedding.scales.2.1 hl.embedding.biases.2.1
  obtain ⟨ht, hc⟩ := ffi_step_ids M K weights w time _ ids hembed hs hs' _ hl.finalNorm.2.1 hsh e G cert hm hin
  obtain ⟨_, hlen, hsome, _⟩ := stepGraph_eval_ids M K weights w time _ ids hembed hs hs' _ hl.finalNorm.2.1 hsh e
  exact ⟨hs', ht, h', hlen, hsome, hc⟩

end Host.Mlx.FfiEval
