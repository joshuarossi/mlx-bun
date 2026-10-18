import host.load.CacheValues

namespace Host.Load.Extract
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.GlueStep

def isCacheKey : InKey → Bool
  | .stage _ (.cache _) => true
  | _ => false

theorem isCacheKey_iff (key : InKey) :
    isCacheKey key = true ↔ ∃ p i, key = .stage p (.cache i) := by
  cases key <;> simp [isCacheKey]
  rename_i p k
  cases k <;> simp

theorem stageNode_parameter (s : Stage) (c : Cache) (key : SKey)
    (hk : ∀ i, key ≠ .cache i) :
    stageNode s c key = (stageParameter s key).map Tensor.node := by
  cases key <;> simp [stageNode, stageParameter, linearNode, linearTensor,
    mlpNode, mlpTensor, Option.map_bind]
  case lin j key =>
    cases s.linears[j]? <;> simp
    rename_i pair
    cases key <;> rfl
  case mlp key => cases key <;> rfl
  case cache i => exact False.elim (hk i rfl)

/-- Non-cache carriers remain parameter projections regardless of current
cache contents. A successful carrier lookup already proves cache presence. -/
theorem inputNode_parameter (l : Loaded) (token : Tensor) (key : InKey) (n : Nat)
    (hk : key ≠ .tokenIds) (hnc : isCacheKey key = false)
    (hn : inputNode l token key = some n) :
    (parameterInput l key).map Tensor.node = some n := by
  cases key with
  | tokenIds => contradiction
  | embedWords | embedScales | embedBiases | finalNorm => exact hn
  | head key => cases key <;> exact hn
  | stage p key =>
    cases hs : l.model.stages[p]? with
    | none => simp [inputNode, hs] at hn
    | some s =>
      cases hc : l.cache[p]? with
      | none => simp [inputNode, hs, hc] at hn
      | some c =>
        have hkey : ∀ i, key ≠ .cache i := by
          intro i he
          subst key
          simp [isCacheKey] at hnc
        have h := (stageNode_parameter s c key hkey).symm.trans
          (show stageNode s c key = some n by simpa [inputNode, hs, hc] using hn)
        simpa only [parameterInput, hs, Option.bind_some] using h

theorem inputNode_cache (l : Loaded) (token : Tensor) (p i : Nat) (s : Stage)
    (hs : l.model.stages[p]? = some s) :
    inputNode l token (.stage p (.cache i)) =
      ((l.cache[p]?).bind fun c => cacheTensor c i).map Tensor.node := by
  cases hc : l.cache[p]? with
  | none => simp [inputNode, hs, hc]
  | some c =>
    cases i with
    | zero => simp [inputNode, hs, hc, stageNode, cacheTensor]
    | succ i =>
      cases i <;> simp [inputNode, hs, hc, stageNode, cacheTensor]

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- Next-step input evaluation combines parameter preservation, actual token
bytes and the preceding step's proved cache values. The input carrier checker
continues to enforce every source-object/node correspondence. -/
theorem inputsHeld_cached (l : Loaded) (token : Tensor) (value : TensorValues)
    (env : FfiEval.Env InKey) (G : Nat → Option (RNode Int InKey))
    (E : List (RNode Int InKey)) (cert : List Nat) (hs : List Handles)
    (hp : ∀ t, t ∈ parameterTensors l → evalR M K env G t.node = some (value t))
    (hi : ∀ key, key ≠ .tokenIds → isCacheKey key = false →
      env.inputs key = (parameterInput l key).map value)
    (hc : CacheValues M K env G l.cache hs)
    (hci : ∀ p i, env.inputs (.stage p (.cache i)) = (hs[p]?).bind fun h => cacheValue h i)
    (ht : evalR M K env G token.node = env.inputs .tokenIds)
    (hm : inputCarriersMatch E cert (inputNode l token) = true) :
    InputsHeld M K env G E cert := by
  apply inputsHeld_of_carriers M K env G E cert (inputNode l token) hm
  intro key n hn
  by_cases hk : key = .tokenIds
  · subst key
    have hnode : token.node = n := Option.some.inj hn
    simpa only [← hnode] using ht
  · by_cases hcache : isCacheKey key = true
    · obtain ⟨p, i, rfl⟩ := (isCacheKey_iff key).mp hcache
      cases hstage : l.model.stages[p]? with
      | none => simp [inputNode, hstage] at hn
      | some stage =>
        rw [inputNode_cache l token p i stage hstage] at hn
        obtain ⟨t, htensor, rfl⟩ := Option.map_eq_some_iff.mp hn
        obtain ⟨c, hlookup, hselected⟩ := Option.bind_eq_some_iff.mp htensor
        rw [hci]
        simpa only [hlookup, Option.bind_some, hselected] using hc.inputs M K env G p i
    · have hfalse : isCacheKey key = false := Bool.eq_false_iff.mpr hcache
      have hparam := inputNode_parameter l token key n hk hfalse hn
      obtain ⟨t, htensor, rfl⟩ := Option.map_eq_some_iff.mp hparam
      rw [hi key hk hfalse, htensor]
      exact hp t (parameterInput_mem l key htensor)

end Host.Load.Extract
