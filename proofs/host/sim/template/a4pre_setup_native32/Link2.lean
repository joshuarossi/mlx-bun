import host.sim.template.a4pre_setup_native32.Link2States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative96 0
host_stream_state PRENative96 1

noncomputable def PRENative96.originalS1 : SSrv :=
  ⟨PRENative96.S1.tab, PRENative64.originalS1.oracle.drop PRENative96.O.length⟩

kernel_rfl PRENative96.start_exact : PRENative96.s0 = PRENative64.s1
kernel_rfl PRENative96.tab_exact : PRENative96.S0.tab = PRENative64.originalS1.tab
kernel_rfl PRENative96.oracle_prefix : PRENative64.originalS1.oracle.take PRENative96.O.length = PRENative96.O

kernel_rfl PRENative96.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative64.s1 PRENative64.originalS1 =
    some (PRENative96.s1, PRENative96.originalS1)

theorem PRENative96.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 96 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative96.s1, PRENative96.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 64 32
    PRE_setup_early_r0.s0 PRENative64.s1 PRENative96.s1
    PRE_setup_early_r0.S0 PRENative64.originalS1 PRENative96.originalS1
    PRENative64.prefix_checked PRENative96.checked

end Host.Load.Run.Tpl
