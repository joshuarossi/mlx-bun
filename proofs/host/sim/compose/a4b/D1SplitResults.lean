import host.sim.compose.a4b.D1SplitStart
import host.sim.compose.a4b.SetupDropData
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

theorem inactive0 : (bridgeOf D1StageSplit.s0.ffi).active = false := by
  have hs := congrArg (fun s : St FF.S => (bridgeOf s.ffi).active) startEq
  have hn := congrArg (fun f : FF.S => (bridgeOf f).active) SetupDrop.nativeEq
  exact hs.trans (hn.trans ((congrArg (fun b => b.active) SetupCommon.bridge10).trans SetupCommon.inactive0))
kernel_rfl bridge1 : bridgeOf D1StageSplit.s1.ffi = bridgeOf D1StageSplit.s0.ffi
kernel_rfl result0 : nth? D1StageSplit.st0.S2.tab 14 = some (.un .trunc (.var 9))
kernel_rfl result1 : nth? D1StageSplit.st0.S2.tab 15 = some (.bin .sub (.var 9) (.lit (F64.zero false)))
kernel_rfl result2 : nth? D1StageSplit.st0.S2.tab 16 = some (.bin .sub (.var 9) (.lit (F64.zero false)))

theorem resultValue {ν : Nat → F64} (hv : ν 9 = F64.ofNat 1) {j : Nat} (hj : j < 3) :
    Conv.resF SymE.var D1StageSplit.st0.S2.tab D1StageSplit.S0.tab.length ν j = F64.ofNat 1 := by
  have he : j = 0 ∨ j = 1 ∨ j = 2 := by omega
  rcases he with rfl | rfl | rfl
  · simp only [Conv.resF, len0, Nat.add_zero, result0, Option.getD_some, Shift.valuation, SymE.eval, hv]
    rfl
  · simp only [Conv.resF, len0]
    change ((nth? D1StageSplit.st0.S2.tab 15).getD (.lit (F64.zero false))).eval (Shift.valuation SymE.var ν) = _
    rw [result1]
    simp only [Option.getD_some, Shift.valuation, SymE.eval, hv]
    rfl
  · simp only [Conv.resF, len0]
    change ((nth? D1StageSplit.st0.S2.tab 16).getD (.lit (F64.zero false))).eval (Shift.valuation SymE.var ν) = _
    rw [result2]
    simp only [Option.getD_some, Shift.valuation, SymE.eval, hv]
    rfl

end Host.Ts.Sim.Compose.D1Split
