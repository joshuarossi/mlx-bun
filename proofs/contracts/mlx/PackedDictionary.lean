import contracts.mlx.TensorWords

namespace Inference.Contracts.Mlx.PackedDictionary
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- A chunk stores finite dictionary indices as base-cardinality digits.
-- Decoding yields a bounded index for every literal chunk; no unchecked
-- index or numerical acceptance result comes from the host generator.
def encode (base : Nat) : List (Fin base) → Nat
  | [] => 0
  | head::tail => head.val+base*encode base tail
def digit (base chunk position : Nat) : Nat := chunk/base^position%base

theorem digit_zero (_positive : 0 < base) (head : Fin base) (tail : Nat) :
    digit base (head.val+base*tail) 0 = head.val := by
  simp only [digit, pow_zero, Nat.div_one, Nat.add_mod, Nat.mul_mod_right, Nat.add_zero,
    Nat.mod_eq_of_lt head.isLt]

theorem digit_succ (positive : 0 < base) (head : Fin base) (tail position : Nat) :
    digit base (head.val+base*tail) (position+1) = digit base tail position := by
  unfold digit
  rw [pow_succ', ← Nat.div_div_eq_div_mul, Nat.add_mul_div_left _ _ positive,
    Nat.div_eq_of_lt head.isLt, Nat.zero_add]

theorem decode_encode (positive : 0 < base) (indices : List (Fin base)) (position : Nat)
    (inside : position < indices.length) : digit base (encode base indices) position = indices[position].val := by
  induction indices generalizing position with
  | nil => simp only [List.length_nil] at inside; omega
  | cons head tail ih =>
    cases position with
    | zero => exact digit_zero positive head (encode base tail)
    | succ position =>
      rw [encode, digit_succ positive]
      exact ih position (by simpa only [List.length_cons, Nat.succ_lt_succ_iff] using inside)

def index (dictionary : List (Model fmt)) (positive : 0 < dictionary.length) (chunk position : Nat) : Fin dictionary.length :=
  ⟨digit dictionary.length chunk position, Nat.mod_lt _ positive⟩
def read (dictionary : List (Model fmt)) (positive : 0 < dictionary.length) (chunk position : Nat) : Model fmt :=
  dictionary[index dictionary positive chunk position]

theorem read_bound (dictionary : List (Model fmt)) (positive : 0 < dictionary.length) (cap : Model fmt)
    (checked : TensorWords.check dictionary cap = true) (chunk position : Nat) :
    Model.isFinite (read dictionary positive chunk position) = true ∧
      |Model.toReal (read dictionary positive chunk position)| ≤ Model.toReal cap :=
  TensorWords.check_sound dictionary cap checked (index dictionary positive chunk position)

theorem read_encode (dictionary : List (Model fmt)) (positive : 0 < dictionary.length)
    (indices : List (Fin dictionary.length)) (position : Nat) (inside : position < indices.length) :
    read dictionary positive (encode dictionary.length indices) position = dictionary[indices[position]] := by
  have same : index dictionary positive (encode dictionary.length indices) position = indices[position] :=
    Fin.ext (decode_encode positive indices position inside)
  exact congrArg (fun i : Fin dictionary.length => dictionary[i]) same

end Inference.Contracts.Mlx.PackedDictionary
