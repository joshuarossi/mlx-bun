import contracts.mlx.BFloat16ConversionBounds
import contracts.mlx.BFloat16DyadicBounds
import contracts.mlx.DyadicBounds
import contracts.mlx.RelativeRounding
import contracts.mlx.NativeDivisionBounds
import contracts.mlx.NativeMultiplication
import contracts.mlx.Float32OverflowMargin

namespace Inference.Contracts.Mlx.BFloat16Log1p
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

def minusOne : Float32 := Float32.ofBits 0xbf800000

/- MLX utils.h:327 log1p(bfloat16_t) as compiled into the fused LogAddExp
   (AIR of the compute_g closure): xp1 = fadd float(x), 1; xp1 == +inf gives
   +inf; xp1 == 1 gives x; otherwise fptrunc(fmul(fdiv(log xp1, fadd xp1, -1),
   float(x))). The comparisons are fcmp oeq against +inf and 1, which agree
   with word equality on every input. -/
def value (log : Float32 → Float32) (divide : Float32 → Float32 → Float32) (x : BF) : BF :=
  let w := BFloat16.widen x
  let xp1 := FlushToZero.add w 1
  if xp1 = Float32.inf then Model.posInf FloatFormat.bfloat16
  else if xp1 = 1 then x
  else BFloat16.narrow (FlushToZero.mul (divide (log xp1) (FlushToZero.add xp1 minusOne)) w)

theorem eq_of_real (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (h : real x = real y) (h0 : real x ≠ 0) : x = y := by
  have hm : model x = model y := Model.eq_of_toReal_eq_of_nonzero
    (by rw [finite_model]; exact hx) (by rw [finite_model]; exact hy) h h0
  have ht := Model.ofFloat32Model_injective hm
  cases x; cases y
  exact congrArg _ ht

-- A binary32 value above one is at least the next grid point 1 + 2^-23.
theorem above_one (y : Float32) (hy : y.isFinite = true) (h : 1 < real y) : 1 + (2 : ℝ)^(-23 : Int) ≤ real y := by
  have hf : Model.isFinite (model y) = true := by rw [finite_model]; exact hy
  obtain ⟨d, hd⟩ := Model.exists_toDyadic?_of_isFinite hf
  have hr : real y = d.toReal := by simp only [real, Model.toReal_eq, hd]
  have hs : d.significand < 2^24 := Model.toDyadic?_significand_lt (model y) hd
  have hp := zpow_pos (by norm_num : (0:ℝ) < 2) d.exponent
  have hc : (((Int.ofNat d.significand : ℤ)) : ℝ) = (d.significand : ℝ) := by simp
  have hneg : d.negative = false := by
    cases hn : d.negative
    · rfl
    · exfalso
      have : d.toReal ≤ 0 := by
        simp only [FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand, hn, ite_true]
        push_cast; rw [hc]
        nlinarith [(Nat.cast_nonneg d.significand : (0:ℝ) ≤ d.significand)]
      linarith
  have hv : real y = (d.significand : ℝ) * (2 : ℝ)^d.exponent := by
    rw [hr]
    simp only [FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand, hneg,
      Bool.false_eq_true, ite_false]
    rw [hc]
  have hsr : (d.significand : ℝ) < (2 : ℝ)^(24 : Nat) := by exact_mod_cast hs
  have he : -23 ≤ d.exponent := by
    by_contra hlt
    have hle : d.exponent ≤ -24 := by omega
    have h2 : (2 : ℝ)^d.exponent ≤ (2 : ℝ)^(-24 : Int) := zpow_le_zpow_right₀ (by norm_num) hle
    have : (d.significand : ℝ) * (2 : ℝ)^d.exponent < 1 := by
      calc (d.significand : ℝ) * (2 : ℝ)^d.exponent ≤ (d.significand : ℝ) * (2 : ℝ)^(-24 : Int) :=
            mul_le_mul_of_nonneg_left h2 (Nat.cast_nonneg _)
        _ < (2 : ℝ)^(24 : Nat) * (2 : ℝ)^(-24 : Int) := by
            apply mul_lt_mul_of_pos_right hsr; positivity
        _ = 1 := by norm_num
    linarith
  obtain ⟨k, hk⟩ : ∃ k : Nat, d.exponent = -23 + k := ⟨(d.exponent + 23).toNat, by omega⟩
  have hN : real y = ((d.significand * 2^k : Nat) : ℝ) * (2 : ℝ)^(-23 : Int) := by
    rw [hv, hk, zpow_add₀ (by norm_num : (2:ℝ) ≠ 0), zpow_natCast]
    push_cast; ring
  have hgt : (2^23 : Nat) < d.significand * 2^k := by
    have : (2 : ℝ)^(23 : Nat) < ((d.significand * 2^k : Nat) : ℝ) := by
      have h23 : (2 : ℝ)^(23 : Nat) * (2 : ℝ)^(-23 : Int) = 1 := by norm_num
      have hq : 0 < (2 : ℝ)^(-23 : Int) := by positivity
      nlinarith
    exact_mod_cast this
  have hge : ((2^23 + 1 : Nat) : ℝ) ≤ ((d.significand * 2^k : Nat) : ℝ) := by exact_mod_cast hgt
  rw [hN]
  have hq : 0 < (2 : ℝ)^(-23 : Int) := by positivity
  calc 1 + (2 : ℝ)^(-23 : Int) = ((2^23 + 1 : Nat) : ℝ) * (2 : ℝ)^(-23 : Int) := by push_cast; norm_num
    _ ≤ _ := mul_le_mul_of_nonneg_right hge hq.le

theorem real_minusOne : real minusOne = -1 := by
  have h : model minusOne = Model.neg (model 1) := by decide
  rw [real, h, Model.toReal_neg _ (by decide)]
  change -real 1 = -1
  rw [real_one]

private theorem grid_upper (v : ℝ) (hv : 0 ≤ v) :
    Model.roundAt FloatFormat.binary32 v ≤ v + (2 : ℝ)^(-24 : Int)*v + (2 : ℝ)^(-150 : Int) := by
  have h := RelativeRounding.binary32_grid v
  rw [abs_of_nonneg hv] at h
  linarith [(abs_le.mp h).2]

private theorem grid_lower (v : ℝ) (hv : 0 ≤ v) :
    v - (2 : ℝ)^(-24 : Int)*v - (2 : ℝ)^(-150 : Int) ≤ Model.roundAt FloatFormat.binary32 v := by
  have h := RelativeRounding.binary32_grid v
  rw [abs_of_nonneg hv] at h
  linarith [(abs_le.mp h).1]

-- xp1 - 1 for xp1 in [1 + 2^-23, 2]: within a factor of two of the exact
-- difference and inside [2^-23, 1].
theorem shifted (y : Float32) (hy : y.isFinite = true) (gap : 1 + (2 : ℝ)^(-23 : Int) ≤ real y) (hi : real y ≤ 2) :
    (y + minusOne).isFinite = true ∧ (2 : ℝ)^(-23 : Int) ≤ real (y + minusOne) ∧ real (y + minusOne) ≤ 1 ∧
      (real y - 1) / 2 ≤ real (y + minusOne) := by
  have hm : (minusOne).isFinite = true := by decide
  have hfy : Model.isFinite (model y) = true := by rw [finite_model]; exact hy
  have hfin : (y + minusOne).isFinite = true := by
    rw [← finite_model, Float32Bounds.add_model _ _ hy hm]
    apply Model.isFinite_add_of_abs_add_le_posMaxFinite _ _ (by decide) hfy (by rw [finite_model]; exact hm)
    change |real y| + |real minusOne| ≤ _
    rw [real_minusOne, abs_neg, abs_one, abs_of_nonneg (by linarith [show (0:ℝ) < (2 : ℝ)^(-23 : Int) by positivity])]
    have hmax := Float32OverflowMargin.maximum_value
    unfold Float32OverflowMargin.maximum at hmax
    rw [hmax]
    norm_num
    linarith
  have hr : real (y + minusOne) = Model.roundAt FloatFormat.binary32 (real y - 1) := by
    rw [Numerics.add_real _ _ hy hm hfin, real_minusOne, ← sub_eq_add_neg]
  have small := DyadicBounds.ceiling_range 1 (-23) (by decide) (by decide) (by decide)
  have rs : Model.roundAt FloatFormat.binary32 ((2 : ℝ)^(-23 : Int)) = (2 : ℝ)^(-23 : Int) := by
    have := Model.roundAt_toReal_eq (model (DyadicBounds.ceiling 1 (-23))) (by rw [finite_model]; exact small.1)
    change Model.roundAt _ (real _) = real _ at this
    rwa [small.2, Nat.cast_one, one_mul] at this
  have r1 : Model.roundAt FloatFormat.binary32 1 = 1 := by
    have := Model.roundAt_toReal_eq (model 1) (by decide); rwa [show Model.toReal (model 1) = 1 from real_one] at this
  refine ⟨hfin, ?_, ?_, ?_⟩
  · rw [hr, ← rs]; exact Model.roundAt_mono _ (by linarith)
  · rw [hr, ← r1]; exact Model.roundAt_mono _ (by linarith)
  · rw [hr]
    have hl := grid_lower (real y - 1) (by have : (0:ℝ) < (2 : ℝ)^(-23 : Int) := by positivity
                                           linarith)
    have p150 : (2 : ℝ)^(-150 : Int) ≤ (2 : ℝ)^(-23 : Int) / 8 := by
      rw [show (2 : ℝ)^(-23 : Int) / 8 = (2 : ℝ)^(-26 : Int) by
        rw [show (-26 : Int) = -23 + -3 by norm_num, zpow_add₀ (by norm_num : (2:ℝ) ≠ 0)]; norm_num]
      exact zpow_le_zpow_right₀ (by norm_num) (by norm_num)
    have p24 : (2 : ℝ)^(-24 : Int) ≤ 1/8 := by
      rw [show (1:ℝ)/8 = (2:ℝ)^(-3 : Int) by norm_num]; exact zpow_le_zpow_right₀ (by norm_num) (by norm_num)
    have hu : (2 : ℝ)^(-23 : Int) ≤ real y - 1 := by linarith
    norm_num at hl p150 p24 hu ⊢
    nlinarith

theorem eight : Model.isFinite (BFloat16DyadicBounds.ceiling 1 3) = true ∧
    Model.toReal (BFloat16DyadicBounds.ceiling 1 3) = 8 := by
  have h := BFloat16DyadicBounds.ceiling_range 1 3 (by decide) (by decide) (by decide)
  exact ⟨h.1, h.2.trans (by norm_num)⟩

-- On [0,1] the result is finite in [0,8], given fast_log's unit-interval
-- clause and correctly rounded division by divisors in [2^-23, 1].
theorem range (log : Float32 → Float32) (divide : Float32 → Float32 → Float32)
    (hlog : ∀ y, y.isFinite = true → 1 ≤ real y → real y ≤ 2 →
      (log y).isFinite = true ∧ 0 ≤ real (log y) ∧ real (log y) ≤ 1)
    (hdiv : ∀ a b, a.isFinite = true → b.isFinite = true → (2 : ℝ)^(-23 : Int) ≤ real b → real b ≤ 1 →
      divide a b = FlushToZero.div a b)
    (x : BF) (hx : Model.isFinite x = true) (h0 : 0 ≤ Model.toReal x) (h1 : Model.toReal x ≤ 1) :
    Model.isFinite (value log divide x) = true ∧ 0 ≤ Model.toReal (value log divide x) ∧
      Model.toReal (value log divide x) ≤ 8 := by
  have hw := BFloat16.widen_finite x hx
  have hwr := BFloat16.widen_real x hx
  have hfw := FlushToZero.finite_flush _ hw
  have hx' := FlushToZero.flush_nonnegative _ (show 0 ≤ real (BFloat16.widen x) by rw [hwr]; exact h0)
  have hx1 : real (FlushToZero.flush (BFloat16.widen x)) ≤ 1 :=
    (le_abs_self _).trans ((FlushToZero.flush_abs_le _).trans (by rw [hwr, abs_of_nonneg h0]; exact h1))
  -- xp1 = flush w + 1 in [1, 2]
  have two := DyadicBounds.ceiling_range 1 1 (by decide) (by decide) (by decide)
  have hs := Float32Bounds.add_range (BFloat16.widen x) 1 (DyadicBounds.ceiling 1 1) hw (by decide) two.1
    (by rw [two.2, real_one, abs_one, abs_of_nonneg (show 0 ≤ real (BFloat16.widen x) by rw [hwr]; exact h0), hwr]
        norm_num; linarith)
  have hsf : (FlushToZero.flush (BFloat16.widen x) + 1).isFinite = true := by
    simpa only [FlushToZero.flush_one] using hs.1
  have hsr : real (FlushToZero.flush (BFloat16.widen x) + 1) =
      Model.roundAt FloatFormat.binary32 (real (FlushToZero.flush (BFloat16.widen x)) + 1) := by
    rw [Numerics.add_real _ _ hfw (by decide) hsf, real_one]
  have r1 : Model.roundAt FloatFormat.binary32 1 = 1 := by
    have := Model.roundAt_toReal_eq (model 1) (by decide); rwa [show Model.toReal (model 1) = 1 from real_one] at this
  have r2 : Model.roundAt FloatFormat.binary32 2 = 2 := by
    have := Model.roundAt_toReal_eq (model (DyadicBounds.ceiling 1 1)) (by rw [finite_model]; exact two.1)
    change Model.roundAt _ (real _) = real _ at this
    rwa [two.2, show ((1 : Nat) : ℝ) * (2 : ℝ)^(1 : Int) = 2 by norm_num] at this
  have slo : 1 ≤ real (FlushToZero.flush (BFloat16.widen x) + 1) := by
    rw [hsr, ← r1]; exact Model.roundAt_mono _ (by linarith)
  have shi : real (FlushToZero.flush (BFloat16.widen x) + 1) ≤ 2 := by
    rw [hsr, ← r2]; exact Model.roundAt_mono _ (by linarith)
  have hxp : FlushToZero.add (BFloat16.widen x) 1 = FlushToZero.flush (BFloat16.widen x) + 1 := by
    unfold FlushToZero.add; rw [FlushToZero.flush_one, FlushToZero.flush_eq_of_one_le _ slo]
  unfold value
  simp only
  rw [hxp]
  have hninf : FlushToZero.flush (BFloat16.widen x) + 1 ≠ Float32.inf := by
    intro e; rw [e] at hsf; exact absurd hsf (by decide)
  rw [if_neg hninf]
  by_cases hone : FlushToZero.flush (BFloat16.widen x) + 1 = 1
  · rw [if_pos hone]; exact ⟨hx, h0, h1.trans (by norm_num)⟩
  rw [if_neg hone]
  set xp1 := FlushToZero.flush (BFloat16.widen x) + 1 with hxp1
  set x' := real (FlushToZero.flush (BFloat16.widen x)) with hx'def
  have hgt : 1 < real xp1 := by
    rcases slo.lt_or_eq with h | h
    · exact h
    · exact absurd (eq_of_real _ _ hsf (by decide) (by rw [← h, real_one]) (by rw [← h]; norm_num)) hone
  have gap := above_one xp1 hsf hgt
  -- d = xp1 - 1 in [2^-23, 1], at least half the exact difference
  have hsh := shifted xp1 hsf gap shi
  have tpos : FlushToZero.threshold < |real (xp1 + minusOne)| := by
    rw [abs_of_pos (lt_of_lt_of_le (by positivity) hsh.2.1)]
    have h126 : (2 : ℝ)^(-126 : Int) < (2 : ℝ)^(-23 : Int) := zpow_lt_zpow_right₀ (by norm_num) (by norm_num)
    exact lt_of_lt_of_le h126 hsh.2.1
  have hd : FlushToZero.add xp1 minusOne = xp1 + minusOne := by
    unfold FlushToZero.add
    rw [FlushToZero.flush_eq_of_one_le _ slo,
      FlushToZero.flush_eq_of_threshold_lt minusOne (by rw [real_minusOne, abs_neg, abs_one]; exact FlushToZero.threshold_lt_one),
      FlushToZero.flush_eq_of_threshold_lt _ tpos]
  rw [hd]
  set d := xp1 + minusOne with hddef
  have hdf := hsh.1
  have dlo : (2 : ℝ)^(-23 : Int) ≤ real d := hsh.2.1
  have dhi : real d ≤ 1 := hsh.2.2.1
  have dhalf : (real xp1 - 1) / 2 ≤ real d := hsh.2.2.2
  have dpos : 0 < real d := lt_of_lt_of_le (by positivity) dlo
  -- x' ≤ 4d
  have hround' : x' + 1 - (2 : ℝ)^(-24 : Int)*(x'+1) - (2 : ℝ)^(-150 : Int) ≤ real xp1 := by
    rw [hxp1, hsr]; exact grid_lower _ (by linarith)
  have p24 : (2 : ℝ)^(-24 : Int) = (2 : ℝ)^(-23 : Int) / 2 := by
    rw [show (-24 : Int) = -23 + -1 by norm_num, zpow_add₀ (by norm_num : (2:ℝ) ≠ 0)]; norm_num
  have p150 : (2 : ℝ)^(-150 : Int) ≤ (2 : ℝ)^(-23 : Int) / 4 := by
    rw [show (2 : ℝ)^(-23 : Int) / 4 = (2 : ℝ)^(-25 : Int) by
      rw [show (-25 : Int) = -23 + -2 by norm_num, zpow_add₀ (by norm_num : (2:ℝ) ≠ 0)]; norm_num]
    exact zpow_le_zpow_right₀ (by norm_num) (by norm_num)
  have e23 : 0 < (2 : ℝ)^(-23 : Int) := by positivity
  have three : x' ≤ 4 * real d := by
    have hu : x' - (2 : ℝ)^(-23 : Int) - (2 : ℝ)^(-150 : Int) ≤ real xp1 - 1 := by
      have : (2 : ℝ)^(-24 : Int) * (x'+1) ≤ (2 : ℝ)^(-24 : Int) * 2 :=
        mul_le_mul_of_nonneg_left (by linarith) (by positivity)
      rw [p24] at this
      norm_num at this hround' ⊢
      linarith
    by_cases hb : 4 * (2 : ℝ)^(-23 : Int) ≤ x'
    · norm_num at hu dhalf hb p150 ⊢
      nlinarith
    · linarith
  -- L = log xp1 in [0, 1]
  obtain ⟨hLf, hL0, hL1⟩ := hlog xp1 hsf slo shi
  rw [hdiv _ _ hLf hdf dlo dhi]
  set L := log xp1 with hLdef
  have hfL := FlushToZero.finite_flush _ hLf
  have fL0 := FlushToZero.flush_nonnegative _ hL0
  have fL1 : real (FlushToZero.flush L) ≤ 1 :=
    (le_abs_self _).trans ((FlushToZero.flush_abs_le _).trans (by rw [abs_of_nonneg hL0]; exact hL1))
  have hfd : FlushToZero.flush d = d := FlushToZero.flush_eq_of_threshold_lt _ (by rw [hddef]; exact tpos)
  have qbound : real (FlushToZero.flush L) / real d ≤ (2 : ℝ)^(23 : Nat) := by
    rw [div_le_iff₀ dpos]
    have : (2 : ℝ)^(23 : Nat) * (2 : ℝ)^(-23 : Int) = 1 := by norm_num
    nlinarith
  have hqo : (FlushToZero.flush L / FlushToZero.flush d).isFinite = true := by
    rw [hfd]
    apply NativeDivisionBounds.finite _ _ hfL hdf (ne_of_gt dpos)
    rw [abs_of_nonneg (div_nonneg fL0 dpos.le)]
    exact qbound.trans_lt (by norm_num)
  have hq0 := FlushToZero.div_nonnegative L d hdf hL0 dpos.le hqo
  have hqf := FlushToZero.div_finite L d hqo
  have hqr := FlushToZero.real_div L d hdf hqo
  rw [hfd] at hqr
  set q := FlushToZero.div L d with hqdef
  have qv0 : 0 ≤ real (FlushToZero.flush L) / real d := div_nonneg fL0 dpos.le
  have qup : real q ≤ real (FlushToZero.flush L) / real d * (1 + (2 : ℝ)^(-24 : Int)) + (2 : ℝ)^(-150 : Int) := by
    rw [hqr]
    split
    · positivity
    · have := grid_upper _ qv0; linarith
  -- m = q * w
  have hfq := FlushToZero.finite_flush _ hqf
  have fq0 := FlushToZero.flush_nonnegative _ hq0
  have fqq : real (FlushToZero.flush q) ≤ real q :=
    (le_abs_self _).trans ((FlushToZero.flush_abs_le _).trans (by rw [abs_of_nonneg hq0]))
  have q24 : real q ≤ (2 : ℝ)^(24 : Nat) := by
    have h1 : (2 : ℝ)^(-24 : Int) ≤ 1/2 := by norm_num
    have h2 : (2 : ℝ)^(-150 : Int) ≤ 1 := by norm_num
    have h3 : real (FlushToZero.flush L) / real d * (1 + (2 : ℝ)^(-24 : Int)) ≤ (2 : ℝ)^(23 : Nat) * (3/2) :=
      mul_le_mul qbound (by linarith) (by positivity) (by positivity)
    have : (2 : ℝ)^(23 : Nat) * (3/2) + 1 ≤ (2 : ℝ)^(24 : Nat) := by norm_num
    linarith
  have hmo' : (FlushToZero.flush q * FlushToZero.flush (BFloat16.widen x)).isFinite = true := by
    rw [← finite_model, NativeMultiplication.float32_model _ _ hfq hfw]
    apply Model.isFinite_mul_of_abs_mul_le_posMaxFinite _ _ (by decide)
      (by rw [finite_model]; exact hfq) (by rw [finite_model]; exact hfw)
    change |real (FlushToZero.flush q)| * |x'| ≤ _
    have hmax := Float32OverflowMargin.maximum_value
    unfold Float32OverflowMargin.maximum at hmax
    rw [hmax, abs_of_nonneg fq0, abs_of_nonneg hx']
    have : real (FlushToZero.flush q) * x' ≤ (2 : ℝ)^(24 : Nat) * 1 :=
      mul_le_mul (fqq.trans q24) hx1 hx' (by positivity)
    have h104 : (2 : ℝ)^(24 : Nat) ≤ 16777215 * (2 : ℝ)^(104 : Int) := by norm_num
    linarith
  have hm0 := FlushToZero.mul_nonnegative q (BFloat16.widen x) (mul_nonneg fq0 hx') hmo'
  have hmr := FlushToZero.real_mul q (BFloat16.widen x) hmo'
  have hmf := FlushToZero.mul_finite q (BFloat16.widen x) hmo'
  have prod : real (FlushToZero.flush q) * x' ≤ 5 := by
    have hLd : real (FlushToZero.flush L) / real d * x' ≤ 4 := by
      rw [div_mul_eq_mul_div, div_le_iff₀ dpos]
      nlinarith
    have hq' := fqq.trans qup
    have hx'3 : x' ≤ 4 := by linarith
    have s24 : (2 : ℝ)^(-24 : Int) ≤ 1/16 := by
      rw [show (1:ℝ)/16 = (2:ℝ)^(-4 : Int) by norm_num]; exact zpow_le_zpow_right₀ (by norm_num) (by norm_num)
    have s150 : (2 : ℝ)^(-150 : Int) ≤ 1/64 := by
      rw [show (1:ℝ)/64 = (2:ℝ)^(-6 : Int) by norm_num]; exact zpow_le_zpow_right₀ (by norm_num) (by norm_num)
    calc real (FlushToZero.flush q) * x'
        ≤ (real (FlushToZero.flush L) / real d * (1 + (2 : ℝ)^(-24 : Int)) + (2 : ℝ)^(-150 : Int)) * x' :=
          mul_le_mul_of_nonneg_right hq' hx'
      _ = (real (FlushToZero.flush L) / real d * x') * (1 + (2 : ℝ)^(-24 : Int)) + (2 : ℝ)^(-150 : Int) * x' := by ring
      _ ≤ 4 * (1 + 1/16) + (1/64) * 4 := by
          apply add_le_add
          · exact mul_le_mul hLd (by linarith) (by positivity) (by norm_num)
          · exact mul_le_mul s150 hx'3 hx' (by norm_num)
      _ ≤ 5 := by norm_num
  have mle : real (FlushToZero.mul q (BFloat16.widen x)) ≤ 8 := by
    rw [hmr]
    split
    · norm_num
    · change Model.roundAt FloatFormat.binary32 (real (FlushToZero.flush q) * x') ≤ 8
      have g := grid_upper _ (mul_nonneg fq0 hx')
      have g1 : (2 : ℝ)^(-24 : Int) * (real (FlushToZero.flush q) * x') ≤ (1/16) * 5 :=
        mul_le_mul (by norm_num) prod (mul_nonneg fq0 hx') (by norm_num)
      have g2 : (2 : ℝ)^(-150 : Int) ≤ 1 := by norm_num
      have p5 := prod
      clear_value x'
      generalize real (FlushToZero.flush q) * x' = v at g g1 p5 ⊢
      generalize (2 : ℝ)^(-24 : Int) = a at g g1
      generalize (2 : ℝ)^(-150 : Int) = e at g g2
      linarith
  have hn := BFloat16ConversionBounds.narrow_range (FlushToZero.mul q (BFloat16.widen x)) (BFloat16DyadicBounds.ceiling 1 3)
    hmf eight.1 (by rw [eight.2, abs_of_nonneg hm0]; exact mle)
  rw [eight.2] at hn
  refine ⟨hn.1, ?_, (le_abs_self _).trans hn.2⟩
  rw [BFloat16.narrow, Model.cast_eq_roundAt (by decide) (by decide) (model _) (by rw [finite_model]; exact hmf) hn.1]
  have := Model.roundAt_mono FloatFormat.bfloat16 hm0
  rwa [Model.roundAt_zero] at this

end Inference.Contracts.Mlx.BFloat16Log1p
