import host.sim.template.a4pre_setup_native32.Link11States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative384 0
host_stream_state PRENative384 1

noncomputable def PRENative384.originalS1 : SSrv :=
  ⟨PRENative384.S1.tab, PRENative352.originalS1.oracle.drop PRENative384.O.length⟩

kernel_rfl PRENative384.start_exact : PRENative384.s0 = PRENative352.s1
kernel_rfl PRENative384.tab_exact : PRENative384.S0.tab = PRENative352.originalS1.tab
kernel_rfl PRENative384.oracle_prefix : PRENative352.originalS1.oracle.take PRENative384.O.length = PRENative384.O

kernel_rfl PRENative384.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative352.s1 PRENative352.originalS1 =
    some (PRENative384.s1, PRENative384.originalS1)

theorem PRENative384.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 384 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative384.s1, PRENative384.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 352 32
    PRE_setup_early_r0.s0 PRENative352.s1 PRENative384.s1
    PRE_setup_early_r0.S0 PRENative352.originalS1 PRENative384.originalS1
    PRENative352.prefix_checked PRENative384.checked

end Host.Load.Run.Tpl
