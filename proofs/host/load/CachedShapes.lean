import host.mlx.FfiEval
import host.load.Extract

namespace Host.Load.CachedShapes
open Host.Mlx Host.Mlx.FfiEval
set_option Elab.async false

/-- A bounded structural certificate for a capacity buffer. Updates preserve
the base buffer's metadata; their newly computed rows need no shape premise. -/
def check (G : Nat → Option (RNode Int InKey)) (dtype : Dtype) (shape : List Nat) : Nat → Nat → Bool
  | 0, _ => false
  | fuel + 1, i => match G i with
    | some ⟨.zeros dims dt, []⟩ => dims == shape.map Int.ofNat && dt == dtype.code
    | some ⟨.sliceUpdate _ _ _, [base, row]⟩ =>
      decide (base < i ∧ row < i) && check G dtype shape fuel base
    | _ => false

theorem slice_update_metadata (base row out : Value) (start stop : List Nat)
    (h : sliceUpdateRange base row start stop = some out) :
    out.dtype = base.dtype ∧ out.shape = base.shape := by
  unfold sliceUpdateRange at h
  split at h
  · unfold sliceUpdate at h
    split at h
    · cases h
      exact ⟨rfl, rfl⟩
    · cases h
  · cases h

private theorem natShape_ofNat (shape : List Nat) : natShape (shape.map Int.ofNat) = some shape := by
  induction shape with
  | nil => rfl
  | cons a rest shapeIH =>
    change natShape ((a : Int) :: rest.map Int.ofNat) = some (a :: rest)
    rw [natShape, ite_eq_left (Int.natCast_nonneg a), shapeIH]
    simp

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env InKey)

theorem update_metadata (base row out : Value) (start stop stride : List Int)
    (h : primEval M K env (.sliceUpdate start stop stride) [base, row] = some out) :
    out.dtype = base.dtype ∧ out.shape = base.shape := by
  simp only [primEval] at h
  split at h
  · cases hs : natShape start with
    | none => simp [hs] at h
    | some st =>
      cases hp : natShape stop with
      | none => simp [hs, hp] at h
      | some sp =>
        exact slice_update_metadata base row out st sp (by simpa [hs, hp] using h)
  · cases h

/-- The certificate proves metadata of every successfully evaluated result;
it never supplies a cache tensor as an external numerical assumption. -/
theorem sound (G : Nat → Option (RNode Int InKey)) (dtype : Dtype) (shape : List Nat)
    (fuel i : Nat) (checked : check G dtype shape fuel i = true) (out : Value)
    (evaluated : evalR M K env G i = some out) :
    out.dtype = dtype ∧ out.shape = shape := by
  induction fuel generalizing i out with
  | zero => simp [check] at checked
  | succ fuel ih =>
    cases hn : G i with
    | none => simp [check, hn] at checked
    | some nd =>
      cases nd with
      | mk prim ins =>
        cases prim <;> try { simp [check, hn] at checked }
        case zeros dims dt =>
          cases ins with
          | cons a rest => simp [check, hn] at checked
          | nil =>
            simp only [check, hn, Bool.and_eq_true, beq_iff_eq] at checked
            obtain ⟨rfl, rfl⟩ := checked
            rw [evalR_eq, hn, cgLeaves_none G i _ hn rfl] at evaluated
            have hs := natShape_ofNat shape
            simp only [List.mapM_nil, Option.bind_some, primEval, hs,
              Dtype.ofCode_code, Option.pure_def] at evaluated
            cases evaluated
            exact ⟨rfl, rfl⟩
        case sliceUpdate start stop stride =>
          cases ins with
          | nil => simp [check, hn] at checked
          | cons base rest =>
            cases rest with
            | nil => simp [check, hn] at checked
            | cons row tail =>
              cases tail with
              | cons a rest => simp [check, hn] at checked
              | nil =>
                simp only [check, hn, Bool.and_eq_true, decide_eq_true_eq] at checked
                obtain ⟨⟨hb, hr⟩, previous⟩ := checked
                rw [evalR_eq, hn, cgLeaves_none G i _ hn rfl] at evaluated
                cases bv : evalR M K env G base with
                | none => simp [List.mapM_cons, hb, bv] at evaluated
                | some b =>
                  cases rv : evalR M K env G row with
                  | none => simp [List.mapM_cons, hb, hr, bv, rv] at evaluated
                  | some r =>
                    have hp : primEval M K env (.sliceUpdate start stop stride) [b, r] = some out := by
                      simpa [List.mapM_cons, hb, hr, bv, rv] using evaluated
                    have same := update_metadata M K env b r out start stop stride hp
                    have old := ih base previous b bv
                    exact ⟨same.1.trans old.1, same.2.trans old.2⟩

def checkCaches (G : Nat → Option (RNode Int InKey)) (dtype : Dtype) (shape : List Nat)
    (fuel : Nat) (caches : List Extract.Cache) : Bool :=
  caches.all fun c => if c.operation = chars!"KVCache" then
    (c.first.toList ++ c.second.toList).all (fun t => check G dtype shape fuel t.node) else true

theorem caches_sound (G : Nat → Option (RNode Int InKey)) (dtype : Dtype) (shape : List Nat)
    (fuel : Nat) (caches : List Extract.Cache)
    (checked : checkCaches G dtype shape fuel caches = true) :
    ∀ c ∈ caches, c.operation = chars!"KVCache" →
      ∀ t, c.first = some t ∨ c.second = some t →
      ∀ v, evalR M K env G t.node = some v → v.dtype = dtype ∧ v.shape = shape := by
  intro c hc operation t ht v hv
  have heads := List.all_eq_true.mp checked c hc
  simp only [operation, ↓reduceIte] at heads
  have member : t ∈ c.first.toList ++ c.second.toList := by
    cases ht with
    | inl h => simp [h]
    | inr h => simp [h]
  exact sound M K env G dtype shape fuel t.node (List.all_eq_true.mp heads t member) v hv

end Host.Load.CachedShapes
