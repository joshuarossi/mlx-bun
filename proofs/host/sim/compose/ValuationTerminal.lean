import host.sim.compose.ValuationBounded

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full

/-- Terminal paths include iteration `T-2`, beyond the strict interior-step selection. -/
theorem valL_vb_terminal {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat}
    (hρ : ∀ j, ∃ k ≤ 2 ^ 20, ρ j = F64.ofNat k)
    (hctx : L + T ≤ 262144) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (i nx : Nat) (hi : i + 2 ≤ T) (hnx : nx ≤ 2 ^ 20) :
    VBOkF loopVB (valL ρ T tk L i nx) := by
  apply loopVal_vbF hρ
  · omega
  · omega
  · omega
  · have := capL_le (L + i + 1); omega
  · have := htv (i + 1) (by omega); omega
  · have := htv i (by omega); omega
  · exact hnx

/-- The final supported valuation is bounded constructively at a finite token prefix. -/
theorem budgetVal_vb_terminal {T L : Nat} {tk : Nat → Nat}
    (hctx : L + T ≤ 262144) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (i nx : Nat) (hi : i + 2 ≤ T) (hnx : nx ≤ 2 ^ 20) :
    VBOkF loopVB (valL (budgetVal T tk) T tk L i nx) :=
  valL_vb_terminal (budgetVal_bound (by omega) htv) hctx htv i nx hi hnx

end Host.Ts.Sim.Compose
