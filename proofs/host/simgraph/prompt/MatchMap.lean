import host.simgraph.Match
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval

/-! # Symbolic matches under a map of dimension types

`matchesD_map` maps a symbolic match into integer dimensions. A match also
survives any map `f : δ → δ'` of symbolic dimension types (`matchesD_mapD`):
a check over `SDim` is a check over `PDim` through `SDim.toP`, so a decode
template is a multi-row template without a new kernel check. -/

section
variable {δ δ' κ : Type} [DecidableEq δ] [DecidableEq δ'] [DecidableEq κ] (f : δ → δ')

omit [DecidableEq δ] [DecidableEq δ'] [DecidableEq κ] in
theorem isInputD_mapP (p : RPrim δ κ) : isInputD (mapP f p) = isInputD p := by
  cases p <;> rfl

theorem isExpD_mapP (p : RPrim δ κ) : isExpD (mapP f p) = isExpD p := by
  simp only [isExpD, strip_mapP, mapP_unary]

theorem nodeOkD_mapD (G : Nat → Option (RNode δ κ)) (cert : List Nat) (k : Nat) (e : RNode δ κ)
    (h : nodeOkD G cert k e = true) : nodeOkD (mapG f G) cert k (mapN f e) = true := by
  simp only [nodeOkD, Bool.and_eq_true] at h
  obtain ⟨⟨h1, h2⟩, h3⟩ := h
  simp only [nodeOkD, Bool.and_eq_true, mapN, isInputD_mapP, h1, h2, true_and]
  by_cases hi : isInputD e.prim = true
  · simp only [hi, ↓reduceIte] at h3 ⊢; exact h3
  · simp only [hi, ↓reduceIte, Bool.false_eq_true] at h3 ⊢
    by_cases hc : e.prim = .computeG
    · simp only [hc, ↓reduceIte] at h3
      simp only [hc, mapP, ↓reduceIte, cgLeaves_mapG]
      exact h3
    · have hc' : ¬ mapP f e.prim = .computeG := fun e' => hc ((mapP_computeG f).mp e')
      simp only [hc, ↓reduceIte] at h3
      simp only [hc', ↓reduceIte, isExpD_mapP]
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

/-- **A symbolic match survives a map of the dimension type.** -/
theorem matchesD_mapD (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ)) (cert : List Nat)
    (h : MatchesD G E cert = true) : MatchesD (mapG f G) (E.map (mapN f)) cert = true := by
  unfold MatchesD at h ⊢
  rw [List.length_map]
  refine List.all_eq_true.mpr fun k hk => ?_
  have hk' := List.all_eq_true.mp h k hk
  have hl : k < E.length := List.mem_range.mp hk
  simp only [List.getElem?_map, List.getElem?_eq_getElem hl, Option.map_some] at hk' ⊢
  exact nodeOkD_mapD f G cert k _ hk'

omit [DecidableEq δ] [DecidableEq δ'] [DecidableEq κ] in
theorem inputCarriersMatchD_mapD (E : List (RNode δ κ)) (cert : List Nat) (inputs : κ → Option Nat) :
    inputCarriersMatchD (E.map (mapN f)) cert inputs = inputCarriersMatchD E cert inputs := by
  unfold inputCarriersMatchD
  rw [List.length_map]
  congr 1; funext k
  rw [List.getElem?_map]
  cases E[k]? with
  | none => rfl
  | some e => cases hp : e.prim <;> simp [mapN, mapP, hp]

end

end Host.Mlx.SimGraph
