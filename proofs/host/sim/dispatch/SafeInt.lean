import host.sim.Num
import host.sim.Support
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # `Number.isSafeInteger` of a number reference

The interpreter answers `Number.isSafeInteger(x)` on a literal with `isSafeInt` and on a
number reference with three server tests (`safeB`): `trunc x = x`, `x ≤ 2^53 - 1` and
`-(2^53 - 1) ≤ x`, in that order. On every binary64 value the tests decide `isSafeInt`
(`isSafeInt_tests`), so `safeB` of a literal is `isSafeInt` (`safeB_lit`), and a target
holding the literal image of a source reference computes the source's answer (`safeB_sim`). -/

/-! ## Binary64 facts -/

/-- No negative exponent: the value of `round`/`norm` at a non-negative exponent. -/
def NonNegExp : F64 → Prop
  | .fin _ _ (.negSucc _) => False
  | _ => True

theorem ilt_eq (a b : Int) : F64.ilt a b = decide (a < b) := by
  apply Bool.eq_iff_iff.2
  cases a <;> cases b <;> simp [F64.ilt, Int.negSucc_eq] <;> omega

theorem ile_eq (a b : Int) : F64.ile a b = decide (a ≤ b) := by
  simp only [F64.ile, ilt_eq]
  by_cases h : b < a
  · simp [h, Int.not_le.2 h]
  · simp [h, Int.not_lt.1 h]

theorem odd_nonneg (neg : Bool) (m j : Nat) : NonNegExp (F64.odd neg m (.ofNat j)) := by
  unfold F64.odd
  have he : ∀ tz : Nat, Int.add (Int.ofNat j) (Int.ofNat tz) = Int.ofNat (j + tz) := fun _ => rfl
  simp only [he]
  cases Nat.blt (Nat.shiftLeft (Nat.shiftRight m (Nat.log2 (Nat.xor m (Nat.sub m 1))))
    (j + Nat.log2 (Nat.xor m (Nat.sub m 1)))) F64.small <;> trivial

theorem norm_nonneg (neg : Bool) (m : Nat) (e : Int) (he : 0 ≤ e) : NonNegExp (F64.norm neg m e) := by
  obtain ⟨j, rfl⟩ := Int.eq_ofNat_of_zero_le he
  unfold F64.norm
  cases Nat.beq m 0
  · cases j with
    | zero =>
      show NonNegExp (bif Nat.blt m F64.small then .fin neg m 0 else F64.odd neg m 0)
      cases Nat.blt m F64.small
      · exact odd_nonneg neg m 0
      · trivial
    | succ j => exact odd_nonneg neg m (j + 1)
  · trivial

theorem round_nonneg (neg : Bool) (p : Nat) : NonNegExp (F64.round F64.b64 neg p 1 0) := by
  unfold F64.round
  simp only [Bool.cond_eq_ite, F64.b64]
  split
  · exact norm_nonneg neg p 0 (Int.le_refl 0)
  · rename_i hc
    have hadd : ∀ a : Int, Int.add a 0 = a := Int.add_zero
    have hl : 53 ≤ Nat.log2 p := by
      simp only [Nat.beq_refl, Bool.true_and, Bool.and_eq_true, Nat.blt_eq, ile_eq, ilt_eq,
        decide_eq_true_eq, Nat.pow_eq, hadd, not_and] at hc
      by_cases hp : p = 0
      · subst hp
        simp [Nat.log2_zero] at hc
      · by_cases h53 : p < 2 ^ 53
        · have := (Nat.log2_lt hp).2 h53
          exact (hc ⟨h53, by decide⟩ (by omega)).elim
        · exact (Nat.le_log2 hp).2 (Nat.le_of_not_lt h53)
    have h1 : Nat.log2 1 = 0 := by decide
    simp only [h1]
    repeat' split
    all_goals first
      | (apply norm_nonneg; (try simp only [ilt_eq, ile_eq, decide_eq_true_eq] at *); omega)
      | exact True.intro

theorem eq_negSucc (r : F64) (hr : NonNegExp r) (s : Bool) (m k : Nat) :
    F64.eq r (.fin s m (.negSucc k)) = false := by
  cases r with
  | nan => rfl
  | inf _ => rfl
  | zero _ => rfl
  | fin a m' e' =>
    cases e' with
    | ofNat j => simp [F64.eq]
    | negSucc _ => exact hr.elim

/-- The three tests decide `isSafeInt` on every binary64 value. -/
theorem isSafeInt_tests (x : F64) :
    isSafeInt x = (F64.eq (F64.trunc x) x && F64.le x maxSafe && F64.le minSafe x) := by
  have hm : minSafe = F64.neg maxSafe := rfl
  rw [hm]
  cases x with
  | nan => rfl
  | inf b => cases b <;> rfl
  | zero b => cases b <;> rfl
  | fin s m e =>
    cases e with
    | ofNat k =>
      have htr : F64.trunc (.fin s m (.ofNat k)) = .fin s m (.ofNat k) := rfl
      have heq : F64.eq (.fin s m (.ofNat k)) (.fin s m (.ofNat k)) = true := by simp [F64.eq]
      rw [htr, heq, Bool.true_and]
      have hS : isSafeInt (.fin s m (.ofNat k)) = decide (m * 2 ^ k ≤ 2 ^ 53 - 1) := by
        cases s <;> simp only [isSafeInt, F64.toInt?, Bool.cond_false, Bool.cond_true, Int.natAbs_neg,
          Int.natAbs_natCast] <;> exact Bool.eq_iff_iff.2 (by simp [Nat.ble_eq])
      rw [hS]
      cases k with
      | zero =>
        apply Bool.eq_iff_iff.2
        cases s
        · have e1 : F64.le (.fin false m (.ofNat 0)) maxSafe =
              (Nat.blt m 9007199254740991 || (Nat.beq m 9007199254740991 && true)) := rfl
          have e2 : F64.le (F64.neg maxSafe) (.fin false m (.ofNat 0)) = true := rfl
          rw [e1, e2]
          simp only [Nat.blt_eq, Nat.beq_eq, Bool.and_true, Bool.or_eq_true, decide_eq_true_eq, Nat.pow_zero,
            Nat.mul_one]
          omega
        · have e1 : F64.le (.fin true m (.ofNat 0)) maxSafe = true := rfl
          have e2 : F64.le (F64.neg maxSafe) (.fin true m (.ofNat 0)) =
              (Nat.blt m 9007199254740991 || (Nat.beq 9007199254740991 m && true)) := rfl
          rw [e1, e2]
          simp only [Nat.blt_eq, Nat.beq_eq, Bool.and_true, Bool.or_eq_true, decide_eq_true_eq, Nat.pow_zero,
            Nat.mul_one, Bool.true_and]
          omega
      | succ k =>
        have h2 : m * 2 ^ (k + 1) = 2 * (m * 2 ^ k) := by rw [Nat.pow_succ, ← Nat.mul_assoc, Nat.mul_comm _ 2]
        have hsc : F64.scaledAt s m (.ofNat (k + 1)) 0 =
            bif s then -((m * 2 ^ (k + 1) : Nat) : Int) else ((m * 2 ^ (k + 1) : Nat) : Int) := by
          simp only [F64.scaledAt]
          rfl
        have hlt1 : F64.lt (.fin s m (.ofNat (k + 1))) maxSafe =
            F64.ilt (F64.scaledAt s m (.ofNat (k + 1)) 0) 9007199254740991 := rfl
        have heq1 : F64.eq (.fin s m (.ofNat (k + 1))) maxSafe = false := by
          simp [F64.eq, maxSafe]; intros; omega
        have hlt2 : F64.lt (F64.neg maxSafe) (.fin s m (.ofNat (k + 1))) =
            F64.ilt (-9007199254740991) (F64.scaledAt s m (.ofNat (k + 1)) 0) := rfl
        have heq2 : F64.eq (F64.neg maxSafe) (.fin s m (.ofNat (k + 1))) = false := by
          simp [F64.eq, maxSafe, F64.neg]; intros; omega
        simp only [F64.le, hlt1, heq1, hlt2, heq2, hsc, ilt_eq, Bool.or_false, h2]
        generalize m * 2 ^ k = w
        apply Bool.eq_iff_iff.2
        cases s <;> simp <;> omega
    | negSucc k =>
      have hf : isSafeInt (.fin s m (.negSucc k)) = false := rfl
      have ht : F64.eq (F64.trunc (.fin s m (.negSucc k))) (.fin s m (.negSucc k)) = false := by
        apply eq_negSucc
        show NonNegExp (bif Nat.beq (m / 2 ^ (k + 1)) 0 then .zero s else F64.round F64.b64 s (m / 2 ^ (k + 1)) 1 0)
        cases Nat.beq (m / 2 ^ (k + 1)) 0
        · exact round_nonneg s _
        · trivial
      rw [hf, ht, Bool.false_and, Bool.false_and]

/-! ## The tests through the servers -/

/-- On a literal the tests compute `isSafeInt`. -/
theorem safeB_lit (u : F64) : safeB (.lit u) = Host.Ts.M.pure (isSafeInt u) := by
  rw [isSafeInt_tests]
  funext β k
  show (cond (F64.eq (F64.trunc u) u) (Host.Ts.M.bind (numTest .le (.lit u) (.lit maxSafe)) fun v =>
      cond v (numTest .le (.lit minSafe) (.lit u)) (Host.Ts.M.pure false)) (Host.Ts.M.pure false)) β k = _
  cases F64.eq (F64.trunc u) u
  · rfl
  · show (cond (F64.le u maxSafe) (numTest .le (.lit minSafe) (.lit u)) (Host.Ts.M.pure false)) β k = _
    cases F64.le u maxSafe <;> rfl

section
variable {ν : Nat → F64} {M : Map} {S : SSrv} {C : CSrv}

/-- A supported number keeps its image under growth. -/
theorem _root_.Host.Ts.Sim.Grow.nv_eq {A : Nat → Prop} {M' : Map} {S' : SSrv} {C' : CSrv} (g : Grow M ν S C M' S' C') {x : NumV}
    (hx : Supp.nv A S.tab.length x) : M'.nv x = M.nv x := by
  cases x with
  | lit _ => rfl
  | ref i => exact g.ext.num i hx

/-- The tests on a source number and on its image give the same answer. -/
theorem safeB_sim {A : Nat → Prop} (hs : Srv M ν S C) (x : NumV) (hx : Supp.nv A S.tab.length x) :
    MSim (fun M' S' C' b b' => b' = b ∧ Grow M ν S C M' S' C') S C (safeB x) (safeB (M.nv x)) := by
  unfold safeB
  refine MSim.bind (numUn_sim hs .trunc x) ?_
  rintro M1 S1 C1 r r' ⟨rfl, g1⟩
  have hx1 := g1.nv_eq hx
  have t1 := numTest_sim g1.srv .eq r x
  rw [hx1] at t1
  refine MSim.bind (MSim.mono (P' := fun M' S' C' (e e' : Bool) => e' = e ∧ Grow M ν S C M' S' C') t1
    fun _ _ _ _ _ h => ⟨h.1, g1.trans h.2⟩) ?_
  rintro M2 S2 C2 e e' ⟨rfl, g2⟩
  cases e'
  · exact MSim.pure ⟨rfl, g2⟩
  · have hx2 := g2.nv_eq hx
    have t2 := numTest_sim g2.srv .le x (.lit maxSafe)
    have e2 : M2.nv (.lit maxSafe) = .lit maxSafe := rfl
    rw [hx2, e2] at t2
    simp only [Bool.cond_true]
    refine MSim.bind (MSim.mono (P' := fun M' S' C' (e e' : Bool) => e' = e ∧ Grow M ν S C M' S' C') t2
      fun _ _ _ _ _ h => ⟨h.1, g2.trans h.2⟩) ?_
    rintro M3 S3 C3 u u' ⟨rfl, g3⟩
    cases u'
    · exact MSim.pure ⟨rfl, g3⟩
    · have hx3 := g3.nv_eq hx
      have t3 := numTest_sim g3.srv .le (.lit minSafe) x
      have e3 : M3.nv (.lit minSafe) = .lit minSafe := rfl
      rw [hx3, e3] at t3
      simp only [Bool.cond_true]
      exact MSim.mono (P' := fun M' S' C' (e e' : Bool) => e' = e ∧ Grow M ν S C M' S' C') t3
        fun _ _ _ _ _ h => ⟨h.1, g3.trans h.2⟩

end

end Host.Ts.Sim.Disp

