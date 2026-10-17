import kernels.attention.SdpaNormalize
import contracts.mlx.FlushedReduction

namespace Inference.Kernels.Attention.SdpaMerge
open Contracts.Mlx Contracts.Mlx.Numerics ArithmeticFold SdpaUpdate
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

-- The 32 groups' partial numerators and denominators are rescaled to a
-- common shift before their SIMD sums. Each real reference shift is the
-- actual float shift, so maximum selection does not add a fictitious error.
structure Platform where
  scalar : SdpaUpdate.Platform
  reduce : (Fin 32 → Float32) → Float32
  reduction : FlushedReduction.SimdContract reduce

def component (s : State) (numerator : Bool) : Float32 := if numerator then s.numerator else s.denominator
noncomputable def referenceComponent (s : OnlineSoftmax.Summary) (numerator : Bool) : ℝ :=
  if numerator then s.numerator else s.denominator
noncomputable def errorComponent (e : Error) (numerator : Bool) : ℝ := if numerator then e.numerator else e.denominator

def operands (left right : Fin 32 → α) (i : Nat) : α :=
  if h : i < 32 then left ⟨i, h⟩ else right ⟨(i-32)%32, by omega⟩

theorem operands_left (left right : Fin 32 → α) (i : Fin 32) : operands left right i.val = left i := by simp [operands, i.isLt]
theorem operands_right (left right : Fin 32 → α) (i : Fin 32) : operands left right (32+i.val) = right i := by
  have hi := i.isLt
  simp [operands, show ¬32+i.val < 32 by omega, Nat.mod_eq_of_lt hi]

def bind (p : Platform) (states : Fin 32 → State) (shift : Float32) (numerator : Bool) : Nat → Float32 :=
  operands (fun i => component (states i) numerator) (fun i => exponential p.scalar (states i).shift shift)
noncomputable def targetBind (states : Fin 32 → OnlineSoftmax.Summary) (shift : ℝ) (numerator : Bool) : Nat → ℝ :=
  operands (fun i => referenceComponent (states i) numerator) (fun i => Real.exp ((states i).shift - shift))
noncomputable def inputBudget (p : Platform) (states : Fin 32 → State) (shift : Float32)
    (targets : Fin 32 → OnlineSoftmax.Summary) (errors : Fin 32 → Error) (numerator : Bool) : Nat → ℝ :=
  operands (fun i => errorComponent (errors i) numerator)
    (fun i => exponentialBudget p.scalar (states i).shift shift (targets i).shift 0)

def expression (tree : Reduction.Tree 32) : Arithmetic.Expr :=
  reduceExpr (fun i => .mul (.input i.val) (.input (32+i.val))) tree

def source (p : Platform) (states : Fin 32 → State) (shift : Float32) (numerator : Bool) : Float32 :=
  p.reduce (fun i => FlushToZero.mul (component (states i) numerator) (exponential p.scalar (states i).shift shift))

def forward (p : Platform) (states : Fin 32 → State) (shift : Float32) : State :=
  ⟨shift, source p states shift false, source p states shift true⟩
noncomputable def targetComponent (states : Fin 32 → OnlineSoftmax.Summary) (shift : ℝ) (numerator : Bool) : ℝ :=
  ∑ i, referenceComponent (states i) numerator * Real.exp ((states i).shift - shift)
noncomputable def target (states : Fin 32 → OnlineSoftmax.Summary) (shift : ℝ) : OnlineSoftmax.Summary :=
  ⟨shift, targetComponent states shift false, targetComponent states shift true⟩
noncomputable def componentBudget (p : Platform) (states : Fin 32 → State) (shift : Float32)
    (targets : Fin 32 → OnlineSoftmax.Summary) (errors : Fin 32 → Error) (numerator : Bool) : ℝ :=
  Arithmetic.budget (bind p states shift numerator) (targetBind targets (real shift) numerator)
    (inputBudget p states shift targets errors numerator) (expression p.reduction.tree)
noncomputable def budget (p : Platform) (states : Fin 32 → State) (shift : Float32)
    (targets : Fin 32 → OnlineSoftmax.Summary) (errors : Fin 32 → Error) : Error :=
  ⟨componentBudget p states shift targets errors false, componentBudget p states shift targets errors true⟩

structure Finite (p : Platform) (states : Fin 32 → State) (shift : Float32) : Prop where
  factor : ∀ i, ExponentFinite p.scalar (states i).shift shift
  arithmetic : ∀ numerator, Arithmetic.Finite (bind p states shift numerator) (expression p.reduction.tree)

theorem bind_error (p : Platform) (states : Fin 32 → State) (shift : Float32)
    (targets : Fin 32 → OnlineSoftmax.Summary) (errors : Fin 32 → Error)
    (he : ∀ i, StateError (states i) (targets i) (errors i)) (hf : Finite p states shift) (numerator : Bool) (i : Nat) :
    |real (bind p states shift numerator i) - targetBind targets (real shift) numerator i| ≤ inputBudget p states shift targets errors numerator i := by
  unfold bind targetBind inputBudget operands
  split
  · cases numerator
    · exact (he _).denominator
    · exact (he _).numerator
  · exact exponential_error p.scalar _ shift _ 0 (hf.factor _) (by rw [(he _).shift]; simp)

theorem execution (p : Platform) (states : Fin 32 → State) (shift : Float32) (numerator : Bool) :
    Arithmetic.evaluate (bind p states shift numerator) (expression p.reduction.tree) = source p states shift numerator := by
  unfold expression source
  rw [evaluate_reduce, p.reduction.execution]
  apply congrArg (fun f => FlushedReduction.evaluate f p.reduction.tree)
  funext i
  simp only [Arithmetic.evaluate, bind, operands_left, operands_right]

theorem ideal (tree : Reduction.Tree 32) (hc : (Reduction.leaves tree).Perm (List.finRange 32))
    (states : Fin 32 → OnlineSoftmax.Summary) (shift : ℝ) (numerator : Bool) :
    Arithmetic.ideal (targetBind states shift numerator) (expression tree) = targetComponent states shift numerator := by
  unfold expression targetComponent
  rw [ideal_reduce, Reduction.ideal_complete _ tree hc, ← Fin.sum_univ_def]
  apply Finset.sum_congr rfl
  intro i _
  simp only [Arithmetic.ideal, targetBind, operands_left, operands_right]

theorem component_error (p : Platform) (states : Fin 32 → State) (shift : Float32)
    (targets : Fin 32 → OnlineSoftmax.Summary) (errors : Fin 32 → Error)
    (he : ∀ i, StateError (states i) (targets i) (errors i)) (hf : Finite p states shift) (numerator : Bool) :
    |real (source p states shift numerator) - targetComponent targets (real shift) numerator| ≤
      componentBudget p states shift targets errors numerator := by
  have h := Arithmetic.error (bind p states shift numerator) (targetBind targets (real shift) numerator)
    (inputBudget p states shift targets errors numerator) (bind_error p states shift targets errors he hf numerator)
    (expression p.reduction.tree) (hf.arithmetic numerator)
  rwa [execution, ideal p.reduction.tree p.reduction.coverage] at h

theorem forward_error (p : Platform) (states : Fin 32 → State) (shift : Float32)
    (targets : Fin 32 → OnlineSoftmax.Summary) (errors : Fin 32 → Error)
    (he : ∀ i, StateError (states i) (targets i) (errors i)) (hf : Finite p states shift) :
    StateError (forward p states shift) (target targets (real shift)) (budget p states shift targets errors) :=
  ⟨rfl, component_error p states shift targets errors he hf false, component_error p states shift targets errors he hf true⟩

theorem forward_finite (p : Platform) (states : Fin 32 → State) (shift : Float32) (hf : Finite p states shift) :
    (forward p states shift).shift.isFinite = true ∧ (forward p states shift).denominator.isFinite = true ∧
      (forward p states shift).numerator.isFinite = true := by
  have hd := Arithmetic.finite_evaluate (bind p states shift false) (expression p.reduction.tree) (hf.arithmetic false)
  have hn := Arithmetic.finite_evaluate (bind p states shift true) (expression p.reduction.tree) (hf.arithmetic true)
  rw [execution] at hd hn
  exact ⟨(hf.factor 0).shiftFinite, hd, hn⟩

theorem denominator_flatMap (score : α → ℝ) (groups : List β) (indices : β → List α) (shift : ℝ) :
    OnlineSoftmax.denominator score (groups.flatMap indices) shift =
      (groups.map (fun g => OnlineSoftmax.denominator score (indices g) shift)).sum := by
  induction groups with
  | nil => simp [OnlineSoftmax.denominator]
  | cons g rest ih =>
    simpa only [List.flatMap_cons, OnlineSoftmax.denominator, List.map_append, List.sum_append, List.map_cons, List.sum_cons] using
      congrArg (fun s => OnlineSoftmax.denominator score (indices g) shift + s) ih

theorem numerator_flatMap (score value : α → ℝ) (groups : List β) (indices : β → List α) (shift : ℝ) :
    OnlineSoftmax.numerator score value (groups.flatMap indices) shift =
      (groups.map (fun g => OnlineSoftmax.numerator score value (indices g) shift)).sum := by
  induction groups with
  | nil => simp [OnlineSoftmax.numerator]
  | cons g rest ih =>
    simpa only [List.flatMap_cons, OnlineSoftmax.numerator, List.map_append, List.sum_append, List.map_cons, List.sum_cons] using
      congrArg (fun s => OnlineSoftmax.numerator score value (indices g) shift + s) ih

theorem target_reference (score value : α → ℝ) (indices : Fin 32 → List α) (shifts : Fin 32 → ℝ) (shift : ℝ) :
    target (fun i => OnlineSoftmax.reference score value (indices i) (shifts i)) shift =
      OnlineSoftmax.reference score value ((List.finRange 32).flatMap indices) shift := by
  have hd : ∀ i : Fin 32, OnlineSoftmax.denominator score (indices i) (shifts i) * Real.exp (shifts i - shift) =
      OnlineSoftmax.denominator score (indices i) shift := by
    intro i
    rw [mul_comm, OnlineSoftmax.denominator_rescale]
  have hn : ∀ i : Fin 32, OnlineSoftmax.numerator score value (indices i) (shifts i) * Real.exp (shifts i - shift) =
      OnlineSoftmax.numerator score value (indices i) shift := by
    intro i
    rw [mul_comm, OnlineSoftmax.numerator_rescale]
  unfold target targetComponent referenceComponent OnlineSoftmax.reference
  simp only [Bool.false_eq_true, ite_false, ite_true]
  congr 1
  · simp_rw [hd]
    rw [Fin.sum_univ_def, denominator_flatMap]
  · simp_rw [hn]
    rw [Fin.sum_univ_def, numerator_flatMap]

-- The final quotient is the softmax-weighted sum over all concatenated key
-- lists. A layout theorem will identify that list with the cache's key range.
theorem normalized_error (p : Platform) (normalization : SdpaNormalize.Platform)
    (states : Fin 32 → State) (shift : Float32) (score value : α → ℝ) (indices : Fin 32 → List α)
    (errors : Fin 32 → Error)
    (he : ∀ i, StateError (states i) (OnlineSoftmax.reference score value (indices i) (real (states i).shift)) (errors i))
    (hf : Finite p states shift) (hn : SdpaNormalize.Finite normalization (forward p states shift))
    (hne : (List.finRange 32).flatMap indices ≠ []) :
    |Model.toReal (SdpaNormalize.value normalization (forward p states shift)) -
      OnlineSoftmax.softmaxWeighted score value ((List.finRange 32).flatMap indices)| ≤
    SdpaNormalize.budget normalization (forward p states shift)
      (OnlineSoftmax.reference score value ((List.finRange 32).flatMap indices) (real shift))
      (budget p states shift (fun i => OnlineSoftmax.reference score value (indices i) (real (states i).shift)) errors) := by
  have hm := forward_error p states shift _ errors he hf
  rw [target_reference] at hm
  have h := SdpaNormalize.value_error normalization _ _ _ hn hm (OnlineSoftmax.denominator_positive score _ _ hne)
  rwa [OnlineSoftmax.normalized_reference] at h

end Inference.Kernels.Attention.SdpaMerge
