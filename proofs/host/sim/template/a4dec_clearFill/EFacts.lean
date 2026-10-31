import host.sim.template.a4dec_clearFill.ERestart
import host.sim.template.a4dec_clearFill.S0Eq
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

/-! The facts of chain `DEC_clearFill`'s end the iteration consumes (`Prefill.IterEndW` apart from its shift): the token reference,
the end counter, freshness of `var 17`, the substitution, the framed arrays past the template's, the fixed addresses. -/

-- the chain's start: the template's with its readback suffix dropped (genChain's S0Eq: `DEC_clearFill.s0_tok`), its token the live one
kernel_rfl DEC_clearFill.tokens_val : (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.tokens = [.ref 79]
kernel_rfl DEC_clearFill.S0_tab : DEC_clearFill.S0.tab = DT.S0.tab
/-- The JS bookkeeping at the chain start (genChain --jstart). -/
theorem DEC_clearFill.jclean0 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearFill.s0 := by rw [DEC_clearFill.s0_tok]; exact DT.jclean
kernel_rfl DEC_clearFill.num79 : DEC_clearFill.σ.num 79 = .ref DEC_clearFill.S1D.tab.length
kernel_rfl DEC_clearFill.hE_check : Nat.blt (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx.next 131072 = true
theorem DEC_clearFill.hE : (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx.next < 131072 := Nat.le_of_ble_eq_true DEC_clearFill.hE_check
kernel_rfl DEC_clearFill.tlen_check : Nat.ble DEC_clearFill.S0.tab.length DEC_clearFill.S1D.tab.length = true
kernel_rfl DEC_clearFill.noVarTab_check : DEC_clearFill.S1D.tab.all (SymE.noVar 17) = true
kernel_rfl DEC_clearFill.noVarOr_check : DEC_clearFill.S1D.oracle.all (Ans.noVar 17) = true
theorem DEC_clearFill.noVarTab : ∀ e ∈ DEC_clearFill.S1D.tab, e.noVar 17 = true := List.all_eq_true.mp DEC_clearFill.noVarTab_check
theorem DEC_clearFill.noVarOr : ∀ q ∈ DEC_clearFill.S1D.oracle, q.noVar 17 = true := List.all_eq_true.mp DEC_clearFill.noVarOr_check
kernel_rfl DEC_clearFill.theta_low : (List.range 18).all (fun j => decide (DEC_clearFill.θ j = loopTheta false 17 j)) = true
kernel_rfl DEC_clearFill.theta_keys : DEC_clearFill.R.theta.all (fun p => Nat.blt p.1 18) = true
theorem DEC_clearFill.theta : ∀ j, DEC_clearFill.θ j = loopTheta false 17 j := theta_eq DEC_clearFill.theta_low DEC_clearFill.theta_keys
/-- The forwarded and emitted arrays' elements past the template's. -/
def DEC_clearFill.xs : List Val := []
def DEC_clearFill.eR : List Val := []
kernel_rfl DEC_clearFill.fwdE : arrOf DEC_clearFill.s11 2673448 = arrOf DEC_clearFill.s0 2673448 ++ DEC_clearFill.xs
kernel_rfl DEC_clearFill.fwdA : isArrB DEC_clearFill.s11 2673448 = true
theorem DEC_clearFill.fwd : ∃ o, DEC_clearFill.s11.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearFill.s0 2673448 ++ DEC_clearFill.xs) :=
  arrExt_of DEC_clearFill.fwdE DEC_clearFill.fwdA
kernel_rfl DEC_clearFill.emitE : arrOf DEC_clearFill.s11 12504 = arrOf DEC_clearFill.s0 12504 ++ DEC_clearFill.eR
kernel_rfl DEC_clearFill.emitA : isArrB DEC_clearFill.s11 12504 = true
theorem DEC_clearFill.emit : ∃ o, DEC_clearFill.s11.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearFill.s0 12504 ++ DEC_clearFill.eR) :=
  arrExt_of DEC_clearFill.emitE DEC_clearFill.emitA
kernel_rfl DEC_clearFill.promptE : arrOf DEC_clearFill.s11 2665 = arrOf DEC_clearFill.s0 2665 ++ []
kernel_rfl DEC_clearFill.promptA : isArrB DEC_clearFill.s11 2665 = true
theorem DEC_clearFill.prompt : ∃ o, DEC_clearFill.s11.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_clearFill.s0 2665 ++ []) :=
  arrExt_of DEC_clearFill.promptE DEC_clearFill.promptA
kernel_rfl DEC_clearFill.fix_check : fixP.all (fun a => Nat.beq (DEC_clearFill.σ.a a) a) = true
theorem DEC_clearFill.fix : ∀ a ∈ fixP, DEC_clearFill.σ.a a = a := fun a ha => by
  have := List.all_eq_true.mp DEC_clearFill.fix_check a ha
  simpa using this
-- the wide frame's address fixed and present
kernel_rfl DEC_clearFill.w4910a : DEC_clearFill.σ.a 4910 = 4910
kernel_rfl DEC_clearFill.w4910p : (DEC_clearFill.s0.heap.get 4910).isSome = true
kernel_rfl DEC_clearFill.w4910f : wfixB DEC_clearFill.σ (presentB DEC_clearFill.s0) (WFrame.memo []) = true
-- the wide frame holds no array at the end (its frame keeps no prefix)
kernel_rfl DEC_clearFill.w4910k : isArrB DEC_clearFill.s11 4910 = false

end Host.Load.Run.Tpl
