import host.sim.template.a4pre_setup_native32.Link26States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative864 0
host_stream_state PRENative864 1

noncomputable def PRENative864.originalS1 : SSrv :=
  ⟨PRENative864.S1.tab, PRENative832.originalS1.oracle.drop PRENative864.O.length⟩

kernel_rfl PRENative864.start_exact : PRENative864.s0 = PRENative832.s1
kernel_rfl PRENative864.tab_exact : PRENative864.S0.tab = PRENative832.originalS1.tab
kernel_rfl PRENative864.oracle_prefix : PRENative832.originalS1.oracle.take PRENative864.O.length = PRENative864.O

kernel_rfl PRENative864.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative832.s1 PRENative832.originalS1 =
    some (PRENative864.s1, PRENative864.originalS1)

theorem PRENative864.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 864 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative864.s1, PRENative864.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 832 32
    PRE_setup_early_r0.s0 PRENative832.s1 PRENative864.s1
    PRE_setup_early_r0.S0 PRENative832.originalS1 PRENative864.originalS1
    PRENative832.prefix_checked PRENative864.checked

end Host.Load.Run.Tpl
