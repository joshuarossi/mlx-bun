import host.ts.Builtins
namespace Host.Ts

/-- Removing a key from a different bucket removes only an immediately false
comparison; numeric keys share a bucket, including every symbolic number. -/
theorem sameValueZero_hash_ne (F : Ffi) (s : St F.S) (a b : Val)
    (h : keyHash a ≠ keyHash b) : sameValueZero F s a b = .pure false := by
  cases a <;> cases b <;> simp_all [keyHash, sameValueZero, strictEq]
  all_goals
    apply congrArg M.pure
    apply Bool.eq_false_iff.mpr
    intro he
    simp only [nameEq, Nat.beq_eq] at he
    exact h (by rw [he])

/-- A linear insertion-order scan may discard entries in other buckets without
changing its number-server requests or result. -/
theorem findKey_filter_hash (F : Ffi) (s : St F.S) (k : Val) (es : List (Val × Nat)) :
    findKey F s k (es.filter fun p => Nat.beq (keyHash p.1) (keyHash k)) = findKey F s k es := by
  induction es with
  | nil => rfl
  | cons p es ih =>
    obtain ⟨j, n⟩ := p
    by_cases h : keyHash j = keyHash k
    · simp only [List.filter_cons, h, Nat.beq_refl, ite_true]
      simp only [findKey, ih]
    · have he : Nat.beq (keyHash j) (keyHash k) = false :=
        Bool.eq_false_iff.mpr fun ht => h (Nat.eq_of_beq_eq_true ht)
      simp only [List.filter_cons, he, Bool.false_eq_true, ite_false]
      rw [ih, findKey, sameValueZero_hash_ne F s j k h]
      rfl

/-- The index invariant needed by lookup: each bucket is the live insertion-order
key list filtered by its hash. Keeping this order also preserves symbolic tests. -/
def MapT.Indexes (m : MapT) (es : List (Val × Nat)) : Prop :=
  ∀ h, m.bucket h = es.filter fun p => Nat.beq (keyHash p.1) h

/-- Indexed lookup refines the linear scan whenever the store's index describes
its live insertion-order keys. -/
theorem MapT.find_eq_linear (F : Ffi) (s : St F.S) (m : MapT)
    (es : List (Val × Nat)) (h : m.Indexes es) (k : Val) :
    m.find F s k = findKey F s k es := by
  rw [MapT.find, h, findKey_filter_hash]

end Host.Ts
