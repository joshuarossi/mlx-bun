import host.sim.native.CallS
import host.sim.LinGood
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

/-! ## Affine bounds

`ivl` has no bound for a difference of correlated terms (`(3 + v) - v`), a product followed by an
exact division (`(v · 5120) / 5120`) or a rounded quotient (`floor((v + 255) / 256)`). `ivlL` reads
an expression with `Lin.absE` (`host.sim.LinGood`: exact affine forms with bounds, rounded quotients,
wrapping windows) over the box of the template variables `v` in `[0, VB v]`, each its own parameter. -/

/-- The largest variable index of an expression. -/
def symMaxVar : SymE → Nat
  | .lit _ => 0
  | .var i => i
  | .bin _ a b => max (symMaxVar a) (symMaxVar b)
  | .un _ a => symMaxVar a

/-- The box of the variables `i, …, i + n - 1` in `[0, VB _]`. -/
def smallBoxL (VB : Nat → Nat) (i n : Nat) : List Lin.Prm := (List.range' i n).map fun j => ⟨0, VB j, []⟩

/-- Every variable `j` of `i, …, i + n - 1` its own parameter. -/
def smallVarsL (i n : Nat) : List (Nat × Lin.Aff) := (List.range' i n).map fun j => (j, Lin.P j)

/-- **The bounds `Lin.absE` gives an expression** over the variables' box. -/
def ivlL (VB : Nat → Nat) (e : SymE) : Option (Nat × Nat) :=
  match Lin.absE (smallBoxL VB 0 (symMaxVar e + 1)) (smallVarsL 0 (symMaxVar e + 1)) e with
  | some r => match r.rg with
    | some (lo, hi) => bif decide (0 ≤ lo) && decide (hi < 2 ^ 53) then some (lo.toNat, hi.toNat) else none
    | none => none
  | none => none

/-- **`ivl`, else the bounds of the affine reading.** -/
def ivlA (VB : Nat → Nat) (e : SymE) : Option (Nat × Nat) :=
  match ivl VB e with
  | some p => some p
  | none => ivlL VB e

theorem smallBoxL_in {VB : Nat → Nat} {x : Nat → Int} (hx : ∀ j, 0 ≤ x j ∧ x j ≤ VB j) :
    ∀ (n i : Nat), Lin.InBox (smallBoxL VB i n) i x
  | 0, _ => trivial
  | n + 1, i => by
    simp only [smallBoxL, List.range'_succ, List.map_cons]
    exact ⟨⟨(hx i).1, (hx i).2, List.not_mem_nil⟩, smallBoxL_in hx n (i + 1)⟩

theorem smallVarsL_ok {ν : Nat → F64} {κ : Nat → Nat} (hν : ∀ v, ν v = F64.ofNat (κ v)) :
    ∀ (n i : Nat), Lin.VarsOk ν (fun j => (κ j : Int)) (smallVarsL i n)
  | 0, _ => trivial
  | n + 1, i => by
    simp only [smallVarsL, List.range'_succ, List.map_cons]
    refine ⟨?_, smallVarsL_ok hν n (i + 1)⟩
    rw [hν i]
    apply Lin.ofNat_ofInt
    simp only [Lin.Aff.eval, Lin.P, Lin.dot_replicate]
    simp

/-- **`ivlL` is sound** (`ivl_sound`'s statement). -/
theorem ivlL_sound {VB : Nat → Nat} {ν : Nat → F64} (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (e : SymE)
    {l h : Nat} (he : ivlL VB e = some (l, h)) : ∃ k, l ≤ k ∧ k ≤ h ∧ h < 2 ^ 53 ∧ e.eval ν = F64.ofNat k := by
  let κ : Nat → Nat := fun v => Classical.choose (hν v)
  have hκ : ∀ v, κ v ≤ VB v ∧ ν v = F64.ofNat (κ v) := fun v => Classical.choose_spec (hν v)
  unfold ivlL at he
  split at he
  · rename_i r hr
    split at he
    · rename_i lo hi hrg
      cases hc : (decide (0 ≤ lo) && decide (hi < 2 ^ 53))
      · rw [hc] at he; cases he
      · rw [hc, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at he
        obtain ⟨rfl, rfl⟩ := he
        simp only [Bool.and_eq_true, decide_eq_true_eq] at hc
        have hbox := smallBoxL_in (VB := VB) (x := fun j => (κ j : Int))
          (fun j => ⟨Int.natCast_nonneg _, Int.ofNat_le.mpr (hκ j).1⟩) (symMaxVar e + 1) 0
        have hvars := smallVarsL_ok (ν := ν) (κ := κ) (fun v => (hκ v).2) (symMaxVar e + 1) 0
        obtain ⟨v, ev, h1, h2, -⟩ := Lin.AV.den_rg (Lin.absE_sound hbox hvars e hr) hrg
        have hv0 : 0 ≤ v := by omega
        refine ⟨v.toNat, by omega, by omega, by omega, ?_⟩
        rw [ev, Lin.ofNat_ie v.toNat (by omega), Int.toNat_of_nonneg hv0]
    · cases he
  · cases he

/-- **`ivlA` is sound** (`ivl_sound`'s statement). -/
theorem ivlA_sound {VB : Nat → Nat} {ν : Nat → F64} (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (e : SymE) {l h : Nat}
    (he : ivlA VB e = some (l, h)) : ∃ k, l ≤ k ∧ k ≤ h ∧ h < 2 ^ 53 ∧ e.eval ν = F64.ofNat k := by
  unfold ivlA at he
  cases hi : ivl VB e with
  | some p => rw [hi] at he; cases he; exact ivl_sound hν e hi
  | none => rw [hi] at he; exact ivlL_sound hν e he

/-- Reference `j` has an interval below `2 ^ 31`. -/
def refSmallB (VB : Nat → Nat) (S : SSrv) (j : Nat) : Bool :=
  match nth? S.tab j with
  | some e => match ivlA VB e with
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
      obtain ⟨k, -, k2, -, k4⟩ := ivlA_sound hν e hi'
      exact ⟨e, k, he, k4, by have := of_decide_eq_true h; omega⟩
    · cases h
  · cases h

/-- **Soundness of the decider.** -/
theorem smallLoadB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : Host.Load.LSt} {name : Name}
    {args : List Arg} (h : smallLoadB VB S x name args = true) (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) :
    smallLoad ν S x name args :=
  fun j hj => refSmallB_sound (List.all_eq_true.mp h j hj) hν

end Host.Ts.Sim
