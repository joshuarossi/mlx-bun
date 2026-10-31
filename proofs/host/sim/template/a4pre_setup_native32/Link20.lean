import host.sim.template.a4pre_setup_native32.Link20States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative672 0
host_stream_state PRENative672 1

noncomputable def PRENative672.originalS1 : SSrv :=
  ⟨PRENative672.S1.tab, PRENative640.originalS1.oracle.drop PRENative672.O.length⟩

kernel_rfl PRENative672.start_exact : PRENative672.s0 = PRENative640.s1
kernel_rfl PRENative672.tab_exact : PRENative672.S0.tab = PRENative640.originalS1.tab
kernel_rfl PRENative672.oracle_prefix : PRENative640.originalS1.oracle.take PRENative672.O.length = PRENative672.O

kernel_rfl PRENative672.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative640.s1 PRENative640.originalS1 =
    some (PRENative672.s1, PRENative672.originalS1)

theorem PRENative672.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 672 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative672.s1, PRENative672.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 640 32
    PRE_setup_early_r0.s0 PRENative640.s1 PRENative672.s1
    PRE_setup_early_r0.S0 PRENative640.originalS1 PRENative672.originalS1
    PRENative640.prefix_checked PRENative672.checked

end Host.Load.Run.Tpl
