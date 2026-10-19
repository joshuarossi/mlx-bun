import host.ts.Core

set_option Elab.async false
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned

theorem nameEq_true_iff (a b : Name) : nameEq a b = true ↔ pack a = pack b := by
  unfold nameEq
  exact (beq_iff_eq : ((pack a == pack b) = true ↔ pack a = pack b))

theorem nameEq_comm (a b : Name) : nameEq a b = nameEq b a := by
  refine Bool.eq_iff_iff.mpr ?_
  simp only [nameEq_true_iff]
  exact Eq.comm

theorem nameEq_trans {a b c : Name} (hab : nameEq a b = true) (hbc : nameEq b c = true) :
    nameEq a c = true := by
  exact (nameEq_true_iff a c).mpr (((nameEq_true_iff a b).mp hab).trans ((nameEq_true_iff b c).mp hbc))

theorem privEq_name_ne {queryBrand writtenBrand : Nat} {queryName writtenName : Name} {key : Nat × Name}
    (different : nameEq queryName writtenName = false) (written : privEq writtenBrand writtenName key = true) :
    privEq queryBrand queryName key = false := by
  rcases key with ⟨brand, name⟩
  simp only [privEq,Bool.and_eq_true] at written
  obtain ⟨_, writtenEq⟩ := written
  cases queryMatch : privEq queryBrand queryName (brand, name)
  · rfl
  · simp only [privEq,Bool.and_eq_true] at queryMatch
    obtain ⟨_, queryNameEq⟩ := queryMatch
    have same := nameEq_trans queryNameEq (nameEq_comm writtenName name ▸ writtenEq)
    rw [different] at same
    cases same

theorem findPriv_set_name_ne (queryBrand writtenBrand : Nat) (queryName writtenName : Name) (value : PropV)
    (xs : List ((Nat × Name) × PropV)) (different : nameEq queryName writtenName = false) :
    findPriv queryBrand queryName (setPrivL writtenBrand writtenName value xs) =
      findPriv queryBrand queryName xs := by
  induction xs with
  | nil => simp only [setPrivL,findPriv,privEq,different,Bool.and_false,Bool.cond_false]
  | cons entry rest ih =>
    obtain ⟨j, stored⟩ := entry
    cases written : privEq writtenBrand writtenName j
    · rw [setPrivL,written,Bool.cond_false]
      cases query : privEq queryBrand queryName j
      · simp only [findPriv,query,Bool.cond_false,ih]
      · simp only [findPriv,query,Bool.cond_true]
    · have query : privEq queryBrand queryName j = false := privEq_name_ne different written
      simp only [setPrivL,findPriv,written,query,Bool.cond_true,Bool.cond_false]

end Host.Ts.Owned
