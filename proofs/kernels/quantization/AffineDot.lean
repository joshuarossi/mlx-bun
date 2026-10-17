import contracts.mlx.ArithmeticFold
import kernels.quantization.AffineLift

namespace Inference.Kernels.Quantization.AffineDot
open Contracts.Mlx Contracts.Mlx.Numerics ArithmeticFold
open scoped BigOperators
open Arithmetic (Expr)

def byte3 (i : Fin 10) : Fin 3 :=
  if i.val < 3 then 0 else if i.val < 7 then 1 else 2
def width3 (i : Fin 10) : Nat :=
  if i.val = 2 ∨ i.val = 7 then 2 else if i.val = 3 ∨ i.val = 6 then 1 else 3
def shift3 (i : Fin 10) : Nat :=
  match i.val with
  | 0 => 0 | 1 => 3 | 2 => 6 | 3 => 0 | 4 => 1 | 5 => 4 | 6 => 7 | 7 => 0 | 8 => 2 | _ => 5
def coordinate3 (i : Fin 10) : Fin 8 :=
  match i.val with
  | 0 => 0 | 1 => 1 | 2 => 2 | 3 => 2 | 4 => 3 | 5 => 4 | 6 => 5 | 7 => 5 | 8 => 6 | _ => 7
def crossed3 (i : Fin 10) : Bool := i.val == 3 || i.val == 7
def inputShift3 (i : Fin 8) : Nat :=
  match i.val with
  | 0 => 0 | 1 => 3 | 2 => 6 | 3 => 1 | 4 => 4 | 5 => 7 | 6 => 2 | _ => 5

def mask3 (w : Fin 3 → BitVec 8) (i : Fin 10) : Nat :=
  AffinePacking.mask8 (w (byte3 i)) ((2^(width3 i)-1)*2^(shift3 i))

theorem mask3_exact (w : Fin 3 → BitVec 8) (i : Fin 10) : real (AffineLift.value (mask3 w i)) = mask3 w i := by
  have hm : (2^(width3 i)-1)*2^(shift3 i) < 256 := by fin_cases i <;> decide
  have hw : width3 i ≤ 4 := by fin_cases i <;> decide
  have hs : shift3 i < 13 := by fin_cases i <;> decide
  simpa only [mask3, AffinePacking.mask8, BitVec.toNat_and, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hm] using
    AffineLift.mask_exact (w (byte3 i)).toNat (width3 i) (shift3 i) hw hs

def bind3 (w : Fin 3 → BitVec 8) (scaled : Fin 8 → Float32) (acc : Float32) (i : Nat) : Float32 :=
  if h : i < 8 then scaled ⟨i, h⟩ else if h : i < 18 then AffineLift.value (mask3 w ⟨i-8, by omega⟩)
  else if i = 18 then 256 else acc

noncomputable def target3 (w : Fin 3 → BitVec 8) (x : Fin 8 → ℝ) (acc : ℝ) (i : Nat) : ℝ :=
  if h : i < 8 then x ⟨i, h⟩ / 2^(inputShift3 ⟨i, h⟩) else if h : i < 18 then mask3 w ⟨i-8, by omega⟩
  else if i = 18 then 256 else acc

noncomputable def errors3 (scaledError : Fin 8 → ℝ) (accError : ℝ) (i : Nat) : ℝ :=
  if h : i < 8 then scaledError ⟨i, h⟩ else if i < 19 then 0 else accError

def left3 (i : Fin 10) : Expr := .input (8+i.val)
def right3 (i : Fin 10) : Expr :=
  if crossed3 i then .mul (.input (coordinate3 i).val) (.input 18) else .input (coordinate3 i).val
def expression3 (contracted : Bool) : Expr :=
  (List.finRange 10).foldl (fun acc i => madd contracted (left3 i) (right3 i) acc) (.input 19)

def source3 (contracted : Bool) (w : Fin 3 → BitVec 8) (scaled : Fin 8 → Float32) (acc : Float32) : Float32 :=
  (List.finRange 10).foldl (fun acc i => maddFloat contracted (AffineLift.value (mask3 w i))
    (if crossed3 i then FlushToZero.mul (scaled (coordinate3 i)) 256 else scaled (coordinate3 i)) acc) acc

theorem execution3 (contracted : Bool) (w : Fin 3 → BitVec 8) (scaled : Fin 8 → Float32) (acc : Float32) :
    Arithmetic.evaluate (bind3 w scaled acc) (expression3 contracted) = source3 contracted w scaled acc := by
  unfold expression3 source3
  rw [evaluate_fold]
  have hl (i : Fin 10) : Arithmetic.evaluate (bind3 w scaled acc) (left3 i) = AffineLift.value (mask3 w i) := by
    have := i.isLt
    simp [left3, Arithmetic.evaluate, bind3, show ¬8+i.val < 8 by omega, show 8+i.val < 18 by omega]
  have hr (i : Fin 10) : Arithmetic.evaluate (bind3 w scaled acc) (right3 i) =
      if crossed3 i then FlushToZero.mul (scaled (coordinate3 i)) 256 else scaled (coordinate3 i) := by
    unfold right3
    split <;> simp [Arithmetic.evaluate, bind3, (coordinate3 i).isLt, *]
  simp only [hl, hr]
  rfl

theorem ideal3 (contracted : Bool) (w : Fin 3 → BitVec 8) (x : Fin 8 → ℝ) (acc : ℝ) :
    Arithmetic.ideal (target3 w x acc) (expression3 contracted) = acc + ∑ i, x i * AffinePacking.field3 w i := by
  unfold expression3
  rw [ideal_fold]
  rw [← AffinePacking.qdot3_correct]
  simp [← Fin.sum_univ_def, Fin.sum_univ_succ, left3, right3, crossed3, coordinate3, target3,
    Arithmetic.ideal, mask3, byte3, width3, shift3, inputShift3, AffinePacking.qdot3]
  ring

private theorem real256 : real (256 : Float32) = 256 := by
  rw [real_unpack]
  change FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal
    (.finite .positive 8388608 (-15) (by decide)) = 256
  rw [FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal_finite]
  norm_num [FloatLib.Floats.Formats.BinaryInterchange.Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow]
  change 8388608 * ((2 : ℝ)^15)⁻¹ = 256
  norm_num

theorem bind3_error (w : Fin 3 → BitVec 8) (scaled : Fin 8 → Float32) (acc : Float32)
    (target scaledError : Fin 8 → ℝ) (targetAcc accError : ℝ)
    (hx : ∀ i, |real (scaled i) - target i / 2^(inputShift3 i)| ≤ scaledError i)
    (ha : |real acc - targetAcc| ≤ accError) (i : Nat) :
    |real (bind3 w scaled acc i) - target3 w target targetAcc i| ≤ errors3 scaledError accError i := by
  unfold bind3 target3 errors3
  split
  · exact hx _
  · split
    · simp only [show i < 19 by omega, ite_true, mask3_exact, sub_self, abs_zero, le_refl]
    · split
      · subst i; simp [real256]
      · simpa only [show ¬i < 19 by omega, ite_false] using ha

theorem error3 (contracted : Bool) (w : Fin 3 → BitVec 8) (scaled : Fin 8 → Float32) (acc : Float32)
    (target scaledError : Fin 8 → ℝ) (targetAcc accError : ℝ)
    (hx : ∀ i, |real (scaled i) - target i / 2^(inputShift3 i)| ≤ scaledError i)
    (ha : |real acc - targetAcc| ≤ accError)
    (hf : Arithmetic.Finite (bind3 w scaled acc) (expression3 contracted)) :
    |real (source3 contracted w scaled acc) - (targetAcc + ∑ i, target i * AffinePacking.field3 w i)| ≤
      Arithmetic.budget (bind3 w scaled acc) (target3 w target targetAcc) (errors3 scaledError accError) (expression3 contracted) := by
  have h := Arithmetic.error _ _ _ (bind3_error w scaled acc target scaledError targetAcc accError hx ha) (expression3 contracted) hf
  rwa [execution3, ideal3] at h

def mask4 (w : BitVec 16) (i : Fin 4) : Nat := AffinePacking.mask16 w (15 * 2^(4*i.val))

theorem mask4_exact (w : BitVec 16) (i : Fin 4) : real (AffineLift.value (mask4 w i)) = mask4 w i := by
  have hm : 15 * 2^(4*i.val) < 65536 := by fin_cases i <;> decide
  have hs : 4*i.val < 13 := by have := i.isLt; omega
  simpa only [mask4, AffinePacking.mask16, BitVec.toNat_and, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hm,
    show 2^4-1 = 15 from rfl] using AffineLift.mask_exact w.toNat 4 (4*i.val) (by decide) hs

def bind4 (w : BitVec 16) (scaled : Fin 4 → Float32) (acc : Float32) (i : Nat) : Float32 :=
  if h : i < 4 then scaled ⟨i, h⟩ else if h : i < 8 then AffineLift.value (mask4 w ⟨i-4, by omega⟩) else acc

noncomputable def target4 (w : BitVec 16) (x : Fin 4 → ℝ) (acc : ℝ) (i : Nat) : ℝ :=
  if h : i < 4 then x ⟨i, h⟩ / 2^(4*i) else if h : i < 8 then mask4 w ⟨i-4, by omega⟩ else acc

noncomputable def errors4 (scaledError : Fin 4 → ℝ) (accError : ℝ) (i : Nat) : ℝ :=
  if h : i < 4 then scaledError ⟨i, h⟩ else if i < 8 then 0 else accError

-- The four-bit path groups four products before adding the group to accum;
-- unlike the three-bit path, it is not ten successive updates of accum.
def expression4 (contracted : Bool) : Expr :=
  .add (.input 8) (madd contracted (.input 3) (.input 7)
    (madd contracted (.input 2) (.input 6) (madd contracted (.input 1) (.input 5) (.mul (.input 0) (.input 4)))))

def source4 (contracted : Bool) (w : BitVec 16) (scaled : Fin 4 → Float32) (acc : Float32) : Float32 :=
  FlushToZero.add acc (maddFloat contracted (scaled 3) (AffineLift.value (mask4 w 3))
    (maddFloat contracted (scaled 2) (AffineLift.value (mask4 w 2))
      (maddFloat contracted (scaled 1) (AffineLift.value (mask4 w 1))
        (FlushToZero.mul (scaled 0) (AffineLift.value (mask4 w 0))))))

theorem execution4 (contracted : Bool) (w : BitVec 16) (scaled : Fin 4 → Float32) (acc : Float32) :
    Arithmetic.evaluate (bind4 w scaled acc) (expression4 contracted) = source4 contracted w scaled acc := by
  simp [expression4, Arithmetic.evaluate, evaluate_madd, bind4, source4]

theorem ideal4 (contracted : Bool) (w : BitVec 16) (x : Fin 4 → ℝ) (acc : ℝ) :
    Arithmetic.ideal (target4 w x acc) (expression4 contracted) = acc + ∑ i, x i * AffinePacking.field4 w i := by
  rw [← AffinePacking.qdot4_correct]
  simp [expression4, Arithmetic.ideal, ideal_madd, target4, AffinePacking.qdot4, mask4]
  ring

theorem bind4_error (w : BitVec 16) (scaled : Fin 4 → Float32) (acc : Float32)
    (target scaledError : Fin 4 → ℝ) (targetAcc accError : ℝ)
    (hx : ∀ i, |real (scaled i) - target i / 2^(4*i.val)| ≤ scaledError i)
    (ha : |real acc - targetAcc| ≤ accError) (i : Nat) :
    |real (bind4 w scaled acc i) - target4 w target targetAcc i| ≤ errors4 scaledError accError i := by
  unfold bind4 target4 errors4
  split
  · exact hx _
  · split
    · simp only [mask4_exact, sub_self, abs_zero, le_refl]
    · exact ha

theorem error4 (contracted : Bool) (w : BitVec 16) (scaled : Fin 4 → Float32) (acc : Float32)
    (target scaledError : Fin 4 → ℝ) (targetAcc accError : ℝ)
    (hx : ∀ i, |real (scaled i) - target i / 2^(4*i.val)| ≤ scaledError i)
    (ha : |real acc - targetAcc| ≤ accError)
    (hf : Arithmetic.Finite (bind4 w scaled acc) (expression4 contracted)) :
    |real (source4 contracted w scaled acc) - (targetAcc + ∑ i, target i * AffinePacking.field4 w i)| ≤
      Arithmetic.budget (bind4 w scaled acc) (target4 w target targetAcc) (errors4 scaledError accError) (expression4 contracted) := by
  have h := Arithmetic.error _ _ _ (bind4_error w scaled acc target scaledError targetAcc accError hx ha) (expression4 contracted) hf
  rwa [execution4, ideal4] at h

end Inference.Kernels.Quantization.AffineDot
