import contracts.mlx.RsqrtRelativeBounds
import contracts.mlx.NormalizationUniform

namespace Inference.Contracts.Mlx.RsqrtEpsilonBounds
open Numerics NormalizationExecution
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

private theorem real_zero : real (0 : Float32)=0 := by
  rw [real_unpack]
  exact Model.unpackedToReal_zero _

-- Only the reached epsilon-normal domain is contracted. No behavior at
-- positive subnormal inputs is required; physical instruction correspondence
-- and the chosen numerical approximation envelope remain explicit.
structure Envelope (rsqrt : Float32 → Float32) (eps : Float32) (factor : ℝ) : Prop where
  finite : ∀ x, x.isFinite=true → real eps≤real x → (rsqrt x).isFinite=true
  bound : ∀ x, x.isFinite=true → real eps≤real x → |real (rsqrt x)| *Real.sqrt (real x)≤factor

-- A reusable hardware-domain form: positive normal inputs only. It does not
-- constrain zero, NaN, infinities, negatives, or positive subnormal inputs.
structure NormalEnvelope (rsqrt : Float32 → Float32) (factor : ℝ) : Prop where
  finite : ∀ x, x.isFinite=true → FlushToZero.threshold<real x → (rsqrt x).isFinite=true
  bound : ∀ x, x.isFinite=true → FlushToZero.threshold<real x →
    |real (rsqrt x)| * Real.sqrt (real x)≤factor

theorem from_normal (h : NormalEnvelope rsqrt factor)
    (normal : FlushToZero.threshold<real eps) : Envelope rsqrt eps factor where
  finite x hx lower := h.finite x hx (normal.trans_le lower)
  bound x hx lower := h.bound x hx (normal.trans_le lower)

theorem restrict (h : RsqrtRelativeBounds.Envelope rsqrt factor) (positive : 0<real eps) :
    Envelope rsqrt eps factor where
  finite x hx lower := h.finite x hx (positive.trans_le lower)
  bound x hx lower := h.bound x hx (positive.trans_le lower)

-- A mathematical completion for reusing existing universal-envelope lemmas.
-- It does not modify an executing kernel. Theorems below prove exact equality
-- with the original function at every reached normalization argument.
noncomputable def complete (rsqrt : Float32 → Float32) (eps x : Float32) : Float32 := by
  classical
  exact if real eps≤real x then rsqrt x else 0

theorem complete_eq (rsqrt : Float32 → Float32) (eps x : Float32) (domain : real eps≤real x) :
    complete rsqrt eps x=rsqrt x := by simp only [complete,ite_eq_left domain]

theorem complete_relative (h : Envelope rsqrt eps factor) (nonnegative : 0≤factor) :
    RsqrtRelativeBounds.Envelope (complete rsqrt eps) factor := by
  constructor
  · intro x hx _
    by_cases domain : real eps≤real x
    · rw [complete_eq _ _ _ domain]
      exact h.finite x hx domain
    · simp only [complete,ite_eq_right domain]
      decide +kernel
  · intro x hx _
    by_cases domain : real eps≤real x
    · rw [complete_eq _ _ _ domain]
      exact h.bound x hx domain
    · simpa only [complete,ite_eq_right domain,real_zero,abs_zero,zero_mul] using nonnegative

theorem complete_envelope (h : Envelope rsqrt eps 2) : RsqrtBounds.Envelope (complete rsqrt eps) :=
  RsqrtRelativeBounds.weaken _ 2 (complete_relative h (by norm_num)) (by norm_num)

-- The exact rounded denominator has a lower bound of epsilon. This follows
-- from the actual finite reduction/division/addition, not an rsqrt assumption.
theorem denominator_lower (divide : Float32 → Float32 → Float32) (error : Float32 → Float32 → ℝ)
    (division : Division.Contract divide error) (input : Fin n → Float32) (expr : SquaredSum.Expr n)
    (width eps : Float32) (hf : ReductionFinite divide input expr width eps) :
    real eps≤real (denominator divide input expr width eps) := by
  have hw : 1≤real width := by rw [hf.hWidthValue]; exact_mod_cast hf.hPositiveWidth
  have hm : 0≤real (mean divide input expr width) :=
    division.nonnegative _ _ (SquaredSum.finite_evaluate input expr hf.hSum) hf.hWidth
      (SquaredSum.nonnegative input expr hf.hSum) ⟨hw,hf.hWidthUpper⟩ hf.hMean
  exact FlushToZero.add_ge_normal_right _ _ hf.hMean hf.hEps hm hf.hNormalEps hf.hDenominator

theorem denominator_normal (divide : Float32 → Float32 → Float32) (error : Float32 → Float32 → ℝ)
    (division : Division.Contract divide error) (input : Fin n → Float32) (expr : SquaredSum.Expr n)
    (width eps : Float32) (hf : ReductionFinite divide input expr width eps) :
    FlushToZero.threshold<real (denominator divide input expr width eps) :=
  hf.hNormalEps.trans_le (denominator_lower divide error division input expr width eps hf)

theorem normalizer_eq (divide : Float32 → Float32 → Float32) (error : Float32 → Float32 → ℝ)
    (division : Division.Contract divide error) (input : Fin n → Float32) (expr : SquaredSum.Expr n)
    (width eps : Float32) (hf : ReductionFinite divide input expr width eps) (rsqrt : Float32 → Float32) :
    normalizer divide input expr width eps (complete rsqrt eps)=normalizer divide input expr width eps rsqrt :=
  complete_eq _ _ _ (denominator_lower divide error division input expr width eps hf)

theorem normalized_eq (divide : Float32 → Float32 → Float32) (error : Float32 → Float32 → ℝ)
    (division : Division.Contract divide error) (input : Fin n → Float32) (expr : SquaredSum.Expr n)
    (width eps : Float32) (hf : ReductionFinite divide input expr width eps) (rsqrt : Float32 → Float32) (i : Fin n) :
    normalized divide input expr width eps (complete rsqrt eps) i=normalized divide input expr width eps rsqrt i := by
  unfold normalized
  rw [normalizer_eq divide error division input expr width eps hf rsqrt]

theorem output_eq (divide : Float32 → Float32 → Float32) (error : Float32 → Float32 → ℝ)
    (division : Division.Contract divide error) (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (expr : SquaredSum.Expr n) (width eps : Float32) (hf : ReductionFinite divide input expr width eps)
    (rsqrt : Float32 → Float32) (i : Fin n) :
    output divide input weight expr width eps (complete rsqrt eps) i=output divide input weight expr width eps rsqrt i := by
  unfold output
  rw [normalized_eq divide error division input expr width eps hf rsqrt i]

theorem finite_of_complete (divide : Float32 → Float32 → Float32) (error : Float32 → Float32 → ℝ)
    (division : Division.Contract divide error) (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (expr : SquaredSum.Expr n) (width eps : Float32) (rsqrt : Float32 → Float32)
    (hf : Finite divide input weight expr width eps (complete rsqrt eps)) :
    Finite divide input weight expr width eps rsqrt := by
  have normalizerSame := normalizer_eq divide error division input expr width eps hf.toReductionFinite rsqrt
  have normalizedSame := normalized_eq divide error division input expr width eps hf.toReductionFinite rsqrt
  exact {
    toReductionFinite := hf.toReductionFinite
    hNormalizer := by rw [← normalizerSame]; exact hf.hNormalizer
    hNormalized := by intro i; rw [← normalizerSame]; exact hf.hNormalized i
    hNarrow := by intro i; rw [← normalizedSame i]; exact hf.hNarrow i
    hWeight := hf.hWeight
    hOutput := by intro i; rw [← normalizedSame i]; exact hf.hOutput i }

-- An independent adapter for the existing full magnitude-independent RMS
-- range proof. The same source function, reduction, epsilon and exact output
-- values are returned; no subnormal rsqrt behavior or final output is assumed.
theorem uniform_ranges_wide (p : NormalizationUniform.Profile n) (divide : Float32 → Float32 → Float32)
    (error : Float32 → Float32 → ℝ) (accuracy : Division.Contract divide error)
    (division : DivisionDirectedBounds.Contract divide) (rsqrt : Float32 → Float32)
    (root : Envelope rsqrt p.eps 2) (expr : SquaredSum.Expr n)
    (coverage : (SquaredSum.indices expr).Perm (List.finRange n))
    (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (hx : ∀ i, (input i).isFinite=true ∧ |real (input i)|≤(2:ℝ)^(56:Nat))
    (hw : ∀ i, Model.isFinite (weight i)=true ∧ |Model.toReal (weight i)|≤Model.toReal p.weightCap) :
    Finite divide input weight expr (Float32.ofInt n) p.eps rsqrt ∧
      ∀ i, |real (output divide input weight expr (Float32.ofInt n) p.eps rsqrt i)|≤Model.toReal p.outputCap := by
  have h := NormalizationUniform.ranges_wide p divide error accuracy division (complete rsqrt p.eps)
    (complete_envelope root) expr coverage input weight hx hw
  refine ⟨finite_of_complete divide error accuracy input weight expr _ p.eps rsqrt h.1,?_⟩
  intro i
  rw [← output_eq divide error accuracy input weight expr _ p.eps h.1.toReductionFinite rsqrt i]
  exact h.2 i

end Inference.Contracts.Mlx.RsqrtEpsilonBounds
