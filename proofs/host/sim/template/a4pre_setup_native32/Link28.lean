import host.sim.template.a4pre_setup_native32.Link28States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative897 0
host_stream_state PRENative897 1

noncomputable def PRENative897.originalS1 : SSrv :=
  ⟨PRENative897.S1.tab, PRENative896.originalS1.oracle.drop PRENative897.O.length⟩

kernel_rfl PRENative897.start_exact : PRENative897.s0 = PRENative896.s1
kernel_rfl PRENative897.tab_exact : PRENative897.S0.tab = PRENative896.originalS1.tab
kernel_rfl PRENative897.oracle_prefix : PRENative896.originalS1.oracle.take PRENative897.O.length = PRENative897.O

kernel_rfl PRENative897.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 1 PRENative896.s1 PRENative896.originalS1 =
    some (PRENative897.s1, PRENative897.originalS1)

theorem PRENative897.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 897 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative897.s1, PRENative897.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 896 1
    PRE_setup_early_r0.s0 PRENative896.s1 PRENative897.s1
    PRE_setup_early_r0.S0 PRENative896.originalS1 PRENative897.originalS1
    PRENative896.prefix_checked PRENative897.checked

end Host.Load.Run.Tpl
