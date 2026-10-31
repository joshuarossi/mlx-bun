import host.sim.template.a4eos_cut.Facts
import host.sim.compose.ValuationTerminal
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template
namespace EosCutData

/-- Frame membership and band endpoints do not constrain the target prompt prefix. -/
theorem prompt_prefix_arbitrary (K : Ctx)
    (hfr : ∀ a, K.fr a ≠ none ↔ a ∈ [2673448, 12504, 2665, 4910]) (q : List Val) :
    let K' := Disp.Ctx.frameAt K 2665 (arrOf DEC.s0 2665, q)
    (∀ a, K'.fr a ≠ none ↔ a ∈ [2673448, 12504, 2665, 4910]) ∧
      K'.lo = K.lo ∧ K'.hi = K.hi := by
  dsimp only
  refine ⟨?_, rfl, rfl⟩
  intro a
  by_cases ha : a = 2665
  · subst a
    rw [Disp.Ctx.frameAt_eq]
    simp
  · rw [Disp.Ctx.frameAt_ne K _ ha]
    exact hfr a

end EosCutData

/-- The valuation part of the EOS entry obligation, including `k = T - 1`. -/
theorem DEC.eosCutVb {T L : Nat} {tk : Nat → Nat}
    (hctx : L + T ≤ 262144) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (k : Nat) (hk : 2 ≤ k) (hkT : k < T) (nx : Nat) (hnx : nx ≤ 2 ^ 20) :
    VBOkF loopVB (valL (budgetVal T tk) T tk L (k - 1) nx) :=
  budgetVal_vb_terminal hctx htv
    (k - 1) nx (by omega) hnx

end Host.Ts.Sim.Compose
