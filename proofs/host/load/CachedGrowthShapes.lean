import host.load.CachedShapes

namespace Host.Load.CachedGrowthShapes
open Host.Mlx Host.Mlx.FfiEval
set_option Elab.async false

/-- Extend the existing capacity certificate with the repository's aligned
growth: append 256 zero rows, then preserve the result through updates. -/
def check (G : Nat → Option (RNode Int InKey)) (dtype : Dtype) (capacity : Nat) : Nat → Nat → Bool
  | 0, _ => false
  | fuel + 1, i =>
    if CachedShapes.check G dtype [1,4,capacity,256] (fuel+1) i then true
    else match G i with
      | some ⟨.sliceUpdate _ _ _, [base, row]⟩ =>
        decide (base < i ∧ row < i) && check G dtype capacity fuel base
      | some ⟨.concat 2, [base, extra]⟩ =>
        decide (256 ≤ capacity ∧ base < i ∧ extra < i) &&
          check G dtype (capacity-256) fuel base &&
          CachedShapes.check G dtype [1,4,256,256] fuel extra
      | _ => false

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env InKey)

/-- Capacity is derived from the operations in the actual producing graph,
including positive-capacity growth. No cache payload is assumed here. -/
theorem sound (G : Nat → Option (RNode Int InKey)) (dtype : Dtype) (capacity fuel i : Nat)
    (checked : check G dtype capacity fuel i = true) (out : Value)
    (evaluated : evalR M K env G i = some out) :
    out.dtype = dtype ∧ out.shape = [1,4,capacity,256] := by
  induction fuel generalizing capacity i out with
  | zero => simp [check] at checked
  | succ fuel ih =>
    by_cases old : CachedShapes.check G dtype [1,4,capacity,256] (fuel+1) i = true
    · exact CachedShapes.sound M K env G dtype _ (fuel+1) i old out evaluated
    · have oldFalse : CachedShapes.check G dtype [1,4,capacity,256] (fuel+1) i = false :=
        Bool.eq_false_iff.mpr old
      simp only [check, oldFalse, Bool.false_eq_true, ↓reduceIte] at checked
      cases hn : G i with
      | none => simp [hn] at checked
      | some nd =>
        cases nd with
        | mk prim ins =>
          cases prim <;> try { simp [hn] at checked }
          case sliceUpdate start stop stride =>
            cases ins with
            | nil => simp [hn] at checked
            | cons base rest =>
              cases rest with
              | nil => simp [hn] at checked
              | cons row tail =>
                cases tail with
                | cons a rest => simp [hn] at checked
                | nil =>
                  simp only [hn, Bool.and_eq_true, decide_eq_true_eq] at checked
                  obtain ⟨⟨hb, hr⟩, previous⟩ := checked
                  rw [evalR_eq, hn, cgLeaves_none G i _ hn rfl] at evaluated
                  cases bv : evalR M K env G base with
                  | none => simp [List.mapM_cons, hb, bv] at evaluated
                  | some b =>
                    cases rv : evalR M K env G row with
                    | none => simp [List.mapM_cons, hb, hr, bv, rv] at evaluated
                    | some r =>
                      have hp : primEval M K env (.sliceUpdate start stop stride) [b,r] = some out := by
                        simpa [List.mapM_cons, hb, hr, bv, rv] using evaluated
                      have same := CachedShapes.update_metadata M K env b r out start stop stride hp
                      have base := ih capacity base previous b bv
                      exact ⟨same.1.trans base.1, same.2.trans base.2⟩
          case concat axis =>
            cases axis with
            | zero => simp [hn] at checked
            | succ axis =>
              cases axis with
              | zero => simp [hn] at checked
              | succ axis =>
                cases axis with
                | succ axis => simp [hn] at checked
                | zero =>
                  cases ins with
                  | nil => simp [hn] at checked
                  | cons base rest =>
                    cases rest with
                    | nil => simp [hn] at checked
                    | cons extra tail =>
                      cases tail with
                      | cons a rest => simp [hn] at checked
                      | nil =>
                        simp only [hn, Bool.and_eq_true, decide_eq_true_eq] at checked
                        obtain ⟨⟨⟨hc, hb, hx⟩, previous⟩, added⟩ := checked
                        rw [evalR_eq, hn, cgLeaves_none G i _ hn rfl] at evaluated
                        cases bv : evalR M K env G base with
                        | none => simp [List.mapM_cons, hb, bv] at evaluated
                        | some b =>
                          cases xv : evalR M K env G extra with
                          | none => simp [List.mapM_cons, hb, hx, bv, xv] at evaluated
                          | some x =>
                            have hp : concatenate b x 2 = some out := by
                              simpa [List.mapM_cons, hb, hx, bv, xv, primEval] using evaluated
                            have base := ih (capacity-256) base previous b bv
                            have extra := CachedShapes.sound M K env G dtype _ fuel extra added x xv
                            have same := concatenate_spec b x out 2 hp
                            refine ⟨same.1.trans base.1, ?_⟩
                            rw [same.2.1, base.2, extra.2]
                            simp only [List.getD, List.getElem?_cons_succ, List.getElem?_cons_zero,
                              Option.getD_some, List.set]
                            have total : capacity - 256 + 256 = capacity := by omega
                            rw [total]

def checkCaches (G : Nat → Option (RNode Int InKey)) (dtype : Dtype) (capacity fuel : Nat)
    (caches : List Extract.Cache) : Bool :=
  caches.all fun c => if c.operation = chars!"KVCache" then
    (c.first.toList ++ c.second.toList).all (fun t => check G dtype capacity fuel t.node) else true

theorem caches_sound (G : Nat → Option (RNode Int InKey)) (dtype : Dtype) (capacity fuel : Nat)
    (caches : List Extract.Cache) (checked : checkCaches G dtype capacity fuel caches = true) :
    ∀ c ∈ caches, c.operation = chars!"KVCache" →
      ∀ t, c.first = some t ∨ c.second = some t →
      ∀ v, evalR M K env G t.node = some v → v.dtype = dtype ∧ v.shape = [1,4,capacity,256] := by
  intro c hc operation t ht v hv
  have heads := List.all_eq_true.mp checked c hc
  simp only [operation, ↓reduceIte] at heads
  have member : t ∈ c.first.toList ++ c.second.toList := by
    cases ht with
    | inl h => simp [h]
    | inr h => simp [h]
  exact sound M K env G dtype capacity fuel t.node (List.all_eq_true.mp heads t member) v hv

end Host.Load.CachedGrowthShapes
