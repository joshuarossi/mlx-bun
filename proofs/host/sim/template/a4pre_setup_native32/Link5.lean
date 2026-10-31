import host.sim.template.a4pre_setup_native32.Link5States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative192 0
host_stream_state PRENative192 1

noncomputable def PRENative192.originalS1 : SSrv :=
  ⟨PRENative192.S1.tab, PRENative160.originalS1.oracle.drop PRENative192.O.length⟩

kernel_rfl PRENative192.start_exact : PRENative192.s0 = PRENative160.s1
kernel_rfl PRENative192.tab_exact : PRENative192.S0.tab = PRENative160.originalS1.tab
kernel_rfl PRENative192.oracle_prefix : PRENative160.originalS1.oracle.take PRENative192.O.length = PRENative192.O

kernel_rfl PRENative192.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative160.s1 PRENative160.originalS1 =
    some (PRENative192.s1, PRENative192.originalS1)

theorem PRENative192.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 192 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative192.s1, PRENative192.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 160 32
    PRE_setup_early_r0.s0 PRENative160.s1 PRENative192.s1
    PRE_setup_early_r0.S0 PRENative160.originalS1 PRENative192.originalS1
    PRENative160.prefix_checked PRENative192.checked

end Host.Load.Run.Tpl
