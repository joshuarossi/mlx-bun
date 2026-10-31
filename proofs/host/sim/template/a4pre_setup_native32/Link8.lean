import host.sim.template.a4pre_setup_native32.Link8States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative288 0
host_stream_state PRENative288 1

noncomputable def PRENative288.originalS1 : SSrv :=
  ⟨PRENative288.S1.tab, PRENative256.originalS1.oracle.drop PRENative288.O.length⟩

kernel_rfl PRENative288.start_exact : PRENative288.s0 = PRENative256.s1
kernel_rfl PRENative288.tab_exact : PRENative288.S0.tab = PRENative256.originalS1.tab
kernel_rfl PRENative288.oracle_prefix : PRENative256.originalS1.oracle.take PRENative288.O.length = PRENative288.O

kernel_rfl PRENative288.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative256.s1 PRENative256.originalS1 =
    some (PRENative288.s1, PRENative288.originalS1)

theorem PRENative288.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 288 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative288.s1, PRENative288.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 256 32
    PRE_setup_early_r0.s0 PRENative256.s1 PRENative288.s1
    PRE_setup_early_r0.S0 PRENative256.originalS1 PRENative288.originalS1
    PRENative256.prefix_checked PRENative288.checked

end Host.Load.Run.Tpl
