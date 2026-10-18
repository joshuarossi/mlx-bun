import host.load.Parameters
import host.mlx.FfiInput
import host.mlx.GraphCertificate

namespace Host.Load.Extract
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.GlueStep Host.Ts

def linearTensor (l : Linear) : LinKey → Option Tensor
  | .w => some l.words
  | .scales => some l.scales
  | .biases => l.biases

def mlpTensor (m : Mlp) : MlpKey → Tensor
  | .norm => m.norm
  | .gateCodes => m.gate.codes
  | .gateScales => m.gate.scales
  | .upCodes => m.up.codes
  | .upScales => m.up.scales
  | .downCodes => m.down.codes
  | .downScales => m.down.scales

/-- The parameter object selected by an expected graph key. Cache and token
inputs are separate, because their values evolve while parameters persist. -/
def stageParameter (s : Stage) : SKey → Option Tensor
  | .inputNorm => some s.inputNorm
  | .lin j k => (s.linears[j]?).bind fun (_, l) => linearTensor l k
  | .conv => namedTensor s.tensors chars!"convWeight"
  | .aLog => namedTensor s.tensors chars!"aLog"
  | .dtBias => namedTensor s.tensors chars!"dtBias"
  | .norm => namedTensor s.tensors chars!"normWeight"
  | .qScale => namedTensor s.tensors chars!"qScale"
  | .kScale => namedTensor s.tensors chars!"kScale"
  | .qNorm => namedTensor s.tensors chars!"qNorm"
  | .kNorm => namedTensor s.tensors chars!"kNorm"
  | .mlp k => some (mlpTensor s.mlp k)
  | .cache _ => none

def parameterInput (l : Loaded) : InKey → Option Tensor
  | .tokenIds => none
  | .embedWords => namedTensor l.model.embedding chars!"w"
  | .embedScales => namedTensor l.model.embedding chars!"scales"
  | .embedBiases => namedTensor l.model.embedding chars!"biases"
  | .finalNorm => some l.model.finalNorm
  | .head k => linearTensor l.model.head k
  | .stage p k => (l.model.stages[p]?).bind fun s => stageParameter s k

private theorem namedTensor_mem (xs : List (List Char × Tensor)) (key : List Char)
    (h : namedTensor xs key = some t) : t ∈ xs.map Prod.snd := by
  obtain ⟨p, hp, rfl⟩ := Option.map_eq_some_iff.mp h
  exact List.mem_map.mpr ⟨p, List.mem_of_find?_eq_some hp, rfl⟩

private theorem linearTensor_mem (l : Linear) (k : LinKey) (h : linearTensor l k = some t) :
    t ∈ linearTensors l := by
  cases k <;> simp_all [linearTensor, linearTensors]

private theorem mlpTensor_mem (m : Mlp) (k : MlpKey) : mlpTensor m k ∈ mlpTensors m := by
  cases k <;> simp [mlpTensor, mlpTensors]

private theorem stageParameter_mem (s : Stage) (k : SKey) (h : stageParameter s k = some t) :
    t ∈ [s.inputNorm] ++ s.linears.flatMap (linearTensors ∘ Prod.snd) ++
      s.tensors.map Prod.snd ++ mlpTensors s.mlp := by
  cases k with
  | inputNorm => simp_all [stageParameter]
  | lin j k =>
    obtain ⟨p, hp, ht⟩ := Option.bind_eq_some_iff.mp h
    have hm := linearTensor_mem p.2 k ht
    have hp' : p ∈ s.linears := List.mem_of_getElem? hp
    simp only [List.mem_append, List.mem_singleton, List.mem_flatMap]
    exact Or.inl (Or.inl (Or.inr ⟨p, hp', hm⟩))
  | mlp k =>
    have ht : t = mlpTensor s.mlp k := Option.some.inj h |>.symm
    subst t
    simp only [List.mem_append, List.mem_singleton]
    exact Or.inr (mlpTensor_mem _ _)
  | cache c => simp [stageParameter] at h
  | _ =>
    have hm := namedTensor_mem _ _ h
    simp only [List.mem_append, List.mem_singleton]
    exact Or.inl (Or.inr hm)

/-- Every projected parameter is an actual loaded tensor, including tensors
produced by load-time transpose, contiguous and scalar preprocessing. -/
theorem parameterInput_mem (l : Loaded) (key : InKey) (h : parameterInput l key = some t) :
    t ∈ parameterTensors l := by
  cases key with
  | tokenIds => simp [parameterInput] at h
  | embedWords | embedScales | embedBiases =>
    have hm := namedTensor_mem _ _ h
    simp only [parameterTensors, List.mem_append]
    exact Or.inl (Or.inl (Or.inl hm))
  | finalNorm =>
    have ht : t = l.model.finalNorm := Option.some.inj h |>.symm
    subst t
    simp [parameterTensors]
  | head k =>
    have hm := linearTensor_mem _ k h
    simp only [parameterTensors, List.mem_append]
    exact Or.inl (Or.inr hm)
  | stage p k =>
    obtain ⟨s, hs, ht⟩ := Option.bind_eq_some_iff.mp h
    have hm := stageParameter_mem s k ht
    simp only [parameterTensors, List.mem_append, List.mem_flatMap]
    exact Or.inr ⟨s, List.mem_of_getElem? hs, by simpa only [List.mem_append, List.mem_flatMap] using hm⟩


/-- The cache objects required by the graph exist and contain no prior arrays. -/
def EmptyCacheInputs (l : Loaded) : Prop :=
  ∀ (p : Nat) (s : Stage), l.model.stages[p]? = some s →
    ∃ (c : Cache), l.cache[p]? = some c ∧ c.first = none ∧ c.second = none

theorem inputNode_initial (l : Loaded) (token : Tensor) (hc : EmptyCacheInputs l)
    (key : InKey) (hk : key ≠ .tokenIds) :
    inputNode l token key = (parameterInput l key).map Tensor.node := by
  cases key with
  | tokenIds => contradiction
  | embedWords | embedScales | embedBiases | finalNorm => rfl
  | head k => cases k <;> rfl
  | stage p k =>
    cases hs : l.model.stages[p]? with
    | none => simp [inputNode, parameterInput, hs]
    | some s =>
      obtain ⟨c, hc, hf, hg⟩ := hc p s hs
      cases k <;> simp [inputNode, parameterInput, hs, hc, stageNode, stageParameter,
        linearNode, linearTensor, mlpNode, mlpTensor, hf, hg, Option.map_bind, Option.bind_map]
      case lin j k =>
        cases h : s.linears[j]? <;> simp [h]
        rename_i pair
        cases k <;> rfl
      case mlp k => cases k <;> rfl
      case cache c =>
        cases c <;> simp_all
        rename_i c
        cases c <;> simp_all

section
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- Initial graph inputs follow from the loaded parameter values and actual
prompt bytes. No input-tensor evaluation is hidden in the carrier certificate. -/
theorem inputsHeld_initial (l : Loaded) (token : Tensor) (value : TensorValues)
    (env : FfiEval.Env InKey) (G : Nat → Option (RNode Int InKey))
    (E : List (RNode Int InKey)) (cert : List Nat)
    (hc : EmptyCacheInputs l)
    (hp : ∀ t, t ∈ parameterTensors l → evalR M K env G t.node = some (value t))
    (hi : ∀ key, key ≠ .tokenIds → env.inputs key = (parameterInput l key).map value)
    (ht : evalR M K env G token.node = env.inputs .tokenIds)
    (hm : inputCarriersMatch E cert (inputNode l token) = true) :
    InputsHeld M K env G E cert := by
  apply inputsHeld_of_carriers M K env G E cert (inputNode l token) hm
  intro key n hn
  by_cases hk : key = .tokenIds
  · subst key
    have hn' : token.node = n := Option.some.inj hn
    simpa only [← hn'] using ht
  · rw [inputNode_initial l token hc key hk] at hn
    obtain ⟨t, ht', rfl⟩ := Option.map_eq_some_iff.mp hn
    rw [hi key hk, ht']
    exact hp t (parameterInput_mem l key ht')
end

end Host.Load.Extract
