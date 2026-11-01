import host.sim.template.Sigma
set_option autoImplicit false
namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim

/-! # A template's table against a state's table padded with the template

A template shared by chains whose tables differ has most entries with no image in the chain's table. So that table is extended by the
template's images, and those entries go to their own image: nothing to look up. Only the entries the walk paired are checked. -/

/-- The map sends `i` to its place in the padding, or `p` says it is fine. -/
def numPadAt (D : RData) (n : Nat) (p : Nat → Bool) (i : Nat) : Bool :=
  (match D.num.get i with
    | some (.ref j) => Nat.beq j (n + i)
    | _ => false) || p i

def numPadB (D : RData) (n len : Nat) (p : Nat → Bool) : Bool :=
  (List.range len).all (numPadAt D n p)

private theorem nth?_append_length {α : Type} : ∀ (l r : List α) (i : Nat), nth? (l ++ r) (l.length + i) = nth? r i
  | [], _, _ => by simp
  | _ :: l, r, i => by
    have h : (l.length + 1) + i = (l.length + i) + 1 := by omega
    simp only [List.cons_append, List.length_cons, h, nth?]
    exact nth?_append_length l r i

theorem checkNum_pad {D : RData} {θ : Nat → SymE} {tab0 tab1 : List SymE} {p : Nat → Bool}
    (hall : numPadB D tab1.length tab0.length p = true)
    (hp : ∀ i e, nth? tab0 i = some e → p i = true →
      (⟨tab1 ++ tab0.map (·.subst θ), []⟩ : SSrv).val (D.map.num i) = some (e.subst θ)) :
    checkNum D.map θ ⟨tab0, []⟩ ⟨tab1 ++ tab0.map (·.subst θ), []⟩ = true := by
  unfold checkNum
  refine List.all_eq_true.mpr fun i hi => ?_
  cases he : nth? tab0 i with
  | none => rfl
  | some e =>
    refine decide_eq_true ?_
    have hc := List.all_eq_true.mp hall i hi
    unfold numPadAt at hc
    cases hb : p i with
    | true => exact hp i e he hb
    | false =>
      rw [hb, Bool.or_false] at hc
      have hnum : D.map.num i = .ref (tab1.length + i) := by
        change (D.num.get i).getD (.ref i) = _
        cases hg : D.num.get i with
        | none => rw [hg] at hc; cases hc
        | some v =>
          rw [hg] at hc
          cases v with
          | ref j =>
            have := Nat.eq_of_beq_eq_true hc
            subst this
            rfl
          | lit x => cases hc
      rw [hnum]
      change nth? (tab1 ++ tab0.map (·.subst θ)) (tab1.length + i) = _
      rw [nth?_append_length, nth?_map, he]
      rfl

end Host.Ts.Sim.Template
