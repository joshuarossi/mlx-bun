import host.sim.template.a4pre_setup_native32.Link28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

kernel_rfl PRENative897.end_bridge :
  PRENative897.s1.ffi.1.1.bridge = PRENative32.s0.ffi.1.1.bridge

kernel_rfl PRENative897.end_fields :
  PRENative32.withBridge PRENative897.s1 (Host.Load.Boot.replay Host.Load.Run.Prompt.P.oblog2818) =
    PRE_setup_early_r0.s1

theorem PRENative897.end_exact : PRENative897.s1 = PRE_setup_early_r0.s1 :=
  (PRENative32.withBridge_self PRENative897.s1).symm.trans
    ((congrArg (PRENative32.withBridge PRENative897.s1)
      (PRENative897.end_bridge.trans PRENative32.bridge_exact.symm)).trans PRENative897.end_fields)

kernel_rfl PRENative897.end_server : PRENative897.originalS1 = PRE_setup_early_r0.S1

theorem PRE_setup_early_r0.k0 :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 897
      PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRE_setup_early_r0.s1, PRE_setup_early_r0.S1) := by
  have h := PRENative897.prefix_checked
  rw [PRENative897.end_exact, PRENative897.end_server] at h
  exact h

end Host.Load.Run.Tpl
