import host.load.run.full.CachedValues
import host.load.run.full.FirstStep
import host.mlx.GraphStability

namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)

/-- Graph extension preserves checkpoint-derived parameter values. The premise
is structural preservation of producing nodes and kernel source bindings. -/
theorem parameter_value_extension (leaves : Leaves code env.weights) (native : Host.Mlx.Ffi.St)
    (preserved : ∀ t ∈ parameterTensors parameterChoice, ∀ j ≤ t.node,
      firstChoice.graph.nodes.get j = native.nodes.get j)
    (kernels : kernelName? SourceKernels.sources firstChoice.graph = kernelName? SourceKernels.sources native)
    (t : Tensor) (ht : t ∈ parameterTensors parameterChoice) :
    evalR M K env (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) t.node =
      some (firstValues M K env table t) := by
  have old := parameter_evaluated M K env (firstFfiGraph table) leaves
    (first_load_matches table SourceKernels.sources) t ht
  have stable := evalFfi_prefix M K env env rfl (concrete (CSrv.val ⟨table⟩))
    SourceKernels.sources firstChoice.graph native t.node (preserved t ht) kernels
  exact stable.symm.trans old

/-- A later actual FFI graph computes the next mathematical token and cache
from the preceding cache values. Expected input values are derived, rather
than assumed again. Source reachability and the checked graph/carrier matches
remain separate obligations for the generate-loop execution theorem. -/
theorem cached_decode_graph (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (time : Nat) (supported : time + 1 ≤ 262144)
    (native : Host.Mlx.Ffi.St) (l : Loaded) (token : Tensor) (ids : Value)
    (hs : List Handles) (nextCache : List Cache) (cert : List Nat)
    (hmodel : l.model = parameterChoice.model)
    (preserved : ∀ t ∈ parameterTensors parameterChoice, ∀ j ≤ t.node,
      firstChoice.graph.nodes.get j = native.nodes.get j)
    (kernels : kernelName? SourceKernels.sources firstChoice.graph = kernelName? SourceKernels.sources native)
    (hh : ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs
      ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).cache)
    (hc : CacheValues M K env
      (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) l.cache hs)
    (hids : TokenBuffer ids
      ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).token.val)
    (ht : evalR M K env (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) token.node = some ids)
    (hm : Matches (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native)
      (stepGraphOf (weights (firstValues M K env table)) hs time).1 cert = true)
    (hi : inputCarriersMatch (stepGraphOf (weights (firstValues M K env table)) hs time).1 cert
      (inputNode l token) = true)
    (ho : nextCache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      (stepGraphOf (weights (firstValues M K env table)) hs time).2.2.map
        (fun (a,b) => (some (certAt cert a), some (certAt cert b)))) :
    let after := (firstContext M K env table leaves typed parameters).run promptToken (time + 1) supported
    ∃ hs', (∃ r, evalR M K env
        (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native)
        (certAt cert (stepGraphOf (weights (firstValues M K env table)) hs time).2.1) = some r ∧
        itemUint32 r = some after.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs' after.cache ∧
      CacheValues M K env (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) nextCache hs' := by
  let value := firstValues M K env table
  let p := firstPipeline M K env table leaves typed
  let G := ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native
  let decodeEnv := stepEnvWithIds env.weights (weights value) ids hs
  have stable (i : Nat) : evalR M K env G i = evalR M K decodeEnv G i :=
    evalFfi_inputs M K env decodeEnv rfl _ _ native i
  have hp : ∀ t, t ∈ parameterTensors l → evalR M K decodeEnv G t.node = some (value t) := by
    intro t ht
    have ht' : t ∈ parameterTensors parameterChoice := by
      simpa only [parameterTensors, hmodel] using ht
    exact (stable t.node).symm.trans (parameter_value_extension M K env table leaves native preserved kernels t ht')
  have hin := cached_input_values M K value p (firstPipeline_loaded M K env table leaves typed)
    l token ids hs _ hh env.weights G _ cert hmodel hp
    (hc.congr M K env G decodeEnv G stable) ((stable token.node).symm.trans ht) hi
  obtain ⟨hs', ⟨r, hr, htoken⟩, hchain, hlen, hsome, hev⟩ :=
    ffi_context_step_ids_caches M K p (weights value) (firstPipeline_loaded M K env table leaves typed)
      parameters promptToken time supported ids hids hs hh env.weights G cert hm hin
  have out := cacheValues_of_facts M K decodeEnv G nextCache _ hs' (certAt cert) ho hlen hsome hev
  exact ⟨hs', ⟨r, (stable _).trans hr, htoken⟩, hchain,
    out.congr M K decodeEnv G env G (fun i => (stable i).symm)⟩

end Host.Load.Run.Full
