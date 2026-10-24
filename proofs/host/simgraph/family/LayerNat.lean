import host.simgraph.family.Layers
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # The layer templates' builders are natural, and branch only on the KV signature

* `nat_*`: each template's graph instance at `I` and the dimension map `f` is
  its graph instance at `f ∘ I` (`Natural`), given the same of its projection
  and MLP parameters;
* `kvStepT_graph`: the KV append's graph instance is `kvStepP`, so its branches
  are `kvSigP`'s (`kvStepT_sig`), and the attention layer's
  (`attentionLayerT_sig`). -/

section
variable {δ δ' κ : Type} (f : δ → δ')

theorem natB_op {p : RPrim δ κ} {p' : RPrim δ' κ} (ins : List Nat) (h : mapP f p = p') :
    Natural f (graphB.op p ins) (graphB.op p' ins) := natural_emit ins h

theorem natB_inp (k : κ) : Natural f (graphB (δ := δ).inp k) (graphB.inp k) := natural_emit [] rfl

/-- Close the side conditions `mapP f p = p'` of the templates' primitives. -/
macro "dimB_map" : tactic =>
  `(tactic| first | rfl | simp [mapP, mapC_kcfg, rowsCfg, splitCfg, downCfg, codebookCfg, wideCfg, gatedCfg, li, lis,
    List.map_map, Function.comp_def])

/-- Peel the templates' binds: operations, inputs, norms. -/
macro "natB_peel" : tactic => `(tactic| ((repeat' (first
  | with_reducible refine natural_bind (natB_op _ _ ?_) fun _ => ?_
  | with_reducible refine natural_bind (natB_inp _ _) fun _ => ?_
  | with_reducible exact natural_pure _
  | with_reducible refine natural_map _ ?_
  | with_reducible refine natB_op _ _ ?_
  | with_reducible exact natB_inp _ _)); all_goals (try dimB_map)))

variable (I : PDim → δ)

theorem nat_normT (key : κ) (x : Nat) : Natural f (normT (δ := δ) graphB key x) (normT (δ := δ') graphB key x) := by
  unfold normT; natB_peel

theorem nat_optInpT (b : Bool) (key : κ) (zp : RPrim δ κ) (zp' : RPrim δ' κ) (h : mapP f zp = zp') :
    Natural f (optInpT graphB b key zp) (optInpT graphB b key zp') := by
  cases b
  · exact natB_op f [] h
  · exact natB_inp f key

theorem nat_rowsProjT (R : Rows) (lay : LinLayout) (key : LinKey → κ) (x : Nat) :
    Natural f (rowsProjT graphB I R lay key x) (rowsProjT graphB (fun d => f (I d)) R lay key x) := by
  unfold rowsProjT; natB_peel

theorem nat_splitProjT (R : Rows) (lay : LinLayout) (key : LinKey → κ) (x : Nat) :
    Natural f (splitProjT graphB I R lay key x) (splitProjT graphB (fun d => f (I d)) R lay key x) := by
  unfold splitProjT; natB_peel

theorem nat_downT (R : Rows) (pass : DownPass) (mlay : MlpLayout) (key : MlpKey → κ) (x : Nat) :
    Natural f (downT graphB I R pass mlay key x) (downT graphB (fun d => f (I d)) R pass mlay key x) := by
  unfold downT; natB_peel

theorem nat_codebookMlpT (R : Rows) (mlay : MlpLayout) (key : MlpKey → κ) (x : Nat) :
    Natural f (codebookMlpT graphB I R mlay key x) (codebookMlpT graphB (fun d => f (I d)) R mlay key x) := by
  unfold codebookMlpT
  natB_peel
  exact nat_downT f I R _ mlay key _

theorem nat_wideMlpT (R : Rows) (mt : Nat) (pass : DownPass) (mlay : MlpLayout) (key : MlpKey → κ) (x : Nat) :
    Natural f (wideMlpT graphB I R mt pass mlay key x) (wideMlpT graphB (fun d => f (I d)) R mt pass mlay key x) := by
  unfold wideMlpT
  natB_peel
  exact nat_downT f I R _ mlay key _

theorem nat_embedT (ids : κ) (key : InKey → κ) :
    Natural f (embedT (δ := δ) graphB ids key) (embedT (δ := δ') graphB ids key) := by
  unfold embedT; natB_peel

theorem kvStepT_graph (R : Rows) (o n : Nat) (cap : Option Nat) (key : κ) (x : Nat) :
    kvStepT graphB I R o n cap key x =
      kvStepP (fun i => I (.lit i)) o n (I R.oP) (I R.onP) (I (PDim.rupF 256 R.nP)) cap key x := by
  have ho : ∀ b, kvOldT (κ := κ) graphB I R o b = kvOldP (fun i => I (.lit i)) o (I R.oP) b := fun _ => rfl
  have hg : ∀ c b, kvGrownT (κ := κ) graphB I R o n c b =
      kvGrownP (fun i => I (.lit i)) o n (I R.oP) (I (PDim.rupF 256 R.nP)) c b := by
    intro c b; unfold kvGrownT kvGrownP; rw [ho]; rfl
  have hw : kvGrowT graphB I R o n cap key = kvGrowP (fun i => I (.lit i)) o n (I R.oP) (I (PDim.rupF 256 R.nP)) cap key := by
    cases cap with
    | none => rfl
    | some c => unfold kvGrowT kvGrowP; simp only [hg]; rfl
  have hv : ∀ b, kvViewT (κ := κ) graphB I R o n cap b = kvViewP (fun i => I (.lit i)) o n (I R.onP) cap b := fun _ => rfl
  unfold kvStepT kvStepP
  rw [hw]
  simp only [hv]
  rfl

theorem nat_kvStepT (R : Rows) (o n : Nat) (cap : Option Nat) (key : κ) (x : Nat) :
    Natural f (kvStepT graphB I R o n cap key x) (kvStepT graphB (fun d => f (I d)) R o n cap key x) := by
  rw [kvStepT_graph, kvStepT_graph]
  exact nat_kvStepP f (fun i => I (.lit i)) o n (I R.oP) (I R.onP) (I (PDim.rupF 256 R.nP)) cap key x

theorem nat_readT (R : Rows) (rd : Read) (aux : Nat → κ) (q k v : Nat) :
    Natural f (readT graphB I R rd aux q k v) (readT graphB (fun d => f (I d)) R rd aux q k v) := by
  cases rd with
  | causal => exact natB_op f _ rfl
  | folded r => unfold readT; natB_peel

variable {I}

theorem nat_deltaLayerT (proj : LinLayout → (LinKey → κ) → Nat → Build δ κ Nat)
    (proj' : LinLayout → (LinKey → κ) → Nat → Build δ' κ Nat)
    (mlp : MlpLayout → (MlpKey → κ) → Nat → Build δ κ Nat) (mlp' : MlpLayout → (MlpKey → κ) → Nat → Build δ' κ Nat)
    (hp : ∀ lay key x, Natural f (proj lay key x) (proj' lay key x))
    (hm : ∀ lay key x, Natural f (mlp lay key x) (mlp' lay key x))
    (R : Rows) (d : DeltaLayout) (key : SKey → κ) (aux : Nat → κ) (x : Nat) :
    Natural f (deltaLayerT graphB I proj mlp R d key aux x)
      (deltaLayerT graphB (fun d => f (I d)) proj' mlp' R d key aux x) := by
  unfold deltaLayerT
  refine natural_bind (nat_normT f _ x) fun _ => ?_
  refine natural_bind (hp _ _ _) fun _ => ?_
  refine natural_bind (hp _ _ _) fun _ => ?_
  refine natural_bind (natB_op f _ (by dimB_map)) fun _ => ?_
  refine natural_bind (hp _ _ _) fun _ => ?_
  refine natural_bind (hp _ _ _) fun _ => ?_
  refine natural_bind (nat_optInpT f _ _ _ _ (by dimB_map)) fun _ => ?_
  natB_peel
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  natB_peel
  refine natural_bind (nat_optInpT f _ _ _ _ (by dimB_map)) fun _ => ?_
  natB_peel
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  natB_peel
  refine natural_bind (hp _ _ _) fun _ => ?_
  natB_peel
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  refine natural_bind (hm _ _ _) fun _ => ?_
  natB_peel

theorem nat_attentionLayerT (proj : LinLayout → (LinKey → κ) → Nat → Build δ κ Nat)
    (proj' : LinLayout → (LinKey → κ) → Nat → Build δ' κ Nat)
    (mlp : MlpLayout → (MlpKey → κ) → Nat → Build δ κ Nat) (mlp' : MlpLayout → (MlpKey → κ) → Nat → Build δ' κ Nat)
    (hp : ∀ lay key x, Natural f (proj lay key x) (proj' lay key x))
    (hm : ∀ lay key x, Natural f (mlp lay key x) (mlp' lay key x))
    (R : Rows) (o n : Nat) (rd : Read) (a : AttnLayout) (key : SKey → κ) (aux : Nat → κ) (x : Nat) :
    Natural f (attentionLayerT graphB I proj mlp R o n rd a key aux x)
      (attentionLayerT graphB (fun d => f (I d)) proj' mlp' R o n rd a key aux x) := by
  unfold attentionLayerT
  refine natural_bind (nat_normT f _ x) fun _ => ?_
  refine natural_bind (hp _ _ _) fun _ => ?_
  natB_peel
  refine natural_bind (hp _ _ _) fun _ => ?_
  refine natural_bind (hp _ _ _) fun _ => ?_
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  natB_peel
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  natB_peel
  refine natural_bind (nat_kvStepT f I R o n _ _ _) fun ⟨_, _⟩ => ?_
  dsimp only
  refine natural_bind (nat_kvStepT f I R o n _ _ _) fun ⟨_, _⟩ => ?_
  dsimp only
  refine natural_bind (nat_readT f I R rd aux _ _ _) fun _ => ?_
  natB_peel
  refine natural_bind (hp _ _ _) fun _ => ?_
  natB_peel
  refine natural_bind (nat_normT f _ _) fun _ => ?_
  refine natural_bind (hm _ _ _) fun _ => ?_
  natB_peel

end

/-! ## Branches -/

section
variable {δ κ : Type} (I : PDim → δ)

theorem kvStepT_sig (R : Rows) (o n o' n' : Nat) (cap cap' : Option Nat) (key : κ) (x : Nat)
    (h : kvSigP cap o n = kvSigP cap' o' n') :
    kvStepT graphB I R o n cap key x = kvStepT graphB I R o' n' cap' key x := by
  rw [kvStepT_graph, kvStepT_graph, kvStepP_sig _ _ _ _ o n o' n' cap cap' key x h]

theorem attentionLayerT_sig (proj : LinLayout → (LinKey → κ) → Nat → Build δ κ Nat)
    (mlp : MlpLayout → (MlpKey → κ) → Nat → Build δ κ Nat) (R : Rows) (o n o' n' : Nat) (rd : Read)
    (a a' : AttnLayout) (h : SigRelR kvSigP o n o' n' (.attention a) (.attention a')) (key : SKey → κ)
    (aux : Nat → κ) (x : Nat) :
    attentionLayerT graphB I proj mlp R o n rd a key aux x = attentionLayerT graphB I proj mlp R o' n' rd a' key aux x := by
  obtain ⟨hq, hk, hv, ho, hm, hkc, hvc⟩ := h
  unfold attentionLayerT
  rw [hq, hk, hv, ho, hm]
  simp only [kvStepT_sig I R o n o' n' a.kcap a'.kcap _ _ hkc, kvStepT_sig I R o n o' n' a.vcap a'.vcap _ _ hvc]

end

end Host.Mlx.SimGraph
