import host.sim.template.a4pre_setup_native32.Link23States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative768 0
host_stream_state PRENative768 1

noncomputable def PRENative768.originalS1 : SSrv :=
  ⟨PRENative768.S1.tab, PRENative736.originalS1.oracle.drop PRENative768.O.length⟩

kernel_rfl PRENative768.start_exact : PRENative768.s0 = PRENative736.s1
kernel_rfl PRENative768.tab_exact : PRENative768.S0.tab = PRENative736.originalS1.tab
kernel_rfl PRENative768.oracle_prefix : PRENative736.originalS1.oracle.take PRENative768.O.length = PRENative768.O

kernel_rfl PRENative768.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative736.s1 PRENative736.originalS1 =
    some (PRENative768.s1, PRENative768.originalS1)

theorem PRENative768.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 768 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative768.s1, PRENative768.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 736 32
    PRE_setup_early_r0.s0 PRENative736.s1 PRENative768.s1
    PRE_setup_early_r0.S0 PRENative736.originalS1 PRENative768.originalS1
    PRENative736.prefix_checked PRENative768.checked

end Host.Load.Run.Tpl
