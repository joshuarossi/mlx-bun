import host.sim.native.CallS
namespace Host.Ts.Sim

/-! # Deciding the numeric premise

`ivl VB e`: an interval of naturals that the server expression `e` denotes
whenever every template variable `v` is a natural at most `VB v` (literal
naturals, variables, sums, differences whose subtrahend is at most the
minuend, and `int32` of values below `2 ^ 31`; every bound below `2 ^ 53`).
`smallLoadB VB` checks that the references `smallLoad` names have intervals
below `2 ^ 31`; `smallLoadB_sound` is its soundness. -/

def ivl (VB : Nat → Nat) : SymE → Option (Nat × Nat)
  | .lit f => match F64.toIndex? f with
    | some n => if f = F64.ofNat n ∧ n < 2 ^ 53 then some (n, n) else none
    | none => none
  | .var v => if VB v < 2 ^ 53 then some (0, VB v) else none
  | .bin .add a b => match ivl VB a, ivl VB b with
    | some (la, ha), some (lb, hb) => if ha + hb < 2 ^ 53 then some (la + lb, ha + hb) else none
    | _, _ => none
  | .bin .sub a b => match ivl VB a, ivl VB b with
    | some (la, ha), some (lb, hb) => if hb ≤ la ∧ ha < 2 ^ 53 then some (la - hb, ha - lb) else none
    | _, _ => none
  | .un .int32 a => match ivl VB a with
    | some (l, h) => if h < 2 ^ 31 then some (l, h) else none
    | none => none
  | _ => none

theorem ivl_sound {VB : Nat → Nat} {ν : Nat → F64} (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) :
    ∀ (e : SymE) {l h : Nat}, ivl VB e = some (l, h) → ∃ k, l ≤ k ∧ k ≤ h ∧ h < 2 ^ 53 ∧ e.eval ν = F64.ofNat k
  | .lit f, l, h, he => by
    simp only [ivl] at he
    split at he
    · rename_i n _
      split at he
      · rename_i hc
        simp only [Option.some.injEq, Prod.mk.injEq] at he
        obtain ⟨rfl, rfl⟩ := he
        exact ⟨_, Nat.le_refl _, Nat.le_refl _, hc.2, hc.1⟩
      · cases he
    · cases he
  | .var v, l, h, he => by
    simp only [ivl] at he
    split at he
    · rename_i hb
      simp only [Option.some.injEq, Prod.mk.injEq] at he
      obtain ⟨rfl, rfl⟩ := he
      obtain ⟨k, hk, hv⟩ := hν v
      exact ⟨k, Nat.zero_le _, hk, hb, hv⟩
    · cases he
  | .bin op a b, l, h, he => by
    cases op
    case add =>
      simp only [ivl] at he
      split at he
      · rename_i la ha lb hb e1 e2
        split at he
        · rename_i hc
          simp only [Option.some.injEq, Prod.mk.injEq] at he
          obtain ⟨rfl, rfl⟩ := he
          obtain ⟨ka, a1, a2, a3, a4⟩ := ivl_sound hν a e1
          obtain ⟨kb, b1, b2, b3, b4⟩ := ivl_sound hν b e2
          refine ⟨ka + kb, by omega, by omega, hc, ?_⟩
          show F64.bin .add (a.eval ν) (b.eval ν) = _
          rw [a4, b4, bin_add_ofNat ka kb (by omega)]
        · cases he
      · cases he
    case sub =>
      simp only [ivl] at he
      split at he
      · rename_i la ha lb hb e1 e2
        split at he
        · rename_i hc
          simp only [Option.some.injEq, Prod.mk.injEq] at he
          obtain ⟨rfl, rfl⟩ := he
          obtain ⟨ka, a1, a2, a3, a4⟩ := ivl_sound hν a e1
          obtain ⟨kb, b1, b2, b3, b4⟩ := ivl_sound hν b e2
          refine ⟨ka - kb, by omega, by omega, by omega, ?_⟩
          show F64.bin .sub (a.eval ν) (b.eval ν) = _
          rw [a4, b4, bin_sub_ofNat ka kb (by omega) (by omega)]
        · cases he
      · cases he
    all_goals (first | cases he | simp [ivl] at he)
  | .un op a, l, h, he => by
    cases op
    case int32 =>
      simp only [ivl] at he
      split at he
      · rename_i l0 h0 e1
        split at he
        · rename_i hc
          simp only [Option.some.injEq, Prod.mk.injEq] at he
          obtain ⟨rfl, rfl⟩ := he
          obtain ⟨k, k1, k2, k3, k4⟩ := ivl_sound hν a e1
          refine ⟨k, k1, k2, by omega, ?_⟩
          show F64.un .int32 (a.eval ν) = _
          rw [k4, un_int32_ofNat k (by omega)]
        · cases he
      · cases he
    all_goals (first | cases he | simp [ivl] at he)

/-- Reference `j` has an interval below `2 ^ 31`. -/
def refSmallB (VB : Nat → Nat) (S : SSrv) (j : Nat) : Bool :=
  match nth? S.tab j with
  | some e => match ivl VB e with
    | some (_, h) => decide (h < 2 ^ 31)
    | none => false
  | none => false

/-- **The decider of the numeric premise.** -/
def smallLoadB (VB : Nat → Nat) (S : SSrv) (x : Host.Load.LSt) (name : Name) (args : List Arg) : Bool :=
  (smallRefs x.mlx name args).all (refSmallB VB S)

theorem refSmallB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {j : Nat} (h : refSmallB VB S j = true)
    (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) : RefSmall ν S j := by
  unfold refSmallB at h
  split at h
  · rename_i e he
    split at h
    · rename_i l hi hi'
      obtain ⟨k, -, k2, -, k4⟩ := ivl_sound hν e hi'
      exact ⟨e, k, he, k4, by have := of_decide_eq_true h; omega⟩
    · cases h
  · cases h

/-- **Soundness of the decider.** -/
theorem smallLoadB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : Host.Load.LSt} {name : Name}
    {args : List Arg} (h : smallLoadB VB S x name args = true) (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) :
    smallLoad ν S x name args :=
  fun j hj => refSmallB_sound (List.all_eq_true.mp h j hj) hν

end Host.Ts.Sim
