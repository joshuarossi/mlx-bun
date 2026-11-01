import host.sim.template.Sigma
namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim

/-! # A template's table against a state's, in one pass

`checkNum` looks every index up in both tables, so its cost is the square of their length. A template
made from a state starts with that state's table: there the map fixes the references, and one pass over
the two lists settles every index. Only the template's new entries (its places) are looked up. -/

private theorem nth?_take {α : Type} : ∀ {l : List α} {n i : Nat}, i < n → nth? (l.take n) i = nth? l i
  | [], _, _, _ => by simp [nth?]
  | _ :: _, 0, _, h => absurd h (Nat.not_lt_zero _)
  | _ :: _, _ + 1, 0, _ => rfl
  | a :: as, n + 1, i + 1, h => by
    simp only [List.take_succ_cons, nth?]
    exact nth?_take (Nat.lt_of_succ_lt_succ h)

/-- The map's number images are the references themselves below `n`. -/
def numIdB (D : RData) (n : Nat) : Bool :=
  (List.range n).all fun i => match D.num.get i with
    | some (.ref j) => Nat.beq j i
    | some _ => false
    | none => true

theorem checkNum_split {D : RData} {θ : Nat → SymE} {tab0 tab1 : List SymE} {n : Nat} {p : Nat → Bool}
    (hid : numIdB D n = true)
    (hhead : (tab0.take n).map (·.subst θ) = tab1.take n)
    (htail : (List.range' n (tab0.length - n)).all p = true)
    (hp : ∀ i e, nth? tab0 i = some e → p i = true →
      (⟨tab1, []⟩ : SSrv).val (D.map.num i) = some (e.subst θ)) :
    checkNum D.map θ ⟨tab0, []⟩ ⟨tab1, []⟩ = true := by
  unfold checkNum
  refine List.all_eq_true.mpr fun i hi => ?_
  have hlen : i < tab0.length := List.mem_range.mp hi
  cases he : nth? tab0 i with
  | none => rfl
  | some e =>
    refine decide_eq_true ?_
    by_cases hn : i < n
    · have h1 : nth? (tab0.take n) i = some e := by rw [nth?_take hn]; exact he
      have h2 : nth? ((tab0.take n).map (·.subst θ)) i = some (e.subst θ) := by
        rw [nth?_map, h1]
        rfl
      rw [hhead, nth?_take hn] at h2
      have hnum : D.map.num i = .ref i := by
        have hc := List.all_eq_true.mp hid i (List.mem_range.mpr hn)
        change (D.num.get i).getD (.ref i) = .ref i
        cases hg : D.num.get i with
        | none => rfl
        | some v =>
          rw [hg] at hc
          cases v with
          | ref j =>
            have := Nat.eq_of_beq_eq_true hc
            subst this
            rfl
          | lit x => cases hc
      rw [hnum]
      exact h2
    · have hm : i ∈ List.range' n (tab0.length - n) := by
        rw [List.mem_range'_1]
        omega
      exact hp i e he (List.all_eq_true.mp htail i hm)

end Host.Ts.Sim.Template
