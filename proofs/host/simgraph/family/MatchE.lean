import host.simgraph.family.Eval
import host.simgraph.Embed
import host.simgraph.prompt.MatchMap
import host.simgraph.Native
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # Carrying a family's expected graph

`MatchesD`/`Matches` check an expected graph against the FFI graph node by
node; a family's expected graph also has compiled-closure nodes
(`closureP c`), which the FFI graph holds as the closure's replayed body.

* `closureLeavesD`: `closureLeaves` (FfiEvalPrefill) at any dimension type;
  `closureLeavesD_mapG`: it ignores the dimensions.
* `nodeOkED`/`MatchesED kind`: `nodeOkD`/`MatchesD`, a closure node carried by
  the root of a replayed body of the closure `kind` names (`kind`: closure
  objects to the TypeScript closures they compile, part of the certificate).
* `matchesED_map`: a symbolic match survives a map of the dimensions (so one
  check of a symbolic template covers every instance).
* `matches_evalG`: a graph carrying `E` whose input carriers hold the inputs
  and whose primitives evaluate as `E`'s (`PrimsAgree`) holds every value `E`
  has: the FFI graph's value at the carrier of node `k` is `evalE`'s, for any
  evaluation of `evalRP`'s shape (`EvalShape`); `matches_evalE`: at `evalRP`,
  kernel nodes evaluating as `ks` (`KernelsAgree`). -/

/-! ## Closures at any dimension type

A closure body's check reads primitives that carry no dimensions (replay
tags, `multiply`, `sigmoid`, `astype`) and the argument lists, so it is the
same at any dimension map (`closureLeaves_mapG_eq`); at a symbolic type it is
`closureLeaves` of the graph with every dimension sent to 0. -/

section
variable {δ κ : Type} [DecidableEq δ] [DecidableEq κ]

theorem closureLeaves_mapG_eq (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (f g : δ → Int)
    (i : Nat) : closureLeaves kind (mapG f G) i = closureLeaves kind (mapG g G) i := by
  have hrb : ∀ (h : δ → Int) (q : RPrim δ κ) (c : Nat) (op : List Char), mapP h q = .replayed c (.binary op) ↔
      q = .replayed c (.binary op) := fun h _ _ _ => mapP_replayed h (fun _ => mapP_binary h)
  have hru : ∀ (h : δ → Int) (q : RPrim δ κ) (c : Nat) (op : List Char), mapP h q = .replayed c (.unary op) ↔
      q = .replayed c (.unary op) := fun h _ _ _ => mapP_replayed h (fun _ => mapP_unary h)
  have hra : ∀ (h : δ → Int) (q : RPrim δ κ) (c d : Nat), mapP h q = .replayed c (.astype d) ↔
      q = .replayed c (.astype d) := fun h _ _ _ => mapP_replayed h (fun _ => mapP_astype h)
  have hb2 : ∀ (h : δ → Int) (q : RPrim δ κ) (op : List Char), mapP h q = .binary op ↔ q = .binary op :=
    fun h _ _ => mapP_binary h
  have hast : ∀ (h : δ → Int) (q : RPrim δ κ) (d : Nat), mapP h q = .astype d ↔ q = .astype d :=
    fun h _ _ => mapP_astype h
  have hb : ∀ h : δ → Int, (fun j => if j < i then mapG h G j else none) =
      (fun j => ((fun j => if j < i then G j else none) j).map (mapN h)) := by
    intro h; funext j; by_cases hj : j < i <;> simp [hj, mapG]
  unfold closureLeaves
  rw [hb f, hb g]
  unfold mapG
  cases hG : G i with
  | none => rfl
  | some r =>
    simp only [Option.map_some, Option.bind_some]
    unfold closureAux
    simp only [mapN]
    cases hp : r.prim with
    | replayed cls p =>
      simp only [mapP, elementwise_mapP]
      split
      · have h1 := hb2 f; have h2 := hb2 g; have h3 := hast f; have h4 := hast g; have h5 := hrb f
        have h6 := hrb g; have h7 := hru f; have h8 := hru g; have h9 := hra f; have h10 := hra g
        simp only [closureBody, Option.bind_eq_bind, Option.bind_map, Function.comp_def, mapN, h1, h2, h3, h4, h5, h6,
          h7, h8, h9, h10, rnode_eq_mk]
      · rfl
    | _ => simp [mapP]

/-- The closure check at any dimension type. -/
def closureLeavesD (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (i : Nat) :
    Option (Compiled × List Nat) :=
  closureLeaves kind (mapG (fun _ => (0 : Int)) G) i

omit [DecidableEq δ] [DecidableEq κ] in
theorem mapG_comp {δ' δ'' : Type} (f : δ → δ') (g : δ' → δ'') (G : Nat → Option (RNode δ κ)) :
    mapG g (mapG f G) = mapG (fun d => g (f d)) G := by
  funext j
  simp only [mapG, Option.map_map, Function.comp_def, mapN, mapP_comp]
  cases G j <;> rfl

omit [DecidableEq δ] in
theorem closureLeavesD_mapG {δ' : Type} (f : δ → δ') (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ))
    (i : Nat) : closureLeavesD kind (mapG f G) i = closureLeavesD kind G i := by
  unfold closureLeavesD
  rw [mapG_comp]

end

theorem closureLeavesD_int {κ : Type} [DecidableEq κ] (kind : Nat → Option Compiled) (G : Nat → Option (RNode Int κ))
    (i : Nat) : closureLeavesD kind G i = closureLeaves kind G i := by
  unfold closureLeavesD
  rw [closureLeaves_mapG_eq kind G (fun _ => 0) (fun d => d)]
  congr 1
  funext j
  simp only [mapG]
  cases G j with
  | none => rfl
  | some r => simp [mapN_id]

theorem closureOf_mapP {δ δ' κ : Type} (f : δ → δ') (p : RPrim δ κ) : closureOf? (mapP f p) = closureOf? p := by
  cases p <;> rfl

/-! ## The check -/

section
variable {δ κ : Type} [DecidableEq δ] [DecidableEq κ]

/-- A closure node's check, if `e` is one. -/
def closureCheck (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (cert : List Nat) (k : Nat)
    (e : RNode δ κ) : Option Bool :=
  (closureOf? e.prim).map fun c => decide (closureLeavesD kind G (certAt cert k) = some (c, e.ins.map (certAt cert)))

/-- An operation node's check: its carrier has the primitive over the carriers of its arguments. -/
def plainCheck (G : Nat → Option (RNode δ κ)) (cert : List Nat) (k : Nat) (e : RNode δ κ) : Bool :=
  !isExpD e.prim && match G (certAt cert k) with
    | some r => decide (strip r.prim = e.prim ∧ (r.prim = e.prim ∨ elementwise e.prim = false) ∧
        r.ins = e.ins.map (certAt cert))
    | none => false

def nodeOkED (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (cert : List Nat) (k : Nat)
    (e : RNode δ κ) : Bool :=
  e.ins.all (· < k) && e.ins.all (fun j => certAt cert j < certAt cert k) &&
  (if isInputD e.prim then e.ins.isEmpty
   else if e.prim = .computeG then decide (cgLeaves G (certAt cert k) = some (e.ins.map (certAt cert)))
   else (closureCheck kind G cert k e).getD (plainCheck G cert k e))

/-- `E` is carried by `G` at `cert`, closures by their replayed bodies. -/
def MatchesED (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ))
    (cert : List Nat) : Bool :=
  (List.range E.length).all fun k => match E[k]? with
    | some e => nodeOkED kind G cert k e
    | none => false

end

section
variable {δ δ' κ : Type} [DecidableEq δ] [DecidableEq δ'] [DecidableEq κ] (f : δ → δ')

omit [DecidableEq δ'] in
theorem closureCheck_map (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (cert : List Nat) (k : Nat)
    (e : RNode δ κ) : closureCheck kind (mapG f G) cert k (mapN f e) = closureCheck kind G cert k e := by
  simp only [closureCheck, mapN, closureOf_mapP, closureLeavesD_mapG]

theorem plainCheck_map (G : Nat → Option (RNode δ κ)) (cert : List Nat) (k : Nat) (e : RNode δ κ)
    (h : plainCheck G cert k e = true) : plainCheck (mapG f G) cert k (mapN f e) = true := by
  simp only [plainCheck, Bool.and_eq_true, Bool.not_eq_true'] at h ⊢
  obtain ⟨hx, hg⟩ := h
  refine ⟨by simp only [mapN, isExpD_mapP]; exact hx, ?_⟩
  unfold mapG
  cases hr : G (certAt cert k) with
  | none => simp [hr] at hg
  | some r =>
    simp only [hr, decide_eq_true_eq] at hg
    obtain ⟨hs, hor, hins⟩ := hg
    rw [Option.map_some]
    refine decide_eq_true ⟨?_, ?_, hins⟩
    · show strip (mapP f r.prim) = mapP f e.prim
      rw [strip_mapP, hs]
    · rcases hor with hor | hor
      · exact .inl (show mapP f r.prim = mapP f e.prim by rw [hor])
      · exact .inr (show elementwise (mapP f e.prim) = false by rw [elementwise_mapP, hor])

theorem nodeOkED_map (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (cert : List Nat) (k : Nat)
    (e : RNode δ κ) (h : nodeOkED kind G cert k e = true) : nodeOkED kind (mapG f G) cert k (mapN f e) = true := by
  simp only [nodeOkED, Bool.and_eq_true] at h
  obtain ⟨⟨h1, h2⟩, h3⟩ := h
  simp only [nodeOkED, Bool.and_eq_true, closureCheck_map]
  simp only [mapN, isInputD_mapP]
  refine ⟨⟨h1, h2⟩, ?_⟩
  by_cases hi : isInputD e.prim = true
  · simp only [hi, ↓reduceIte] at h3 ⊢; exact h3
  · simp only [hi, ↓reduceIte, Bool.false_eq_true] at h3 ⊢
    by_cases hc : e.prim = .computeG
    · simp only [hc, ↓reduceIte] at h3
      simp only [hc, mapP, ↓reduceIte, cgLeaves_mapG]
      exact h3
    · have hc' : ¬ mapP f e.prim = .computeG := fun e' => hc ((mapP_computeG f).mp e')
      simp only [hc, ↓reduceIte] at h3
      simp only [hc', ↓reduceIte]
      cases hk : closureCheck kind G cert k e with
      | some b => rw [hk] at h3; exact h3
      | none =>
        rw [hk] at h3
        have := plainCheck_map f G cert k e h3
        simp only [mapN] at this
        exact this

/-- **A symbolic match covers every instance.** -/
theorem matchesED_map (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ))
    (cert : List Nat) (h : MatchesED kind G E cert = true) :
    MatchesED kind (mapG f G) (E.map (mapN f)) cert = true := by
  unfold MatchesED at h ⊢
  rw [List.length_map]
  refine List.all_eq_true.mpr fun k hk => ?_
  have hk' := List.all_eq_true.mp h k hk
  have hl : k < E.length := List.mem_range.mp hk
  simp only [List.getElem?_map, List.getElem?_eq_getElem hl, Option.map_some] at hk' ⊢
  exact nodeOkED_map f kind G cert k _ hk'

end

/-! ## Values -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) {κ : Type} [DecidableEq κ]
  (env : Env κ) (ks : KernelSem) (kind : Nat → Option Compiled)

omit [DecidableEq κ] in
theorem primEvalP_replayed (c : Nat) (p : RPrim Int κ) (xs : List Value) :
    primEvalP P K env (.replayed c p) xs = if elementwise p then none else primEvalP P K env p xs := by
  unfold primEvalP
  by_cases h : elementwise p = true
  · simp only [h, ↓reduceIte]
    show ((if elementwise p then none else primEval P.toMlxContract K env p xs).orElse
      fun _ => if elementwise p then none else rowsEval P p xs) = none
    simp [h]
  · simp only [h, ↓reduceIte, Bool.false_eq_true]
    show ((if elementwise p then none else primEval P.toMlxContract K env p xs).orElse
      fun _ => if elementwise p then none else rowsEval P p xs) = _
    simp [h]

/-- A replayed node over a non-elementwise primitive evaluates as the primitive. -/
theorem primEvalP_strip (p q : RPrim Int κ) (hs : strip p = q) (hq : p = q ∨ elementwise q = false) :
    primEvalP P K env p = primEvalP P K env q := by
  induction p generalizing q with
  | replayed c p ih =>
    have hs' : strip p = q := hs
    have hq' : elementwise q = false := by
      rcases hq with hq | hq
      · exact absurd (hs'.trans hq.symm) (strip_not_replayed p c p)
      · exact hq
    have he : elementwise p = false := by rw [← elementwise_strip, hs', hq']
    funext xs
    rw [primEvalP_replayed, he, ← ih q hs' (.inr hq')]
    rfl
  | _ => simp at hs; subst hs; rfl

/-- A closure root is not compute_g's root. -/
theorem closureBody_prim {cls : Nat} {p : RPrim Int κ} {r : RNode Int κ} {b : Nat → Option (RNode Int κ)}
    {x : Compiled × List Nat} (h : closureBody kind cls p r b = some x) :
    p = .binary chars!"multiply" ∨ p = .astype Ffi.dtBf16 := by
  unfold closureBody at h
  cases hk : kind cls with
  | none => simp [hk] at h
  | some c =>
    cases c <;> simp only [hk] at h
    · by_cases hp : p = .binary chars!"multiply"
      · exact .inl hp
      · simp [hp] at h
    · by_cases hp : p = .binary chars!"multiply"
      · exact .inl hp
      · simp [hp] at h
    · by_cases hp : p = .astype Ffi.dtBf16
      · exact .inr hp
      · simp [hp] at h

theorem closure_not_cg (G : Nat → Option (RNode Int κ)) (i : Nat) {x : Compiled × List Nat}
    (h : closureLeaves kind G i = some x) : cgLeaves G i = none := by
  unfold closureLeaves at h
  obtain ⟨r, hr, ha⟩ := Option.bind_eq_some_iff.mp h
  unfold closureAux at ha
  split at ha
  · rename_i cls p hp
    split at ha
    · rcases closureBody_prim kind ha with rfl | rfl <;>
        exact cgLeaves_none G i r hr (by rw [hp]; rfl)
    · cases ha
  · cases ha

/-- An evaluation of the FFI graph with `evalRP`'s shape at the primitive semantics `pe` (`evalRP`: `primEvalP`;
FfiEvalRoute's `evalRR`: `primEvalR`). -/
def EvalShape (ev : (Nat → Option (RNode Int κ)) → Nat → Option Value)
    (pe : RPrim Int κ → List Value → Option Value) : Prop :=
  ∀ g i, ev g i =
    match g i with
    | none => none
    | some nd =>
      match cgLeaves g i with
      | some leaves => (leaves.mapM fun j => if _h : j < i then ev g j else none).bind (computeGP P (κ := κ))
      | none =>
        match closureLeaves kind g i with
        | some (c, leaves) => (leaves.mapM fun j => if _h : j < i then ev g j else none).bind (compiledValue P c)
        | none => (nd.ins.mapM fun j => if _h : j < i then ev g j else none).bind (pe nd.prim)

/-- The FFI graph's primitives evaluate (`pe`) as the expected primitives (`primEvalE`) they carry. -/
def PrimsAgree (G : Nat → Option (RNode Int κ)) (pe : RPrim Int κ → List Value → Option Value) : Prop :=
  ∀ j nd (q : RPrim Int κ) xs v, G j = some nd → strip nd.prim = q → (nd.prim = q ∨ elementwise q = false) →
    q ≠ .computeG → closureOf? q = none → primEvalE P K env ks q xs = some v → pe nd.prim xs = some v

/-- **A carried expected graph's values are the carriers' values**, for any evaluation of `evalRP`'s shape whose
primitives agree with the expected graph's. -/
theorem matches_evalG (ev : (Nat → Option (RNode Int κ)) → Nat → Option Value)
    (pe : RPrim Int κ → List Value → Option Value) (hev : EvalShape P kind ev pe)
    (G : Nat → Option (RNode Int κ)) (E : List (RNode Int κ)) (cert : List Nat) (hm : MatchesED kind G E cert = true)
    (hin : ∀ k e key v, E[k]? = some e → e.prim = .input key → env.inputs key = some v →
      ev G (certAt cert k) = some v)
    (hpa : PrimsAgree P K env ks G pe) :
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
          exact hpa _ r e.prim xs v hr hs hor hc hk' hp

/-- The FFI nodes carrying `E`'s inputs hold the inputs' values. -/
def InputsHeldE (G : Nat → Option (RNode Int κ)) (E : List (RNode Int κ)) (cert : List Nat) : Prop :=
  ∀ k e key v, E[k]? = some e → e.prim = .input key → env.inputs key = some v →
    evalRP P K env kind G (certAt cert k) = some v

/-- `ks` is the FFI graph's kernel semantics wherever it has a value. -/
def KernelsAgree : Prop :=
  ∀ name c out xs v, ks name c out xs = some v → primEvalP P K env (.kernel name c out) xs = some v

theorem primsAgree_P (hks : KernelsAgree P K env ks) (G : Nat → Option (RNode Int κ)) :
    PrimsAgree P K env ks G (primEvalP P K env) := by
  intro j nd q xs v _ hs hor hc hcl hp
  rw [primEvalP_strip P K env nd.prim q hs hor]
  unfold primEvalE at hp
  split at hp
  · exact hks _ _ _ _ _ hp
  · contradiction
  · rw [hcl] at hp; exact hp

/-- **A carried expected graph's values are the carriers' values.** -/
theorem matches_evalE (G : Nat → Option (RNode Int κ)) (E : List (RNode Int κ)) (cert : List Nat)
    (hm : MatchesED kind G E cert = true) (hin : InputsHeldE P K env kind G E cert) (hks : KernelsAgree P K env ks) :
    ∀ k, k < E.length → ∀ v, evalE P K env ks (listGraph E) k = some v →
      evalRP P K env kind G (certAt cert k) = some v := by
  exact matches_evalG P K env ks kind (evalRP P K env kind) (primEvalP P K env) (evalRP_eq P K env kind) G E cert hm
    hin (primsAgree_P P K env ks hks G)

end

end Host.Mlx.SimGraph
