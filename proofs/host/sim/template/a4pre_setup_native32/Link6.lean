import host.sim.template.a4pre_setup_native32.Link6States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative224 0
host_stream_state PRENative224 1

noncomputable def PRENative224.originalS1 : SSrv :=
  ⟨PRENative224.S1.tab, PRENative192.originalS1.oracle.drop PRENative224.O.length⟩

kernel_rfl PRENative224.start_exact : PRENative224.s0 = PRENative192.s1
kernel_rfl PRENative224.tab_exact : PRENative224.S0.tab = PRENative192.originalS1.tab
kernel_rfl PRENative224.oracle_prefix : PRENative192.originalS1.oracle.take PRENative224.O.length = PRENative224.O

kernel_rfl PRENative224.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative192.s1 PRENative192.originalS1 =
    some (PRENative224.s1, PRENative224.originalS1)

theorem PRENative224.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 224 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative224.s1, PRENative224.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 192 32
    PRE_setup_early_r0.s0 PRENative192.s1 PRENative224.s1
    PRE_setup_early_r0.S0 PRENative192.originalS1 PRENative224.originalS1
    PRENative192.prefix_checked PRENative224.checked

end Host.Load.Run.Tpl
