import host.sim.template.a4pre_setup_native32.Link18States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative608 0
host_stream_state PRENative608 1

noncomputable def PRENative608.originalS1 : SSrv :=
  ⟨PRENative608.S1.tab, PRENative576.originalS1.oracle.drop PRENative608.O.length⟩

kernel_rfl PRENative608.start_exact : PRENative608.s0 = PRENative576.s1
kernel_rfl PRENative608.tab_exact : PRENative608.S0.tab = PRENative576.originalS1.tab
kernel_rfl PRENative608.oracle_prefix : PRENative576.originalS1.oracle.take PRENative608.O.length = PRENative608.O

kernel_rfl PRENative608.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative576.s1 PRENative576.originalS1 =
    some (PRENative608.s1, PRENative608.originalS1)

theorem PRENative608.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 608 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative608.s1, PRENative608.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 576 32
    PRE_setup_early_r0.s0 PRENative576.s1 PRENative608.s1
    PRE_setup_early_r0.S0 PRENative576.originalS1 PRENative608.originalS1
    PRENative576.prefix_checked PRENative608.checked

end Host.Load.Run.Tpl
