import host.simgraph.family.AneFamilies
import host.simgraph.ref.Ane
namespace Host.Mlx.SimGraph.Mach
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Inference.Contracts.Mlx
open Host.Mlx.SimGraph.Ref (noInputK)

/-! # A Neural Engine family's readbacks come after their taps

The node-by-node run of a Neural Engine step (`aneNodes`) runs a split at its readback input and reads the
split's sources at the site's tap nodes (`tapsOf`) from the values computed so far. Here, on the family's
graph alone: every input of a readback key (`.linOut p j`, `.mlpOut p`) is of a layer of the chain, at a
site (`rbSite`: a split projection's, or the MLP's) whose taps precede it (`aneOrder`), the taps of a layer
have their site shapes (`TapShape`), and there is one cache pair per stage.

* `KeysB S b`: the builder's new inputs read keys with `S`; the layer templates' plain parts read no readback
  key.
* `LInv`: within a layer, every new readback input is the layer's, at a site whose taps (collected so far)
  precede it; the projections and the MLP split extend it by their taps (`linv_proj`, `linv_mlp`). -/

/-! ## The new inputs of a builder -/

section
variable {κ : Type}

/-- `g'` extends `g`, and every new input reads a key with `S`. -/
def NewKeys (S : κ → Prop) (g g' : List (RNode Int κ)) : Prop :=
  (∃ t, g' = g ++ t) ∧ ∀ i nd k, g.length ≤ i → g'[i]? = some nd → nd.prim = .input k → S k

/-- A builder whose new inputs read keys with `S`, from any graph. -/
def KeysB {α : Type} (S : κ → Prop) (b : Build Int κ α) : Prop := ∀ g, NewKeys S g (run b g).2

theorem newKeys_refl (S : κ → Prop) (g : List (RNode Int κ)) : NewKeys S g g :=
  ⟨⟨[], by simp⟩, fun i nd k hi h _ => by rw [List.getElem?_eq_none (by omega)] at h; cases h⟩

theorem newKeys_trans {S : κ → Prop} {g g' g'' : List (RNode Int κ)} (h1 : NewKeys S g g') (h2 : NewKeys S g' g'') :
    NewKeys S g g'' := by
  obtain ⟨⟨t1, rfl⟩, k1⟩ := h1
  obtain ⟨⟨t2, rfl⟩, k2⟩ := h2
  refine ⟨⟨t1 ++ t2, by simp⟩, fun i nd k hi h hk => ?_⟩
  by_cases hlt : i < (g ++ t1).length
  · exact k1 i nd k hi (by rwa [List.getElem?_append_left hlt] at h) hk
  · exact k2 i nd k (by omega) h hk

theorem keysB_bind {α β : Type} {S : κ → Prop} {x : Build Int κ α} {f : α → Build Int κ β} (hx : KeysB S x)
    (hf : ∀ a, KeysB S (f a)) : KeysB S (x >>= f) :=
  fun g => show NewKeys S g (run (f (run x g).1) (run x g).2).2 from newKeys_trans (hx g) (hf _ _)

theorem keysB_pure {α : Type} {S : κ → Prop} (a : α) : KeysB S (pure a : Build Int κ α) := fun g => newKeys_refl S g

theorem keysB_emit {S : κ → Prop} (p : RPrim Int κ) (ins : List Nat) (h : ∀ k, p = .input k → S k) :
    KeysB S (emit p ins) := by
  intro g
  refine ⟨⟨[⟨p, ins⟩], rfl⟩, fun i nd k hi hg hk => ?_⟩
  have hl : (run (emit p ins) g).2 = g ++ [⟨p, ins⟩] := rfl
  rw [hl] at hg
  have hi' : i = g.length := by
    have := (List.getElem?_eq_some_iff.mp hg).1
    simp at this; omega
  subst hi'
  rw [List.getElem?_append_right (by omega)] at hg
  simp at hg
  subst hg
  exact h k hk

theorem keysB_op {S : κ → Prop} (p : RPrim Int κ) (ins : List Nat) (hp : noInputK p = true) :
    KeysB S (graphB.op p ins) :=
  keysB_emit p ins fun k h => by subst h; simp [noInputK] at hp

theorem keysB_inp {S : κ → Prop} {k : κ} (h : S k) : KeysB S (graphB (δ := Int).inp k) :=
  keysB_emit _ [] fun k' e => by cases e; exact h

theorem keysB_ite {α : Type} {S : κ → Prop} (c : Prop) [Decidable c] {b₁ b₂ : Build Int κ α} (h₁ : KeysB S b₁)
    (h₂ : KeysB S b₂) : KeysB S (if c then b₁ else b₂) := by
  by_cases hc : c
  · simp only [hc, ↓reduceIte]; exact h₁
  · simp only [hc, ↓reduceIte]; exact h₂

end

/-- Peel a builder's binds for `KeysB`: operations (reading no input, by `rfl`), inputs (their keys left as
goals), branches. -/
macro "keys_peel" : tactic => `(tactic| ((repeat' (first
  | refine keysB_bind (keysB_op _ _ rfl) fun _ => ?_
  | refine keysB_bind (keysB_inp ?_) fun _ => ?_
  | exact keysB_op _ _ rfl
  | exact keysB_pure _
  | refine keysB_ite _ ?_ ?_
  | refine keysB_bind (keysB_ite _ ?_ ?_) fun _ => ?_))))

section
variable {κ : Type} (S : κ → Prop) (I : PDim → Int)

theorem keysB_normT (key : κ) (x : Nat) (h : S key) : KeysB S (normT graphB key x : Build Int κ Nat) := by
  unfold normT; keys_peel; exact h

theorem keysB_optInpT (b : Bool) (key : κ) (zp : RPrim Int κ) (hz : noInputK zp = true) (h : S key) :
    KeysB S (optInpT graphB b key zp) := by
  cases b
  · exact keysB_op _ _ hz
  · exact keysB_inp h

theorem keysB_kvStepT (R : Rows) (o n : Nat) (cap : Option Nat) (key : κ) (x : Nat) (h : S key) :
    KeysB S (kvStepT graphB I R o n cap key x) := by
  unfold kvStepT
  refine keysB_bind ?_ fun _ => ?_
  · cases cap with
    | none => exact keysB_op _ _ rfl
    | some c =>
      unfold kvGrowT kvGrownT kvOldT
      keys_peel
      exact h
  · unfold kvViewT
    keys_peel

theorem keysB_readCausal (R : Rows) (aux : Nat → κ) (q k w : Nat) :
    KeysB S (readT graphB I R .causal aux q k w) := by
  unfold readT; keys_peel

theorem keysB_denseProjT (lay : LinLayout) (key : LinKey → κ) (x : Nat) (h : ∀ l, S (key l)) :
    KeysB S (denseProjT graphB lay key x : Build Int κ Nat) := by
  unfold denseProjT; keys_peel <;> exact h _

theorem keysB_plainProjT (lay : LinLayout) (key : LinKey → κ) (x : Nat) (h : ∀ l, S (key l)) :
    KeysB S (plainProjT graphB lay key x : Build Int κ Nat) := by
  unfold plainProjT; keys_peel <;> exact h _

theorem keysB_embedT (ids : κ) (key : InKey → κ) (hi : S ids) (h : ∀ k, S (key k)) :
    KeysB S (embedT graphB ids key : Build Int κ Nat) := by
  unfold embedT; keys_peel
  · exact hi
  all_goals exact h _

end

/-! ## Readback keys and tap sites -/

/-- The layer of a readback key: `.linOut p _`, `.mlpOut p`. -/
def rbLayer : AKey → Option Nat
  | .linOut p _ => some p
  | .mlpOut p => some p
  | _ => none

/-- Whether a projection site is split. -/
def projSplit : AneProj → Bool
  | .split _ => true
  | _ => false

/-- A delta layer's tap site of projection `j` (call order: qkv, z, b, a, out). -/
def deltaSite : Nat → Option Nat
  | 0 => some 0
  | 1 => some 1
  | 3 => some 2
  | 2 => some 3
  | 4 => some 4
  | _ => none

/-- An attention layer's tap site of projection `j` (q, k, v, o). -/
def attnSite (j : Nat) : Option Nat := if j < 4 then some j else none

/-- **The tap site of a readback key** in a layer of kind `s` of a family with projection kinds `kd`: a split
site's projection, or the MLP (after the projections). -/
def rbSite (kd : AneKinds) : StageLayout → AKey → Option Nat
  | .delta _, .linOut _ j => if projSplit (kd.delta j) then deltaSite j else none
  | .delta _, .mlpOut _ => some 5
  | .attention _, .linOut _ j => if projSplit (kd.attn j) then attnSite j else none
  | .attention _, .mlpOut _ => some 4
  | _, _ => none

/-- A layer's taps: two per projection site, one for the MLP. -/
def TapShape {γ : Type} : StageLayout → List (List γ) → Prop
  | .delta _, l => ∃ a1 a2 b1 b2 c1 c2 d1 d2 e1 e2 f, l = [[a1, a2], [b1, b2], [c1, c2], [d1, d2], [e1, e2], [f]]
  | .attention _, l => ∃ a1 a2 b1 b2 c1 c2 d1 d2 f, l = [[a1, a2], [b1, b2], [c1, c2], [d1, d2], [f]]

/-! ## Within a layer -/

section
-- (no variables)

/-- Within layer `p` from graph `g₀`: `g` extends `g₀`, the taps `pre` collected so far are nodes of `g`, and every
new input of a readback key is the layer's, at a site of `site` among `pre`, after its taps. -/
def LInv (p : Nat) (site : AKey → Option Nat) (g₀ : List (RNode Int AKey)) (pre : List (List Nat))
    (g : List (RNode Int AKey)) : Prop :=
  (∃ t, g = g₀ ++ t) ∧ (∀ ts ∈ pre, ∀ t ∈ ts, t < g.length) ∧
    ∀ i nd k q, g₀.length ≤ i → g[i]? = some nd → nd.prim = .input k → rbLayer k = some q →
      q = p ∧ ∃ s ts, site k = some s ∧ pre[s]? = some ts ∧ ∀ t ∈ ts, t < i

variable {p : Nat} {site : AKey → Option Nat} {g₀ : List (RNode Int AKey)} {pre : List (List Nat)}

theorem linv_start (p : Nat) (site : AKey → Option Nat) (g₀ : List (RNode Int AKey)) : LInv p site g₀ [] g₀ := by
  refine ⟨⟨[], by simp⟩, fun _ h => (by cases h), ?_⟩
  intro i nd k q hi h _ _
  rw [List.getElem?_eq_none (by omega)] at h
  cases h

theorem linv_keys {α : Type} {b : Build Int AKey α} (hb : KeysB (fun k => rbLayer k = none) b) {g : List (RNode Int AKey)}
    (h : LInv p site g₀ pre g) : Spec b g fun _ g' => LInv p site g₀ pre g' := by
  obtain ⟨⟨t, rfl⟩, hlt, hrb⟩ := h
  obtain ⟨⟨t', ht'⟩, hk⟩ := hb (g₀ ++ t)
  refine ⟨⟨t ++ t', by rw [show (run b (g₀ ++ t)).2 = _ from ht']; simp⟩, fun ts hts x hx => ?_, fun i nd k q hi hg hki hq => ?_⟩
  · have := hlt ts hts x hx
    show x < (run b (g₀ ++ t)).2.length
    rw [ht', List.length_append]; omega
  · by_cases hlt' : i < (g₀ ++ t).length
    · rw [show (run b (g₀ ++ t)).2 = _ from ht', List.getElem?_append_left hlt'] at hg
      exact hrb i nd k q hi hg hki hq
    · rw [hk i nd k (by omega) hg hki] at hq; cases hq

theorem linv_op {g : List (RNode Int AKey)} (h : LInv p site g₀ pre g) (pr : RPrim Int AKey) (ins : List Nat)
    (hp : noInputK pr = true) :
    Spec (graphB.op pr ins) g fun a g' => LInv p site g₀ pre g' ∧ a = g.length ∧ g' = g ++ [⟨pr, ins⟩] :=
  ⟨linv_keys (keysB_op pr ins hp) h, rfl, rfl⟩

theorem linv_taps {pre : List (List Nat)} {g : List (RNode Int AKey)} (h : LInv p site g₀ pre g) (ts : List Nat)
    (hts : ts ∈ pre) : ∀ t ∈ ts, t < g.length := h.2.1 ts hts

theorem linv_add {g : List (RNode Int AKey)} (h : LInv p site g₀ pre g) (ts : List Nat) (hts : ∀ t ∈ ts, t < g.length) :
    LInv p site g₀ (pre ++ [ts]) g := by
  obtain ⟨he, hlt, hrb⟩ := h
  refine ⟨he, fun ts' hm => ?_, fun i nd k q hi hg hki hq => ?_⟩
  · rcases List.mem_append.mp hm with hm | hm
    · exact hlt ts' hm
    · simp at hm; subst hm; exact hts
  · obtain ⟨e, s, ts', hs, hp, hlt'⟩ := hrb i nd k q hi hg hki hq
    exact ⟨e, s, ts', hs, by rw [List.getElem?_append_left (List.getElem?_eq_some_iff.mp hp).1]; exact hp, hlt'⟩

/-- A readback input at a site whose taps are collected. -/
theorem linv_inpRb {g : List (RNode Int AKey)} (h : LInv p site g₀ pre g) (k : AKey) (hk : rbLayer k = some p) (s : Nat)
    (hs : site k = some s) (ts : List Nat) (hp : pre[s]? = some ts) (hts : ∀ t ∈ ts, t < g.length) :
    Spec (graphB.inp k) g fun _ g' => LInv p site g₀ pre g' := by
  obtain ⟨⟨t, rfl⟩, hlt, hrb⟩ := h
  have hl : (run (graphB (δ := Int).inp k) (g₀ ++ t)).2 = g₀ ++ t ++ [⟨.input k, []⟩] := rfl
  refine ⟨⟨t ++ [⟨.input k, []⟩], by rw [hl]; simp⟩, fun ts' hm x hx => ?_, fun i nd k' q hi hg hki hq => ?_⟩
  · have := hlt ts' hm x hx
    rw [hl, List.length_append]; omega
  · rw [hl] at hg
    by_cases hlt' : i < (g₀ ++ t).length
    · rw [List.getElem?_append_left hlt'] at hg
      exact hrb i nd k' q hi hg hki hq
    · have hi' : i = (g₀ ++ t).length := by
        have := (List.getElem?_eq_some_iff.mp hg).1
        simp at this hlt' ⊢; omega
      subst hi'
      rw [List.getElem?_append_right (by omega)] at hg
      simp at hg
      subst hg
      cases hki
      rw [hk] at hq
      cases hq
      exact ⟨rfl, s, ts, hs, hp, hts⟩

end

/-- Peel a layer's plain binds under `LInv`: operations and inputs of no readback key, norms, optional inputs.
Each step matches its builder syntactically (`with_reducible`: a sub-template or a final `pure` is left alone);
the side conditions (`noInputK`, the keys) close by `rfl`. -/
macro "linv_peel" : tactic => `(tactic| ((repeat' (first
  | (with_reducible refine spec_bind (spec_mono (linv_op (by assumption) _ _ ?_) fun _ _ h => ?_)); (· rfl);
      obtain ⟨_, _, _⟩ := h
  | (with_reducible refine spec_bind (spec_mono (linv_keys (keysB_inp ?_) (by assumption)) fun _ _ _ => ?_));
      (· rfl)
  | (with_reducible refine spec_bind (spec_mono (linv_keys (keysB_normT _ _ _ ?_) (by assumption))
      fun _ _ _ => ?_)); (· rfl)
  | (with_reducible refine spec_bind (spec_mono (linv_keys (keysB_optInpT _ _ _ _ ?_ ?_) (by assumption))
      fun _ _ _ => ?_)); (· rfl); (· rfl)))))

/-! ## The projections and the MLP split -/

section
variable (I : PDim → Int) (R : Rows) (p : Nat) {site : AKey → Option Nat}
  {g₀ : List (RNode Int AKey)}

theorem linv_denseProjT {pre : List (List Nat)} (lay : LinLayout) (key : LinKey → AKey)
    (hkey : ∀ l, rbLayer (key l) = none) (x : Nat) {g : List (RNode Int AKey)} (h : LInv p site g₀ pre g) :
    Spec (denseProjT graphB lay key x) g fun y g' => LInv p site g₀ pre g' ∧ y < g'.length := by
  unfold denseProjT
  refine spec_bind (spec_mono (linv_keys (keysB_inp (hkey _)) h) fun _ _ h1 => ?_)
  refine spec_bind (spec_mono (linv_keys (keysB_inp (hkey _)) h1) fun _ _ h2 => ?_)
  refine spec_bind (spec_mono (linv_keys (keysB_inp (hkey _)) h2) fun _ _ h3 => ?_)
  refine spec_bind (spec_mono (linv_op h3 _ _ rfl) fun _ _ h4 => ?_)
  refine spec_bind (spec_mono (linv_op h4.1 _ _ rfl) fun _ _ h5 => ?_)
  exact spec_mono (linv_op h5.1 _ _ rfl) fun _ _ h6 => ⟨h6.1, by rw [h6.2.1, h6.2.2]; simp⟩

theorem linv_plainProjT {pre : List (List Nat)} (lay : LinLayout) (key : LinKey → AKey)
    (hkey : ∀ l, rbLayer (key l) = none) (x : Nat) {g : List (RNode Int AKey)} (h : LInv p site g₀ pre g) :
    Spec (plainProjT graphB lay key x) g fun y g' => LInv p site g₀ pre g' ∧ y < g'.length := by
  unfold plainProjT
  refine spec_bind (spec_mono (linv_keys (keysB_inp (hkey _)) h) fun _ _ h1 => ?_)
  refine spec_bind (spec_mono (linv_keys (keysB_inp (hkey _)) h1) fun _ _ h2 => ?_)
  refine spec_bind (spec_mono (linv_keys (keysB_inp (hkey _)) h2) fun _ _ h3 => ?_)
  exact spec_mono (linv_op h3 _ _ rfl) fun _ _ h4 => ⟨h4.1, by rw [h4.2.1, h4.2.2]; simp⟩

/-- **A projection site** extends the layer's taps by its two, after which its readback (a split's) comes. -/
theorem linv_proj (kd : Nat → AneProj) (j : Nat) (lay : LinLayout) (x : Nat) {pre : List (List Nat)}
    {g : List (RNode Int AKey)} (h : LInv p site g₀ pre g)
    (hsite : projSplit (kd j) = true → site (.linOut p j) = some pre.length) :
    Spec (aneProjAt graphB I R kd p j lay x) g fun r g' => LInv p site g₀ (pre ++ [[r.2.1, r.2.2]]) g' := by
  have hk : ∀ (h : Bool) l, rbLayer (AKey.part p j h l) = none := fun _ _ => rfl
  have hs : ∀ l, rbLayer (AKey.p (stageKey p (.lin j l))) = none := fun _ => rfl
  unfold aneProjAt
  cases e : kd j with
  | dense =>
    simp only [aneProjT]
    refine spec_bind (spec_mono (linv_denseProjT p lay _ hs x h) fun y g' hy => ?_)
    exact spec_pure (linv_add hy.1 _ (by simp [hy.2]))
  | plain =>
    simp only [aneProjT]
    refine spec_bind (spec_mono (linv_plainProjT p lay _ hs x h) fun y g' hy => ?_)
    exact spec_pure (linv_add hy.1 _ (by simp [hy.2]))
  | split nA =>
    simp only [aneProjT, aneSplitProjT]
    have hsp := hsite (by rw [e]; rfl)
    refine spec_bind (spec_mono (linv_keys (keysB_inp (hk _ _)) h) fun _ _ h1 => ?_)
    refine spec_bind (spec_mono (linv_keys (keysB_inp (hk _ _)) h1) fun _ _ h2 => ?_)
    refine spec_bind (spec_mono (linv_keys (keysB_inp (hk _ _)) h2) fun _ _ h3 => ?_)
    refine spec_bind (spec_mono (linv_op h3 _ _ rfl) fun _ _ h4 => ?_)
    refine spec_bind (spec_mono (linv_op h4.1 _ _ rfl) fun flat g5 h5 => ?_)
    refine spec_bind (spec_mono (linv_op h5.1 _ _ rfl) fun x2 g6 h6 => ?_)
    have h6' := linv_add h6.1 [flat, x2] (by
      intro t ht
      simp only [List.mem_cons, List.not_mem_nil, or_false] at ht
      rw [h6.2.2, h5.2.2] at *
      rcases ht with rfl | rfl
      · rw [h5.2.1]; simp
      · rw [h6.2.1]; simp)
    refine spec_bind (spec_mono (linv_denseProjT p lay _ (hk false) x h6') fun _ _ h7 => ?_)
    refine spec_bind (spec_mono (linv_inpRb h7.1 (.linOut p j) rfl pre.length hsp [flat, x2] (by simp)
      (linv_taps h7.1 _ (by simp))) fun _ _ h8 => ?_)
    refine spec_bind (spec_mono (linv_op h8 _ _ rfl) fun _ _ h9 => ?_)
    refine spec_bind (spec_mono (linv_op h9.1 _ _ rfl) fun _ _ h10 => ?_)
    refine spec_bind (spec_mono (linv_op h10.1 _ _ rfl) fun _ _ h11 => ?_)
    exact spec_pure h11.1

/-- **The MLP split** extends the layer's taps by its one, after which its readback comes. -/
theorem linv_mlp (rest : Nat) (mlay : MlpLayout) (x : Nat) {pre : List (List Nat)}
    {g : List (RNode Int AKey)} (h : LInv p site g₀ pre g) (hsite : site (.mlpOut p) = some pre.length) :
    Spec (aneMlpAt graphB I R rest p mlay x) g fun r g' => LInv p site g₀ (pre ++ [[r.2]]) g' := by
  unfold aneMlpAt aneMlpT
  refine spec_bind (spec_mono (linv_op h _ _ rfl) fun h2 g1 hh => ?_)
  have h1 := linv_add hh.1 [h2] (by rw [hh.2.1, hh.2.2]; simp)
  clear hh
  linv_peel
  refine spec_bind (spec_mono (linv_inpRb (by assumption) (.mlpOut p) rfl pre.length hsite [h2] (by simp)
    (linv_taps (by assumption) _ (by simp))) fun _ _ _ => ?_)
  linv_peel
  exact spec_pure (by assumption)

end

end Host.Mlx.SimGraph.Mach
