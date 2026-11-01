import host.sim.template.Sigma
set_option autoImplicit false
namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim

/-! # A template's table against a state's table padded with the template

A template shared by chains whose tables differ has entries with no image in the chain's table. So that table is extended by the
template's images, and those entries go to their own image: nothing to look up. One pass over the two lists settles an entry the map
fixes. Only what remains is looked up. -/

/-- One pass: entry `e` at index `i`, with `rest` the chain's table from `i`. -/
def numPadGo (D : RData) (θ : Nat → SymE) (n : Nat) (p : Nat → Bool) : List SymE → List SymE → Nat → Bool
  | [], _, _ => true
  | e :: es, rest, i =>
    ((match D.num.get i with
      | some (.ref j) => Nat.beq j (n + i)
      | some _ => false
      | none => decide (rest.head? = some (e.subst θ))) || p i) && numPadGo D θ n p es rest.tail (i + 1)

def numPadB (D : RData) (θ : Nat → SymE) (tab0 tab1 : List SymE) (p : Nat → Bool) : Bool :=
  numPadGo D θ tab1.length p tab0 tab1 0

private theorem nth?_append_length {α : Type} : ∀ (l r : List α) (i : Nat), nth? (l ++ r) (l.length + i) = nth? r i
  | [], _, _ => by simp
  | _ :: l, r, i => by
    have h : (l.length + 1) + i = (l.length + i) + 1 := by omega
    simp only [List.cons_append, List.length_cons, h, nth?]
    exact nth?_append_length l r i

private theorem nth?_append_left {α : Type} : ∀ (l r : List α) (i : Nat) (a : α), nth? l i = some a → nth? (l ++ r) i = some a
  | [], _, _, _, h => by simp [nth?] at h
  | _ :: _, _, 0, _, h => h
  | _ :: l, r, i + 1, a, h => nth?_append_left l r i a h

private theorem nth?_tail {α : Type} : ∀ (l : List α) (k : Nat), nth? l.tail k = nth? l (k + 1)
  | [], _ => by simp [nth?]
  | _ :: _, _ => rfl

private theorem head?_nth {α : Type} : ∀ (l : List α), l.head? = nth? l 0
  | [] => rfl
  | _ :: _ => rfl

theorem numPadGo_sound {D : RData} {θ : Nat → SymE} {tab0 tab1 : List SymE} {p : Nat → Bool}
    (hp : ∀ i e, nth? tab0 i = some e → p i = true →
      (⟨tab1 ++ tab0.map (·.subst θ), []⟩ : SSrv).val (D.map.num i) = some (e.subst θ)) :
    ∀ (es rest : List SymE) (i : Nat), numPadGo D θ tab1.length p es rest i = true →
      (∀ k, nth? es k = nth? tab0 (i + k)) → (∀ k, nth? rest k = nth? tab1 (i + k)) →
      ∀ k e, nth? es k = some e →
        (⟨tab1 ++ tab0.map (·.subst θ), []⟩ : SSrv).val (D.map.num (i + k)) = some (e.subst θ)
  | [], _, _, _, _, _, _, _, he => by simp [nth?] at he
  | e0 :: es, rest, i, h, hes, hrest, k, e, he => by
    simp only [numPadGo, Bool.and_eq_true, Bool.or_eq_true] at h
    obtain ⟨hc, hgo⟩ := h
    cases k with
    | zero =>
      obtain rfl : e0 = e := Option.some.inj he
      have he0 : nth? tab0 i = some e0 := by
        have := hes 0
        simp only [Nat.add_zero] at this
        rw [← this]
        rfl
      rcases hc with hc | hc
      · cases hg : D.num.get i with
        | none =>
          rw [hg] at hc
          have hh : rest.head? = some (e0.subst θ) := of_decide_eq_true hc
          have hnum : D.map.num i = .ref i := by
            change (D.num.get i).getD (.ref i) = _
            rw [hg]
            rfl
          have h1 : nth? tab1 i = some (e0.subst θ) := by
            have := hrest 0
            simp only [Nat.add_zero] at this
            rw [← this, ← head?_nth, hh]
          change (⟨tab1 ++ tab0.map (·.subst θ), []⟩ : SSrv).val (D.map.num i) = _
          rw [hnum]
          exact nth?_append_left _ _ _ _ h1
        | some v =>
          rw [hg] at hc
          cases v with
          | ref j =>
            have hj : j = tab1.length + i := Nat.eq_of_beq_eq_true hc
            subst hj
            have hnum : D.map.num i = .ref (tab1.length + i) := by
              change (D.num.get i).getD (.ref i) = _
              rw [hg]
              rfl
            change (⟨tab1 ++ tab0.map (·.subst θ), []⟩ : SSrv).val (D.map.num i) = _
            rw [hnum]
            change nth? (tab1 ++ tab0.map (·.subst θ)) (tab1.length + i) = _
            rw [nth?_append_length, nth?_map, he0]
            rfl
          | lit x => cases hc
      · exact hp i e0 he0 hc
    | succ k =>
      have hrec := numPadGo_sound hp es rest.tail (i + 1) hgo
        (fun m => by
          have := hes (m + 1)
          rw [show i + (m + 1) = i + 1 + m by omega] at this
          exact this)
        (fun m => by
          rw [nth?_tail, hrest (m + 1)]
          rw [show i + (m + 1) = i + 1 + m by omega])
        k e he
      rw [show i + (k + 1) = i + 1 + k by omega]
      exact hrec

theorem checkNum_pad {D : RData} {θ : Nat → SymE} {tab0 tab1 : List SymE} {p : Nat → Bool}
    (hall : numPadB D θ tab0 tab1 p = true)
    (hp : ∀ i e, nth? tab0 i = some e → p i = true →
      (⟨tab1 ++ tab0.map (·.subst θ), []⟩ : SSrv).val (D.map.num i) = some (e.subst θ)) :
    checkNum D.map θ ⟨tab0, []⟩ ⟨tab1 ++ tab0.map (·.subst θ), []⟩ = true := by
  unfold checkNum
  refine List.all_eq_true.mpr fun i _ => ?_
  cases he : nth? tab0 i with
  | none => rfl
  | some e =>
    refine decide_eq_true ?_
    have h := numPadGo_sound hp tab0 tab1 0 hall (fun k => by simp) (fun k => by simp) i e he
    simpa using h

end Host.Ts.Sim.Template
