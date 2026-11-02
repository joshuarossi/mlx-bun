import host.route.PostHandoff
import host.sim.template.HandVals
import host.sim.template.DimVals
import host.sim.compose.ValuationBounded
import host.sim.template.DecOk
import host.route.DecVal
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Ts Host.Ts.Sim
open Host.Load.Run.Tpl (handVal decVal)
open Host.Route (decVal_le decVal_range)

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

theorem handVal_le {L v k : Nat} (h : handVal L v = some k) : k ≤ 8 + L := by
  unfold handVal at h
  cases hL : Nat.ble L 2 <;> rw [hL] at h <;> dsimp only [cond] at h <;> split at h <;>
    first
      | (obtain rfl := Option.some.inj h; omega)
      | cases h

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

theorem handRho_pin {T L q k : Nat} {tk : Nat → Nat} (h : decVal q = some k) : handRho T L tk q = F64.ofNat k := by
  unfold handRho
  rw [h]

/-- **The loop's valuation at `handRho` is a decode chain's.** -/
theorem handRho_vp {T L : Nat} {tk : Nat → Nat} (hL : L ≤ 224) (hv : ∀ j, tk j ≤ 2 ^ 20) (hctx : L + T ≤ 262144)
    (htv : ∀ j, j ≤ T → tk j ≤ 248319) (i nx : Nat) (hi : i + 2 < T) (hnx : nx ≤ 2 ^ 20) :
    Host.Load.Run.Tpl.DecOk.VP (valL (handRho T L tk) T tk L i nx) :=
  ⟨Host.Ts.Sim.Compose.valL_vb_supported (handRho_small hL (by omega) hv) hctx htv i nx hi hnx, fun v k hk => by
    have hr := decVal_range hk
    unfold valL
    rw [loopVal_rest v (by omega) (.inr (by omega))]
    exact handRho_pin hk⟩

end Host.Route.PrefGraph
