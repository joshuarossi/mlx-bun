import contracts.mlx.NormalizationEnergyBounds
import contracts.mlx.NormalizationFloorBounds
import contracts.mlx.RsqrtBounds
import contracts.mlx.DyadicCover

namespace Inference.Contracts.Mlx.NormalizationEnergyScale
open Numerics NormalizationExecution
open scoped BigOperators

noncomputable def energy (input : Fin n → Float32) : ℝ := ∑ i, real (input i)^2

theorem energy_nonnegative (input : Fin n → Float32) : 0 ≤ energy input := by
  exact Finset.sum_nonneg (fun _ _ => sq_nonneg _)

theorem energy_upper (input : Fin n → Float32) (hx : ∀ i, |real (input i)| ≤ (2 : ℝ)^56) :
    energy input ≤ (n : ℝ)*(2 : ℝ)^(112 : Int) := by
  have h : ∀ i, real (input i)^2 ≤ (2 : ℝ)^(112 : Int) := by
    intro i
    have hs := (sq_le_sq₀ (abs_nonneg _) (by positivity : (0 : ℝ) ≤ (2 : ℝ)^56)).mpr (hx i)
    simpa only [sq_abs, ← pow_mul, show 56*2=112 from by decide, zpow_ofNat] using hs
  have hs := Finset.sum_le_sum (s := Finset.univ) (fun i _ => h i)
  simpa only [energy, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] using hs

theorem half_energy (input : Fin n → Float32) (expr : SquaredSum.Expr n)
    (hx : ∀ i, |real (input i)| ≤ (2 : ℝ)^56) (hf : SquaredSum.Finite input expr)
    (hs : SquaredSumEnergyBounds.sites expr ≤ 16384)
    (coverage : (SquaredSum.indices expr).Perm (List.finRange n))
    (large : (2 : ℝ)^(-40 : Int) ≤ energy input) :
    energy input/2 ≤ real (FlushToZero.flush (sum input expr)) := by
  have h := SquaredSumEnergyBounds.sum_lower input expr hx hf hs coverage
  rw [← Fin.sum_univ_def] at h
  have he := (abs_le.mp (FlushToZero.flush_error (sum input expr))).1
  change -(FlushToZero.threshold) ≤ real (FlushToZero.flush (sum input expr))-real (sum input expr) at he
  change (1023/1024 : ℝ)*energy input-(2 : ℝ)^(-46 : Int) ≤ real (sum input expr) at h
  norm_num [FlushToZero.threshold] at he
  norm_num at h large
  linarith

-- Transfer a representable mean floor through the directed division contract
-- and rounded epsilon addition. This does not assume exact IEEE division.
theorem denominator_floor (divide : Float32 → Float32 → Float32)
    (division : DivisionDirectedBounds.Contract divide) (input : Fin n → Float32)
    (expr : SquaredSum.Expr n) (width eps floor : Float32)
    (hf : ReductionFinite divide input expr width eps) (ff : floor.isFinite = true)
    (fn : FlushToZero.threshold < real floor)
    (bound : real floor ≤ real (FlushToZero.flush (sum input expr))/real width) :
    real floor ≤ real (denominator divide input expr width eps) := by
  have hd : Division.DivisorDomain width :=
    ⟨by rw [hf.hWidthValue]; exact_mod_cast hf.hPositiveWidth, hf.hWidthUpper⟩
  have hm := division.lower (sum input expr) width floor
    (SquaredSum.finite_evaluate input expr hf.hSum) hf.hWidth hd ff fn bound
  have hmf := SquaredSumDyadicBounds.flush_lower floor (mean divide input expr width) fn hm
  apply SquaredSumDyadicBounds.flush_lower floor _ fn
  rw [Numerics.add_real _ _ (FlushToZero.finite_flush _ hf.hMean)
    (FlushToZero.finite_flush _ hf.hEps) hf.hDenominator]
  apply SquaredSumDyadicBounds.round_lower floor ff
  exact hmf.trans (le_add_of_nonneg_right (FlushToZero.flush_nonnegative eps
    (FlushToZero.threshold_pos.trans hf.hNormalEps).le))

theorem denominator_energy (divide : Float32 → Float32 → Float32)
    (divError : Float32 → Float32 → ℝ) (accuracy : Division.Contract divide divError)
    (division : DivisionDirectedBounds.Contract divide) (input : Fin n → Float32)
    (expr : SquaredSum.Expr n) (width eps : Float32)
    (hf : ReductionFinite divide input expr width eps)
    (hx : ∀ i, |real (input i)| ≤ (2 : ℝ)^56)
    (hs : SquaredSumEnergyBounds.sites expr ≤ 16384)
    (coverage : (SquaredSum.indices expr).Perm (List.finRange n))
    (epsLower : (2 : ℝ)^(-40 : Int) ≤ real eps) :
    energy input/(4*(n : ℝ)) ≤ real (denominator divide input expr width eps) := by
  have np : (0 : ℝ) < n := by exact_mod_cast hf.hPositiveWidth
  have n1 : (1 : ℝ) ≤ n := by exact_mod_cast hf.hPositiveWidth
  have en := energy_nonnegative input
  let q := energy input/(n : ℝ)
  have qn : 0 ≤ q := div_nonneg en np.le
  have eqn : q*(n : ℝ) = energy input := div_mul_cancel₀ _ (ne_of_gt np)
  have qu : q ≤ (2 : ℝ)^(112 : Int) := (div_le_iff₀ np).mpr (by
    simpa only [mul_comm] using energy_upper input hx)
  have hm : 0 ≤ real (mean divide input expr width) := accuracy.nonnegative _ _
    (SquaredSum.finite_evaluate input expr hf.hSum) hf.hWidth
    (SquaredSum.nonnegative input expr hf.hSum)
    ⟨by rw [hf.hWidthValue]; exact n1, hf.hWidthUpper⟩ hf.hMean
  have epsBound := FlushToZero.add_ge_normal_right (mean divide input expr width) eps
    hf.hMean hf.hEps hm hf.hNormalEps hf.hDenominator
  have goalEq : energy input/(4*(n : ℝ)) = q/4 := by dsimp [q]; ring
  rw [goalEq]
  rcases DyadicCover.interval (fun _ : Unit => q) (-40) 152
      (fun _ => by simpa only [abs_of_nonneg qn, show (-40 : Int)+(152 : Nat)=112 from by decide] using qu)
      with small | ⟨e, elo, ehi, upper, _, lower⟩
  · have hq := small ()
    rw [abs_of_nonneg qn] at hq
    change real eps ≤ real (denominator divide input expr width eps) at epsBound
    linarith
  · have hehi : e ≤ 112 := by norm_num at ehi; exact ehi
    have hu := upper ()
    rw [abs_of_nonneg qn] at hu lower
    let floor := DyadicBounds.ceiling 1 (e-2)
    have ff := DyadicBounds.ceiling_range_wide 1 (e-2) (by decide) (by omega) (by omega)
    have fv : real floor = (2 : ℝ)^(e-2) := by simpa only [Nat.cast_one, one_mul] using ff.2
    have fn : FlushToZero.threshold < real floor := by
      rw [fv]
      exact (by norm_num [FlushToZero.threshold] : FlushToZero.threshold < (2 : ℝ)^(-41 : Int)).trans_le
        (zpow_le_zpow_right₀ (by norm_num) (by omega))
    have eLarge : (2 : ℝ)^(-40 : Int) ≤ energy input := by
      have hq : (2 : ℝ)^(-40 : Int) ≤ q :=
        (zpow_le_zpow_right₀ (by norm_num) (by omega : (-40 : Int) ≤ e-1)).trans lower.le
      have hqn : q ≤ energy input := by nlinarith only [mul_nonneg qn (sub_nonneg.mpr n1), eqn]
      exact hq.trans hqn
    have raw := half_energy input expr hx hf.hSum hs coverage eLarge
    have halfPower : (2 : ℝ)^(e-1) = 2*(2 : ℝ)^(e-2) := by
      rw [show e-1=(e-2)+1 from by omega, zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
      norm_num
      ring
    have fourthPower : (2 : ℝ)^e = 4*(2 : ℝ)^(e-2) := by
      rw [show e=(e-2)+2 from by omega, zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
      norm_num
      ring
    have floorHalf : real floor ≤ q/2 := by
      rw [fv]
      rw [halfPower] at lower
      linarith only [lower]
    have bound : real floor ≤ real (FlushToZero.flush (sum input expr))/real width := by
      rw [hf.hWidthValue]
      apply (le_div_iff₀ np).mpr
      have hp := mul_le_mul_of_nonneg_right floorHalf np.le
      nlinarith only [hp, eqn, raw]
    have floorDen := denominator_floor divide division input expr width eps floor hf ff.1 fn bound
    rw [fv] at floorDen
    rw [fourthPower] at hu
    linarith only [hu, floorDen]

theorem normalizer_energy (divide : Float32 → Float32 → Float32)
    (divError : Float32 → Float32 → ℝ) (accuracy : Division.Contract divide divError)
    (division : DivisionDirectedBounds.Contract divide) (input : Fin n → Float32)
    (expr : SquaredSum.Expr n) (width eps : Float32)
    (hf : ReductionFinite divide input expr width eps)
    (hx : ∀ i, |real (input i)| ≤ (2 : ℝ)^56)
    (hs : SquaredSumEnergyBounds.sites expr ≤ 16384)
    (coverage : (SquaredSum.indices expr).Perm (List.finRange n))
    (epsLower : (2 : ℝ)^(-40 : Int) ≤ real eps)
    (rsqrt : Float32 → Float32) (root : RsqrtBounds.Envelope rsqrt) :
    (normalizer divide input expr width eps rsqrt).isFinite = true ∧
      real (normalizer divide input expr width eps rsqrt)^2*energy input ≤ 16*(n : ℝ) := by
  have dp := denominator_positive divide divError accuracy input expr width eps hf
  have df := denominator_finite divide input expr width eps hf
  refine ⟨root.finite _ df dp, ?_⟩
  have h := root.bound _ df dp
  have hn : 0 ≤ |real (rsqrt (denominator divide input expr width eps))| *
      Real.sqrt (real (denominator divide input expr width eps)) := by positivity
  have sq := (sq_le_sq₀ hn (by norm_num : (0 : ℝ) ≤ 2)).mpr h
  rw [mul_pow, sq_abs, Real.sq_sqrt dp.le] at sq
  have lower := denominator_energy divide divError accuracy division input expr width eps hf hx hs coverage epsLower
  have np : (0 : ℝ) < n := by exact_mod_cast hf.hPositiveWidth
  have energyBound := (div_le_iff₀ (by positivity : (0 : ℝ) < 4*(n : ℝ))).mp lower
  have mulBound := mul_le_mul_of_nonneg_left energyBound
    (sq_nonneg (real (normalizer divide input expr width eps rsqrt)))
  have upper := mul_le_mul_of_nonneg_right sq (by positivity : (0 : ℝ) ≤ 4*(n : ℝ))
  change real (normalizer divide input expr width eps rsqrt)^2 *
    real (denominator divide input expr width eps) * (4*(n : ℝ)) ≤ 2^2*(4*(n : ℝ)) at upper
  nlinarith only [mulBound, upper]

end Inference.Contracts.Mlx.NormalizationEnergyScale
