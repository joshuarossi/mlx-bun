import host.ts.RenameMaterializeState
import Lean.Elab.Tactic.Omega
namespace Host.Ts.F64

def natExact (n : Nat) : F64 := if n = 0 then .zero false else .fin false n 0

theorem ofNat_exact32 (n : Nat) (h : n < 2 ^ 31) : ofNat n = natExact n := by
  have hsmall : Nat.blt n (Nat.pow 2 53) = true := by
    rw [Nat.blt_eq]
    change n < 9007199254740992
    omega
  have hlog : Nat.log2 n < 1024 := by
    by_cases hn : n = 0
    · subst n; decide
    · have hh : Nat.log2 n < 31 := (Nat.log2_lt hn).mpr h
      omega
  have htop : ilt (Int.add (Nat.log2 n : Int) 0) 1024 = true := by
    change Nat.blt (Nat.log2 n) 1024 = true
    rw [Nat.blt_eq]
    exact hlog
  change round b64 false n 1 0 = _
  simp only [round, b64, hsmall, htop]
  change norm false n 0 = _
  unfold norm natExact
  by_cases hn : n = 0
  · subst n; rfl
  · have hb : Nat.beq n 0 = false := by
      cases hq : Nat.beq n 0
      · rfl
      · exact False.elim (hn (Nat.eq_of_beq_eq_true hq))
    have hs : Nat.blt n small = true := hsmall
    simp only [hb, hs, ite_eq_right hn]
    rfl

end Host.Ts.F64
namespace Host.Ts.F64

theorem toInt_natExact (n : Nat) : toInt? (natExact n) = some (n : Int) := by
  cases n with
  | zero => rfl
  | succ n =>
    simp only [natExact, Nat.succ_ne_zero, ↓reduceIte]
    change some (Int.ofNat ((n + 1) * 1)) = some (Int.ofNat (n + 1))
    rw [Nat.mul_one]

theorem add_natExact (m n : Nat) (h : m + n < 2 ^ 31) :
    add (natExact m) (natExact n) = natExact (m + n) := by
  cases m with
  | zero =>
    cases n <;> simp [natExact, add]
  | succ m =>
    cases n with
    | zero => simp [natExact, add]
    | succ n =>
      have hs : Nat.blt (m + 1 + (n + 1)) small = true := by
        rw [Nat.blt_eq]
        change m + 1 + (n + 1) < 9007199254740992
        omega
      change (bif Nat.blt (m + 1 + (n + 1)) small then
          fin false (m + 1 + (n + 1)) 0 else round b64 false (m + 1 + (n + 1)) 1 0) =
        fin false (m + 1 + (n + 1)) 0
      rw [hs]
      rfl

theorem lt_natExact (m n : Nat) : lt (natExact m) (natExact n) = decide (m < n) := by
  cases m with
  | zero => cases n <;> simp [natExact, lt]
  | succ m =>
    cases n with
    | zero => simp [natExact, lt]
    | succ n =>
      change Nat.blt (m + 1) (n + 1) = decide (m + 1 < n + 1)
      apply Bool.eq_iff_iff.mpr
      simp only [Nat.blt_eq, decide_eq_true_eq]

theorem rem_natExact (m n : Nat) (hn : 0 < n) :
    rem (natExact m) (natExact n) = natExact (m % n) := by
  cases n with
  | zero => omega
  | succ n =>
    cases m with
    | zero => rfl
    | succ m =>
      change (bif Nat.beq ((m + 1) % (n + 1)) 0 then zero false
        else fin false ((m + 1) % (n + 1)) 0) = _
      unfold natExact
      by_cases hr : (m + 1) % (n + 1) = 0
      · simp only [hr, ↓reduceIte]
        rfl
      · have hb : Nat.beq ((m + 1) % (n + 1)) 0 = false := by
          cases he : Nat.beq ((m + 1) % (n + 1)) 0
          · rfl
          · exact False.elim (hr (Nat.eq_of_beq_eq_true he))
        simp only [hb, Bool.cond_false, ite_eq_right hr]

theorem toInt_ofNat32 (n : Nat) (h : n < 2 ^ 31) : toInt? (ofNat n) = some (n : Int) := by
  rw [ofNat_exact32 n h, toInt_natExact]

theorem add_ofNat32 (m n : Nat) (h : m + n < 2 ^ 31) :
    add (ofNat m) (ofNat n) = ofNat (m + n) := by
  have hm : m < 2 ^ 31 := by omega
  have hn : n < 2 ^ 31 := by omega
  rw [ofNat_exact32 m hm, ofNat_exact32 n hn, ofNat_exact32 (m + n) h]
  exact add_natExact m n h

theorem test_lt_ofNat32 (m n : Nat) (hm : m < 2 ^ 31) (hn : n < 2 ^ 31) :
    test .lt (ofNat m) (ofNat n) = decide (m < n) := by
  change lt (ofNat m) (ofNat n) = _
  rw [ofNat_exact32 m hm, ofNat_exact32 n hn, lt_natExact]

theorem rem_ofNat32 (m n : Nat) (hm : m < 2 ^ 31) (hn : n < 2 ^ 31) (hp : 0 < n) :
    rem (ofNat m) (ofNat n) = ofNat (m % n) := by
  have hr : m % n < 2 ^ 31 := Nat.lt_trans (Nat.mod_lt m hp) hn
  rw [ofNat_exact32 m hm, ofNat_exact32 n hn, rem_natExact m n hp, ofNat_exact32 (m % n) hr]

/-- `prev + 1 > capacity` on a valid one-token KV append is precisely the full-cache
case. This derives the actual binary64 branch answer from the cache bounds. -/
theorem kv_growth_test (n c : Nat) (hc : c < 2 ^ 31) (hn : n + 1 < 2 ^ 31)
    (hfits : n ≤ c) :
    test .lt (ofNat c) (add (ofNat n) (ofNat 1)) = decide (n = c) := by
  rw [add_ofNat32 n 1 hn, test_lt_ofNat32 c (n + 1) hc hn]
  apply Bool.eq_iff_iff.mpr
  simp only [decide_eq_true_eq]
  omega

theorem kv_growth_aligned (c : Nat) (hc : c < 2 ^ 31) (halign : c % 256 = 0) :
    rem (ofNat c) (ofNat 256) = zero false := by
  rw [rem_ofNat32 c 256 hc (by decide) (by decide), halign]
  rfl

end Host.Ts.F64

namespace Host.Mlx.Ffi
open Host.Ts

theorem dimOf_ofNat32 (n : Nat) (h : n < 2 ^ 31) : dimOf (.lit (F64.ofNat n)) = .lit (n : Int) := by
  simp only [dimOf, F64.toInt_ofNat32 n h]

end Host.Mlx.Ffi

namespace Host.Ts

/-- A successful source comparison of bounded loop counters selects exactly the
natural-number branch, both before and after full-state materialization. -/
theorem step_numLt_bounded (F : Ffi) (ffiMap : CSrv → F.S → F.S)
    (s : St F.S) (C E : CSrv) (a b : NumV) (fs : List Frame) (m n : Nat)
    (hc : s.ctl = .ret (.num b)) (hf : s.stack = .e (.binR .lt (.num a)) :: fs)
    (ha : C.val a = some (F64.ofNat m)) (hb : C.val b = some (F64.ofNat n))
    (hm : m < 2 ^ 31) (hn : n < 2 ^ 31) :
    let t := { s with ctl := .ret (.bool (decide (m < n))), stack := fs }
    interpC (step F s).run C = some (t, C) ∧
      interpC (step F (materializeStateWith ffiMap C s)).run E =
        some (materializeStateWith ffiMap C t, E) := by
  have h := step_numLt_materializeWith F ffiMap s C E a b fs _ _ hc hf ha hb
  simpa only [F64.test_lt_ofNat32 m n hm hn] using h

end Host.Ts
