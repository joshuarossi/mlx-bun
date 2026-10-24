import host.sim.LinExact
namespace Host.Ts.Sim.Lin
open Host.Ts

/-! # Rounding a quotient of integers to an integer

`Math.floor(a / m)`, `Math.trunc(a / m)` and `Math.ceil(a / m)` for integers `0 ≤ a < 2^53` and
`0 < m < 2^53` are the integer quotients `⌊a/m⌋` and `⌈a/m⌉`, although `a / m` is rounded to
binary64 first: the rounded quotient `m'·2^-K` has a 53-bit significand `m' ∈ [2^52, 2^53]`,
so `⌊m'/2^K⌋ = ⌊a/m⌋` (rounding up never reaches the next integer: that would need
`2^(K+1) ≤ m`, hence `m' ≤ a/2 < 2^52`), and a non-integral quotient stays non-integral
(`m' % 2^K ≠ 0`). `F64.odd` strips `log2 (m' xor (m' - 1))` trailing zero bits, a power of two
dividing `m'` (`xor_pred`). -/

/-! ## Bits -/

theorem xor_odd (u : Nat) : (2 * u + 1) ^^^ (2 * u) = 1 := by
  apply Nat.eq_of_testBit_eq
  intro i
  cases i with
  | zero =>
    simp only [Nat.testBit_zero]
    have h1 : (2 * u + 1) % 2 = 1 := by omega
    have h2 : (2 * u) % 2 = 0 := by omega
    simp [h1, h2]
  | succ i =>
    rw [Nat.testBit_xor, Nat.testBit_succ, Nat.testBit_succ, Nat.testBit_succ]
    have h1 : (2 * u + 1) / 2 = u := by omega
    have h2 : (2 * u) / 2 = u := by omega
    rw [h1, h2]
    simp

theorem xor_even (a b : Nat) : (2 * a) ^^^ (2 * b + 1) = 2 * (a ^^^ b) + 1 := by
  apply Nat.eq_of_testBit_eq
  intro i
  cases i with
  | zero =>
    simp only [Nat.testBit_zero]
    have h1 : (2 * a) % 2 = 0 := by omega
    have h2 : (2 * b + 1) % 2 = 1 := by omega
    have h3 : (2 * (a ^^^ b) + 1) % 2 = 1 := by omega
    simp [h1, h2, h3]
  | succ i =>
    rw [Nat.testBit_xor, Nat.testBit_succ, Nat.testBit_succ, Nat.testBit_succ]
    have h1 : (2 * a) / 2 = a := by omega
    have h2 : (2 * b + 1) / 2 = b := by omega
    have h3 : (2 * (a ^^^ b) + 1) / 2 = a ^^^ b := by omega
    rw [h1, h2, h3, Nat.testBit_xor]

/-- `m xor (m - 1)` is `2^(t+1) - 1` for a power `2^t` dividing `m`. -/
theorem xor_pred : ∀ (m : Nat), 0 < m → ∃ t, 2 ^ t ∣ m ∧ m ^^^ (m - 1) = 2 ^ (t + 1) - 1 := by
  intro m
  induction m using Nat.strongRecOn with
  | ind m ih =>
    intro hm
    rcases Nat.mod_two_eq_zero_or_one m with h | h
    · obtain ⟨u, rfl⟩ : ∃ u, m = 2 * u := ⟨m / 2, by omega⟩
      have hu : 0 < u := by omega
      obtain ⟨t, ht, hx⟩ := ih u (by omega) hu
      refine ⟨t + 1, ?_, ?_⟩
      · rw [Nat.pow_succ, Nat.mul_comm]; exact Nat.mul_dvd_mul_left 2 ht
      · rw [show 2 * u - 1 = 2 * (u - 1) + 1 by omega, xor_even, hx]
        have : 1 ≤ 2 ^ (t + 1) := Nat.one_le_two_pow
        rw [Nat.pow_succ 2 (t + 1)]; omega
    · obtain ⟨u, rfl⟩ : ∃ u, m = 2 * u + 1 := ⟨m / 2, by omega⟩
      refine ⟨0, by simp, ?_⟩
      rw [show 2 * u + 1 - 1 = 2 * u by omega, xor_odd]

theorem log2_pow_sub_one (t : Nat) : Nat.log2 (2 ^ (t + 1) - 1) = t := by
  have h1 : 2 ^ t ≤ 2 ^ (t + 1) - 1 := by rw [Nat.pow_succ]; have := Nat.one_le_two_pow (n := t); omega
  have h0 : 2 ^ (t + 1) - 1 ≠ 0 := by have := Nat.one_le_two_pow (n := t); omega
  have a := (Nat.le_log2 h0).mpr h1
  have b := (Nat.log2_lt h0).mpr (show 2 ^ (t + 1) - 1 < 2 ^ (t + 1) by have := Nat.one_le_two_pow (n := t + 1); omega)
  omega

/-- `F64.odd` strips a power of two that divides the significand. -/
theorem tz_dvd (m : Nat) (hm : 0 < m) : 2 ^ Nat.log2 (Nat.xor m (Nat.sub m 1)) ∣ m := by
  obtain ⟨t, ht, hx⟩ := xor_pred m hm
  change 2 ^ Nat.log2 (m ^^^ (m - 1)) ∣ m
  rw [hx, log2_pow_sub_one]; exact ht

/-! ## `odd` forms with a negative exponent -/

theorem ilt_eq (a b : Int) : F64.ilt a b = decide (a < b) := by
  apply Bool.eq_iff_iff.mpr
  cases a <;> cases b <;> simp [F64.ilt, Nat.blt_eq, Int.negSucc_eq] <;> omega

theorem ile_eq (a b : Int) : F64.ile a b = decide (a ≤ b) := by
  unfold F64.ile; rw [ilt_eq]
  apply Bool.eq_iff_iff.mpr
  simp only [Bool.not_eq_true', decide_eq_false_iff_not, decide_eq_true_eq]
  omega

/-- The value of `odd false m (-K)` (`K ≥ 1`, `m < 2^54`), when integral, is `m / 2^K`; otherwise
its exponent is negative and its significand over `2^-e` is `m / 2^K`. -/
theorem odd_cases (m K : Nat) (hm : 0 < m) (hK : 1 ≤ K) (hm' : m < 2 ^ 54) :
    (2 ^ K ∣ m ∧ F64.odd false m (0 - (K : Int)) = .fin false (m / 2 ^ K) 0 ∧ 0 < m / 2 ^ K) ∨
    (∃ m' j, F64.odd false m (0 - (K : Int)) = .fin false m' (.negSucc j) ∧ m' / 2 ^ (j + 1) = m / 2 ^ K) := by
  have htz := tz_dvd m hm
  generalize ht : Nat.log2 (Nat.xor m (Nat.sub m 1)) = tz at htz
  have hodd : F64.odd false m (0 - (K : Int)) =
      match Int.add (0 - (K : Int)) (Int.ofNat tz) with
      | .ofNat k => let v := Nat.shiftLeft (Nat.shiftRight m tz) k;
          bif Nat.blt v F64.small then .fin false v 0 else .fin false (Nat.shiftRight m tz) (Int.add (0 - (K : Int)) (Int.ofNat tz))
      | .negSucc _ => .fin false (Nat.shiftRight m tz) (Int.add (0 - (K : Int)) (Int.ofNat tz)) := by
    unfold F64.odd; rw [ht]; rfl
  obtain ⟨u, hu⟩ := htz
  have hpos : 0 < 2 ^ tz := Nat.two_pow_pos tz
  have hsr : Nat.shiftRight m tz = u := by
    change m >>> tz = u
    rw [Nat.shiftRight_eq_div_pow, hu, Nat.mul_div_cancel_left _ hpos]
  by_cases hK' : K ≤ tz
  · left
    have he : Int.add (0 - (K : Int)) (Int.ofNat tz) = Int.ofNat (tz - K) := by
      change 0 - (K : Int) + (tz : Int) = ((tz - K : Nat) : Int); omega
    have hpow : 2 ^ tz = 2 ^ K * 2 ^ (tz - K) := by rw [← Nat.pow_add]; congr 1; omega
    have hdiv : m / 2 ^ K = u * 2 ^ (tz - K) := by
      rw [hu, hpow, Nat.mul_assoc, Nat.mul_div_cancel_left _ (Nat.two_pow_pos K), Nat.mul_comm]
    have hdvd : 2 ^ K ∣ m := ⟨2 ^ (tz - K) * u, by rw [hu, hpow, Nat.mul_assoc]⟩
    have hlt : m / 2 ^ K < 2 ^ 53 := by
      have : 2 ≤ 2 ^ K := by
        have := Nat.pow_le_pow_right (show 0 < 2 by omega) hK; simpa using this
      have := Nat.div_le_div_left this (show 0 < 2 by omega) (a := m)
      omega
    have hv : Nat.shiftLeft (Nat.shiftRight m tz) (tz - K) = m / 2 ^ K := by
      rw [hsr, hdiv]; exact Nat.shiftLeft_eq u (tz - K)
    have hs : Nat.blt (m / 2 ^ K) F64.small = true := Nat.blt_eq.mpr (by change _ < 2 ^ 53; exact hlt)
    refine ⟨hdvd, ?_, ?_⟩
    · rw [hodd, he]; dsimp only; rw [hv, hs]; rfl
    · exact Nat.div_pos (Nat.le_of_dvd hm hdvd) (Nat.two_pow_pos K)
  · right
    have he : Int.add (0 - (K : Int)) (Int.ofNat tz) = Int.negSucc (K - tz - 1) := by
      change 0 - (K : Int) + (tz : Int) = Int.negSucc (K - tz - 1)
      rw [Int.negSucc_eq]; omega
    refine ⟨u, K - tz - 1, ?_, ?_⟩
    · rw [hodd, he, hsr]
    · rw [hu, show K - tz - 1 + 1 = K - tz by omega]
      conv => rhs; rw [show K = tz + (K - tz) by omega, Nat.pow_add]
      rw [Nat.mul_div_mul_left _ _ hpos]

end Host.Ts.Sim.Lin
namespace Host.Ts.Sim.Lin

/-! ## The rounded significand's quotient -/

/-- `M · Q0 + R0 = A · P` with `Q0 ≥ 2^52`, `A < 2^53`: the scale `2P` exceeds `M`. -/
theorem scale_gt (A M P Q0 R0 : Nat) (hA : A < 2 ^ 53) (hq1 : 2 ^ 52 ≤ Q0) (he : M * Q0 + R0 = A * P)
    (hP : 0 < P) (h2 : 2 * P ≤ M) : False := by
  have h1 : (2 * P) * Q0 ≤ M * Q0 := Nat.mul_le_mul_right Q0 h2
  have h3 : (2 * Q0) * P ≤ A * P := by
    have : (2 * P) * Q0 = (2 * Q0) * P := by grind
    omega
  have h4 := Nat.le_of_mul_le_mul_right h3 hP
  omega

/-- The quotient of the rounded significand `Q0` or `Q0 + 1` (`up`) by the scale `P` is
`A / M`, and is not exact when `A / M` is not. -/
theorem quot_core (A M P Q0 R0 : Nat) (hP : 0 < P) (hA : A < 2 ^ 53) (hq1 : 2 ^ 52 ≤ Q0)
    (he : M * Q0 + R0 = A * P) (hR : R0 < M) (up : Bool) (hup1 : up = true → M ≤ 2 * R0)
    (hup2 : up = false → 2 * R0 ≤ M) :
    (bif up then Q0 + 1 else Q0) / P = A / M ∧ (A % M ≠ 0 → (bif up then Q0 + 1 else Q0) % P ≠ 0) := by
  have hM : 0 < M := by omega
  obtain ⟨q, r, hA', hr⟩ : ∃ q r, A = M * q + r ∧ r < M := ⟨A / M, A % M, (Nat.div_add_mod A M).symm, Nat.mod_lt _ hM⟩
  have hq : A / M = q := by
    rw [hA', Nat.mul_comm, Nat.add_comm, Nat.add_mul_div_right _ _ hM, Nat.div_eq_of_lt hr, Nat.zero_add]
  have hrm : A % M = r := by rw [hA', Nat.mul_comm, Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hr]
  have eq1 : A * P = M * (q * P) + r * P := by rw [hA']; grind
  have eq2 : M * ((q + 1) * P) = M * (q * P) + M * P := by grind
  have hrP : r * P < M * P := Nat.mul_lt_mul_of_pos_right hr hP
  have hQhi : Q0 < (q + 1) * P := by
    have : M * Q0 < M * ((q + 1) * P) := by omega
    exact Nat.lt_of_mul_lt_mul_left this
  have hQlo : q * P ≤ Q0 := by
    have : M * (q * P) < M * (Q0 + 1) := by
      have : M * (Q0 + 1) = M * Q0 + M := by grind
      omega
    have := Nat.lt_of_mul_lt_mul_left this
    omega
  have hdiv0 : Q0 / P = q := Nat.div_eq_of_lt_le (by rw [Nat.mul_comm] at hQlo ⊢; grind) (by grind)
  -- rounding up never reaches the next multiple of `P`
  have hup : up = true → Q0 + 1 < (q + 1) * P := by
    intro hu
    have h1 := hup1 hu
    rcases Nat.lt_or_ge (Q0 + 1) ((q + 1) * P) with h | h
    · exact h
    · exfalso
      have hQ1 : Q0 + 1 = (q + 1) * P := by omega
      obtain ⟨d, rfl⟩ : ∃ d, M = r + d := ⟨M - r, by omega⟩
      have hd : 1 ≤ d := by omega
      have e3 : (r + d) * P = r * P + d * P := by grind
      have e4 : (r + d) * (Q0 + 1) = (r + d) * Q0 + (r + d) := by grind
      have e5 : (r + d) * (Q0 + 1) = (r + d) * ((q + 1) * P) := by rw [hQ1]
      have e6 : d * P = r + d - R0 := by omega
      have e7 : P ≤ d * P := Nat.le_mul_of_pos_left P (by omega)
      exact scale_gt A (r + d) P Q0 R0 hA hq1 he hP (by omega)
  refine ⟨?_, ?_⟩
  · rw [hq]
    cases hu : up
    · simpa using hdiv0
    · simp only [Bool.cond_true]
      exact Nat.div_eq_of_lt_le (by rw [Nat.mul_comm] at hQlo ⊢; grind) (by have := hup hu; grind)
  · intro hnd
    rw [hrm] at hnd
    cases hu : up
    · simp only [Bool.cond_false]
      intro h0
      obtain ⟨w, hw⟩ := Nat.dvd_of_mod_eq_zero h0
      -- `Q0 = P · w` gives `w = q` and `R0 = r · P ≥ P`, so rounding would have gone up
      have hw' : w = q := by
        have : P * w / P = q := by rw [← hw]; exact hdiv0
        rwa [Nat.mul_div_cancel_left _ hP] at this
      subst hw'
      have : R0 = r * P := by
        have : M * (P * w) = M * (w * P) := by rw [Nat.mul_comm P w]
        have he' := he
        rw [hw] at he'
        omega
      have e7 : P ≤ r * P := Nat.le_mul_of_pos_left P (by omega)
      exact scale_gt A M P Q0 R0 hA hq1 he hP (by have := hup2 hu; omega)
    · simp only [Bool.cond_true]
      have h1 := hup hu
      have : (Q0 + 1) % P = Q0 + 1 - q * P := by
        have : Q0 + 1 = (Q0 + 1 - q * P) + q * P := by omega
        rw [this, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt (by grind)]
        omega
      rw [this]
      omega

theorem pow2_nat (k : Nat) : F64.pow2 (k : Int) = (2 ^ k, 1) := rfl

/-- `round`'s rounding direction for the significand `Q0` with remainder `R0` of `M`. -/
def upB (M Q0 R0 : Nat) : Bool :=
  bif Nat.blt M (2 * R0) then true else bif Nat.beq (2 * R0) M then Q0 % 2 == 1 else false

theorem upB_true {M Q0 R0 : Nat} (h : upB M Q0 R0 = true) : M ≤ 2 * R0 := by
  unfold upB at h
  cases h1 : Nat.blt M (2 * R0)
  · rw [h1, Bool.cond_false] at h
    cases h2 : Nat.beq (2 * R0) M
    · rw [h2, Bool.cond_false] at h; cases h
    · have := Nat.eq_of_beq_eq_true h2; omega
  · have := Nat.blt_eq.mp h1; omega

theorem upB_false {M Q0 R0 : Nat} (h : upB M Q0 R0 = false) : 2 * R0 ≤ M := by
  unfold upB at h
  cases h1 : Nat.blt M (2 * R0)
  · have : ¬ M < 2 * R0 := fun h' => by rw [Nat.blt_eq.mpr h'] at h1; cases h1
    omega
  · rw [h1, Bool.cond_true] at h; cases h

theorem round_tail (m K : Nat) (hm1 : 2 ^ 52 ≤ m) (hm2 : m ≤ 2 ^ 53) (hK : 1 ≤ K) :
    (bif Nat.beq m 0 then F64.zero false else
      bif F64.ile 1024 ((Nat.log2 m : Int) + (0 - (K : Int))) then F64.inf false else F64.norm false m (0 - (K : Int))) =
    F64.odd false m (0 - (K : Int)) := by
  have hm0 : m ≠ 0 := by omega
  have hb : Nat.beq m 0 = false := Bool.eq_false_iff.mpr (fun h => hm0 (Nat.eq_of_beq_eq_true h))
  have hl : Nat.log2 m < 54 := (Nat.log2_lt hm0).mpr (by omega)
  rw [hb, Bool.cond_false, ile_eq, decide_eq_false (by omega), Bool.cond_false]
  have he : (0 : Int) - (K : Int) = Int.negSucc (K - 1) := by rw [Int.negSucc_eq]; omega
  unfold F64.norm
  rw [hb, Bool.cond_false, he]

theorem cond_bounds (u : Bool) (Q : Nat) (h1 : 2 ^ 52 ≤ Q) (h2 : Q < 2 ^ 53) :
    2 ^ 52 ≤ (bif u then Q + 1 else Q) ∧ (bif u then Q + 1 else Q) ≤ 2 ^ 53 := by
  cases u <;> simp only [Bool.cond_true, Bool.cond_false] <;> omega

/-- `round` of `A / M` (`A % M ≠ 0` aside): the significand `⌊A·2^K/M⌋ ∈ [2^52, 2^53)`, rounded
by `upB`, at exponent `-K`. -/
theorem round_div (A M : Nat) (hA : 0 < A) (hA' : A < 2 ^ 53) (hM : 2 ≤ M) (hM' : M < 2 ^ 53) :
    ∃ K : Nat, 1 ≤ K ∧ 2 ^ 52 ≤ A * 2 ^ K / M ∧ A * 2 ^ K / M < 2 ^ 53 ∧
      F64.round F64.b64 false A M 0 =
        F64.odd false (bif upB M (A * 2 ^ K / M) (A * 2 ^ K % M) then A * 2 ^ K / M + 1 else A * 2 ^ K / M)
          (0 - (K : Int)) := by
  have hb : Nat.beq M 1 = false := Bool.eq_false_iff.mpr (fun h => by have := Nat.eq_of_beq_eq_true h; omega)
  have hA0 : A ≠ 0 := by omega
  have hM0 : M ≠ 0 := by omega
  have hMp : 0 < M := by omega
  have a1 : 2 ^ Nat.log2 A ≤ A := (Nat.le_log2 hA0).mp (Nat.le_refl _)
  have a2 : A < 2 ^ (Nat.log2 A + 1) := (Nat.log2_lt hA0).mp (Nat.lt_succ_self _)
  have a3 : Nat.log2 A < 53 := (Nat.log2_lt hA0).mpr hA'
  have b1 : 2 ^ Nat.log2 M ≤ M := (Nat.le_log2 hM0).mp (Nat.le_refl _)
  have b2 : M < 2 ^ (Nat.log2 M + 1) := (Nat.log2_lt hM0).mp (Nat.lt_succ_self _)
  have b3 : 1 ≤ Nat.log2 M := (Nat.le_log2 hM0).mpr (by simpa using hM)
  have b4 : Nat.log2 M < 53 := (Nat.log2_lt hM0).mpr hM'
  simp only [F64.round, F64.b64, hb, Bool.false_and, Bool.cond_false]
  generalize Nat.log2 A = LA at *
  generalize Nat.log2 M = LM at *
  have h53 : ((53 : Nat) : Int) - ((LA : Int) - (LM : Int)) = ((53 - LA + LM : Nat) : Int) := by omega
  rw [h53]
  simp only [pow2_nat, Nat.mul_one]
  have p0 : 2 ^ LA * 2 ^ (53 - LA + LM) = 2 ^ 52 * 2 ^ (LM + 1) := by
    rw [← Nat.pow_add, ← Nat.pow_add]; congr 1; omega
  have p1 : 2 ^ (LA + 1) * 2 ^ (53 - LA + LM - 1) = 2 ^ 53 * 2 ^ LM := by
    rw [← Nat.pow_add, ← Nat.pow_add]; congr 1; omega
  have p2 : 2 ^ (53 - LA + LM) = 2 * 2 ^ (53 - LA + LM - 1) := by
    rw [← Nat.pow_succ']; congr 1; omega
  have p3 : 2 ^ (LM + 1) = 2 * 2 ^ LM := Nat.pow_succ'
  by_cases hbig : 2 ^ 53 ≤ A * 2 ^ (53 - LA + LM) / M
  · have hb1 : Nat.ble (2 ^ 53) (A * 2 ^ (53 - LA + LM) / M) = true := Nat.ble_eq.mpr hbig
    have hk : ((53 - LA + LM : Nat) : Int) - 1 = ((53 - LA + LM - 1 : Nat) : Int) := by omega
    have hil : F64.ilt (0 - ((53 - LA + LM - 1 : Nat) : Int)) (-1074) = false := by
      rw [ilt_eq]; exact decide_eq_false (by omega)
    simp only [hb1, Bool.cond_true, hk, hil, Bool.cond_false, pow2_nat, Nat.mul_one]
    generalize 53 - LA + LM - 1 = K at *
    -- `2^53·M ≤ A·2^(K+1)` and `A·2^K < 2^(LA+1)·2^K = 2^53·2^LM ≤ 2^53·M`
    have q1 : 2 ^ 52 ≤ A * 2 ^ K / M := by
      have := (Nat.le_div_iff_mul_le hMp).mp hbig
      rw [p2] at this
      apply (Nat.le_div_iff_mul_le hMp).mpr
      have e : A * (2 * 2 ^ K) = 2 * (A * 2 ^ K) := by grind
      have e' : 2 ^ 53 * M = 2 * (2 ^ 52 * M) := by grind
      omega
    have q2 : A * 2 ^ K / M < 2 ^ 53 := by
      apply (Nat.div_lt_iff_lt_mul hMp).mpr
      have h1 : A * 2 ^ K < 2 ^ (LA + 1) * 2 ^ K := Nat.mul_lt_mul_of_pos_right a2 (Nat.two_pow_pos K)
      have h2 : 2 ^ 53 * 2 ^ LM ≤ 2 ^ 53 * M := Nat.mul_le_mul_left _ b1
      omega
    have hK1 : 1 ≤ K := by omega
    refine ⟨K, hK1, q1, q2, ?_⟩
    rw [round_tail _ _ (cond_bounds _ _ q1 q2).1 (cond_bounds _ _ q1 q2).2 hK1]
    rfl
  · have hb1 : Nat.ble (2 ^ 53) (A * 2 ^ (53 - LA + LM) / M) = false :=
      Bool.eq_false_iff.mpr (fun h => hbig (Nat.ble_eq.mp h))
    have hil : F64.ilt (0 - ((53 - LA + LM : Nat) : Int)) (-1074) = false := by
      rw [ilt_eq]; exact decide_eq_false (by omega)
    simp only [hb1, Bool.cond_false, hil, pow2_nat, Nat.mul_one]
    have hK1 : 1 ≤ 53 - LA + LM := by omega
    generalize 53 - LA + LM = K at *
    have q1 : 2 ^ 52 ≤ A * 2 ^ K / M := by
      apply (Nat.le_div_iff_mul_le hMp).mpr
      have h1 : 2 ^ LA * 2 ^ K ≤ A * 2 ^ K := Nat.mul_le_mul_right _ a1
      have h2 : 2 ^ 52 * M ≤ 2 ^ 52 * 2 ^ (LM + 1) := Nat.mul_le_mul_left _ (Nat.le_of_lt b2)
      omega
    have q2 : A * 2 ^ K / M < 2 ^ 53 := by omega
    refine ⟨K, hK1, q1, q2, ?_⟩
    rw [round_tail _ _ (cond_bounds _ _ q1 q2).1 (cond_bounds _ _ q1 q2).2 hK1]
    rfl

/-! ## `floor`, `trunc`, `ceil` of a quotient -/

/-- The non-integral quotient: `round` of `A / M` is `fin false m' (-(j+1))` with
`m' / 2^(j+1) = A / M`. -/
theorem div_frac (A M : Nat) (hA : 0 < A) (hA' : A < 2 ^ 53) (hM0 : 0 < M) (hM' : M < 2 ^ 53) (hr : A % M ≠ 0) :
    ∃ m' j, F64.div (ie A) (ie M) = .fin false m' (.negSucc j) ∧ m' / 2 ^ (j + 1) = A / M := by
  have hM : 2 ≤ M := by
    rcases Nat.lt_or_ge M 2 with h | h
    · exfalso
      have : M = 1 := by omega
      subst this
      exact hr (Nat.mod_one A)
    · exact h
  obtain ⟨K, hK, q1, q2, hround⟩ := round_div A M hA hA' hM hM'
  have hdiv : F64.div (ie A) (ie M) = F64.round F64.b64 false A M 0 := by
    rw [ie_ne (by omega), ie_ne (by omega)]
    simp only [Int.natAbs_natCast, decide_eq_false (show ¬ (A : Int) < 0 by omega),
      decide_eq_false (show ¬ (M : Int) < 0 by omega)]
    show (bif Nat.beq (Nat.mod A M) 0 then F64.fin (false != false) (Nat.div A M) 0
      else F64.round F64.b64 (false != false) A M 0) = _
    have : Nat.beq (Nat.mod A M) 0 = false := Bool.eq_false_iff.mpr (fun h => hr (Nat.eq_of_beq_eq_true h))
    rw [this]; rfl
  have hP : 0 < 2 ^ K := Nat.two_pow_pos K
  obtain ⟨hq, hnd⟩ := quot_core A M (2 ^ K) (A * 2 ^ K / M) (A * 2 ^ K % M) hP hA' q1
    (Nat.div_add_mod _ _) (Nat.mod_lt _ (by omega)) (upB M (A * 2 ^ K / M) (A * 2 ^ K % M))
    upB_true upB_false
  have hb := cond_bounds (upB M (A * 2 ^ K / M) (A * 2 ^ K % M)) _ q1 q2
  generalize (bif upB M (A * 2 ^ K / M) (A * 2 ^ K % M) then A * 2 ^ K / M + 1 else A * 2 ^ K / M) = mv at hround hq hnd hb
  rcases odd_cases mv K (by omega) hK (by omega) with ⟨hd, -, -⟩ | ⟨m', j, ho, hj⟩
  · exact absurd (Nat.mod_eq_zero_of_dvd hd) (hnd hr)
  · exact ⟨m', j, by rw [hdiv, hround, ho], by rw [hj, hq]⟩

theorem div_int (a m : Int) (hm : 0 < m) (hd : m ∣ a) (ha : a.natAbs < 2 ^ 53) :
    F64.div (ie a) (ie m) = ie (a / m) := by
  obtain ⟨q, rfl⟩ := hd
  rw [Int.mul_ediv_cancel_left _ (by omega)]
  exact div_ie _ q m hm rfl ha

theorem floor_div_ie (a m : Int) (ha : 0 ≤ a) (ha' : a < 2 ^ 53) (hm : 0 < m) (hm' : m < 2 ^ 53) :
    F64.floor (F64.div (ie a) (ie m)) = ie (a / m) := by
  by_cases hd : m ∣ a
  · rw [div_int a m hm hd (by omega), floor_ie]
  obtain ⟨A, rfl⟩ : ∃ A : Nat, a = A := ⟨a.toNat, by omega⟩
  obtain ⟨M, rfl⟩ : ∃ M : Nat, m = M := ⟨m.toNat, by omega⟩
  have hr : A % M ≠ 0 := fun h => hd (Int.natCast_dvd_natCast.mpr (Nat.dvd_of_mod_eq_zero h))
  have hA : 0 < A := Nat.pos_of_ne_zero (fun h => hd (by subst h; exact Int.dvd_zero _))
  obtain ⟨m', j, hf, hq⟩ := div_frac A M hA (by omega) (by omega) (by omega) hr
  rw [hf, show ((A : Int) / (M : Int)) = ((A / M : Nat) : Int) from (Int.natCast_ediv A M).symm]
  show (bif Nat.beq (m' / 2 ^ (j + 1)) 0 then F64.zero false else F64.ofNat (m' / 2 ^ (j + 1))) = _
  rw [hq]
  by_cases h0 : A / M = 0
  · rw [h0]; rfl
  · have : Nat.beq (A / M) 0 = false := Bool.eq_false_iff.mpr (fun h => h0 (Nat.eq_of_beq_eq_true h))
    rw [this, Bool.cond_false, ofNat_ie _ (by have := Nat.div_le_self A M; omega)]

theorem trunc_div_ie (a m : Int) (ha : 0 ≤ a) (ha' : a < 2 ^ 53) (hm : 0 < m) (hm' : m < 2 ^ 53) :
    F64.trunc (F64.div (ie a) (ie m)) = ie (a / m) := by
  by_cases hd : m ∣ a
  · rw [div_int a m hm hd (by omega), trunc_ie]
  obtain ⟨A, rfl⟩ : ∃ A : Nat, a = A := ⟨a.toNat, by omega⟩
  obtain ⟨M, rfl⟩ : ∃ M : Nat, m = M := ⟨m.toNat, by omega⟩
  have hr : A % M ≠ 0 := fun h => hd (Int.natCast_dvd_natCast.mpr (Nat.dvd_of_mod_eq_zero h))
  have hA : 0 < A := Nat.pos_of_ne_zero (fun h => hd (by subst h; exact Int.dvd_zero _))
  obtain ⟨m', j, hf, hq⟩ := div_frac A M hA (by omega) (by omega) (by omega) hr
  rw [hf, show ((A : Int) / (M : Int)) = ((A / M : Nat) : Int) from (Int.natCast_ediv A M).symm]
  show (bif Nat.beq (m' / 2 ^ (j + 1)) 0 then F64.zero false else F64.round F64.b64 false (m' / 2 ^ (j + 1)) 1 0) = _
  rw [hq]
  have hle := Nat.div_le_self A M
  generalize A / M = q at *
  by_cases h0 : q = 0
  · rw [h0]; rfl
  · have : Nat.beq q 0 = false := Bool.eq_false_iff.mpr (fun h => h0 (Nat.eq_of_beq_eq_true h))
    rw [this, Bool.cond_false, round_int false _ h0 (by omega)]
    exact fin_ie (by omega) (decide_eq_false (by omega)).symm (Int.natAbs_natCast _).symm

theorem ceil_div_ie (a m : Int) (ha : 0 ≤ a) (ha' : a < 2 ^ 53) (hm : 0 < m) (hm' : m < 2 ^ 53) :
    F64.ceil (F64.div (ie a) (ie m)) = ie ((a + m - 1) / m) := by
  by_cases hd : m ∣ a
  · rw [div_int a m hm hd (by omega), ceil_ie]
    obtain ⟨q, rfl⟩ := hd
    congr 1
    rw [Int.mul_ediv_cancel_left _ (by omega), show m * q + m - 1 = (m - 1) + m * q by omega,
      Int.add_mul_ediv_left _ _ (by omega), Int.ediv_eq_zero_of_lt (by omega) (by omega), Int.zero_add]
  obtain ⟨A, rfl⟩ : ∃ A : Nat, a = A := ⟨a.toNat, by omega⟩
  obtain ⟨M, rfl⟩ : ∃ M : Nat, m = M := ⟨m.toNat, by omega⟩
  have hr : A % M ≠ 0 := fun h => hd (Int.natCast_dvd_natCast.mpr (Nat.dvd_of_mod_eq_zero h))
  have hA : 0 < A := Nat.pos_of_ne_zero (fun h => hd (by subst h; exact Int.dvd_zero _))
  obtain ⟨m', j, hf, hq⟩ := div_frac A M hA (by omega) (by omega) (by omega) hr
  have hc : ((A : Int) + M - 1) / M = ((A / M + 1 : Nat) : Int) := by
    have e1 := Nat.div_add_mod A M
    have e2 := Nat.mod_lt A (show 0 < M by omega)
    have hn : (A + M - 1) / M = A / M + 1 := by
      have : A + M - 1 = (A % M - 1) + M * (A / M + 1) := by
        have : M * (A / M + 1) = M * (A / M) + M := by grind
        omega
      rw [this, Nat.add_mul_div_left _ _ (by omega), Nat.div_eq_of_lt (by omega), Nat.zero_add]
    rw [← hn, Int.natCast_ediv]
    congr 1
    omega
  rw [hf, hc]
  show F64.neg (bif Nat.beq (m' / 2 ^ (j + 1)) 0 then F64.ofSigned F64.b64 (-1) 0
    else F64.ofSigned F64.b64 (-((m' / 2 ^ (j + 1) + 1 : Nat) : Int)) 0) = _
  rw [hq]
  have hle : A / M < 2 ^ 52 := by
    have hM2 : 2 ≤ M := by
      rcases Nat.lt_or_ge M 2 with h | h
      · exfalso; have : M = 1 := by omega
        subst this; exact hr (Nat.mod_one A)
      · exact h
    apply (Nat.div_lt_iff_lt_mul (by omega)).mpr
    have : 2 ^ 52 * 2 ≤ 2 ^ 52 * M := Nat.mul_le_mul_left _ hM2
    omega
  generalize A / M = q at *
  by_cases h0 : q = 0
  · rw [h0]
    show F64.neg (F64.round F64.b64 true 1 1 0) = _
    rw [round_int true 1 (by omega) (by omega)]
    exact fin_ie (by omega) (decide_eq_false (by omega)).symm (Int.natAbs_natCast _).symm
  · have : Nat.beq q 0 = false := Bool.eq_false_iff.mpr (fun h => h0 (Nat.eq_of_beq_eq_true h))
    rw [this, Bool.cond_false]
    show F64.neg (F64.round F64.b64 true (q + 1) 1 0) = _
    rw [round_int true _ (by omega) (by omega)]
    exact fin_ie (by omega) (decide_eq_false (by omega)).symm (Int.natAbs_natCast _).symm

end Host.Ts.Sim.Lin
