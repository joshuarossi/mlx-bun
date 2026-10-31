import host.simgraph.family.KeyMap
import host.mlx.FfiEvalRoute
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Mlx.FfiEval
open Inference.Contracts.Mlx
open Host.Mlx.SimGraph (KeyAgree primEval_keyP keyP)

/-! # The graph's values under the route's kernels, with the recorded values of its surface nodes

`evalRR` gives a node its primitive's value on its arguments' values, at the route's kernels. A node reading an
IOSurface has no such value: its bytes are the surface's when MLX ran it (`host.mlx.FfiAneEval`). `evalZ` is
`evalRR` falling back to a recorded value `Z` where its primitive has none. With nothing recorded it is `evalRR`
(`evalZ_empty`), and it extends `evalRR` wherever that has a value (`evalRR_evalZ`).

`matches_evalZ`: **an expected graph carried by the decode-resolved graph holds its values under `evalZ`**, given
its input carriers' values, however those were produced. The proved decode templates transport by this alone:
their nodes are carried by `Matches` on the decode resolution, whose nodes the route resolution keeps, and only the
values of their inputs (the caches a prefill left) need the route's kernels. -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} [DecidableEq κ]
  (env : Env κ) (kind : Nat → Option Compiled) (Z : Nat → Option Value)

/-- `evalRR`, falling back to the recorded value where the primitive has none. -/
noncomputable def evalZ (g : Nat → Option (RNode Int κ)) (i : Nat) : Option Value :=
  (match g i with
    | none => none
    | some nd =>
      match cgLeaves g i with
      | some leaves => do
        let xs ← leaves.mapM fun j => if _h : j < i then evalZ g j else none
        computeGP P (κ := κ) xs
      | none =>
        match closureLeaves kind g i with
        | some (c, leaves) => do
          let xs ← leaves.mapM fun j => if _h : j < i then evalZ g j else none
          compiledValue P c xs
        | none => do
          let xs ← nd.ins.mapM fun j => if _h : j < i then evalZ g j else none
          primEvalR P K env nd.prim xs).orElse fun _ => Z i
termination_by i
decreasing_by all_goals assumption

theorem evalZ_eq (g : Nat → Option (RNode Int κ)) (i : Nat) : evalZ P K env kind Z g i =
    (match g i with
    | none => none
    | some nd =>
      match cgLeaves g i with
      | some leaves => (leaves.mapM fun j => if _h : j < i then evalZ P K env kind Z g j else none).bind
          (computeGP P (κ := κ))
      | none =>
        match closureLeaves kind g i with
        | some (c, leaves) => (leaves.mapM fun j => if _h : j < i then evalZ P K env kind Z g j else none).bind
            (compiledValue P c)
        | none => (nd.ins.mapM fun j => if _h : j < i then evalZ P K env kind Z g j else none).bind
            (primEvalR P K env nd.prim)).orElse fun _ => Z i := by
  rw [evalZ]; rfl

/-- **With nothing recorded, the values are `evalRR`'s.** -/
theorem evalZ_empty (g : Nat → Option (RNode Int κ)) (i : Nat) :
    evalZ P K env kind (fun _ => none) g i = evalRR P K env kind g i := by
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  have hargs : ∀ l : List Nat,
      (l.mapM fun j => if _h : j < i then evalZ P K env kind (fun _ => none) g j else none) =
        l.mapM fun j => if _h : j < i then evalRR P K env kind g j else none := fun l =>
    mapM_congr' l _ _ fun j _ => by
      by_cases hj : j < i
      · simp only [hj, ↓reduceDIte, ih j hj]
      · simp only [hj, ↓reduceDIte]
  have hO : ∀ x : Option Value, (x.orElse fun _ => none) = x := fun x => by cases x <;> rfl
  rw [evalZ_eq, hO, evalRR_eq]
  cases g i with
  | none => rfl
  | some nd =>
    dsimp only
    cases cgLeaves g i with
    | some leaves => dsimp only; rw [hargs]
    | none =>
      dsimp only
      cases closureLeaves kind g i with
      | some x =>
        obtain ⟨c, leaves⟩ := x
        dsimp only
        rw [hargs]
      | none =>
        dsimp only
        rw [hargs]

/-- **`evalZ` extends `evalRR`**: a node with a value under the route's kernels has that value. -/
theorem evalRR_evalZ (g : Nat → Option (RNode Int κ)) :
    ∀ i v, evalRR P K env kind g i = some v → evalZ P K env kind Z g i = some v := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro v hv
  rw [evalRR_eq] at hv
  rw [evalZ_eq]
  have hargs : ∀ (l : List Nat) (ys : List Value),
      (l.mapM fun j => if _h : j < i then evalRR P K env kind g j else none) = some ys →
      (l.mapM fun j => if _h : j < i then evalZ P K env kind Z g j else none) = some ys := by
    intro l ys hl
    refine mapM_some_mono l _ _ (fun j _ y hy => ?_) hl
    by_cases hj : j < i
    · simp only [hj, ↓reduceDIte] at hy ⊢; exact ih j hj y hy
    · simp only [hj, ↓reduceDIte] at hy; cases hy
  cases hg : g i with
  | none => rw [hg] at hv; cases hv
  | some nd =>
    rw [hg] at hv
    dsimp only at hv ⊢
    cases hc : cgLeaves g i with
    | some leaves =>
      rw [hc] at hv
      dsimp only at hv ⊢
      obtain ⟨xs, hxs, hcl⟩ := Option.bind_eq_some_iff.mp hv
      rw [hargs leaves xs hxs, Option.bind_some, hcl]
      rfl
    | none =>
      rw [hc] at hv
      dsimp only at hv ⊢
      cases hk : closureLeaves kind g i with
      | some x =>
        obtain ⟨c, leaves⟩ := x
        rw [hk] at hv
        dsimp only at hv ⊢
        obtain ⟨xs, hxs, hcl⟩ := Option.bind_eq_some_iff.mp hv
        rw [hargs leaves xs hxs, Option.bind_some, hcl]
        rfl
      | none =>
        rw [hk] at hv
        dsimp only at hv ⊢
        obtain ⟨xs, hxs, hp⟩ := Option.bind_eq_some_iff.mp hv
        rw [hargs nd.ins xs hxs, Option.bind_some, hp]
        rfl

end

/-! ## The route resolution keeps a carried graph's nodes -/

section
variable {κ : Type} [DecidableEq κ]

theorem cgAux_root (r : RNode Int κ) (b : Nat → Option (RNode Int κ)) {l : List Nat} (h : cgAux r b = some l) :
    strip r.prim ≠ .unsupported := by
  simp only [cgAux, Option.bind_eq_bind, Option.bind_eq_some_iff] at h
  obtain ⟨cls, hcls, -⟩ := h
  cases hp : r.prim with
  | replayed c q =>
    rw [hp] at hcls
    cases q <;> simp [replayedExp?] at hcls
    simp
  | _ => rw [hp] at hcls; simp [replayedExp?] at hcls

/-- The compute_g pattern reads only nodes a keeping resolution keeps. -/
theorem cgAux_mono (r : RNode Int κ) (b b' : Nat → Option (RNode Int κ))
    (hb : ∀ j x, b j = some x → strip x.prim ≠ .unsupported → b' j = some x) (leaves : List Nat)
    (h : cgAux r b = some leaves) : cgAux r b' = some leaves := by
  simp only [cgAux, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.ite_none_right_eq_some, Option.bind_none,
    Prod.exists, Option.pure_def, Option.some.injEq] at h
  obtain ⟨cls, hcls, m, hm, mn, hmn, p1, ng, sp, hpr, nn, hnn, p2, e1, he1, en, hen, p3, c, hc, cn, hcn, p4,
    x0, hx0, sn, hsn, p5, sm, z, hpr2, smn, hsmn, p6, x1, x2, hpr3, zn, hzn, p7, hl⟩ := h
  subst hl p7
  have k1 := hb _ _ hmn (by rw [p1]; simp)
  have k2 := hb _ _ hnn (by rw [p2]; simp)
  have k3 := hb _ _ hen (by rw [p3]; simp)
  have k4 := hb _ _ hcn (by rw [p4]; simp)
  have k5 := hb _ _ hsn (by rw [p5]; simp)
  have k6 := hb _ _ hsmn (by rw [p6]; simp)
  have k7 := hb _ _ hzn (by simp)
  simp only [cgAux, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.ite_none_right_eq_some, Option.bind_none,
    Option.pure_def, Option.some.injEq, hcls, hm, hpr, he1, hc, hx0, hpr2, hpr3, k1, k2, k3, k4, k5, k6, k7, p1, p2, p3,
    p4, p5, p6, exists_eq_left', true_and, and_true, Option.bind_some, ↓reduceIte, Prod.exists]

theorem cgLeaves_mono {G GR : Nat → Option (RNode Int κ)}
    (hnode : ∀ j nd, G j = some nd → strip nd.prim ≠ .unsupported → GR j = some nd) {i : Nat} {l : List Nat}
    (h : cgLeaves G i = some l) : cgLeaves GR i = some l := by
  unfold cgLeaves at h ⊢
  obtain ⟨r, hr, ha⟩ := Option.bind_eq_some_iff.mp h
  rw [hnode i r hr (cgAux_root r _ ha), Option.bind_some]
  refine cgAux_mono r _ _ (fun j x hx hn => ?_) l ha
  by_cases hj : j < i
  · rw [ite_eq_left hj] at hx ⊢
    exact hnode j x hx hn
  · rw [ite_eq_right hj] at hx; cases hx

end

/-! ## Primitives do not read the step's inputs -/

section
variable {κ : Type} [DecidableEq κ]

theorem keyP_id : ∀ p : RPrim Int κ, keyP (id : κ → κ) p = p := by
  intro p
  induction p <;> simp_all [keyP]

theorem keyAgree_self {env env₀ : Env κ} {p : RPrim Int κ} (hs : strip p = p) (hi : isInput p = false) :
    KeyAgree (id : κ → κ) env env₀ p := by
  cases p with
  | input k => simp [isInput] at hi
  | replayed c q => exact absurd hs (by rw [eq_comm]; exact (strip_not_replayed _ c q).symm ∘ Eq.symm ∘ Eq.symm)
  | _ => trivial

end

/-! ## A carried graph's values -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} [DecidableEq κ]
  (env envE : Env κ) (kind : Nat → Option Compiled) (Z : Nat → Option Value)

/-- **An expected graph carried by `G` holds its values under `evalZ` on any graph keeping `G`'s nodes**, its input
carriers' values given. Each carried node is computed from its arguments, so `Z` is never consulted at one. -/
theorem matches_evalZ {G GR : Nat → Option (RNode Int κ)} {E : List (RNode Int κ)} {cert : List Nat}
    (hw : env.weights = envE.weights)
    (hnode : ∀ j nd, G j = some nd → strip nd.prim ≠ .unsupported → GR j = some nd)
    (hm : Matches G E cert = true)
    (hin : ∀ k e key v, E[k]? = some e → e.prim = .input key → envE.inputs key = some v →
      evalZ P K env kind Z GR (certAt cert k) = some v) :
    ∀ k, k < E.length → ∀ v, evalR P.toMlxContract K.toKernelContract envE (listGraph E) k = some v →
      evalZ P K env kind Z GR (certAt cert k) = some v := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
  intro hk v hv
  have hek : E[k]? = some E[k] := List.getElem?_eq_getElem hk
  generalize E[k] = e at hek
  have hok : nodeOk G cert k e = true := by
    have := List.all_eq_true.mp hm k (List.mem_range.mpr hk)
    simpa [hek] using this
  simp only [nodeOk, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at hok
  obtain ⟨⟨hlt, hcl⟩, hrest⟩ := hok
  have hE : listGraph E k = some e := hek
  -- the arguments' values carry
  have hargs : ∀ xs, (e.ins.mapM fun j => if _h : j < k then
        evalR P.toMlxContract K.toKernelContract envE (listGraph E) j else none) = some xs →
      ((e.ins.map (certAt cert)).mapM fun j => if _h : j < certAt cert k then
        evalZ P K env kind Z GR j else none) = some xs := by
    intro xs hxs
    rw [List.mapM_map]
    refine mapM_some_mono e.ins _ _ (fun j hj y hy => ?_) hxs
    simp only [dite_eq_left (hlt j hj)] at hy
    simp only [Function.comp, dite_eq_left (hcl j hj)]
    exact ih j (hlt j hj) (by have := hlt j hj; omega) y hy
  by_cases hi : isInput e.prim = true
  · cases hp : e.prim with
    | input key =>
      rw [if_pos hi] at hrest
      have hnil : e.ins = [] := by simpa using hrest
      rw [evalR_eq, hE, cgLeaves_none _ _ e hE (by rw [hp]; rfl)] at hv
      simp [hnil, hp, primEval] at hv
      exact hin k e key v hek hp hv
    | _ => rw [hp] at hi; simp [isInput] at hi
  · have hi' : isInput e.prim = false := by simpa using hi
    rw [if_neg hi] at hrest
    by_cases hc : e.prim = .computeG
    · rw [if_pos hc] at hrest
      simp only [decide_eq_true_eq] at hrest
      have hrestR := cgLeaves_mono hnode hrest
      rw [evalR_eq, hE, cgLeaves_none _ _ e hE (by rw [hc]; rfl)] at hv
      dsimp only at hv
      obtain ⟨xs, hxs, hp⟩ := Option.bind_eq_some_iff.mp hv
      rw [hc] at hp
      obtain ⟨r, hr, _⟩ := Option.bind_eq_some_iff.mp hrestR
      rw [evalZ_eq, hr, hrestR]
      dsimp only
      rw [hargs xs hxs, Option.bind_some]
      have hg : computeGP P (κ := κ) xs = some v := by
        simp only [primEval] at hp
        simp [computeGP, hp, Option.orElse]
      rw [hg]
      rfl
    · rw [if_neg hc] at hrest
      simp only [Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq] at hrest
      obtain ⟨hx, hG⟩ := hrest
      match hr : G (certAt cert k), hG with
      | none, hG => simp at hG
      | some r, hG =>
        simp only [decide_eq_true_eq] at hG
        obtain ⟨hs, hor, hins⟩ := hG
        have hes : strip e.prim = e.prim := by rw [← hs, strip_strip]
        have hrx : isExp r.prim = false := by
          simp only [isExp, decide_eq_false_iff_not] at hx ⊢
          rw [hs]; rwa [hes] at hx
        rw [evalR_eq, hE, cgLeaves_none _ _ e hE (not_exp hx)] at hv
        dsimp only at hv
        obtain ⟨xs, hxs, hp⟩ := Option.bind_eq_some_iff.mp hv
        have hne : strip r.prim ≠ .unsupported := by
          rw [hs]
          intro hu
          rw [hu] at hp
          cases xs <;> simp [primEval] at hp
        have hrR := hnode _ r hr hne
        have hcgR : cgLeaves GR (certAt cert k) = none := cgLeaves_none _ _ _ hrR (not_exp hrx)
        have hclR : closureLeaves kind GR (certAt cert k) = none := by
          cases hk' : closureLeaves kind GR (certAt cert k) with
          | none => rfl
          | some x =>
            exfalso
            have ha : closureAux kind r (fun j => if j < certAt cert k then GR j else none) = some x := by
              unfold closureLeaves at hk'
              rw [hrR] at hk'
              exact hk'
            obtain ⟨c, q, hrq, hq⟩ := closureAux_root kind r _ ha
            rw [hrq] at hs hor
            simp only [strip] at hs
            rcases hor with h | h
            · rw [← h] at hes
              exact strip_not_replayed _ c q hes
            · rw [← hs, elementwise_strip, hq] at h
              cases h
        have hpe : primEval P.toMlxContract K.toKernelContract env r.prim xs = some v := by
          rw [primEval_strip P.toMlxContract K.toKernelContract env r.prim e.prim hs hor]
          have hk2 := primEval_keyP (id : κ → κ) P K.toKernelContract env envE hw e.prim xs (keyAgree_self hes hi')
          rw [keyP_id] at hk2
          rw [hk2]
          exact hp
        have hpR : primEvalR P K env r.prim xs = some v :=
          primEvalR_of P K env (by simp [primEvalP, hpe, Option.orElse])
        rw [evalZ_eq, hrR]
        dsimp only
        rw [hcgR]
        dsimp only
        rw [hclR]
        dsimp only
        rw [hins, hargs xs hxs, Option.bind_some, hpR]
        rfl

end

end Host.Mlx.FfiEval
