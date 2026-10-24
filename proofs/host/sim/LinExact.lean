import host.ts.Run
namespace Host.Ts.Sim.Lin
open Host.Ts

/-! # Exact binary64 arithmetic on integers

Every integer `v` with `|v| < 2^53` has one binary64 form, `ie v`: `+0`, or `±|v|·2^0`.
`F64.ofInt v` is that form (`ofInt_ie`), and the interpreter's integer operations on it are
the integer operations: `+ - *` while the result stays below `2^53` (and a product is not a
negative zero), `%` of a non-negative dividend, `/` by a divisor of the dividend, `floor`,
`ceil` and `trunc` (identities on integers), `int32`/`uint32` wrapping, `min`/`max`, and the
comparisons, also against `±Infinity`. -/

/-- The canonical binary64 form of an integer. -/
def ie (v : Int) : F64 := if v = 0 then .zero false else .fin (decide (v < 0)) v.natAbs 0

theorem ie_zero : ie 0 = .zero false := rfl

theorem ie_ne {v : Int} (h : v ≠ 0) : ie v = .fin (decide (v < 0)) v.natAbs 0 := by
  simp only [ie, h, ↓reduceIte]

/-- A finite form with the sign and magnitude of `v ≠ 0` is `ie v`. -/
theorem fin_ie {v : Int} {s : Bool} {m : Nat} (hv : v ≠ 0) (hs : s = decide (v < 0)) (hm : m = v.natAbs) :
    F64.fin s m 0 = ie v := by
  rw [ie_ne hv, hs, hm]

theorem round_int (s : Bool) (n : Nat) (h0 : n ≠ 0) (h : n < 2 ^ 53) :
    F64.round F64.b64 s n 1 0 = .fin s n 0 := by
  have hsmall : Nat.blt n (Nat.pow 2 53) = true := Nat.blt_eq.mpr h
  have hlog : Nat.log2 n < 53 := (Nat.log2_lt h0).mpr h
  have htop : F64.ilt (Int.add (Nat.log2 n : Int) 0) 1024 = true := by
    change Nat.blt (Nat.log2 n) 1024 = true
    exact Nat.blt_eq.mpr (by omega)
  simp only [F64.round, F64.b64, hsmall, htop]
  change F64.norm s n 0 = _
  have hb : Nat.beq n 0 = false := by
    cases hq : Nat.beq n 0
    · rfl
    · exact absurd (Nat.eq_of_beq_eq_true hq) h0
  have hs : Nat.blt n F64.small = true := hsmall
  simp only [F64.norm, hb, hs]
  rfl

theorem ofInt_ie (v : Int) (h : v.natAbs < 2 ^ 53) : F64.ofInt v = ie v := by
  cases v with
  | ofNat n =>
    by_cases h0 : n = 0
    · subst h0; rfl
    · change F64.round F64.b64 false n 1 0 = _
      rw [round_int false n h0 (by simpa using h)]
      exact fin_ie (by simpa using h0) (by simp) (by simp)
  | negSucc n =>
    change F64.round F64.b64 true (n + 1) 1 0 = _
    rw [round_int true (n + 1) (by omega) (by simpa using h)]
    exact fin_ie (by omega) (by simp) rfl

theorem ofNat_ie (n : Nat) (h : n < 2 ^ 53) : F64.ofNat n = ie n :=
  ofInt_ie n (by simpa using h)

/-! ## Arithmetic -/

theorem add_ie (a b : Int) (h : (a + b).natAbs < 2 ^ 53) : F64.add (ie a) (ie b) = ie (a + b) := by
  by_cases ha : a = 0
  · subst ha
    by_cases hb : b = 0
    · subst hb; rfl
    · rw [Int.zero_add, ie_ne hb, ie_zero]; rfl
  by_cases hb : b = 0
  · subst hb; rw [Int.add_zero, ie_ne ha, ie_zero]; rfl
  rw [ie_ne ha, ie_ne hb]
  show (bif decide (a < 0) == decide (b < 0) then
      (bif Nat.blt (a.natAbs + b.natAbs) F64.small then F64.fin (decide (a < 0)) (a.natAbs + b.natAbs) 0
       else F64.round F64.b64 (decide (a < 0)) (a.natAbs + b.natAbs) 1 0)
    else bif Nat.blt b.natAbs a.natAbs then F64.fin (decide (a < 0)) (a.natAbs - b.natAbs) 0
    else bif Nat.blt a.natAbs b.natAbs then F64.fin (decide (b < 0)) (b.natAbs - a.natAbs) 0
    else F64.zero false) = ie (a + b)
  rcases Int.lt_or_gt_of_ne ha with ha' | ha' <;> rcases Int.lt_or_gt_of_ne hb with hb' | hb'
  · have hs : Nat.blt (a.natAbs + b.natAbs) F64.small = true := Nat.blt_eq.mpr (by
      change _ < 2 ^ 53; omega)
    simp only [decide_eq_true ha', decide_eq_true hb', BEq.rfl, hs, Bool.cond_true]
    exact fin_ie (by omega) (decide_eq_true (by omega)).symm (by omega)
  · simp only [decide_eq_true ha', decide_eq_false (show ¬ b < 0 by omega)]
    by_cases h1 : b.natAbs < a.natAbs
    · simp only [Nat.blt_eq.mpr h1]
      exact fin_ie (by omega) (decide_eq_true (by omega)).symm (by omega)
    · by_cases h2 : a.natAbs < b.natAbs
      · simp only [Nat.blt_eq.mpr h2, show Nat.blt b.natAbs a.natAbs = false from
          Bool.eq_false_iff.mpr (fun h => h1 (Nat.blt_eq.mp h))]
        exact fin_ie (by omega) (decide_eq_false (by omega)).symm (by omega)
      · simp only [show Nat.blt b.natAbs a.natAbs = false from Bool.eq_false_iff.mpr (fun h => h1 (Nat.blt_eq.mp h)),
          show Nat.blt a.natAbs b.natAbs = false from Bool.eq_false_iff.mpr (fun h => h2 (Nat.blt_eq.mp h))]
        rw [show a + b = 0 by omega]; rfl
  · simp only [decide_eq_false (show ¬ a < 0 by omega), decide_eq_true hb']
    by_cases h1 : b.natAbs < a.natAbs
    · simp only [Nat.blt_eq.mpr h1]
      exact fin_ie (by omega) (decide_eq_false (by omega)).symm (by omega)
    · by_cases h2 : a.natAbs < b.natAbs
      · simp only [Nat.blt_eq.mpr h2, show Nat.blt b.natAbs a.natAbs = false from
          Bool.eq_false_iff.mpr (fun h => h1 (Nat.blt_eq.mp h))]
        exact fin_ie (by omega) (decide_eq_true (by omega)).symm (by omega)
      · simp only [show Nat.blt b.natAbs a.natAbs = false from Bool.eq_false_iff.mpr (fun h => h1 (Nat.blt_eq.mp h)),
          show Nat.blt a.natAbs b.natAbs = false from Bool.eq_false_iff.mpr (fun h => h2 (Nat.blt_eq.mp h))]
        rw [show a + b = 0 by omega]; rfl
  · have hs : Nat.blt (a.natAbs + b.natAbs) F64.small = true := Nat.blt_eq.mpr (by
      change _ < 2 ^ 53; omega)
    simp only [decide_eq_false (show ¬ a < 0 by omega), decide_eq_false (show ¬ b < 0 by omega), BEq.rfl, hs,
      Bool.cond_true]
    exact fin_ie (by omega) (decide_eq_false (by omega)).symm (by omega)

theorem neg_ie (a : Int) (h : a ≠ 0) : F64.neg (ie a) = ie (-a) := by
  rw [ie_ne h]
  exact fin_ie (by omega) (by
    rcases Int.lt_or_gt_of_ne h with h' | h'
    · simp only [decide_eq_true h', decide_eq_false (show ¬ -a < 0 by omega)]; rfl
    · simp only [decide_eq_false (show ¬ a < 0 by omega), decide_eq_true (show -a < 0 by omega)]; rfl) (by omega)

theorem sub_ie (a b : Int) (h : (a - b).natAbs < 2 ^ 53) : F64.sub (ie a) (ie b) = ie (a - b) := by
  by_cases hb : b = 0
  · subst hb
    rw [Int.sub_zero]
    by_cases ha : a = 0
    · subst ha; rfl
    · rw [ie_ne ha]; rfl
  · change F64.add (ie a) (F64.neg (ie b)) = _
    rw [neg_ie b hb, add_ie a (-b) (by omega), Int.sub_eq_add_neg]

/-- A product is exact below `2^53` unless it is a negative zero. -/
theorem mul_ie (a b : Int) (h : (a * b).natAbs < 2 ^ 53) (hz : a * b = 0 → 0 ≤ a ∧ 0 ≤ b) :
    F64.mul (ie a) (ie b) = ie (a * b) := by
  by_cases ha : a = 0
  · subst ha
    have hb := (hz (Int.zero_mul b)).2
    rw [Int.zero_mul]
    by_cases hb0 : b = 0
    · subst hb0; rfl
    · rw [ie_ne hb0, decide_eq_false (show ¬ b < 0 by omega)]; rfl
  by_cases hb : b = 0
  · subst hb
    have ha' := (hz (Int.mul_zero a)).1
    rw [Int.mul_zero, ie_ne ha, decide_eq_false (show ¬ a < 0 by omega)]; rfl
  have hab : a * b ≠ 0 := Int.mul_ne_zero ha hb
  rw [ie_ne ha, ie_ne hb]
  have hn : (a * b).natAbs = a.natAbs * b.natAbs := Int.natAbs_mul a b
  have hs : Nat.blt (a.natAbs * b.natAbs) F64.small = true := Nat.blt_eq.mpr (by
    change _ < 2 ^ 53; omega)
  show (bif Nat.blt (a.natAbs * b.natAbs) F64.small then
      F64.fin (decide (a < 0) != decide (b < 0)) (a.natAbs * b.natAbs) 0
    else F64.round F64.b64 (decide (a < 0) != decide (b < 0)) (a.natAbs * b.natAbs) 1 0) = ie (a * b)
  rw [hs]
  refine fin_ie hab ?_ hn.symm
  rcases Int.lt_or_gt_of_ne ha with ha' | ha' <;> rcases Int.lt_or_gt_of_ne hb with hb' | hb'
  · rw [decide_eq_true ha', decide_eq_true hb', decide_eq_false (show ¬ a * b < 0 from
      Int.not_lt.mpr (Int.le_of_lt (Int.mul_pos_of_neg_of_neg ha' hb')))]; rfl
  · rw [decide_eq_true ha', decide_eq_false (show ¬ b < 0 by omega),
      decide_eq_true (Int.mul_neg_of_neg_of_pos ha' hb')]; rfl
  · rw [decide_eq_false (show ¬ a < 0 by omega), decide_eq_true hb',
      decide_eq_true (Int.mul_neg_of_pos_of_neg ha' hb')]; rfl
  · rw [decide_eq_false (show ¬ a < 0 by omega), decide_eq_false (show ¬ b < 0 by omega),
      decide_eq_false (show ¬ a * b < 0 from Int.not_lt.mpr (Int.le_of_lt (Int.mul_pos ha' hb')))]; rfl

/-- Division by a positive divisor of the dividend. -/
theorem div_ie (a q m : Int) (hm : 0 < m) (ha : a = m * q) (h : a.natAbs < 2 ^ 53) :
    F64.div (ie a) (ie m) = ie q := by
  have hm0 : m ≠ 0 := by omega
  by_cases hq : q = 0
  · subst hq
    rw [Int.mul_zero] at ha
    subst ha
    rw [ie_ne hm0, decide_eq_false (show ¬ m < 0 by omega)]; rfl
  have ha0 : a ≠ 0 := by rw [ha]; exact Int.mul_ne_zero hm0 hq
  rw [ie_ne ha0, ie_ne hm0, decide_eq_false (show ¬ m < 0 by omega)]
  have hn : a.natAbs = m.natAbs * q.natAbs := by rw [ha]; exact Int.natAbs_mul m q
  have hmn : 0 < m.natAbs := by omega
  have hmod : Nat.mod a.natAbs m.natAbs = 0 := by rw [hn]; exact Nat.mul_mod_right _ _
  have hdiv : Nat.div a.natAbs m.natAbs = q.natAbs := by rw [hn]; exact Nat.mul_div_cancel_left _ hmn
  show (bif Nat.beq (Nat.mod a.natAbs m.natAbs) 0 then F64.fin (decide (a < 0) != false) (Nat.div a.natAbs m.natAbs) 0
    else F64.round F64.b64 (decide (a < 0) != false) a.natAbs m.natAbs 0) = ie q
  rw [hmod, hdiv]
  refine fin_ie hq ?_ rfl
  rw [Bool.bne_false]
  rcases Int.lt_or_gt_of_ne hq with hq' | hq'
  · rw [decide_eq_true hq', decide_eq_true (show a < 0 by rw [ha]; exact Int.mul_neg_of_pos_of_neg hm hq')]
  · rw [decide_eq_false (show ¬ q < 0 by omega),
      decide_eq_false (show ¬ a < 0 by rw [ha]; exact Int.not_lt.mpr (Int.le_of_lt (Int.mul_pos hm hq')))]

/-- `%` of a non-negative dividend by a positive divisor. -/
theorem rem_ie (a b : Int) (ha : 0 ≤ a) (hb : 0 < b) : F64.rem (ie a) (ie b) = ie (a % b) := by
  have hb0 : b ≠ 0 := by omega
  by_cases ha0 : a = 0
  · subst ha0; rw [ie_ne hb0, Int.zero_emod]; rfl
  rw [ie_ne ha0, ie_ne hb0, decide_eq_false (show ¬ a < 0 by omega), decide_eq_false (show ¬ b < 0 by omega)]
  show (bif Nat.beq (Nat.mod a.natAbs b.natAbs) 0 then F64.zero false else F64.fin false (Nat.mod a.natAbs b.natAbs) 0) =
    ie (a % b)
  have hr : ((Nat.mod a.natAbs b.natAbs : Nat) : Int) = a % b := by
    change ((a.natAbs % b.natAbs : Nat) : Int) = a % b
    rw [Int.natCast_emod, Int.natAbs_of_nonneg ha, Int.natAbs_of_nonneg (by omega)]
  by_cases hz : Nat.mod a.natAbs b.natAbs = 0
  · rw [hz, show a % b = 0 by omega]; rfl
  · have hbz : Nat.beq (Nat.mod a.natAbs b.natAbs) 0 = false := Bool.eq_false_iff.mpr (fun h => hz (Nat.eq_of_beq_eq_true h))
    rw [hbz]
    exact fin_ie (by omega) (decide_eq_false (by omega)).symm (by omega)

/-! ## Rounding to integers, conversions -/

theorem floor_ie (a : Int) : F64.floor (ie a) = ie a := by
  by_cases h : a = 0
  · subst h; rfl
  · rw [ie_ne h]; rfl

theorem trunc_ie (a : Int) : F64.trunc (ie a) = ie a := by
  by_cases h : a = 0
  · subst h; rfl
  · rw [ie_ne h]; rfl

theorem ceil_ie (a : Int) : F64.ceil (ie a) = ie a := by
  by_cases h : a = 0
  · subst h; rfl
  · rw [ie_ne h]
    change F64.neg (F64.floor (F64.fin (!decide (a < 0)) a.natAbs 0)) = _
    change F64.fin (!!decide (a < 0)) a.natAbs 0 = _
    rw [Bool.not_not]

theorem truncInt_ie (a : Int) : F64.truncInt (ie a) = some a := by
  by_cases h : a = 0
  · subst h; rfl
  · rw [ie_ne h]
    change some (bif decide (a < 0) then -((a.natAbs * 2 ^ 0 : Nat) : Int) else ((a.natAbs * 2 ^ 0 : Nat) : Int)) = some a
    rcases Int.lt_or_gt_of_ne h with h' | h'
    · rw [decide_eq_true h']; simp only [Bool.cond_true, Nat.pow_zero, Nat.mul_one, Option.some.injEq]; omega
    · rw [decide_eq_false (show ¬ a < 0 by omega)]; simp only [Bool.cond_false, Nat.pow_zero, Nat.mul_one, Option.some.injEq]; omega

theorem toUint32_ie (a : Int) : F64.toUint32 (ie a) = (a % 4294967296).toNat := by
  simp only [F64.toUint32, truncInt_ie, F64.modNat]
  rfl

theorem toInt32_ie (a : Int) : F64.toInt32 (ie a) = (a + 2147483648) % 4294967296 - 2147483648 := by
  simp only [F64.toInt32, toUint32_ie]
  by_cases hl : (a % 4294967296).toNat < 2 ^ 31
  · rw [Nat.blt_eq.mpr hl]; simp only [Bool.cond_true]; omega
  · rw [Bool.eq_false_iff.mpr (fun h => hl (Nat.blt_eq.mp h))]; simp only [Bool.cond_false]; omega

/-- `int32` of an integer below `2^53`. -/
theorem int32_ie (a : Int) : F64.un .int32 (ie a) = ie ((a + 2147483648) % 4294967296 - 2147483648) := by
  change F64.ofInt (F64.toInt32 (ie a)) = _
  rw [toInt32_ie, ofInt_ie _ (by omega)]

/-- `uint32` of an integer below `2^53`. -/
theorem uint32_ie (a : Int) : F64.un .uint32 (ie a) = ie (a % 4294967296) := by
  change F64.ofNat (F64.toUint32 (ie a)) = _
  rw [toUint32_ie, ofNat_ie _ (by omega), Int.toNat_of_nonneg (by omega)]

/-! ## Comparisons -/

theorem lt_ie (a b : Int) : F64.lt (ie a) (ie b) = decide (a < b) := by
  by_cases ha : a = 0
  · subst ha
    by_cases hb : b = 0
    · subst hb; rfl
    · rw [ie_ne hb]
      change (!decide (b < 0)) = decide (0 < b)
      rcases Int.lt_or_gt_of_ne hb with h | h
      · rw [decide_eq_true h, decide_eq_false (show ¬ (0 : Int) < b by omega)]; rfl
      · rw [decide_eq_false (show ¬ b < 0 by omega), decide_eq_true h]; rfl
  by_cases hb : b = 0
  · subst hb
    rw [ie_ne ha]
    change decide (a < 0) = decide (a < 0)
    rfl
  rw [ie_ne ha, ie_ne hb]
  change (bif decide (a < 0) then (bif decide (b < 0) then Nat.blt b.natAbs a.natAbs else true)
    else (bif decide (b < 0) then false else Nat.blt a.natAbs b.natAbs)) = decide (a < b)
  rcases Int.lt_or_gt_of_ne ha with ha' | ha' <;> rcases Int.lt_or_gt_of_ne hb with hb' | hb'
  · rw [decide_eq_true ha', decide_eq_true hb']
    simp only [Bool.cond_true]
    apply Bool.eq_iff_iff.mpr; simp only [Nat.blt_eq, decide_eq_true_eq]; omega
  · rw [decide_eq_true ha', decide_eq_false (show ¬ b < 0 by omega), decide_eq_true (show a < b by omega)]; rfl
  · rw [decide_eq_false (show ¬ a < 0 by omega), decide_eq_true hb', decide_eq_false (show ¬ a < b by omega)]; rfl
  · rw [decide_eq_false (show ¬ a < 0 by omega), decide_eq_false (show ¬ b < 0 by omega)]
    simp only [Bool.cond_false]
    apply Bool.eq_iff_iff.mpr; simp only [Nat.blt_eq, decide_eq_true_eq]; omega

theorem eq_ie (a b : Int) : F64.eq (ie a) (ie b) = decide (a = b) := by
  by_cases ha : a = 0
  · subst ha
    by_cases hb : b = 0
    · subst hb; rfl
    · rw [ie_ne hb, decide_eq_false (Ne.symm hb)]; rfl
  by_cases hb : b = 0
  · subst hb; rw [ie_ne ha, decide_eq_false ha]; rfl
  rw [ie_ne ha, ie_ne hb]
  change (decide (a < 0) == decide (b < 0) && Nat.beq a.natAbs b.natAbs && ((0 : Int) == 0)) = decide (a = b)
  apply Bool.eq_iff_iff.mpr
  simp only [Bool.and_eq_true, beq_iff_eq, Nat.beq_eq, decide_eq_true_eq, and_true]
  constructor
  · intro ⟨h1, h2⟩
    rcases Int.lt_or_gt_of_ne ha with ha' | ha'
    · have : b < 0 := by
        have := h1; rw [decide_eq_true ha'] at this; exact of_decide_eq_true this.symm
      omega
    · have : ¬ b < 0 := by
        have := h1; rw [decide_eq_false (show ¬ a < 0 by omega)] at this; exact of_decide_eq_false this.symm
      omega
  · intro h; subst h; exact ⟨rfl, rfl⟩

theorem le_ie (a b : Int) : F64.le (ie a) (ie b) = decide (a ≤ b) := by
  change (F64.lt (ie a) (ie b) || F64.eq (ie a) (ie b)) = _
  rw [lt_ie, eq_ie]
  apply Bool.eq_iff_iff.mpr
  simp only [Bool.or_eq_true, decide_eq_true_eq]
  omega

theorem truthy_ie (a : Int) : F64.truthy (ie a) = decide (a ≠ 0) := by
  by_cases h : a = 0
  · subst h; rfl
  · rw [ie_ne h, decide_eq_true h]; rfl

theorem lt_ie_inf (a : Int) (s : Bool) : F64.lt (ie a) (.inf s) = !s := by
  by_cases h : a = 0
  · subst h; rfl
  · rw [ie_ne h]; rfl

theorem lt_inf_ie (s : Bool) (a : Int) : F64.lt (.inf s) (ie a) = s := by
  by_cases h : a = 0
  · subst h; rfl
  · rw [ie_ne h]; rfl

theorem eq_ie_inf (a : Int) (s : Bool) : F64.eq (ie a) (.inf s) = false := by
  by_cases h : a = 0
  · subst h; rfl
  · rw [ie_ne h]; rfl

theorem eq_inf_ie (s : Bool) (a : Int) : F64.eq (.inf s) (ie a) = false := by
  by_cases h : a = 0
  · subst h; rfl
  · rw [ie_ne h]; rfl

/-! ## `Math.min`, `Math.max` -/

theorem min_ie (a b : Int) : F64.min (ie a) (ie b) = ie (min a b) := by
  have key : (bif F64.lt (ie b) (ie a) then ie b else ie a) = ie (min a b) := by
    rw [lt_ie]
    by_cases h : b < a
    · rw [decide_eq_true h, Int.min_eq_right (by omega)]; rfl
    · rw [decide_eq_false h, Int.min_eq_left (by omega)]; rfl
  by_cases ha : a = 0
  · subst ha
    by_cases hb : b = 0
    · subst hb; rfl
    · rw [← key, ie_ne hb]; rfl
  · rw [← key, ie_ne ha]
    by_cases hb : b = 0
    · subst hb; rfl
    · rw [ie_ne hb]; rfl

theorem max_ie (a b : Int) : F64.max (ie a) (ie b) = ie (max a b) := by
  have key : (bif F64.lt (ie a) (ie b) then ie b else ie a) = ie (max a b) := by
    rw [lt_ie]
    by_cases h : a < b
    · rw [decide_eq_true h, Int.max_eq_right (by omega)]; rfl
    · rw [decide_eq_false h, Int.max_eq_left (by omega)]; rfl
  by_cases ha : a = 0
  · subst ha
    by_cases hb : b = 0
    · subst hb; rfl
    · rw [← key, ie_ne hb]; rfl
  · rw [← key, ie_ne ha]
    by_cases hb : b = 0
    · subst hb; rfl
    · rw [ie_ne hb]; rfl

theorem min_ie_inf (a : Int) (s : Bool) : F64.min (ie a) (.inf s) = bif s then .inf true else ie a := by
  have key : F64.min (ie a) (.inf s) = bif F64.lt (.inf s) (ie a) then .inf s else ie a := by
    by_cases h : a = 0
    · subst h; rfl
    · rw [ie_ne h]; rfl
  rw [key, lt_inf_ie]; cases s <;> rfl

theorem min_inf_ie (s : Bool) (a : Int) : F64.min (.inf s) (ie a) = bif s then .inf true else ie a := by
  have key : F64.min (.inf s) (ie a) = bif F64.lt (ie a) (.inf s) then ie a else .inf s := by
    by_cases h : a = 0
    · subst h; rfl
    · rw [ie_ne h]; rfl
  rw [key, lt_ie_inf]; cases s <;> rfl

theorem max_ie_inf (a : Int) (s : Bool) : F64.max (ie a) (.inf s) = bif s then ie a else .inf false := by
  have key : F64.max (ie a) (.inf s) = bif F64.lt (ie a) (.inf s) then .inf s else ie a := by
    by_cases h : a = 0
    · subst h; rfl
    · rw [ie_ne h]; rfl
  rw [key, lt_ie_inf]; cases s <;> rfl

theorem max_inf_ie (s : Bool) (a : Int) : F64.max (.inf s) (ie a) = bif s then ie a else .inf false := by
  have key : F64.max (.inf s) (ie a) = bif F64.lt (.inf s) (ie a) then ie a else .inf s := by
    by_cases h : a = 0
    · subst h; rfl
    · rw [ie_ne h]; rfl
  rw [key, lt_inf_ie]; cases s <;> rfl

end Host.Ts.Sim.Lin
