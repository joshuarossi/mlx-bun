import host.sim.template.a4pre_setup_native32.Link27States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative896 0
host_stream_state PRENative896 1

noncomputable def PRENative896.originalS1 : SSrv :=
  ⟨PRENative896.S1.tab, PRENative864.originalS1.oracle.drop PRENative896.O.length⟩

kernel_rfl PRENative896.start_exact : PRENative896.s0 = PRENative864.s1
kernel_rfl PRENative896.tab_exact : PRENative896.S0.tab = PRENative864.originalS1.tab
kernel_rfl PRENative896.oracle_prefix : PRENative864.originalS1.oracle.take PRENative896.O.length = PRENative896.O

kernel_rfl PRENative896.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative864.s1 PRENative864.originalS1 =
    some (PRENative896.s1, PRENative896.originalS1)

theorem PRENative896.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 896 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative896.s1, PRENative896.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 864 32
    PRE_setup_early_r0.s0 PRENative864.s1 PRENative896.s1
    PRE_setup_early_r0.S0 PRENative864.originalS1 PRENative896.originalS1
    PRENative864.prefix_checked PRENative896.checked

end Host.Load.Run.Tpl
