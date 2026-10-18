import host.ts.Core
import host.ts.KeyIndex

namespace Host.Ts.StringIndex

open KeyIndex

def firstCode (code : Nat) : List (Val × Val) → Nat → Option Nat
  | [], _ => none
  | (.str cs, _) :: es, i => bif Nat.beq (pack cs) code then some i else firstCode code es (i + 1)
  | _ :: es, i => firstCode code es (i + 1)

def buildValuesImpl : List (Val × Val) → Index Val
  | [] => .nil
  | (.str cs, v) :: es => add (buildValuesImpl es) (pack cs) v
  | _ :: es => buildValuesImpl es

/-- Rebuilding from the exact entry list does not alter its order or contents.
The tail is indexed first, so prepending preserves the earliest duplicate. -/
@[implemented_by buildValuesImpl]
def buildValues (es : List (Val × Val)) : Index Val :=
  List.rec (motive := fun _ => Index Val) .nil
    (fun p _ ih => match p.1 with | .str cs => add ih (pack cs) p.2 | _ => ih) es

def firstValue (code : Nat) : List (Val × Val) → Option Val
  | [] => none
  | (.str cs, v) :: es => bif Nat.beq (pack cs) code then some v else firstValue code es
  | _ :: es => firstValue code es

theorem buildValues_cons (p : Val × Val) (es : List (Val × Val)) :
    buildValues (p :: es) =
      match p.1 with | .str cs => add (buildValues es) (pack cs) p.2 | _ => buildValues es := rfl

theorem lookup_buildValues (es : List (Val × Val)) (code : Nat) :
    lookup (buildValues es) code = firstValue code es := by
  induction es with
  | nil => rfl
  | cons p es ih =>
    rcases p with ⟨k, v⟩
    rw [buildValues_cons]
    cases k <;> simp only [firstValue, ih]
    rename_i cs
    rw [lookup_add, ih]
    by_cases h : pack cs = code <;> simp [h]

theorem firstCode_succ (es : List (Val × Val)) (i code : Nat) :
    firstCode code es (i + 1) = (firstCode code es i).map Nat.succ := by
  induction es generalizing i with
  | nil => rfl
  | cons p es ih =>
    rcases p with ⟨k, v⟩
    cases k <;> simp only [firstCode, ih]
    rename_i cs
    cases Nat.beq (pack cs) code <;> simp

theorem firstCode_value (es : List (Val × Val)) (code : Nat) :
    ((firstCode code es 0).bind fun i => (nth? es i).map Prod.snd) = firstValue code es := by
  induction es with
  | nil => rfl
  | cons p es ih =>
    rcases p with ⟨k, v⟩
    cases k <;> simp only [firstCode, firstValue, firstCode_succ]
    all_goals try (cases h : firstCode code es 0 <;> simpa [h, nth?] using ih)
    rename_i cs
    cases Nat.beq (pack cs) code
    · cases h : firstCode code es 0 <;> simpa [h, nth?] using ih
    · rfl

end Host.Ts.StringIndex
