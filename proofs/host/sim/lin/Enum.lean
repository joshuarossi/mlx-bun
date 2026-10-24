import host.sim.LinGood
namespace Host.Ts.Sim.Lin
open Host.Ts

/-! # goodEnum: one parameter by enumeration

`goodLin` decides an answer only when both sides are exact integer forms, ranges or `±Infinity`
over the box. Where a template compares binary64 values that are not integers (the down
plan's costs, `Math.ceil(M / 8) * 0.6 <= Math.ceil(M / 16)`, kernels/trellis/down-mma-wide.ts:40-53),
`goodEnum` checks the answer at every integer value of the one parameter the forms read: the
interpreter's binary64 operations (`SymE.eval`, `F64.test`) are evaluated by the kernel at each
point. An answer `goodLin` decides over the box (`checkAns`) is not enumerated.

The forms must read at most one parameter `i` (`readVar`, `onlyAt`; when they read none the
answers are checked at one point), and every variable of an enumerated answer must have a form
(`varsIn`). `goodEnum_sound` then gives `Good ρ o` at every valuation of the class, as
`goodLin_sound` does. The cost is linear in the parameter's range `hi - lo + 1`. -/

/-- Every variable of `e` has a form in `V`. -/
def varsIn (V : List (Nat × Aff)) : SymE → Bool
  | .lit _ => true
  | .var j => (lookup V j).isSome
  | .bin _ a b => varsIn V a && varsIn V b
  | .un _ a => varsIn V a

/-- The coefficients from index `k` on are zero except at `i`. -/
def onlyAt (i : Nat) : List Int → Nat → Bool
  | [], _ => true
  | a :: as, k => (k == i || a == 0) && onlyAt i as (k + 1)

/-- The first index from `k` on with a nonzero coefficient. -/
def firstVar : List Int → Nat → Option Nat
  | [], _ => none
  | a :: as, k => if a = 0 then firstVar as (k + 1) else some k

/-- The first parameter the forms read. -/
def readVar : List (Nat × Aff) → Option Nat
  | [] => none
  | (_, f) :: V => match firstVar f.cs 0 with
    | some i => some i
    | none => readVar V

/-- The valuation of the forms at parameter value `v` (`+0` off the forms). -/
def valAt (V : List (Nat × Aff)) (v : Int) (j : Nat) : F64 :=
  match lookup V j with
  | some f => F64.ofInt (f.eval fun _ => v)
  | none => .zero false

/-- Answer `q` holds at parameter value `v`. -/
def ansAt (V : List (Nat × Aff)) (q : Ans) (v : Int) : Bool :=
  F64.test q.op (q.a.eval (valAt V v)) (q.b.eval (valAt V v)) == q.r

/-- `f` holds at `v, v + 1, …, v + n - 1`, except at the excluded values `ex`. -/
def allPts (ex : List Int) (f : Int → Bool) : Int → Nat → Bool
  | _, 0 => true
  | v, n + 1 => (ex.contains v || f v) && allPts ex f (v + 1) n

/-- **goodEnum.** Every answer is decided by `goodLin` or checked at every value of the one
parameter the forms read. -/
def goodEnum (ps : List Prm) (V : List (Nat × Aff)) (o : List Ans) : Bool :=
  match readVar V with
  | none => o.all fun q => checkAns ps V q || (varsIn V q.a && varsIn V q.b && ansAt V q 0)
  | some i => match ps[i]? with
    | some p => V.all (fun f => onlyAt i f.2.cs 0) && o.all fun q => checkAns ps V q ||
        (varsIn V q.a && varsIn V q.b && allPts p.ex (ansAt V q) p.lo (p.hi - p.lo + 1).toNat)
    | none => false

/-! ## Soundness -/

theorem lookup_mem : ∀ {V : List (Nat × Aff)} {j : Nat} {f : Aff}, lookup V j = some f → (j, f) ∈ V
  | [], _, _, h => by simp [lookup] at h
  | (k, g) :: V, j, f, h => by
    simp only [lookup] at h
    split at h
    · next hk => simp only [Option.some.injEq] at h; subst h hk; exact List.mem_cons_self
    · exact List.mem_cons_of_mem _ (lookup_mem h)

theorem eval_congr {V : List (Nat × Aff)} {ρ ρ' : Nat → F64} (h : ∀ j f, lookup V j = some f → ρ j = ρ' j) :
    ∀ e : SymE, varsIn V e = true → e.eval ρ = e.eval ρ'
  | .lit _, _ => rfl
  | .var j, hv => by
    simp only [varsIn, Option.isSome_iff_exists] at hv
    obtain ⟨f, hf⟩ := hv
    exact h j f hf
  | .bin op a b, hv => by
    simp only [varsIn, Bool.and_eq_true] at hv
    simp only [SymE.eval, eval_congr h a hv.1, eval_congr h b hv.2]
  | .un op a, hv => by
    simp only [varsIn] at hv
    simp only [SymE.eval, eval_congr h a hv]

theorem dot_onlyAt {i : Nat} {x y : Nat → Int} (h : x i = y i) :
    ∀ (cs : List Int) (k : Nat), onlyAt i cs k = true → dot cs k x = dot cs k y
  | [], _, _ => rfl
  | a :: as, k, ho => by
    simp only [onlyAt, Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq] at ho
    simp only [dot, dot_onlyAt h as (k + 1) ho.2]
    rcases ho.1 with e | e
    · subst e; rw [h]
    · subst e; simp

theorem dot_firstVar {x y : Nat → Int} : ∀ (cs : List Int) (k : Nat), firstVar cs k = none → dot cs k x = dot cs k y
  | [], _, _ => rfl
  | a :: as, k, h => by
    simp only [firstVar] at h
    split at h
    · next e => subst e; simp only [dot, Int.zero_mul, Int.zero_add]; exact dot_firstVar as (k + 1) h
    · cases h

theorem readVar_none : ∀ {V : List (Nat × Aff)}, readVar V = none → ∀ p ∈ V, firstVar p.2.cs 0 = none
  | [], _, _, hp => by simp at hp
  | (j, f) :: V, h, p, hp => by
    simp only [readVar] at h
    split at h
    · cases h
    · next hf =>
      rcases List.mem_cons.mp hp with rfl | hp
      · exact hf
      · exact readVar_none h p hp

theorem inBox_get : ∀ {ps : List Prm} {i : Nat} {x : Nat → Int}, InBox ps i x → ∀ {k : Nat} {p : Prm},
    ps[k]? = some p → p.lo ≤ x (i + k) ∧ x (i + k) ≤ p.hi ∧ x (i + k) ∉ p.ex
  | [], _, _, _, _, _, h => by simp at h
  | q :: qs, i, x, hb, 0, p, h => by
    simp only [List.getElem?_cons_zero, Option.some.injEq] at h; subst h
    exact hb.1
  | q :: qs, i, x, hb, k + 1, p, h => by
    simp only [List.getElem?_cons_succ] at h
    have := inBox_get hb.2 h
    rwa [show i + 1 + k = i + (k + 1) by omega] at this

theorem allPts_sound {ex : List Int} {f : Int → Bool} :
    ∀ {lo : Int} {n : Nat}, allPts ex f lo n = true → ∀ {v : Int}, lo ≤ v → v < lo + n → v ∉ ex → f v = true
  | _, 0, _, _, h1, h2, _ => by omega
  | lo, n + 1, h, v, h1, h2, hv => by
    simp only [allPts, Bool.and_eq_true, Bool.or_eq_true] at h
    by_cases e : v = lo
    · subst e
      rcases h.1 with h' | h'
      · exact absurd (List.contains_iff_mem.mp h') hv
      · exact h'
    · exact allPts_sound h.2 (by omega) (by omega) hv

/-- An answer checked at the point `v` holds at `ρ` when `ρ` agrees with the forms at `v`. -/
theorem ans_of_at {V : List (Nat × Aff)} {ρ : Nat → F64} {v : Int} (hagree : ∀ j f, lookup V j = some f → ρ j = valAt V v j)
    {q : Ans} (ha : varsIn V q.a = true) (hb : varsIn V q.b = true) (h : ansAt V q v = true) :
    F64.test q.op (q.a.eval ρ) (q.b.eval ρ) = q.r := by
  simp only [ansAt, beq_iff_eq] at h
  rw [eval_congr hagree q.a ha, eval_congr hagree q.b hb]
  exact h

/-- **goodEnum is sound**: a `true` result makes `Good ρ o` hold at every valuation of the class. -/
theorem goodEnum_sound {ps : List Prm} {V : List (Nat × Aff)} {o : List Ans} (h : goodEnum ps V o = true)
    {x : Nat → Int} (hx : InBox ps 0 x) {ρ : Nat → F64} (hρ : VarsOk ρ x V) : Good ρ o := by
  unfold goodEnum at h
  split at h
  · next hn =>
    have hagree : ∀ j f, lookup V j = some f → ρ j = valAt V 0 j := by
      intro j f hf
      rw [lookup_ok hρ hf]
      simp only [valAt, hf]
      congr 1
      unfold Aff.eval
      rw [dot_firstVar f.cs 0 (readVar_none hn (j, f) (lookup_mem hf))]
    intro q hq
    simp only [List.all_eq_true, Bool.or_eq_true, Bool.and_eq_true] at h
    rcases h q hq with hc | ⟨⟨ha, hb⟩, he⟩
    · exact checkAns_sound hx hρ hc
    · exact ans_of_at hagree ha hb he
  · next i _ =>
    split at h
    · next p hp =>
      simp only [Bool.and_eq_true, List.all_eq_true, Bool.or_eq_true] at h
      obtain ⟨h1, h2⟩ := h
      have hb := inBox_get hx hp
      rw [Nat.zero_add] at hb
      have hagree : ∀ j f, lookup V j = some f → ρ j = valAt V (x i) j := by
        intro j f hf
        rw [lookup_ok hρ hf]
        simp only [valAt, hf]
        congr 1
        unfold Aff.eval
        rw [dot_onlyAt (y := fun _ => x i) rfl f.cs 0 (h1 _ (lookup_mem hf))]
      intro q hq
      rcases h2 q hq with hc | ⟨⟨ha, hb'⟩, he⟩
      · exact checkAns_sound hx hρ hc
      · exact ans_of_at hagree ha hb' (allPts_sound he hb.1 (by omega) hb.2.2)
    · cases h

end Host.Ts.Sim.Lin
