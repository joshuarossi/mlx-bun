import host.sim.template.a4pre_setup_native32.Link25States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative832 0
host_stream_state PRENative832 1

noncomputable def PRENative832.originalS1 : SSrv :=
  ⟨PRENative832.S1.tab, PRENative800.originalS1.oracle.drop PRENative832.O.length⟩

kernel_rfl PRENative832.start_exact : PRENative832.s0 = PRENative800.s1
kernel_rfl PRENative832.tab_exact : PRENative832.S0.tab = PRENative800.originalS1.tab
kernel_rfl PRENative832.oracle_prefix : PRENative800.originalS1.oracle.take PRENative832.O.length = PRENative832.O

kernel_rfl PRENative832.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative800.s1 PRENative800.originalS1 =
    some (PRENative832.s1, PRENative832.originalS1)

theorem PRENative832.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 832 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative832.s1, PRENative832.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 800 32
    PRE_setup_early_r0.s0 PRENative800.s1 PRENative832.s1
    PRE_setup_early_r0.S0 PRENative800.originalS1 PRENative832.originalS1
    PRENative800.prefix_checked PRENative832.checked

end Host.Load.Run.Tpl
