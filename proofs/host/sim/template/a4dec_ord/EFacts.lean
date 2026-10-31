import host.sim.template.a4dec_ord.ERestart
import host.sim.template.a4dec_ord.S0Eq
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

/-! The facts of chain `DEC_ord`'s end the iteration consumes (`Prefill.IterEndW` apart from its shift): the token reference,
the end counter, freshness of `var 17`, the substitution, the framed arrays past the template's, the fixed addresses. -/

-- the chain's start: the template's with its readback suffix dropped (genChain's S0Eq: `DEC_ord.s0_tok`), its token the live one
kernel_rfl DEC_ord.tokens_val : (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.tokens = [.ref 79]
kernel_rfl DEC_ord.S0_tab : DEC_ord.S0.tab = DT.S0.tab
/-- The JS bookkeeping at the chain start (genChain --jstart). -/
theorem DEC_ord.jclean0 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_ord.s0 := by rw [DEC_ord.s0_tok]; exact DT.jclean
kernel_rfl DEC_ord.num79 : DEC_ord.σ.num 79 = .ref DEC_ord.S1D.tab.length
kernel_rfl DEC_ord.hE_check : Nat.blt (Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx.next 131072 = true
theorem DEC_ord.hE : (Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx.next < 131072 := Nat.le_of_ble_eq_true DEC_ord.hE_check
kernel_rfl DEC_ord.tlen_check : Nat.ble DEC_ord.S0.tab.length DEC_ord.S1D.tab.length = true
kernel_rfl DEC_ord.noVarTab_check : DEC_ord.S1D.tab.all (SymE.noVar 17) = true
kernel_rfl DEC_ord.noVarOr_check : DEC_ord.S1D.oracle.all (Ans.noVar 17) = true
theorem DEC_ord.noVarTab : ∀ e ∈ DEC_ord.S1D.tab, e.noVar 17 = true := List.all_eq_true.mp DEC_ord.noVarTab_check
theorem DEC_ord.noVarOr : ∀ q ∈ DEC_ord.S1D.oracle, q.noVar 17 = true := List.all_eq_true.mp DEC_ord.noVarOr_check
kernel_rfl DEC_ord.theta_low : (List.range 18).all (fun j => decide (DEC_ord.θ j = loopTheta false 17 j)) = true
kernel_rfl DEC_ord.theta_keys : DEC_ord.R.theta.all (fun p => Nat.blt p.1 18) = true
theorem DEC_ord.theta : ∀ j, DEC_ord.θ j = loopTheta false 17 j := theta_eq DEC_ord.theta_low DEC_ord.theta_keys
/-- The forwarded and emitted arrays' elements past the template's. -/
def DEC_ord.xs : List Val := []
def DEC_ord.eR : List Val := []
kernel_rfl DEC_ord.fwdE : arrOf DEC_ord.s11 2673448 = arrOf DEC_ord.s0 2673448 ++ DEC_ord.xs
kernel_rfl DEC_ord.fwdA : isArrB DEC_ord.s11 2673448 = true
theorem DEC_ord.fwd : ∃ o, DEC_ord.s11.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_ord.s0 2673448 ++ DEC_ord.xs) :=
  arrExt_of DEC_ord.fwdE DEC_ord.fwdA
kernel_rfl DEC_ord.emitE : arrOf DEC_ord.s11 12504 = arrOf DEC_ord.s0 12504 ++ DEC_ord.eR
kernel_rfl DEC_ord.emitA : isArrB DEC_ord.s11 12504 = true
theorem DEC_ord.emit : ∃ o, DEC_ord.s11.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_ord.s0 12504 ++ DEC_ord.eR) :=
  arrExt_of DEC_ord.emitE DEC_ord.emitA
kernel_rfl DEC_ord.promptE : arrOf DEC_ord.s11 2665 = arrOf DEC_ord.s0 2665 ++ []
kernel_rfl DEC_ord.promptA : isArrB DEC_ord.s11 2665 = true
theorem DEC_ord.prompt : ∃ o, DEC_ord.s11.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_ord.s0 2665 ++ []) :=
  arrExt_of DEC_ord.promptE DEC_ord.promptA
kernel_rfl DEC_ord.fix_check : fixP.all (fun a => Nat.beq (DEC_ord.σ.a a) a) = true
theorem DEC_ord.fix : ∀ a ∈ fixP, DEC_ord.σ.a a = a := fun a ha => by
  have := List.all_eq_true.mp DEC_ord.fix_check a ha
  simpa using this
-- the wide frame's address fixed and present
kernel_rfl DEC_ord.w4910a : DEC_ord.σ.a 4910 = 4910
kernel_rfl DEC_ord.w4910p : (DEC_ord.s0.heap.get 4910).isSome = true
kernel_rfl DEC_ord.w4910f : wfixB DEC_ord.σ (presentB DEC_ord.s0) (WFrame.memo []) = true
-- the wide frame holds no array at the end (its frame keeps no prefix)
kernel_rfl DEC_ord.w4910k : isArrB DEC_ord.s11 4910 = false

end Host.Load.Run.Tpl
