import host.load.CachedInputs

namespace Host.Load.Extract
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.GlueStep
open Inference.Models.Qwen

/-- The cache constructor agrees with the corresponding layer constructor. -/
def CacheCompatible : StageWeights → Handles → Prop
  | .delta _, .delta _ _ => True
  | .attention _, .attention _ _ => True
  | _, _ => False

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

theorem cacheCompatible_of_holds (stages : List DecodeStage.Stage) (ws : List StageWeights)
    (hs : List Handles) (c : DecodeChain.Caches stages n)
    (hl : ChainLoaded M K stages ws) (hh : ChainHolds stages hs c) :
    List.Forall₂ CacheCompatible ws hs := by
  induction stages generalizing ws hs with
  | nil =>
    cases ws <;> cases hs <;> simp_all [ChainLoaded, ChainHolds]
  | cons s ss ih =>
    cases ws with
    | nil => exact hl.elim
    | cons w ws =>
      cases hs with
      | nil => exact hh.elim
      | cons h hs =>
        refine .cons ?_ (ih ws hs c.2 hl.2 hh.2)
        cases s <;> cases w <;> cases h <;>
          simp_all [ChainLoaded, ChainHolds, StageLoaded, StageHolds, CacheCompatible]

theorem stageInput_parameter_eq (w : StageWeights) (h h' : Handles)
    (hc : CacheCompatible w h) (hc' : CacheCompatible w h')
    (key : SKey) (hk : ∀ i, key ≠ .cache i) :
    stageInput w h key = stageInput w h' key := by
  cases w <;> cases h <;> cases h' <;>
    simp_all only [CacheCompatible]
  all_goals cases key <;> simp only [stageInput, deltaInput, attnInput]
  all_goals first | exact False.elim (hk _ rfl) | (rename_i j l; rcases j with _ | _ | _ | _ | _ | j <;> rfl)

theorem stageInput_cache_value (w : StageWeights) (h : Handles)
    (hc : CacheCompatible w h) (hp : (handleVals h).isSome) (i : Nat) :
    stageInput w h (.cache i) = cacheValue h i := by
  cases w <;> cases h <;> simp_all only [CacheCompatible]
  all_goals rename_i a b
  all_goals cases a <;> cases b <;> simp_all [handleVals]
  all_goals cases i with
    | zero => rfl
    | succ i => cases i <;> rfl

def chainInput (ws : List StageWeights) (hs : List Handles) (p : Nat) (key : SKey) : Option Value :=
  match ws[p]?, hs[p]? with
  | some w, some h => stageInput w h key
  | _, _ => none

theorem chainInput_parameter_eq (ws : List StageWeights) (hs hs' : List Handles)
    (hc : List.Forall₂ CacheCompatible ws hs) (hc' : List.Forall₂ CacheCompatible ws hs')
    (p : Nat) (key : SKey) (hk : ∀ i, key ≠ .cache i) :
    chainInput ws hs p key = chainInput ws hs' p key := by
  induction hc generalizing hs' p with
  | nil => cases hc'; rfl
  | cons h rest ih =>
    cases hc' with
    | cons h' rest' =>
      cases p with
      | zero => exact stageInput_parameter_eq _ _ _ h h' key hk
      | succ p => exact ih _ rest' p

theorem chainInput_cache_value (ws : List StageWeights) (hs : List Handles)
    (hc : List.Forall₂ CacheCompatible ws hs) (hp : ∀ h ∈ hs, (handleVals h).isSome)
    (p i : Nat) :
    chainInput ws hs p (.cache i) = (hs[p]?).bind (fun h => cacheValue h i) := by
  induction hc generalizing p with
  | nil => rfl
  | cons h rest ih =>
    cases p with
    | zero => exact stageInput_cache_value _ _ h (hp _ (List.mem_cons_self ..)) i
    | succ p => exact ih (fun x hx => hp x (List.mem_cons_of_mem _ hx)) p

theorem stepInputsWithIds_parameter_eq (w : PipelineWeights) (ids : Value) (hs hs' : List Handles)
    (hc : List.Forall₂ CacheCompatible (stageWeights w) hs)
    (hc' : List.Forall₂ CacheCompatible (stageWeights w) hs')
    (key : InKey) (hk : isCacheKey key = false) :
    stepInputsWithIds w ids hs key = stepInputsWithIds w ids hs' key := by
  cases key with
  | stage p key =>
    apply chainInput_parameter_eq _ _ _ hc hc' p key
    intro i he
    subst key
    simp [isCacheKey] at hk
  | _ => rfl

theorem stepInputsWithIds_cache_value (w : PipelineWeights) (ids : Value) (hs : List Handles)
    (hc : List.Forall₂ CacheCompatible (stageWeights w) hs)
    (hp : ∀ h ∈ hs, (handleVals h).isSome) (p i : Nat) :
    stepInputsWithIds w ids hs (.stage p (.cache i)) = (hs[p]?).bind (fun h => cacheValue h i) :=
  chainInput_cache_value _ _ hc hp p i

theorem CacheValues.populated (env : FfiEval.Env InKey) (G : Nat → Option (RNode Int InKey))
    {cs : List Cache} {hs : List Handles} (h : CacheValues M K env G cs hs) :
    ∀ x ∈ hs, (handleVals x).isSome := by
  induction h with
  | nil => simp
  | cons h rest ih =>
    obtain ⟨_, _, _, _, _, _, hv, _, _⟩ := h
    intro x hx
    rcases List.mem_cons.mp hx with rfl | hx
    · simp [hv]
    · exact ih x hx

end Host.Load.Extract
