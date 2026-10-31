import host.sim.template.a4pre_setup_native32.Link14States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative480 0
host_stream_state PRENative480 1

noncomputable def PRENative480.originalS1 : SSrv :=
  ⟨PRENative480.S1.tab, PRENative448.originalS1.oracle.drop PRENative480.O.length⟩

kernel_rfl PRENative480.start_exact : PRENative480.s0 = PRENative448.s1
kernel_rfl PRENative480.tab_exact : PRENative480.S0.tab = PRENative448.originalS1.tab
kernel_rfl PRENative480.oracle_prefix : PRENative448.originalS1.oracle.take PRENative480.O.length = PRENative480.O

kernel_rfl PRENative480.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative448.s1 PRENative448.originalS1 =
    some (PRENative480.s1, PRENative480.originalS1)

theorem PRENative480.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 480 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative480.s1, PRENative480.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 448 32
    PRE_setup_early_r0.s0 PRENative448.s1 PRENative480.s1
    PRE_setup_early_r0.S0 PRENative448.originalS1 PRENative480.originalS1
    PRENative448.prefix_checked PRENative480.checked

end Host.Load.Run.Tpl
