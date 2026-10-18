import host.ts.Builtins
import host.ts.StringIndex

namespace Host.Ts

section
variable (F : Ffi) (s : St F.S)

/-- With a string query every original comparison is pure, including the
comparisons skipped by the derived index. Numeric symbolic requests are absent. -/
theorem findEntry_string (cs : List Char) (es : List (Val × Val)) (i : Nat) :
    findEntry F s (.str cs) es i = M.pure (StringIndex.firstCode (pack cs) es i) := by
  induction es generalizing i with
  | nil => rfl
  | cons p es ih =>
    rcases p with ⟨k, v⟩
    cases k <;> simp only [findEntry, findEntry.sameValueZero, strictEq,
      StringIndex.firstCode, ih]
    all_goals try rfl
    rename_i ds
    unfold nameEq M.bind M.pure
    cases Nat.beq (pack ds) (pack cs) <;> rfl

theorem stringLookupValue_eq (cs : List Char) (es : List (Val × Val)) :
    M.pure ((KeyIndex.lookup (StringIndex.buildValues es) (pack cs)).getD .undef) =
      M.bind (findEntry F s (.str cs) es 0) (fun
        | some i => M.pure ((nth? es i).elim .undef Prod.snd)
        | none => M.pure .undef) := by
  rw [findEntry_string, StringIndex.lookup_buildValues, ← StringIndex.firstCode_value]
  generalize StringIndex.firstCode (pack cs) es 0 = r
  cases r with
  | none => rfl
  | some i =>
    change M.pure (((nth? es i).map Prod.snd).getD .undef) =
      M.pure ((nth? es i).elim .undef Prod.snd)
    cases nth? es i <;> rfl

/-- Equality of the complete request computation, for arbitrary original
entry lists. In particular it holds after set, delete, clear, or construction. -/
theorem mapEntryValue_eq_linear (k : Val) (es : List (Val × Val)) :
    mapEntryValue F s k es = mapEntryValueLinear F s k es := by
  cases k <;> try rfl
  rename_i cs
  unfold mapEntryValue
  cases KeyIndex.large es 16
  · rfl
  · exact stringLookupValue_eq F s cs es

theorem mapN_get_eq_linear (this : Val) (args : List Val) :
    mapN F s this args .get =
      match mapOf F s this with
      | some (_, _, es) => M.bind (findEntry F s (arg args 0) es 0) (fun
          | some i => retS F s ((nth? es i).elim .undef Prod.snd)
          | none => retS F s .undef)
      | none => typeErr s chars!"Map method on a non-Map" := by
  simp only [mapN, mapN.withMap]
  cases h : mapOf F s this with
  | none => rfl
  | some p =>
    rcases p with ⟨a, o, es⟩
    dsimp only
    rw [mapEntryValue_eq_linear]
    funext β k
    unfold mapEntryValueLinear M.bind
    congr 1
    funext r
    cases r <;> rfl

end
end Host.Ts
