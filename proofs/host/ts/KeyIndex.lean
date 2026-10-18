import host.ts.StoreLaws

namespace Host.Ts.KeyIndex

/-- Hash collisions retain full codes and first-match order in their bucket. -/
abbrev Index (α : Type) := Trie (List (Nat × α))
variable {α : Type}

def bucket (t : Index α) (code : Nat) : List (Nat × α) :=
  (t.get (code % 16381)).getD []

def add (t : Index α) (code : Nat) (value : α) : Index α :=
  t.set (code % 16381) ((code, value) :: bucket t code)

def inBucketImpl (code : Nat) : List (Nat × α) → Option α
  | [] => none
  | (c, i) :: es => bif Nat.beq c code then some i else inBucketImpl code es

@[implemented_by inBucketImpl]
def inBucket (code : Nat) (es : List (Nat × α)) : Option α :=
  List.rec (motive := fun _ => Nat → Option α) (fun _ => none)
    (fun p _ ih q => Prod.rec (fun c i => brec (Nat.beq c q) (some i) (ih q)) p) es code

def lookup (t : Index α) (code : Nat) : Option α := inBucket code (bucket t code)

theorem lookup_nil (code : Nat) : lookup (.nil : Index α) code = none := rfl

theorem bucket_bound (code : Nat) : code % 16381 < 4 ^ 31 := by
  have := Nat.mod_lt code (by decide : 0 < 16381)
  omega

theorem lookup_add (t : Index α) (code : Nat) (value : α) (query : Nat) :
    lookup (add t code value) query = if code = query then some value else lookup t query := by
  unfold lookup bucket add
  rw [Trie.get_set _ _ _ (bucket_bound code)]
  by_cases h : query % 16381 = code % 16381
  · simp only [h, ite_true, Option.getD_some, inBucket]
    by_cases hc : code = query
    · simp [hc, bucket, brec]
    · have hb : Nat.beq code query = false := by
        cases he : Nat.beq code query
        · rfl
        · exact False.elim (hc (Nat.eq_of_beq_eq_true he))
      simp [hb, hc, bucket, brec]
  · have hc : code ≠ query := by intro he; subst query; exact h rfl
    simp [h, hc]

def largeImpl : List α → Nat → Bool
  | [], _ => false
  | _ :: _, 0 => true
  | _ :: xs, n + 1 => largeImpl xs n

/-- Keep the original path on lists with at most sixteen entries. -/
@[implemented_by largeImpl]
def large (xs : List α) : Nat → Bool :=
  List.rec (motive := fun _ => Nat → Bool) (fun _ => false)
    (fun _ _ ih n => Nat.rec true (fun k _ => ih k) n) xs

end Host.Ts.KeyIndex
