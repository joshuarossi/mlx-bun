import contracts.mlx.Numerics

namespace Inference.Contracts.Mlx.FlushToZero
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Binary32 subnormals have an exponent of -149 and fewer than 24 significant
-- bits. Model input and output flushing explicitly; IEEE gradual underflow is
-- not an unconditional description of M1 Max arithmetic.
def flush (x : Float32) : Float32 :=
  match x.toModel.unpack with
  | .finite s m e _ =>
    if m<8388608 ∧ e = -149 then Float32.ofModel (Float32.Model.pack (.zero s)) else x
  | _ => x

noncomputable def threshold : ℝ := (2 : ℝ)^(-126 : ℤ)

theorem threshold_pos : 0 < threshold := by unfold threshold; positivity
theorem threshold_lt_one : threshold < 1 := by norm_num [threshold]

theorem real_signed_zero (s : Float.Model.UnpackedFloat.Sign) :
    real (Float32.ofModel (Float32.Model.pack (.zero s))) = 0 := by
  rw [real_unpack]
  cases s <;> exact Model.unpackedToReal_zero _

theorem finite_flush (x : Float32) (hx : x.isFinite=true) : (flush x).isFinite=true := by
  unfold flush
  split
  · split
    · rename_i s _ _ _ _ _
      cases s <;> decide
    · exact hx
  · exact hx

theorem finite_flush_iff (x : Float32) : (flush x).isFinite = x.isFinite := by
  unfold flush
  split
  · rename_i s m e hm hu
    split
    · have hx : x.isFinite = true := by
        simp only [Float32.isFinite, Float32.Model.isFinite, hu, Float.Model.UnpackedFloat.isFinite]
      rw [hx]
      cases s <;> decide
    · rfl
  · rfl

theorem flush_abs_le (x : Float32) : |real (flush x)| ≤ |real x| := by
  unfold flush
  split
  · split
    · rw [real_signed_zero, abs_zero]
      exact abs_nonneg _
    · exact le_refl _
  · exact le_refl _

theorem flush_error (x : Float32) : |real (flush x)-real x| ≤ threshold := by
  unfold flush
  split
  · rename_i s m e hm hu
    split
    · rename_i h
      rw [real_signed_zero, zero_sub, abs_neg, real_unpack, hu, Model.unpackedToReal_finite]
      obtain ⟨hsmall, rfl⟩ := h
      have hm' : (m : ℝ) ≤ 8388608 := by exact_mod_cast (show m≤8388608 by omega)
      have hp : 0 < (2 : ℝ)^(-149 : ℤ) := by positivity
      have hbound := mul_le_mul_of_nonneg_right hm' hp.le
      cases s <;> norm_num [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow] at *
      all_goals
        change (m : ℝ) * (|(2 : ℝ)|^149)⁻¹ ≤ (2 : ℝ)^(-126 : ℤ)
        norm_num at hbound ⊢
        linarith
    · simpa using threshold_pos.le
  · simpa using threshold_pos.le

-- With denormals disabled, M1 Max multiplication, division and fused
-- multiply-add flush a nonzero exact result n/d·2^e below 2^-126 in magnitude
-- to the zero of its sign before rounding. Addition and subtraction coincide
-- with flushing after rounding: exact sums below 2^-126 are representable.
def below (n : Int) (d : Nat) (e : Int) : Bool :=
  n != 0 && n.natAbs*2^(e+126).toNat < d*2^(-(e+126)).toNat

theorem below_iff (n : Int) (d : Nat) (e : Int) (hd : 0<d) :
    below n d e = true ↔ n ≠ 0 ∧ |(n : ℝ)/d*(2 : ℝ)^e| < threshold := by
  have hk : (((e+126).toNat : ℕ) : ℤ)-(((-(e+126)).toNat : ℕ) : ℤ) = e+126 := Int.toNat_sub_toNat_neg _
  have hp : (2 : ℝ)^e = (2 : ℝ)^(e+126).toNat/(2 : ℝ)^(-(e+126)).toNat*threshold := by
    unfold threshold
    rw [← zpow_natCast, ← zpow_natCast, ← zpow_sub₀ two_ne_zero, ← zpow_add₀ two_ne_zero, hk]
    ring_nf
  have hd' : (0 : ℝ) < d := by exact_mod_cast hd
  have hb : (0 : ℝ) < (2 : ℝ)^(-(e+126)).toNat := by positivity
  have habs : |(n : ℝ)/d*(2 : ℝ)^e| = (n.natAbs : ℝ)/d*((2 : ℝ)^(e+126).toNat/(2 : ℝ)^(-(e+126)).toNat*threshold) := by
    rw [hp, abs_mul, abs_div, abs_of_pos hd', Nat.cast_natAbs, Int.cast_abs, abs_of_pos (mul_pos (by positivity) threshold_pos)]
  rw [habs]
  have key : (n.natAbs : ℝ)/d*((2 : ℝ)^(e+126).toNat/(2 : ℝ)^(-(e+126)).toNat*threshold) < threshold ↔
      (n.natAbs : ℝ)*(2 : ℝ)^(e+126).toNat < d*(2 : ℝ)^(-(e+126)).toNat := by
    rw [show (n.natAbs : ℝ)/d*((2 : ℝ)^(e+126).toNat/(2 : ℝ)^(-(e+126)).toNat*threshold) =
      ((n.natAbs : ℝ)*(2 : ℝ)^(e+126).toNat/(d*(2 : ℝ)^(-(e+126)).toNat))*threshold by field_simp]
    rw [mul_lt_iff_lt_one_left threshold_pos, div_lt_one (by positivity)]
  rw [key]
  simp only [below, Bool.and_eq_true, bne_iff_ne, ne_eq, decide_eq_true_eq]
  constructor
  · rintro ⟨h0, h⟩
    exact ⟨h0, by exact_mod_cast h⟩
  · rintro ⟨h0, h⟩
    exact ⟨h0, by exact_mod_cast h⟩

-- Exact results n/d·2^e of finite operands; `none` when an operand is not
-- finite or the divisor is zero, where the real semantics is zero.
def mulExact {fmt : FloatFormat} (x y : Model fmt) : Option (Int × Nat × Int) :=
  match Model.toDyadic? x, Model.toDyadic? y with
  | some a, some b => some (a.signedSignificand*b.signedSignificand, 1, a.exponent+b.exponent)
  | _, _ => none

def divExact {fmt : FloatFormat} (x y : Model fmt) : Option (Int × Nat × Int) :=
  match Model.toDyadic? x, Model.toDyadic? y with
  | some a, some b =>
    if b.significand = 0 then none else some (a.signedSignificand*b.signedSignificand.sign, b.significand, a.exponent-b.exponent)
  | _, _ => none

def fmaExact {fmt : FloatFormat} (x y z : Model fmt) : Option (Int × Nat × Int) :=
  match Model.toDyadic? x, Model.toDyadic? y, Model.toDyadic? z with
  | some a, some b, some c =>
    let e := min (a.exponent+b.exponent) c.exponent
    some (a.signedSignificand*b.signedSignificand*2^(a.exponent+b.exponent-e).toNat +
      c.signedSignificand*2^(c.exponent-e).toNat, 1, e)
  | _, _, _ => none

def Exact (exact : Option (Int × Nat × Int)) (v : ℝ) : Prop :=
  match exact with
  | some (n, d, e) => 0<d ∧ (n : ℝ)/d*(2 : ℝ)^e = v
  | none => v = 0

theorem toReal_of_toDyadic {fmt : FloatFormat} {x : Model fmt} {a : FloatLib.Numerics.Dyadic}
    (h : Model.toDyadic? x = some a) : Model.toReal x = (a.signedSignificand : ℝ)*(2 : ℝ)^a.exponent := by
  rw [Model.toReal_eq, h]
  rfl

theorem toReal_of_toDyadic_none {fmt : FloatFormat} {x : Model fmt}
    (h : Model.toDyadic? x = none) : Model.toReal x = 0 := by
  rw [Model.toReal_eq, h]

theorem exact_mul {fmt : FloatFormat} (x y : Model fmt) :
    Exact (mulExact x y) (Model.toReal x*Model.toReal y) := by
  unfold mulExact
  cases hx : Model.toDyadic? x <;> cases hy : Model.toDyadic? y
  · simp [Exact, toReal_of_toDyadic_none hx]
  · simp [Exact, toReal_of_toDyadic_none hx]
  · simp [Exact, toReal_of_toDyadic_none hy]
  · rename_i a b
    refine ⟨one_pos, ?_⟩
    rw [toReal_of_toDyadic hx, toReal_of_toDyadic hy, zpow_add₀ two_ne_zero]
    push_cast
    ring

theorem exact_div {fmt : FloatFormat} (x y : Model fmt) :
    Exact (divExact x y) (Model.toReal x/Model.toReal y) := by
  unfold divExact
  cases hx : Model.toDyadic? x <;> cases hy : Model.toDyadic? y
  · simp [Exact, toReal_of_toDyadic_none hx]
  · simp [Exact, toReal_of_toDyadic_none hx]
  · simp [Exact, toReal_of_toDyadic_none hy]
  rename_i a b
  dsimp only
  have habs : ((b.significand : ℕ) : ℝ) = |(b.signedSignificand : ℝ)| := by
    rw [← FloatLib.Numerics.Dyadic.natAbs_signedSignificand b, Nat.cast_natAbs, Int.cast_abs]
  by_cases h0 : b.significand = 0
  · rw [if_pos h0]
    have hs : (b.signedSignificand : ℝ) = 0 := by
      rw [← abs_eq_zero, ← habs, h0, Nat.cast_zero]
    simp [Exact, toReal_of_toDyadic hy, hs]
  rw [if_neg h0]
  refine ⟨Nat.pos_of_ne_zero h0, ?_⟩
  rw [toReal_of_toDyadic hx, toReal_of_toDyadic hy, zpow_sub₀ two_ne_zero, habs]
  have hne : (b.signedSignificand : ℝ) ≠ 0 := by
    intro h
    rw [h, abs_zero] at habs
    exact h0 (by exact_mod_cast habs)
  have hsign : ((b.signedSignificand.sign : ℤ) : ℝ) = (b.signedSignificand : ℝ)/|(b.signedSignificand : ℝ)| := by
    rw [eq_div_iff (abs_ne_zero.mpr hne)]
    exact_mod_cast Int.sign_mul_abs _
  push_cast
  rw [hsign]
  have h2 : (2 : ℝ)^b.exponent ≠ 0 := zpow_ne_zero _ two_ne_zero
  have ha : |(b.signedSignificand : ℝ)| ≠ 0 := abs_ne_zero.mpr hne
  field_simp
  rw [sq_abs]


theorem exact_fma {fmt : FloatFormat} (x y z : Model fmt)
    (hx : Model.isFinite x = true) (hy : Model.isFinite y = true) (hz : Model.isFinite z = true) :
    Exact (fmaExact x y z) (Model.toReal x*Model.toReal y+Model.toReal z) := by
  obtain ⟨a, ha⟩ := Model.exists_toDyadic?_of_isFinite hx
  obtain ⟨b, hb⟩ := Model.exists_toDyadic?_of_isFinite hy
  obtain ⟨c, hc⟩ := Model.exists_toDyadic?_of_isFinite hz
  simp only [fmaExact, ha, hb, hc, Exact]
  refine ⟨one_pos, ?_⟩
  rw [toReal_of_toDyadic ha, toReal_of_toDyadic hb, toReal_of_toDyadic hc]
  set E := min (a.exponent+b.exponent) c.exponent with hE
  have hp : (0 : ℤ) ≤ a.exponent+b.exponent-E := by omega
  have hq : (0 : ℤ) ≤ c.exponent-E := by omega
  have e1 : (2 : ℝ)^(a.exponent+b.exponent-E).toNat*2^E = 2^a.exponent*2^b.exponent := by
    rw [← zpow_natCast, Int.toNat_of_nonneg hp, ← zpow_add₀ two_ne_zero, ← zpow_add₀ two_ne_zero]
    congr 1; ring
  have e2 : (2 : ℝ)^(c.exponent-E).toNat*2^E = 2^c.exponent := by
    rw [← zpow_natCast, Int.toNat_of_nonneg hq, ← zpow_add₀ two_ne_zero]
    congr 1; ring
  push_cast
  linear_combination ((a.signedSignificand : ℝ)*b.signedSignificand)*e1 + (c.signedSignificand : ℝ)*e2

-- `some negative` when a nonzero exact result is below 2^-126.
def underflow : Option (Int × Nat × Int) → Option Bool
  | some (n, d, e) => if below n d e then some (decide (n<0)) else none
  | none => none

theorem underflow_some {exact : Option (Int × Nat × Int)} {v : ℝ} (h : Exact exact v) {s : Bool}
    (hu : underflow exact = some s) : |v| < threshold := by
  match exact, h, hu with
  | some (n, d, e), ⟨hd, hv⟩, hu =>
    simp only [underflow] at hu
    split at hu
    · rw [← hv]; exact ((below_iff n d e hd).mp (by assumption)).2
    · cases hu

theorem underflow_none {exact : Option (Int × Nat × Int)} {v : ℝ} (h : Exact exact v)
    (hu : underflow exact = none) : v = 0 ∨ threshold ≤ |v| := by
  match exact, h, hu with
  | some (n, d, e), ⟨hd, hv⟩, hu =>
    simp only [underflow] at hu
    split at hu
    · cases hu
    · rename_i hb
      by_cases hn : n = 0
      · left; rw [← hv, hn]; simp
      · right
        rw [← hv]
        exact le_of_not_gt (fun hl => hb ((below_iff n d e hd).mpr ⟨hn, hl⟩))
  | none, h, _ => exact Or.inl h

def zero (negative : Bool) : Float32 :=
  Float32.ofModel (Float32.Model.pack (.zero (if negative then .negative else .positive)))

@[irreducible] def flushExact (exact
 : Option (Int × Nat × Int)) (rounded : Float32) : Float32 :=
  match underflow exact with
  | some negative => zero negative
  | none => rounded

theorem real_zero (negative : Bool) : real (zero negative) = 0 := real_signed_zero _

theorem finite_zero (negative : Bool) : (zero negative).isFinite = true := by
  cases negative <;> decide

theorem flushExact_cases (exact : Option (Int × Nat × Int)) (r : Float32) :
    flushExact exact r = r ∨ real (flushExact exact r) = 0 := by
  unfold flushExact
  split
  · exact Or.inr (real_zero _)
  · exact Or.inl rfl

theorem real_flushExact_congr (exact : Option (Int × Nat × Int)) (r s : Float32) (h : real r = real s) :
    real (flushExact exact r) = real (flushExact exact s) := by
  unfold flushExact
  split
  · rfl
  · exact h

theorem flushExact_abs_le (exact : Option (Int × Nat × Int)) (r : Float32) :

    |real (flushExact exact r)| ≤ |real r| := by
  rcases flushExact_cases exact r with h | h
  · rw [h]
  · rw [h, abs_zero]; exact abs_nonneg _

theorem finite_flushExact (exact : Option (Int × Nat × Int)) (r : Float32) (hr : r.isFinite=true) :

    (flushExact exact r).isFinite=true := by
  unfold flushExact
  split
  · exact finite_zero _
  · exact hr

theorem real_flushExact {exact : Option (Int × Nat × Int)} {v : ℝ} (h : Exact exact v) (r : Float32)
    (hr : real r = Model.roundAt FloatFormat.binary32 v) :
    real (flushExact exact r) = if |v|<threshold then 0 else Model.roundAt FloatFormat.binary32 v := by
  unfold flushExact
  split
  · rename_i s hu
    rw [real_zero, if_pos (underflow_some h hu)]
  · rename_i hu
    rw [hr]
    split
    · rename_i hl
      rcases underflow_none h hu with h0 | h0
      · rw [h0, Model.roundAt_zero]
      · exact absurd h0 (not_le.mpr hl)
    · rfl

theorem flushExact_error {exact : Option (Int × Nat × Int)} {v : ℝ} (h : Exact exact v) (r : Float32)
    (hr : real r = Model.roundAt FloatFormat.binary32 v) :
    |real (flushExact exact r)-v| ≤ threshold + epsilon v := by
  have er : |Model.roundAt FloatFormat.binary32 v-v| ≤ epsilon v := Model.abs_roundAt_sub_le _ _
  have ep : 0 ≤ epsilon v := (abs_nonneg _).trans er
  rw [real_flushExact h r hr]
  split
  · rw [zero_sub, abs_neg]
    linarith
  · linarith [threshold_pos]

def mul (x y : Float32) : Float32 :=
  flushExact (mulExact (model (flush x)) (model (flush y))) (flush x * flush y)
def add (x y : Float32) : Float32 := flush (flush x + flush y)
def fma (x y z : Float32) : Float32 :=
  flushExact (fmaExact (model (flush x)) (model (flush y)) (model (flush z))) (Float32.fma (flush x) (flush y) (flush z))
def div (x y : Float32) : Float32 :=
  flushExact (divExact (model (flush x)) (model (flush y))) (flush x / flush y)

theorem finite_flush_model (x : Float32) (hx : x.isFinite=true) : Model.isFinite (model (flush x)) = true := by
  rw [finite_model]; exact finite_flush x hx

theorem real_mul (x y : Float32)
 (ho : (flush x*flush y).isFinite=true) :
    real (mul x y) = if |real (flush x)*real (flush y)|<threshold then 0
      else Model.roundAt FloatFormat.binary32 (real (flush x)*real (flush y)) :=
  real_flushExact (exact_mul _ _) _ (Numerics.mul_real _ _ ho)

theorem real_div (x y : Float32) (hy : y.isFinite=true) (ho : (flush x/flush y).isFinite=true) :
    real (div x y) = if |real (flush x)/real (flush y)|<threshold then 0
      else Model.roundAt FloatFormat.binary32 (real (flush x)/real (flush y)) :=
  real_flushExact (exact_div _ _) _ (Numerics.div_real _ _ (finite_flush y hy) ho)

theorem real_fma (x y z : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true) (hz : z.isFinite=true)
    (ho : (Float32.fma (flush x) (flush y) (flush z)).isFinite=true) :
    real (fma x y z) = if |real (flush x)*real (flush y)+real (flush z)|<threshold then 0
      else Model.roundAt FloatFormat.binary32 (real (flush x)*real (flush y)+real (flush z)) :=
  real_flushExact (exact_fma _ _ _ (finite_flush_model x hx) (finite_flush_model y hy) (finite_flush_model z hz)) _
    (Numerics.fma_real _ _ _ (finite_flush x hx) (finite_flush y hy) (finite_flush z hz) ho)

theorem real_minNormal : real (Float32.ofBits 0x00800000) = threshold := by
  rw [real_unpack]
  change Model.unpackedToReal (.finite .positive 8388608 (-149) (by decide)) = threshold
  rw [Model.unpackedToReal_finite]
  norm_num [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow, threshold]
  change (8388608 : ℝ) * ((2 : ℝ)^149)⁻¹ = _
  norm_num


theorem round_tiny (v : ℝ) (hv : |v|<threshold) : |Model.roundAt FloatFormat.binary32 v| ≤ threshold := by
  have hm : Model.roundAt FloatFormat.binary32 threshold = threshold := by
    rw [← real_minNormal]
    exact Model.roundAt_toReal_eq _ (by rw [finite_model]; decide)
  obtain ⟨lo, hi⟩ := abs_lt.mp hv
  have l := Model.roundAt_mono FloatFormat.binary32 lo.le
  have u := Model.roundAt_mono FloatFormat.binary32 hi.le
  rw [Model.roundAt_neg, hm] at l
  rw [hm] at u
  exact abs_le.mpr ⟨l, u⟩

-- A rounded result above the threshold is not flushed.
theorem flushExact_eq {exact : Option (Int × Nat × Int)} {v : ℝ} (h : Exact exact v) (r : Float32)
    (hr : real r = Model.roundAt FloatFormat.binary32 v) (hn : threshold < |real r|) : flushExact exact r = r := by
  unfold flushExact
  split
  · rename_i s hu
    have := round_tiny v (underflow_some h hu)
    rw [← hr] at this
    linarith
  · rfl

theorem flushExact_lower {exact : Option (Int × Nat × Int)} {v : ℝ} (h : Exact exact v) (r : Float32)
    (hr : real r = Model.roundAt FloatFormat.binary32 v) (floor : ℝ) (normal : threshold < floor)
    (bound : floor ≤ real r) : floor ≤ real (flushExact exact r) := by
  rw [flushExact_eq h r hr (lt_of_lt_of_le normal (bound.trans (le_abs_self _)))]
  exact bound

-- Flushing a tiny rounded result moves it by at most the threshold.
theorem flushExact_raw_error {exact : Option (Int × Nat × Int)} {v : ℝ} (h : Exact exact v) (r : Float32)
    (hr : real r = Model.roundAt FloatFormat.binary32 v) : |real (flushExact exact r)-real r| ≤ threshold := by
  unfold flushExact
  split
  · rename_i s hu
    rw [real_zero, zero_sub, abs_neg, hr]
    exact round_tiny v (underflow_some h hu)
  · rw [sub_self, abs_zero]; exact threshold_pos.le

theorem mul_raw_error (x y : Float32) (ho : (flush x*flush y).isFinite=true) :
    |real (mul x y)-real (flush x*flush y)| ≤ threshold :=
  flushExact_raw_error (exact_mul _ _) _ (Numerics.mul_real _ _ ho)

theorem mul_lower (x y : Float32)
 (ho : (flush x*flush y).isFinite=true) (floor : ℝ) (normal : threshold < floor)
    (bound : floor ≤ Model.roundAt FloatFormat.binary32 (real (flush x)*real (flush y))) : floor ≤ real (mul x y) :=
  flushExact_lower (exact_mul _ _) _ (Numerics.mul_real _ _ ho) floor normal (by rwa [Numerics.mul_real _ _ ho])

theorem div_lower (x y : Float32) (hy : y.isFinite=true) (ho : (flush x/flush y).isFinite=true) (floor : ℝ)
    (normal : threshold < floor)
    (bound : floor ≤ Model.roundAt FloatFormat.binary32 (real (flush x)/real (flush y))) : floor ≤ real (div x y) :=
  flushExact_lower (exact_div _ _) _ (Numerics.div_real _ _ (finite_flush y hy) ho) floor normal
    (by rwa [Numerics.div_real _ _ (finite_flush y hy) ho])

theorem fma_lower (x y z : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true) (hz : z.isFinite=true)
    (ho : (Float32.fma (flush x) (flush y) (flush z)).isFinite=true) (floor : ℝ) (normal : threshold < floor)
    (bound : floor ≤ Model.roundAt FloatFormat.binary32 (real (flush x)*real (flush y)+real (flush z))) :
    floor ≤ real (fma x y z) :=
  flushExact_lower (exact_fma _ _ _ (finite_flush_model x hx) (finite_flush_model y hy) (finite_flush_model z hz)) _
    (Numerics.fma_real _ _ _ (finite_flush x hx) (finite_flush y hy) (finite_flush z hz) ho) floor normal
    (by rwa [Numerics.fma_real _ _ _ (finite_flush x hx) (finite_flush y hy) (finite_flush z hz) ho])

theorem mul_eq (x y : Float32)
 (ho : (flush x*flush y).isFinite=true)
    (hn : threshold < |real (flush x*flush y)|) : mul x y = flush x*flush y :=
  flushExact_eq (exact_mul _ _) _ (Numerics.mul_real _ _ ho) hn

theorem div_eq (x y : Float32) (hy : y.isFinite=true) (ho : (flush x/flush y).isFinite=true)
    (hn : threshold < |real (flush x/flush y)|) : div x y = flush x/flush y :=
  flushExact_eq (exact_div _ _) _ (Numerics.div_real _ _ (finite_flush y hy) ho) hn

theorem fma_eq (x y z : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true) (hz : z.isFinite=true)
    (ho : (Float32.fma (flush x) (flush y) (flush z)).isFinite=true)
    (hn : threshold < |real (Float32.fma (flush x) (flush y) (flush z))|) :
    fma x y z = Float32.fma (flush x) (flush y) (flush z) :=
  flushExact_eq (exact_fma _ _ _ (finite_flush_model x hx) (finite_flush_model y hy) (finite_flush_model z hz)) _
    (Numerics.fma_real _ _ _ (finite_flush x hx) (finite_flush y hy) (finite_flush z hz) ho) hn

theorem mul_finite (x y : Float32)
 (ho : (flush x*flush y).isFinite=true) : (mul x y).isFinite=true :=
  finite_flushExact _ _ ho
theorem div_finite (x y : Float32) (ho : (flush x/flush y).isFinite=true) : (div x y).isFinite=true :=
  finite_flushExact _ _ ho
theorem fma_finite (x y z : Float32) (ho : (Float32.fma (flush x) (flush y) (flush z)).isFinite=true) :
    (fma x y z).isFinite=true :=
  finite_flushExact _ _ ho

theorem flush_nonnegative (x : Float32) (hx : 0 ≤ real x) : 0 ≤ real (flush x) := by
  unfold flush
  split
  · split
    · rw [real_signed_zero]
    · exact hx
  · exact hx

theorem flush_eq_or_zero (x : Float32) : flush x = x ∨ real (flush x) = 0 := by
  unfold flush
  split
  · split
    · exact Or.inr (real_signed_zero _)
    · exact Or.inl rfl
  · exact Or.inl rfl

theorem flush_nonpositive (x : Float32) (hx : real x ≤ 0) : real (flush x) ≤ 0 := by
  rcases flush_eq_or_zero x with h | h
  · rwa [h]
  · rw [h]

theorem mul_nonpositive (x y : Float32) (hx : real x ≤ 0) (hy : 0 ≤ real y)
    (ho : (flush x * flush y).isFinite = true) : real (mul x y) ≤ 0 := by
  rw [real_mul x y ho]
  split
  · exact le_rfl
  have h := Model.roundAt_mono FloatFormat.binary32
    (mul_nonpos_of_nonpos_of_nonneg (flush_nonpositive x hx) (flush_nonnegative y hy))
  simpa only [Model.roundAt_zero] using h

theorem flush_eq_of_one_le (x : Float32) (hx : 1 ≤ real x) : flush x = x := by
  rcases flush_eq_or_zero x with h | h
  · exact h
  · have he := flush_error x
    rw [h, zero_sub, abs_neg, abs_of_nonneg (by linarith)] at he
    have ht : threshold < 1 := by norm_num [threshold]
    linarith

theorem flush_eq_of_threshold_lt (x : Float32) (hx : threshold < |real x|) : flush x = x := by
  rcases flush_eq_or_zero x with h | h
  · exact h
  · have he := flush_error x
    rw [h, zero_sub, abs_neg] at he
    linarith

theorem round_nonnegative (x : ℝ) (hx : 0 ≤ x) :
    0 ≤ Model.roundAt FloatFormat.binary32 x := by
  have h := Model.roundAt_mono FloatFormat.binary32 hx
  simpa only [Model.roundAt_zero] using h

theorem mul_nonnegative (x y : Float32)
    (hp : 0 ≤ real (flush x) * real (flush y)) (ho : (flush x * flush y).isFinite=true) :
    0 ≤ real (mul x y) := by
  rw [real_mul x y ho]
  split
  · exact le_rfl
  exact round_nonnegative _ hp

theorem add_nonnegative (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (hnx : 0 ≤ real x) (hny : 0 ≤ real y) (ho : (flush x + flush y).isFinite=true) :
    0 ≤ real (add x y) := by
  apply flush_nonnegative
  rw [Numerics.add_real _ _ (finite_flush x hx) (finite_flush y hy) ho]
  exact round_nonnegative _ (add_nonneg (flush_nonnegative x hnx) (flush_nonnegative y hny))

theorem fma_square_nonnegative (x acc : Float32) (hx : x.isFinite=true) (ha : acc.isFinite=true)
    (hna : 0 ≤ real acc) (ho : (Float32.fma (flush x) (flush x) (flush acc)).isFinite=true) :
    0 ≤ real (fma x x acc) := by
  rw [real_fma x x acc hx hx ha ho]
  split
  · exact le_rfl
  exact round_nonnegative _ (add_nonneg (mul_self_nonneg _) (flush_nonnegative acc hna))

theorem fma_nonnegative (x y z : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true) (hz : z.isFinite=true)
    (ho : (Float32.fma (flush x) (flush y) (flush z)).isFinite=true)
    (hp : 0 ≤ real (flush x)*real (flush y)+real (flush z)) : 0 ≤ real (fma x y z) := by
  rw [real_fma x y z hx hy hz ho]
  split
  · exact le_rfl
  exact round_nonnegative _ hp

theorem div_nonnegative (x y : Float32) (hy : y.isFinite=true)

    (hnx : 0 ≤ real x) (hny : 0 ≤ real y) (ho : (flush x / flush y).isFinite=true) :
    0 ≤ real (div x y) := by
  rw [real_div x y hy ho]
  split
  · exact le_rfl
  exact round_nonnegative _ (div_nonneg (flush_nonnegative x hnx) (flush_nonnegative y hny))


-- Adding a nonnegative value cannot decrease a positive normal addend, even
-- when input/output subnormals are flushed. Used to establish RMS positivity.
theorem add_ge_normal_right (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (hnx : 0 ≤ real x) (hny : threshold < real y) (ho : (flush x + flush y).isFinite=true) :
    real y ≤ real (add x y) := by
  have hyp : 0 < real y := lt_trans threshold_pos hny
  have hfy := flush_eq_of_threshold_lt y (by rwa [abs_of_pos hyp])
  have h := Model.roundAt_mono FloatFormat.binary32
    (show real y ≤ real (flush x) + real y by have := flush_nonnegative x hnx; linarith)
  have hround : Model.roundAt FloatFormat.binary32 (real y) = real y :=
    Model.roundAt_toReal_eq (model y) (by rw [finite_model]; exact hy)
  rw [hround] at h
  have hr : real y ≤ real (flush x + flush y) := by
    rw [Numerics.add_real _ _ (finite_flush x hx) (finite_flush y hy) ho, hfy]
    exact h
  have hfo := flush_eq_of_threshold_lt (flush x + flush y) (by
    rw [abs_of_pos (lt_of_lt_of_le hyp hr)]
    exact lt_of_lt_of_le hny hr)
  simpa only [add, hfo] using hr

theorem flush_one : flush (1 : Float32) = 1 := by
  apply flush_eq_of_one_le
  rw [real_one]

-- A sigmoid denominator cannot be subnormal: adding a nonnegative finite
-- exponential to one and rounding nearest-even still produces at least one.
theorem add_one_ge_one (x : Float32) (hx : x.isFinite=true) (hn : 0 ≤ real x)
    (hs : ((1 : Float32) + flush x).isFinite=true) : 1 ≤ real (add 1 x) := by
  have hi := flush_nonnegative x hn
  have hm := Model.roundAt_mono FloatFormat.binary32 (show (1 : ℝ) ≤ 1+real (flush x) by linarith)
  have hr := Model.roundAt_toReal_eq (model (1 : Float32)) (by rw [finite_model]; decide)
  rw [show Model.toReal (model (1 : Float32))=1 from real_one] at hr
  rw [hr] at hm
  have hs' : 1 ≤ real ((1 : Float32)+flush x) := by
    rw [Numerics.add_real _ _ (by decide) (finite_flush x hx) hs, real_one]
    exact hm
  unfold add
  rw [flush_one, flush_eq_of_one_le _ hs']
  exact hs'

theorem reciprocal_error (x : Float32) (hx : x.isFinite=true) (hn : 1 ≤ real x)
    (hq : ((1 : Float32)/x).isFinite=true) :
    |real (div 1 x)-1/real x| ≤ threshold + epsilon (1/real x) := by
  have e : |real (flushExact (divExact (model 1) (model x)) ((1 : Float32)/x))-real 1/real x| ≤
      threshold + epsilon (real 1/real x) :=
    flushExact_error (exact_div _ _) _ (Numerics.div_real _ _ hx hq)
  rw [real_one] at e
  unfold div
  rw [flush_one, flush_eq_of_one_le x hn]
  exact e

noncomputable def divBudget (x y : Float32) : ℝ :=
  threshold + epsilon (real (flush x)/real y) + threshold/|real y|

theorem div_normal_error (x y : Float32) (hy : y.isFinite=true) (hn : 1 ≤ real y)
    (ho : (flush x/y).isFinite=true) :
    |real (div x y)-real x/real y| ≤ divBudget x y := by
  have e : |real (flushExact (divExact (model (flush x)) (model y)) (flush x/y))-real (flush x)/real y| ≤
      threshold + epsilon (real (flush x)/real y) :=
    flushExact_error (exact_div _ _) _ (Numerics.div_real _ _ hy ho)
  have ei : |real (flush x)/real y-real x/real y| ≤ threshold/|real y| := by
    rw [← sub_div, abs_div]
    exact div_le_div_of_nonneg_right (flush_error x) (abs_nonneg _)
  unfold div divBudget
  rw [flush_eq_of_one_le y hn]
  calc
    _ = |(real (flushExact (divExact (model (flush x)) (model y)) (flush x/y))-real (flush x)/real y) +
        (real (flush x)/real y-real x/real y)| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add e ei)
      linarith

theorem product_input_error (x y : Float32) :
    |real (flush x)*real (flush y)-real x*real y| ≤ threshold*(|real x|+|real y|) := by
  have ex := flush_error x
  have ey := flush_error y
  have exy := mul_le_mul_of_nonneg_right ex (abs_nonneg (real y))
  have eyx := mul_le_mul_of_nonneg_left ey (abs_nonneg (real (flush x)))
  have hm := mul_le_mul_of_nonneg_right (flush_abs_le x) threshold_pos.le
  calc
    _ = |real (flush x)*(real (flush y)-real y)+(real (flush x)-real x)*real y| := by congr 1; ring
    _ ≤ _ := by
      have h := abs_add_le (real (flush x)*(real (flush y)-real y)) ((real (flush x)-real x)*real y)
      simp only [abs_mul] at h
      nlinarith

theorem mul_error (x y : Float32) (hf : (flush x*flush y).isFinite=true) :
    |real (mul x y)-real x*real y| ≤
      threshold + epsilon (real (flush x)*real (flush y)) + threshold*(|real x|+|real y|) := by
  have e : |real (mul x y)-real (flush x)*real (flush y)| ≤ threshold + epsilon (real (flush x)*real (flush y)) :=
    flushExact_error (exact_mul _ _) _ (Numerics.mul_real _ _ hf)
  have ei := product_input_error x y
  calc
    _ = |(real (mul x y)-real (flush x)*real (flush y)) +
        (real (flush x)*real (flush y)-real x*real y)| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add e ei)
      linarith

theorem add_error (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (hf : (flush x+flush y).isFinite=true) :
    |real (add x y)-(real x+real y)| ≤
      3*threshold + epsilon (real (flush x)+real (flush y)) := by
  have eo := flush_error (flush x+flush y)
  have er := Numerics.add_error (flush x) (flush y) (finite_flush x hx) (finite_flush y hy) hf
  have ex := flush_error x
  have ey := flush_error y
  unfold add
  calc
    _ = |(real (flush (flush x+flush y))-real (flush x+flush y)) +
        ((real (flush x+flush y)-(real (flush x)+real (flush y))) +
          ((real (flush x)-real x)+(real (flush y)-real y)))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add eo ((abs_add_le _ _).trans (add_le_add er
        ((abs_add_le _ _).trans (add_le_add ex ey)))))
      linarith

theorem fma_error (x y z : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true) (hz : z.isFinite=true)
    (hf : (Float32.fma (flush x) (flush y) (flush z)).isFinite=true) :
    |real (fma x y z)-(real x*real y+real z)| ≤
      2*threshold + epsilon (real (flush x)*real (flush y)+real (flush z)) + threshold*(|real x|+|real y|) := by
  have e : |real (fma x y z)-(real (flush x)*real (flush y)+real (flush z))| ≤
      threshold + epsilon (real (flush x)*real (flush y)+real (flush z)) :=
    flushExact_error (exact_fma _ _ _ (finite_flush_model x hx) (finite_flush_model y hy) (finite_flush_model z hz)) _
      (Numerics.fma_real _ _ _ (finite_flush x hx) (finite_flush y hy) (finite_flush z hz) hf)
  have ei := product_input_error x y
  have ez := flush_error z
  calc
    _ = |(real (fma x y z)-(real (flush x)*real (flush y)+real (flush z))) +
          ((real (flush x)*real (flush y)-real x*real y)+(real (flush z)-real z))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add e ((abs_add_le _ _).trans (add_le_add ei ez)))
      linarith

-- Kernel-checked distinctions from IEEE gradual underflow and from flushing
-- after rounding, also observed by the locked M1 Max probe. These finite
-- witnesses cannot establish all hardware cases.
theorem underflow_witness :
    (Float32.ofBits 0x00800000 * Float32.ofBits 0x3f000000).toBits = 0x00400000 ∧
    (mul (Float32.ofBits 0x00800000) (Float32.ofBits 0x3f000000)).toBits = 0 ∧
    (Float32.ofBits 0x00800000 * Float32.ofBits 0x3f7fffff).toBits = 0x00800000 ∧
    (mul (Float32.ofBits 0x00800000) (Float32.ofBits 0x3f7fffff)).toBits = 0 ∧
    (div (Float32.ofBits 0x00ffffff) (Float32.ofBits 0x40000000)).toBits = 0 ∧
    (fma (Float32.ofBits 0x00800000) (Float32.ofBits 0x00800000) (Float32.ofBits 0x80800000)).toBits = 0x80000000 := by
  decide +kernel

noncomputable def mulBudget (x y : Float32) : ℝ :=
  threshold + epsilon (real (flush x)*real (flush y)) + threshold*(|real x|+|real y|)

noncomputable def addBudget (x y : Float32) : ℝ :=
  3*threshold + epsilon (real (flush x)+real (flush y))

noncomputable def fmaBudget (x y z : Float32) : ℝ :=
  2*threshold + epsilon (real (flush x)*real (flush y)+real (flush z)) + threshold*(|real x|+|real y|)

theorem scaled_fma_error (code scale input acc : Float32)
    (hw : (flush code*flush scale).isFinite=true) (hx : input.isFinite=true) (ha : acc.isFinite=true)
    (ho : (Float32.fma (flush (mul code scale)) (flush input) (flush acc)).isFinite=true) :
    |real (fma (mul code scale) input acc)-(real code*real scale*real input+real acc)| ≤
      mulBudget code scale * |real input| + fmaBudget (mul code scale) input acc := by
  have em := mul_error code scale hw
  have ef := fma_error (mul code scale) input acc (mul_finite _ _ hw) hx ha ho

  have ep := mul_le_mul_of_nonneg_right em (abs_nonneg (real input))
  unfold mulBudget fmaBudget
  calc
    _ = |(real (fma (mul code scale) input acc)-(real (mul code scale)*real input+real acc)) +
        (real (mul code scale)-real code*real scale)*real input| := by congr 1; ring
    _ ≤ _ := by
      have e : |(real (mul code scale)-real code*real scale)*real input| ≤
          (threshold+epsilon (real (flush code)*real (flush scale))+threshold*(|real code|+|real scale|))* |real input| := by
        simpa only [abs_mul] using ep
      have h := (abs_add_le _ _).trans (add_le_add ef e)
      linarith


theorem flush_cases (x : Float32) :
    flush x = x ∨ (real (flush x) = 0 ∧ real x ≠ 0 ∧ |real x| < threshold) := by
  unfold flush
  split
  · rename_i s m e hm hu
    split
    · rename_i h
      right
      refine ⟨real_signed_zero _, ?_⟩
      rw [real_unpack, hu, Model.unpackedToReal_finite]
      obtain ⟨hsmall, rfl⟩ := h
      have hm' : (m : ℝ) < 8388608 := by exact_mod_cast hsmall
      have hp : (0 : ℝ) < m := by exact_mod_cast hm
      have hb : (FloatLib.Floats.Formats.Flocq.bpow FloatLib.Numerics.binaryRadix (-149) : ℝ) = (2 : ℝ)^(-149 : ℤ) := by
        simp [FloatLib.Floats.Formats.Flocq.bpow, FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal]
      have hq : (0 : ℝ) < (2 : ℝ)^(-149 : ℤ) := by positivity
      have ht : (8388608 : ℝ)*(2 : ℝ)^(-149 : ℤ) = threshold := by unfold threshold; norm_num
      rw [hb]
      constructor
      · cases s <;> simp [Model.modelSignBit] <;> positivity
      · rw [← ht]
        cases s <;> simp only [Model.modelSignBit, if_true, if_false, Bool.false_eq_true, abs_mul, abs_neg,
          abs_one, one_mul, abs_of_pos hp, abs_of_pos hq] <;> exact mul_lt_mul_of_pos_right hm' hq

    · exact Or.inl rfl
  · exact Or.inl rfl

theorem flush_eq_of_real_zero (x : Float32) (h : real x = 0) : flush x = x := by
  rcases flush_cases x with e | e
  · exact e
  · exact absurd h e.2.1

theorem flush_eq_of_threshold_le (x : Float32) (h : threshold ≤ |real x|) : flush x = x := by
  rcases flush_cases x with e | e
  · exact e
  · exact absurd h (not_le.mpr e.2.2)

theorem flush_flush (x : Float32) : flush (flush x) = flush x := by
  rcases flush_cases x with e | e
  · rw [e, e]
  · exact flush_eq_of_real_zero _ e.1

theorem flush_add (x y : Float32) : flush (add x y) = add x y := flush_flush _

theorem round_normal (v : ℝ) (hv : threshold ≤ |v|) : threshold ≤ |Model.roundAt FloatFormat.binary32 v| := by
  have hm : Model.roundAt FloatFormat.binary32 threshold = threshold := by
    rw [← real_minNormal]
    exact Model.roundAt_toReal_eq _ (by rw [finite_model]; decide)
  rcases le_abs'.mp hv with h | h
  · have l := Model.roundAt_mono FloatFormat.binary32 h
    rw [Model.roundAt_neg, hm] at l
    rw [abs_of_nonpos (by linarith [threshold_pos])]
    linarith
  · have u := Model.roundAt_mono FloatFormat.binary32 h
    rw [hm] at u
    rw [abs_of_pos (by linarith [threshold_pos])]
    exact u

theorem flush_eq_of_not_finite (x : Float32) (h : x.isFinite = false) : flush x = x := by
  unfold flush
  split
  · rename_i s m e hm hu
    change x.toModel.unpack.isFinite = false at h
    rw [hu] at h
    cases h
  · rfl

theorem flush_flushExact {exact : Option (Int × Nat × Int)} {v : ℝ} (h : Exact exact v) (r : Float32)
    (hr : r.isFinite = true → real r = Model.roundAt FloatFormat.binary32 v) :
    flush (flushExact exact r) = flushExact exact r := by
  unfold flushExact
  split
  · exact flush_eq_of_real_zero _ (real_zero _)
  · rename_i hu
    cases hf : r.isFinite
    · exact flush_eq_of_not_finite _ hf
    · rcases underflow_none h hu with h0 | h0
      · exact flush_eq_of_real_zero _ (by rw [hr hf, h0, Model.roundAt_zero])
      · exact flush_eq_of_threshold_le _ (by rw [hr hf]; exact round_normal _ h0)

theorem flush_mul (x y : Float32) : flush (mul x y) = mul x y :=
  flush_flushExact (exact_mul _ _) _ (Numerics.mul_real _ _)

theorem flush_div (x y : Float32) (hy : y.isFinite = true) : flush (div x y) = div x y :=
  flush_flushExact (exact_div _ _) _ (Numerics.div_real _ _ (finite_flush y hy))

theorem flush_fma (x y z : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) (hz : z.isFinite = true) :
    flush (fma x y z) = fma x y z :=
  flush_flushExact (exact_fma _ _ _ (finite_flush_model x hx) (finite_flush_model y hy) (finite_flush_model z hz)) _
    (Numerics.fma_real _ _ _ (finite_flush x hx) (finite_flush y hy) (finite_flush z hz))

end Inference.Contracts.Mlx.FlushToZero
