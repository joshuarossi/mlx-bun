import host.sim.template.a4pre_setup_native32.Link1States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative64 0
host_stream_state PRENative64 1

noncomputable def PRENative64.originalS1 : SSrv :=
  ⟨PRENative64.S1.tab, PRENative32.originalS1.oracle.drop PRENative64.O.length⟩

kernel_rfl PRENative64.start_exact : PRENative64.s0 = PRENative32.s1
kernel_rfl PRENative64.tab_exact : PRENative64.S0.tab = PRENative32.originalS1.tab
kernel_rfl PRENative64.oracle_prefix :
  PRENative32.originalS1.oracle.take PRENative64.O.length = PRENative64.O

kernel_rfl PRENative64.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32
    PRENative32.s1 PRENative32.originalS1 = some (PRENative64.s1, PRENative64.originalS1)

theorem PRENative64.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 64
      PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative64.s1, PRENative64.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 32
    PRE_setup_early_r0.s0 PRENative32.s1 PRENative64.s1
    PRE_setup_early_r0.S0 PRENative32.originalS1 PRENative64.originalS1
    PRENative32.checked PRENative64.checked

end Host.Load.Run.Tpl
