import host.simgraph.Dims
import host.mlx.GraphCertificate
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval

/-! # Matching at symbolic dimensions

`nodeOkD`/`MatchesD` are `nodeOk`/`Matches` for any dimension type with
decidable equality. `matchesD_map`: a symbolic match stays a match after
mapping both graphs' dimensions by any `f : δ → Int`, so one kernel check
of a symbolic template covers every offset.

`SDim` is the template's dimension type: integer literals and the cache
offset `n` and `n + 1`; `SDim.eval n` reads it at offset `n`. -/

/-- Symbolic dimensions of a decode-step template. -/
inductive SDim where
  | lit (i : Int)
  | pos
  | pos1
deriving DecidableEq, Repr

def SDim.eval (n : Nat) : SDim → Int
  | .lit i => i
  | .pos => n
  | .pos1 => n + 1

section
variable {δ κ : Type} [DecidableEq δ] [DecidableEq κ]

def isExpD (p : RPrim δ κ) : Bool := decide (strip p = .unary chars!"exp")

def isInputD : RPrim δ κ → Bool
  | .input _ => true
  | _ => false

def nodeOkD (G : Nat → Option (RNode δ κ)) (cert : List Nat) (k : Nat) (e : RNode δ κ) : Bool :=
  e.ins.all (· < k) && e.ins.all (fun j => certAt cert j < certAt cert k) &&
  (if isInputD e.prim then e.ins.isEmpty
   else if e.prim = .computeG then decide (cgLeaves G (certAt cert k) = some (e.ins.map (certAt cert)))
   else !isExpD e.prim && match G (certAt cert k) with
     | some r => decide (strip r.prim = e.prim ∧ (r.prim = e.prim ∨ elementwise e.prim = false) ∧
         r.ins = e.ins.map (certAt cert))
     | none => false)

/-- `Matches` at dimension type `δ`. -/
def MatchesD (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ)) (cert : List Nat) : Bool :=
  (List.range E.length).all fun k => match E[k]? with
    | some e => nodeOkD G cert k e
    | none => false

end

section
variable {δ δ' κ : Type} (f : δ → δ')

theorem strip_mapP (p : RPrim δ κ) : strip (mapP f p) = mapP f (strip p) := by
  induction p <;> simp_all [mapP]

theorem elementwise_mapP (p : RPrim δ κ) : elementwise (mapP f p) = elementwise p := by
  induction p <;> simp_all [mapP, elementwise]

theorem mapP_unary {p : RPrim δ κ} {op : List Char} : mapP f p = .unary op ↔ p = .unary op := by
  cases p <;> simp [mapP]

theorem mapP_computeG {p : RPrim δ κ} : mapP f p = .computeG ↔ p = .computeG := by
  cases p <;> simp [mapP]

theorem mapP_replayed {p : RPrim δ κ} {c : Nat} {q : RPrim δ' κ} {q' : RPrim δ κ} (hq : ∀ r : RPrim δ κ, mapP f r = q ↔ r = q') :
    mapP f p = .replayed c q ↔ p = .replayed c q' := by
  cases p <;> simp [mapP, hq]

theorem mapP_binary {p : RPrim δ κ} {op : List Char} : mapP f p = .binary op ↔ p = .binary op := by
  cases p <;> simp [mapP]

theorem mapP_astype {p : RPrim δ κ} {d : Nat} : mapP f p = .astype d ↔ p = .astype d := by
  cases p <;> simp [mapP]

theorem replayedExp_mapP (p : RPrim δ κ) : replayedExp? (mapP f p) = replayedExp? p := by
  cases p with
  | replayed c q => cases q <;> simp [mapP, replayedExp?]
  | _ => rfl

theorem mapN_zero {r : RNode δ κ} {bs : List Nat} {d : Nat} :
    mapN f r = ⟨.data bs [] d, []⟩ ↔ r = ⟨.data bs [] d, []⟩ := by
  obtain ⟨p, ins⟩ := r
  cases p <;> simp [mapN, mapP]

theorem mapP_data_nil {p : RPrim δ κ} {bs : List Nat} {d : Nat} :
    mapP f p = .data bs [] d ↔ p = .data bs [] d := by
  cases p <;> simp [mapP]

theorem rnode_eq_mk {x : RNode δ κ} {p : RPrim δ κ} {l : List Nat} : x = ⟨p, l⟩ ↔ x.prim = p ∧ x.ins = l := by
  cases x; simp

theorem cgAux_map [DecidableEq δ] [DecidableEq δ'] [DecidableEq κ] (r : RNode δ κ) (b : Nat → Option (RNode δ κ)) :
    cgAux (mapN f r) (fun j => (b j).map (mapN f)) = cgAux r b := by
  have hm : ∀ {c : Nat} {op : List Char} (p : RPrim δ κ),
      mapP f p = .replayed c (.binary op) ↔ p = .replayed c (.binary op) :=
    fun p => mapP_replayed f (fun _ => mapP_binary f)
  have hu : ∀ {c : Nat} {op : List Char} (p : RPrim δ κ),
      mapP f p = .replayed c (.unary op) ↔ p = .replayed c (.unary op) :=
    fun p => mapP_replayed f (fun _ => mapP_unary f)
  have ha : ∀ {c d : Nat} (p : RPrim δ κ), mapP f p = .replayed c (.astype d) ↔ p = .replayed c (.astype d) :=
    fun p => mapP_replayed f (fun _ => mapP_astype f)
  simp only [cgAux, mapN, replayedExp_mapP, Option.bind_eq_bind, Option.bind_map, Function.comp_def, hm, hu, ha,
    mapP_data_nil, rnode_eq_mk]

theorem cgLeaves_mapG [DecidableEq δ] [DecidableEq δ'] [DecidableEq κ] (G : Nat → Option (RNode δ κ)) (i : Nat) :
    cgLeaves (mapG f G) i = cgLeaves G i := by
  unfold cgLeaves mapG
  cases hg : G i with
  | none => rfl
  | some r =>
    simp only [Option.map_some, Option.bind_some]
    have hb : (fun j => if j < i then (G j).map (mapN f) else none) =
        (fun j => ((fun j => if j < i then G j else none) j).map (mapN f)) := by
      funext j; by_cases h : j < i <;> simp [h]
    rw [hb, cgAux_map]

end

theorem isInput_mapP {δ κ : Type} (f : δ → Int) (p : RPrim δ κ) : isInput (mapP f p) = isInputD p := by
  cases p <;> rfl

section
variable {δ κ : Type} [DecidableEq δ] [DecidableEq κ] (f : δ → Int)

theorem isExp_mapP (p : RPrim δ κ) : isExp (mapP f p) = isExpD p := by
  simp only [isExp, isExpD, strip_mapP, mapP_unary]

theorem nodeOkD_map (G : Nat → Option (RNode δ κ)) (cert : List Nat) (k : Nat) (e : RNode δ κ)
    (h : nodeOkD G cert k e = true) : nodeOk (mapG f G) cert k (mapN f e) = true := by
  simp only [nodeOkD, Bool.and_eq_true] at h
  obtain ⟨⟨h1, h2⟩, h3⟩ := h
  simp only [nodeOk, Bool.and_eq_true, mapN, isInput_mapP, h1, h2, true_and]
  by_cases hi : isInputD e.prim = true
  · simp only [hi, ↓reduceIte] at h3 ⊢; exact h3
  · simp only [hi, ↓reduceIte, Bool.false_eq_true] at h3 ⊢
    by_cases hc : e.prim = .computeG
    · simp only [hc, ↓reduceIte] at h3
      simp only [hc, mapP, ↓reduceIte, cgLeaves_mapG]
      exact h3
    · have hc' : ¬ mapP f e.prim = .computeG := fun e' => hc ((mapP_computeG f).mp e')
      simp only [hc, ↓reduceIte] at h3
      simp only [hc', ↓reduceIte, isExp_mapP]
      simp only [Bool.and_eq_true, Bool.not_eq_true'] at h3 ⊢
      obtain ⟨hx, hg⟩ := h3
      refine ⟨hx, ?_⟩
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
          · exact .inr (by rw [elementwise_mapP, hor])

/-- **A symbolic match covers every instance.** -/
theorem matchesD_map (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ)) (cert : List Nat)
    (h : MatchesD G E cert = true) : Matches (mapG f G) (E.map (mapN f)) cert = true := by
  unfold MatchesD at h
  unfold Matches
  rw [List.length_map]
  refine List.all_eq_true.mpr fun k hk => ?_
  have hk' := List.all_eq_true.mp h k hk
  have hl : k < E.length := List.mem_range.mp hk
  simp only [List.getElem?_map, List.getElem?_eq_getElem hl, Option.map_some] at hk' ⊢
  exact nodeOkD_map f G cert k _ hk'

end

/-! ## Input carriers at symbolic dimensions -/

/-- `inputCarriersMatch` at dimension type `δ`. -/
def inputCarriersMatchD {δ κ : Type} (E : List (RNode δ κ)) (cert : List Nat) (inputs : κ → Option Nat) : Bool :=
  (List.range E.length).all fun k => match E[k]? with
    | some e => match e.prim with
      | .input key => decide (inputs key = some (certAt cert k))
      | _ => true
    | none => false

theorem inputCarriersMatch_map {δ κ : Type} (f : δ → Int) (E : List (RNode δ κ)) (cert : List Nat)
    (inputs : κ → Option Nat) : inputCarriersMatch (E.map (mapN f)) cert inputs = inputCarriersMatchD E cert inputs := by
  unfold inputCarriersMatch inputCarriersMatchD
  rw [List.length_map]
  congr 1; funext k
  rw [List.getElem?_map]
  cases E[k]? with
  | none => rfl
  | some e => cases hp : e.prim <;> simp [mapN, mapP, hp]

end Host.Mlx.SimGraph
