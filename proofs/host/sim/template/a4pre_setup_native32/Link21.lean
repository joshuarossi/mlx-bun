import host.sim.template.a4pre_setup_native32.Link21States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative704 0
host_stream_state PRENative704 1

noncomputable def PRENative704.originalS1 : SSrv :=
  ⟨PRENative704.S1.tab, PRENative672.originalS1.oracle.drop PRENative704.O.length⟩

kernel_rfl PRENative704.start_exact : PRENative704.s0 = PRENative672.s1
kernel_rfl PRENative704.tab_exact : PRENative704.S0.tab = PRENative672.originalS1.tab
kernel_rfl PRENative704.oracle_prefix : PRENative672.originalS1.oracle.take PRENative704.O.length = PRENative704.O

kernel_rfl PRENative704.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative672.s1 PRENative672.originalS1 =
    some (PRENative704.s1, PRENative704.originalS1)

theorem PRENative704.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 704 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative704.s1, PRENative704.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 672 32
    PRE_setup_early_r0.s0 PRENative672.s1 PRENative704.s1
    PRE_setup_early_r0.S0 PRENative672.originalS1 PRENative704.originalS1
    PRENative672.prefix_checked PRENative704.checked

end Host.Load.Run.Tpl
