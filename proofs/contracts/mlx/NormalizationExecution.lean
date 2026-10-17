import contracts.mlx.Normalization
import contracts.mlx.Division
import contracts.mlx.SquaredSum
import contracts.mlx.BFloat16
import contracts.mlx.BFloat16Arithmetic

namespace Inference.Contracts.Mlx.NormalizationExecution
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

variable (divide : Float32 → Float32 → Float32) (divError : Float32 → Float32 → ℝ)

-- Arithmetic of MLX v0.32.2 rms_norm.metal: float square reduction, divide
-- by width, add epsilon, precise rsqrt, float multiply, bf16 conversion, then
-- bf16 weight multiply. Source scheduling/coverage is an explicit obligation;
-- a generic reduction primitive is not assumed to compute the right sum.
def sum (input : Fin n → Float32) (expr : SquaredSum.Expr n) : Float32 := SquaredSum.evaluate input expr
def mean (input : Fin n → Float32) (expr : SquaredSum.Expr n) (width : Float32) : Float32 :=
  divide (sum input expr) width
def denominator (input : Fin n → Float32) (expr : SquaredSum.Expr n) (width eps : Float32) : Float32 :=
  FlushToZero.add (mean divide input expr width) eps
def normalizer (input : Fin n → Float32) (expr : SquaredSum.Expr n) (width eps : Float32)
    (rsqrt : Float32 → Float32) : Float32 := rsqrt (denominator divide input expr width eps)
def normalized (input : Fin n → Float32) (expr : SquaredSum.Expr n) (width eps : Float32)
    (rsqrt : Float32 → Float32) (i : Fin n) : Float32 := FlushToZero.mul (input i) (normalizer divide input expr width eps rsqrt)
def output (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (expr : SquaredSum.Expr n) (width eps : Float32) (rsqrt : Float32 → Float32) (i : Fin n) : Float32 :=
  BFloat16.widen (BFloat16Arithmetic.mul (weight i) (BFloat16.narrow (normalized divide input expr width eps rsqrt i)))

structure ReductionFinite (input : Fin n → Float32) (expr : SquaredSum.Expr n) (width eps : Float32) : Prop where
  hSum : SquaredSum.Finite input expr
  hWidth : width.isFinite=true
  hWidthValue : real width=(n : ℝ)
  hPositiveWidth : 0<n
  hWidthUpper : real width ≤ (2 : ℝ) ^ (126 : Nat)
  hMean : (mean divide input expr width).isFinite=true
  hEps : eps.isFinite=true
  hDenominator : (FlushToZero.flush (mean divide input expr width)+FlushToZero.flush eps).isFinite=true
  hNormalEps : FlushToZero.threshold < real eps

noncomputable def meanBudget (input : Fin n → Float32) (expr : SquaredSum.Expr n) (width : Float32) : ℝ :=
  divError (sum input expr) width + SquaredSum.budget input expr / real width

noncomputable def denominatorBudget (input : Fin n → Float32) (expr : SquaredSum.Expr n)
    (width eps : Float32) (epsError : ℝ) : ℝ :=
  FlushToZero.addBudget (mean divide input expr width) eps + meanBudget divError input expr width + epsError

theorem mean_finite (input : Fin n → Float32) (expr : SquaredSum.Expr n) (width eps : Float32)
    (hf : ReductionFinite divide input expr width eps) : (mean divide input expr width).isFinite=true := hf.hMean

theorem denominator_finite (input : Fin n → Float32) (expr : SquaredSum.Expr n) (width eps : Float32)
    (hf : ReductionFinite divide input expr width eps) : (denominator divide input expr width eps).isFinite=true :=
  FlushToZero.finite_flush _ hf.hDenominator

theorem denominator_positive (division : Division.Contract divide divError) (input : Fin n → Float32) (expr : SquaredSum.Expr n) (width eps : Float32)
    (hf : ReductionFinite divide input expr width eps) : 0 < real (denominator divide input expr width eps) := by
  have hw : 1 ≤ real width := by rw [hf.hWidthValue]; exact_mod_cast hf.hPositiveWidth
  have hm : 0 ≤ real (mean divide input expr width) :=
    division.nonnegative _ _ (SquaredSum.finite_evaluate input expr hf.hSum) hf.hWidth
      (SquaredSum.nonnegative input expr hf.hSum) ⟨hw, hf.hWidthUpper⟩ hf.hMean
  have hd := FlushToZero.add_ge_normal_right (mean divide input expr width) eps
    (mean_finite divide input expr width eps hf) hf.hEps hm hf.hNormalEps hf.hDenominator
  exact lt_of_lt_of_le (lt_trans FlushToZero.threshold_pos hf.hNormalEps) hd

theorem mean_error (division : Division.Contract divide divError) (input : Fin n → Float32) (expr : SquaredSum.Expr n)
    (coverage : (SquaredSum.indices expr).Perm (List.finRange n)) (width eps : Float32)
    (hf : ReductionFinite divide input expr width eps) :
    |real (mean divide input expr width)-Normalization.meanSquare (fun i => real (input i))| ≤ meanBudget divError input expr width := by
  have hw : 1 ≤ real width := by rw [hf.hWidthValue]; exact_mod_cast hf.hPositiveWidth
  have hs := SquaredSum.sum_error input expr coverage hf.hSum
  rw [← Fin.sum_univ_def] at hs
  have hd := division.accuracy (sum input expr) width (SquaredSum.finite_evaluate input expr hf.hSum)
    hf.hWidth ⟨hw, hf.hWidthUpper⟩ hf.hMean
  have hi : |real (sum input expr)/real width-(∑ i, real (input i)^2)/real width| ≤
      SquaredSum.budget input expr/real width := by
    rw [← sub_div, abs_div, abs_of_nonneg (show 0 ≤ real width by linarith)]
    exact div_le_div_of_nonneg_right hs (by linarith)
  unfold Normalization.meanSquare meanBudget
  rw [← hf.hWidthValue]
  calc
    _ = |(real (mean divide input expr width)-real (sum input expr)/real width) +
        (real (sum input expr)/real width-(∑ i, real (input i)^2)/real width)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hd hi)

theorem denominator_error (division : Division.Contract divide divError) (input : Fin n → Float32) (expr : SquaredSum.Expr n)
    (coverage : (SquaredSum.indices expr).Perm (List.finRange n)) (width eps : Float32)
    (idealEps epsError : ℝ) (he : |real eps-idealEps| ≤ epsError) (hf : ReductionFinite divide input expr width eps) :
    |real (denominator divide input expr width eps)-Normalization.denominator (fun i => real (input i)) idealEps| ≤
      denominatorBudget divide divError input expr width eps epsError := by
  have hm := mean_error divide divError division input expr coverage width eps hf
  have ha := FlushToZero.add_error (mean divide input expr width) eps (mean_finite divide input expr width eps hf) hf.hEps hf.hDenominator
  change |real (denominator divide input expr width eps)-(real (mean divide input expr width)+real eps)| ≤
    FlushToZero.addBudget (mean divide input expr width) eps at ha
  unfold Normalization.denominator denominatorBudget
  calc
    _ = |(real (denominator divide input expr width eps)-(real (mean divide input expr width)+real eps)) +
        ((real (mean divide input expr width)-Normalization.meanSquare (fun i => real (input i)))+(real eps-idealEps))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add ha ((abs_add_le _ _).trans (add_le_add hm he)))
      linarith

noncomputable def normalizerBudget (input : Fin n → Float32) (expr : SquaredSum.Expr n)
    (width eps : Float32) (idealEps epsError : ℝ) (rsqrtError : Float32 → ℝ) : ℝ :=
  let d := real (denominator divide input expr width eps)
  let t := Normalization.denominator (fun i => real (input i)) idealEps
  rsqrtError (denominator divide input expr width eps)+denominatorBudget divide divError input expr width eps epsError /
    (Real.sqrt d*Real.sqrt t*(Real.sqrt d+Real.sqrt t))

theorem normalizer_error (division : Division.Contract divide divError) (input : Fin n → Float32) (expr : SquaredSum.Expr n)
    (coverage : (SquaredSum.indices expr).Perm (List.finRange n)) (width eps : Float32)
    (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps-idealEps| ≤ epsError)
    (hf : ReductionFinite divide input expr width eps) (rsqrt : Float32 → Float32) (rsqrtError : Float32 → ℝ)
    (hardware : Normalization.RsqrtContract rsqrt rsqrtError)
    (ho : (normalizer divide input expr width eps rsqrt).isFinite=true) :
    |real (normalizer divide input expr width eps rsqrt)-
      1/Real.sqrt (Normalization.denominator (fun i => real (input i)) idealEps)| ≤
        normalizerBudget divide divError input expr width eps idealEps epsError rsqrtError := by
  exact Normalization.rsqrt_error rsqrt rsqrtError hardware _ _ _ (denominator_finite divide input expr width eps hf)
    (denominator_positive divide divError division input expr width eps hf) (Normalization.denominator_positive _ _ hp) ho
    (denominator_error divide divError division input expr coverage width eps idealEps epsError he hf)

noncomputable def normalizedBudget (input : Fin n → Float32) (expr : SquaredSum.Expr n)
    (width eps : Float32) (idealEps epsError : ℝ) (rsqrt : Float32 → Float32)
    (rsqrtError : Float32 → ℝ) (i : Fin n) : ℝ :=
  BFloat16.epsilon (real (normalized divide input expr width eps rsqrt i))+
    FlushToZero.mulBudget (input i) (normalizer divide input expr width eps rsqrt)+
    |real (input i)| *normalizerBudget divide divError input expr width eps idealEps epsError rsqrtError

theorem normalized_error (division : Division.Contract divide divError) (input : Fin n → Float32) (expr : SquaredSum.Expr n)
    (coverage : (SquaredSum.indices expr).Perm (List.finRange n)) (width eps : Float32)
    (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps-idealEps| ≤ epsError)
    (hf : ReductionFinite divide input expr width eps) (rsqrt : Float32 → Float32) (rsqrtError : Float32 → ℝ)
    (hardware : Normalization.RsqrtContract rsqrt rsqrtError)
    (ho : (normalizer divide input expr width eps rsqrt).isFinite=true) (i : Fin n)
    (hm : (FlushToZero.flush (input i)*FlushToZero.flush (normalizer divide input expr width eps rsqrt)).isFinite=true)
    (hb : Model.isFinite (BFloat16.narrow (normalized divide input expr width eps rsqrt i))=true) :
    |Model.toReal (BFloat16.narrow (normalized divide input expr width eps rsqrt i))-
      real (input i)/Real.sqrt (Normalization.denominator (fun j => real (input j)) idealEps)| ≤
        normalizedBudget divide divError input expr width eps idealEps epsError rsqrt rsqrtError i := by
  have en := normalizer_error divide divError division input expr coverage width eps idealEps epsError hp he hf rsqrt rsqrtError hardware ho
  have em := FlushToZero.mul_error (input i) (normalizer divide input expr width eps rsqrt) hm
  change |real (normalized divide input expr width eps rsqrt i)-real (input i)*real (normalizer divide input expr width eps rsqrt)| ≤
    FlushToZero.mulBudget (input i) (normalizer divide input expr width eps rsqrt) at em
  have eb := BFloat16.narrow_error (normalized divide input expr width eps rsqrt i) (FlushToZero.finite_flush _ hm) hb
  have ex := mul_le_mul_of_nonneg_left en (abs_nonneg (real (input i)))
  rw [← abs_mul] at ex
  unfold normalizedBudget
  calc
    _ = |(Model.toReal (BFloat16.narrow (normalized divide input expr width eps rsqrt i))-
          real (normalized divide input expr width eps rsqrt i)) +
        ((real (normalized divide input expr width eps rsqrt i)-real (input i)*real (normalizer divide input expr width eps rsqrt)) +
          real (input i)*(real (normalizer divide input expr width eps rsqrt)-
            1/Real.sqrt (Normalization.denominator (fun j => real (input j)) idealEps)))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add eb ((abs_add_le _ _).trans (add_le_add em ex)))
      linarith

theorem output_error (division : Division.Contract divide divError) (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (expr : SquaredSum.Expr n) (coverage : (SquaredSum.indices expr).Perm (List.finRange n)) (width eps : Float32)
    (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps-idealEps| ≤ epsError)
    (hf : ReductionFinite divide input expr width eps) (rsqrt : Float32 → Float32) (rsqrtError : Float32 → ℝ)
    (hardware : Normalization.RsqrtContract rsqrt rsqrtError)
    (ho : (normalizer divide input expr width eps rsqrt).isFinite=true) (i : Fin n)
    (hm : (FlushToZero.flush (input i)*FlushToZero.flush (normalizer divide input expr width eps rsqrt)).isFinite=true)
    (hb : Model.isFinite (BFloat16.narrow (normalized divide input expr width eps rsqrt i))=true)
    (hw : Model.isFinite (weight i)=true)
    (hout : Model.isFinite (Model.mul (BFloat16Arithmetic.flush (weight i))
      (BFloat16Arithmetic.flush (BFloat16.narrow (normalized divide input expr width eps rsqrt i))))=true) :
    |real (output divide input weight expr width eps rsqrt i)-
      Normalization.rmsNorm (fun j => real (input j)) (fun j => Model.toReal (weight j)) idealEps i| ≤
      BFloat16Arithmetic.mulBudget (weight i) (BFloat16.narrow (normalized divide input expr width eps rsqrt i)) +
        |Model.toReal (weight i)| *normalizedBudget divide divError input expr width eps idealEps epsError rsqrt rsqrtError i := by
  have en := normalized_error divide divError division input expr coverage width eps idealEps epsError hp he hf rsqrt rsqrtError hardware ho i hm hb
  have ew := BFloat16Arithmetic.mul_error (weight i) (BFloat16.narrow (normalized divide input expr width eps rsqrt i)) hw hb hout
  have ex := mul_le_mul_of_nonneg_left en (abs_nonneg (Model.toReal (weight i)))
  rw [← abs_mul] at ex
  unfold output Normalization.rmsNorm
  have hfout : Model.isFinite (BFloat16Arithmetic.mul (weight i) (BFloat16.narrow (normalized divide input expr width eps rsqrt i)))=true :=
    BFloat16Arithmetic.finite_flush _ hout
  rw [BFloat16.widen_real _ hfout]
  calc
    _ = |(Model.toReal (BFloat16Arithmetic.mul (weight i) (BFloat16.narrow (normalized divide input expr width eps rsqrt i)))-
          Model.toReal (weight i)*Model.toReal (BFloat16.narrow (normalized divide input expr width eps rsqrt i))) +
        Model.toReal (weight i)*(Model.toReal (BFloat16.narrow (normalized divide input expr width eps rsqrt i))-
          real (input i)/Real.sqrt (Normalization.denominator (fun j => real (input j)) idealEps))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add ew ex)

structure Finite (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (expr : SquaredSum.Expr n) (width eps : Float32) (rsqrt : Float32 → Float32) : Prop
    extends ReductionFinite divide input expr width eps where
  hNormalizer : (normalizer divide input expr width eps rsqrt).isFinite = true
  hNormalized : ∀ i, (FlushToZero.flush (input i) * FlushToZero.flush (normalizer divide input expr width eps rsqrt)).isFinite = true
  hNarrow : ∀ i, Model.isFinite (BFloat16.narrow (normalized divide input expr width eps rsqrt i)) = true
  hWeight : ∀ i, Model.isFinite (weight i) = true
  hOutput : ∀ i, Model.isFinite (Model.mul (BFloat16Arithmetic.flush (weight i))
    (BFloat16Arithmetic.flush (BFloat16.narrow (normalized divide input expr width eps rsqrt i)))) = true

noncomputable def outputBudget (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (expr : SquaredSum.Expr n) (width eps : Float32) (idealEps epsError : ℝ)
    (rsqrt : Float32 → Float32) (rsqrtError : Float32 → ℝ) (i : Fin n) : ℝ :=
  BFloat16Arithmetic.mulBudget (weight i) (BFloat16.narrow (normalized divide input expr width eps rsqrt i)) +
    |Model.toReal (weight i)| * normalizedBudget divide divError input expr width eps idealEps epsError rsqrt rsqrtError i

theorem accuracy (division : Division.Contract divide divError) (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (expr : SquaredSum.Expr n) (coverage : (SquaredSum.indices expr).Perm (List.finRange n)) (width eps : Float32)
    (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (rsqrt : Float32 → Float32) (rsqrtError : Float32 → ℝ)
    (hardware : Normalization.RsqrtContract rsqrt rsqrtError) (hf : Finite divide input weight expr width eps rsqrt) (i : Fin n) :
    |real (output divide input weight expr width eps rsqrt i) -
      Normalization.rmsNorm (fun j => real (input j)) (fun j => Model.toReal (weight j)) idealEps i| ≤
      outputBudget divide divError input weight expr width eps idealEps epsError rsqrt rsqrtError i :=
  output_error divide divError division input weight expr coverage width eps idealEps epsError hp he hf.toReductionFinite rsqrt rsqrtError
    hardware hf.hNormalizer i (hf.hNormalized i) (hf.hNarrow i) (hf.hWeight i) (hf.hOutput i)

end Inference.Contracts.Mlx.NormalizationExecution
