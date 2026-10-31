import host.sim.template.a4pre_setup_native32.Link4States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative160 0
host_stream_state PRENative160 1

noncomputable def PRENative160.originalS1 : SSrv :=
  ⟨PRENative160.S1.tab, PRENative128.originalS1.oracle.drop PRENative160.O.length⟩

kernel_rfl PRENative160.start_exact : PRENative160.s0 = PRENative128.s1
kernel_rfl PRENative160.tab_exact : PRENative160.S0.tab = PRENative128.originalS1.tab
kernel_rfl PRENative160.oracle_prefix : PRENative128.originalS1.oracle.take PRENative160.O.length = PRENative160.O

kernel_rfl PRENative160.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative128.s1 PRENative128.originalS1 =
    some (PRENative160.s1, PRENative160.originalS1)

theorem PRENative160.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 160 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative160.s1, PRENative160.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 128 32
    PRE_setup_early_r0.s0 PRENative128.s1 PRENative160.s1
    PRE_setup_early_r0.S0 PRENative128.originalS1 PRENative160.originalS1
    PRENative128.prefix_checked PRENative160.checked

end Host.Load.Run.Tpl
