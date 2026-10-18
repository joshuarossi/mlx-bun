import host.ts.RenameHeap
namespace Host.Ts

/-- Retain a chosen map on old resources and pair every future allocation by its
offset from the two fresh counters. -/
def freshMap (base target : Nat) (old : Nat → Nat) (a : Nat) : Nat :=
  if a < base then old a else target + (a - base)

theorem freshMap_old (base target : Nat) (old : Nat → Nat) (a : Nat) (ha : a < base) :
    freshMap base target old a = old a := by simp only [freshMap, ha, ite_true]

theorem freshMap_fresh (base target : Nat) (old : Nat → Nat) (k : Nat) :
    freshMap base target old (base + k) = target + k := by
  simp only [freshMap, Nat.add_sub_cancel_left]
  have hn : ¬ base + k < base := by omega
  rw [ite_eq_right hn]

theorem freshMap_injective (base target : Nat) (old : Nat → Nat)
    (hb : ∀ a, a < base → old a < target)
    (hi : ∀ a b, a < base → b < base → old a = old b → a = b) :
    Function.Injective (freshMap base target old) := by
  intro a b he
  by_cases ha : a < base <;> by_cases hb' : b < base
  · exact hi a b ha hb' (by simpa only [freshMap, ha, hb', ite_true] using he)
  · have ho := hb a ha
    simp only [freshMap, ha, hb', ite_true, ite_false] at he
    omega
  · have ho := hb b hb'
    simp only [freshMap, ha, hb', ite_true, ite_false] at he
    omega
  · simp only [freshMap, ha, hb', ite_false] at he
    omega

theorem freshMap_zero (base target : Nat) (old : Nat → Nat) (hb : 0 < base) (hz : old 0 = 0) :
    freshMap base target old 0 = 0 := by rw [freshMap_old _ _ _ _ hb, hz]

/-- Every earlier input remains earlier than a newly appended node. Old inputs
need only lie below the target fresh counter; fresh inputs preserve their offset
order. No ordering assumption on opaque old boundary roots is needed. -/
theorem freshMap_edge_to_fresh (base target : Nat) (old : Nat → Nat)
    (hb : ∀ a, a < base → old a < target) (i j : Nat) (hi : base ≤ i) (hj : j < i) :
    freshMap base target old j < freshMap base target old i := by
  have hin : ¬ i < base := by omega
  by_cases hjo : j < base
  · have ho := hb j hjo
    simp only [freshMap, hjo, hin, ite_true, ite_false]
    omega
  · simp only [freshMap, hjo, hin, ite_false]
    omega

theorem freshMap_strictMono (base target : Nat) (old : Nat → Nat)
    (hb : ∀ a, a < base → old a < target)
    (ho : ∀ a b, a < b → b < base → old a < old b) :
    ∀ a b, a < b → freshMap base target old a < freshMap base target old b := by
  intro a b hab
  by_cases hbo : b < base
  · have hao : a < base := by omega
    rw [freshMap_old _ _ _ _ hao, freshMap_old _ _ _ _ hbo]
    exact ho a b hab hbo
  · exact freshMap_edge_to_fresh base target old hb b a (by omega) hab

/-- Negative ordinary integers retain their value. Nonnegative native handles
use the same fresh-tail map as their native storage keys. Ordinary nonnegative
bigints must be explicitly fixed by the old-resource map. -/
def freshBig (base target : Nat) (old : Nat → Nat) (i : Int) : Int :=
  if i < 0 then i else Int.ofNat (freshMap base target old i.toNat)

theorem freshBig_ofNat (base target : Nat) (old : Nat → Nat) (a : Nat) :
    freshBig base target old (Int.ofNat a) = Int.ofNat (freshMap base target old a) := by
  have hn : ¬ (a : Int) < 0 := by omega
  simp only [freshBig, Int.ofNat_eq_natCast, hn, ite_false, Int.toNat_natCast]

theorem freshBig_fresh (base target : Nat) (old : Nat → Nat) (k : Nat) :
    freshBig base target old (Int.ofNat (base + k)) = Int.ofNat (target + k) := by
  rw [freshBig_ofNat, freshMap_fresh]

theorem freshBig_handle (base target : Nat) (old : Nat → Nat) (a : Nat) :
    (freshBig base target old (Int.ofNat a)).toNat = freshMap base target old a := by
  rw [freshBig_ofNat]
  rfl

theorem freshBig_fixed_negative (base target : Nat) (old : Nat → Nat) (i : Int) (hi : i < 0) :
    freshBig base target old i = i := by simp only [freshBig, hi, ite_true]

theorem freshBig_fixed_old (base target : Nat) (old : Nat → Nat) (a : Nat)
    (ha : a < base) (hf : old a = a) :
    freshBig base target old (Int.ofNat a) = Int.ofNat a := by
  rw [freshBig_ofNat, freshMap_old _ _ _ _ ha, hf]

theorem freshBig_zero (base target : Nat) (old : Nat → Nat) (hb : 0 < base) (hz : old 0 = 0) :
    freshBig base target old 0 = 0 := by
  exact freshBig_fixed_old base target old 0 hb hz

/-- An unbounded affine fresh-handle map cannot also fix an ordinary bigint at
or above its fresh source counter, unless the two counters are equal. Packed
optional integers make this an actual interface restriction, so a full source
simulation must distinguish ordinary integer values from owned handles. -/
theorem unbounded_bigFresh_fixed (big : Int → Int) (base target ordinary : Nat)
    (hb : base ≤ ordinary)
    (hf : ∀ k, big (Int.ofNat (base + k)) = Int.ofNat (target + k))
    (ho : big (Int.ofNat ordinary) = Int.ofNat ordinary) : target = base := by
  have h := hf (ordinary - base)
  have he : base + (ordinary - base) = ordinary := by omega
  rw [he, ho] at h
  have hi := Int.ofNat.inj h
  omega

/-- Evaluation of an actual bigint literal commutes exactly when that ordinary
literal is fixed. Freshness alone is insufficient; this is the explicit side
condition absent from a false unrestricted bigint-renaming theorem. -/
theorem step_bigLiteral_live (F : Ffi) (R : Ren) (live framed : Nat → Prop) (before after : List Val)
    (s s' : St F.S) (raw : Name) (i : Nat) (env : Env)
    (h : LiveHeap R live framed before after s s')
    (hc : s.ctl = .ev (.lit (.big raw)) env) (hc' : s'.ctl = .ev (.lit (.big raw)) (R.env env))
    (hp : F64.parseIntLit raw = some i) (hi : R.big (Int.ofNat i) = Int.ofNat i) :
    step F s = M.pure (s.ret (.big (Int.ofNat i))) ∧ step F s' = M.pure (s'.ret (.big (Int.ofNat i))) ∧
      LiveHeap R live framed before after (s.ret (.big (Int.ofNat i))) (s'.ret (.big (Int.ofNat i))) ∧
      (s'.ret (.big (Int.ofNat i))).ctl = R.ctl (s.ret (.big (Int.ofNat i))).ctl := by
  refine ⟨?_, ?_, h.control _ _, ?_⟩
  · simp only [step, hc, evStep, evLit, hp, retS, Int.ofNat_eq_natCast]
  · simp only [step, hc', evStep, evLit, hp, retS, Int.ofNat_eq_natCast]
  · change Ctl.ret (.big (Int.ofNat i)) = .ret (.big (R.big (Int.ofNat i)))
    rw [hi]

end Host.Ts
