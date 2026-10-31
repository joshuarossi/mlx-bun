import host.sim.Free
set_option Elab.async false
namespace Host.Ts.Sim.Compose
open Host.Ts

theorem nth_take_lt {α : Type} : ∀ (xs : List α) (n i : Nat), i < n →
    nth? (xs.take n) i = nth? xs i
  | [], n, i, _ => by cases n <;> rfl
  | _ :: _, 0, _, h => (Nat.not_lt_zero _ h).elim
  | _ :: _, _ + 1, 0, _ => rfl
  | _ :: xs, n + 1, i + 1, h => nth_take_lt xs n i (Nat.lt_of_succ_lt_succ h)

theorem nth_range (n i : Nat) (hi : i < n) : nth? (List.range n) i = some i := by
  induction n with
  | zero => omega
  | succ n ih =>
    by_cases h : i < n
    · rw [List.range_succ, nth?_append_lt _ _ _ (by simpa using h)]
      exact ih h
    · have he : i = n := by omega
      subst i
      rw [List.range_succ]
      simpa only [List.length_range] using nth?_length_append (List.range n) n

theorem table_var_prefix {S : SSrv} {n : Nat}
    (h : S.tab.take n = (List.range n).map SymE.var) {j : Nat} (hj : j < n) :
    nth? S.tab j = some (.var j) := by
  have he := congrArg (fun xs : List SymE => nth? xs j) h
  rw [nth_take_lt S.tab n j hj, nth?_map, nth_range n j hj] at he
  exact he

/-- An unchanged reference prefix and a growing concrete server retain the
same variable values, even when the endpoint chooses a new valuation witness. -/
theorem valuation_prefix {M M' : Map} {ν ν' : Nat → F64} {S S' : SSrv} {C C' : CSrv}
    {n : Nat} (h : NumOK M ν S C) (h' : NumOK M' ν' S' C')
    (hs : S.tab.take n = (List.range n).map SymE.var)
    (hs' : S'.tab.take n = (List.range n).map SymE.var)
    (he : Ext M M' n) (hc : CSrv.Le C C') :
    ∀ j, j < n → ν' j = ν j := by
  intro j hj
  have ha := hc.val (h j (.var j) (table_var_prefix hs hj))
  have hb := h' j (.var j) (table_var_prefix hs' hj)
  change C'.val (M.num j) = some (ν j) at ha
  change C'.val (M'.num j) = some (ν' j) at hb
  rw [he.num j hj] at hb
  exact Option.some.inj (hb.symm.trans ha)

end Host.Ts.Sim.Compose
