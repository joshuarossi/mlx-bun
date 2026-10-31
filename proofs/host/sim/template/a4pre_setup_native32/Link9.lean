import host.sim.template.a4pre_setup_native32.Link9States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative320 0
host_stream_state PRENative320 1

noncomputable def PRENative320.originalS1 : SSrv :=
  ⟨PRENative320.S1.tab, PRENative288.originalS1.oracle.drop PRENative320.O.length⟩

kernel_rfl PRENative320.start_exact : PRENative320.s0 = PRENative288.s1
kernel_rfl PRENative320.tab_exact : PRENative320.S0.tab = PRENative288.originalS1.tab
kernel_rfl PRENative320.oracle_prefix : PRENative288.originalS1.oracle.take PRENative320.O.length = PRENative320.O

kernel_rfl PRENative320.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative288.s1 PRENative288.originalS1 =
    some (PRENative320.s1, PRENative320.originalS1)

theorem PRENative320.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 320 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative320.s1, PRENative320.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 288 32
    PRE_setup_early_r0.s0 PRENative288.s1 PRENative320.s1
    PRE_setup_early_r0.S0 PRENative288.originalS1 PRENative320.originalS1
    PRENative288.prefix_checked PRENative320.checked

end Host.Load.Run.Tpl
