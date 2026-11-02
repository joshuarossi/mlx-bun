import host.sim.template.DimVals
set_option autoImplicit false
namespace Host.Route
open Host.Load.Run.Tpl (decVal)

/-! # The abstracted dims' values, as bounds -/

theorem decVal_le {j k : Nat} (h : decVal j = some k) : k ≤ 1536 := by
  unfold decVal at h
  cases h1 : Nat.ble 114 j && Nat.ble j 161
  · rw [h1] at h
    cases h2 : Nat.ble 102 j && Nat.ble j 108
    · rw [h2] at h
      cases h3 : Nat.beq j 109
      · rw [h3] at h
        cases h
      · rw [h3] at h
        obtain rfl := Option.some.inj h
        omega
    · rw [h2] at h
      obtain rfl := Option.some.inj h
      omega
  · rw [h1] at h
    obtain rfl := Option.some.inj h
    omega

theorem decVal_range {q k : Nat} (h : decVal q = some k) : 102 ≤ q ∧ q ≤ 161 := by
  unfold decVal at h
  cases h1 : Nat.ble 114 q && Nat.ble q 161
  · rw [h1] at h
    cases h2 : Nat.ble 102 q && Nat.ble q 108
    · rw [h2] at h
      cases h3 : Nat.beq q 109
      · rw [h3] at h
        cases h
      · have := Nat.eq_of_beq_eq_true h3
        omega
    · simp only [Bool.and_eq_true, Nat.ble_eq] at h2
      omega
  · simp only [Bool.and_eq_true, Nat.ble_eq] at h1
    omega

end Host.Route
