import host.sim.CasesL
import host.sim.full.Step
import host.sim.native.DimV
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full

/-- Bounded loop inputs give a bounded valuation; no iteration outside the budget is needed. -/
theorem loopVal_vbF {ρ : Nat → F64} {T p i c tok prev nx : Nat}
    (hρ : ∀ j, ∃ k ≤ 2 ^ 20, ρ j = F64.ofNat k)
    (hT : T ≤ 2 ^ 20) (hp : p ≤ 2 ^ 20) (hi : i ≤ 2 ^ 20)
    (hc : c ≤ 2 ^ 20) (ht : tok ≤ 2 ^ 20) (hprev : prev ≤ 2 ^ 20) (hnx : nx ≤ 2 ^ 20) :
    VBOkF loopVB (loopVal ρ T p i c tok prev nx) := by
  intro v
  match v with
  | 0 => exact ⟨T, hT, rfl⟩
  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 => exact hρ _
  | 9 => exact ⟨p, hp, rfl⟩
  | 10 | 11 | 12 => exact ⟨i, hi, rfl⟩
  | 13 => exact ⟨i - 1, by show i - 1 ≤ 2 ^ 20; omega, rfl⟩
  | 14 => exact ⟨tok, ht, rfl⟩
  | 15 => exact ⟨prev, hprev, rfl⟩
  | 16 => exact ⟨c, hc, rfl⟩
  | 17 => exact ⟨nx, hnx, rfl⟩
  | j + 18 => exact hρ _

theorem valL_vb_supported {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat}
    (hρ : ∀ j, ∃ k ≤ 2 ^ 20, ρ j = F64.ofNat k)
    (hctx : L + T ≤ 262144) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (i nx : Nat) (hi : i + 2 < T) (hnx : nx ≤ 2 ^ 20) :
    VBOkF loopVB (valL ρ T tk L i nx) := by
  apply loopVal_vbF hρ
  · omega
  · omega
  · omega
  · have := capL_le (L + i + 1); omega
  · have := htv (i + 1) (by omega); omega
  · have := htv i (by omega); omega
  · exact hnx

/-- Values beyond the observable token budget can use zero without constraining the reference. -/
def budgetTokens (T : Nat) (tk : Nat → Nat) (j : Nat) : Nat := if j ≤ T then tk j else 0

theorem budgetTokens_eq {T : Nat} {tk : Nat → Nat} {j : Nat} (hj : j ≤ T) :
    budgetTokens T tk j = tk j := by simp [budgetTokens, hj]

theorem budgetTokens_bound {T : Nat} {tk : Nat → Nat} (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (j : Nat) : budgetTokens T tk j ≤ 248319 := by
  unfold budgetTokens
  split <;> rename_i h
  · exact htv j h
  · omega

/-- A concrete base valuation uses only the finite observable token prefix. -/
def budgetVal (T : Nat) (tk : Nat → Nat) (j : Nat) : F64 :=
  if j = 0 then F64.ofNat T else F64.ofNat (budgetTokens T tk j)

theorem budgetVal_bound {T : Nat} {tk : Nat → Nat} (hT : T ≤ 262144)
    (htv : ∀ j, j ≤ T → tk j ≤ 248319) :
    ∀ j, ∃ k ≤ 2 ^ 20, budgetVal T tk j = F64.ofNat k := by
  intro j
  unfold budgetVal
  split
  · exact ⟨T, by omega, rfl⟩
  · exact ⟨budgetTokens T tk j, by have := budgetTokens_bound htv j; omega, rfl⟩

/-- The former unrestricted premise has no instance, even independently of the model. -/
theorem global_loopVB_impossible (ρ : Nat → F64) (T L : Nat) (tk : Nat → Nat)
    (h : ∀ i nx, nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) : False := by
  obtain ⟨k, hk, he⟩ := h 1048577 0 (by decide) 10
  change k ≤ 2 ^ 20 at hk
  change F64.ofNat 1048577 = F64.ofNat k at he
  have := ofNat_inj53 (by decide) (by omega) he
  omega

end Host.Ts.Sim.Compose
