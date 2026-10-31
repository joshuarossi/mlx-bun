import host.sim.template.a4pre_setup_native32.Link12States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative416 0
host_stream_state PRENative416 1

noncomputable def PRENative416.originalS1 : SSrv :=
  ⟨PRENative416.S1.tab, PRENative384.originalS1.oracle.drop PRENative416.O.length⟩

kernel_rfl PRENative416.start_exact : PRENative416.s0 = PRENative384.s1
kernel_rfl PRENative416.tab_exact : PRENative416.S0.tab = PRENative384.originalS1.tab
kernel_rfl PRENative416.oracle_prefix : PRENative384.originalS1.oracle.take PRENative416.O.length = PRENative416.O

kernel_rfl PRENative416.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative384.s1 PRENative384.originalS1 =
    some (PRENative416.s1, PRENative416.originalS1)

theorem PRENative416.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 416 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative416.s1, PRENative416.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 384 32
    PRE_setup_early_r0.s0 PRENative384.s1 PRENative416.s1
    PRE_setup_early_r0.S0 PRENative384.originalS1 PRENative416.originalS1
    PRENative384.prefix_checked PRENative416.checked

end Host.Load.Run.Tpl
