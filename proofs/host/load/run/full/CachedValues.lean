import host.load.run.full.InputValues
import host.load.CacheInputValues

namespace Host.Load.Run.Full
open Host.Load.Extract Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval
open Inference.Models.Qwen

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- The source-derived parameter interpretation remains the expected input
interpretation at every cache state represented by the mathematical chain. -/
theorem cached_parameter_inputs (value : TensorValues) (p : TokenInference.Pipeline)
    (hl : PipelineLoaded M K p (weights value)) (hs : List Handles)
    (cache : DecodeChain.Caches p.graph.stages n) (hh : ChainHolds p.graph.stages hs cache)
    (ids : Value) (key : InKey) (hk : key ≠ .tokenIds) (hc : isCacheKey key = false) :
    stepInputsWithIds (weights value) ids hs key = (parameterInput parameterChoice key).map value := by
  have loaded := stages_loaded M K p (weights value) hl
  have current := cacheCompatible_of_holds M K _ _ hs cache loaded hh
  have initial := cacheCompatible_of_holds M K _ _ initialHandles _ loaded (initialChainHolds p)
  exact (stepInputsWithIds_parameter_eq _ ids hs initialHandles current initial key hc).trans
    (initial_input_values value ids key hk)

/-- All input values for a later decode graph follow from the preserved loaded
parameters, the actual token tensor, and the preceding graph's cache outputs.
The cache kind and expected cache projections are derived from ChainHolds. -/
theorem cached_input_values (value : TensorValues) (p : TokenInference.Pipeline)
    (hl : PipelineLoaded M K p (weights value)) (l : Loaded) (token : Tensor) (ids : Value)
    (hs : List Handles) (cache : DecodeChain.Caches p.graph.stages n)
    (hh : ChainHolds p.graph.stages hs cache)
    (weightsEnv : List Char → List Char → Option Value) (G : Nat → Option (RNode Int InKey))
    (E : List (RNode Int InKey)) (cert : List Nat)
    (hmodel : l.model = parameterChoice.model)
    (hp : ∀ t, t ∈ parameterTensors l →
      evalR M K (stepEnvWithIds weightsEnv (weights value) ids hs) G t.node = some (value t))
    (hc : CacheValues M K (stepEnvWithIds weightsEnv (weights value) ids hs) G l.cache hs)
    (ht : evalR M K (stepEnvWithIds weightsEnv (weights value) ids hs) G token.node = some ids)
    (hm : inputCarriersMatch E cert (inputNode l token) = true) :
    InputsHeld M K (stepEnvWithIds weightsEnv (weights value) ids hs) G E cert := by
  apply inputsHeld_cached M K l token value _ G E cert hs hp
  · intro key hk hnc
    have parameters : parameterInput l key = parameterInput parameterChoice key := by
      cases key <;> simp only [parameterInput, hmodel]
    rw [parameters]
    exact cached_parameter_inputs M K value p hl hs cache hh ids key hk hnc
  · exact hc
  · intro q i
    exact stepInputsWithIds_cache_value _ ids hs
      (cacheCompatible_of_holds M K _ _ _ cache (stages_loaded M K p _ hl) hh)
      (hc.populated M K _ _) q i
  · exact ht
  · exact hm

end Host.Load.Run.Full
