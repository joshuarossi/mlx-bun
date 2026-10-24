import kernels.quantization.AffineInput
import kernels.quantization.AffineDot

namespace Inference.Kernels.Quantization.AffineTile
open Contracts.Mlx Contracts.Mlx.Numerics ArithmeticFold
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

structure Platform where
  divide : Float32 → Float32 → Float32
  divError : Float32 → Float32 → ℝ
  division : Division.Contract divide divError
  -- The compiler's choice at each contraction site of the dot, as
  -- `AffineDot.expression3`/`expression4` number them; `tailContracted` at the tail.
  contracted : Nat → Bool
  tailContracted : Bool

def shift3 (i : Fin 8) : Fin 13 := ⟨AffineDot.inputShift3 i, by fin_cases i <;> decide⟩
def shift4 (i : Fin 4) : Fin 13 := ⟨4*i.val, by have := i.isLt; omega⟩
def prepared3 (p : Platform) (x : Fin 16 → BF) (chunk : Fin 2) (i : Fin 8) : Float32 :=
  AffineInput.prepare p.divide (x (AffineInput.index8 chunk i)) (shift3 i)
def prepared4 (p : Platform) (x : Fin 16 → BF) (chunk : Fin 4) (i : Fin 4) : Float32 :=
  AffineInput.prepare p.divide (x (AffineInput.index4 chunk i)) (shift4 i)

noncomputable def prepareBudget3 (p : Platform) (x : Fin 16 → BF) (error : Fin 16 → ℝ) (chunk : Fin 2) (i : Fin 8) : ℝ :=
  AffineInput.prepareBudget p.divError (x (AffineInput.index8 chunk i)) (shift3 i) (error (AffineInput.index8 chunk i))
noncomputable def prepareBudget4 (p : Platform) (x : Fin 16 → BF) (error : Fin 16 → ℝ) (chunk : Fin 4) (i : Fin 4) : ℝ :=
  AffineInput.prepareBudget p.divError (x (AffineInput.index4 chunk i)) (shift4 i) (error (AffineInput.index4 chunk i))

def step3 (p : Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (chunk : Fin 2) (acc : Float32) : Float32 :=
  AffineDot.source3 p.contracted (w chunk) (prepared3 p x chunk) acc
def step4 (p : Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (chunk : Fin 4) (acc : Float32) : Float32 :=
  AffineDot.source4 p.contracted (w chunk) (prepared4 p x chunk) acc

noncomputable def part3 (target : Fin 16 → ℝ) (w : Fin 2 → Fin 3 → BitVec 8) (chunk : Fin 2) : ℝ :=
  ∑ i, target (AffineInput.index8 chunk i) * AffinePacking.field3 (w chunk) i
noncomputable def part4 (target : Fin 16 → ℝ) (w : Fin 4 → BitVec 16) (chunk : Fin 4) : ℝ :=
  ∑ i, target (AffineInput.index4 chunk i) * AffinePacking.field4 (w chunk) i

def valid3 (p : Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (chunk : Fin 2) (acc : Float32) : Prop :=
  Arithmetic.Finite (AffineDot.bind3 (w chunk) (prepared3 p x chunk) acc) (AffineDot.expression3 p.contracted)
def valid4 (p : Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (chunk : Fin 4) (acc : Float32) : Prop :=
  Arithmetic.Finite (AffineDot.bind4 (w chunk) (prepared4 p x chunk) acc) (AffineDot.expression4 p.contracted)

noncomputable def cost3 (p : Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8)
    (target error : Fin 16 → ℝ) (chunk : Fin 2) (acc : Float32) (targetAcc accError : ℝ) : ℝ :=
  Arithmetic.budget (AffineDot.bind3 (w chunk) (prepared3 p x chunk) acc)
    (AffineDot.target3 (w chunk) (fun i => target (AffineInput.index8 chunk i)) targetAcc)
    (AffineDot.errors3 (prepareBudget3 p x error chunk) accError) (AffineDot.expression3 p.contracted)
noncomputable def cost4 (p : Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16)
    (target error : Fin 16 → ℝ) (chunk : Fin 4) (acc : Float32) (targetAcc accError : ℝ) : ℝ :=
  Arithmetic.budget (AffineDot.bind4 (w chunk) (prepared4 p x chunk) acc)
    (AffineDot.target4 (w chunk) (fun i => target (AffineInput.index4 chunk i)) targetAcc)
    (AffineDot.errors4 (prepareBudget4 p x error chunk) accError) (AffineDot.expression4 p.contracted)

structure DotFinite3 (p : Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) : Prop where
  input : ∀ i, Model.isFinite (x i) = true
  prepared : ∀ c i, (prepared3 p x c i).isFinite = true
  arithmetic : FoldFinite (step3 p x w) (valid3 p x w) (List.finRange 2) 0
structure DotFinite4 (p : Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) : Prop where
  input : ∀ i, Model.isFinite (x i) = true
  prepared : ∀ c i, (prepared4 p x c i).isFinite = true
  arithmetic : FoldFinite (step4 p x w) (valid4 p x w) (List.finRange 4) 0

def dot3 (p : Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) : Float32 :=
  (List.finRange 2).foldl (fun acc chunk => step3 p x w chunk acc) 0
def dot4 (p : Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) : Float32 :=
  (List.finRange 4).foldl (fun acc chunk => step4 p x w chunk acc) 0

noncomputable def dotBudget3 (p : Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (target error : Fin 16 → ℝ) : ℝ :=
  errorFold (step3 p x w) (part3 target w) (cost3 p x w target error) (List.finRange 2) 0 0 0
noncomputable def dotBudget4 (p : Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (target error : Fin 16 → ℝ) : ℝ :=
  errorFold (step4 p x w) (part4 target w) (cost4 p x w target error) (List.finRange 4) 0 0 0

private theorem zero_error : |real (0 : Float32) - 0| ≤ 0 := by
  have hz : real (0 : Float32) = 0 := by rw [real_unpack]; exact Model.unpackedToReal_zero .positive
  simp only [hz, sub_zero, abs_zero, le_refl]

theorem dot3_error (p : Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (target error : Fin 16 → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hf : DotFinite3 p x w) :
    |real (dot3 p x w) - ∑ c, part3 target w c| ≤ dotBudget3 p x w target error := by
  have hs : ∀ c acc targetAcc accError, valid3 p x w c acc → |real acc - targetAcc| ≤ accError →
      |real (step3 p x w c acc) - (targetAcc + part3 target w c)| ≤ cost3 p x w target error c acc targetAcc accError := by
    intro c acc targetAcc accError hv ha
    apply AffineDot.error3 p.contracted (w c) (prepared3 p x c) acc _ _ targetAcc accError _ ha hv
    intro i
    exact AffineInput.prepare_error p.divide p.divError p.division _ (shift3 i)
      (hf.input _) (hf.prepared c i) _ _ (hi _)
  have h := fold_error (step3 p x w) (part3 target w) (cost3 p x w target error) (valid3 p x w)
    hs (List.finRange 2) 0 0 0 hf.arithmetic zero_error
  simpa only [dot3, dotBudget3, ← Fin.sum_univ_def, zero_add] using h

theorem dot4_error (p : Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (target error : Fin 16 → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hf : DotFinite4 p x w) :
    |real (dot4 p x w) - ∑ c, part4 target w c| ≤ dotBudget4 p x w target error := by
  have hs : ∀ c acc targetAcc accError, valid4 p x w c acc → |real acc - targetAcc| ≤ accError →
      |real (step4 p x w c acc) - (targetAcc + part4 target w c)| ≤ cost4 p x w target error c acc targetAcc accError := by
    intro c acc targetAcc accError hv ha
    apply AffineDot.error4 p.contracted (w c) (prepared4 p x c) acc _ _ targetAcc accError _ ha hv
    intro i
    exact AffineInput.prepare_error p.divide p.divError p.division _ (shift4 i)
      (hf.input _) (hf.prepared c i) _ _ (hi _)
  have h := fold_error (step4 p x w) (part4 target w) (cost4 p x w target error) (valid4 p x w)
    hs (List.finRange 4) 0 0 0 hf.arithmetic zero_error
  simpa only [dot4, dotBudget4, ← Fin.sum_univ_def, zero_add] using h

def tailExpr (contracted : Bool) : Arithmetic.Expr := madd contracted (.input 0) (.input 1) (.mul (.input 2) (.input 3))
def tailBind (scale dot sum bias : Float32) : Nat → Float32
  | 0 => scale | 1 => dot | 2 => sum | _ => bias
noncomputable def tailTarget (scale dot sum bias : ℝ) : Nat → ℝ
  | 0 => scale | 1 => dot | 2 => sum | _ => bias
def combine (contracted : Bool) (scale : BF) (dot sum : Float32) (bias : BF) : Float32 :=
  maddFloat contracted (BFloat16.widen scale) dot (FlushToZero.mul sum (BFloat16.widen bias))

theorem tail_execution (contracted : Bool) (scale : BF) (dot sum : Float32) (bias : BF) :
    Arithmetic.evaluate (tailBind (BFloat16.widen scale) dot sum (BFloat16.widen bias)) (tailExpr contracted) =
      combine contracted scale dot sum bias := by
  simp only [tailExpr, evaluate_madd, Arithmetic.evaluate, tailBind, combine]

theorem tail_ideal (contracted : Bool) (scale dot sum bias : ℝ) :
    Arithmetic.ideal (tailTarget scale dot sum bias) (tailExpr contracted) = scale * dot + sum * bias := by
  simp only [tailExpr, ideal_madd, Arithmetic.ideal, tailTarget]
  ring

noncomputable def combineBudget (contracted : Bool) (scale : BF) (dot sum : Float32) (bias : BF)
    (targetDot targetSum dotError sumError : ℝ) : ℝ :=
  Arithmetic.budget (tailBind (BFloat16.widen scale) dot sum (BFloat16.widen bias))
    (tailTarget (Model.toReal scale) targetDot targetSum (Model.toReal bias)) (tailTarget 0 dotError sumError 0) (tailExpr contracted)

theorem combine_error (contracted : Bool) (scale : BF) (dot sum : Float32) (bias : BF)
    (hs : Model.isFinite scale = true) (hb : Model.isFinite bias = true)
    (targetDot targetSum dotError sumError : ℝ) (hd : |real dot - targetDot| ≤ dotError) (hu : |real sum - targetSum| ≤ sumError)
    (hf : Arithmetic.Finite (tailBind (BFloat16.widen scale) dot sum (BFloat16.widen bias)) (tailExpr contracted)) :
    |real (combine contracted scale dot sum bias) - (Model.toReal scale * targetDot + targetSum * Model.toReal bias)| ≤
      combineBudget contracted scale dot sum bias targetDot targetSum dotError sumError := by
  have he : ∀ i, |real (tailBind (BFloat16.widen scale) dot sum (BFloat16.widen bias) i) -
      tailTarget (Model.toReal scale) targetDot targetSum (Model.toReal bias) i| ≤ tailTarget 0 dotError sumError 0 i := by
    intro i
    match i with
    | 0 => simp [tailBind, tailTarget, BFloat16.widen_real _ hs]
    | 1 => exact hd
    | 2 => exact hu
    | n+3 => simp [tailBind, tailTarget, BFloat16.widen_real _ hb]
  have h := Arithmetic.error _ _ _ he (tailExpr contracted) hf
  rwa [tail_execution, tail_ideal] at h

theorem input_coverage3 (target : Fin 16 → ℝ) : (∑ c : Fin 2, ∑ i : Fin 8, target (AffineInput.index8 c i)) = ∑ i, target i := by
  simpa only [AffineInput.groups3, AffineInput.ideal_group8, AffineInput.ideal] using AffineInput.groups3_coverage target
theorem input_coverage4 (target : Fin 16 → ℝ) : (∑ c : Fin 4, ∑ i : Fin 4, target (AffineInput.index4 c i)) = ∑ i, target i := by
  simpa only [AffineInput.groups4, AffineInput.ideal_group4, AffineInput.ideal] using AffineInput.groups4_coverage target

theorem grouped_affine_identity (x quant : Fin groups → Fin width → ℝ) (scale bias : ℝ) :
    (∑ c, ∑ i, x c i * (scale * quant c i + bias)) =
      scale * (∑ c, ∑ i, x c i * quant c i) + (∑ c, ∑ i, x c i) * bias := by
  simp_rw [← AffinePacking.affine_identity]
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.sum_mul]

def value3 (p : Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (scale bias : BF) : Float32 :=
  combine p.tailContracted scale (dot3 p x w) (AffineInput.summed x AffineInput.groups3) bias
def value4 (p : Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (scale bias : BF) : Float32 :=
  combine p.tailContracted scale (dot4 p x w) (AffineInput.summed x AffineInput.groups4) bias

noncomputable def target3 (x : Fin 16 → ℝ) (w : Fin 2 → Fin 3 → BitVec 8) (scale bias : BF) : ℝ :=
  ∑ c, ∑ i, x (AffineInput.index8 c i) * (Model.toReal scale * AffinePacking.field3 (w c) i + Model.toReal bias)
noncomputable def target4 (x : Fin 16 → ℝ) (w : Fin 4 → BitVec 16) (scale bias : BF) : ℝ :=
  ∑ c, ∑ i, x (AffineInput.index4 c i) * (Model.toReal scale * AffinePacking.field4 (w c) i + Model.toReal bias)

theorem target3_formula (x : Fin 16 → ℝ) (w : Fin 2 → Fin 3 → BitVec 8) (scale bias : BF) :
    target3 x w scale bias = Model.toReal scale * (∑ c, part3 x w c) + (∑ i, x i) * Model.toReal bias := by
  unfold target3
  rw [grouped_affine_identity, input_coverage3]
  rfl
theorem target4_formula (x : Fin 16 → ℝ) (w : Fin 4 → BitVec 16) (scale bias : BF) :
    target4 x w scale bias = Model.toReal scale * (∑ c, part4 x w c) + (∑ i, x i) * Model.toReal bias := by
  unfold target4
  rw [grouped_affine_identity, input_coverage4]
  rfl

structure Finite3 (p : Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (scale bias : BF) : Prop where
  dot : DotFinite3 p x w
  groups : ∀ i, AffineInput.Finite x (AffineInput.groups3 i)
  sum : Arithmetic.Finite (AffineInput.bind (fun i => BFloat16.widen (AffineInput.evaluate x (AffineInput.groups3 i)))) (AffineInput.sumExpression 2)
  scaleFinite : Model.isFinite scale = true
  biasFinite : Model.isFinite bias = true
  tail : Arithmetic.Finite (tailBind (BFloat16.widen scale) (dot3 p x w) (AffineInput.summed x AffineInput.groups3) (BFloat16.widen bias)) (tailExpr p.tailContracted)
structure Finite4 (p : Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (scale bias : BF) : Prop where
  dot : DotFinite4 p x w
  groups : ∀ i, AffineInput.Finite x (AffineInput.groups4 i)
  sum : Arithmetic.Finite (AffineInput.bind (fun i => BFloat16.widen (AffineInput.evaluate x (AffineInput.groups4 i)))) (AffineInput.sumExpression 4)
  scaleFinite : Model.isFinite scale = true
  biasFinite : Model.isFinite bias = true
  tail : Arithmetic.Finite (tailBind (BFloat16.widen scale) (dot4 p x w) (AffineInput.summed x AffineInput.groups4) (BFloat16.widen bias)) (tailExpr p.tailContracted)

noncomputable def budget3 (p : Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (scale bias : BF) (target error : Fin 16 → ℝ) : ℝ :=
  combineBudget p.tailContracted scale (dot3 p x w) (AffineInput.summed x AffineInput.groups3) bias
    (∑ c, part3 target w c) (∑ i, target i) (dotBudget3 p x w target error) (AffineInput.summedBudget x target error AffineInput.groups3)
noncomputable def budget4 (p : Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (scale bias : BF) (target error : Fin 16 → ℝ) : ℝ :=
  combineBudget p.tailContracted scale (dot4 p x w) (AffineInput.summed x AffineInput.groups4) bias
    (∑ c, part4 target w c) (∑ i, target i) (dotBudget4 p x w target error) (AffineInput.summedBudget x target error AffineInput.groups4)

theorem value3_error (p : Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (scale bias : BF)
    (target error : Fin 16 → ℝ) (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hf : Finite3 p x w scale bias) :
    |real (value3 p x w scale bias) - target3 target w scale bias| ≤ budget3 p x w scale bias target error := by
  rw [target3_formula]
  exact combine_error p.tailContracted scale _ _ bias hf.scaleFinite hf.biasFinite _ _ _ _
    (dot3_error p x w target error hi hf.dot) (AffineInput.sum3_error x target error hi hf.groups hf.sum) hf.tail

theorem value4_error (p : Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (scale bias : BF)
    (target error : Fin 16 → ℝ) (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hf : Finite4 p x w scale bias) :
    |real (value4 p x w scale bias) - target4 target w scale bias| ≤ budget4 p x w scale bias target error := by
  rw [target4_formula]
  exact combine_error p.tailContracted scale _ _ bias hf.scaleFinite hf.biasFinite _ _ _ _
    (dot4_error p x w target error hi hf.dot) (AffineInput.sum4_error x target error hi hf.groups hf.sum) hf.tail

end Inference.Kernels.Quantization.AffineTile
