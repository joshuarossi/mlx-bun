import host.sim.template.a4pre_setup_native32.Link13States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative448 0
host_stream_state PRENative448 1

noncomputable def PRENative448.originalS1 : SSrv :=
  ⟨PRENative448.S1.tab, PRENative416.originalS1.oracle.drop PRENative448.O.length⟩

kernel_rfl PRENative448.start_exact : PRENative448.s0 = PRENative416.s1
kernel_rfl PRENative448.tab_exact : PRENative448.S0.tab = PRENative416.originalS1.tab
kernel_rfl PRENative448.oracle_prefix : PRENative416.originalS1.oracle.take PRENative448.O.length = PRENative448.O

kernel_rfl PRENative448.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative416.s1 PRENative416.originalS1 =
    some (PRENative448.s1, PRENative448.originalS1)

theorem PRENative448.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 448 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative448.s1, PRENative448.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 416 32
    PRE_setup_early_r0.s0 PRENative416.s1 PRENative448.s1
    PRE_setup_early_r0.S0 PRENative416.originalS1 PRENative448.originalS1
    PRENative416.prefix_checked PRENative448.checked

end Host.Load.Run.Tpl
