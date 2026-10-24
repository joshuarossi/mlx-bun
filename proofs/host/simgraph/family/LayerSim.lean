import host.simgraph.family.LayerNat
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # The layer templates' builders carry their value computations

For each template: from a graph whose nodes hold the facts `fs` (among them
its arguments' values), the graph instance's result nodes hold the value
instance's results (`Sim`), the projection and MLP parameters assumed to do
the same. -/

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {K : KernelContract C} {κ : Type} {env : Env κ}
  {ks : KernelSem} (ν : Nat → Int)

theorem sim_normT (fs : List (Nat × Value)) (key : κ) (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (normT graphB key x) (normT (valueB P K env ks) key v) := by
  unfold normT; sim_peel

theorem sim_rowsProjT (R : Rows) (lay : LinLayout) (key : LinKey → κ) (fs : List (Nat × Value)) (x : Nat) (v : Value)
    (h : (x, v) ∈ fs) :
    Sim P K env ks fs (rowsProjT graphB (PDim.eval ν) R lay key x) (rowsProjT (valueB P K env ks) (PDim.eval ν) R lay key v) := by
  unfold rowsProjT; sim_peel


theorem sim_splitProjT (R : Rows) (lay : LinLayout) (key : LinKey → κ) (fs : List (Nat × Value)) (x : Nat) (v : Value)
    (h : (x, v) ∈ fs) :
    Sim P K env ks fs (splitProjT graphB (PDim.eval ν) R lay key x)
      (splitProjT (valueB P K env ks) (PDim.eval ν) R lay key v) := by
  unfold splitProjT; sim_peel

theorem sim_downT (R : Rows) (pass : DownPass) (mlay : MlpLayout) (key : MlpKey → κ) (fs : List (Nat × Value))
    (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (downT graphB (PDim.eval ν) R pass mlay key x)
      (downT (valueB P K env ks) (PDim.eval ν) R pass mlay key v) := by
  unfold downT; sim_peel

theorem sim_codebookMlpT (R : Rows) (mlay : MlpLayout) (key : MlpKey → κ) (fs : List (Nat × Value))
    (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (codebookMlpT graphB (PDim.eval ν) R mlay key x)
      (codebookMlpT (valueB P K env ks) (PDim.eval ν) R mlay key v) := by
  unfold codebookMlpT
  sim_peel

theorem sim_wideMlpT (R : Rows) (mt : Nat) (pass : DownPass) (mlay : MlpLayout) (key : MlpKey → κ)
    (fs : List (Nat × Value)) (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (wideMlpT graphB (PDim.eval ν) R mt pass mlay key x)
      (wideMlpT (valueB P K env ks) (PDim.eval ν) R mt pass mlay key v) := by
  unfold wideMlpT
  sim_peel

theorem sim_embedT (ids : κ) (key : InKey → κ) (fs : List (Nat × Value)) :
    Sim P K env ks fs (embedT graphB ids key) (embedT (valueB P K env ks) ids key) := by
  unfold embedT; sim_peel

theorem sim_optInpT (b : Bool) (key : κ) (zp : RPrim Int κ) (fs : List (Nat × Value)) :
    Sim P K env ks fs (optInpT graphB b key zp) (optInpT (valueB P K env ks) b key zp) := by
  cases b
  · exact sim_op _ [] [] .nil
  · exact sim_inp key

theorem sim_kvStepT (R : Rows) (o n : Nat) (cap : Option Nat) (key : κ) (fs : List (Nat × Value)) (x : Nat)
    (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (kvStepT graphB (PDim.eval ν) R o n cap key x)
      (kvStepT (valueB P K env ks) (PDim.eval ν) R o n cap key v) := by
  unfold kvStepT
  refine sim_bind (α := Nat) (β := Value) ?_ fun b vb => ?_
  · cases cap with
    | none => exact sim_op _ [] [] .nil
    | some c =>
      unfold kvGrowT
      refine sim_bind (sim_inp _) fun b vb => ?_
      unfold kvGrownT
      refine sim_ite _ (fun _ => ?_) (fun _ => ?_)
      · refine sim_bind (α := Nat) (β := Value) ?_ fun old vold => ?_
        · unfold kvOldT
          refine sim_ite _ (fun _ => ?_) (fun _ => ?_) <;> sim_peel
        · sim_peel
      · sim_peel
  · refine sim_bind (sim_op _ _ _ ?_) fun c vc => ?_
    · args_mem
    refine sim_bind (α := Nat) (β := Value) ?_ fun d vd => ?_
    · unfold kvViewT
      refine sim_ite _ (fun _ => ?_) (fun _ => ?_) <;> sim_peel
    · sim_peel

theorem sim_readT (R : Rows) (rd : Read) (aux : Nat → κ) (fs : List (Nat × Value)) (q k w : Nat) (vq vk vw : Value)
    (hq : (q, vq) ∈ fs) (hk : (k, vk) ∈ fs) (hw : (w, vw) ∈ fs) :
    Sim P K env ks fs (readT graphB (PDim.eval ν) R rd aux q k w)
      (readT (valueB P K env ks) (PDim.eval ν) R rd aux vq vk vw) := by
  cases rd with
  | causal => unfold readT; sim_peel
  | folded r => unfold readT; sim_peel

variable (proj : LinLayout → (LinKey → κ) → Nat → Build Int κ Nat)
  (projV : LinLayout → (LinKey → κ) → Value → Option Value)
  (mlp : MlpLayout → (MlpKey → κ) → Nat → Build Int κ Nat) (mlpV : MlpLayout → (MlpKey → κ) → Value → Option Value)
  (hp : ∀ lay key fs x v, (x, v) ∈ fs → Sim P K env ks fs (proj lay key x) (projV lay key v))
  (hm : ∀ lay key fs x v, (x, v) ∈ fs → Sim P K env ks fs (mlp lay key x) (mlpV lay key v))
include hp hm

/-- Apply a sub-template's simulation, its input fact by membership. -/
macro "sim_sub " t:term : tactic => `(tactic| (refine sim_bind ($t _ _ ?_) fun _ _ => ?_; · mem_tac))

theorem sim_deltaLayerT (R : Rows) (d : DeltaLayout) (key : SKey → κ) (aux : Nat → κ) (fs : List (Nat × Value))
    (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (deltaLayerT graphB (PDim.eval ν) proj mlp R d key aux x)
      (deltaLayerT (valueB P K env ks) (PDim.eval ν) projV mlpV R d key aux v) := by
  unfold deltaLayerT
  sim_sub sim_normT _ _
  sim_sub hp _ _ _
  sim_sub hp _ _ _
  sim_peel
  sim_sub hp _ _ _
  sim_sub hp _ _ _
  refine sim_bind (sim_optInpT _ _ _ _) fun conv vconv => ?_
  sim_peel
  sim_sub sim_normT _ _
  sim_sub sim_normT _ _
  sim_peel
  refine sim_bind (sim_optInpT _ _ _ _) fun st vst => ?_
  sim_peel
  sim_sub sim_normT _ _
  sim_peel
  sim_sub hp _ _ _
  sim_peel
  sim_sub sim_normT _ _
  sim_sub hm _ _ _
  sim_peel

theorem sim_attentionLayerT (R : Rows) (o n : Nat) (rd : Read) (a : AttnLayout) (key : SKey → κ) (aux : Nat → κ)
    (fs : List (Nat × Value)) (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    Sim P K env ks fs (attentionLayerT graphB (PDim.eval ν) proj mlp R o n rd a key aux x)
      (attentionLayerT (valueB P K env ks) (PDim.eval ν) projV mlpV R o n rd a key aux v) := by
  unfold attentionLayerT
  sim_sub sim_normT _ _
  sim_sub hp _ _ _
  sim_peel
  sim_sub hp _ _ _
  sim_sub hp _ _ _
  sim_sub sim_normT _ _
  sim_peel
  sim_sub sim_normT _ _
  sim_peel
  refine sim_bind (sim_kvStepT ν R o n _ _ _ _ _ ?_) fun ⟨kb, keys⟩ ⟨vkb, vkeys⟩ => ?_
  · mem_tac
  dsimp only
  refine sim_bind (sim_kvStepT ν R o n _ _ _ _ _ ?_) fun ⟨vb, values⟩ ⟨vvb, vvalues⟩ => ?_
  · mem_tac
  dsimp only
  refine sim_bind (sim_readT ν R rd aux _ _ _ _ _ _ _ ?_ ?_ ?_) fun attn vattn => ?_
  · mem_tac
  · mem_tac
  · mem_tac
  sim_peel
  sim_sub hp _ _ _
  sim_peel
  sim_sub sim_normT _ _
  sim_sub hm _ _ _
  sim_peel

end

end Host.Mlx.SimGraph
