import host.simgraph.family.KernelSlot
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # Carrying a family's graph, with the primitives agreeing at the carriers

`matches_evalG` asks the FFI graph's primitives to agree at every node, and `KernelsPlain` asks that of the whole target
graph, which the relation at a forward's end doesn't speak to. The argument reads them only at the carriers:
`matches_evalGOn`, `kernelsPlainOn_values`. -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} [DecidableEq κ]
  (env : Env κ) (ks : KernelSem) (kind : Nat → Option Compiled)

theorem matches_evalGOn (ev : (Nat → Option (RNode Int κ)) → Nat → Option Value)
    (pe : RPrim Int κ → List Value → Option Value) (hev : EvalShape P kind ev pe)
    (G : Nat → Option (RNode Int κ)) (E : List (RNode Int κ)) (cert : List Nat) (hm : MatchesED kind G E cert = true)
    (hin : ∀ k e key v, E[k]? = some e → e.prim = .input key → env.inputs key = some v →
      ev G (certAt cert k) = some v)
    (hpa : ∀ k, k < E.length → ∀ nd (q : RPrim Int κ) xs v, G (certAt cert k) = some nd → strip nd.prim = q →
      (nd.prim = q ∨ elementwise q = false) → q ≠ .computeG → closureOf? q = none → primEvalE P K env ks q xs = some v →
      pe nd.prim xs = some v) :
    ∀ k, k < E.length → ∀ v, evalE P K env ks (listGraph E) k = some v → ev G (certAt cert k) = some v := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
  intro hk v hv
  have hek : E[k]? = some E[k] := List.getElem?_eq_getElem hk
  generalize E[k] = e at hek
  have hok : nodeOkED kind G cert k e = true := by
    have := List.all_eq_true.mp hm k (List.mem_range.mpr hk)
    simpa [hek] using this
  simp only [nodeOkED, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at hok
  obtain ⟨⟨hlt, hcl⟩, hrest⟩ := hok
  have hE : listGraph E k = some e := hek
  rw [evalE_eq, hE] at hv
  dsimp only at hv
  obtain ⟨xs, hxs, hp⟩ := Option.bind_eq_some_iff.mp hv
  -- the carriers' arguments hold the arguments' values
  have hargs : ∀ (l : List Nat) (ys : List Value), (∀ j ∈ l, j < k ∧ certAt cert j < certAt cert k) →
      (l.mapM fun j => if _h : j < k then evalE P K env ks (listGraph E) j else none) = some ys →
      ((l.map (certAt cert)).mapM fun j => if _h : j < certAt cert k then ev G j else none) = some ys := by
    intro l
    induction l with
    | nil => intro ys _ h; simpa using h
    | cons a l ihl =>
      intro ys hl h
      rw [List.mapM_cons] at h
      obtain ⟨y, hy, h⟩ := Option.bind_eq_some_iff.mp h
      obtain ⟨ys', hys', h⟩ := Option.bind_eq_some_iff.mp h
      simp only [Option.pure_def, Option.some.injEq] at h
      subst h
      obtain ⟨hak, hac⟩ := hl a (List.mem_cons_self ..)
      rw [dite_eq_left hak] at hy
      rw [List.map_cons, List.mapM_cons, dite_eq_left hac, ih a hak (by omega) y hy,
        ihl ys' (fun j hj => hl j (List.mem_cons_of_mem _ hj)) hys']
      rfl
  have hxs' := hargs e.ins xs (fun j hj => ⟨hlt j hj, hcl j hj⟩) hxs
  by_cases hi : isInputD e.prim = true
  · rw [ite_eq_left hi] at hrest
    cases hpe : e.prim with
    | input key =>
      have hnil : e.ins = [] := by simpa using hrest
      rw [hnil] at hxs
      simp only [List.mapM_nil, Option.pure_def, Option.some.injEq] at hxs
      subst hxs
      have : primEvalE P K env ks (.input key) [] = env.inputs key := by
        simp only [primEvalE, closureOf?, primEvalP, primEval]
        cases env.inputs key <;> rfl
      rw [hpe, this] at hp
      exact hin k e key v hek hpe hp
    | _ => rw [hpe] at hi; simp [isInputD] at hi
  · rw [ite_eq_right hi] at hrest
    by_cases hc : e.prim = .computeG
    · rw [ite_eq_left hc] at hrest
      simp only [decide_eq_true_eq] at hrest
      obtain ⟨r, hr, _⟩ := Option.bind_eq_some_iff.mp hrest
      rw [hev, hr, hrest]
      dsimp only
      rw [hxs']
      rw [hc] at hp
      exact hp
    · rw [ite_eq_right hc] at hrest
      cases hk' : closureOf? e.prim with
      | some c =>
        simp only [closureCheck, hk', Option.map_some, Option.getD_some, decide_eq_true_eq] at hrest
        rw [closureLeavesD_int] at hrest
        obtain ⟨r, hr, _⟩ := Option.bind_eq_some_iff.mp hrest
        rw [hev, hr, closure_not_cg kind G _ hrest]
        dsimp only
        rw [hrest]
        dsimp only
        rw [hxs']
        have : primEvalE P K env ks e.prim xs = compiledValue P c xs := by
          unfold primEvalE
          split
          · rename_i hpk; rw [hpk] at hk'; cases hk'
          · contradiction
          · rw [hk']
        rw [this] at hp
        exact hp
      | none =>
        simp only [closureCheck, hk', Option.map_none, Option.getD_none, plainCheck, Bool.and_eq_true,
          Bool.not_eq_true'] at hrest
        obtain ⟨hx, hg⟩ := hrest
        match hr : G (certAt cert k), hg with
        | none, hg => simp at hg
        | some r, hg =>
          simp only [decide_eq_true_eq] at hg
          obtain ⟨hs, hor, hins⟩ := hg
          have hrx : replayedExp? r.prim = none := by
            have h1 : strip e.prim = e.prim := by rw [← hs, strip_strip]
            apply not_exp
            simp only [isExpD, decide_eq_false_iff_not] at hx
            simp only [isExp, decide_eq_false_iff_not]
            rw [hs]; rwa [h1] at hx
          have hcg : cgLeaves G (certAt cert k) = none := cgLeaves_none G _ r hr hrx
          have hcz : closureLeaves kind G (certAt cert k) = none := by
            unfold closureLeaves
            rw [hr, Option.bind_some]
            unfold closureAux
            split
            · rename_i cls p hpr
              have hsp : strip p = e.prim := by rw [← hs, hpr]; rfl
              have hne : elementwise e.prim = false := by
                rcases hor with hor | hor
                · rw [hpr] at hor
                  exact absurd (hsp.trans hor.symm) (strip_not_replayed p cls p)
                · exact hor
              have hep : elementwise p = false := by rw [← elementwise_strip, hsp, hne]
              simp [hep]
            · rfl
          rw [hev, hr, hcg]
          dsimp only
          rw [hcz]
          dsimp only
          rw [hins, hxs', Option.bind_some]
          exact hpa k hk r e.prim xs v hr hs hor hc hk' hp

end

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} [DecidableEq κ] (env : Env κ)

/-- **The carriers hold the family's values**, the kernels plain at the carriers. -/
theorem kernelsPlainOn_values (kind : Nat → Option Compiled) (G : Nat → Option (RNode Int κ))
    (E : List (RNode Int κ)) (cert : List Nat) (hm : MatchesED kind G E cert = true)
    (hin : InputsHeldR P K env kind G E cert)
    (hG : ∀ k, k < E.length → ∀ nd name c out, G (certAt cert k) = some nd → strip nd.prim = .kernel name c out →
      nd.prim = .kernel name c out)
    (i : Nat) (v : Value) (hv : EvE P K.toKernelContract env (ksR P K env) E i v) :
    evalRR P K env kind G (certAt cert i) = some v :=
  matches_evalGOn P K.toKernelContract env (ksR P K env) kind (evalRR P K env kind) (primEvalR P K env)
    (evalRR_eq P K env kind) G E cert hm hin (by
      intro k hk nd q xs w hj hs hor hc hcl hp
      unfold primEvalE at hp
      split at hp
      · rw [hG k hk nd _ _ _ hj hs]
        exact hp
      · contradiction
      · rw [hcl] at hp
        exact primEvalR_of P K env (by rw [primEvalP_strip P K.toKernelContract env nd.prim _ hs hor]; exact hp)) i hv.1 v hv.2

end

end Host.Mlx.SimGraph
