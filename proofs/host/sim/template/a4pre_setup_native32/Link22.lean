import host.sim.template.a4pre_setup_native32.Link22States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative736 0
host_stream_state PRENative736 1

noncomputable def PRENative736.originalS1 : SSrv :=
  ⟨PRENative736.S1.tab, PRENative704.originalS1.oracle.drop PRENative736.O.length⟩

kernel_rfl PRENative736.start_exact : PRENative736.s0 = PRENative704.s1
kernel_rfl PRENative736.tab_exact : PRENative736.S0.tab = PRENative704.originalS1.tab
kernel_rfl PRENative736.oracle_prefix : PRENative704.originalS1.oracle.take PRENative736.O.length = PRENative736.O

kernel_rfl PRENative736.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative704.s1 PRENative704.originalS1 =
    some (PRENative736.s1, PRENative736.originalS1)

theorem PRENative736.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 736 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative736.s1, PRENative736.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 704 32
    PRE_setup_early_r0.s0 PRENative704.s1 PRENative736.s1
    PRE_setup_early_r0.S0 PRENative704.originalS1 PRENative736.originalS1
    PRENative704.prefix_checked PRENative736.checked

end Host.Load.Run.Tpl
