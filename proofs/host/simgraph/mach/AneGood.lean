import host.simgraph.family.AneFamilies
import host.simgraph.ref.Ane
namespace Host.Mlx.SimGraph.Mach
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Inference.Contracts.Mlx
open Host.Mlx.SimGraph.Ref (noInputK)

/-! # Every node of a Neural Engine family's graph has a value

`Sim` (family/Eval.lean) keeps the facts of a builder's results only. The node-by-node run of a Neural
Engine step (`aneNodes`) needs every node of the family's graph defined, and each node an input without
arguments or a primitive reading no input (`NodeForm`). `SimA` is `Sim` keeping that of the whole graph
(`Good`); its combinators are `Sim`'s, and the Neural Engine family's templates satisfy it as they satisfy
`Sim` (`aneGraph_good`: when the family's value instance is defined, every node of its graph is). -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} (env : Env κ)
  (ks : KernelSem)

/-- A node as the node-by-node run reads it: an input without arguments, or a primitive reading no input. -/
def NodeForm (nd : RNode Int κ) : Prop := (∃ k, nd.prim = .input k ∧ nd.ins = []) ∨ noInputK nd.prim = true

/-- Every node of `g` has a value and the node-by-node run's form. -/
def Good (g : List (RNode Int κ)) : Prop :=
  ∀ i (h : i < g.length), (∃ v, evalE P K env ks (listGraph g) i = some v) ∧ NodeForm g[i]

/-- `Sim` keeping `Good`. -/
def SimA {α β : Type} [Handle α β] (fs : List (Nat × Value)) (b : Build Int κ α) (bv : Option β) : Prop :=
  ∀ g, AllEvE P K env ks g fs → Good P K env ks g → ∀ v, bv = some v →
    Spec b g (fun a g' => AllEvE P K env ks g' (Handle.facts a v ++ fs) ∧ Good P K env ks g' ∧ ∃ t, g' = g ++ t)

theorem good_nil : Good P K env ks [] := fun _ h => absurd h (by simp)

variable {P K env ks}

theorem good_snoc {g : List (RNode Int κ)} (hg : Good P K env ks g) (nd : RNode Int κ) (w : Value)
    (hw : evalE P K env ks (listGraph (g ++ [nd])) g.length = some w) (hf : NodeForm nd) :
    Good P K env ks (g ++ [nd]) := by
  intro i hi
  rw [List.length_append, List.length_singleton] at hi
  by_cases h : i < g.length
  · obtain ⟨⟨v, hv⟩, hn⟩ := hg i h
    refine ⟨⟨v, by rw [evalE_append P K env ks g [nd] i h]; exact hv⟩, ?_⟩
    rw [List.getElem_append_left h]; exact hn
  · have e : i = g.length := by omega
    subst e
    refine ⟨⟨w, hw⟩, ?_⟩
    rw [List.getElem_append_right (by omega)]
    simpa using hf

theorem simA_bind {α β γ ε : Type} [Handle α β] [Handle γ ε] {fs : List (Nat × Value)} {x : Build Int κ α}
    {xv : Option β} {k : α → Build Int κ γ} {kv : β → Option ε} (hx : SimA P K env ks fs x xv)
    (hk : ∀ a v, SimA P K env ks (Handle.facts a v ++ fs) (k a) (kv v)) :
    SimA P K env ks fs (x >>= k) (xv >>= kv) := by
  intro g hg hgood w hw
  obtain ⟨v, hv, hkv⟩ := Option.bind_eq_some_iff.mp hw
  obtain ⟨h1, hg1, t1, ht1⟩ := hx g hg hgood v hv
  obtain ⟨h2, hg2, t2, ht2⟩ := hk (run x g).1 v (run x g).2 h1 hg1 w hkv
  refine ⟨h2.mono P K env ks fun q hq => ?_, hg2, t1 ++ t2, ?_⟩
  · rcases List.mem_append.mp hq with hq | hq
    · exact List.mem_append_left _ hq
    · exact List.mem_append_right _ (List.mem_append_right _ hq)
  · show (run (k (run x g).1) (run x g).2).2 = _
    rw [ht2, ht1, List.append_assoc]

theorem simA_pure {α β : Type} [Handle α β] {fs : List (Nat × Value)} {a : α} {v : β}
    (h : ∀ q ∈ Handle.facts a v, q ∈ fs) : SimA P K env ks fs (pure a) (some v) := by
  intro g hg hgood w hw
  cases hw
  refine ⟨fun q hq => ?_, hgood, [], by simp [run, pure, StateT.pure]⟩
  rcases List.mem_append.mp hq with hq | hq
  · exact hg q (h q hq)
  · exact hg q hq

theorem simA_emit {fs : List (Nat × Value)} (p : RPrim Int κ) (ins : List Nat) (vs : List Value)
    (hf : NodeForm ⟨p, ins⟩) (hargs : List.Forall₂ (fun i v => (i, v) ∈ fs) ins vs) :
    SimA P K env ks fs (emit p ins) (primEvalE P K env ks p vs) := by
  intro g hg hgood w hw
  obtain ⟨h1, t, ht⟩ := sim_emit (P := P) (K := K) (env := env) (ks := ks) p ins vs hargs g hg w hw
  refine ⟨h1, ?_, t, ht⟩
  have ht' : t = [⟨p, ins⟩] := by
    have : (run (emit p ins) g).2 = g ++ [⟨p, ins⟩] := rfl
    rw [this] at ht
    exact (List.append_cancel_left ht).symm
  subst ht'
  show Good P K env ks (g ++ [⟨p, ins⟩])
  refine good_snoc hgood ⟨p, ins⟩ w ?_ hf
  have := h1 (g.length, w) (List.mem_append_left _ (by simp [run, emit]))
  exact this.2

theorem simA_op {fs : List (Nat × Value)} (p : RPrim Int κ) (ins : List Nat) (vs : List Value)
    (hp : noInputK p = true) (hargs : List.Forall₂ (fun i v => (i, v) ∈ fs) ins vs) :
    SimA P K env ks fs (graphB.op p ins) ((valueB P K env ks).op p vs) :=
  simA_emit p ins vs (.inr hp) hargs

theorem simA_inp {fs : List (Nat × Value)} (k : κ) :
    SimA P K env ks fs (graphB.inp k) ((valueB P K env ks).inp k) := by
  show SimA P K env ks fs (emit (.input k) []) (env.inputs k)
  have : primEvalE P K env ks (.input k) [] = env.inputs k := by
    simp only [primEvalE, closureOf?, primEvalP, primEval, Option.orElse]
    cases env.inputs k <;> rfl
  rw [← this]
  exact simA_emit _ [] [] (.inl ⟨k, rfl, rfl⟩) .nil

theorem simA_ite {α β : Type} [Handle α β] {fs : List (Nat × Value)} (c : Prop) [Decidable c]
    {b₁ b₂ : Build Int κ α} {v₁ v₂ : Option β} (h₁ : c → SimA P K env ks fs b₁ v₁)
    (h₂ : ¬ c → SimA P K env ks fs b₂ v₂) :
    SimA P K env ks fs (if c then b₁ else b₂) (if c then v₁ else v₂) := by
  by_cases hc : c
  · simp only [hc, ↓reduceIte]; exact h₁ hc
  · simp only [hc, ↓reduceIte]; exact h₂ hc

theorem simA_map {α β γ ε : Type} [Handle α β] [Handle γ ε] {fs : List (Nat × Value)} {x : Build Int κ α}
    {xv : Option β} (g : α → γ) (h : β → ε) (hx : SimA P K env ks fs x xv)
    (hg : ∀ a v, ∀ q ∈ Handle.facts (g a) (h v), q ∈ Handle.facts a v ++ fs) :
    SimA P K env ks fs (g <$> x) (h <$> xv) := by
  intro gr hgr hgood w hw
  obtain ⟨v, hv, rfl⟩ := Option.map_eq_some_iff.mp hw
  obtain ⟨h1, hg1, t, ht⟩ := hx gr hgr hgood v hv
  refine ⟨fun q hq => ?_, hg1, t, ht⟩
  rcases List.mem_append.mp hq with hq | hq
  · exact h1 q (hg _ _ q hq)
  · exact h1 q (List.mem_append_right _ hq)

end

/-- `sim_peel` for `SimA`: operations (reading no input, by `rfl`), inputs, mapped results, the final result. -/
macro "simA_peel" : tactic => `(tactic| ((repeat' (first
  | refine simA_bind (simA_op _ _ _ rfl ?_) fun _ _ => ?_
  | refine simA_bind (simA_inp _) fun _ _ => ?_
  | refine simA_map _ _ (simA_op _ _ _ rfl ?_) (fun _ _ => ?_)
  | refine simA_pure ?_
  | refine simA_op _ _ _ rfl ?_
  | exact simA_inp _
  | args_mem
  | facts_sub))))

/-- Apply a sub-template's `SimA`, its input fact by membership. -/
macro "simA_sub " t:term : tactic => `(tactic| (refine simA_bind ($t _ _ ?_) fun _ _ => ?_; · mem_tac))

/-! ## The templates -/

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {K : KernelContract C} {κ : Type} {env : Env κ}
  {ks : KernelSem} (ν : Nat → Int)

theorem simA_normT (fs : List (Nat × Value)) (key : κ) (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    SimA P K env ks fs (normT graphB key x) (normT (valueB P K env ks) key v) := by
  unfold normT; simA_peel

theorem simA_embedT (ids : κ) (key : InKey → κ) (fs : List (Nat × Value)) :
    SimA P K env ks fs (embedT graphB ids key) (embedT (valueB P K env ks) ids key) := by
  unfold embedT; simA_peel

theorem simA_optInpT (b : Bool) (key : κ) (zp : RPrim Int κ) (hz : noInputK zp = true) (fs : List (Nat × Value)) :
    SimA P K env ks fs (optInpT graphB b key zp) (optInpT (valueB P K env ks) b key zp) := by
  cases b
  · exact simA_op _ [] [] hz .nil
  · exact simA_inp key

theorem simA_kvStepT (R : Rows) (o n : Nat) (cap : Option Nat) (key : κ) (fs : List (Nat × Value)) (x : Nat)
    (v : Value) (h : (x, v) ∈ fs) :
    SimA P K env ks fs (kvStepT graphB (PDim.eval ν) R o n cap key x)
      (kvStepT (valueB P K env ks) (PDim.eval ν) R o n cap key v) := by
  unfold kvStepT
  refine simA_bind (α := Nat) (β := Value) ?_ fun b vb => ?_
  · cases cap with
    | none => exact simA_op _ [] [] rfl .nil
    | some c =>
      unfold kvGrowT
      refine simA_bind (simA_inp _) fun b vb => ?_
      unfold kvGrownT
      refine simA_ite _ (fun _ => ?_) (fun _ => ?_)
      · refine simA_bind (α := Nat) (β := Value) ?_ fun old vold => ?_
        · unfold kvOldT
          refine simA_ite _ (fun _ => ?_) (fun _ => ?_) <;> simA_peel
        · simA_peel
      · simA_peel
  · refine simA_bind (simA_op _ _ _ rfl ?_) fun c vc => ?_
    · args_mem
    refine simA_bind (α := Nat) (β := Value) ?_ fun d vd => ?_
    · unfold kvViewT
      refine simA_ite _ (fun _ => ?_) (fun _ => ?_) <;> simA_peel
    · simA_peel

theorem simA_readCausal (R : Rows) (aux : Nat → κ) (fs : List (Nat × Value)) (q k w : Nat) (vq vk vw : Value)
    (hq : (q, vq) ∈ fs) (hk : (k, vk) ∈ fs) (hw : (w, vw) ∈ fs) :
    SimA P K env ks fs (readT graphB (PDim.eval ν) R .causal aux q k w)
      (readT (valueB P K env ks) (PDim.eval ν) R .causal aux vq vk vw) := by
  unfold readT; simA_peel

theorem simA_denseProjT (lay : LinLayout) (key : LinKey → κ) (fs : List (Nat × Value)) (x : Nat) (v : Value)
    (h : (x, v) ∈ fs) :
    SimA P K env ks fs (denseProjT graphB lay key x) (denseProjT (valueB P K env ks) lay key v) := by
  unfold denseProjT; simA_peel

theorem simA_plainProjT (lay : LinLayout) (key : LinKey → κ) (fs : List (Nat × Value)) (x : Nat) (v : Value)
    (h : (x, v) ∈ fs) :
    SimA P K env ks fs (plainProjT graphB lay key x) (plainProjT (valueB P K env ks) lay key v) := by
  unfold plainProjT; simA_peel

theorem simA_aneSplitProjT (R : Rows) (lay : LinLayout) (nA : Nat) (head rest : LinKey → κ) (out : κ)
    (fs : List (Nat × Value)) (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    SimA P K env ks fs (aneSplitProjT graphB (PDim.eval ν) R lay nA head rest out x)
      (aneSplitProjT (valueB P K env ks) (PDim.eval ν) R lay nA head rest out v) := by
  unfold aneSplitProjT
  simA_peel
  refine simA_bind (simA_denseProjT _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  simA_peel

theorem simA_aneProjT (R : Rows) (k : AneProj) (lay : LinLayout) (key head rest : LinKey → κ) (out : κ)
    (fs : List (Nat × Value)) (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    SimA P K env ks fs (aneProjT graphB (PDim.eval ν) R k lay key head rest out x)
      (aneProjT (valueB P K env ks) (PDim.eval ν) R k lay key head rest out v) := by
  cases k with
  | dense =>
    unfold aneProjT
    refine simA_bind (simA_denseProjT _ _ _ _ _ h) fun _ _ => ?_
    simA_peel
  | plain =>
    unfold aneProjT
    refine simA_bind (simA_plainProjT _ _ _ _ _ h) fun _ _ => ?_
    simA_peel
  | split nA => exact simA_aneSplitProjT ν R lay nA head rest out fs x v h

theorem simA_aneMlpT (R : Rows) (rest : Nat) (mlay : MlpLayout) (key : MlpKey → κ) (out : κ)
    (fs : List (Nat × Value)) (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    SimA P K env ks fs (aneMlpT graphB (PDim.eval ν) R rest mlay key out x)
      (aneMlpT (valueB P K env ks) (PDim.eval ν) R rest mlay key out v) := by
  unfold aneMlpT; simA_peel

variable (proj : Nat → LinLayout → Nat → Build Int κ (Nat × Nat × Nat))
  (projV : Nat → LinLayout → Value → Option (Value × Value × Value))
  (mlp : MlpLayout → Nat → Build Int κ (Nat × Nat)) (mlpV : MlpLayout → Value → Option (Value × Value))
  (hp : ∀ j lay fs x v, (x, v) ∈ fs → SimA P K env ks fs (proj j lay x) (projV j lay v))
  (hm : ∀ lay fs x v, (x, v) ∈ fs → SimA P K env ks fs (mlp lay x) (mlpV lay v))
include hp hm

theorem simA_aneDeltaLayerT (R : Rows) (d : DeltaLayout) (key : SKey → κ) (aux : Nat → κ) (fs : List (Nat × Value))
    (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    SimA P K env ks fs (aneDeltaLayerT graphB (PDim.eval ν) proj mlp R d key aux x)
      (aneDeltaLayerT (valueB P K env ks) (PDim.eval ν) projV mlpV R d key aux v) := by
  unfold aneDeltaLayerT
  simA_sub simA_normT _ _
  refine simA_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  refine simA_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  simA_peel
  refine simA_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  refine simA_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  refine simA_bind (simA_optInpT _ _ _ rfl _) fun conv vconv => ?_
  simA_peel
  simA_sub simA_normT _ _
  simA_sub simA_normT _ _
  simA_peel
  refine simA_bind (simA_optInpT _ _ _ rfl _) fun st vst => ?_
  simA_peel
  simA_sub simA_normT _ _
  simA_peel
  refine simA_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  simA_peel
  simA_sub simA_normT _ _
  refine simA_bind (hm _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  simA_peel

theorem simA_aneAttentionLayerT (R : Rows) (o n : Nat) (a : AttnLayout) (key : SKey → κ) (aux : Nat → κ)
    (fs : List (Nat × Value)) (x : Nat) (v : Value) (h : (x, v) ∈ fs) :
    SimA P K env ks fs (aneAttentionLayerT graphB (PDim.eval ν) proj mlp R o n a key aux x)
      (aneAttentionLayerT (valueB P K env ks) (PDim.eval ν) projV mlpV R o n a key aux v) := by
  unfold aneAttentionLayerT
  simA_sub simA_normT _ _
  refine simA_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  simA_peel
  refine simA_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  refine simA_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  simA_sub simA_normT _ _
  simA_peel
  simA_sub simA_normT _ _
  simA_peel
  refine simA_bind (simA_kvStepT ν R o n _ _ _ _ _ ?_) fun ⟨kb, keys⟩ ⟨vkb, vkeys⟩ => ?_
  · mem_tac
  dsimp only
  refine simA_bind (simA_kvStepT ν R o n _ _ _ _ _ ?_) fun ⟨vb, values⟩ ⟨vvb, vvalues⟩ => ?_
  · mem_tac
  dsimp only
  refine simA_bind (simA_readCausal ν R aux _ _ _ _ _ _ _ ?_ ?_ ?_) fun attn vattn => ?_
  · mem_tac
  · mem_tac
  · mem_tac
  simA_peel
  refine simA_bind (hp _ _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  simA_peel
  simA_sub simA_normT _ _
  refine simA_bind (hm _ _ _ _ ?_) fun _ _ => ?_
  · mem_tac
  simA_peel

end

/-! ## The family -/

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {K : KernelContract C} {env : Env AKey} {ks : KernelSem}
  (R : Rows) (k : AneKinds) (rest : Nat) (ν : Nat → Int) (o n : Nat)

theorem simA_aneLayer (p : Nat) (s : StageLayout) (x : Nat) (v : Value) (fs : List (Nat × Value)) (h : (x, v) ∈ fs) :
    SimA P K env ks fs ((aneTpl R k rest).layer graphB (PDim.eval ν) o n p s x)
      ((aneTpl R k rest).layer (valueB P K env ks) (PDim.eval ν) o n p s v) := by
  dsimp only [aneTpl]
  cases s with
  | delta d =>
    exact simA_aneDeltaLayerT ν (aneProjAt graphB (PDim.eval ν) R k.delta p)
      (aneProjAt (valueB P K env ks) (PDim.eval ν) R k.delta p) (aneMlpAt graphB (PDim.eval ν) R rest p)
      (aneMlpAt (valueB P K env ks) (PDim.eval ν) R rest p)
      (fun j lay fs x v h => simA_aneProjT ν R _ lay _ _ _ _ fs x v h)
      (fun lay fs x v h => simA_aneMlpT ν R rest lay _ _ fs x v h) R d _ _ fs x v h
  | attention a =>
    exact simA_aneAttentionLayerT ν (aneProjAt graphB (PDim.eval ν) R k.attn p)
      (aneProjAt (valueB P K env ks) (PDim.eval ν) R k.attn p) (aneMlpAt graphB (PDim.eval ν) R rest p)
      (aneMlpAt (valueB P K env ks) (PDim.eval ν) R rest p)
      (fun j lay fs x v h => simA_aneProjT ν R _ lay _ _ _ _ fs x v h)
      (fun lay fs x v h => simA_aneMlpT ν R rest lay _ _ fs x v h) R o n a _ _ fs x v h

theorem simA_aneChain : ∀ (p : Nat) (ss : List StageLayout) (x : Nat) (v : Value) (fs : List (Nat × Value)),
    (x, v) ∈ fs → SimA P K env ks fs (chainTX (aneTpl R k rest) graphB (PDim.eval ν) o n p ss x)
      (chainTX (aneTpl R k rest) (valueB P K env ks) (PDim.eval ν) o n p ss v)
  | _, [], x, v, fs, h => simA_pure (by intro q hq; simp [Handle.facts] at hq; rcases hq with rfl; exact h)
  | p, s :: ss, x, v, fs, h => by
    refine simA_bind (simA_aneLayer R k rest ν o n p s x v fs h) fun ⟨⟨y, c1, c2⟩, ts⟩ ⟨⟨vy, vc1, vc2⟩, vts⟩ => ?_
    dsimp only
    refine simA_bind (simA_aneChain (p + 1) ss y vy _ (by simp [Handle.facts]))
      fun ⟨z, cs, tss⟩ ⟨vz, vcs, vtss⟩ => ?_
    dsimp only
    refine simA_pure fun q hq => ?_
    simp only [Handle.facts, List.zip_cons_cons, List.flatMap_cons, List.mem_append] at hq ⊢
    rcases hq with hq | ((hq | hq) | hq) | (hq | hq) <;> simp_all

/-- **Every node of a Neural Engine family's graph has a value** (and the node-by-node run's form) when the
family's value instance is defined. -/
theorem aneGraph_good (ss : List StageLayout) (r : (Value × List (Value × Value)) × List (List (List Value)))
    (hv : forwardTX (aneTpl R k rest) (valueB P K env ks) (PDim.eval ν) o n ss = some r) :
    Good P K env ks (familyGraph (aneTpl R k rest).toTpl.ops (PDim.eval ν) o n ss).1 := by
  have hS : SimA P K env ks [] (forwardTX (aneTpl R k rest) graphB (PDim.eval ν) o n ss)
      (forwardTX (aneTpl R k rest) (valueB P K env ks) (PDim.eval ν) o n ss) := by
    refine simA_bind (by dsimp only [aneTpl]; exact simA_embedT _ _ []) fun x vx => ?_
    refine simA_bind (simA_aneChain R k rest ν o n 0 ss x vx _ (by simp [Handle.facts]))
      fun ⟨y, cs, tss⟩ ⟨vy, vcs, vtss⟩ => ?_
    dsimp only
    refine simA_bind (by dsimp only [aneTpl]; exact simA_normT _ _ y vy (by simp [Handle.facts])) fun r vr => ?_
    refine simA_pure fun q hq => ?_
    simp only [Handle.facts, List.mem_append] at hq ⊢
    rcases hq with (hq | hq) | hq <;> simp_all
  obtain ⟨_, hg, _⟩ := hS [] (fun _ h => by cases h) (good_nil P K env ks) r hv
  rw [familyGraph_toTpl]
  exact hg

end

end Host.Mlx.SimGraph.Mach
