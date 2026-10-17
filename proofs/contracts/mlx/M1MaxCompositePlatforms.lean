import contracts.mlx.M1MaxPlatforms
import contracts.mlx.BFloat16OverflowMargin
import contracts.mlx.BFloat16Log1p
import contracts.mlx.Negation
import kernels.GatedRmsNorm
import kernels.attention.OutputGate
import kernels.delta.DecayRanges
import kernels.trellis.SigmoidRanges
import kernels.StableSigmoidRanges
import kernels.trellis.GateUpFloatTailRanges
import kernels.attention.RopeAnglesRanges
import kernels.attention.RopeRanges
import kernels.attention.SdpaExponentRanges

namespace Inference.Contracts.Mlx.M1Max.Contract
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels
abbrev BF := BFloat16Arithmetic.Value

/- Composite scalar functions of the decode route, built from the contract's
   transcendental clauses and the flushed/rounded arithmetic models, with
   their range premises proved from operation-level clauses. -/
variable (C : Contract)

/-! ## bf16 exp(|x|) -/

-- metal::exp(metal::abs(x)) on bfloat (bf16_math.h): abs and exp through
-- float, each narrowed back to bfloat.
def expAbsWith (e a : Float32 → Float32) (x : BF) : BF :=
  BFloat16.narrow (e (BFloat16.widen (BFloat16.narrow (a (BFloat16.widen x)))))

-- JIT kernels (silu-rms-heads.ts:23, gate-up-codebook.ts:91): fast_fabs, fast_exp.
def fastExpAbs : BF → BF := expAbsWith C.fastExp C.fastFabs
-- Precompiled v_Sigmoid bfloat16 (unary_ops.h:308): fabs, exp.
def preciseExpAbs : BF → BF := expAbsWith C.exp C.fabs

noncomputable def expAbsError (f : BF → BF) (x : BF) : ℝ := |Model.toReal (f x) - Real.exp (|Model.toReal x|)|

theorem round_nonnegative (v : ℝ) (hv : 0 ≤ v) : 0 ≤ Model.roundAt FloatFormat.bfloat16 v := by
  have := Model.roundAt_mono FloatFormat.bfloat16 hv
  rwa [Model.roundAt_zero] at this

theorem narrow_nonnegative (z : Float32) (hz : z.isFinite = true) (hn : 0 ≤ real z)
    (hf : Model.isFinite (BFloat16.narrow z) = true) : 0 ≤ Model.toReal (BFloat16.narrow z) := by
  rw [BFloat16.narrow, Model.cast_eq_roundAt (by decide) (by decide) (model z) (by rw [finite_model]; exact hz) hf]
  exact round_nonnegative _ hn

theorem expAbsWith_range (e a : Float32 → Float32)
    (he : ∀ y, y.isFinite = true → ((e y).isFinite = true ∧ 0 ≤ real (e y)) ∨ e y = Float32.inf)
    (ha : ∀ y, y.isFinite = true → (a y).isFinite = true ∧ real (a y) = |real y|)
    (x : BF) (hx : Model.isFinite x = true) :
    (Model.isFinite (expAbsWith e a x) = true ∧ 0 ≤ Model.toReal (expAbsWith e a x)) ∨
      expAbsWith e a x = Model.posInf FloatFormat.bfloat16 := by
  have hw := BFloat16.widen_finite x hx
  obtain ⟨haf, har⟩ := ha _ hw
  have hn : Model.isFinite (BFloat16.narrow (a (BFloat16.widen x))) = true := by
    apply BFloat16ConversionBounds.narrow_finite _ haf
    rw [har, abs_abs, BFloat16.widen_real x hx]
    exact Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite x (by decide) hx
  rcases he _ (BFloat16.widen_finite _ hn) with ⟨hef, hen⟩ | hinf
  · rcases BFloat16OverflowMargin.narrow_cases _ hef hen with hf | hi
    · exact Or.inl ⟨hf, narrow_nonnegative _ hef hen hf⟩
    · exact Or.inr hi
  · right
    unfold expAbsWith
    rw [hinf]
    exact BFloat16OverflowMargin.narrow_inf

theorem expAbsWith_contract (e a : Float32 → Float32)
    (he : ∀ y, y.isFinite = true → ((e y).isFinite = true ∧ 0 ≤ real (e y)) ∨ e y = Float32.inf)
    (ha : ∀ y, y.isFinite = true → (a y).isFinite = true ∧ real (a y) = |real y|) :
    Trellis.GateUpSplitTail.ExpAbsContract (expAbsWith e a) (expAbsError (expAbsWith e a)) := by
  constructor
  · intro x hx hf
    rcases expAbsWith_range e a he ha x hx with h | h
    · exact h.2
    · rw [h] at hf; exact absurd hf (by decide)
  · intro _ _ _
    exact le_rfl

theorem expAbsWith_exponential (e a : Float32 → Float32)
    (he : ∀ y, y.isFinite = true → ((e y).isFinite = true ∧ 0 ≤ real (e y)) ∨ e y = Float32.inf)
    (ha : ∀ y, y.isFinite = true → (a y).isFinite = true ∧ real (a y) = |real y|) :
    Trellis.SigmoidRanges.ExponentialRange (expAbsWith e a) :=
  ⟨fun x hx => (expAbsWith_range e a he ha x hx).imp And.left id⟩

theorem fastExp_cases (y : Float32) (hy : y.isFinite = true) :
    ((C.fastExp y).isFinite = true ∧ 0 ≤ real (C.fastExp y)) ∨ C.fastExp y = Float32.inf :=
  (C.fastExp_overflow y hy).imp (fun h => ⟨h, C.fastExp_nonnegative y hy h⟩) id
theorem exp_cases (y : Float32) (hy : y.isFinite = true) :
    ((C.exp y).isFinite = true ∧ 0 ≤ real (C.exp y)) ∨ C.exp y = Float32.inf :=
  (C.exp_overflow y hy).imp (fun h => ⟨h, C.exp_nonnegative y hy h⟩) id

theorem fastExpAbs_contract : Trellis.GateUpSplitTail.ExpAbsContract C.fastExpAbs (expAbsError C.fastExpAbs) :=
  expAbsWith_contract _ _ C.fastExp_cases C.fastFabs_value
theorem fastExpAbs_exponential : Trellis.SigmoidRanges.ExponentialRange C.fastExpAbs :=
  expAbsWith_exponential _ _ C.fastExp_cases C.fastFabs_value
theorem preciseExpAbs_contract : Trellis.GateUpSplitTail.ExpAbsContract C.preciseExpAbs (expAbsError C.preciseExpAbs) :=
  expAbsWith_contract _ _ C.exp_cases C.fabs_value
theorem preciseExpAbs_exponential : Trellis.SigmoidRanges.ExponentialRange C.preciseExpAbs :=
  expAbsWith_exponential _ _ C.exp_cases C.fabs_value

/-! ## Platforms -/

-- MLX unary_ops.h Sigmoid on bfloat16 (beta and the attention output gate).
noncomputable def sigmoidPlatform : Attention.OutputGate.Platform where
  expAbs := C.preciseExpAbs
  expError := expAbsError C.preciseExpAbs
  exponential := C.preciseExpAbs_contract

noncomputable def headsPlatform (contracted : Bool) : Delta.SiluRmsHeads.Platform where
  expAbs := C.fastExpAbs
  expAbsError := expAbsError C.fastExpAbs
  exponential := C.fastExpAbs_contract
  reduce := C.simdSum
  reduction := C.simdSum_tree
  contracted := contracted
  divide := C.fdiv
  divError := FlushToZero.divBudget
  division := C.division
  rsqrt := C.rsqrt
  rsqrtError := C.rsqrtError
  rootAccuracy := C.rootAccuracy

-- gated-rms-norm.ts:43 metal::exp(metal::abs(g)) on float: fast_fabs, fast_exp.
def gatedExpAbs (x : Float32) : Float32 := C.fastExp (C.fastFabs x)

noncomputable def gatedPlatform (contracted : Bool) : GatedRmsNorm.Platform where
  reduce := C.simdSum
  reduction := C.simdSum_tree
  contracted := contracted
  divide := C.fdiv
  divError := FlushToZero.divBudget
  division := C.division
  rsqrt := C.rsqrt
  rsqrtError := C.rsqrtError
  rootAccuracy := C.rootAccuracy
  expAbs := C.gatedExpAbs
  expAbsError := fun x => |real (C.gatedExpAbs x) - Real.exp (|real x|)|
  exponential := ⟨fun x hx hf => C.fastExp_nonnegative _ (C.fastFabs_value x hx).1 hf, fun _ _ _ => le_rfl⟩

theorem gatedExpAbs_exponential : StableSigmoidRanges.ExponentialRange C.gatedExpAbs :=
  ⟨fun x hx => C.fastExp_overflow _ (C.fastFabs_value x hx).1⟩

-- compute_g (gated.ts, mx.compile): precise exp on float; the fused
-- LogAddExp's bfloat exp is fast_exp through float, its log1p utils.h:327.
def expBF (x : BF) : BF := BFloat16.narrow (C.fastExp (BFloat16.widen x))
def log1pBF : BF → BF := BFloat16Log1p.value C.fastLog C.fdiv

theorem expBF_nonnegative (x : BF) (hx : Model.isFinite x = true) (hf : Model.isFinite (C.expBF x) = true) :
    0 ≤ Model.toReal (C.expBF x) := by
  have hw := BFloat16.widen_finite x hx
  rcases C.fastExp_cases _ hw with ⟨hef, hen⟩ | hinf
  · exact narrow_nonnegative _ hef hen hf
  · unfold expBF at hf; rw [hinf, BFloat16OverflowMargin.narrow_inf] at hf; exact absurd hf (by decide)

noncomputable def decayPlatform (policy : Delta.Softplus.Policy) : Delta.Decay.Platform where
  policy := policy
  exp := C.exp
  expError := fun x => |real (C.exp x) - Real.exp (real x)|
  exponential := ⟨fun x hx hf => C.exp_nonnegative x hx hf, fun _ _ _ => le_rfl⟩
  expBF := C.expBF
  expBFError := fun x => |Model.toReal (C.expBF x) - Real.exp (Model.toReal x)|
  exponentialBF := ⟨C.expBF_nonnegative, fun _ _ _ => le_rfl⟩
  log1pBF := C.log1pBF
  log1pBFError := fun x => |Model.toReal (C.log1pBF x) - Real.log (1 + Model.toReal x)|
  logarithmBF := ⟨fun _ _ _ _ => le_rfl⟩

-- gate-up-codebook.ts:96 (TAIL=0): metal::precise::exp(-float(gate)).
def expNeg (x : Float32) : Float32 := C.exp (-x)

theorem expNeg_contract : Trellis.GateUpTail.ExpNegContract C.expNeg (fun x => |real (C.expNeg x) - Real.exp (-real x)|) :=
  ⟨fun x hx hf => C.exp_nonnegative _ (Negation.finite_neg x hx) hf, fun _ _ _ => le_rfl⟩

theorem expNeg_exponential : Trellis.GateUpFloatTailRanges.ExponentialRange C.expNeg :=
  ⟨fun x hx => C.exp_cases _ (Negation.finite_neg x hx)⟩

/-! ## Range premises from operation-level clauses -/

theorem decayRanges (P : Proposed C) (policy : Delta.Softplus.Policy) (profile : Delta.DecayRanges.Profile)
    (aLogCap : real profile.aLogCap ≤ 8) (scaleCap : (2:ℝ)^(12:Nat) ≤ real profile.scaleCap) :
    Delta.DecayRanges.PrimitiveRanges (C.decayPlatform policy) profile where
  softplus := {
    exponential := by
      intro x hx hn
      have hw := BFloat16.widen_finite x hx
      have he := C.fastExp_nonpositive _ hw (by rw [BFloat16.widen_real x hx]; exact hn)
      have hr := BFloat16ConversionBounds.narrow_range _ BFloat16Arithmetic.one he.1 BFloat16Arithmetic.finite_one
        (by rw [BFloat16Arithmetic.real_one, abs_of_nonneg he.2.1]; exact he.2.2)
      rw [BFloat16Arithmetic.real_one] at hr
      exact ⟨hr.1, narrow_nonnegative _ he.1 he.2.1 hr.1, (le_abs_self _).trans hr.2⟩
    logarithm := fun x hx h => BFloat16Log1p.range C.fastLog C.fdiv C.fastLog_unit P.fdiv_unit x hx h.1 h.2 }
  scale := by
    intro x hx hb
    have h := C.exp_small x hx (hb.trans aLogCap)
    refine ⟨h.1, ?_⟩
    change |real (C.exp x)| ≤ _
    rw [abs_of_nonneg (C.exp_nonnegative x hx h.1)]
    exact h.2.trans scaleCap
  nonpositive := fun x hx hn => C.exp_nonpositive x hx hn

theorem rsqrtEnvelope (factor : ℝ) (h : 17/16 ≤ factor) : RsqrtEpsilonBounds.NormalEnvelope C.rsqrt factor :=
  ⟨C.rsqrt_normal.finite, fun x hx lower => (C.rsqrt_normal.bound x hx lower).trans h⟩

theorem exp2Range : Attention.RopeAnglesRanges.Exp2Range C.anglePlatform := C.exp2_nonpositive

theorem trigRanges (one two : Attention.Rope.Contraction) :
    Attention.RopeRanges.TrigRanges (C.rotationPlatform one two) :=
  ⟨fun θ hθ hd => C.fastSin_bounded θ hθ hd, fun θ hθ hd => C.fastCos_bounded θ hθ hd⟩

theorem sdpaExponent (sumContracted : Bool) (numeratorContracted : Attention.SdpaUpdate.Contraction) :
    Attention.SdpaExponentRanges.Primitive (C.updatePlatform sumContracted numeratorContracted) :=
  ⟨C.fastExp_nonpositive, C.fastExp_zero⟩

theorem logSumExpPrimitives (sumContracted : Bool) (numeratorContracted : Attention.SdpaUpdate.Contraction) :
    Sampling.LogSumExpRanges.Primitives (C.logSumExpPlatform sumContracted numeratorContracted) :=
  ⟨C.sdpaExponent sumContracted numeratorContracted, ⟨C.fastExp_negInf.1, C.fastExp_negInf.2⟩, C.log_bounded⟩

end Inference.Contracts.Mlx.M1Max.Contract
