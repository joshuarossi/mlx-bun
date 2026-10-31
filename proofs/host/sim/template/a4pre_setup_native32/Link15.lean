import host.sim.template.a4pre_setup_native32.Link15States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative512 0
host_stream_state PRENative512 1

noncomputable def PRENative512.originalS1 : SSrv :=
  ⟨PRENative512.S1.tab, PRENative480.originalS1.oracle.drop PRENative512.O.length⟩

kernel_rfl PRENative512.start_exact : PRENative512.s0 = PRENative480.s1
kernel_rfl PRENative512.tab_exact : PRENative512.S0.tab = PRENative480.originalS1.tab
kernel_rfl PRENative512.oracle_prefix : PRENative480.originalS1.oracle.take PRENative512.O.length = PRENative512.O

kernel_rfl PRENative512.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative480.s1 PRENative480.originalS1 =
    some (PRENative512.s1, PRENative512.originalS1)

theorem PRENative512.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 512 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative512.s1, PRENative512.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 480 32
    PRE_setup_early_r0.s0 PRENative480.s1 PRENative512.s1
    PRE_setup_early_r0.S0 PRENative480.originalS1 PRENative512.originalS1
    PRENative480.prefix_checked PRENative512.checked

end Host.Load.Run.Tpl
