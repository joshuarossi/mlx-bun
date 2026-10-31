import host.sim.template.a4dec_clearGrow.ERestart
import host.sim.template.a4dec_clearGrow.S0Eq
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

/-! The facts of chain `DEC_clearGrow`'s end the iteration consumes (`Prefill.IterEndW` apart from its shift): the token reference,
the end counter, freshness of `var 17`, the substitution, the framed arrays past the template's, the fixed addresses. -/

-- the chain's start: the template's with its readback suffix dropped (genChain's S0Eq: `DEC_clearGrow.s0_tok`), its token the live one
kernel_rfl DEC_clearGrow.tokens_val : (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.tokens = [.ref 79]
kernel_rfl DEC_clearGrow.S0_tab : DEC_clearGrow.S0.tab = DT.S0.tab
/-- The JS bookkeeping at the chain start (genChain --jstart). -/
theorem DEC_clearGrow.jclean0 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearGrow.s0 := by rw [DEC_clearGrow.s0_tok]; exact DT.jclean
kernel_rfl DEC_clearGrow.num79 : DEC_clearGrow.σ.num 79 = .ref DEC_clearGrow.S1D.tab.length
kernel_rfl DEC_clearGrow.hE_check : Nat.blt (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx.next 131072 = true
theorem DEC_clearGrow.hE : (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx.next < 131072 := Nat.le_of_ble_eq_true DEC_clearGrow.hE_check
kernel_rfl DEC_clearGrow.tlen_check : Nat.ble DEC_clearGrow.S0.tab.length DEC_clearGrow.S1D.tab.length = true
kernel_rfl DEC_clearGrow.noVarTab_check : DEC_clearGrow.S1D.tab.all (SymE.noVar 17) = true
kernel_rfl DEC_clearGrow.noVarOr_check : DEC_clearGrow.S1D.oracle.all (Ans.noVar 17) = true
theorem DEC_clearGrow.noVarTab : ∀ e ∈ DEC_clearGrow.S1D.tab, e.noVar 17 = true := List.all_eq_true.mp DEC_clearGrow.noVarTab_check
theorem DEC_clearGrow.noVarOr : ∀ q ∈ DEC_clearGrow.S1D.oracle, q.noVar 17 = true := List.all_eq_true.mp DEC_clearGrow.noVarOr_check
kernel_rfl DEC_clearGrow.theta_low : (List.range 18).all (fun j => decide (DEC_clearGrow.θ j = loopTheta true 17 j)) = true
kernel_rfl DEC_clearGrow.theta_keys : DEC_clearGrow.R.theta.all (fun p => Nat.blt p.1 18) = true
theorem DEC_clearGrow.theta : ∀ j, DEC_clearGrow.θ j = loopTheta true 17 j := theta_eq DEC_clearGrow.theta_low DEC_clearGrow.theta_keys
/-- The forwarded and emitted arrays' elements past the template's. -/
def DEC_clearGrow.xs : List Val := []
def DEC_clearGrow.eR : List Val := []
kernel_rfl DEC_clearGrow.fwdE : arrOf DEC_clearGrow.s11 2673448 = arrOf DEC_clearGrow.s0 2673448 ++ DEC_clearGrow.xs
kernel_rfl DEC_clearGrow.fwdA : isArrB DEC_clearGrow.s11 2673448 = true
theorem DEC_clearGrow.fwd : ∃ o, DEC_clearGrow.s11.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearGrow.s0 2673448 ++ DEC_clearGrow.xs) :=
  arrExt_of DEC_clearGrow.fwdE DEC_clearGrow.fwdA
kernel_rfl DEC_clearGrow.emitE : arrOf DEC_clearGrow.s11 12504 = arrOf DEC_clearGrow.s0 12504 ++ DEC_clearGrow.eR
kernel_rfl DEC_clearGrow.emitA : isArrB DEC_clearGrow.s11 12504 = true
theorem DEC_clearGrow.emit : ∃ o, DEC_clearGrow.s11.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearGrow.s0 12504 ++ DEC_clearGrow.eR) :=
  arrExt_of DEC_clearGrow.emitE DEC_clearGrow.emitA
kernel_rfl DEC_clearGrow.promptE : arrOf DEC_clearGrow.s11 2665 = arrOf DEC_clearGrow.s0 2665 ++ []
kernel_rfl DEC_clearGrow.promptA : isArrB DEC_clearGrow.s11 2665 = true
theorem DEC_clearGrow.prompt : ∃ o, DEC_clearGrow.s11.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearGrow.s0 2665 ++ []) :=
  arrExt_of DEC_clearGrow.promptE DEC_clearGrow.promptA
kernel_rfl DEC_clearGrow.fix_check : fixP.all (fun a => Nat.beq (DEC_clearGrow.σ.a a) a) = true
theorem DEC_clearGrow.fix : ∀ a ∈ fixP, DEC_clearGrow.σ.a a = a := fun a ha => by
  have := List.all_eq_true.mp DEC_clearGrow.fix_check a ha
  simpa using this
-- the wide frame's address fixed and present
kernel_rfl DEC_clearGrow.w4910a : DEC_clearGrow.σ.a 4910 = 4910
kernel_rfl DEC_clearGrow.w4910p : (DEC_clearGrow.s0.heap.get 4910).isSome = true
kernel_rfl DEC_clearGrow.w4910f : wfixB DEC_clearGrow.σ (presentB DEC_clearGrow.s0) (WFrame.memo []) = true
-- the wide frame holds no array at the end (its frame keeps no prefix)
kernel_rfl DEC_clearGrow.w4910k : isArrB DEC_clearGrow.s11 4910 = false

end Host.Load.Run.Tpl
