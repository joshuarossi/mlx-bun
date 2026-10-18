import host.load.run.full.FirstStep
import host.load.CacheValues

namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

/-- Producing nodes projected from the source cache objects. The checked
carrier equality below ensures both optional tensors are present. -/
def cacheNodes (c : Cache) : Nat × Nat :=
  ((c.first.map Tensor.node).getD 0, (c.second.map Tensor.node).getD 0)

theorem first_cache_nodes :
    firstChoice.cache.map cacheNodes =
      Expected.cacheOutputs.map (fun (a,b) => (certAt firstCarriers a, certAt firstCarriers b)) := by
  have h := congrArg (List.map fun (p : Option Nat × Option Nat) => (p.1.getD 0, p.2.getD 0))
    first_cache_carriers
  change firstChoice.cache.map (fun c => ((c.first.map Tensor.node).getD 0, (c.second.map Tensor.node).getD 0)) = _
  simpa only [List.map_map, Function.comp_def, Option.getD_some] using h.symm

theorem cacheFacts_map_nodes (f : Nat → Nat) (ps : List (Nat × Nat)) (hs : List Handles) :
    cacheFacts (ps.map fun (a,b) => (f a, f b)) hs =
      (cacheFacts ps hs).map (fun (a,v) => (f a, v)) := by
  induction ps generalizing hs with
  | nil => cases hs <;> rfl
  | cons p ps ih =>
    cases hs with
    | nil => rfl
    | cons h hs =>
      cases hv : handleVals h <;> simp [cacheFacts, hv, ih]

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)

/-- The graph and cache nodes are the actual source-state projections at the
first yield. Evaluation needs no supplied expected-input interpretation.
Reachability of this state from the program entry is proved separately. -/
theorem first_decoded_state (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed)) :
    let G := ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources P.s2974.ffi.mlx
    let after := (firstContext M K env table leaves typed parameters).run promptToken 1 (by decide)
    ∃ hs', (∃ r, evalR M K env G 17776 = some r ∧ itemUint32 r = some after.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs' after.cache ∧
      (∀ q ∈ cacheFacts (firstChoice.cache.map cacheNodes) hs', evalR M K env G q.1 = some q.2) ∧
      Extract.loaded P.s2974 (entryEnv P.s0) = some firstChoice ∧
      firstChoice.model = parameterChoice.model := by
  dsimp only
  rw [first_graph_matches]
  obtain ⟨hs', ⟨r, hr, ht⟩, hc, hv⟩ := first_decode_graph M K env table leaves typed parameters
  have stable (i : Nat) := evalFfi_inputs M K (firstStepEnv M K env table) env rfl
    (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources firstChoice.graph i
  refine ⟨hs', ⟨r, (stable _).symm.trans hr, ht⟩, hc, ?_, firstParameters.matches,
    first_parameters_preserved⟩
  intro q hq
  rw [first_cache_nodes, cacheFacts_map_nodes] at hq
  obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hq
  exact (stable _).symm.trans (hv p hp)

/-- The actual first-yield cache objects have all the produced values needed
by the next decode call. No cache contents are added as external premises. -/
theorem first_source_cache_values (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed)) :
    let G := ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources P.s2974.ffi.mlx
    let after := (firstContext M K env table leaves typed parameters).run promptToken 1 (by decide)
    ∃ hs', (∃ r, evalR M K env G 17776 = some r ∧ itemUint32 r = some after.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs' after.cache ∧
      CacheValues M K env G firstChoice.cache hs' := by
  dsimp only
  rw [first_graph_matches]
  obtain ⟨hs', ⟨r, hr, ht⟩, hc, hlen, hsome, hv⟩ :=
    first_decode_graph_caches M K env table leaves typed parameters
  have stable (i : Nat) := evalFfi_inputs M K (firstStepEnv M K env table) env rfl
    (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources firstChoice.graph i
  refine ⟨hs', ⟨r, (stable _).symm.trans hr, ht⟩, hc, ?_⟩
  have cached := cacheValues_of_facts M K (firstStepEnv M K env table) (firstFfiGraph table)
    firstChoice.cache Expected.cacheOutputs hs' (certAt firstCarriers)
    first_cache_carriers.symm hlen hsome hv
  exact cached.congr M K _ _ env _ stable

end Host.Load.Run.Full
