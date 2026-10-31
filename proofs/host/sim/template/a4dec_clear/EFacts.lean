import host.sim.template.a4dec_clear.ERestart
import host.sim.template.a4dec_clear.S0Eq
import host.sim.template.a4dec.Facts
import host.sim.template.a4dec.JClean
import host.sim.template.FactsGen
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The facts of chain `DEC_clear`'s end the iteration consumes (`Prefill.IterEndW` apart from its shift): the token reference,
the end counter, freshness of `var 17`, the substitution, the framed arrays past the template's, the fixed addresses. -/

-- the chain's start: the template's with its readback suffix dropped (genChain's S0Eq: `DEC_clear.s0_tok`), its token the live one
kernel_rfl DEC_clear.tokens_val : (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.tokens = [.ref 79]
kernel_rfl DEC_clear.S0_tab : DEC_clear.S0.tab = DT.S0.tab
/-- The JS bookkeeping at the chain start (genChain --jstart). -/
theorem DEC_clear.jclean0 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clear.s0 := by rw [DEC_clear.s0_tok]; exact DT.jclean
kernel_rfl DEC_clear.num79 : DEC_clear.σ.num 79 = .ref DEC_clear.S1D.tab.length
kernel_rfl DEC_clear.hE_check : Nat.blt (Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx.next 131072 = true
theorem DEC_clear.hE : (Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx.next < 131072 := Nat.le_of_ble_eq_true DEC_clear.hE_check
kernel_rfl DEC_clear.tlen_check : Nat.ble DEC_clear.S0.tab.length DEC_clear.S1D.tab.length = true
kernel_rfl DEC_clear.noVarTab_check : DEC_clear.S1D.tab.all (SymE.noVar 17) = true
kernel_rfl DEC_clear.noVarOr_check : DEC_clear.S1D.oracle.all (Ans.noVar 17) = true
theorem DEC_clear.noVarTab : ∀ e ∈ DEC_clear.S1D.tab, e.noVar 17 = true := List.all_eq_true.mp DEC_clear.noVarTab_check
theorem DEC_clear.noVarOr : ∀ q ∈ DEC_clear.S1D.oracle, q.noVar 17 = true := List.all_eq_true.mp DEC_clear.noVarOr_check
kernel_rfl DEC_clear.theta_low : (List.range 18).all (fun j => decide (DEC_clear.θ j = loopTheta false 17 j)) = true
kernel_rfl DEC_clear.theta_keys : DEC_clear.R.theta.all (fun p => Nat.blt p.1 18) = true
theorem DEC_clear.theta : ∀ j, DEC_clear.θ j = loopTheta false 17 j := theta_eq DEC_clear.theta_low DEC_clear.theta_keys
/-- The forwarded and emitted arrays' elements past the template's. -/
def DEC_clear.xs : List Val := []
def DEC_clear.eR : List Val := []
kernel_rfl DEC_clear.fwdE : arrOf DEC_clear.s11 2673448 = arrOf DEC_clear.s0 2673448 ++ DEC_clear.xs
kernel_rfl DEC_clear.fwdA : isArrB DEC_clear.s11 2673448 = true
theorem DEC_clear.fwd : ∃ o, DEC_clear.s11.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clear.s0 2673448 ++ DEC_clear.xs) :=
  arrExt_of DEC_clear.fwdE DEC_clear.fwdA
kernel_rfl DEC_clear.emitE : arrOf DEC_clear.s11 12504 = arrOf DEC_clear.s0 12504 ++ DEC_clear.eR
kernel_rfl DEC_clear.emitA : isArrB DEC_clear.s11 12504 = true
theorem DEC_clear.emit : ∃ o, DEC_clear.s11.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clear.s0 12504 ++ DEC_clear.eR) :=
  arrExt_of DEC_clear.emitE DEC_clear.emitA
kernel_rfl DEC_clear.promptE : arrOf DEC_clear.s11 2665 = arrOf DEC_clear.s0 2665 ++ []
kernel_rfl DEC_clear.promptA : isArrB DEC_clear.s11 2665 = true
theorem DEC_clear.prompt : ∃ o, DEC_clear.s11.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clear.s0 2665 ++ []) :=
  arrExt_of DEC_clear.promptE DEC_clear.promptA
kernel_rfl DEC_clear.fix_check : fixP.all (fun a => Nat.beq (DEC_clear.σ.a a) a) = true
theorem DEC_clear.fix : ∀ a ∈ fixP, DEC_clear.σ.a a = a := fun a ha => by
  have := List.all_eq_true.mp DEC_clear.fix_check a ha
  simpa using this
-- the wide frame's address fixed and present
kernel_rfl DEC_clear.w4910a : DEC_clear.σ.a 4910 = 4910
kernel_rfl DEC_clear.w4910p : (DEC_clear.s0.heap.get 4910).isSome = true
kernel_rfl DEC_clear.w4910f : wfixB DEC_clear.σ (presentB DEC_clear.s0) (WFrame.memo []) = true
-- the wide frame holds no array at the end (its frame keeps no prefix)
kernel_rfl DEC_clear.w4910k : isArrB DEC_clear.s11 4910 = false

end Host.Load.Run.Tpl
