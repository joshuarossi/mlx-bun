import host.sim.template.a4pre_setup_native32.Link16States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative544 0
host_stream_state PRENative544 1

noncomputable def PRENative544.originalS1 : SSrv :=
  ⟨PRENative544.S1.tab, PRENative512.originalS1.oracle.drop PRENative544.O.length⟩

kernel_rfl PRENative544.start_exact : PRENative544.s0 = PRENative512.s1
kernel_rfl PRENative544.tab_exact : PRENative544.S0.tab = PRENative512.originalS1.tab
kernel_rfl PRENative544.oracle_prefix : PRENative512.originalS1.oracle.take PRENative544.O.length = PRENative544.O

kernel_rfl PRENative544.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative512.s1 PRENative512.originalS1 =
    some (PRENative544.s1, PRENative544.originalS1)

theorem PRENative544.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 544 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative544.s1, PRENative544.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 512 32
    PRE_setup_early_r0.s0 PRENative512.s1 PRENative544.s1
    PRE_setup_early_r0.S0 PRENative512.originalS1 PRENative544.originalS1
    PRENative512.prefix_checked PRENative544.checked

end Host.Load.Run.Tpl
