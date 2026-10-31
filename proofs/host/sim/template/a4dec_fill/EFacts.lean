import host.sim.template.a4dec_fill.ERestart
import host.sim.template.a4dec_fill.S0Eq
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

/-! The facts of chain `DEC_fill`'s end the iteration consumes (`Prefill.IterEndW` apart from its shift): the token reference,
the end counter, freshness of `var 17`, the substitution, the framed arrays past the template's, the fixed addresses. -/

-- the chain's start: the template's with its readback suffix dropped (genChain's S0Eq: `DEC_fill.s0_tok`), its token the live one
kernel_rfl DEC_fill.tokens_val : (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.tokens = [.ref 79]
kernel_rfl DEC_fill.S0_tab : DEC_fill.S0.tab = DT.S0.tab
/-- The JS bookkeeping at the chain start (genChain --jstart). -/
theorem DEC_fill.jclean0 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_fill.s0 := by rw [DEC_fill.s0_tok]; exact DT.jclean
kernel_rfl DEC_fill.num79 : DEC_fill.σ.num 79 = .ref DEC_fill.S1D.tab.length
kernel_rfl DEC_fill.hE_check : Nat.blt (Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx.next 131072 = true
theorem DEC_fill.hE : (Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx.next < 131072 := Nat.le_of_ble_eq_true DEC_fill.hE_check
kernel_rfl DEC_fill.tlen_check : Nat.ble DEC_fill.S0.tab.length DEC_fill.S1D.tab.length = true
kernel_rfl DEC_fill.noVarTab_check : DEC_fill.S1D.tab.all (SymE.noVar 17) = true
kernel_rfl DEC_fill.noVarOr_check : DEC_fill.S1D.oracle.all (Ans.noVar 17) = true
theorem DEC_fill.noVarTab : ∀ e ∈ DEC_fill.S1D.tab, e.noVar 17 = true := List.all_eq_true.mp DEC_fill.noVarTab_check
theorem DEC_fill.noVarOr : ∀ q ∈ DEC_fill.S1D.oracle, q.noVar 17 = true := List.all_eq_true.mp DEC_fill.noVarOr_check
kernel_rfl DEC_fill.theta_low : (List.range 18).all (fun j => decide (DEC_fill.θ j = loopTheta false 17 j)) = true
kernel_rfl DEC_fill.theta_keys : DEC_fill.R.theta.all (fun p => Nat.blt p.1 18) = true
theorem DEC_fill.theta : ∀ j, DEC_fill.θ j = loopTheta false 17 j := theta_eq DEC_fill.theta_low DEC_fill.theta_keys
/-- The forwarded and emitted arrays' elements past the template's. -/
def DEC_fill.xs : List Val := []
def DEC_fill.eR : List Val := []
kernel_rfl DEC_fill.fwdE : arrOf DEC_fill.s11 2673448 = arrOf DEC_fill.s0 2673448 ++ DEC_fill.xs
kernel_rfl DEC_fill.fwdA : isArrB DEC_fill.s11 2673448 = true
theorem DEC_fill.fwd : ∃ o, DEC_fill.s11.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_fill.s0 2673448 ++ DEC_fill.xs) :=
  arrExt_of DEC_fill.fwdE DEC_fill.fwdA
kernel_rfl DEC_fill.emitE : arrOf DEC_fill.s11 12504 = arrOf DEC_fill.s0 12504 ++ DEC_fill.eR
kernel_rfl DEC_fill.emitA : isArrB DEC_fill.s11 12504 = true
theorem DEC_fill.emit : ∃ o, DEC_fill.s11.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_fill.s0 12504 ++ DEC_fill.eR) :=
  arrExt_of DEC_fill.emitE DEC_fill.emitA
kernel_rfl DEC_fill.promptE : arrOf DEC_fill.s11 2665 = arrOf DEC_fill.s0 2665 ++ []
kernel_rfl DEC_fill.promptA : isArrB DEC_fill.s11 2665 = true
theorem DEC_fill.prompt : ∃ o, DEC_fill.s11.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_fill.s0 2665 ++ []) :=
  arrExt_of DEC_fill.promptE DEC_fill.promptA
kernel_rfl DEC_fill.fix_check : fixP.all (fun a => Nat.beq (DEC_fill.σ.a a) a) = true
theorem DEC_fill.fix : ∀ a ∈ fixP, DEC_fill.σ.a a = a := fun a ha => by
  have := List.all_eq_true.mp DEC_fill.fix_check a ha
  simpa using this
-- the wide frame's address fixed and present
kernel_rfl DEC_fill.w4910a : DEC_fill.σ.a 4910 = 4910
kernel_rfl DEC_fill.w4910p : (DEC_fill.s0.heap.get 4910).isSome = true
kernel_rfl DEC_fill.w4910f : wfixB DEC_fill.σ (presentB DEC_fill.s0) (WFrame.memo []) = true
-- the wide frame holds no array at the end (its frame keeps no prefix)
kernel_rfl DEC_fill.w4910k : isArrB DEC_fill.s11 4910 = false

end Host.Load.Run.Tpl
