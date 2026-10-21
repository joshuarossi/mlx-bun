import host.ts.RenameIntegerPacking
import host.ts.Rename
namespace Host.Ts.Sim

/-! # Decode-loop template arithmetic

The symbolic decode-loop template names its loop state by variables: `v0`
budget `T`, `v9` cache offset `p`, `v10`/`v11`/`v12` generated count, step
index and yield count (all `i`), `v13` last index `i - 1`, `v14` current
token, `v15` previous token, `v16` KV capacity `c`, `v17` look-ahead token.
Every number is a natural far below `2^53`, so binary64 arithmetic on them is
exact: each template term denotes `F64.ofNat` of its natural-number value,
and each oracle test is a decidable proposition about naturals. One
iteration's substitution maps the loop valuation to the next one. -/

/-! ## Exact binary64 arithmetic on small naturals -/

theorem fin_eq_ofNat (k : Nat) (h0 : 0 < k) (h : k < 2 ^ 53) : F64.fin false k 0 = F64.ofNat k := by
  rw [F64.ofNat_exact53 k h]
  unfold F64.natExact
  exact (ite_eq_right (by omega)).symm

theorem zero_eq_ofNat : F64.zero false = F64.ofNat 0 := rfl

theorem bin_add_ofNat (m n : Nat) (h : m + n < 2 ^ 53) :
    F64.bin .add (F64.ofNat m) (F64.ofNat n) = F64.ofNat (m + n) :=
  F64.add_ofNat53 m n h

theorem sub_natExact_le (m n : Nat) (h : n ≤ m) :
    F64.sub (F64.natExact m) (F64.natExact n) = F64.natExact (m - n) := by
  cases m with
  | zero =>
    have hn : n = 0 := by omega
    subst n
    rfl
  | succ m => cases n with
    | zero => simp [F64.natExact, F64.sub, F64.neg, F64.add]
    | succ n =>
      by_cases he : m = n
      · subst m
        change (bif Nat.blt (n + 1) (n + 1) then F64.fin false ((n + 1) - (n + 1)) 0
          else bif Nat.blt (n + 1) (n + 1) then F64.fin true ((n + 1) - (n + 1)) 0 else F64.zero false) =
            F64.natExact ((n + 1) - (n + 1))
        have hz : Nat.blt (n + 1) (n + 1) = false := by
          cases hb : Nat.blt (n + 1) (n + 1)
          · rfl
          · have := Nat.blt_eq.mp hb
            omega
        rw [hz, Nat.sub_self]
        rfl
      · have hlt : Nat.blt (n + 1) (m + 1) = true := by
          rw [Nat.blt_eq]
          omega
        have hz : m + 1 - (n + 1) ≠ 0 := by omega
        change (bif Nat.blt (n + 1) (m + 1) then F64.fin false ((m + 1) - (n + 1)) 0
          else bif Nat.blt (m + 1) (n + 1) then F64.fin true ((n + 1) - (m + 1)) 0 else F64.zero false) =
            F64.natExact ((m + 1) - (n + 1))
        rw [hlt]
        exact (ite_eq_right hz).symm

theorem sub_natExact_lt (m n : Nat) (h : m < n) :
    F64.sub (F64.natExact m) (F64.natExact n) = F64.fin true (n - m) 0 := by
  cases n with
  | zero => omega
  | succ n => cases m with
    | zero => rfl
    | succ m =>
      have hge : Nat.blt (n + 1) (m + 1) = false := by
        cases hb : Nat.blt (n + 1) (m + 1)
        · rfl
        · have := Nat.blt_eq.mp hb
          omega
      have hlt : Nat.blt (m + 1) (n + 1) = true := by
        rw [Nat.blt_eq]
        omega
      change (bif Nat.blt (n + 1) (m + 1) then F64.fin false ((m + 1) - (n + 1)) 0
        else bif Nat.blt (m + 1) (n + 1) then F64.fin true ((n + 1) - (m + 1)) 0 else F64.zero false) = _
      rw [hge, hlt]
      rfl

theorem bin_sub_ofNat (m n : Nat) (hm : m < 2 ^ 53) (h : n ≤ m) :
    F64.bin .sub (F64.ofNat m) (F64.ofNat n) = F64.ofNat (m - n) := by
  change F64.sub _ _ = _
  rw [F64.ofNat_exact53 m hm, F64.ofNat_exact53 n (by omega), F64.ofNat_exact53 (m - n) (by omega)]
  exact sub_natExact_le m n h

/-- A negative difference is `-(n - m)`; no template term reaches it except
inside equality tests, which it fails. -/
theorem bin_sub_ofNat_neg (m n : Nat) (hn : n < 2 ^ 53) (h : m < n) :
    F64.bin .sub (F64.ofNat m) (F64.ofNat n) = F64.fin true (n - m) 0 := by
  change F64.sub _ _ = _
  rw [F64.ofNat_exact53 m (by omega), F64.ofNat_exact53 n hn]
  exact sub_natExact_lt m n h

theorem bin_rem_ofNat (m n : Nat) (hm : m < 2 ^ 53) (hn : n < 2 ^ 53) (hp : 0 < n) :
    F64.bin .rem (F64.ofNat m) (F64.ofNat n) = F64.ofNat (m % n) := by
  have hr : m % n < 2 ^ 53 := Nat.lt_trans (Nat.mod_lt m hp) hn
  change F64.rem _ _ = _
  rw [F64.ofNat_exact53 m hm, F64.ofNat_exact53 n hn, F64.rem_natExact m n hp, F64.ofNat_exact53 _ hr]

theorem toInt32_ofNat (n : Nat) (h : n < 2 ^ 31) : F64.toInt32 (F64.ofNat n) = (n : Int) := by
  have ht : F64.truncInt (F64.ofNat n) = some (n : Int) := by
    rw [F64.ofNat_exact53 n (by omega)]
    cases n <;> simp [F64.natExact, F64.truncInt]
  have hu : F64.toUint32 (F64.ofNat n) = n := by
    simp only [F64.toUint32, ht, F64.modNat]
    rw [Int.emod_eq_of_lt (by omega) (by omega)]
    rfl
  have hl : Nat.blt n (2 ^ 31) = true := Nat.blt_eq.mpr h
  simp only [F64.toInt32, hu, hl]
  rfl

theorem un_int32_ofNat (n : Nat) (h : n < 2 ^ 31) : F64.un .int32 (F64.ofNat n) = F64.ofNat n := by
  change F64.ofInt (F64.toInt32 (F64.ofNat n)) = _
  rw [toInt32_ofNat n h]
  rfl

theorem eq_natExact (m n : Nat) : F64.eq (F64.natExact m) (F64.natExact n) = decide (m = n) := by
  cases m with
  | zero => cases n <;> simp [F64.natExact, F64.eq]
  | succ m => cases n with
    | zero => simp [F64.natExact, F64.eq]
    | succ n =>
      simp only [F64.natExact, Nat.succ_ne_zero, ↓reduceIte]
      change (true && Nat.beq (m + 1) (n + 1) && true) = decide (m + 1 = n + 1)
      simp only [Bool.and_true, Bool.true_and]
      apply Bool.eq_iff_iff.mpr
      simp only [Nat.beq_eq, decide_eq_true_eq]

theorem test_lt_ofNat (m n : Nat) (hm : m < 2 ^ 53) (hn : n < 2 ^ 53) :
    F64.test .lt (F64.ofNat m) (F64.ofNat n) = decide (m < n) := by
  change F64.lt _ _ = _
  rw [F64.ofNat_exact53 m hm, F64.ofNat_exact53 n hn, F64.lt_natExact]

theorem test_eq_ofNat (m n : Nat) (hm : m < 2 ^ 53) (hn : n < 2 ^ 53) :
    F64.test .eq (F64.ofNat m) (F64.ofNat n) = decide (m = n) := by
  change F64.eq _ _ = _
  rw [F64.ofNat_exact53 m hm, F64.ofNat_exact53 n hn, eq_natExact]

/-- `1 === a - b` without `b ≤ a`: a negative difference is never `1`. -/
theorem test_eq_one_sub (a b : Nat) (ha : a < 2 ^ 53) (hb : b < 2 ^ 53) :
    F64.test .eq (F64.ofNat 1) (F64.bin .sub (F64.ofNat a) (F64.ofNat b)) = decide (a = b + 1) := by
  by_cases h : b ≤ a
  · rw [bin_sub_ofNat a b ha h, test_eq_ofNat 1 (a - b) (by decide) (by omega)]
    exact Bool.eq_iff_iff.mpr (by simp only [decide_eq_true_eq]; omega)
  · rw [bin_sub_ofNat_neg a b hb (by omega)]
    have hf : decide (a = b + 1) = false := decide_eq_false (by omega)
    rw [hf]
    rfl

/-! ## The same facts on symbolic terms -/

section
variable {ν : Nat → F64} {a b : SymE} {m n : Nat}

theorem eval_lit (k : Nat) (h0 : 0 < k) (h : k < 2 ^ 53) :
    (SymE.lit (F64.fin false k 0)).eval ν = F64.ofNat k :=
  fin_eq_ofNat k h0 h

theorem eval_add (ha : a.eval ν = F64.ofNat m) (hb : b.eval ν = F64.ofNat n) (h : m + n < 2 ^ 53) :
    (SymE.bin .add a b).eval ν = F64.ofNat (m + n) := by
  change F64.bin .add (a.eval ν) (b.eval ν) = _
  rw [ha, hb]
  exact bin_add_ofNat m n h

theorem eval_sub (ha : a.eval ν = F64.ofNat m) (hb : b.eval ν = F64.ofNat n) (hm : m < 2 ^ 53)
    (h : n ≤ m) : (SymE.bin .sub a b).eval ν = F64.ofNat (m - n) := by
  change F64.bin .sub (a.eval ν) (b.eval ν) = _
  rw [ha, hb]
  exact bin_sub_ofNat m n hm h

theorem eval_rem (ha : a.eval ν = F64.ofNat m) (hb : b.eval ν = F64.ofNat n) (hm : m < 2 ^ 53)
    (hn : n < 2 ^ 53) (hp : 0 < n) : (SymE.bin .rem a b).eval ν = F64.ofNat (m % n) := by
  change F64.bin .rem (a.eval ν) (b.eval ν) = _
  rw [ha, hb]
  exact bin_rem_ofNat m n hm hn hp

theorem eval_int32 (ha : a.eval ν = F64.ofNat m) (h : m < 2 ^ 31) :
    (SymE.un .int32 a).eval ν = F64.ofNat m := by
  change F64.un .int32 (a.eval ν) = _
  rw [ha]
  exact un_int32_ofNat m h

theorem test_lt_eval (ha : a.eval ν = F64.ofNat m) (hb : b.eval ν = F64.ofNat n) (hm : m < 2 ^ 53)
    (hn : n < 2 ^ 53) : F64.test .lt (a.eval ν) (b.eval ν) = decide (m < n) := by
  rw [ha, hb]
  exact test_lt_ofNat m n hm hn

theorem test_eq_eval (ha : a.eval ν = F64.ofNat m) (hb : b.eval ν = F64.ofNat n) (hm : m < 2 ^ 53)
    (hn : n < 2 ^ 53) : F64.test .eq (a.eval ν) (b.eval ν) = decide (m = n) := by
  rw [ha, hb]
  exact test_eq_ofNat m n hm hn

end

/-! ## Template literals and terms

Literals are the parser's binary64 normal forms (`F64.ofLit` of `0`, `1`,
`256`, `248044`); `Host.Ts.one` is `.lit (F64.fin false 1 0)`. Template terms
put the variable on the left of a literal operand, as the source writes
`generated + 1`. -/

abbrev litZero : SymE := .lit (.zero false)
abbrev litOne : SymE := .lit (.fin false 1 0)
abbrev lit256 : SymE := .lit (.fin false 256 0)
abbrev litEos : SymE := .lit (.fin false 248044 0)

/-- `v10 add 1`. -/
abbrev gen1 : SymE := .bin .add (.var 10) litOne
/-- `(v10 add 1) sub 1`. -/
abbrev gen1Prev : SymE := .bin .sub gen1 litOne
/-- `(v10 add 1) add 1`. -/
abbrev gen2 : SymE := .bin .add gen1 litOne
/-- `((v10 add 1) add 1) sub 1`. -/
abbrev gen2Prev : SymE := .bin .sub gen2 litOne
/-- `v9 add 1`. -/
abbrev off1 : SymE := .bin .add (.var 9) litOne
/-- `int32(v9)`. -/
abbrev off32 : SymE := .un .int32 (.var 9)
/-- `int32(v9 add 1)`. -/
abbrev off1I32 : SymE := .un .int32 off1
/-- `v16 add 256`. -/
abbrev capGrow : SymE := .bin .add (.var 16) lit256

theorem lit_ofNat : (F64.zero false = F64.ofNat 0) ∧ F64.fin false 1 0 = F64.ofNat 1 ∧
    F64.fin false 256 0 = F64.ofNat 256 ∧ F64.fin false 248044 0 = F64.ofNat 248044 :=
  ⟨rfl, rfl, rfl, rfl⟩

section
variable {ν : Nat → F64}
theorem eval_litZero : litZero.eval ν = F64.ofNat 0 := rfl
theorem eval_litOne : litOne.eval ν = F64.ofNat 1 := rfl
theorem eval_lit256 : lit256.eval ν = F64.ofNat 256 := rfl
theorem eval_litEos : litEos.eval ν = F64.ofNat 248044 := rfl
end

/-! ## The loop valuation -/

/-- The template's variables at loop state `(T, p, i, c)` with current,
previous and look-ahead tokens; `rest` gives `v1`–`v8` and fresh variables. -/
def loopVal (rest : Nat → F64) (T p i c tok ptok next : Nat) : Nat → F64
  | 0 => F64.ofNat T
  | 9 => F64.ofNat p
  | 10 => F64.ofNat i
  | 11 => F64.ofNat i
  | 12 => F64.ofNat i
  | 13 => F64.ofNat (i - 1)
  | 14 => F64.ofNat tok
  | 15 => F64.ofNat ptok
  | 16 => F64.ofNat c
  | 17 => F64.ofNat next
  | j => rest j

section
variable {rest : Nat → F64} {T p i c tok ptok next : Nat}

theorem loopVal_rest (j : Nat) (h0 : j ≠ 0) (h : j < 9 ∨ 17 < j) :
    loopVal rest T p i c tok ptok next j = rest j := by
  match j, h0, h with
  | 1, _, _ | 2, _, _ | 3, _, _ | 4, _, _ | 5, _, _ | 6, _, _ | 7, _, _ | 8, _, _ => rfl
  | j + 18, _, _ => rfl
  | 0, h0, _ => exact absurd rfl h0
  | 9, _, h | 10, _, h | 11, _, h | 12, _, h | 13, _, h | 14, _, h | 15, _, h | 16, _, h | 17, _, h =>
    omega

/-! ### Terms -/

theorem eval_v0 : (SymE.var 0).eval (loopVal rest T p i c tok ptok next) = F64.ofNat T := rfl
theorem eval_v9 : (SymE.var 9).eval (loopVal rest T p i c tok ptok next) = F64.ofNat p := rfl
theorem eval_v10 : (SymE.var 10).eval (loopVal rest T p i c tok ptok next) = F64.ofNat i := rfl
theorem eval_v11 : (SymE.var 11).eval (loopVal rest T p i c tok ptok next) = F64.ofNat i := rfl
theorem eval_v12 : (SymE.var 12).eval (loopVal rest T p i c tok ptok next) = F64.ofNat i := rfl
theorem eval_v13 : (SymE.var 13).eval (loopVal rest T p i c tok ptok next) = F64.ofNat (i - 1) := rfl
theorem eval_v14 : (SymE.var 14).eval (loopVal rest T p i c tok ptok next) = F64.ofNat tok := rfl
theorem eval_v15 : (SymE.var 15).eval (loopVal rest T p i c tok ptok next) = F64.ofNat ptok := rfl
theorem eval_v16 : (SymE.var 16).eval (loopVal rest T p i c tok ptok next) = F64.ofNat c := rfl
theorem eval_v17 : (SymE.var 17).eval (loopVal rest T p i c tok ptok next) = F64.ofNat next := rfl

theorem eval_gen1 (hi : i < 2 ^ 30) : gen1.eval (loopVal rest T p i c tok ptok next) = F64.ofNat (i + 1) :=
  eval_add eval_v10 eval_litOne (by omega)

theorem eval_gen1Prev (hi : i < 2 ^ 30) : gen1Prev.eval (loopVal rest T p i c tok ptok next) = F64.ofNat i :=
  eval_sub (eval_gen1 hi) eval_litOne (by omega) (by omega)

theorem eval_gen1Prev_rem (hi : i < 2 ^ 30) :
    (SymE.bin .rem gen1Prev lit256).eval (loopVal rest T p i c tok ptok next) = F64.ofNat (i % 256) :=
  eval_rem (eval_gen1Prev hi) eval_lit256 (by omega) (by decide) (by decide)

theorem eval_gen2 (hi : i < 2 ^ 30) : gen2.eval (loopVal rest T p i c tok ptok next) = F64.ofNat (i + 2) :=
  eval_add (m := i + 1) (n := 1) (eval_gen1 hi) eval_litOne (by omega)

theorem eval_gen2Prev (hi : i < 2 ^ 30) : gen2Prev.eval (loopVal rest T p i c tok ptok next) = F64.ofNat (i + 1) :=
  eval_sub (eval_gen2 hi) eval_litOne (by omega) (by omega)

theorem eval_gen2Prev_rem (hi : i < 2 ^ 30) :
    (SymE.bin .rem gen2Prev lit256).eval (loopVal rest T p i c tok ptok next) = F64.ofNat ((i + 1) % 256) :=
  eval_rem (eval_gen2Prev hi) eval_lit256 (by omega) (by decide) (by decide)

theorem eval_off1 (hp : p < 2 ^ 30) : off1.eval (loopVal rest T p i c tok ptok next) = F64.ofNat (p + 1) :=
  eval_add eval_v9 eval_litOne (by omega)

theorem eval_off32 (hp : p < 2 ^ 30) : off32.eval (loopVal rest T p i c tok ptok next) = F64.ofNat p :=
  eval_int32 eval_v9 (by omega)

theorem eval_off1I32 (hp : p < 2 ^ 30) : off1I32.eval (loopVal rest T p i c tok ptok next) = F64.ofNat (p + 1) :=
  eval_int32 (eval_off1 hp) (by omega)

/-- `int32(v9 add 1) sub int32(v9)`. -/
theorem eval_offDelta (hp : p < 2 ^ 30) :
    (SymE.bin .sub off1I32 off32).eval (loopVal rest T p i c tok ptok next) = F64.ofNat 1 := by
  have h := eval_sub (ν := loopVal rest T p i c tok ptok next) (eval_off1I32 hp) (eval_off32 hp) (by omega) (by omega)
  rwa [Nat.add_sub_cancel_left] at h

/-- `int32(v9 add 1) sub 0`. -/
theorem eval_off1I32_sub0 (hp : p < 2 ^ 30) :
    (SymE.bin .sub off1I32 litZero).eval (loopVal rest T p i c tok ptok next) = F64.ofNat (p + 1) :=
  eval_sub (eval_off1I32 hp) eval_litZero (by omega) (by omega)

/-- `v9 rem 256`. -/
theorem eval_off_rem (hp : p < 2 ^ 30) :
    (SymE.bin .rem (.var 9) lit256).eval (loopVal rest T p i c tok ptok next) = F64.ofNat (p % 256) :=
  eval_rem eval_v9 eval_lit256 (by omega) (by decide) (by decide)

theorem eval_capGrow (hc : c < 2 ^ 30) : capGrow.eval (loopVal rest T p i c tok ptok next) = F64.ofNat (c + 256) :=
  eval_add eval_v16 eval_lit256 (by omega)

/-! ### Tests

Each oracle query `op a b` of the template, as the natural-number fact the
binary64 test decides. Capacity tests are stated for any capacity term `k`
denoting `C < 2^31`; `test_*_c` and `test_*_c256` instantiate `k` with `v16`
and `v16 add 256`. -/

/-- `eq v10 0`. -/
theorem test_gen_zero (hi : i < 2 ^ 30) :
    F64.test .eq ((SymE.var 10).eval (loopVal rest T p i c tok ptok next)) (litZero.eval (loopVal rest T p i c tok ptok next)) =
      decide (i = 0) :=
  test_eq_eval eval_v10 eval_litZero (by omega) (by decide)

/-- `eq (v10 add 1) 0`. -/
theorem test_gen1_zero (hi : i < 2 ^ 30) :
    F64.test .eq (gen1.eval (loopVal rest T p i c tok ptok next)) (litZero.eval (loopVal rest T p i c tok ptok next)) = false := by
  rw [test_eq_eval (eval_gen1 hi) eval_litZero (by omega) (by decide)]
  exact decide_eq_false (by omega)

/-- `eq 248044 a` for a token term `a`. -/
theorem test_eos {ν : Nat → F64} {a : SymE} {t : Nat} (ha : a.eval ν = F64.ofNat t) (ht : t < 2 ^ 32) :
    F64.test .eq (litEos.eval ν) (a.eval ν) = decide (t = 248044) := by
  rw [test_eq_eval eval_litEos ha (by decide) (by omega)]
  exact Bool.eq_iff_iff.mpr (by simp only [decide_eq_true_eq]; omega)

/-- `eq 248044 v14`. -/
theorem test_eos_tok (ht : tok < 2 ^ 32) :
    F64.test .eq (litEos.eval (loopVal rest T p i c tok ptok next)) ((SymE.var 14).eval (loopVal rest T p i c tok ptok next)) =
      decide (tok = 248044) :=
  test_eos eval_v14 ht

/-- `eq 248044 v17`. -/
theorem test_eos_next (ht : next < 2 ^ 32) :
    F64.test .eq (litEos.eval (loopVal rest T p i c tok ptok next)) ((SymE.var 17).eval (loopVal rest T p i c tok ptok next)) =
      decide (next = 248044) :=
  test_eos eval_v17 ht

/-- `eq (((v10 add 1) sub 1) rem 256) 0`. -/
theorem test_gen1Prev_rem (hi : i < 2 ^ 30) :
    F64.test .eq ((SymE.bin .rem gen1Prev lit256).eval (loopVal rest T p i c tok ptok next))
      (litZero.eval (loopVal rest T p i c tok ptok next)) = decide (i % 256 = 0) :=
  test_eq_eval (eval_gen1Prev_rem hi) eval_litZero (by omega) (by decide)

/-- `eq ((((v10 add 1) add 1) sub 1) rem 256) 0`. -/
theorem test_gen2Prev_rem (hi : i < 2 ^ 30) :
    F64.test .eq ((SymE.bin .rem gen2Prev lit256).eval (loopVal rest T p i c tok ptok next))
      (litZero.eval (loopVal rest T p i c tok ptok next)) = decide ((i + 1) % 256 = 0) :=
  test_eq_eval (eval_gen2Prev_rem hi) eval_litZero (by omega) (by decide)

/-- `lt ((v10 add 1) add 1) v0`. -/
theorem test_gen2_budget (hi : i < 2 ^ 30) (hT : T < 2 ^ 30) :
    F64.test .lt (gen2.eval (loopVal rest T p i c tok ptok next)) ((SymE.var 0).eval (loopVal rest T p i c tok ptok next)) =
      decide (i + 2 < T) :=
  test_lt_eval (eval_gen2 hi) eval_v0 (by omega) (by omega)

/-- `lt int32(v9) 0`. -/
theorem test_off32_neg (hp : p < 2 ^ 30) :
    F64.test .lt (off32.eval (loopVal rest T p i c tok ptok next)) (litZero.eval (loopVal rest T p i c tok ptok next)) = false := by
  rw [test_lt_eval (eval_off32 hp) eval_litZero (by omega) (by decide)]
  exact decide_eq_false (by omega)

/-- `lt int32(v9 add 1) 0`. -/
theorem test_off1I32_neg (hp : p < 2 ^ 30) :
    F64.test .lt (off1I32.eval (loopVal rest T p i c tok ptok next)) (litZero.eval (loopVal rest T p i c tok ptok next)) = false := by
  rw [test_lt_eval (eval_off1I32 hp) eval_litZero (by omega) (by decide)]
  exact decide_eq_false (by omega)

/-- `lt 0 int32(v9)`. -/
theorem test_zero_off32 (hp : p < 2 ^ 30) :
    F64.test .lt (litZero.eval (loopVal rest T p i c tok ptok next)) (off32.eval (loopVal rest T p i c tok ptok next)) =
      decide (0 < p) :=
  test_lt_eval eval_litZero (eval_off32 hp) (by decide) (by omega)

/-- `lt 0 int32(v9 add 1)`. -/
theorem test_zero_off1I32 (hp : p < 2 ^ 30) :
    F64.test .lt (litZero.eval (loopVal rest T p i c tok ptok next)) (off1I32.eval (loopVal rest T p i c tok ptok next)) = true := by
  rw [test_lt_eval eval_litZero (eval_off1I32 hp) (by decide) (by omega)]
  exact decide_eq_true (by omega)

/-- `lt int32(v9 add 1) int32(v9)`. -/
theorem test_off1I32_off32 (hp : p < 2 ^ 30) :
    F64.test .lt (off1I32.eval (loopVal rest T p i c tok ptok next)) (off32.eval (loopVal rest T p i c tok ptok next)) = false := by
  rw [test_lt_eval (eval_off1I32 hp) (eval_off32 hp) (by omega) (by omega)]
  exact decide_eq_false (by omega)

/-- `eq 1 (int32(v9 add 1) sub int32(v9))`. -/
theorem test_one_offDelta (hp : p < 2 ^ 30) :
    F64.test .eq (litOne.eval (loopVal rest T p i c tok ptok next))
      ((SymE.bin .sub off1I32 off32).eval (loopVal rest T p i c tok ptok next)) = true := by
  rw [test_eq_eval eval_litOne (eval_offDelta hp) (by decide) (by decide)]
  rfl

/-- `eq (v9 rem 256) 0`. -/
theorem test_off_rem (hp : p < 2 ^ 30) :
    F64.test .eq ((SymE.bin .rem (.var 9) lit256).eval (loopVal rest T p i c tok ptok next))
      (litZero.eval (loopVal rest T p i c tok ptok next)) = decide (p % 256 = 0) :=
  test_eq_eval (eval_off_rem hp) eval_litZero (by omega) (by decide)

/-! #### Capacity tests for a capacity term `k` with value `C` -/

/-- `lt k (v9 add 1)`. -/
theorem test_cap_off1 {k : SymE} {C : Nat} (hk : k.eval (loopVal rest T p i c tok ptok next) = F64.ofNat C)
    (hC : C < 2 ^ 31) (hp : p < 2 ^ 30) :
    F64.test .lt (k.eval (loopVal rest T p i c tok ptok next)) (off1.eval (loopVal rest T p i c tok ptok next)) =
      decide (C < p + 1) :=
  test_lt_eval hk (eval_off1 hp) (by omega) (by omega)

/-- `lt int32(v9) k`. -/
theorem test_off32_cap {k : SymE} {C : Nat} (hk : k.eval (loopVal rest T p i c tok ptok next) = F64.ofNat C)
    (hC : C < 2 ^ 31) (hp : p < 2 ^ 30) :
    F64.test .lt (off32.eval (loopVal rest T p i c tok ptok next)) (k.eval (loopVal rest T p i c tok ptok next)) =
      decide (p < C) :=
  test_lt_eval (eval_off32 hp) hk (by omega) (by omega)

/-- `lt int32(v9 add 1) k`. -/
theorem test_off1I32_cap {k : SymE} {C : Nat} (hk : k.eval (loopVal rest T p i c tok ptok next) = F64.ofNat C)
    (hC : C < 2 ^ 31) (hp : p < 2 ^ 30) :
    F64.test .lt (off1I32.eval (loopVal rest T p i c tok ptok next)) (k.eval (loopVal rest T p i c tok ptok next)) =
      decide (p + 1 < C) :=
  test_lt_eval (eval_off1I32 hp) hk (by omega) (by omega)

/-- `lt 0 k`. -/
theorem test_zero_cap {k : SymE} {C : Nat} (hk : k.eval (loopVal rest T p i c tok ptok next) = F64.ofNat C)
    (hC : C < 2 ^ 31) :
    F64.test .lt (litZero.eval (loopVal rest T p i c tok ptok next)) (k.eval (loopVal rest T p i c tok ptok next)) =
      decide (0 < C) :=
  test_lt_eval eval_litZero hk (by decide) (by omega)

/-- `eq (int32(v9 add 1) sub 0) k`. -/
theorem test_off1I32_sub0_cap {k : SymE} {C : Nat} (hk : k.eval (loopVal rest T p i c tok ptok next) = F64.ofNat C)
    (hC : C < 2 ^ 31) (hp : p < 2 ^ 30) :
    F64.test .eq ((SymE.bin .sub off1I32 litZero).eval (loopVal rest T p i c tok ptok next))
      (k.eval (loopVal rest T p i c tok ptok next)) = decide (p + 1 = C) :=
  test_eq_eval (eval_off1I32_sub0 hp) hk (by omega) (by omega)

/-- `eq (k sub 0) k`. -/
theorem test_cap_sub0 {k : SymE} {C : Nat} (hk : k.eval (loopVal rest T p i c tok ptok next) = F64.ofNat C)
    (hC : C < 2 ^ 31) :
    F64.test .eq ((SymE.bin .sub k litZero).eval (loopVal rest T p i c tok ptok next))
      (k.eval (loopVal rest T p i c tok ptok next)) = true := by
  rw [test_eq_eval (eval_sub hk eval_litZero (by omega) (Nat.zero_le C)) hk (by omega) (by omega)]
  exact decide_eq_true (Nat.sub_zero C)

/-- `eq 1 (k sub int32(v9))`; holds for any order of `p` and `C`. -/
theorem test_one_cap_sub_off32 {k : SymE} {C : Nat} (hk : k.eval (loopVal rest T p i c tok ptok next) = F64.ofNat C)
    (hC : C < 2 ^ 31) (hp : p < 2 ^ 30) :
    F64.test .eq (litOne.eval (loopVal rest T p i c tok ptok next))
      ((SymE.bin .sub k off32).eval (loopVal rest T p i c tok ptok next)) = decide (C = p + 1) := by
  change F64.test .eq (F64.ofNat 1) (F64.bin .sub (k.eval _) (off32.eval _)) = _
  rw [hk, eval_off32 hp]
  exact test_eq_one_sub C p (by omega) (by omega)

/-- `lt k int32(v9)`. -/
theorem test_cap_off32 {k : SymE} {C : Nat} (hk : k.eval (loopVal rest T p i c tok ptok next) = F64.ofNat C)
    (hC : C < 2 ^ 31) (hp : p < 2 ^ 30) :
    F64.test .lt (k.eval (loopVal rest T p i c tok ptok next)) (off32.eval (loopVal rest T p i c tok ptok next)) =
      decide (C < p) :=
  test_lt_eval hk (eval_off32 hp) (by omega) (by omega)

/-- `lt k 0`. -/
theorem test_cap_neg {k : SymE} {C : Nat} (hk : k.eval (loopVal rest T p i c tok ptok next) = F64.ofNat C)
    (hC : C < 2 ^ 31) :
    F64.test .lt (k.eval (loopVal rest T p i c tok ptok next)) (litZero.eval (loopVal rest T p i c tok ptok next)) = false := by
  rw [test_lt_eval hk eval_litZero (by omega) (by decide)]
  exact decide_eq_false (by omega)

/-! #### Capacity `v16` -/

theorem test_cap_off1_c (hc : c < 2 ^ 30) (hp : p < 2 ^ 30) :
    F64.test .lt ((SymE.var 16).eval (loopVal rest T p i c tok ptok next)) (off1.eval (loopVal rest T p i c tok ptok next)) =
      decide (c < p + 1) :=
  test_cap_off1 eval_v16 (by omega) hp

theorem test_off32_cap_c (hc : c < 2 ^ 30) (hp : p < 2 ^ 30) :
    F64.test .lt (off32.eval (loopVal rest T p i c tok ptok next)) ((SymE.var 16).eval (loopVal rest T p i c tok ptok next)) =
      decide (p < c) :=
  test_off32_cap eval_v16 (by omega) hp

theorem test_off1I32_cap_c (hc : c < 2 ^ 30) (hp : p < 2 ^ 30) :
    F64.test .lt (off1I32.eval (loopVal rest T p i c tok ptok next)) ((SymE.var 16).eval (loopVal rest T p i c tok ptok next)) =
      decide (p + 1 < c) :=
  test_off1I32_cap eval_v16 (by omega) hp

theorem test_zero_cap_c (hc : c < 2 ^ 30) :
    F64.test .lt (litZero.eval (loopVal rest T p i c tok ptok next)) ((SymE.var 16).eval (loopVal rest T p i c tok ptok next)) =
      decide (0 < c) :=
  test_zero_cap eval_v16 (by omega)

theorem test_off1I32_sub0_cap_c (hc : c < 2 ^ 30) (hp : p < 2 ^ 30) :
    F64.test .eq ((SymE.bin .sub off1I32 litZero).eval (loopVal rest T p i c tok ptok next))
      ((SymE.var 16).eval (loopVal rest T p i c tok ptok next)) = decide (p + 1 = c) :=
  test_off1I32_sub0_cap eval_v16 (by omega) hp

theorem test_cap_sub0_c (hc : c < 2 ^ 30) :
    F64.test .eq ((SymE.bin .sub (.var 16) litZero).eval (loopVal rest T p i c tok ptok next))
      ((SymE.var 16).eval (loopVal rest T p i c tok ptok next)) = true :=
  test_cap_sub0 eval_v16 (by omega)

theorem test_one_cap_sub_off32_c (hc : c < 2 ^ 30) (hp : p < 2 ^ 30) :
    F64.test .eq (litOne.eval (loopVal rest T p i c tok ptok next))
      ((SymE.bin .sub (.var 16) off32).eval (loopVal rest T p i c tok ptok next)) = decide (c = p + 1) :=
  test_one_cap_sub_off32 eval_v16 (by omega) hp

theorem test_cap_off32_c (hc : c < 2 ^ 30) (hp : p < 2 ^ 30) :
    F64.test .lt ((SymE.var 16).eval (loopVal rest T p i c tok ptok next)) (off32.eval (loopVal rest T p i c tok ptok next)) =
      decide (c < p) :=
  test_cap_off32 eval_v16 (by omega) hp

theorem test_cap_neg_c (hc : c < 2 ^ 30) :
    F64.test .lt ((SymE.var 16).eval (loopVal rest T p i c tok ptok next)) (litZero.eval (loopVal rest T p i c tok ptok next)) =
      false :=
  test_cap_neg eval_v16 (by omega)

/-! #### Capacity `v16 add 256` -/

theorem test_cap_off1_c256 (hc : c < 2 ^ 30) (hp : p < 2 ^ 30) :
    F64.test .lt (capGrow.eval (loopVal rest T p i c tok ptok next)) (off1.eval (loopVal rest T p i c tok ptok next)) =
      decide (c + 256 < p + 1) :=
  test_cap_off1 (eval_capGrow hc) (by omega) hp

theorem test_off32_cap_c256 (hc : c < 2 ^ 30) (hp : p < 2 ^ 30) :
    F64.test .lt (off32.eval (loopVal rest T p i c tok ptok next)) (capGrow.eval (loopVal rest T p i c tok ptok next)) =
      decide (p < c + 256) :=
  test_off32_cap (eval_capGrow hc) (by omega) hp

theorem test_off1I32_cap_c256 (hc : c < 2 ^ 30) (hp : p < 2 ^ 30) :
    F64.test .lt (off1I32.eval (loopVal rest T p i c tok ptok next)) (capGrow.eval (loopVal rest T p i c tok ptok next)) =
      decide (p + 1 < c + 256) :=
  test_off1I32_cap (eval_capGrow hc) (by omega) hp

theorem test_zero_cap_c256 (hc : c < 2 ^ 30) :
    F64.test .lt (litZero.eval (loopVal rest T p i c tok ptok next)) (capGrow.eval (loopVal rest T p i c tok ptok next)) =
      true := by
  rw [test_zero_cap (eval_capGrow hc) (by omega)]
  exact decide_eq_true (by omega)

theorem test_off1I32_sub0_cap_c256 (hc : c < 2 ^ 30) (hp : p < 2 ^ 30) :
    F64.test .eq ((SymE.bin .sub off1I32 litZero).eval (loopVal rest T p i c tok ptok next))
      (capGrow.eval (loopVal rest T p i c tok ptok next)) = decide (p + 1 = c + 256) :=
  test_off1I32_sub0_cap (eval_capGrow hc) (by omega) hp

theorem test_cap_sub0_c256 (hc : c < 2 ^ 30) :
    F64.test .eq ((SymE.bin .sub capGrow litZero).eval (loopVal rest T p i c tok ptok next))
      (capGrow.eval (loopVal rest T p i c tok ptok next)) = true :=
  test_cap_sub0 (eval_capGrow hc) (by omega)

theorem test_one_cap_sub_off32_c256 (hc : c < 2 ^ 30) (hp : p < 2 ^ 30) :
    F64.test .eq (litOne.eval (loopVal rest T p i c tok ptok next))
      ((SymE.bin .sub capGrow off32).eval (loopVal rest T p i c tok ptok next)) = decide (c + 256 = p + 1) :=
  test_one_cap_sub_off32 (eval_capGrow hc) (by omega) hp

theorem test_cap_off32_c256 (hc : c < 2 ^ 30) (hp : p < 2 ^ 30) :
    F64.test .lt (capGrow.eval (loopVal rest T p i c tok ptok next)) (off32.eval (loopVal rest T p i c tok ptok next)) =
      decide (c + 256 < p) :=
  test_cap_off32 (eval_capGrow hc) (by omega) hp

theorem test_cap_neg_c256 (hc : c < 2 ^ 30) :
    F64.test .lt (capGrow.eval (loopVal rest T p i c tok ptok next)) (litZero.eval (loopVal rest T p i c tok ptok next)) =
      false :=
  test_cap_neg (eval_capGrow hc) (by omega)

end

/-! ## One iteration's substitution -/

/-- The template's post-body substitution: offset and counters advance, `v14`
takes the next read token `w` and `v15` the current one; the capacity grows
by 256 when `grow`. -/
def loopTheta (grow : Bool) (w : Nat) : Nat → SymE
  | 9 => off1
  | 10 => gen1
  | 11 => gen1
  | 12 => .bin .add gen1Prev litOne
  | 13 => gen1Prev
  | 14 => .var w
  | 15 => .var 14
  | 16 => bif grow then capGrow else .var 16
  | j => .var j

abbrev thetaOrd (w : Nat) : Nat → SymE := loopTheta false w
abbrev thetaGrow (w : Nat) : Nat → SymE := loopTheta true w

section
variable {rest : Nat → F64} {T p i c tok ptok next : Nat}

/-- One iteration maps the loop valuation to the next one; the token read
into `v14` is whatever `w` denotes. -/
theorem loopTheta_step (grow : Bool) (w tok' : Nat) (hp : p < 2 ^ 30) (hi : i < 2 ^ 30) (hc : c < 2 ^ 30)
    (hw : loopVal rest T p i c tok ptok next w = F64.ofNat tok') :
    (fun j => (loopTheta grow w j).eval (loopVal rest T p i c tok ptok next)) =
      loopVal rest T (p + 1) (i + 1) (bif grow then c + 256 else c) tok' tok next := by
  funext j
  match j with
  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 => rfl
  | 9 => exact eval_off1 hp
  | 10 => exact eval_gen1 hi
  | 11 => exact eval_gen1 hi
  | 12 => exact eval_add (m := i) (n := 1) (eval_gen1Prev hi) eval_litOne (by omega)
  | 13 => exact eval_gen1Prev hi
  | 14 => exact hw
  | 15 => rfl
  | 16 => cases grow
          · rfl
          · exact eval_capGrow hc
  | 17 => rfl
  | _ + 18 => rfl

theorem thetaOrd_step (w tok' : Nat) (hp : p < 2 ^ 30) (hi : i < 2 ^ 30) (hc : c < 2 ^ 30)
    (hw : loopVal rest T p i c tok ptok next w = F64.ofNat tok') :
    (fun j => (thetaOrd w j).eval (loopVal rest T p i c tok ptok next)) =
      loopVal rest T (p + 1) (i + 1) c tok' tok next :=
  loopTheta_step false w tok' hp hi hc hw

theorem thetaGrow_step (w tok' : Nat) (hp : p < 2 ^ 30) (hi : i < 2 ^ 30) (hc : c < 2 ^ 30)
    (hw : loopVal rest T p i c tok ptok next w = F64.ofNat tok') :
    (fun j => (thetaGrow w j).eval (loopVal rest T p i c tok ptok next)) =
      loopVal rest T (p + 1) (i + 1) (c + 256) tok' tok next :=
  loopTheta_step true w tok' hp hi hc hw

/-- The next token is a fresh variable beyond the template's own. -/
theorem loopTheta_step_fresh (grow : Bool) (w tok' : Nat) (hp : p < 2 ^ 30) (hi : i < 2 ^ 30)
    (hc : c < 2 ^ 30) (hfresh : 17 < w) (hw : rest w = F64.ofNat tok') :
    (fun j => (loopTheta grow w j).eval (loopVal rest T p i c tok ptok next)) =
      loopVal rest T (p + 1) (i + 1) (bif grow then c + 256 else c) tok' tok next :=
  loopTheta_step grow w tok' hp hi hc ((loopVal_rest w (by omega) (.inr hfresh)).trans hw)

/-- The next token is the template's look-ahead `v17`. -/
theorem loopTheta_step_next (grow : Bool) (hp : p < 2 ^ 30) (hi : i < 2 ^ 30) (hc : c < 2 ^ 30) :
    (fun j => (loopTheta grow 17 j).eval (loopVal rest T p i c tok ptok next)) =
      loopVal rest T (p + 1) (i + 1) (bif grow then c + 256 else c) next tok next :=
  loopTheta_step grow 17 next hp hi hc rfl

/-- Substituted terms denote the original ones at the next valuation. -/
theorem eval_loopTheta (grow : Bool) (w tok' : Nat) (hp : p < 2 ^ 30) (hi : i < 2 ^ 30) (hc : c < 2 ^ 30)
    (hw : loopVal rest T p i c tok ptok next w = F64.ofNat tok') (e : SymE) :
    (e.subst (loopTheta grow w)).eval (loopVal rest T p i c tok ptok next) =
      e.eval (loopVal rest T (p + 1) (i + 1) (bif grow then c + 256 else c) tok' tok next) := by
  rw [SymE.eval_subst, loopTheta_step grow w tok' hp hi hc hw]

/-- The substituted oracle is correct exactly when the template oracle is correct
at the next valuation. -/
theorem good_loopTheta (grow : Bool) (w tok' : Nat) (hp : p < 2 ^ 30) (hi : i < 2 ^ 30) (hc : c < 2 ^ 30)
    (hw : loopVal rest T p i c tok ptok next w = F64.ofNat tok') (o : List Ans) :
    Good (loopVal rest T p i c tok ptok next) (o.map (Ans.subst (loopTheta grow w))) ↔
      Good (loopVal rest T (p + 1) (i + 1) (bif grow then c + 256 else c) tok' tok next) o := by
  rw [good_subst, loopTheta_step grow w tok' hp hi hc hw]

end

end Host.Ts.Sim
