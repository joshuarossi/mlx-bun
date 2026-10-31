import host.sim.template.a4pre_setup_native32.Link19States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative640 0
host_stream_state PRENative640 1

noncomputable def PRENative640.originalS1 : SSrv :=
  ⟨PRENative640.S1.tab, PRENative608.originalS1.oracle.drop PRENative640.O.length⟩

kernel_rfl PRENative640.start_exact : PRENative640.s0 = PRENative608.s1
kernel_rfl PRENative640.tab_exact : PRENative640.S0.tab = PRENative608.originalS1.tab
kernel_rfl PRENative640.oracle_prefix : PRENative608.originalS1.oracle.take PRENative640.O.length = PRENative640.O

kernel_rfl PRENative640.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative608.s1 PRENative608.originalS1 =
    some (PRENative640.s1, PRENative640.originalS1)

theorem PRENative640.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 640 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative640.s1, PRENative640.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 608 32
    PRE_setup_early_r0.s0 PRENative608.s1 PRENative640.s1
    PRE_setup_early_r0.S0 PRENative608.originalS1 PRENative640.originalS1
    PRENative608.prefix_checked PRENative640.checked

end Host.Load.Run.Tpl
