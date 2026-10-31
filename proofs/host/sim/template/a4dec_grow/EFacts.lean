import host.sim.template.a4dec_grow.ERestart
import host.sim.template.a4dec_grow.S0Eq
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

/-! The facts of chain `DEC_grow`'s end the iteration consumes (`Prefill.IterEndW` apart from its shift): the token reference,
the end counter, freshness of `var 17`, the substitution, the framed arrays past the template's, the fixed addresses. -/

-- the chain's start: the template's with its readback suffix dropped (genChain's S0Eq: `DEC_grow.s0_tok`), its token the live one
kernel_rfl DEC_grow.tokens_val : (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.tokens = [.ref 79]
kernel_rfl DEC_grow.S0_tab : DEC_grow.S0.tab = DT.S0.tab
/-- The JS bookkeeping at the chain start (genChain --jstart). -/
theorem DEC_grow.jclean0 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_grow.s0 := by rw [DEC_grow.s0_tok]; exact DT.jclean
kernel_rfl DEC_grow.num79 : DEC_grow.σ.num 79 = .ref DEC_grow.S1D.tab.length
kernel_rfl DEC_grow.hE_check : Nat.blt (Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx.next 131072 = true
theorem DEC_grow.hE : (Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx.next < 131072 := Nat.le_of_ble_eq_true DEC_grow.hE_check
kernel_rfl DEC_grow.tlen_check : Nat.ble DEC_grow.S0.tab.length DEC_grow.S1D.tab.length = true
kernel_rfl DEC_grow.noVarTab_check : DEC_grow.S1D.tab.all (SymE.noVar 17) = true
kernel_rfl DEC_grow.noVarOr_check : DEC_grow.S1D.oracle.all (Ans.noVar 17) = true
theorem DEC_grow.noVarTab : ∀ e ∈ DEC_grow.S1D.tab, e.noVar 17 = true := List.all_eq_true.mp DEC_grow.noVarTab_check
theorem DEC_grow.noVarOr : ∀ q ∈ DEC_grow.S1D.oracle, q.noVar 17 = true := List.all_eq_true.mp DEC_grow.noVarOr_check
kernel_rfl DEC_grow.theta_low : (List.range 18).all (fun j => decide (DEC_grow.θ j = loopTheta true 17 j)) = true
kernel_rfl DEC_grow.theta_keys : DEC_grow.R.theta.all (fun p => Nat.blt p.1 18) = true
theorem DEC_grow.theta : ∀ j, DEC_grow.θ j = loopTheta true 17 j := theta_eq DEC_grow.theta_low DEC_grow.theta_keys
/-- The forwarded and emitted arrays' elements past the template's. -/
def DEC_grow.xs : List Val := []
def DEC_grow.eR : List Val := []
kernel_rfl DEC_grow.fwdE : arrOf DEC_grow.s11 2673448 = arrOf DEC_grow.s0 2673448 ++ DEC_grow.xs
kernel_rfl DEC_grow.fwdA : isArrB DEC_grow.s11 2673448 = true
theorem DEC_grow.fwd : ∃ o, DEC_grow.s11.heap.get 2673448 = some (.obj o) ∧ o.kind = .array (arrOf DEC_grow.s0 2673448 ++ DEC_grow.xs) :=
  arrExt_of DEC_grow.fwdE DEC_grow.fwdA
kernel_rfl DEC_grow.emitE : arrOf DEC_grow.s11 12504 = arrOf DEC_grow.s0 12504 ++ DEC_grow.eR
kernel_rfl DEC_grow.emitA : isArrB DEC_grow.s11 12504 = true
theorem DEC_grow.emit : ∃ o, DEC_grow.s11.heap.get 12504 = some (.obj o) ∧ o.kind = .array (arrOf DEC_grow.s0 12504 ++ DEC_grow.eR) :=
  arrExt_of DEC_grow.emitE DEC_grow.emitA
kernel_rfl DEC_grow.promptE : arrOf DEC_grow.s11 2665 = arrOf DEC_grow.s0 2665 ++ []
kernel_rfl DEC_grow.promptA : isArrB DEC_grow.s11 2665 = true
theorem DEC_grow.prompt : ∃ o, DEC_grow.s11.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf DEC_grow.s0 2665 ++ []) :=
  arrExt_of DEC_grow.promptE DEC_grow.promptA
kernel_rfl DEC_grow.fix_check : fixP.all (fun a => Nat.beq (DEC_grow.σ.a a) a) = true
theorem DEC_grow.fix : ∀ a ∈ fixP, DEC_grow.σ.a a = a := fun a ha => by
  have := List.all_eq_true.mp DEC_grow.fix_check a ha
  simpa using this
-- the wide frame's address fixed and present
kernel_rfl DEC_grow.w4910a : DEC_grow.σ.a 4910 = 4910
kernel_rfl DEC_grow.w4910p : (DEC_grow.s0.heap.get 4910).isSome = true
kernel_rfl DEC_grow.w4910f : wfixB DEC_grow.σ (presentB DEC_grow.s0) (WFrame.memo []) = true
-- the wide frame holds no array at the end (its frame keeps no prefix)
kernel_rfl DEC_grow.w4910k : isArrB DEC_grow.s11 4910 = false

end Host.Load.Run.Tpl
