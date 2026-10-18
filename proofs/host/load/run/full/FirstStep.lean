import host.load.run.full.FirstValues
import host.load.run.full.FirstOutputs
import host.load.run.full.InitialLayout
import host.mlx.FfiCache
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)

noncomputable def firstPipeline (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) :=
  loadedPipeline M K env (firstFfiGraph table) leaves typed (first_load_matches table SourceKernels.sources)

theorem firstPipeline_loaded (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) :
    PipelineLoaded M K (firstPipeline M K env table leaves typed) (weights (firstValues M K env table)) :=
  loadedPipeline_loaded M K env (firstFfiGraph table) leaves typed (first_load_matches table SourceKernels.sources)

noncomputable def firstContext (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed)) :=
  GlueM1Max.context M K (firstPipeline M K env table leaves typed) (weights (firstValues M K env table))
    (firstPipeline_loaded M K env table leaves typed) parameters

def promptToken : Fin 248320 := ⟨9707, by decide⟩

/-- The first source graph computes the mathematical next token and all 64
next caches. Its parameters are constructed from the actual load program;
only checkpoint leaves, their dtypes, numerical ranges, and platform contracts
remain premises. Source execution to the named cut is a separate theorem. -/
theorem first_decode_graph_caches (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed)) :
    let after := (firstContext M K env table leaves typed parameters).run promptToken 1 (by decide)
    ∃ hs', (∃ r, evalR M K (firstStepEnv M K env table) (firstFfiGraph table) 17776 = some r ∧
      itemUint32 r = some after.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs' after.cache ∧
      Expected.cacheOutputs.length = hs'.length ∧
      (∀ h ∈ hs', (handleVals h).isSome) ∧
      ∀ q ∈ cacheFacts Expected.cacheOutputs hs',
        evalR M K (firstStepEnv M K env table) (firstFfiGraph table) (certAt firstCarriers q.1) = some q.2 := by
  let p := firstPipeline M K env table leaves typed
  let w := weights (firstValues M K env table)
  have hl := firstPipeline_loaded M K env table leaves typed
  have hm : Matches (firstFfiGraph table) (stepGraphOf w initialHandles 0).1 firstCarriers = true := by
    rw [show stepGraphOf w initialHandles 0 = (Expected.graph, Expected.tokenNode, Expected.cacheOutputs) from
      initial_step_graph (contents M K env (firstFfiGraph table))]
    exact firstCertificate.matches table
  have hi : InputsHeld M K (firstStepEnv M K env table) (firstFfiGraph table)
      (stepGraphOf w initialHandles 0).1 firstCarriers := by
    rw [show stepGraphOf w initialHandles 0 = (Expected.graph, Expected.tokenNode, Expected.cacheOutputs) from
      initial_step_graph (contents M K env (firstFfiGraph table))]
    exact first_input_values M K env table leaves _ _ (firstCertificate.inputs table)
  obtain ⟨hs', ht, hc, hlen, hsome, hv⟩ := ffi_context_step_ids_caches M K p w hl parameters promptToken 0 (by decide)
    (promptIds 9707) (prompt_buffer 9707 (by decide)) initialHandles (initialChainHolds p)
    env.weights (firstFfiGraph table) firstCarriers hm hi
  have hg := initial_step_graph (contents M K env (firstFfiGraph table))
  change stepGraphOf w initialHandles 0 = _ at hg
  rw [hg] at ht hlen hv
  refine ⟨hs', ?_, hc, hlen, hsome, hv⟩
  simpa only [first_token_carrier, firstStepEnv, firstContext, p, w, Nat.zero_add] using ht

theorem first_decode_graph (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed)) :
    let after := (firstContext M K env table leaves typed parameters).run promptToken 1 (by decide)
    ∃ hs', (∃ r, evalR M K (firstStepEnv M K env table) (firstFfiGraph table) 17776 = some r ∧
      itemUint32 r = some after.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs' after.cache ∧
      ∀ q ∈ cacheFacts Expected.cacheOutputs hs',
        evalR M K (firstStepEnv M K env table) (firstFfiGraph table) (certAt firstCarriers q.1) = some q.2 := by
  obtain ⟨hs', ht, hc, _, _, hv⟩ := first_decode_graph_caches M K env table leaves typed parameters
  exact ⟨hs', ht, hc, hv⟩

end Host.Load.Run.Full
