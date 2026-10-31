import host.sim.template.a4pre_setup_native32.Link17States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative576 0
host_stream_state PRENative576 1

noncomputable def PRENative576.originalS1 : SSrv :=
  ⟨PRENative576.S1.tab, PRENative544.originalS1.oracle.drop PRENative576.O.length⟩

kernel_rfl PRENative576.start_exact : PRENative576.s0 = PRENative544.s1
kernel_rfl PRENative576.tab_exact : PRENative576.S0.tab = PRENative544.originalS1.tab
kernel_rfl PRENative576.oracle_prefix : PRENative544.originalS1.oracle.take PRENative576.O.length = PRENative576.O

kernel_rfl PRENative576.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative544.s1 PRENative544.originalS1 =
    some (PRENative576.s1, PRENative576.originalS1)

theorem PRENative576.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 576 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative576.s1, PRENative576.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 544 32
    PRE_setup_early_r0.s0 PRENative544.s1 PRENative576.s1
    PRE_setup_early_r0.S0 PRENative544.originalS1 PRENative576.originalS1
    PRENative544.prefix_checked PRENative576.checked

end Host.Load.Run.Tpl
