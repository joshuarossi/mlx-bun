import host.sim.compose.a4b.PrefillD1First
import host.sim.compose.a4b.SetupCommonStart
import host.sim.compose.a4b.SetupRestCuts
import host.sim.compose.SetupKeep
import host.sim.template.a4pre_d1_stage_split.S0Eq

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

kernel_rfl tokens16 : (mlxOf PRE_setup_early_r0.s16.ffi).tokens = [.ref 1, .ref 2]

theorem startEq : (D1StageSplit.s0 : St FF.S) = PRE_setup_early_r0.s16 := by
  have hf : fullSetTokens PRE_setup_early_r0.s16.ffi [.ref 1, .ref 2] = PRE_setup_early_r0.s16.ffi :=
    (congrArg (fullSetTokens PRE_setup_early_r0.s16.ffi) tokens16.symm).trans
      (SetupCommon.fullSetTokens_self PRE_setup_early_r0.s16.ffi)
  have h : (D1StageSplit.s0 : St FF.S) = PRE_setup_early_r0.s16.setFfi
      (fullSetTokens PRE_setup_early_r0.s16.ffi [.ref 1, .ref 2]) := D1StageSplit.s0_tok
  exact h.trans ((congrArg (fun z : FF.S => (PRE_setup_early_r0.s16 : St FF.S).setFfi z) hf).trans rfl)

kernel_rfl startTab : D1StageSplit.S0.tab = PRE_setup_early_r0.S16.tab
kernel_rfl len0 : D1StageSplit.S0.tab.length = 14
kernel_rfl ws0 : D1StageSplit.ws0 = [1000, 1001, 1002]

end Host.Ts.Sim.Compose.D1Split
