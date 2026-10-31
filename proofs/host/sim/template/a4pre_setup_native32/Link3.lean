import host.sim.template.a4pre_setup_native32.Link3States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative128 0
host_stream_state PRENative128 1

noncomputable def PRENative128.originalS1 : SSrv :=
  ⟨PRENative128.S1.tab, PRENative96.originalS1.oracle.drop PRENative128.O.length⟩

kernel_rfl PRENative128.start_exact : PRENative128.s0 = PRENative96.s1
kernel_rfl PRENative128.tab_exact : PRENative128.S0.tab = PRENative96.originalS1.tab
kernel_rfl PRENative128.oracle_prefix : PRENative96.originalS1.oracle.take PRENative128.O.length = PRENative128.O

kernel_rfl PRENative128.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative96.s1 PRENative96.originalS1 =
    some (PRENative128.s1, PRENative128.originalS1)

theorem PRENative128.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 128 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative128.s1, PRENative128.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 96 32
    PRE_setup_early_r0.s0 PRENative96.s1 PRENative128.s1
    PRE_setup_early_r0.S0 PRENative96.originalS1 PRENative128.originalS1
    PRENative96.prefix_checked PRENative128.checked

end Host.Load.Run.Tpl
