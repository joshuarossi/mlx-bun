import host.route.PostHandoff
import host.sim.template.HandVals
import host.sim.template.DimVals
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Ts Host.Ts.Sim
open Host.Load.Run.Tpl (handVal decVal)

/-! # The decode template's valuation

`handRho`: what the loop's valuation holds off its own variables: the abstracted dims, the compile bookkeeping at POST's end, the tokens. -/

/-- The valuation off the loop's variables. `traceCalls` is `v21` in the template, `v200` at POST's end. -/
def handRho (T L : Nat) (tk : Nat → Nat) : Nat → F64 := fun j =>
  match decVal j with
  | some k => F64.ofNat k
  | none =>
    match handVal L (bif Nat.beq j 21 then 200 else j) with
    | some k => F64.ofNat k
    | none => machVal T tk j

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

theorem handVal_le {L v k : Nat} (h : handVal L v = some k) : k ≤ max 8 L := by
  unfold handVal at h
  cases hL : Nat.ble L 2 <;> rw [hL] at h <;> dsimp only [cond] at h <;> split at h <;>
    first
      | cases h
      | (obtain rfl := Option.some.inj h; omega)

/-- The valuation's values are small. -/
theorem handRho_small {T L : Nat} {tk : Nat → Nat} (hL : L ≤ 224) (hT : T ≤ 2 ^ 20) (hv : ∀ j, tk j ≤ 2 ^ 20) :
    ∀ j, ∃ n ≤ 2 ^ 20, handRho T L tk j = F64.ofNat n := by
  intro j
  unfold handRho
  cases hd : decVal j with
  | some k => exact ⟨k, by have := decVal_le hd; omega, rfl⟩
  | none =>
    dsimp only
    cases hh : handVal L (bif Nat.beq j 21 then 200 else j) with
    | some k => exact ⟨k, by have := handVal_le hh; omega, rfl⟩
    | none =>
      dsimp only
      by_cases hj : j = 0
      · exact ⟨T, hT, by simp [machVal, hj]⟩
      · exact ⟨tk j, hv j, by simp [machVal, hj]⟩

end Host.Route.PrefGraph
