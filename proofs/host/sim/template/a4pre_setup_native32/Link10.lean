import host.sim.template.a4pre_setup_native32.Link10States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative352 0
host_stream_state PRENative352 1

noncomputable def PRENative352.originalS1 : SSrv :=
  ⟨PRENative352.S1.tab, PRENative320.originalS1.oracle.drop PRENative352.O.length⟩

kernel_rfl PRENative352.start_exact : PRENative352.s0 = PRENative320.s1
kernel_rfl PRENative352.tab_exact : PRENative352.S0.tab = PRENative320.originalS1.tab
kernel_rfl PRENative352.oracle_prefix : PRENative320.originalS1.oracle.take PRENative352.O.length = PRENative352.O

kernel_rfl PRENative352.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative320.s1 PRENative320.originalS1 =
    some (PRENative352.s1, PRENative352.originalS1)

theorem PRENative352.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 352 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative352.s1, PRENative352.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 320 32
    PRE_setup_early_r0.s0 PRENative320.s1 PRENative352.s1
    PRE_setup_early_r0.S0 PRENative320.originalS1 PRENative352.originalS1
    PRENative320.prefix_checked PRENative352.checked

end Host.Load.Run.Tpl
