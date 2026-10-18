import host.load.run.full.cached.Certificate1
import host.load.run.full.cached.Step
import host.load.run.full.FirstValues
import host.load.run.full.FirstOutputs
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem terminal_prompt_node (table : List F64) :
    terminalGraph table promptCarrier.node = some ⟨.data [235,37,0,0] [1,1] 7, []⟩ := by rfl

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)

theorem terminal_prompt_value :
    evalR M K env (terminalGraph table) promptCarrier.node = some (promptIds 9707) := by
  rw [evalR_eq, terminal_prompt_node,
    cgLeaves_none (terminalGraph table) promptCarrier.node _ (terminal_prompt_node table) (by rfl)]
  exact prompt_data

theorem terminal_initial_inputs (leaves : Leaves code env.weights)
    (E : List (RNode Int InKey)) (cert : List Nat)
    (hc : inputCarriersMatch E cert firstInputs = true) :
    InputsHeld M K (firstStepEnv M K env table) (terminalGraph table) E cert := by
  apply inputsHeld_initial M K parameterChoice promptCarrier (firstValues M K env table)
    (firstStepEnv M K env table) (terminalGraph table) E cert empty_input_caches
  · intro t ht
    exact (evalFfi_inputs M K (firstStepEnv M K env table) env rfl
      (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources P.s3573.ffi.mlx t.node).trans
      (terminal_parameter_value M K env table leaves t ht)
  · exact initial_input_values (firstValues M K env table) (promptIds 9707)
  · exact terminal_prompt_value M K (firstStepEnv M K env table) table
  · exact hc

/-- The first mathematical cache is established inside the same original
source graph subsequently used for the four cached forwards. -/
theorem terminal_first_step (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed)) :
    let after := (firstContext M K env table leaves typed parameters).run promptToken 1 (by decide)
    ∃ hs, (∃ r, evalR M K env (terminalGraph table) 17776 = some r ∧ itemUint32 r = some after.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs after.cache ∧
      CacheValues M K env (terminalGraph table) firstChoice.cache hs := by
  let p := firstPipeline M K env table leaves typed
  let value := firstValues M K env table
  let w := weights value
  let decodeEnv := firstStepEnv M K env table
  have stable (i : Nat) : evalR M K env (terminalGraph table) i = evalR M K decodeEnv (terminalGraph table) i :=
    evalFfi_inputs M K env decodeEnv rfl _ _ P.s3573.ffi.mlx i
  have hg := initial_step_graph (contents M K env (firstFfiGraph table))
  change stepGraphOf w initialHandles 0 = _ at hg
  have hm : Matches (terminalGraph table) (stepGraphOf w initialHandles 0).1 firstCarriers = true := by
    rw [hg]
    exact certificate1.matches table
  have hi : InputsHeld M K decodeEnv (terminalGraph table) (stepGraphOf w initialHandles 0).1 firstCarriers := by
    rw [hg]
    exact terminal_initial_inputs M K env table leaves _ _ (certificate1.inputs table)
  obtain ⟨hs, ht, hh, hlen, hsome, hv⟩ := ffi_context_step_ids_caches M K p w
    (firstPipeline_loaded M K env table leaves typed) parameters promptToken 0 (by decide)
    (promptIds 9707) (prompt_buffer 9707 (by decide)) initialHandles (initialChainHolds p)
    env.weights (terminalGraph table) firstCarriers hm hi
  rw [hg] at ht hlen hv
  have caches := cacheValues_of_facts M K decodeEnv (terminalGraph table) firstChoice.cache _ hs
    (certAt firstCarriers) first_cache_carriers.symm hlen hsome hv
  refine ⟨hs, ?_, hh, caches.congr M K decodeEnv (terminalGraph table) env (terminalGraph table) (fun i => (stable i).symm)⟩
  obtain ⟨r, hr, htoken⟩ := ht
  refine ⟨r, (stable 17776).trans ?_, ?_⟩
  · simpa only [first_token_carrier, decodeEnv, firstStepEnv, w, value] using hr
  · exact htoken
end Host.Load.Run.Full.Cached
