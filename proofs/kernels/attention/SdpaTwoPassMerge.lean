import kernels.attention.SdpaTwoPassReduction
import kernels.attention.SdpaMerge
import contracts.mlx.FlushedIdentities

namespace Inference.Kernels.Attention.SdpaTwoPassMerge
open Contracts.Mlx Contracts.Mlx.Numerics ArithmeticFold SdpaUpdate
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

-- The second kernel reads FP32 maxima/sums and widened BF16 partials.
-- Unlike the one-pass merge, each lane accumulates several products first.
-- The contraction choice and SIMD tree are explicit platform contracts.
def operands (left right : Fin blocks → α) (fallback : α) (i : Nat) : α :=
  if h : i < blocks then left ⟨i, h⟩
  else if h : i-blocks < blocks then right ⟨i-blocks, h⟩ else fallback

theorem operands_left (left right : Fin blocks → α) (fallback : α) (i : Fin blocks) :
    operands left right fallback i.val = left i := by simp [operands, i.isLt]
theorem operands_right (left right : Fin blocks → α) (fallback : α) (i : Fin blocks) :
    operands left right fallback (blocks+i.val) = right i := by
  have hi := i.isLt
  simp [operands, show ¬blocks+i.val < blocks by omega, hi]

def bind (p : SdpaMerge.Platform) (states : Fin blocks → State) (shift : Float32) (numerator : Bool) : Nat → Float32 :=
  operands (fun i => exponential p.scalar (states i).shift shift)
    (fun i => SdpaMerge.component (states i) numerator) 0
noncomputable def targetBind (states : Fin blocks → OnlineSoftmax.Summary) (shift : ℝ) (numerator : Bool) : Nat → ℝ :=
  operands (fun i => Real.exp ((states i).shift-shift))
    (fun i => SdpaMerge.referenceComponent (states i) numerator) 0
noncomputable def inputBudget (p : SdpaMerge.Platform) (states : Fin blocks → State) (shift : Float32)
    (targets : Fin blocks → OnlineSoftmax.Summary) (errors : Fin blocks → Error) (numerator : Bool) : Nat → ℝ :=
  operands (fun i => exponentialBudget p.scalar (states i).shift shift (targets i).shift 0)
    (fun i => SdpaMerge.errorComponent (errors i) numerator) 0

def expression (blocks : Nat) (contracted : Bool) (tree : Reduction.Tree 32) : Arithmetic.Expr :=
  SdpaTwoPassReduction.expression contracted (fun i : Fin blocks => .input i.val)
    (fun i => .input (blocks+i.val)) tree
def source (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State)
    (shift : Float32) (numerator : Bool) : Float32 :=
  p.reduce (fun thread => (SdpaLayout.keys blocks thread).foldl (fun acc i =>
    maddFloat contracted (exponential p.scalar (states i).shift shift)
      (SdpaMerge.component (states i) numerator) acc) 0)
def forward (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State) (shift : Float32) : State :=
  ⟨shift, source p contracted states shift false, source p contracted states shift true⟩
noncomputable def targetComponent (states : Fin blocks → OnlineSoftmax.Summary) (shift : ℝ) (numerator : Bool) : ℝ :=
  ∑ i, Real.exp ((states i).shift-shift)*SdpaMerge.referenceComponent (states i) numerator
noncomputable def target (states : Fin blocks → OnlineSoftmax.Summary) (shift : ℝ) : OnlineSoftmax.Summary :=
  ⟨shift, targetComponent states shift false, targetComponent states shift true⟩
noncomputable def componentBudget (p : SdpaMerge.Platform) (contracted : Bool)
    (states : Fin blocks → State) (shift : Float32) (targets : Fin blocks → OnlineSoftmax.Summary)
    (errors : Fin blocks → Error) (numerator : Bool) : ℝ :=
  Arithmetic.budget (bind p states shift numerator) (targetBind targets (real shift) numerator)
    (inputBudget p states shift targets errors numerator) (expression blocks contracted p.reduction.tree)
noncomputable def budget (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State)
    (shift : Float32) (targets : Fin blocks → OnlineSoftmax.Summary) (errors : Fin blocks → Error) : Error :=
  ⟨componentBudget p contracted states shift targets errors false,
    componentBudget p contracted states shift targets errors true⟩

structure Finite (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State) (shift : Float32) : Prop where
  factor : ∀ i, ExponentFinite p.scalar (states i).shift shift
  arithmetic : ∀ numerator, Arithmetic.Finite (bind p states shift numerator) (expression blocks contracted p.reduction.tree)

theorem bind_error (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State) (shift : Float32)
    (targets : Fin blocks → OnlineSoftmax.Summary) (errors : Fin blocks → Error)
    (he : ∀ i, StateError (states i) (targets i) (errors i)) (hf : Finite p contracted states shift)
    (numerator : Bool) (i : Nat) :
    |real (bind p states shift numerator i)-targetBind targets (real shift) numerator i| ≤
      inputBudget p states shift targets errors numerator i := by
  unfold bind targetBind inputBudget operands
  split
  · exact exponential_error p.scalar _ shift _ 0 (hf.factor _) (by rw [(he _).shift]; simp)
  · split
    · cases numerator
      · exact (he _).denominator
      · exact (he _).numerator
    · simp [FlushedIdentities.zero_real]

theorem execution (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State)
    (shift : Float32) (numerator : Bool) :
    Arithmetic.evaluate (bind p states shift numerator) (expression blocks contracted p.reduction.tree) =
      source p contracted states shift numerator := by
  unfold expression SdpaTwoPassReduction.expression source
  rw [evaluate_reduce, p.reduction.execution]
  apply congrArg (fun f => FlushedReduction.evaluate f p.reduction.tree)
  funext thread
  unfold SdpaTwoPassReduction.lane WeightedFold.ordered
  rw [evaluate_fold]
  simp only [Arithmetic.evaluate, bind, operands_left, operands_right]

theorem ideal (contracted : Bool) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32))
    (states : Fin blocks → OnlineSoftmax.Summary) (shift : ℝ) (numerator : Bool) :
    Arithmetic.ideal (targetBind states shift numerator) (expression blocks contracted tree) =
      targetComponent states shift numerator := by
  unfold expression SdpaTwoPassReduction.expression
  rw [ideal_reduce, Reduction.ideal_complete _ tree coverage, ← Fin.sum_univ_def]
  simp only [SdpaTwoPassReduction.lane, WeightedFold.ordered, ideal_fold, Arithmetic.ideal,
    zero_add, targetBind, operands_left, operands_right]
  exact SdpaTwoPassReduction.partition_sum _

theorem component_error (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State)
    (shift : Float32) (targets : Fin blocks → OnlineSoftmax.Summary) (errors : Fin blocks → Error)
    (he : ∀ i, StateError (states i) (targets i) (errors i)) (hf : Finite p contracted states shift) (numerator : Bool) :
    |real (source p contracted states shift numerator)-targetComponent targets (real shift) numerator| ≤
      componentBudget p contracted states shift targets errors numerator := by
  have h := Arithmetic.error (bind p states shift numerator) (targetBind targets (real shift) numerator)
    (inputBudget p states shift targets errors numerator) (bind_error p contracted states shift targets errors he hf numerator)
    (expression blocks contracted p.reduction.tree) (hf.arithmetic numerator)
  rwa [execution, ideal contracted p.reduction.tree p.reduction.coverage] at h

theorem forward_error (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State)
    (shift : Float32) (targets : Fin blocks → OnlineSoftmax.Summary) (errors : Fin blocks → Error)
    (he : ∀ i, StateError (states i) (targets i) (errors i)) (hf : Finite p contracted states shift) :
    StateError (forward p contracted states shift) (target targets (real shift))
      (budget p contracted states shift targets errors) :=
  ⟨rfl, component_error p contracted states shift targets errors he hf false,
    component_error p contracted states shift targets errors he hf true⟩

theorem forward_finite (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State)
    (shift : Float32) (hf : Finite p contracted states shift) (hs : shift.isFinite = true) :
    (forward p contracted states shift).shift.isFinite = true ∧
      (forward p contracted states shift).denominator.isFinite = true ∧
      (forward p contracted states shift).numerator.isFinite = true := by
  have hd := Arithmetic.finite_evaluate _ _ (hf.arithmetic false)
  have hn := Arithmetic.finite_evaluate _ _ (hf.arithmetic true)
  rw [execution] at hd hn
  exact ⟨hs, hd, hn⟩

theorem target_reference (score value : α → ℝ) (indices : Fin blocks → List α)
    (shifts : Fin blocks → ℝ) (shift : ℝ) :
    target (fun i => OnlineSoftmax.reference score value (indices i) (shifts i)) shift =
      OnlineSoftmax.reference score value ((List.finRange blocks).flatMap indices) shift := by
  have hd (i : Fin blocks) := OnlineSoftmax.denominator_rescale score (indices i) (shifts i) shift
  have hn (i : Fin blocks) := OnlineSoftmax.numerator_rescale score value (indices i) (shifts i) shift
  unfold target targetComponent SdpaMerge.referenceComponent OnlineSoftmax.reference
  simp only [Bool.false_eq_true, ite_false, ite_true]
  congr 1
  · simp_rw [hd]
    rw [Fin.sum_univ_def, SdpaMerge.denominator_flatMap]
  · simp_rw [hn]
    rw [Fin.sum_univ_def, SdpaMerge.numerator_flatMap]

theorem normalized_error (p : SdpaMerge.Platform) (normalization : SdpaNormalize.Platform)
    (contracted : Bool) (states : Fin blocks → State) (shift : Float32)
    (score value : α → ℝ) (indices : Fin blocks → List α) (errors : Fin blocks → Error)
    (he : ∀ i, StateError (states i) (OnlineSoftmax.reference score value (indices i) (real (states i).shift)) (errors i))
    (hf : Finite p contracted states shift) (hn : SdpaNormalize.Finite normalization (forward p contracted states shift))
    (hne : (List.finRange blocks).flatMap indices ≠ []) :
    |Model.toReal (SdpaNormalize.value normalization (forward p contracted states shift))-
      OnlineSoftmax.softmaxWeighted score value ((List.finRange blocks).flatMap indices)| ≤
      SdpaNormalize.budget normalization (forward p contracted states shift)
        (OnlineSoftmax.reference score value ((List.finRange blocks).flatMap indices) (real shift))
        (budget p contracted states shift
          (fun i => OnlineSoftmax.reference score value (indices i) (real (states i).shift)) errors) := by
  have hm := forward_error p contracted states shift _ errors he hf
  rw [target_reference] at hm
  have h := SdpaNormalize.value_error normalization _ _ _ hn hm (OnlineSoftmax.denominator_positive score _ _ hne)
  rwa [OnlineSoftmax.normalized_reference] at h

end Inference.Kernels.Attention.SdpaTwoPassMerge
