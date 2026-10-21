import host.simgraph.Match
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval
open Inference.Contracts.Mlx

/-! # Graphs carried under a node renaming

`Embeds σ cl G G'`: every node `i` of `G` is at `σ i` in `G'`, with the same
resolved primitive (closure objects of replay tags renamed by `cl`) over the
images of its arguments, and `σ` keeps every node above everything below
it. A later decode iteration's graph carries the template iteration's graph
this way: `σ` sends the template's node ids to the iteration's, the
identity on nodes created before the loop.

* `evalR_embed`: a node of `G` with a value has the same value at its image.
* `matches_embed`: a certificate for `G` renamed by `σ` is one for `G'`.
* `inputsHeld_embed`, `inputCarriers_embed`: the input side. -/

section
variable {δ κ : Type}

/-- Rename the closure objects of replay tags. -/
def renameCls (cl : Nat → Nat) : RPrim δ κ → RPrim δ κ
  | .replayed c p => .replayed (cl c) (renameCls cl p)
  | p => p

def renameN (σ cl : Nat → Nat) (r : RNode δ κ) : RNode δ κ := ⟨renameCls cl r.prim, r.ins.map σ⟩

theorem strip_rename (cl : Nat → Nat) (p : RPrim δ κ) : strip (renameCls cl p) = strip p := by
  induction p <;> simp_all [renameCls]

theorem elementwise_rename (cl : Nat → Nat) (p : RPrim δ κ) : elementwise (renameCls cl p) = elementwise p := by
  induction p <;> simp_all [renameCls, elementwise]

theorem replayedExp_rename (cl : Nat → Nat) (p : RPrim δ κ) :
    replayedExp? (renameCls cl p) = (replayedExp? p).map cl := by
  cases p with
  | replayed c q =>
    cases q <;> simp [renameCls, replayedExp?]
  | _ => rfl

theorem rename_replayed (cl : Nat → Nat) {p q : RPrim δ κ} {c : Nat} (h : p = .replayed c q)
    (hq : renameCls cl q = q) : renameCls cl p = .replayed (cl c) q := by
  subst h; simp [renameCls, hq]

theorem one?_map (σ : Nat → Nat) (l : List Nat) : one? (l.map σ) = (one? l).map σ := by
  match l with
  | [] => rfl
  | [_] => rfl
  | _ :: _ :: _ => rfl

theorem two?_map (σ : Nat → Nat) (l : List Nat) : two? (l.map σ) = (two? l).map fun p => (σ p.1, σ p.2) := by
  match l with
  | [] => rfl
  | [_] => rfl
  | [_, _] => rfl
  | _ :: _ :: _ :: _ => rfl

end

/-- `G'` carries `G` under node map `σ`, with replay closures renamed by `cl`. -/
structure Embeds {κ : Type} (σ cl : Nat → Nat) (G G' : Nat → Option (RNode Int κ)) : Prop where
  node : ∀ i r, G i = some r → G' (σ i) = some (renameN σ cl r)
  order : ∀ i j, (G i).isSome → j < i → σ j < σ i

section
variable {κ : Type} [DecidableEq κ] {σ cl : Nat → Nat}

macro "peel_some " h:ident " => " x:ident e:ident : tactic =>
  `(tactic| obtain ⟨$x, $e, $h⟩ := Option.bind_eq_some_iff.mp $h)

/-- compute_g's replayed pattern survives the renaming. -/
theorem cgAux_embed (r : RNode Int κ) (b b' : Nat → Option (RNode Int κ))
    (hb : ∀ j x, b j = some x → b' (σ j) = some (renameN σ cl x)) (leaves : List Nat)
    (h : cgAux r b = some leaves) : cgAux (renameN σ cl r) b' = some (leaves.map σ) := by
  simp only [cgAux, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.ite_none_right_eq_some, Option.bind_none,
    Prod.exists, Option.pure_def, Option.some.injEq] at h
  obtain ⟨cls, hcls, m, hm, mn, hmn, p1, ng, sp, hpr, nn, hnn, p2, e1, he1, en, hen, p3, c, hc, cn, hcn, p4,
    x0, hx0, sn, hsn, p5, sm, z, hpr2, smn, hsmn, p6, x1, x2, hpr3, zn, hzn, p7, hl⟩ := h
  subst hl p7
  simp only [cgAux, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.ite_none_right_eq_some, Option.bind_none,
    Option.pure_def, Option.some.injEq, renameN, replayedExp_rename, hcls, Option.map_some, one?_map,
    two?_map, hm, hpr, he1, hc, hx0, hpr2, hpr3, hb _ _ hmn, hb _ _ hnn, hb _ _ hen, hb _ _ hcn, hb _ _ hsn,
    hb _ _ hsmn, hb _ _ hzn, p1, p2, p3, p4, p5, p6, renameCls, exists_eq_left', List.map_cons, List.map_nil, true_and,
    and_true]

theorem cgLeaves_embed (G G' : Nat → Option (RNode Int κ)) (h : Embeds σ cl G G') (i : Nat) (leaves : List Nat)
    (hc : cgLeaves G i = some leaves) : cgLeaves G' (σ i) = some (leaves.map σ) := by
  unfold cgLeaves at hc ⊢
  peel_some hc => r hr
  rw [h.node i r hr, Option.bind_some]
  refine cgAux_embed r _ _ (fun j x hx => ?_) leaves hc
  by_cases hj : j < i
  · rw [ite_eq_left hj] at hx
    rw [ite_eq_left (h.order i j (by simp [hr]) hj)]
    exact h.node j x hx
  · rw [ite_eq_right hj] at hx; cases hx

end

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) {κ : Type} [DecidableEq κ] (env : Env κ)
variable {σ cl : Nat → Nat}

omit [DecidableEq κ] in
theorem primEval_rename (cl : Nat → Nat) (p : RPrim Int κ) : primEval M K env (renameCls cl p) = primEval M K env p := by
  induction p with
  | replayed c p ih =>
    funext xs
    show (if elementwise (renameCls cl p) then none else primEval M K env (renameCls cl p) xs) =
      (if elementwise p then none else primEval M K env p xs)
    rw [elementwise_rename, ih]
  | _ => rfl

omit [DecidableEq κ] in
theorem replayedExp_none {p : RPrim Int κ} {c : Nat} (h : replayedExp? p = some c) (xs : List Value) :
    primEval M K env p xs = none := by
  match p, h with
  | .replayed c (.unary op), h =>
    show (if elementwise (RPrim.unary (δ := Int) (κ := κ) op) then none else _) = none
    rfl

/-- **Values transport along an embedding.** -/
theorem evalR_embed (G G' : Nat → Option (RNode Int κ)) (h : Embeds σ cl G G') :
    ∀ i v, evalR M K env G i = some v → evalR M K env G' (σ i) = some v := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro v hv
  rw [evalR_eq] at hv
  cases hg : G i with
  | none => rw [hg] at hv; cases hv
  | some r =>
    rw [hg] at hv
    dsimp only at hv
    have hpres : (G i).isSome := by simp [hg]
    -- arguments of smaller id with values keep them at their images
    have hargs : ∀ (l : List Nat) (xs : List Value),
        (l.mapM fun j => if _h : j < i then evalR M K env G j else none) = some xs →
        ((l.map σ).mapM fun j => if _h : j < σ i then evalR M K env G' j else none) = some xs := by
      intro l
      induction l with
      | nil => intro xs hx; simpa using hx
      | cons a l ihl =>
        intro xs hx
        rw [List.mapM_cons] at hx
        peel_some hx => x ha
        peel_some hx => ys hys
        have hlt : a < i := by
          by_cases hai : a < i
          · exact hai
          · rw [dite_eq_right hai] at ha; cases ha
        rw [dite_eq_left hlt] at ha
        rw [List.map_cons, List.mapM_cons, dite_eq_left (h.order i a hpres hlt), ih a hlt x ha, ihl ys hys]
        simpa using hx
    cases hc : cgLeaves G i with
    | some leaves =>
      rw [hc] at hv
      dsimp only at hv
      peel_some hv => xs hxs
      rw [evalR_eq, h.node i r hg, cgLeaves_embed G G' h i leaves hc]
      dsimp only
      rw [hargs leaves xs hxs]
      exact hv
    | none =>
      rw [hc] at hv
      dsimp only at hv
      peel_some hv => xs hxs
      have hre : replayedExp? r.prim = none := by
        cases hx : replayedExp? r.prim with
        | none => rfl
        | some c => rw [replayedExp_none M K env hx] at hv; cases hv
      have hc' : cgLeaves G' (σ i) = none :=
        cgLeaves_none _ _ (renameN σ cl r) (h.node i r hg) (by simp [renameN, replayedExp_rename, hre])
      rw [evalR_eq, h.node i r hg, hc']
      dsimp only
      rw [show (renameN σ cl r).ins = r.ins.map σ from rfl, hargs r.ins xs hxs]
      show (some xs).bind (primEval M K env (renameCls cl r.prim)) = some v
      rw [primEval_rename]
      exact hv

end

section
variable {κ : Type} [DecidableEq κ] {σ cl : Nat → Nat}

theorem certAt_map (σ : Nat → Nat) (cert : List Nat) (k : Nat) (hk : k < cert.length) :
    certAt (cert.map σ) k = σ (certAt cert k) := by
  simp [certAt, List.getD_eq_getElem?_getD, List.getElem?_map, List.getElem?_eq_getElem hk]

omit [DecidableEq κ] in
theorem isInput_rename (cl : Nat → Nat) (p : RPrim Int κ) : isInput (renameCls cl p) = isInput p := by
  cases p <;> rfl

/-- **Certificates transport along an embedding.** -/
theorem matches_embed (G G' : Nat → Option (RNode Int κ)) (h : Embeds σ cl G G') (E : List (RNode Int κ))
    (cert : List Nat) (hlen : E.length ≤ cert.length) (hm : Matches G E cert = true) :
    Matches G' E (cert.map σ) = true := by
  unfold Matches at hm ⊢
  refine List.all_eq_true.mpr fun k hk => ?_
  have hkE : k < E.length := List.mem_range.mp hk
  have hok := List.all_eq_true.mp hm k hk
  rw [List.getElem?_eq_getElem hkE] at hok ⊢
  dsimp only at hok ⊢
  generalize E[k] = e at hok ⊢
  simp only [nodeOk, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at hok ⊢
  obtain ⟨⟨hlt, hcl⟩, hrest⟩ := hok
  have hcm : ∀ j ∈ e.ins, certAt (cert.map σ) j = σ (certAt cert j) := fun j hj =>
    certAt_map σ cert j (by have := hlt j hj; omega)
  have hck : certAt (cert.map σ) k = σ (certAt cert k) := certAt_map σ cert k (by omega)
  have hins : e.ins.map (certAt (cert.map σ)) = (e.ins.map (certAt cert)).map σ := by
    rw [List.map_map]
    exact List.map_congr_left fun j hj => hcm j hj
  -- the carrier of `k` is a node of `G` unless `e` is an input
  have present : isInput e.prim = false → (G (certAt cert k)).isSome := by
    intro hi
    rw [hi] at hrest
    simp only [Bool.false_eq_true, ↓reduceIte] at hrest
    by_cases hc : e.prim = .computeG
    · rw [ite_eq_left hc] at hrest
      simp only [decide_eq_true_eq] at hrest
      unfold cgLeaves at hrest
      cases hg : G (certAt cert k) with
      | none => rw [hg] at hrest; cases hrest
      | some _ => rfl
    · rw [ite_eq_right hc] at hrest
      simp only [Bool.and_eq_true] at hrest
      cases hg : G (certAt cert k) with
      | none => rw [hg] at hrest; simp at hrest
      | some _ => rfl
  by_cases hi : isInput e.prim = true
  · refine ⟨⟨hlt, ?_⟩, by rw [ite_eq_left hi] at hrest ⊢; exact hrest⟩
    intro j hj
    rw [ite_eq_left hi] at hrest
    have : e.ins = [] := by simpa using hrest
    rw [this] at hj; cases hj
  · have hi' : isInput e.prim = false := by simpa using hi
    have hp := present hi'
    refine ⟨⟨hlt, fun j hj => ?_⟩, ?_⟩
    · rw [hcm j hj, hck]
      exact h.order _ _ hp (hcl j hj)
    · rw [ite_eq_right hi] at hrest ⊢
      by_cases hc : e.prim = .computeG
      · rw [ite_eq_left hc] at hrest ⊢
        simp only [decide_eq_true_eq] at hrest ⊢
        rw [hck, cgLeaves_embed G G' h _ _ hrest, hins]
      · rw [ite_eq_right hc] at hrest ⊢
        simp only [Bool.and_eq_true] at hrest ⊢
        obtain ⟨hx, hg⟩ := hrest
        refine ⟨hx, ?_⟩
        rw [hck]
        cases hr : G (certAt cert k) with
        | none => rw [hr] at hg; cases hg
        | some r =>
          rw [hr] at hg
          simp only [decide_eq_true_eq] at hg
          obtain ⟨hs, hor, hrins⟩ := hg
          rw [h.node _ r hr]
          simp only [decide_eq_true_eq]
          refine ⟨by rw [renameN, strip_rename, hs], ?_, by rw [renameN, hrins, hins]⟩
          rcases hor with hor | hor
          · left
            show renameCls cl r.prim = e.prim
            rw [hor]
            cases hp : e.prim with
            | replayed _ _ =>
              have := strip_not_replayed (κ := κ) r.prim
              rw [← hor] at hp
              exact absurd (hs.trans (hor.symm.trans hp)) (this _ _)
            | _ => rfl
          · exact .inr hor

omit [DecidableEq κ] in
/-- Input carriers transport when the iteration's input projection is the
template's renamed. -/
theorem inputCarriers_embed (E : List (RNode Int κ)) (cert : List Nat) (hlen : E.length ≤ cert.length)
    (ins ins' : κ → Option Nat) (hins : ∀ key j, ins key = some j → ins' key = some (σ j))
    (h : inputCarriersMatch E cert ins = true) : inputCarriersMatch E (cert.map σ) ins' = true := by
  unfold inputCarriersMatch at h ⊢
  refine List.all_eq_true.mpr fun k hk => ?_
  have hkE : k < E.length := List.mem_range.mp hk
  have hok := List.all_eq_true.mp h k hk
  rw [List.getElem?_eq_getElem hkE] at hok ⊢
  dsimp only at hok ⊢
  cases hp : E[k].prim with
  | input key =>
    rw [hp] at hok
    simp only [decide_eq_true_eq] at hok ⊢
    rw [certAt_map σ cert k (by omega)]
    exact hins key _ hok
  | _ => rfl

end

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) {κ : Type} [DecidableEq κ] (env : Env κ)
variable {σ cl : Nat → Nat}

/-- Input values transport when every input the graph reads has a value. -/
theorem inputsHeld_embed (G G' : Nat → Option (RNode Int κ)) (h : Embeds σ cl G G') (E : List (RNode Int κ))
    (cert : List Nat) (hlen : E.length ≤ cert.length)
    (defined : ∀ (k : Nat) (e : RNode Int κ) (key : κ), E[k]? = some e → e.prim = .input key → (env.inputs key).isSome)
    (hin : InputsHeld M K env G E cert) : InputsHeld M K env G' E (cert.map σ) := by
  intro k e key he hp
  have hk : k < E.length := (List.getElem?_eq_some_iff.mp he).1
  rw [certAt_map σ cert k (by omega)]
  have hv := hin k e key he hp
  cases hd : env.inputs key with
  | none => have := defined k e key he hp; rw [hd] at this; cases this
  | some v => rw [hd] at hv; rw [evalR_embed M K env G G' h _ v hv]

end

end Host.Mlx.SimGraph
