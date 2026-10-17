import kernels.attention.SdpaUpdate

namespace Inference.Kernels.Attention.SdpaLoop
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate

-- Each SIMD group visits its own list of key indices. This loop theorem is
-- independent of the partition and will be applied to those exact lists.
def next (p : Platform) (choose : Float32 → Float32 → Float32) (scores values : α → Float32) (i : α) (s : State) : State :=
  step p s (scores i) (values i) (choose s.shift (scores i))

def run (p : Platform) (choose : Float32 → Float32 → Float32) (scores values : α → Float32) : List α → State → State
  | [], s => s
  | i :: rest, s => run p choose scores values rest (next p choose scores values i s)

def Finite (p : Platform) (choose : Float32 → Float32 → Float32) (scores values : α → Float32) : List α → State → Prop
  | [], _ => True
  | i :: rest, s => SdpaUpdate.Finite p s (scores i) (values i) (choose s.shift (scores i)) ∧
      Finite p choose scores values rest (next p choose scores values i s)

noncomputable def errorRun (p : Platform) (choose : Float32 → Float32 → Float32) (scores values : α → Float32)
    (targetScore targetValue scoreError valueError : α → ℝ) : List α → List α → State → Error → Error
  | _, [], _, error => error
  | processed, i :: rest, s, error =>
    errorRun p choose scores values targetScore targetValue scoreError valueError (processed ++ [i]) rest
      (next p choose scores values i s)
      (budget p s (scores i) (values i) (choose s.shift (scores i))
        (OnlineSoftmax.reference targetScore targetValue processed (real s.shift)) error
        (targetScore i) (targetValue i) (scoreError i) (valueError i))

theorem run_error (p : Platform) (choose : Float32 → Float32 → Float32) (scores values : α → Float32)
    (targetScore targetValue scoreError valueError : α → ℝ)
    (hs : ∀ i, |real (scores i) - targetScore i| ≤ scoreError i)
    (hv : ∀ i, |real (values i) - targetValue i| ≤ valueError i)
    (processed indices : List α) (initial : State) (error : Error)
    (hi : StateError initial (OnlineSoftmax.reference targetScore targetValue processed (real initial.shift)) error)
    (hf : Finite p choose scores values indices initial) :
    StateError (run p choose scores values indices initial)
      (OnlineSoftmax.reference targetScore targetValue (processed ++ indices) (real (run p choose scores values indices initial).shift))
      (errorRun p choose scores values targetScore targetValue scoreError valueError processed indices initial error) := by
  induction indices generalizing processed initial error with
  | nil => simpa only [run, errorRun, List.append_nil] using hi
  | cons i rest ih =>
    have hn := step_error p initial (scores i) (values i) (choose initial.shift (scores i))
      (OnlineSoftmax.reference targetScore targetValue processed (real initial.shift)) error
      (targetScore i) (targetValue i) (scoreError i) (valueError i) hf.1 hi (hs i) (hv i)
    rw [OnlineSoftmax.append_correct] at hn
    have h := ih (processed ++ [i]) (next p choose scores values i initial) _ hn hf.2
    simpa only [run, errorRun, List.append_assoc, List.singleton_append] using h

def initial (shift : Float32) : State := ⟨shift, 0, 0⟩

theorem initial_error (scores values : α → ℝ) (shift : Float32) :
    StateError (initial shift) (OnlineSoftmax.reference scores values [] (real shift)) ⟨0, 0⟩ := by
  have hz : real (0 : Float32) = 0 := FlushToZero.real_signed_zero .positive
  constructor
  · rfl
  · simp [initial, OnlineSoftmax.reference, OnlineSoftmax.denominator, hz]
  · simp [initial, OnlineSoftmax.reference, OnlineSoftmax.numerator, hz]

theorem initialized_run_error (p : Platform) (choose : Float32 → Float32 → Float32) (scores values : α → Float32)
    (targetScore targetValue scoreError valueError : α → ℝ)
    (hs : ∀ i, |real (scores i) - targetScore i| ≤ scoreError i)
    (hv : ∀ i, |real (values i) - targetValue i| ≤ valueError i)
    (indices : List α) (shift : Float32) (hf : Finite p choose scores values indices (initial shift)) :
    StateError (run p choose scores values indices (initial shift))
      (OnlineSoftmax.reference targetScore targetValue indices (real (run p choose scores values indices (initial shift)).shift))
      (errorRun p choose scores values targetScore targetValue scoreError valueError [] indices (initial shift) ⟨0, 0⟩) := by
  simpa only [List.nil_append] using run_error p choose scores values targetScore targetValue scoreError valueError hs hv
    [] indices (initial shift) ⟨0, 0⟩ (initial_error targetScore targetValue shift) hf

-- Arithmetic range conditions are only required on the states actually
-- visited. The empty loop preserves the incoming state exactly.
theorem run_finite (p : Platform) (choose : Float32 → Float32 → Float32) (scores values : α → Float32)
    (indices : List α) (initial : State) (hf : Finite p choose scores values indices initial)
    (hi : initial.shift.isFinite = true ∧ initial.denominator.isFinite = true ∧ initial.numerator.isFinite = true) :
    (run p choose scores values indices initial).shift.isFinite = true ∧
      (run p choose scores values indices initial).denominator.isFinite = true ∧
      (run p choose scores values indices initial).numerator.isFinite = true := by
  induction indices generalizing initial with
  | nil => exact hi
  | cons i rest ih => exact ih (next p choose scores values i initial) hf.2 (step_finite p initial (scores i) (values i) _ hf.1)

end Inference.Kernels.Attention.SdpaLoop
