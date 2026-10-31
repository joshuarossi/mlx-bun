import host.sim.template.a4pre_setup_native32.Link7States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative256 0
host_stream_state PRENative256 1

noncomputable def PRENative256.originalS1 : SSrv :=
  ⟨PRENative256.S1.tab, PRENative224.originalS1.oracle.drop PRENative256.O.length⟩

kernel_rfl PRENative256.start_exact : PRENative256.s0 = PRENative224.s1
kernel_rfl PRENative256.tab_exact : PRENative256.S0.tab = PRENative224.originalS1.tab
kernel_rfl PRENative256.oracle_prefix : PRENative224.originalS1.oracle.take PRENative256.O.length = PRENative256.O

kernel_rfl PRENative256.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative224.s1 PRENative224.originalS1 =
    some (PRENative256.s1, PRENative256.originalS1)

theorem PRENative256.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 256 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative256.s1, PRENative256.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 224 32
    PRE_setup_early_r0.s0 PRENative224.s1 PRENative256.s1
    PRE_setup_early_r0.S0 PRENative224.originalS1 PRENative256.originalS1
    PRENative224.prefix_checked PRENative256.checked

end Host.Load.Run.Tpl
