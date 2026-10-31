import host.sim.lin.Classes
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

/-- A call result's checked value at a row: a natural number inside the variable bound, and,
when the chain maps its canonical variable, the mapped quantity. -/
def resChk (r : Row) (m : List (Nat × Q)) (E : SymE) (oq : Option Q) : Bool :=
  match absE r.ps (varsOf r.V m) E with
  | none => false
  | some a =>
    (match a.rg with
      | some (lo, hi) => decide (0 ≤ lo) && decide (hi ≤ 2 ^ 20)
      | none => false) &&
    (match oq with
      | none => true
      | some q =>
        match a, lookupQ r.V q with
        | .aff f _ _, some g => isConst (g - f) && decide ((g - f).c = 0)
        | _, _ => false)

theorem resChk_sound {r : Row} {m : List (Nat × Q)} {E : SymE} {oq : Option Q}
    (h : resChk r m E oq = true) {i : Cls.Inst} (hi : InRow r i) {ν : Nat → F64} (hν : MapOk ν i m) :
    (∃ k ≤ 2 ^ 20, E.eval ν = F64.ofNat k) ∧ ∀ q, oq = some q → E.eval ν = F64.ofNat (i.get q) := by
  obtain ⟨-, x, hx, hq⟩ := hi
  unfold resChk at h
  cases ha : absE r.ps (varsOf r.V m) E with
  | none => simp [ha] at h
  | some a =>
    simp only [ha, Bool.and_eq_true] at h
    obtain ⟨h1, h2⟩ := h
    have hd := absE_sound hx (varsOk_of hq hν) E ha
    constructor
    · cases hr : a.rg with
      | none => simp [hr] at h1
      | some p =>
        obtain ⟨lo, hi'⟩ := p
        simp only [hr, Bool.and_eq_true, decide_eq_true_eq] at h1
        obtain ⟨v, hv, hl, hh, hs⟩ := AV.den_rg hd hr
        refine ⟨v.toNat, by omega, ?_⟩
        rw [hv, ← ofInt_ie v (by have := hs.1; have := hs.2; omega)]
        exact (ofNat_ofInt (n := v.toNat) (a := v) (by omega)).symm
    · intro q hqq
      subst hqq
      simp only at h2
      cases a with
      | aff f lo hi' =>
        cases hg : lookupQ r.V q with
        | none => simp [hg] at h2
        | some g =>
          simp only [hg, Bool.and_eq_true, decide_eq_true_eq] at h2
          have hge := lookupQ_ok hq hg
          have hd0 : (g - f).eval x = 0 := by
            rw [eval_const h2.1]; exact h2.2
          rw [Lin.eval_sub] at hd0
          rw [hd.1, ← ofInt_ie (f.eval x) (by have := hd.2.2.2.1; have := hd.2.2.2.2; have := hd.2.1; have := hd.2.2.1; omega)]
          exact (ofNat_ofInt (n := i.get q) (a := f.eval x) (by omega)).symm
      | rng lo hi' => simp at h2
      | inf s => simp at h2

end Host.Ts.Sim.Compose
