import host.sim.template.a4pre_setup_native32.Link24States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
host_stream_state PRENative800 0
host_stream_state PRENative800 1

noncomputable def PRENative800.originalS1 : SSrv :=
  ⟨PRENative800.S1.tab, PRENative768.originalS1.oracle.drop PRENative800.O.length⟩

kernel_rfl PRENative800.start_exact : PRENative800.s0 = PRENative768.s1
kernel_rfl PRENative800.tab_exact : PRENative800.S0.tab = PRENative768.originalS1.tab
kernel_rfl PRENative800.oracle_prefix : PRENative768.originalS1.oracle.take PRENative800.O.length = PRENative800.O

kernel_rfl PRENative800.checked :
  runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 32 PRENative768.s1 PRENative768.originalS1 =
    some (PRENative800.s1, PRENative800.originalS1)

theorem PRENative800.prefix_checked :
    runOk PRE_setup_early_r0.F PRE_setup_early_r0.okB0 800 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 =
      some (PRENative800.s1, PRENative800.originalS1) :=
  runOk_trans PRE_setup_early_r0.F PRE_setup_early_r0.okB0 768 32
    PRE_setup_early_r0.s0 PRENative768.s1 PRENative800.s1
    PRE_setup_early_r0.S0 PRENative768.originalS1 PRENative800.originalS1
    PRENative768.prefix_checked PRENative800.checked

end Host.Load.Run.Tpl
