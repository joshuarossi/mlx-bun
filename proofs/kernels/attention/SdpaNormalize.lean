import kernels.attention.SdpaLoop
import contracts.mlx.Division
import contracts.mlx.BFloat16Arithmetic

namespace Inference.Kernels.Attention.SdpaNormalize
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- The selected nonempty attention route divides a positive accumulator sum.
-- Positivity/range is a software obligation, not an assumed accuracy result.
structure Platform where
  divide : Float32 → Float32 → Float32
  error : Float32 → Float32 → ℝ
  division : Division.Contract divide error

def raw (p : Platform) (s : State) : Float32 := p.divide s.numerator s.denominator
def value (p : Platform) (s : State) : BF := BFloat16.narrow (raw p s)
structure Finite (p : Platform) (s : State) : Prop where
  numerator : s.numerator.isFinite = true
  denominator : s.denominator.isFinite = true
  domain : Division.DivisorDomain s.denominator
  quotient : (raw p s).isFinite = true
  cast : Model.isFinite (value p s) = true

noncomputable def propagatedBudget (s : State) (target : OnlineSoftmax.Summary) (error : Error) : ℝ :=
  error.numerator / real s.denominator +
    |target.numerator| * error.denominator / (real s.denominator * target.denominator)

noncomputable def budget (p : Platform) (s : State) (target : OnlineSoftmax.Summary) (error : Error) : ℝ :=
  BFloat16.epsilon (real (raw p s)) + p.error s.numerator s.denominator + propagatedBudget s target error

theorem quotient_error (x y X Y ex ey : ℝ) (hy : 0 < y) (hY : 0 < Y)
    (hx : |x-X| ≤ ex) (he : |y-Y| ≤ ey) :
    |x/y - X/Y| ≤ ex/y + |X| * ey/(y*Y) := by
  have hform : x/y - X/Y = (x-X)/y + X*(Y-y)/(y*Y) := by
    field_simp
    ring
  rw [hform]
  apply (abs_add_le _ _).trans
  apply add_le_add
  · rw [abs_div, abs_of_pos hy]
    exact div_le_div_of_nonneg_right hx hy.le
  · rw [abs_div, abs_mul, abs_of_pos (mul_pos hy hY), abs_sub_comm Y y]
    exact div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left he (abs_nonneg X)) (mul_pos hy hY).le

theorem value_error (p : Platform) (s : State) (target : OnlineSoftmax.Summary) (error : Error)
    (hf : Finite p s) (he : StateError s target error) (ht : 0 < target.denominator) :
    |Model.toReal (value p s) - OnlineSoftmax.normalized target| ≤ budget p s target error := by
  have hd : 0 < real s.denominator := lt_of_lt_of_le (by norm_num) hf.domain.1
  have hp := quotient_error (real s.numerator) (real s.denominator) target.numerator target.denominator
    error.numerator error.denominator hd ht he.numerator he.denominator
  have hr := p.division.accuracy s.numerator s.denominator hf.numerator hf.denominator hf.domain hf.quotient
  have hc := BFloat16.narrow_error (raw p s) hf.quotient hf.cast
  change |Model.toReal (value p s) - real (raw p s)| ≤ _ at hc
  change |real (raw p s) - real s.numerator / real s.denominator| ≤ _ at hr
  unfold budget propagatedBudget OnlineSoftmax.normalized
  calc
    _ = |(Model.toReal (value p s) - real (raw p s)) +
      ((real (raw p s) - real s.numerator / real s.denominator) +
        (real s.numerator / real s.denominator - target.numerator / target.denominator))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add hc ((abs_add_le _ _).trans (add_le_add hr hp)))
      linarith

theorem loop_softmax_error (p : SdpaUpdate.Platform) (normalization : Platform)
    (choose : Float32 → Float32 → Float32) (scores values : α → Float32)
    (targetScore targetValue scoreError valueError : α → ℝ)
    (hs : ∀ i, |real (scores i) - targetScore i| ≤ scoreError i)
    (hv : ∀ i, |real (values i) - targetValue i| ≤ valueError i)
    (indices : List α) (shift : Float32) (hne : indices ≠ [])
    (hf : SdpaLoop.Finite p choose scores values indices (SdpaLoop.initial shift))
    (hn : Finite normalization (SdpaLoop.run p choose scores values indices (SdpaLoop.initial shift))) :
    |Model.toReal (value normalization (SdpaLoop.run p choose scores values indices (SdpaLoop.initial shift))) -
      OnlineSoftmax.softmaxWeighted targetScore targetValue indices| ≤
    budget normalization (SdpaLoop.run p choose scores values indices (SdpaLoop.initial shift))
      (OnlineSoftmax.reference targetScore targetValue indices
        (real (SdpaLoop.run p choose scores values indices (SdpaLoop.initial shift)).shift))
      (SdpaLoop.errorRun p choose scores values targetScore targetValue scoreError valueError [] indices (SdpaLoop.initial shift) ⟨0, 0⟩) := by
  have h := value_error normalization _ _ _ hn
    (SdpaLoop.initialized_run_error p choose scores values targetScore targetValue scoreError valueError hs hv indices shift hf)
    (OnlineSoftmax.denominator_positive targetScore indices _ hne)
  rwa [OnlineSoftmax.normalized_reference] at h

end Inference.Kernels.Attention.SdpaNormalize
